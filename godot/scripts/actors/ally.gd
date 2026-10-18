extends CharacterBody3D
## 카드로 소환한 아군. 직업 분화 v1(docs/mercenary-jobs-design.md):
##  - 나무꾼(lumberjack): 지정 나무를 끝까지 벌목하고 목재를 들고 있다가 마녀가 오면 건넨다. 밤에는 산장 안으로 대피.
##  - 사냥꾼(hunter): 낮에는 토끼·사슴을 활로 사냥해 고기·가죽을 모은다. 적이 오면 원거리 사격, 없으면 산장 주변 정찰.
##  - 전투용병(warrior): 산장 주변을 정찰하다 적이 보이면 근접 전투. 산장이 공격받으면 공격자를 먼저 찾아간다.
##  - 채집가(gatherer): 낮에 랜드마크를 돌며 자원을 줍고 저녁 전에 돌아온다. 밤에는 산장 안으로 대피.
##  - 하수인(minion, 큰 숲의 괴물): 소환 자리 주변의 적과 싸우고, 쓰러지거나 낮이 되면 시들어 목재 1개가 된다.
## 용병은 체력이 0이 되어 쓰러지기 전까지 산장에 남는다. 쓰러지면 산장 뒤편에 무덤이 생기고 들고 있던 자원은 사라진다.

const Cfg := preload("res://scripts/config.gd")
const Layout := preload("res://scripts/world/layout.gd")
const NavUtil := preload("res://scripts/world/nav_util.gd")
const Models := preload("res://scripts/visual/models.gd")
const Fx := preload("res://scripts/visual/fx.gd")
const Sfx := preload("res://scripts/audio/sfx.gd")
const B := preload("res://scripts/visual/build.gd")
const Mats := preload("res://scripts/visual/mats.gd")
const ArrowScript := preload("res://scripts/actors/arrow.gd")

enum State { GO_WORK, WORKING, PATROL, PATROL_WAIT, ENGAGE, HUNT, GATHER_OUT, GATHER_PICK, GATHER_RETURN, IDLE, GO_HIDE, HIDDEN, GUARD, DEAD }

var game
var kind := "merc"            # merc | minion
var job := "warrior"          # lumberjack | hunter | warrior | gatherer | minion
var person := ""
var task := "guard"           # 호환용 요약: chop | guard | gather | idle
var state := State.PATROL
var hp := Cfg.MERC_HP
var max_hp := Cfg.MERC_HP
var dead := false
var hidden := false
var hp_offset := 1.75
var tree = null               # 벌목 대상(world.harvest_trees의 항목)
var work_pos := Vector3.ZERO
var progress := 0.0
var guard_point := Vector3.ZERO
var priority = null           # 우선 공격 대상(카드로 지정한 적·산장 공격자)
var target = null             # 현재 교전 대상
var prey = null               # 사냥 대상(야생 동물)
var attack_cd := 0.0
var carry: Dictionary = {}    # 들고 있는 자원 {card_id: 수량}
var patrol_point := Vector3.ZERO
var patrol_wait := 0.0
var gather_stops: Array = []
var gather_index := 0
var gather_timer := 0.0
var hide_on_arrive := false
var agent: NavigationAgent3D
var visual: Node3D
var body: Node3D
var _anim_t := 0.0
var _lunge_t := 0.0
var _leaf_t := 0.0
var _repath_t := 0.0
var _stuck_t := 0.0          # 움직이려는데 제자리면 누적(구석·막힌 목적지 감시)
var _stuck_ref := Vector3.ZERO
var failed_tree = null       # 가다가 막힌 나무(다음 배정에서 제외)
var _handover_cd := 0.0
var _bow: Node3D
var _rng := RandomNumberGenerator.new()


var card_uid := -1   # 이 활동을 시작한 카드(활동이 끝나면 버림패로)


func setup(g, ally_kind: String, ally_person: String, ally_job: String, pos: Vector3) -> void:
	game = g
	kind = ally_kind
	person = ally_person
	job = ally_job if ally_kind == "merc" else "minion"
	guard_point = pos
	_rng.randomize()
	if kind == "minion":
		hp = Cfg.MINION_HP
		max_hp = Cfg.MINION_HP
		hp_offset = 1.95
		state = State.GUARD
		task = "guard"
	else:
		max_hp = float(Cfg.JOB_HP.get(job, Cfg.MERC_HP))
		hp = max_hp
		match job:
			"lumberjack":
				task = "chop"
				state = State.GO_WORK
			"gatherer":
				task = "gather"
				state = State.IDLE
			_:
				task = "guard"
				state = State.PATROL


