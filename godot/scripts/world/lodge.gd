extends StaticBody3D
## 산장 래퍼: 체력·충돌·공격 지점·증축. 시각 모델은 Models.build_lodge가 만든다.

const Cfg := preload("res://scripts/config.gd")
const Layout := preload("res://scripts/world/layout.gd")
const Models := preload("res://scripts/visual/models.gd")
const Fx := preload("res://scripts/visual/fx.gd")

var game
var hp := Cfg.LODGE_HP
var max_hp := Cfg.LODGE_HP
var dead := false
var hp_offset := 5.9
var rects: Array = []
var attack_points: Array = []
var point_load: Dictionary = {}
var visual: Node3D
var extension_built := false
var _shake_t := 0.0


func _ready() -> void:
	collision_layer = Cfg.L_OBSTACLE
	collision_mask = 0
	_add_box(Vector3(4.9, 3.2, 5.9), Vector3(0, 1.6, 0))
	var parts := Models.build_lodge(self)
	visual = parts["visual"]
	rects.append(Layout.LODGE_RECT)
	_rebuild_attack_points()
	add_to_group("show_hp")


func _add_box(size: Vector3, pos: Vector3) -> void:
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = size
	cs.shape = bs
	cs.position = pos
	add_child(cs)


func build_extension() -> void:
	if extension_built:
		return
	extension_built = true
	var ext := Models.build_extension(self)
	_add_box(Vector3(3.2, 2.6, 3.4), Vector3(-3.85, 1.3, 0))
	rects.append(Layout.EXTENSION_RECT)
	_rebuild_attack_points()
	game.world.bake_nav()
	ext.scale = Vector3(1, 0.05, 1)
	var tw := ext.create_tween()
	tw.tween_property(ext, "scale", Vector3.ONE, 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	Fx.celebrate(global_position + Vector3(-3.85, 1.0, 0), Fx.C_GOLD, 1.4)


func distance_to(pos: Vector3) -> float:
	var p := Vector2(pos.x, pos.z)
	var best := 1e9
	for r in rects:
		best = minf(best, _rect_dist(r, p))
	return best


func closest_point(pos: Vector3) -> Vector3:
	var p := Vector2(pos.x, pos.z)
	var best := 1e9
	var out := Vector3.ZERO
	for r: Rect2 in rects:
		var c := Vector2(clampf(p.x, r.position.x, r.end.x), clampf(p.y, r.position.y, r.end.y))
		var d := c.distance_to(p)
		if d < best:
			best = d
			out = Vector3(c.x, 0, c.y)
	return out


static func _rect_dist(r: Rect2, p: Vector2) -> float:
	var dx := maxf(maxf(r.position.x - p.x, 0.0), p.x - r.end.x)
	var dy := maxf(maxf(r.position.y - p.y, 0.0), p.y - r.end.y)
	return Vector2(dx, dy).length()


func _rebuild_attack_points() -> void:
	attack_points.clear()
	point_load.clear()
	# 목장은 증축으로 넓어지므로 최대 단계 영역을 비워 둔다
	var pasture_zone: Rect2 = Cfg.PASTURE_LEVELS[-1]["rect"].grow(0.7)
	for r: Rect2 in rects:
		var g := r.grow(0.85)
		var corners := [g.position, Vector2(g.end.x, g.position.y), g.end, Vector2(g.position.x, g.end.y)]
		for i in 4:
			var a: Vector2 = corners[i]
			var b: Vector2 = corners[(i + 1) % 4]
			var n := maxi(1, int(a.distance_to(b) / 1.6))
			for k in n:
				var c := a.lerp(b, (k + 0.5) / n)
				if pasture_zone.has_point(c):
					continue
				if distance_to(Vector3(c.x, 0, c.y)) < 0.6:
					continue
				attack_points.append(Vector3(c.x, 0, c.y))


func claim_attack_point(from: Vector3) -> Vector3:
	var best_i := 0
	var best_score := 1e9
	for i in attack_points.size():
		var score: float = from.distance_to(attack_points[i]) + 3.5 * float(point_load.get(i, 0))
		if score < best_score:
			best_score = score
			best_i = i
	point_load[best_i] = int(point_load.get(best_i, 0)) + 1
	return attack_points[best_i]


func take_damage(amount: float) -> void:
	if dead:
		return
	hp = maxf(hp - amount, 0.0)
	Fx.flash(visual, 0.45)
	Fx.splinters(closest_point(global_position + Fx._rh(8.0)) + Vector3(0, randf_range(0.6, 1.8), 0))
	_shake_t = 0.18
	if hp <= 0.0:
		dead = true
		game.session.report_defeat("산장이 무너졌습니다")


func repair(amount: float) -> float:
	var actual := minf(amount, max_hp - hp)
	hp += actual
	if actual > 0.0:
		Fx.heal(global_position + Vector3(0.5, 1.2, 3.2))
		Fx.celebrate(global_position + Vector3(0.5, 1.0, 3.2), Color(0.95, 0.8, 0.5))
	return actual


func _process(delta: float) -> void:
	if _shake_t > 0.0:
		_shake_t -= delta
		visual.position = Vector3(randf_range(-0.04, 0.04), 0, randf_range(-0.04, 0.04)) if _shake_t > 0.0 else Vector3.ZERO
