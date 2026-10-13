extends CharacterBody3D
## 카드로 소환한 아군: 도끼 용병(벌목 또는 전투 한 임무) / 숲의 괴물 하수인(전투).
## 계약은 사용 시 이미 소비되었다. 임무를 마친 용병은 걸어서 귀가하며 카드로 돌아오지 않는다.

const Cfg := preload("res://scripts/config.gd")
const Layout := preload("res://scripts/world/layout.gd")
const Models := preload("res://scripts/visual/models.gd")
const Fx := preload("res://scripts/visual/fx.gd")
const B := preload("res://scripts/visual/build.gd")
const Mats := preload("res://scripts/visual/mats.gd")

enum State { GO_WORK, WORKING, WAITING, GUARD, RETURNING, DEAD }

var game
var kind := "merc"            # merc | minion
var person := ""
var task := "guard"           # chop | guard
var state := State.GUARD
var hp := Cfg.MERC_HP
var max_hp := Cfg.MERC_HP
var dead := false
var hp_offset := 1.75
var tree = null               # 벌목 대상(world.harvest_trees의 항목)
var work_pos := Vector3.ZERO
var progress := 0.0
var guard_point := Vector3.ZERO
var priority = null
var target = null
var attack_cd := 0.0
var agent: NavigationAgent3D
var visual: Node3D
var body: Node3D
var _anim_t := 0.0
var _lunge_t := 0.0
var _return_t := 0.0
var _repath_t := 0.0


func setup(g, ally_kind: String, ally_person: String, ally_task: String, pos: Vector3) -> void:
	game = g
	kind = ally_kind
	person = ally_person
	task = ally_task
	guard_point = pos
	if kind == "minion":
		hp = Cfg.MINION_HP
		max_hp = Cfg.MINION_HP
		hp_offset = 1.5
	state = State.GO_WORK if task == "chop" else State.GUARD


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
		visual = Models.make_monster()
	else:
		var rng := RandomNumberGenerator.new()
		rng.randomize()
		visual = Models.make_traveler(rng)
		visual.scale = Vector3.ONE * 1.12
	body = visual.get_node("Body")
	add_child(visual)
	if kind == "merc":
		_add_axe()
	# 아군 표식: 발밑의 따뜻한 고리(적과 구분)
	var ring_col := Color(0.55, 1.0, 0.65, 0.75) if kind == "minion" else Color(1.0, 0.82, 0.45, 0.75)
	var ring := B.torus(self, 0.36, 0.46, Vector3(0, 0.04, 0), Mats.unshaded(ring_col, true, true))
	ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	ring.scale = Vector3(1.0, 0.15, 1.0)
	add_to_group("allies")
	add_to_group("show_hp")
	_anim_t = randf() * 10.0
	Fx.burst(get_parent(), global_position + Vector3(0, 0.8, 0), Color(1.0, 0.85, 0.55), 22, 2.6, 0.22, 0.7, true, -1.5)


func _add_axe() -> void:
	var grip := B.node(body, Vector3(0.26, 0.42, 0.06), Vector3(0, 0, -20), "Axe")
	B.cyl(grip, 0.025, 0.03, 0.62, Vector3(0, 0.2, 0), Mats.solid(Color("6b4a2c")), 6)
	B.box(grip, Vector3(0.05, 0.16, 0.2), Vector3(0, 0.46, 0.08), Mats.solid(Color("aeb4c4")))


# ───────────────────────── 명령(ContractDirector가 호출) ─────────────────────────

func set_chop(t, pos: Vector3) -> void:
	tree = t
	work_pos = pos
	state = State.GO_WORK


## 일몰·원정 전투 시작: 벌목을 중단하고 산장 앞에서 대기(진척 보존).
func interrupt() -> void:
	if dead or task != "chop":
		return
	if state == State.GO_WORK or state == State.WORKING:
		state = State.WAITING
		_go(Layout.DOOR_FRONT + Vector3(1.4 + randf_range(-0.4, 0.4), 0, 0.9))


## 다음 안전한 낮: 같은 계약으로 재개(추가 결제 없음).
func resume() -> void:
	if dead or state != State.WAITING:
		return
	state = State.GO_WORK


## 전투 계약 종료(밤의 적이 모두 정리됨).
func end_combat() -> void:
	if dead or task != "guard":
		return
	if kind == "minion":
		dead = true
		_leave_world()
		Fx.vanish(self, Color(0.5, 0.9, 0.55, 0.8), 0.6)
		return
	go_home()


func go_home() -> void:
	if dead:
		return
	state = State.RETURNING
	_return_t = 0.0
	var exit: Vector3 = Layout.TRAVELER_ROUTE[0]
	_go(NavigationServer3D.map_get_closest_point(get_world_3d().navigation_map, exit))


