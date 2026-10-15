extends Node3D
## 서리 룬(카드 frost_rune): 놓은 자리에서 즉시 터져 반경 안의 적에게 피해를 주고 느리게 한다.
## 판정은 생성 순간 한 번이며, 바닥 문양은 짧게 남았다가 사라진다(표시 전용).

const Cfg := preload("res://scripts/config.gd")
const B := preload("res://scripts/visual/build.gd")
const Mats := preload("res://scripts/visual/mats.gd")
const Fx := preload("res://scripts/visual/fx.gd")
const Sfx := preload("res://scripts/audio/sfx.gd")

const C_FROST := Color(0.62, 0.86, 1.0)
const C_RUNE := Color(0.78, 0.7, 1.0)

var game
var hits := 0


func _ready() -> void:
	_burst()
	_build_glyph()


func _burst() -> void:
	Sfx.play(self, "frost_burst")
	for e in get_tree().get_nodes_in_group("enemies"):
		if e.dead:
			continue
		var d := Vector2(e.global_position.x - global_position.x, e.global_position.z - global_position.z).length()
		if d > Cfg.FROST_RADIUS:
			continue
		e.take_damage(Cfg.FROST_DAMAGE)
		if not e.dead:
			e.apply_slow("frost", Cfg.FROST_SLOW, Cfg.FROST_SLOW_TIME)
		Fx.hit(e.global_position + Vector3(0, 0.7, 0), C_FROST)
		hits += 1
	Fx.burst(get_parent(), global_position + Vector3(0, 0.3, 0), C_FROST, 26, 4.5, 0.2, 0.7)
	Fx.celebrate(global_position, C_FROST, Cfg.FROST_RADIUS / 3.0)
	if game != null:
		game.world.shake(0.12, 0.25)


## 달 룬 문양: 안팎 고리와 여섯 갈래 서리 결정. 커졌다가 옅어진다.
func _build_glyph() -> void:
	var glyph := B.node(self, Vector3(0, 0.05, 0), Vector3.ZERO, "Glyph")
	var mat := Mats.unshaded(Color(C_FROST, 0.85), true, true)
	var mat2 := Mats.unshaded(Color(C_RUNE, 0.7), true, true)
	var r := Cfg.FROST_RADIUS
	B.torus(glyph, r - 0.1, r, Vector3.ZERO, mat)
	B.torus(glyph, r * 0.55 - 0.06, r * 0.55, Vector3.ZERO, mat2)
	for i in 6:
		var a := TAU * i / 6.0
		B.box(glyph, Vector3(0.07, 0.02, r * 0.9), Vector3(sin(a), 0, cos(a)) * r * 0.45, mat, Vector3(0, a, 0))
		B.box(glyph, Vector3(0.05, 0.02, 0.4), Vector3(sin(a), 0, cos(a)) * r * 0.7, mat2, Vector3(0, a + 0.6, 0))
	glyph.scale = Vector3(0.2, 1, 0.2)
	var tw := create_tween()
	tw.tween_property(glyph, "scale", Vector3.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_interval(0.9)
	tw.tween_property(glyph, "scale", Vector3(1.08, 1, 1.08), 0.5)
	tw.parallel().tween_method(_fade.bind(mat, mat2), 1.0, 0.0, 0.5)
	tw.tween_callback(queue_free)


func _fade(a: float, mat: StandardMaterial3D, mat2: StandardMaterial3D) -> void:
	mat.albedo_color.a = a * 0.85
	mat2.albedo_color.a = a * 0.7
