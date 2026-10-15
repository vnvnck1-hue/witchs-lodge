extends CharacterBody3D
## 카드로 소환한 아군: 도끼 용병(벌목·전투) / 큰 숲의 괴물 하수인(전투).
## 용병은 체력이 0이 되어 쓰러지기 전까지 산장에 남는다. 임무를 마치면 산장 마당에서 대기하고,
## 낮에는 남은 나무를 찾아 벌목하며 밤에는 대기 자리를 지킨다. 쓰러지면 산장 뒤편에 무덤이 생긴다.
## 하수인은 쓰러지거나 낮이 되면 시들어 목재 1개가 된다.

const Cfg := preload("res://scripts/config.gd")
const Layout := preload("res://scripts/world/layout.gd")
const Models := preload("res://scripts/visual/models.gd")
const Fx := preload("res://scripts/visual/fx.gd")
const Sfx := preload("res://scripts/audio/sfx.gd")
const B := preload("res://scripts/visual/build.gd")
const Mats := preload("res://scripts/visual/mats.gd")

enum State { GO_WORK, WORKING, WAITING, GUARD, IDLE, DEAD }

var game
var kind := "merc"            # merc | minion
var person := ""
var task := "guard"           # chop | guard | idle(임무 없음 — 마당 대기)
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
var _leaf_t := 0.0
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
		hp_offset = 1.95
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
		visual = Models.make_big_monster()
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
	Fx.summon(global_position, Color(0.55, 1.0, 0.6) if kind == "minion" else Color(1.0, 0.82, 0.45))
	Sfx.play(self, "minion_spawn" if kind == "minion" else "merc_spawn")


func _add_axe() -> void:
	var grip := B.node(body, Vector3(0.26, 0.42, 0.06), Vector3(0, 0, -20), "Axe")
	B.cyl(grip, 0.025, 0.03, 0.62, Vector3(0, 0.2, 0), Mats.solid(Color("6b4a2c")), 6)
	B.box(grip, Vector3(0.05, 0.16, 0.2), Vector3(0, 0.46, 0.08), Mats.solid(Color("aeb4c4")))


# ───────────────────────── 명령(ContractDirector가 호출) ─────────────────────────

func set_chop(t, pos: Vector3) -> void:
	tree = t
	work_pos = pos
	task = "chop"
	progress = 0.0
	state = State.GO_WORK


## 임무 없음: 산장 마당의 대기 자리로 걸어가 기다린다(낮에는 감독이 다음 나무를 맡긴다).
func become_idle(spot: Vector3) -> void:
	if dead:
		return
	task = "idle"
	tree = null
	priority = null
	target = null
	guard_point = spot
	state = State.IDLE


## 일몰: 벌목을 중단하고 산장 앞 대기 자리를 지킨다(진척 보존). 쉬던 용병도 마당을 지킨다.
func interrupt() -> void:
	if dead:
		return
	if task == "chop" and (state == State.GO_WORK or state == State.WORKING):
		state = State.WAITING
		guard_point = Layout.DOOR_FRONT + Vector3(1.4 + randf_range(-0.4, 0.4), 0, 0.9)
	elif task == "idle":
		state = State.GUARD


## 다음 안전한 낮: 같은 계약으로 벌목 재개(추가 결제 없음). 마당을 지키던 용병은 다시 쉰다.
func resume() -> void:
	if dead:
		return
	if state == State.WAITING:
		target = null
		state = State.GO_WORK
	elif task == "idle" and state == State.GUARD:
		target = null
		state = State.IDLE


## 밤의 적이 모두 정리됨: 전투 임무 용병은 마당으로 돌아가 남고, 하수인은 시들어 목재가 된다.
func end_combat(spot: Vector3) -> void:
	if dead:
		return
	if kind == "minion":
		game.contracts.wither_minion(self, "낮이 밝아")
		return
	if task == "guard":
		become_idle(spot)


func status_text() -> String:
	match state:
		State.GO_WORK: return "벌목하러 가는 중"
		State.WORKING: return "벌목 %d초" % int(ceil(Cfg.CHOP_TIME - progress))
		State.WAITING: return "밤 — 산장 앞 방어" if target == null else "전투 중"
		State.GUARD:
			if target != null:
				return "전투 중"
			return "대기 — 밤 전투" if game.session.state == 0 else "방어 중"
		State.IDLE: return "산장 마당에서 휴식" if hp >= max_hp else "휴식·회복 중"
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
		State.WAITING, State.GUARD:
			vel = _guard(delta)
		State.IDLE:
			vel = _steer(guard_point) if _flat(guard_point) > 0.35 else Vector3.ZERO
			if game.session.state == 0 and hp < max_hp:
				hp = minf(hp + Cfg.MERC_REGEN * delta, max_hp)
	velocity = vel
	walking = vel.length() > 0.05
	if walking:
		_face(vel, delta)
		if kind == "minion":
			_shed_leaves(delta, vel)
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
	var speed := Cfg.BIG_MONSTER_SPEED + 0.3 if kind == "minion" else Cfg.MERC_SPEED
	var v := d.normalized() * speed if d.length() > 0.05 else Vector3.ZERO
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
			if kind == "minion":
				Fx.claw(global_position + Vector3(0, 0.7, 0), target.global_position - global_position, Color(0.5, 1.0, 0.55))
			else:
				Fx.slash(global_position + Vector3(0, 0.8, 0), target.global_position - global_position)
			target.take_damage(Cfg.MINION_DAMAGE if kind == "minion" else Cfg.MERC_DAMAGE)
			Sfx.play(self, "ally_attack")
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
			var tp: Vector3 = tree["pos"]
			Fx.wood_chips(tp + (global_position - tp).normalized() * 0.35 + Vector3(0, 0.7, 0), tp + Vector3(0, 3.5, 0))
			_shake_tree(tree["visual"])
			Sfx.play(self, "chop")
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
	if v == null or v.has_meta("fx_shake"):
		return
	v.set_meta("fx_shake", true)
	var base := v.rotation
	var tw := v.create_tween()
	tw.tween_property(v, "rotation", base + Vector3(0.05, 0, -0.05), 0.06)
	tw.tween_property(v, "rotation", base + Vector3(-0.03, 0, 0.03), 0.1)
	tw.tween_property(v, "rotation", base, 0.18).set_trans(Tween.TRANS_SINE)
	tw.tween_callback(func(): v.remove_meta("fx_shake"))