func status_text() -> String:
	match state:
		State.GO_WORK: return "벌목하러 가는 중"
		State.WORKING: return "벌목 %d초" % int(ceil(Cfg.CHOP_TIME - progress))
		State.WAITING: return "밤 — 산장에서 대기"
		State.GUARD:
			if target != null:
				return "전투 중"
			return "대기 — 밤 전투" if game.session.state == 0 else "방어 중"
		State.RETURNING: return "임무 완료 — 귀가"
	return ""


func display_name() -> String:
	return person if kind == "merc" else "숲의 괴물"


# ───────────────────────── 행동 ─────────────────────────

func _go(p: Vector3) -> void:
	agent.target_position = p


func _flat(p: Vector3) -> float:
	return Vector2(p.x - global_position.x, p.z - global_position.z).length()


func _physics_process(delta: float) -> void:
	if dead:
		return
	var vel := Vector3.ZERO
	var walking := false
	match state:
		State.GO_WORK:
			if _flat(work_pos) <= 0.25:
				state = State.WORKING
			else:
				vel = _steer(work_pos)
		State.WORKING:
			_face(tree["pos"] - global_position, delta)
			progress += delta
			if progress >= Cfg.CHOP_TIME:
				game.contracts.finish_chop(self)
		State.WAITING, State.RETURNING:
			if not agent.is_navigation_finished():
				vel = _steer(agent.target_position)
			if state == State.RETURNING:
				_return_t += delta
				if agent.is_navigation_finished() or _return_t > 30.0:
					dead = true
					_leave_world()
					Fx.vanish(self, Color(0.85, 0.8, 1.0, 0.6), 0.8)
					return
		State.GUARD:
			vel = _guard(delta)
	velocity = vel
	walking = vel.length() > 0.05
	if walking:
		_face(vel, delta)
	move_and_slide()
	global_position.y = 0.0
	_animate(delta, walking)


func _steer(p: Vector3) -> Vector3:
	_repath_t -= get_physics_process_delta_time()
	if _repath_t <= 0.0 or agent.target_position.distance_to(p) > 0.3:
		agent.target_position = p
		_repath_t = 0.4
	var next := agent.get_next_path_position()
	var d := next - global_position
	d.y = 0.0
	var v := d.normalized() * Cfg.MERC_SPEED if d.length() > 0.05 else Vector3.ZERO
	return v + _separation()


func _guard(delta: float) -> Vector3:
	if target != null and (not is_instance_valid(target) or target.dead):
		target = null
	if priority != null and (not is_instance_valid(priority) or priority.dead):
		priority = null
	if priority != null:
		target = priority
	elif target == null or _flat_from(guard_point, target.global_position) > Cfg.ALLY_LEASH:
		target = _nearest_enemy()
	attack_cd = maxf(attack_cd - delta, 0.0)
	if target == null:
		return _steer(guard_point) if _flat(guard_point) > 0.35 else Vector3.ZERO
	if _flat(target.global_position) <= Cfg.ALLY_MELEE:
		_face(target.global_position - global_position, delta)
		if attack_cd <= 0.0:
			attack_cd = Cfg.MINION_INTERVAL if kind == "minion" else Cfg.MERC_INTERVAL
			_lunge_t = 0.3
			target.take_damage(Cfg.MINION_DAMAGE if kind == "minion" else Cfg.MERC_DAMAGE)
		return Vector3.ZERO
	return _steer(target.global_position)


func _flat_from(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()


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
		if a == self:
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
		if fmod(progress, TAU / 6.0) < delta:
			Fx.burst(get_parent(), tree["pos"] + Vector3(0, 0.7, 0), Color(0.85, 0.65, 0.4), 5, 1.6, 0.12, 0.4, false, -4.0)
	elif _lunge_t > 0.0:
		_lunge_t -= delta
		var k2 := sin(clampf(_lunge_t / 0.3, 0.0, 1.0) * PI)
		body.position.z = k2 * 0.25
		body.rotation.x = k2 * 0.4
	else:
		body.position.z = 0.0
		body.rotation.x = 0.0


func take_damage(amount: float) -> void:
	if dead:
		return
	hp = maxf(hp - amount, 0.0)
	Fx.flash(visual)
	if hp <= 0.0:
		dead = true
		game.contracts.on_ally_died(self)
		_leave_world()
		Fx.vanish(self, Color(0.6, 0.3, 0.3, 0.8))


func _leave_world() -> void:
	velocity = Vector3.ZERO
	remove_from_group("allies")
	remove_from_group("show_hp")
	collision_mask = 0
	if game.contracts != null:
		game.contracts.on_ally_removed(self)
