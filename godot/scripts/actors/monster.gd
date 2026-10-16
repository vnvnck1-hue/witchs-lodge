extends CharacterBody3D
## 숲의 괴물: 출현 시 산장 또는 양을 목표로 배정. 플레이어가 근접하면 플레이어를 공격.
## 기본 개체는 가장 연약한 적이다. big=true는 카드로 변환되는 큰 숲의 괴물(덩치·체력이 크고 등에 가지, 걸을 때 잎이 떨어짐).

const Cfg := preload("res://scripts/config.gd")
const Models := preload("res://scripts/visual/models.gd")
const Fx := preload("res://scripts/visual/fx.gd")
const Sfx := preload("res://scripts/audio/sfx.gd")
const B := preload("res://scripts/visual/build.gd")
const Mats := preload("res://scripts/visual/mats.gd")

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
## 카드 획득 대상(표식 개체). 처치자와 무관하게 사망 시 한 번만 카드를 준다(v0.3 §8).
var card_drop := ""
var _card_given := false
var big := false
var speed := Cfg.MONSTER_SPEED
var damage := Cfg.MONSTER_DAMAGE
var _leaf_t := 0.0
var _slows: Dictionary = {}  # 출처 -> [이동 배율, 남은 시간]. 서리 룬·수호 등불이 건다
var _frost_mark: MeshInstance3D


func setup(g, hp_value: float, sheep_goal: bool) -> void:
	game = g
	hp = hp_value
	max_hp = hp_value
	goal = Goal.SHEEP if sheep_goal else Goal.LODGE


## 큰 숲의 괴물로 지정(_ready 전에 호출).
func make_big() -> void:
	big = true
	hp *= Cfg.BIG_MONSTER_HP_MULT
	max_hp = hp
	speed = Cfg.BIG_MONSTER_SPEED
	damage = Cfg.BIG_MONSTER_DAMAGE
	hp_offset = 1.95


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
	visual = Models.make_big_monster() if big else Models.make_monster()
	body = visual.get_node("Body")
	add_child(visual)
	add_to_group("enemies")
	add_to_group("wave_enemies")
	add_to_group("show_hp")
	if card_drop != "":
		_add_card_mark()
	if goal == Goal.LODGE:
		attack_point = game.world.lodge.claim_attack_point(global_position)
	_anim_t = randf() * 10.0
	_stuck_ref = global_position
	Fx.spawn_portal(global_position)
	Sfx.play(self, "mon_big" if card_drop != "" else "mon_spawn")


func _add_card_mark() -> void:
	# 머리 위의 초록 빛 표식과 발밑 고리: 처치하면 카드를 얻는 개체
	var mark := B.node(self, Vector3(0, 2.45 if big else 1.75, 0), Vector3.ZERO, "CardMark")
	var orb := B.sphere(mark, 0.12, Vector3.ZERO, Mats.glow(Color(0.55, 1.0, 0.45), 5.0), Vector3.ONE, 8, 4)
	orb.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	B.omni(mark, Vector3.ZERO, Color(0.55, 1.0, 0.45), 0.8, 2.4, false, 1.2)
	var ring := B.torus(self, 0.45, 0.58, Vector3(0, 0.04, 0), Mats.unshaded(Color(0.55, 1.0, 0.45, 0.7), true, true))
	ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	ring.scale = Vector3(1.0, 0.15, 1.0)
	var tw := mark.create_tween().set_loops()
	var y0 := mark.position.y
	tw.tween_property(mark, "position:y", y0 + 0.2, 0.6).set_trans(Tween.TRANS_SINE)
	tw.tween_property(mark, "position:y", y0, 0.6).set_trans(Tween.TRANS_SINE)


