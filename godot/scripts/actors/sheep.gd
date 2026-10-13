extends Node3D
## 양: 목장 안에서 짧게 배회. 근처에 적이 오면 반대쪽으로 도망친다.
## 하루 한 번 털을 생산한다(v0.3 §7). 미수확분은 한 번분만 유지하며, 마녀가 다가가 수확해야 양털 카드가 된다.

const Cfg := preload("res://scripts/config.gd")
const Models := preload("res://scripts/visual/models.gd")
const Fx := preload("res://scripts/visual/fx.gd")

var pasture
var slot := 0
var hp := Cfg.SHEEP_HP
var max_hp := Cfg.SHEEP_HP
var dead := false
var hp_offset := 1.05
var born_day := 1
var wool_ready := false
var held := false          # 수확 중에는 제자리에 멈춘다
var come_to = null         # 수확하러 온 마녀 쪽 울타리로 다가간다
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
	visual.rotation.y = _rng.randf_range(0, TAU)
	add_to_group("sheep")
	add_to_group("show_hp")
	_target = position
	_wait = _rng.randf_range(0.5, 3.0)
	_anim_t = _rng.randf() * 10.0


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
	var speed := 0.45
	if held and threat == null:
		body.position.y = 0.0
		return
	if come_to != null and threat == null:
		var r: Rect2 = pasture.wander_rect()
		_target = Vector3(clampf(come_to.x, r.position.x, r.end.x), 0, clampf(come_to.z, r.position.y, r.end.y))
		_wait = 0.0
		speed = 0.9
	if threat != null:
		speed = 1.1
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
		return
	global_position += to.normalized() * minf(speed * delta, to.length())
	visual.rotation.y = lerp_angle(visual.rotation.y, atan2(to.x, to.z), clampf(delta * 6.0, 0.0, 1.0))
	_anim_t += delta * (9.0 if speed > 0.5 else 6.0)
	body.position.y = absf(sin(_anim_t)) * 0.04
	visual.get_node("Body/Head").rotation.x = 0.0


func take_damage(amount: float) -> void:
	if dead:
		return
	hp = maxf(hp - amount, 0.0)
	Fx.flash(visual)
	if hp <= 0.0:
		dead = true
		remove_from_group("sheep")
		remove_from_group("show_hp")
		pasture.on_sheep_died(self)
		Fx.vanish(self, Color(0.95, 0.92, 0.9, 0.8))