func _ready() -> void:
	collision_layer = 0
	collision_mask = Cfg.L_OBSTACLE | Cfg.L_BOUNDARY
	var cs := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.3
	cap.height = 1.1
	cs.shape = cap
	cs.position.y = 0.55
	add_child(cs)
	agent = NavigationAgent3D.new()
	agent.radius = 0.4
	agent.path_desired_distance = 0.35
	agent.target_desired_distance = 0.2
	add_child(agent)
	if kind == "minion":
		visual = Models.make_big_monster()
	else:
		visual = Models.make_traveler(_rng)
		visual.scale = Vector3.ONE * 1.12
	body = visual.get_node("Body")
	add_child(visual)
	if kind == "merc":
		_add_job_props()
	# 아군 표식: 발밑의 따뜻한 고리(적과 구분). 직업별 색.
	var ring_col := Color(0.55, 1.0, 0.65, 0.75)
	if kind == "merc":
		ring_col = {"lumberjack": Color(1.0, 0.82, 0.45, 0.75), "hunter": Color(0.6, 0.95, 0.75, 0.75),
			"warrior": Color(1.0, 0.6, 0.5, 0.75), "gatherer": Color(0.8, 0.75, 1.0, 0.75)}.get(job, Color(1.0, 0.82, 0.45, 0.75))
	var ring := B.torus(self, 0.36, 0.46, Vector3(0, 0.04, 0), Mats.unshaded(ring_col, true, true))
	ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	ring.scale = Vector3(1.0, 0.15, 1.0)
	add_to_group("allies")
	add_to_group("show_hp")
	_anim_t = randf() * 10.0
	Fx.summon(global_position, Color(0.55, 1.0, 0.6) if kind == "minion" else Color(1.0, 0.82, 0.45))
	Sfx.play(self, "minion_spawn" if kind == "minion" else "merc_spawn")
	if job == "gatherer":
		game.contracts.plan_gathering(self)


## 직업 소품: 나무꾼 도끼 / 사냥꾼 활·화살통 / 전투용병 검·방패 / 채집가 바구니.
func _add_job_props() -> void:
	match job:
		"lumberjack":
			var grip := B.node(body, Vector3(0.26, 0.42, 0.06), Vector3(0, 0, -20), "Axe")
			B.cyl(grip, 0.025, 0.03, 0.62, Vector3(0, 0.2, 0), Mats.solid(Color("6b4a2c")), 6)
			B.box(grip, Vector3(0.05, 0.16, 0.2), Vector3(0, 0.46, 0.08), Mats.solid(Color("aeb4c4")))
		"hunter":
			_bow = B.node(body, Vector3(-0.24, 0.5, 0.14), Vector3(0, 0, 0), "Bow")
			var wood := Mats.solid(Color("7a4f2a"))
			for seg in [[Vector3(0, 0.22, 0.05), Vector3(28, 0, 0)], [Vector3(0, 0, 0.11), Vector3(0, 0, 0)], [Vector3(0, -0.22, 0.05), Vector3(-28, 0, 0)]]:
				B.cyl(_bow, 0.016, 0.02, 0.24, seg[0], wood, 6, seg[1])
			B.box(_bow, Vector3(0.006, 0.6, 0.006), Vector3(0, 0, -0.02), Mats.solid(Color("e8e2d0")))
			var quiver := B.node(body, Vector3(-0.12, 0.46, -0.24), Vector3(15, 0, 20), "Quiver")
			B.cyl(quiver, 0.05, 0.06, 0.34, Vector3.ZERO, Mats.solid(Color("5c3a22")), 8)
			for i in 3:
				B.cyl(quiver, 0.006, 0.006, 0.22, Vector3(-0.02 + 0.02 * i, 0.26, 0.015 * (i - 1)), Mats.solid(Color("d8d2c0")), 4)
		"warrior":
			var hilt := B.node(body, Vector3(0.26, 0.4, 0.1), Vector3(-10, 0, -15), "Sword")
			B.cyl(hilt, 0.018, 0.02, 0.14, Vector3(0, 0.0, 0), Mats.solid(Color("5c3a22")), 6)
			B.box(hilt, Vector3(0.14, 0.03, 0.03), Vector3(0, 0.08, 0), Mats.solid(Color("8e8a80")))
			B.box(hilt, Vector3(0.05, 0.5, 0.012), Vector3(0, 0.34, 0), Mats.solid(Color("c8ccd8")))
			var shield := B.node(body, Vector3(-0.27, 0.42, 0.05), Vector3(0, 90, 0), "Shield")
			B.cyl(shield, 0.2, 0.2, 0.03, Vector3.ZERO, Mats.solid(Color("7b4a2e")), 12, Vector3(90, 0, 0))
			B.sphere(shield, 0.05, Vector3(0, 0, 0.03), Mats.solid(Color("aeb4c4")), Vector3(1, 1, 0.5), 8, 4)
		"gatherer":
			var basket := B.node(body, Vector3(0, 0.44, -0.3), Vector3(0, 0, 0), "Basket")
			B.cyl(basket, 0.17, 0.13, 0.26, Vector3.ZERO, Mats.solid(Color("b48a4e")), 10)
			B.torus(basket, 0.15, 0.18, Vector3(0, 0.13, 0), Mats.solid(Color("8a6230")))
			B.sphere(basket, 0.06, Vector3(0.04, 0.16, 0.02), Mats.solid(Color("b8443a")), Vector3.ONE, 6, 3)
			B.sphere(basket, 0.05, Vector3(-0.05, 0.15, -0.03), Mats.solid(Color("8fb36a")), Vector3.ONE, 6, 3)