func _nearest_ally():
	var best = null
	var best_d := Cfg.MONSTER_MELEE
	for a in get_tree().get_nodes_in_group("allies") + get_tree().get_nodes_in_group("thorn_plants"):
		if a.dead or a.get("hidden") == true:
			continue
		var d := _flat(a.global_position)
		if d <= best_d:
			best_d = d
			best = a
	return best


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

	var ally = _nearest_ally()
	if not player.dead and _flat(player.global_position) <= Cfg.MONSTER_MELEE:
		attack_target = player
		face_point = player.global_position
	elif ally != null:
		# 길을 막은 용병·하수인과 맞붙는다(아군도 정상 피격)
		attack_target = ally
		face_point = ally.global_position
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
			Fx.claw(global_position + Vector3(0, 0.7, 0), face_point - global_position)
			Sfx.play(self, "mon_attack")
			if attack_target == lodge:
				lodge.take_damage(damage, self)
			else:
				attack_target.take_damage(damage)
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
			v = dir.normalized() * speed * slow_factor()
		v += _separation() * 1.4
		velocity = v
		if v.length() > 0.05:
			_face(v, delta)
			if big:
				_shed_leaves(delta, v)
		_check_stuck(delta)
	_tick_slows(delta)
	if not dead:
		move_and_slide()
		global_position.y = 0.0
		_animate(delta, attack_target == null)


## 감속: 같은 출처는 갱신하고, 여러 출처가 겹치면 가장 강한 배율만 적용한다.
func apply_slow(source: String, factor: float, duration: float) -> void:
	if dead:
		return
	var cur = _slows.get(source)
	if cur == null or cur[1] < duration:
		_slows[source] = [factor, duration]
	_sync_frost_mark()


func slow_factor() -> float:
	var f := 1.0
	for k in _slows:
		f = minf(f, _slows[k][0])
	if game != null and game.get("relics") != null and game.relics != null:
		f *= game.relics.enemy_speed_mult()
	return f


func _tick_slows(delta: float) -> void:
	if _slows.is_empty():
		return
	for k in _slows.keys():
		_slows[k][1] -= delta
		if _slows[k][1] <= 0.0:
			_slows.erase(k)
	_sync_frost_mark()


## 느려진 동안 발밑에 옅은 서리 고리를 둔다(표시 전용).
func _sync_frost_mark() -> void:
	var on := not _slows.is_empty() and not dead
	if on and _frost_mark == null:
		_frost_mark = B.torus(self, 0.32, 0.5, Vector3(0, 0.05, 0), Mats.unshaded(Color(0.62, 0.86, 1.0, 0.6), true, true))
		Sfx.play(self, "slow_apply")
	if _frost_mark != null:
		if on and not _frost_mark.visible:
			Sfx.play(self, "slow_apply")
		_frost_mark.visible = on


## 걸을 때 등의 가지에서 나뭇잎이 조금씩 떨어진다(표시 전용).
func _shed_leaves(delta: float, vel: Vector3) -> void:
	_leaf_t -= delta
	if _leaf_t > 0.0:
		return
	_leaf_t = randf_range(0.28, 0.5)
	var back := -vel.normalized()
	Fx.leaf_shed(global_position + Vector3(0, 1.45, 0) + back * 0.35, back, 1 if randf() < 0.7 else 2)


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
	Fx.damage_number(get_parent(), global_position + Vector3(0, 1.9, 0), amount)
	if hp <= 0.0:
		die()
	else:
		Sfx.play(self, "mon_hit")


func die() -> void:
	dead = true
	hp = 0.0
	velocity = Vector3.ZERO
	remove_from_group("enemies")
	remove_from_group("wave_enemies")
	remove_from_group("show_hp")
	collision_mask = 0
	Sfx.play(self, "mon_die")
	if card_drop != "" and not _card_given:
		_card_given = true
		game.cards.add(card_drop)
		game.toast("큰 숲의 괴물을 쓰러뜨려 숲의 괴물 카드를 얻었습니다!", Color(0.6, 1.0, 0.55))
		Fx.celebrate(global_position + Vector3(0, 1.0, 0), Color(0.55, 1.0, 0.45))
		Sfx.play(self, "mon_drop")
	Fx.vanish(self)
