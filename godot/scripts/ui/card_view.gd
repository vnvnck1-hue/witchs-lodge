extends Control
## 손패 카드 한 장의 화면 표현(하스스톤식). 게임 상태는 갖지 않고 CardHand가 목표(위치·회전·배율)를 준다.
## 스프링으로 따라가 약간 출렁이며, 드래그 중에는 속도에 따라 관성으로 기운다.
## 기준점 pos = 카드 아래 가운데(화면 좌표). 그림자·발광은 카드 뒤(show_behind_parent)에 그린다.

const MoonSkin := preload("res://scripts/ui/moon/moon_skin.gd")
const DISSOLVE := preload("res://shaders/card_dissolve.gdshader")

enum Mode { HAND, DRAG, REVEAL, LEAVING, DYING }

var uid := -1
var card_id := ""
var mode := Mode.HAND
var art: TextureRect
var shadow: TextureRect
var glow: TextureRect
var badge: Label
var person: Label

# 스프링 상태(화면 좌표, 도, 배율)
var pos := Vector2.ZERO
var vel := Vector2.ZERO
var rot := 0.0
var rvel := 0.0
var scl := 1.0
var svel := 0.0
var t_pos := Vector2.ZERO
var t_rot := 0.0
var t_scl := 1.0
var lift := 0.0           # 0=손패에 놓임 · 1=들어 올림(그림자가 멀고 흐려짐)
var t_lift := 0.0
var glow_color := Color(0.22, 0.74, 0.76)
var glow_amt := 0.0
var t_glow := 0.0
var fade := 1.0
var tilt := Vector2.ZERO  # 원근 기울기(셰이더). x: 좌우, y: 앞뒤
var t_tilt := Vector2.ZERO
var mat: ShaderMaterial
var t_fade := 1.0
var timer := 0.0          # REVEAL 유지 시간 / LEAVING·DYING 진행 시간
var on_done: Callable

# 모드별 스프링 강도와 감쇠비(1 미만이면 살짝 출렁임)
const SPRING := {
	Mode.HAND: [240.0, 0.68],
	Mode.DRAG: [620.0, 0.78],
	Mode.REVEAL: [170.0, 0.8],
	Mode.LEAVING: [120.0, 0.95],
	Mode.DYING: [300.0, 0.9],
}

static var _soft_tex: Texture2D
static var _noise: Texture2D


static func soft_texture() -> Texture2D:
	if _soft_tex == null:
		# 둥근 사각형 + 부드러운 가장자리(그림자·발광 공용). 안쪽 영역 = 카드 크기, 바깥 24px 감쇠
		var w := 96
		var h := 112
		var m := 22.0
		var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
		for y in h:
			for x in w:
				var dx := maxf(maxf(m - x, x - (w - 1 - m)), 0.0)
				var dy := maxf(maxf(m - y, y - (h - 1 - m)), 0.0)
				var d := sqrt(dx * dx + dy * dy) / m
				var a := clampf(1.0 - d, 0.0, 1.0)
				a = a * a * (3.0 - 2.0 * a)
				img.set_pixel(x, y, Color(1, 1, 1, a))
		_soft_tex = ImageTexture.create_from_image(img)
	return _soft_tex


static func noise_texture() -> Texture2D:
	if _noise == null:
		var n := NoiseTexture2D.new()
		n.width = 128
		n.height = 128
		n.seamless = true
		var fn := FastNoiseLite.new()
		fn.frequency = 0.035
		fn.fractal_octaves = 3
		n.noise = fn
		_noise = n
	return _noise


func setup(id: String, tex: Texture2D) -> void:
	card_id = id
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# 발광을 먼저, 그림자를 그 위에 그린다(그림자가 발광에 씻겨 사라지지 않게)
	glow = _soft_rect()
	var add := CanvasItemMaterial.new()
	add.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	glow.material = add
	glow.modulate = Color(glow_color, 0.0)
	shadow = _soft_rect()
	shadow.modulate = Color(0.02, 0.0, 0.06, 0.7)
	art = TextureRect.new()
	art.texture = tex
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_SCALE
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(art)
	mat = ShaderMaterial.new()
	mat.shader = DISSOLVE
	mat.set_shader_parameter("noise", noise_texture())
	art.material = mat