# ───────────────────────── 명령(ContractDirector가 호출) ─────────────────────────

func set_chop(t, pos: Vector3) -> void:
	tree = t
	work_pos = pos
	task = "chop"
	progress = 0.0
	state = State.GO_WORK


## 임무 없음: 산장 마당의 대기 자리로 걸어가 기다린다.
func become_idle(spot: Vector3) -> void:
	if dead:
		return
	tree = null
	priority = null
	target = null
	prey = null
	guard_point = spot
	state = State.IDLE


## 채집 경로 지정(출발).
func set_gathering(stops: Array) -> void:
	if dead or stops.is_empty():
		return
	gather_stops = stops
	gather_index = 0
	gather_timer = 0.0
	task = "gather"
	state = State.GATHER_OUT


## 채집 중단·귀환(저녁이 가깝거나 웨이브 시작).
func return_home(hide_after: bool) -> void:
	if dead or state == State.HIDDEN or state == State.GO_HIDE:
		return
	hide_on_arrive = hide_after
	guard_point = game.contracts.yard_spot(self)
	state = State.GATHER_RETURN


func is_combat_job() -> bool:
	return job == "hunter" or job == "warrior" or kind == "minion"


func is_noncombat_job() -> bool:
	return job == "lumberjack" or job == "gatherer"


## 일몰(웨이브 시작): 비전투직은 산장 안으로 대피, 전투직은 계속 정찰·교전, 하수인은 그대로.
func interrupt() -> void:
	if dead:
		return
	if is_noncombat_job():
		if state == State.GATHER_OUT or state == State.GATHER_PICK:
			return_home(true)
		else:
			_go_hide()
	elif kind == "merc":
		prey = null
		if state == State.IDLE or state == State.HUNT:
			state = State.PATROL
			_pick_patrol_point()


## 새벽(준비 시작): 대피했던 용병이 나오고, 각 직업이 낮 일을 다시 시작한다.
func resume() -> void:
	if dead:
		return
	if state == State.HIDDEN or state == State.GO_HIDE:
		_unhide()
	hide_on_arrive = false
	match job:
		"lumberjack":
			if tree != null and not tree.get("removed", false) and tree["remaining"] > 0:
				state = State.GO_WORK
			else:
				become_idle(game.contracts.yard_spot(self))
		"gatherer":
			become_idle(game.contracts.yard_spot(self))
			game.contracts.plan_gathering(self)
		"hunter", "warrior":
			if state != State.ENGAGE:
				state = State.PATROL
				_pick_patrol_point()


## 밤의 적이 모두 정리됨: 하수인은 시들어 목재가 되고, 전투직은 정찰을 계속한다.
func end_combat(_spot: Vector3) -> void:
	if dead:
		return
	if kind == "minion":
		game.contracts.wither_minion(self, "낮이 밝아")
		return
	if is_combat_job() and state == State.ENGAGE:
		target = null
		priority = null
		state = State.PATROL
		_pick_patrol_point()


func status_text() -> String:
	var load := carry_total()
	var suffix := " · 보관 %d" % load if load > 0 else ""
	match state:
		State.GO_WORK: return "벌목하러 가는 중" + suffix
		State.WORKING: return "벌목 %d초" % int(ceil(_chop_time() - progress)) + suffix
		State.PATROL, State.PATROL_WAIT: return "정찰 중" + suffix
		State.ENGAGE: return "전투 중" + suffix
		State.HUNT: return "사냥 중" + suffix
		State.GATHER_OUT: return "숲 탐색 중 (%d/%d)" % [gather_index + 1, gather_stops.size()] + suffix
		State.GATHER_PICK: return "줍는 중" + suffix
		State.GATHER_RETURN: return "돌아오는 중" + suffix
		State.GO_HIDE: return "산장으로 대피"
		State.HIDDEN: return "산장 안"
		State.GUARD:
			if target != null:
				return "전투 중"
			return "대기 — 밤 전투" if game.session.state == 0 else "방어 중"
		State.IDLE:
			if job == "lumberjack" and int(carry.get("timber", 0)) >= Cfg.LUMBERJACK_CARRY:
				return "목재 가득 — 쉬며 마녀를 기다림" + suffix
			if load > 0:
				return "마녀를 기다림" + suffix
			if hp >= max_hp:
				return "산장 마당에서 휴식"
			return "모닥불 곁에서 회복 중" if campfire_heal_rate() > 0.0 else "휴식 중 — 모닥불이 꺼져 회복하지 못함"
	return ""


