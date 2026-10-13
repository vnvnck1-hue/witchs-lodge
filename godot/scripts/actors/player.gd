extends CharacterBody3D
## 마녀: 클릭 이동 + 사거리 안 가장 가까운 적 자동 공격(이동을 멈추지 않음).

const Cfg := preload("res://scripts/config.gd")
const Models := preload("res://scripts/visual/models.gd")
const Fx := preload("res://scripts/visual/fx.gd")
const B := preload("res://scripts/visual/build.gd")
const BoltScript := preload("res://scripts/actors/magic_bolt.gd")

var game
var hp := Cfg.PLAYER_HP
var max_hp := Cfg.PLAYER_HP
var dead := false
var hp_offset := 2.0
var agent: NavigationAgent3D
var visual: Node3D
var body: Node3D
var staff: Node3D
var staff_tip: Node3D
var target_enemy = null
var attack_cd := 0.0
var moving := false
var _anim_t := 0.0
var _cast_t := 0.0


func _ready() -> void:
	collision_layer = Cfg.L_ACTOR
	collision_mask = Cfg.L_OBSTACLE | Cfg.L_BOUNDARY
	var cs := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.3
	cap.height = 1.2
	cs.shape = cap
	cs.position.y = 0.6
	add_child(cs)
	agent = NavigationAgent3D.new()
	agent.radius = 0.4
	agent.path_desired_distance = 0.3
	agent.target_desired_distance = 0.15
	agent.path_max_distance = 2.0
	add_child(agent)
	var parts := Models.make_witch()
	visual = parts["root"]
	body = parts["body"]
	staff = parts["staff"]
	staff_tip = parts["tip"]
	visual.scale = Vector3.ONE * 1.3
	add_child(visual)
	# 마녀 주변의 아주 약한 보랏빛(어두운 눈밭 위 가독성)
	B.omni(self, Vector3(0, 1.1, 0.3), Color(0.75, 0.6, 1.0), 0.10, 2.2, false, 1.5)
	add_to_group("show_hp")


func set_destination(p: Vector3) -> void:
	if dead:
		return
	agent.target_position = p
	moving = true


func _physics_process(delta: float) -> void:
	if dead:
		return
	var vel := Vector3.ZERO
	if moving:
		if agent.is_navigation_finished():
			moving = false
		else:
			var next := agent.get_next_path_position()
			var d := next - global_position
			d.y = 0.0
			if d.length() > 0.02:
				vel = d.normalized() * Cfg.PLAYER_SPEED
	velocity = vel
	move_and_slide()
	global_position.y = 0.0
	if vel.length() > 0.1:
		var yaw := atan2(vel.x, vel.z)
		visual.rotation.y = lerp_angle(visual.rotation.y, yaw, clampf(delta * 12.0, 0.0, 1.0))
	_update_attack(delta)
	_animate(delta, vel.length() > 0.1)


func _flat_dist(p: Vector3) -> float:
	return Vector2(p.x - global_position.x, p.z - global_position.z).length()


func _has_los(e: Node3D) -> bool:
	var space := get_world_3d().direct_space_state
	var q := PhysicsRayQueryParameters3D.create(global_position + Vector3(0, 0.7, 0), e.global_position + Vector3(0, 0.7, 0), Cfg.L_OBSTACLE)
	return space.intersect_ray(q).is_empty()


func _update_attack(delta: float) -> void:
	var best = null
	var best_d := Cfg.BOLT_RANGE
	for e in get_tree().get_nodes_in_group("enemies"):
		if e.dead:
			continue
		var d := _flat_dist(e.global_position)
		if d <= best_d and _has_los(e):
			best = e
			best_d = d
	var cur_valid: bool = target_enemy != null and is_instance_valid(target_enemy) and not target_enemy.dead
	if best != target_enemy:
		# 살아 있는 타깃에서 다른 타깃으로 바뀌면 간격을 초기화해 연속 발사를 막는다
		if cur_valid and best != null:
			attack_cd = Cfg.BOLT_INTERVAL
		target_enemy = best
	attack_cd = maxf(attack_cd - delta, 0.0)
	if target_enemy != null and attack_cd <= 0.0:
		_fire(target_enemy)
		attack_cd = Cfg.BOLT_INTERVAL


func _fire(e) -> void:
	var bolt := BoltScript.new()
	bolt.target = e
	game.actors.add_child(bolt)
	bolt.global_position = staff_tip.global_position
	_cast_t = 0.3
	var to: Vector3 = e.global_position - global_position
	visual.rotation.y = atan2(to.x, to.z)


func _animate(delta: float, walking: bool) -> void:
	_anim_t += delta * (10.0 if walking else 2.2)
	if walking:
		body.position.y = absf(sin(_anim_t)) * 0.06
		body.rotation.z = sin(_anim_t) * 0.06
	else:
		body.position.y = 0.0
		body.rotation.z = 0.0
		body.scale = Vector3(1.0, 1.0 + sin(_anim_t) * 0.015, 1.0)
	if _cast_t > 0.0:
		_cast_t -= delta
		staff.rotation_degrees.x = 8.0 - 50.0 * sin(clampf(_cast_t / 0.3, 0.0, 1.0) * PI)
	else:
		staff.rotation_degrees.x = 8.0


func take_damage(amount: float) -> void:
	if dead:
		return
	hp = maxf(hp - amount, 0.0)
	Fx.flash(visual)
	if hp <= 0.0:
		dead = true
		velocity = Vector3.ZERO
		visual.rotation_degrees.x = -80.0
		game.session.report_defeat("마녀가 쓰러졌습니다")


func heal(amount: float) -> float:
	var actual := minf(amount, max_hp - hp)
	hp += actual
	if actual > 0.0:
		Fx.burst(get_parent(), global_position + Vector3(0, 0.6, 0), Color(0.75, 1.0, 0.7), 14, 1.5, 0.18, 0.8, true, 1.5)
	return actual
