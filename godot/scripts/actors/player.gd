extends CharacterBody3D
## 마녀: 클릭 이동 + 사거리 안 가장 가까운 적 자동 공격(이동을 멈추지 않음).

const Cfg := preload("res://scripts/config.gd")
const Layout := preload("res://scripts/world/layout.gd")
const Models := preload("res://scripts/visual/models.gd")
const Fx := preload("res://scripts/visual/fx.gd")
const B := preload("res://scripts/visual/build.gd")
const BoltScript := preload("res://scripts/actors/magic_bolt.gd")
const Mats := preload("res://scripts/visual/mats.gd")

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
var harvest_target = null   # 털 수확을 위해 다가가는 양
var harvest_t := 0.0        # 털 깎기 진행(초). HUD가 작은 게이지로 그린다
var shearing := false
var shears: Node3D
var _shear_blades: Array = []
var _harvest_repath := 0.0
var _shear_fx := 0.0
var _harvest_pathing := false


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
	_build_shears()
	# 마녀 주변의 아주 약한 보랏빛(어두운 눈밭 위 가독성)
	B.omni(self, Vector3(0, 1.1, 0.3), Color(0.75, 0.6, 1.0), 0.10, 2.2, false, 1.5)
	add_to_group("show_hp")


func set_destination(p: Vector3) -> void:
	if dead:
		return
	cancel_harvest()
	agent.target_position = Layout.clamp_to_map(p)
	moving = true


## 양 클릭: 목장 문으로 들어가 양 바로 옆까지 다가간 뒤 HARVEST_TIME 동안 털을 깎는다(v0.3 §7).
func harvest(sheep) -> void:
	if dead or sheep == null or sheep.dead or not sheep.wool_ready:
		return
	cancel_harvest()
	harvest_target = sheep
	sheep.held = true
	_harvest_repath = 0.0
	_harvest_pathing = false
	moving = true


func cancel_harvest() -> void:
	if harvest_target != null and is_instance_valid(harvest_target):
		harvest_target.held = false
		harvest_target.shearing = false
	harvest_target = null
	harvest_t = 0.0
	shearing = false


## 양 옆의 설 자리: 목장 안쪽이면서 문에서 가까운 쪽의 이동 가능 지점.
func _shear_spot(s) -> Vector3:
	var pen = s.pasture
	var gate: Vector3 = pen.gate_center()
	var best: Vector3 = s.global_position
	var best_d := 1e9
	for dir in [Vector3(1, 0, 0), Vector3(0, 0, 1), Vector3(0, 0, -1), Vector3(-1, 0, 0), Vector3(0.7, 0, 0.7), Vector3(0.7, 0, -0.7)]:
		var p: Vector3 = s.global_position + dir * 0.6
		if not pen.inside(p, -0.45):
			continue
		var dd := p.distance_to(gate)
		if dd < best_d:
			best_d = dd
			best = p
	var nav := NavigationServer3D.map_get_closest_point(get_world_3d().navigation_map, best)
	nav.y = 0.0
	return nav


func _update_harvest(delta: float) -> void:
	var s = harvest_target
	if not is_instance_valid(s) or s.dead or not s.wool_ready or game.session.state != 0:
		cancel_harvest()
		moving = false
		return
	var d := _flat_dist(s.global_position)
	# 울타리 너머로 깎지 않도록 목장 안에 들어와 양 옆에 섰을 때만 시작한다
	var in_pen: bool = s.pasture.inside(global_position, 0.0)
	var arrived := in_pen and (d <= Cfg.HARVEST_RANGE or (_harvest_pathing and agent.is_navigation_finished() and d <= 1.3))
	if shearing or arrived:
		moving = false
		shearing = true
		s.held = true
		s.shearing = true
		harvest_t += delta
		var to: Vector3 = s.global_position - global_position
		visual.rotation.y = lerp_angle(visual.rotation.y, atan2(to.x, to.z), clampf(delta * 10.0, 0.0, 1.0))
		_shear_fx -= delta
		if _shear_fx <= 0.0:
			_shear_fx = 0.32
			Fx.shear(s.global_position + Vector3(0, 0.55, 0) - to.normalized() * 0.15)
		if harvest_t >= Cfg.HARVEST_TIME:
			s.wool_ready = false
			cancel_harvest()
			game.cards.add("wool", 1)
			game.toast("양털 +1 (보유 %d)" % game.cards.count_of("wool"), Color(1.0, 0.97, 0.85))
			Fx.wool(s.global_position + Vector3(0, 0.6, 0))
	else:
		_harvest_repath -= delta
		if _harvest_repath <= 0.0:
			agent.target_position = _shear_spot(s)
			_harvest_repath = 0.3
			_harvest_pathing = true
		moving = true