## 지금 이 자리에서 받는 모닥불 낮 회복(초당). 앞마당이 없으면 0.
func campfire_heal_rate() -> float:
	var yard = game.world.yard if game != null and game.world != null else null
	return yard.heal_rate_at(global_position) if yard != null else 0.0


## 다친 전투직이 낮에 켜진 모닥불 곁으로 가 쉬어야 하는가.
func wants_campfire_rest() -> bool:
	if dead or kind != "merc" or not is_combat_job() or hp >= max_hp:
		return false
	if game.session.state != 0:   # 낮(준비 시간)만
		return false
	var yard = game.world.yard if game.world != null else null
	return yard != null and yard.is_lit()


func display_name() -> String:
	if kind == "minion":
		return "숲의 괴물"
	return "%s(%s)" % [person, Cfg.JOB_NAMES.get(job, "")]


func carry_total() -> int:
	var n := 0
	for k in carry:
		n += int(carry[k])
	return n


## 자원을 들고 있게 한다(나무꾼 벌목·사냥꾼 사냥·채집가 줍기).
func add_carry(id: String, amount: int) -> void:
	if amount <= 0:
		return
	carry[id] = int(carry.get(id, 0)) + amount


## 마녀에게 들고 있던 자원을 모두 넘긴다.
func hand_over() -> void:
	if carry.is_empty() or dead:
		return
	var parts: Array = []
	for id in carry.keys():
		var n: int = carry[id]
		game.cards.add(id, n)
		parts.append("%s +%d" % [game.cards.def(id).get("name", id), n])
	carry.clear()
	game.toast("%s — %s을(를) 건네받았습니다" % [person, " · ".join(parts)], Color(1.0, 0.92, 0.7))
	Fx.celebrate(global_position + Vector3(0, 1.4, 0), Color(1.0, 0.9, 0.6), 0.8)
	Sfx.play(self, "wool_get")
	_handover_cd = 1.0


# ───────────────────────── 행동 ─────────────────────────

func _flat(p: Vector3) -> float:
	return Vector2(p.x - global_position.x, p.z - global_position.z).length()


