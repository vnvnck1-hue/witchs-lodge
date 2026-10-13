extends Node3D
## 목장: 울타리(이동 차단), 열린 문, 양 3개 슬롯.

const Cfg := preload("res://scripts/config.gd")
const Layout := preload("res://scripts/world/layout.gd")
const Models := preload("res://scripts/visual/models.gd")
const Painted := preload("res://scripts/visual/painted_models.gd")
const B := preload("res://scripts/visual/build.gd")
const SheepScript := preload("res://scripts/actors/sheep.gd")
const Mats := preload("res://scripts/visual/mats.gd")

var game
var slots: Array = []
var rect: Rect2 = Layout.PASTURE_RECT


func _ready() -> void:
	name = "Pasture"
	_build_fences()
	slots.resize(Cfg.SHEEP_MAX)
	for i in Cfg.SHEEP_MAX:
		spawn_sheep(i)


func _build_fences() -> void:
	var x0 := rect.position.x
	var x1 := rect.end.x
	var z0 := rect.position.y
	var z1 := rect.end.y
	var g0 := Layout.GATE_Z.x
	var g1 := Layout.GATE_Z.y
	var visual := B.node(self, Vector3.ZERO, Vector3.ZERO, "FenceVisual")
	var lines := [
		[Vector3(x0 + 0.05, 0, z0), Vector3(x1, 0, z0)],
		[Vector3(x1, 0, z0), Vector3(x1, 0, g0)],
		[Vector3(x1, 0, g1), Vector3(x1, 0, z1)],
		[Vector3(x1, 0, z1), Vector3(x0 + 0.05, 0, z1)],
	]
	var body := StaticBody3D.new()
	body.name = "FenceBody"
	body.collision_layer = Cfg.L_BOUNDARY
	body.collision_mask = 0
	add_child(body)
	for i in lines.size():
		var a: Vector3 = lines[i][0]
		var b: Vector3 = lines[i][1]
		Models.build_fence(visual, a, b, i == 1 or i == 3)
		var cs := CollisionShape3D.new()
		var bs := BoxShape3D.new()
		var seg_len := a.distance_to(b)
		bs.size = Vector3(0.3, 1.0, seg_len + 0.3)
		cs.shape = bs
		cs.position = (a + b) * 0.5 + Vector3(0, 0.5, 0)
		cs.rotation.y = atan2((b - a).x, (b - a).z)
		body.add_child(cs)
	# 항상 열린 목장 문(바깥 +X 쪽으로 열림)
	Painted.gate(visual,Vector3(x1,0,g0),Vector3(x1,0,g1))
	# 건초
	var hay := Models.make_hay()
	hay.position = Vector3(x0 + 0.55, 0, z0 + 0.5)
	hay.rotation_degrees.y = 90
	add_child(hay)


func slot_home(i: int) -> Vector3:
	var homes := [Vector3(3.6, 0, 0.9), Vector3(4.6, 0, 1.6), Vector3(4.7, 0, -0.4)]
	return homes[i % homes.size()]


func spawn_sheep(i: int, day := 1) -> void:
	var s := SheepScript.new()
	s.pasture = self
	s.slot = i
	s.born_day = day
	s.position = slot_home(i)
	add_child(s)
	slots[i] = s


func alive_count() -> int:
	var n := 0
	for s in slots:
		if s != null and not s.dead:
			n += 1
	return n


func has_empty_slot() -> bool:
	return alive_count() < Cfg.SHEEP_MAX


func add_sheep() -> bool:
	for i in slots.size():
		if slots[i] == null or slots[i].dead:
			# 오늘 들인 양은 다음 낮부터 털을 생산한다
			spawn_sheep(i, game.session.wave_index + 1)
			return true
	return false


## 낮 시작: 2일차부터 생존 양마다 수확 가능 상태(미수확분은 1회분까지만).
func produce_wool(day: int) -> int:
	var n := 0
	for s in slots:
		if s != null and not s.dead and s.born_day < day and not s.wool_ready:
			s.wool_ready = true
			n += 1
	return n


func ready_count() -> int:
	var n := 0
	for s in slots:
		if s != null and not s.dead and s.wool_ready:
			n += 1
	return n


func nearest_alive_sheep(pos: Vector3):
	var best = null
	var best_d := 1e9
	for s in slots:
		if s == null or s.dead:
			continue
		var d := pos.distance_to(s.global_position)
		if d < best_d:
			best_d = d
			best = s
	return best


func inside(pos: Vector3, margin := 0.0) -> bool:
	return rect.grow(margin).has_point(Vector2(pos.x, pos.z))


func wander_rect() -> Rect2:
	return Rect2(rect.position.x + 0.5, rect.position.y + 0.45, rect.size.x - 0.95, rect.size.y - 0.9)


func on_sheep_died(s) -> void:
	if s.slot >= 0 and s.slot < slots.size() and slots[s.slot] == s:
		slots[s.slot] = null
	game.on_sheep_died()