func _soft_rect() -> TextureRect:
	var t := TextureRect.new()
	t.texture = soft_texture()
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_SCALE
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	t.show_behind_parent = true
	add_child(t)
	return t


func resize(card_size: Vector2) -> void:
	size = card_size
	pivot_offset = Vector2(card_size.x * 0.5, card_size.y)
	art.size = card_size
	mat.set_shader_parameter("card_size", card_size)


## 상태를 즉시 맞춘다(첫 배치·순간 이동)
func snap(p: Vector2, r := 0.0, s := 1.0) -> void:
	pos = p
	t_pos = p
	rot = r
	t_rot = r
	scl = s
	t_scl = s
	vel = Vector2.ZERO
	rvel = 0.0
	svel = 0.0
	_apply()


func step(delta: float) -> void:
	var k: float = SPRING[mode][0]
	var z: float = SPRING[mode][1]
	var c := 2.0 * sqrt(k) * z
	var n := maxi(1, ceili(delta / (1.0 / 120.0)))
	var h := delta / n
	for i in n:
		vel += ((t_pos - pos) * k - vel * c) * h
		pos += vel * h
		rvel += ((t_rot - rot) * k * 0.8 - rvel * c * 0.9) * h
		rot += rvel * h
		svel += ((t_scl - scl) * k - svel * c) * h
		scl += svel * h
	var e := 1.0 - exp(-delta * 14.0)
	lift = lerpf(lift, t_lift, e)
	glow_amt = lerpf(glow_amt, t_glow, 1.0 - exp(-delta * 10.0))
	fade = lerpf(fade, t_fade, e)
	tilt = tilt.lerp(t_tilt, 1.0 - exp(-delta * 16.0))
	mat.set_shader_parameter("tilt", tilt)
	mat.set_shader_parameter("shine", clampf(lift, 0.0, 1.0))
	_apply()


func _apply() -> void:
	position = pos - pivot_offset
	rotation_degrees = rot
	scale = Vector2.ONE * maxf(scl, 0.01)
	modulate.a = fade
	# 그림자: 화면 아래쪽으로 떨어지고, 들어 올릴수록 멀고 넓고 옅어진다(카드 회전과 무관하게 화면 기준)
	# 부드러운 텍스처의 꽉 찬 안쪽은 전체의 54%: 테두리를 카드 폭의 30~42%만큼 넓혀 안쪽이 카드와 비슷해지게 한다.
	var u := size.x / 96.0
	var off := (Vector2(4.0 + 14.0 * lift, 7.0 + 34.0 * lift) * u).rotated(-rotation)
	var g := size.x * (0.26 + 0.12 * lift)
	shadow.position = off - Vector2(g, g)
	shadow.size = size + Vector2(g, g) * 2.0
	shadow.modulate.a = (0.78 - 0.18 * lift) * fade
	var gs := size.x * 0.24
	glow.position = -Vector2(gs, gs)
	glow.size = size + Vector2(gs, gs) * 2.0
	glow.modulate = Color(glow_color, glow_amt * fade)


## 소모: 섬광 → 살짝 커지며 노이즈 경계로 타 없어짐
func start_dissolve(done: Callable) -> void:
	mode = Mode.DYING
	timer = 0.0
	on_done = done
	t_tilt = Vector2.ZERO
	t_scl = maxf(scl * 1.3, 1.05)
	t_rot = rot * 0.5
	t_lift = 1.0
	t_glow = 0.8
	glow_color = Color(1.0, 0.8, 0.45)
	if badge != null:
		badge.get_parent().visible = false
	if person != null:
		person.get_parent().visible = false


func tick_dissolve(delta: float) -> bool:
	timer += delta
	var m := art.material as ShaderMaterial
	var flash := clampf(1.0 - timer / 0.16, 0.0, 1.0) if timer < 0.16 else 0.0
	m.set_shader_parameter("flash", clampf(timer / 0.08, 0.0, 1.0) if timer < 0.08 else flash)
	var p := clampf((timer - 0.12) / 0.55, 0.0, 1.0)
	m.set_shader_parameter("progress", p)
	shadow.visible = p < 0.35
	t_glow = maxf(0.0, 1.0 - p * 1.4)
	return timer >= 0.7