func _flat_from(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()


func _lodge_center() -> Vector3:
	return game.world.lodge.global_position


func _chop_time() -> float:
	return Cfg.RELIC_CHOP_TIME if game.relics != null and game.relics.has("old_tree_heart") else Cfg.CHOP_TIME


func _physics_process(delta: float) -> void:
	if dead:
		return
	if hidden:
		# 산장 안에서 쉬는 동안에도 회복한다
		hp = minf(hp + Cfg.MERC_REGEN * delta, max_hp)
		return
	var vel := Vector3.ZERO
	attack_cd = maxf(attack_cd - delta, 0.0)
	_handover_cd = maxf(_handover_cd - delta, 0.0)
	# 전투직은 어느 상태에서든 적을 발견하면 교전으로 전환한다(산장 공격자 우선).
	if is_combat_job() and kind == "merc" and state != State.ENGAGE:
		var e = _find_enemy()
		if e != null:
			target = e
			prey = null
			state = State.ENGAGE
	match state:
		State.GO_WORK:
			if tree == null or tree.get("removed", false) or tree["remaining"] <= 0:
				game.contracts.assign_next_tree(self)
			elif _flat(work_pos) <= 0.25:
				state = State.WORKING
			else:
				vel = _steer(work_pos)
		State.WORKING:
			if tree == null or tree.get("removed", false):
				game.contracts.assign_next_tree(self)
			else:
				_face(tree["pos"] - global_position, delta)
				progress += delta
				if progress >= _chop_time():
					game.contracts.finish_chop(self)
		State.PATROL:
			if wants_campfire_rest():
				become_idle(game.contracts.yard_spot(self))
			elif _flat(patrol_point) <= 0.4:
				state = State.PATROL_WAIT
				patrol_wait = _rng.randf_range(Cfg.PATROL_PAUSE[0], Cfg.PATROL_PAUSE[1])
			else:
				vel = _steer(patrol_point)
			if job == "hunter" and game.session.state == 0:
				_look_for_prey()
		State.PATROL_WAIT:
			patrol_wait -= delta
			if wants_campfire_rest():
				become_idle(game.contracts.yard_spot(self))
			elif patrol_wait <= 0.0:
				_pick_patrol_point()
				state = State.PATROL
			if job == "hunter" and game.session.state == 0:
				_look_for_prey()
		State.ENGAGE:
			vel = _engage(delta)
		State.HUNT:
			vel = _hunt(delta)
		State.GATHER_OUT:
			vel = _gather_out(delta)
		State.GATHER_PICK:
			gather_timer += delta
			body.rotation.x = 0.35 + sin(gather_timer * 5.0) * 0.08
			if gather_timer >= Cfg.GATHER_PICK_TIME:
				body.rotation.x = 0.0
				game.contracts.gather_pick(self)
				gather_index += 1
				if gather_index >= gather_stops.size() or game.contracts.gather_must_return(self):
					return_home(false)
				else:
					state = State.GATHER_OUT
		State.GATHER_RETURN:
			if _flat(guard_point) <= 0.35:
				if hide_on_arrive:
					_go_hide()
				else:
					become_idle(guard_point)
			else:
				vel = _steer(guard_point)
		State.IDLE:
			# 모닥불에서 쉬던 전투직: 다 나았거나 불이 꺼지면 정찰로 돌아간다
			if is_combat_job() and kind == "merc" and not wants_campfire_rest():
				state = State.PATROL
				_pick_patrol_point()
			else:
				vel = _steer(guard_point) if _flat(guard_point) > 0.35 else Vector3.ZERO
		State.GO_HIDE:
			var door := Layout.DOOR_FRONT
			if _flat(door) <= 0.5:
				_enter_lodge()
			else:
				vel = _steer(door)
		State.GUARD:
			vel = _guard(delta)
	# 낮에는 켜진 모닥불 곁에서만 아주 천천히 회복한다(docs/resource-uses-expansion-v01.md v0.3).
	# 화로의 온기석이 있으면 밤에도 산장 곁에서 회복한다.
	if kind == "merc" and hp < max_hp:
		var day: bool = game.session.state == 0
		var ember: bool = game.relics != null and game.relics.has("hearth_ember") and _flat(_lodge_center()) <= Cfg.RELIC_EMBER_RADIUS
		if day:
			hp = minf(hp + campfire_heal_rate() * delta, max_hp)
		elif ember:
			hp = minf(hp + Cfg.RELIC_EMBER_REGEN * delta, max_hp)
	_check_handover()
	_watch_stuck(vel, delta)
	velocity = vel
	var walking := vel.length() > 0.05
	if walking:
		_face(vel, delta)
		if kind == "minion":
			_shed_leaves(delta, vel)
	move_and_slide()
	global_position.y = 0.0
	_animate(delta, walking)


## 마녀가 가까이 오면 들고 있던 자원을 넘긴다.
func _check_handover() -> void:
	if carry.is_empty() or _handover_cd > 0.0 or game.player == null or game.player.dead:
		return
	if _flat(game.player.global_position) <= Cfg.HANDOVER_RANGE:
		_face(game.player.global_position - global_position, 0.2)
		hand_over()


func _steer(p: Vector3) -> Vector3:
	_repath_t -= get_physics_process_delta_time()
	if _repath_t <= 0.0 or agent.target_position.distance_to(p) > 0.3:
		agent.target_position = p
		_repath_t = 0.4
	var next := agent.get_next_path_position()
	var d := next - global_position
	d.y = 0.0
	var speed := Cfg.BIG_MONSTER_SPEED + 0.3 if kind == "minion" else Cfg.MERC_SPEED
	var v := d.normalized() * speed if d.length() > 0.05 else Vector3.ZERO
	return v + _separation()


# ── 정찰 ──

func _pick_patrol_point() -> void:
	var c := _lodge_center()
	var map: RID = get_world_3d().navigation_map
	for i in 12:
		var a := _rng.randf_range(0.0, TAU)
		var r := _rng.randf_range(Cfg.PATROL_RADIUS[0], Cfg.PATROL_RADIUS[1])
		var p := c + Vector3(cos(a) * r, 0, sin(a) * r)
		# 앞마당·양옆만 정찰한다. 산장 뒤(후면 띠·목장 뒤 구석)는 막다른 포켓이라 제외.
		if p.z < -0.5 or Layout.in_rear_enclosure(Vector2(p.x, p.z)):
			continue
		# 지면 내비 점이고 지금 자리에서 경로가 닿아야 한다(장애물 윗면 섬·막힌 포켓 제외).
		var nav = NavUtil.walkable_from(map, global_position, p, 1.5, 0.6)
		if nav == null:
			continue
		if game.world.pasture.inside(nav, 0.3) or game.world.lodge.distance_to(nav) < 0.8:
			continue
		patrol_point = nav
		return
	patrol_point = Layout.DOOR_FRONT + Vector3(_rng.randf_range(-1.5, 1.5), 0, 1.0 + _rng.randf_range(0.0, 1.5))


# ── 교전 ──

func _valid_enemy(e) -> bool:
	return e != null and is_instance_valid(e) and not e.dead


## 교전 대상 찾기: 산장 공격자 → 카드로 지정한 적 → 산장 근처(ENGAGE_RADIUS)의 웨이브 적.
func _find_enemy():
	var threat = game.contracts.lodge_threat
	if _valid_enemy(threat):
		return threat
	if _valid_enemy(priority):
		return priority
	var c := _lodge_center()
	var best = null
	var best_d := Cfg.ENGAGE_RADIUS
	for e in get_tree().get_nodes_in_group("wave_enemies"):
		if not _valid_enemy(e):
			continue
		var d := _flat_from(c, e.global_position)
		if d <= best_d:
			best_d = d
			best = e
	return best


func _damage_mult() -> float:
	if kind == "merc" and game.relics != null and game.relics.has("wolf_fang_pendant"):
		return Cfg.RELIC_FANG_MULT
	return 1.0


func _engage(delta: float) -> Vector3:
	if not _valid_enemy(target) or _flat_from(_lodge_center(), target.global_position) > Cfg.DISENGAGE_RADIUS:
		target = _find_enemy()
		if target == null:
			priority = null
			state = State.PATROL
			_pick_patrol_point()
			return Vector3.ZERO
	var threat = game.contracts.lodge_threat
	if _valid_enemy(threat) and target != threat:
		target = threat
	var d := _flat(target.global_position)
	if job == "hunter":
		if d <= Cfg.HUNTER_RANGE:
			_face(target.global_position - global_position, delta)
			if attack_cd <= 0.0:
				attack_cd = Cfg.HUNTER_INTERVAL
				_shoot(target, Cfg.HUNTER_DAMAGE * _damage_mult())
			if d < Cfg.HUNTER_KITE:
				var away: Vector3 = (global_position - target.global_position)
				away.y = 0.0
				return away.normalized() * Cfg.MERC_SPEED * 0.8 + _separation()
			return Vector3.ZERO
		return _steer(target.global_position)
	# 전투용병: 근접
	if d <= Cfg.ALLY_MELEE:
		_face(target.global_position - global_position, delta)
		if attack_cd <= 0.0:
			attack_cd = Cfg.WARRIOR_INTERVAL
			_lunge_t = 0.3
			Fx.slash(global_position + Vector3(0, 0.8, 0), target.global_position - global_position)
			target.take_damage(Cfg.WARRIOR_DAMAGE * _damage_mult())
			Sfx.play(self, "ally_attack")
		return Vector3.ZERO
	return _steer(target.global_position)


func _shoot(at, dmg: float) -> void:
	var arrow := ArrowScript.new()
	arrow.target = at
	arrow.damage = dmg
	arrow.shooter = self
	game.actors.add_child(arrow)
	arrow.global_position = global_position + Vector3(0, 1.0, 0)
	_lunge_t = 0.25
	Sfx.play(self, "ally_attack")


# ── 사냥 ──

func _look_for_prey() -> void:
	var best = null
	var best_d := Cfg.HUNT_SEARCH_RADIUS
	for a in get_tree().get_nodes_in_group("animals"):
		if a.dead:
			continue
		var d := _flat(a.global_position)
		if d < best_d:
			best_d = d
			best = a
	if best != null:
		prey = best
		state = State.HUNT


func _hunt(delta: float) -> Vector3:
	if prey == null or not is_instance_valid(prey) or prey.dead or game.session.state != 0:
		prey = null
		state = State.PATROL
		_pick_patrol_point()
		return Vector3.ZERO
	var d := _flat(prey.global_position)
	if d <= Cfg.HUNTER_RANGE - 0.4:
		_face(prey.global_position - global_position, delta)
		if attack_cd <= 0.0:
			attack_cd = Cfg.HUNTER_INTERVAL
			_shoot(prey, Cfg.HUNTER_DAMAGE)
		return Vector3.ZERO
	return _steer(prey.global_position)


## 화살에 맞은 사냥감이 쓰러짐: 전리품을 들고 있는다(늑대 송곳니 목걸이면 +1).
func receive_loot(loot: Dictionary) -> void:
	if dead:
		return
	var bonus: int = Cfg.RELIC_FANG_DROP if game.relics != null and game.relics.has("wolf_fang_pendant") else 0
	var parts: Array = []
	for id in loot:
		var n: int = int(loot[id]) + (bonus if loot.keys()[0] == id else 0)
		add_carry(id, n)
		parts.append("%s +%d" % [game.cards.def(id).get("name", id), n])
	game.toast("%s — 사냥 성공: %s (들고 있음)" % [person, " · ".join(parts)], Color(0.9, 1.0, 0.85))


# ── 채집 ──

func _gather_out(_delta: float) -> Vector3:
	if gather_index >= gather_stops.size():
		return_home(false)
		return Vector3.ZERO
	if game.contracts.gather_must_return(self):
		return_home(false)
		return Vector3.ZERO
	var stop: Vector3 = gather_stops[gather_index]
	if _flat(stop) <= 0.5:
		gather_timer = 0.0
		state = State.GATHER_PICK
		return Vector3.ZERO
	return _steer(stop)


# ── 대피 ──

func _go_hide() -> void:
	target = null
	prey = null
	state = State.GO_HIDE


func _enter_lodge() -> void:
	hidden = true
	state = State.HIDDEN
	visible = false
	collision_mask = 0
	remove_from_group("show_hp")
	Fx.poof(Layout.DOOR_FRONT + Vector3(0, 0.6, 0), Color(1.0, 0.85, 0.6), 0.6)
	Sfx.play(self, "panel_close")


func _unhide() -> void:
	hidden = false
	visible = true
	collision_mask = Cfg.L_OBSTACLE | Cfg.L_BOUNDARY
	global_position = Layout.DOOR_FRONT + Vector3(_rng.randf_range(-0.4, 0.4), 0, 0.6)
	if not is_in_group("show_hp"):
		add_to_group("show_hp")
	Fx.poof(global_position + Vector3(0, 0.6, 0), Color(1.0, 0.85, 0.6), 0.6)


# ── 하수인(기존 방식) ──

func _guard(delta: float) -> Vector3:
	if target != null and (not is_instance_valid(target) or target.dead):
		target = null
	if priority != null and (not is_instance_valid(priority) or priority.dead):
		priority = null
	if priority != null:
		target = priority
	elif target == null or _flat_from(guard_point, target.global_position) > Cfg.ALLY_LEASH:
		target = _nearest_enemy()
	if target == null:
		return _steer(guard_point) if _flat(guard_point) > 0.35 else Vector3.ZERO
	if _flat(target.global_position) <= Cfg.ALLY_MELEE:
		_face(target.global_position - global_position, delta)
		if attack_cd <= 0.0:
			attack_cd = Cfg.MINION_INTERVAL
			_lunge_t = 0.3
			Fx.claw(global_position + Vector3(0, 0.7, 0), target.global_position - global_position, Color(0.5, 1.0, 0.55))
			target.take_damage(Cfg.MINION_DAMAGE)
			Sfx.play(self, "ally_attack")
		return Vector3.ZERO
	return _steer(target.global_position)


func _nearest_enemy():
	var best = null
	var best_d := Cfg.ALLY_AGGRO
	for e in get_tree().get_nodes_in_group("enemies"):
		if e.dead:
			continue
		var d := _flat_from(guard_point, e.global_position)
		if d <= best_d:
			best_d = d
			best = e
	return best


func _separation() -> Vector3:
	var push := Vector3.ZERO
	for a in get_tree().get_nodes_in_group("allies"):
		if a == self or a.hidden:
			continue
		var d: Vector3 = global_position - a.global_position
		d.y = 0.0
		var l := d.length()
		if l > 0.001 and l < 0.7:
			push += d / l * (0.7 - l)
	return push


func _face(dir: Vector3, delta: float) -> void:
	dir.y = 0.0
	if dir.length() < 0.01:
		return
	visual.rotation.y = lerp_angle(visual.rotation.y, atan2(dir.x, dir.z), clampf(delta * 9.0, 0.0, 1.0))


func _animate(delta: float, walking: bool) -> void:
	_anim_t += delta * (8.0 if walking else 2.0)
	body.position.y = absf(sin(_anim_t)) * (0.06 if walking else 0.0)
	if state == State.WORKING:
		# 도끼질: 앞으로 크게 숙였다 펴기
		var k := maxf(sin(progress * 6.0), 0.0)
		body.rotation.x = k * 0.45
		if fmod(progress, TAU / 6.0) < delta and tree != null:
			var tp: Vector3 = tree["pos"]
			Fx.wood_chips(tp + (global_position - tp).normalized() * 0.35 + Vector3(0, 0.7, 0), tp + Vector3(0, 3.5, 0))
			_shake_tree(tree["visual"])
			Sfx.play(self, "chop")
	elif state == State.GATHER_PICK:
		pass  # 줍기 숙임은 상태 처리에서
	elif _lunge_t > 0.0:
		_lunge_t -= delta
		var k2 := sin(clampf(_lunge_t / 0.3, 0.0, 1.0) * PI)
		if job == "hunter":
			body.rotation.x = -k2 * 0.12
			if _bow != null:
				_bow.position.z = 0.14 + k2 * 0.1
		else:
			body.position.z = k2 * 0.25
			body.rotation.x = k2 * 0.4
	else:
		body.position.z = 0.0
		body.rotation.x = 0.0


func take_damage(amount: float) -> void:
	if dead or hidden:
		return
	hp = maxf(hp - amount, 0.0)
	if hp <= 0.0 and game.get("chapter") != null and game.chapter != null and game.chapter.try_ward(self):
		hp = 1.0  # 수의: 치명타를 한 번 버틴다
	if hp > 0.0:
		Sfx.play(self, "ally_hurt")
	Fx.flash(visual)
	Fx.damage_number(get_parent(), global_position + Vector3(0, 2.0, 0), amount, Color(1.0, 0.5, 0.45))
	if hp <= 0.0:
		if kind != "minion":
			Sfx.play(self, "merc_die")
		if kind == "minion":
			game.contracts.wither_minion(self, "쓰러져")
			return
		dead = true
		game.contracts.on_ally_died(self)
		_leave_world()
		Fx.vanish(self, Color(0.6, 0.3, 0.3, 0.8))


## 계약 해지(산장 관리): 들고 있던 자원은 마녀에게 넘기고 산장을 떠난다. 계약 카드는 버림패로 가지 않고 없어진다.
func dismiss() -> void:
	if dead or kind != "merc":
		return
	hand_over()
	if tree != null and tree.get("reserved") == self:
		tree["reserved"] = null
	if card_uid >= 0:
		game.cards.release(card_uid)
		card_uid = -1
	dead = true
	_leave_world()
	if hidden:
		queue_free()
	else:
		Fx.vanish(self, Color(1.0, 0.9, 0.65, 0.8), 0.5)


## 하수인 퇴장(시듦): 감독이 목재를 지급한 뒤 호출한다.
func wither_out() -> void:
	if dead:
		return
	dead = true
	_leave_world()
	Fx.wither(global_position + Vector3(0, 0.6, 0))
	Sfx.play(self, "minion_wither")
	Fx.vanish(self, Color(0.55, 0.75, 0.4, 0.8), 0.6)


## 큰 숲의 괴물의 걸음: 등의 가지에서 나뭇잎이 조금씩 떨어진다(표시 전용).
func _shed_leaves(delta: float, vel: Vector3) -> void:
	_leaf_t -= delta
	if _leaf_t > 0.0:
		return
	_leaf_t = randf_range(0.28, 0.5)
	var back := -vel.normalized()
	Fx.leaf_shed(global_position + Vector3(0, 1.45, 0) + back * 0.35, back, 1 if randf() < 0.7 else 2)


func _leave_world() -> void:
	velocity = Vector3.ZERO
	remove_from_group("allies")
	remove_from_group("show_hp")
	collision_mask = 0
	if game.contracts != null:
		game.contracts.on_ally_removed(self)


## 도끼질에 맞은 나무가 움찔 흔들린다(외형만).
func _shake_tree(v: Node3D) -> void:
	if v == null or not is_instance_valid(v) or v.has_meta("fx_shake"):
		return
	v.set_meta("fx_shake", true)
	var base := v.rotation
	var tw := v.create_tween()
	tw.tween_property(v, "rotation", base + Vector3(0.05, 0, -0.05), 0.06)
	tw.tween_property(v, "rotation", base + Vector3(-0.03, 0, 0.03), 0.1)
	tw.tween_property(v, "rotation", base, 0.18).set_trans(Tween.TRANS_SINE)
	tw.tween_callback(func():
		if is_instance_valid(v):
			v.remove_meta("fx_shake"))


# ── 멈춤 감시 ──

## 움직이려는데 2.5초 동안 0.3m 도 못 갔으면 목적지가 막힌 것이다(구석·막힌 포켓·닿을 수 없는 나무).
## 상태별로 목적지를 버리고 다시 고른다. 벽에 부딪혀 제자리에서 진동하는 현상을 끊는다.
func _watch_stuck(vel: Vector3, delta: float) -> void:
	if vel.length() <= 0.05:
		_stuck_t = 0.0
		_stuck_ref = global_position
		return
	_stuck_t += delta
	if _stuck_t < 2.5:
		return
	var moved := _flat(_stuck_ref)
	_stuck_t = 0.0
	_stuck_ref = global_position
	if moved >= 0.3:
		return
	match state:
		State.PATROL:
			_pick_patrol_point()
		State.GO_WORK:
			failed_tree = tree
			if tree != null and tree.get("reserved") == self:
				tree["reserved"] = null
			tree = null
			game.contracts.assign_next_tree(self)
		State.IDLE, State.GATHER_RETURN:
			guard_point = game.contracts.yard_spot(self)
		State.GATHER_OUT:
			gather_index += 1
		State.ENGAGE, State.HUNT, State.GUARD:
			# 대상이 닿을 수 없는 곳이면 놓아준다
			target = null
			prey = null
			if state != State.GUARD:
				state = State.PATROL
				_pick_patrol_point()
		_:
			pass