func _build_shears() -> void:
	# 털 깎는 가위: 평소에는 숨기고 털 깎기 중에만 왼손에 든다
	shears = B.node(body, Vector3(-0.2, 0.42, 0.26), Vector3(-70, 0, 0), "Shears")
	var steel := Mats.solid(Color("d8dcea"), {"rim_strength": 0.6})
	var grip := Mats.solid(Color("8a3a4a"))
	for side: float in [-1.0, 1.0]:
		var blade := B.node(shears, Vector3.ZERO, Vector3(0, 0, side * 12.0), "Blade")
		B.box(blade, Vector3(0.025, 0.2, 0.012), Vector3(0, 0.1, 0), steel)
		B.torus(blade, 0.025, 0.04, Vector3(side * 0.03, -0.04, 0), grip, Vector3(90, 0, 0))
		_shear_blades.append(blade)
	shears.scale = Vector3.ONE * 1.6
	shears.visible = false


func _physics_process(delta: float) -> void:
	if dead:
		return
	var vel := Vector3.ZERO
	var stick := Input.get_vector("walk_left","walk_right","walk_up","walk_down") if game.movement_input_allowed() else Vector2.ZERO
	if stick.length_squared() > 0.01:
		cancel_harvest()
		moving = false
		vel = _keyboard_velocity(stick,delta)
	elif harvest_target != null:
		_update_harvest(delta)
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


func _keyboard_velocity(stick: Vector2, delta: float) -> Vector3:
	var cam: Camera3D = game.world.camera
	var right := cam.global_basis.x
	var down := cam.global_basis.z
	right.y = 0.0
	down.y = 0.0
	var direction := (right.normalized()*stick.x + down.normalized()*stick.y).limit_length(1.0)
	var desired := Layout.clamp_to_map(global_position + direction*Cfg.PLAYER_SPEED*delta)
	var nav_map := get_world_3d().navigation_map
	if NavigationServer3D.map_get_iteration_id(nav_map) == 0: return Vector3.ZERO
	var closest := NavigationServer3D.map_get_closest_point(nav_map,desired)
	closest.y = 0.0
	# Never snap across a gap or an obstacle to another navigation polygon.
	if closest.distance_to(desired) > .3: return Vector3.ZERO
	return ((closest-global_position)/maxf(delta,.001)).limit_length(Cfg.PLAYER_SPEED)


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
	Fx.cast(staff_tip.global_position, global_position)
	_cast_t = 0.3
	var to: Vector3 = e.global_position - global_position
	visual.rotation.y = atan2(to.x, to.z)


func _animate(delta: float, walking: bool) -> void:
	_anim_t += delta * (10.0 if walking else 2.2)
	shears.visible = shearing
	if shearing:
		# 털 깎기: 양 쪽으로 몸을 숙이고 가위를 빠르게 여닫는다
		var k := sin(harvest_t * 18.0)
		body.position.y = -0.06 + absf(sin(harvest_t * 9.0)) * 0.015
		body.rotation.x = 0.32
		body.rotation.z = sin(harvest_t * 4.0) * 0.05
		body.scale = Vector3.ONE
		_shear_blades[0].rotation_degrees.z = -6.0 - k * 10.0
		_shear_blades[1].rotation_degrees.z = 6.0 + k * 10.0
		shears.position.z = 0.26 + sin(harvest_t * 6.0) * 0.04
		staff.rotation_degrees.x = 30.0
		return
	body.rotation.x = 0.0
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
	Fx.hit(global_position + Vector3(0, 0.9, 0), Color(1.0, 0.35, 0.4))
	Fx.damage_number(get_parent(), global_position + Vector3(0, 2.2, 0), amount, Color(1.0, 0.4, 0.4))
	if hp <= 0.0:
		dead = true
		cancel_harvest()
		velocity = Vector3.ZERO
		visual.rotation_degrees.x = -80.0
		game.session.report_defeat("마녀가 쓰러졌습니다")


func heal(amount: float) -> float:
	var actual := minf(amount, max_hp - hp)
	hp += actual
	if actual > 0.0:
		Fx.heal(global_position + Vector3(0, 0.8, 0))
	return actual
