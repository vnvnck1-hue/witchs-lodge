extends Node3D
## 여행자: 숲길에서 걸어와 문 앞에서 입실(숨김), 지불 후 다시 나와 숲길로 떠난다.

const Cfg := preload("res://scripts/config.gd")
const Models := preload("res://scripts/visual/models.gd")
const Layout := preload("res://scripts/world/layout.gd")
const Fx := preload("res://scripts/visual/fx.gd")

signal arrived

var route: Array = []
var profile: Dictionary = {}
var leaving := false
var waiting := false
var visual: Node3D
var body: Node3D
var _anim_t := 0.0
var _delay := 0.0
var _rng := RandomNumberGenerator.new()


func setup(points: Array, delay: float) -> void:
	route = points.duplicate()
	_delay = delay


func _ready() -> void:
	_rng.randomize()
	visual = Models.make_traveler(_rng)
	body = visual.get_node("Body")
	add_child(visual)
	visible = _delay <= 0.0


func leave(points: Array, delay: float) -> void:
	leaving = true
	waiting = false
	route = points.duplicate()
	_delay = delay
	visible = delay <= 0.0


## 정산 후 고용 기회: 문가에 나와 기다린다.
func wait_at(p: Vector3) -> void:
	leaving = false
	waiting = true
	position = Layout.DOOR_FRONT
	route = [p]
	_delay = 0.0
	visible = true


## 고용됨: 계약 카드로 들어가므로 월드에서 퇴장(카드 사용 시 다시 나타난다).
func vanish() -> void:
	waiting = false
	route.clear()
	Fx.vanish(self, Color(1.0, 0.85, 0.55, 0.8), 0.5)


func _process(delta: float) -> void:
	if _delay > 0.0:
		_delay -= delta
		if _delay > 0.0:
			return
		visible = true
	if route.is_empty():
		return
	var tgt: Vector3 = route[0]
	var to := tgt - position
	to.y = 0
	var step := Cfg.GUEST_WALK_SPEED * delta
	if to.length() <= step:
		position = tgt
		route.pop_front()
		if route.is_empty():
			if leaving:
				queue_free()
			elif waiting:
				visual.rotation.y = deg_to_rad(35.0)
			else:
				visible = false
				arrived.emit()
		return
	position += to.normalized() * step
	visual.rotation.y = lerp_angle(visual.rotation.y, atan2(to.x, to.z), clampf(delta * 10.0, 0.0, 1.0))
	_anim_t += delta * 9.0
	body.position.y = absf(sin(_anim_t)) * 0.05
