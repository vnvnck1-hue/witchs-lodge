extends Node3D
## 양: 목장 안에서 짧게 배회. 근처에 적이 오면 반대쪽으로 도망친다.
## 하루 한 번 털을 생산한다(v0.3 §7). 미수확분은 한 번분만 유지하며, 마녀가 다가가 수확해야 양털 카드가 된다.
## 새끼양(카드 lamb)은 작고 약하며 털을 생산하지 않는다. grow_day 낮이 되면 목장이 grow_up()을 불러 어른 양이 된다.
## 남은 일수는 마녀가 가까이 갔을 때만 말풍선(ui/lamb_bubble.gd)으로 알려 준다.

const Cfg := preload("res://scripts/config.gd")
const Models := preload("res://scripts/visual/models.gd")
const Fx := preload("res://scripts/visual/fx.gd")
const Sfx := preload("res://scripts/audio/sfx.gd")
var _fleeing := false

var pasture
var hp := Cfg.SHEEP_HP
var max_hp := Cfg.SHEEP_HP
var dead := false
var hp_offset := 1.05
var born_day := 1
var is_lamb := false
var is_black := false
var card_uid := -1   # 입식 카드(죽으면 버림패로)
var grow_day := 0          # 새끼양이 어른 양이 되는 날(낮 시작 기준)
var wool_ready := false
var held := false          # 마녀가 털을 깎으러 오는 동안·깎는 동안 제자리에 멈춘다
var shearing := false      # 털 깎는 중(몸을 살짝 떠는 모션)
var visual: Node3D
var body: Node3D
var _target := Vector3.ZERO
var _wait := 0.0
var _anim_t := 0.0
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	visual = Models.make_sheep()
	body = visual.get_node("Body")
	add_child(visual)
	if is_black:
		_style_black(visual)
		var head := visual.get_node("Body/Head")
		var b := preload("res://scripts/visual/build.gd")
		var mats := preload("res://scripts/visual/mats.gd")
		for side: float in [-1.0, 1.0]:
			b.sphere(head, 0.035, Vector3(side * 0.13, 0.07, 0.13), mats.glow(Color(1.0, 0.78, 0.3), 2.5), Vector3.ONE, 8, 4)
	if is_lamb:
		hp = Cfg.LAMB_HP
		max_hp = Cfg.LAMB_HP
		hp_offset = 1.05 * Cfg.LAMB_SCALE + 0.15
		visual.scale = Vector3.ONE * Cfg.LAMB_SCALE
	visual.rotation.y = _rng.randf_range(0, TAU)
	add_to_group("sheep")
	add_to_group("show_hp")
	_target = position
	_wait = _rng.randf_range(0.5, 3.0)
	_anim_t = _rng.randf() * 10.0


## Replace only this sheep's mesh overrides; imported meshes/materials stay shared and unchanged.
func _style_black(node: Node) -> void:
	if node is MeshInstance3D:
		var label := str(node.name).to_lower()
		if not ("eye" in label or "bell" in label):
			var mats := preload("res://scripts/visual/mats.gd")
			node.material_override = mats.solid(Color("393047") if "wool" in label else Color("211d2b"), {"rim_strength": 0.3, "rim_color": Color("a68dcd"), "sky_fill": 0.12})
	for child in node.get_children():
		_style_black(child)


func wool_card_id() -> String:
	return "black_wool" if is_black else "wool"


func _pick_target(away_from = null) -> void:
	var r: Rect2 = pasture.wander_rect()
	if away_from != null:
		var dir: Vector3 = global_position - away_from
		dir.y = 0
		_target = global_position + dir.normalized() * 1.5
	else:
		_target = Vector3(_rng.randf_range(r.position.x, r.end.x), 0, _rng.randf_range(r.position.y, r.end.y))
	_target.x = clampf(_target.x, r.position.x, r.end.x)
	_target.z = clampf(_target.z, r.position.y, r.end.y)
	# 건초 더미 모서리는 피한다
	if _target.x < r.position.x + 0.6 and _target.z < r.position.y + 0.7:
		_target.z = r.position.y + 0.9


func _process(delta: float) -> void:
	if dead:
		return
	var threat = null
	var td := 2.6
	for e in get_tree().get_nodes_in_group("enemies"):
		var d: float = global_position.distance_to(e.global_position)
		if d < td:
			td = d
			threat = e
	var speed := 0.45 if not is_lamb else 0.55
	if held and threat == null:
		_anim_t += delta * (14.0 if shearing else 2.0)
		body.position.y = 0.0
		body.rotation.z = sin(_anim_t) * (0.05 if shearing else 0.0)
		visual.get_node("Body/Head").rotation.x = -0.15 if shearing else 0.1
		_target = global_position
		_wait = 0.5
		return
	body.rotation.z = 0.0
	if threat == null:
		_fleeing = false
	if threat != null:
		speed = 1.1
		if not _fleeing:
			_fleeing = true
			Sfx.play(self, "sheep_flee")
		if _wait > 0.0 or global_position.distance_to(_target) < 0.2:
			_pick_target(threat.global_position)
			_wait = 0.0
	if _wait > 0.0:
		_wait -= delta
		_anim_t += delta * 2.0
		body.position.y = 0.0
		visual.get_node("Body/Head").rotation.x = 0.25 + sin(_anim_t) * 0.1
		if _wait <= 0.0:
			_pick_target()
		return
	var to := _target - global_position
	to.y = 0
	if to.length() < 0.08:
		_wait = _rng.randf_range(1.5, 4.0)
		# 풀 뜯으며 가끔 운다: 마녀가 가까울 때만, 네 번에 한 번꼴
		if _rng.randf() < 0.25 and Sfx.near_player(self, 3.0, 12.0) > 0.2:
			Sfx.play(self, "sheep_bleat")
		return
	global_position += to.normalized() * minf(speed * delta, to.length())
	visual.rotation.y = lerp_angle(visual.rotation.y, atan2(to.x, to.z), clampf(delta * 6.0, 0.0, 1.0))
	_anim_t += delta * (9.0 if speed > 0.5 else 6.0)
	body.position.y = absf(sin(_anim_t)) * 0.04
	visual.get_node("Body/Head").rotation.x = 0.0


## 어른 양이 되기까지 남은 낮의 수(오늘 기준). 어른 양은 0.
func days_to_grow(today: int) -> int:
	return maxi(grow_day - today, 0) if is_lamb else 0


func grow_up() -> void:
	if not is_lamb or dead:
		return
	is_lamb = false
	max_hp = Cfg.SHEEP_HP
	hp = Cfg.SHEEP_HP
	hp_offset = 1.05
	var tw := visual.create_tween()
	tw.tween_property(visual, "scale", Vector3.ONE * 1.12, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(visual, "scale", Vector3.ONE, 0.2)
	Fx.celebrate(global_position + Vector3(0, 0.4, 0), Color(1.0, 0.96, 0.82), 0.7)


func take_damage(amount: float) -> void:
	if dead:
		return
	hp = maxf(hp - amount, 0.0)
	Fx.flash(visual)
	Fx.damage_number(get_parent(), global_position + Vector3(0, 1.3, 0), amount, Color(1.0, 0.5, 0.45))
	Sfx.play(self, "sheep_hurt")
	if hp <= 0.0:
		dead = true
		remove_from_group("sheep")
		remove_from_group("show_hp")
		pasture.on_sheep_died(self)
		Fx.vanish(self, Color(0.95, 0.92, 0.9, 0.8))
