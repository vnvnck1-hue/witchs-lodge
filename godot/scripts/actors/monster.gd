extends CharacterBody3D
## 일반 몬스터: 출현 시 산장 또는 양을 목표로 배정. 플레이어가 근접하면 플레이어를 공격.

const Cfg := preload("res://scripts/config.gd")
const Models := preload("res://scripts/visual/models.gd")
const Fx := preload("res://scripts/visual/fx.gd")

enum Goal { LODGE, SHEEP }

var game
var hp := 36.0
var max_hp := 36.0
var dead := false
var hp_offset := 1.5
var goal := Goal.LODGE
var attack_point := Vector3.ZERO
var target_sheep = null
var agent: NavigationAgent3D
var visual: Node3D
var body: Node3D
var attack_cd := 0.0
var engaged = null
var path_failed := false
var _repath_t := 0.0
var _stuck_t := 0.0
var _stuck_ref := Vector3.ZERO
var _anim_t := 0.0
var _lunge_t := 0.0


func setup(g, hp_value: float, sheep_goal: bool) -> void:
	game = g
	hp = hp_value
	max_hp = hp_value
	goal = Goal.SHEEP if sheep_goal else Goal.LODGE


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
	agent.path_desired_distance = 0.4
	agent.target_desired_distance = 0.2
	add_child(agent)
	visual = Models.make_monster()
	body = visual.get_node("Body")
	add_child(visual)
	add_to_group("enemies")
	add_to_group("show_hp")
	if goal == Goal.LODGE:
		attack_point = game.world.lodge.claim_attack_point(global_position)
	_anim_t = randf() * 10.0
	_stuck_ref = global_position


func _flat(p: Vector3) -> float:
	return Vector2(p.x - global_position.x, p.z - global_position.z).length()


func _physics_process(delta: float) -> void:
	if dead:
		return
	var lodge = game.world.lodge
	var pasture = game.world.pasture
	var player = game.player
	var attack_target = null
	var face_point := global_position
	var move_target := global_position

	if not player.dead and _flat(player.global_position) <= Cfg.MONSTER_MELEE:
		attack_target = player
		face_point = player.global_position
	else:
		if goal == Goal.SHEEP:
			if target_sheep == null or not is_instance_valid(target_sheep) or target_sheep.dead:
				target_sheep = pasture.nearest_alive_sheep(global_position)
				if target_sheep == null:
					goal = Goal.LODGE
					attack_point = lodge.claim_attack_point(global_position)
		if goal == Goal.SHEEP:
			move_target = target_sheep.global_position
			# 울타리 너머로 공격하지 않도록 목장 안에 들어왔을 때만 공격
			if _flat(move_target) <= Cfg.MONSTER_MELEE and pasture.inside(global_position, 0.05):
				attack_target = target_sheep
				face_point = move_target
		else:
			move_target = attack_point
			if lodge.distance_to(global_position) <= Cfg.MONSTER_MELEE:
				attack_target = lodge
				face_point = lodge.closest_point(global_position)

	if attack_target != null:
		velocity = Vector3.ZERO
		_face(face_point - global_position, delta)
		if attack_target != engaged:
			engaged = attack_target
			attack_cd = 0.5
		attack_cd -= delta
		if attack_cd <= 0.0:
			attack_cd = Cfg.MONSTER_INTERVAL
			_lunge_t = 0.35
			attack_target.take_damage(Cfg.MONSTER_DAMAGE)
		_stuck_t = 0.0
		_stuck_ref = global_position
	else:
		engaged = null
		_repath_t -= delta
		if _repath_t <= 0.0:
			agent.target_position = move_target
			_repath_t = 0.35
		var next := agent.get_next_path_position()
		var dir := next - global_position
		dir.y = 0.0
		var v := Vector3.ZERO
		if dir.length() > 0.05:
			v = dir.normalized() * Cfg.MONSTER_SPEED
		v += _separation() * 1.4
		velocity = v
		if v.length() > 0.05:
			_face(v, delta)
		_check_stuck(delta)
	if not dead:
		move_and_slide()
		global_position.y = 0.0
		_animate(delta, attack_target == null)


func _separation() -> Vector3:
	var push := Vector3.ZERO
	for e in get_tree().get_nodes_in_group("enemies"):
		if e == self:
			continue
		var d: Vector3 = global_position - e.global_position
		d.y = 0.0
		var l := d.length()
		if l > 0.001 and l < 0.8:
			push += d / l * (0.8 - l) / 0.8
	return push


func _check_stuck(delta: float) -> void:
	_stuck_t += delta
	if _stuck_t >= 3.0:
		var moved := _flat(_stuck_ref)
		if moved < 0.3:
			if not path_failed:
				push_warning("몬스터 경로 실패: %s" % str(global_position))
			path_failed = true
			if goal == Goal.LODGE:
				attack_point = game.world.lodge.claim_attack_point(global_position)
		else:
			path_failed = false
		_stuck_t = 0.0
		_stuck_ref = global_position


func _face(dir: Vector3, delta: float) -> void:
	dir.y = 0.0
	if dir.length() < 0.01:
		return
	visual.rotation.y = lerp_angle(visual.rotation.y, atan2(dir.x, dir.z), clampf(delta * 8.0, 0.0, 1.0))


func _animate(delta: float, walking: bool) -> void:
	_anim_t += delta * (7.0 if walking else 2.0)
	body.position.y = absf(sin(_anim_t)) * (0.07 if walking else 0.02)
	body.rotation.z = sin(_anim_t * 0.5) * 0.08
	if _lunge_t > 0.0:
		_lunge_t -= delta
		var k := sin(clampf(_lunge_t / 0.35, 0.0, 1.0) * PI)
		body.position.z = k * 0.3
		body.rotation.x = k * 0.35
	else:
		body.position.z = 0.0
		body.rotation.x = 0.0


func take_damage(amount: float) -> void:
	if dead:
		return
	hp -= amount
	Fx.flash(visual)
	if hp <= 0.0:
		die()


func die() -> void:
	dead = true
	hp = 0.0
	velocity = Vector3.ZERO
	remove_from_group("enemies")
	remove_from_group("show_hp")
	collision_mask = 0
	Fx.vanish(self)
