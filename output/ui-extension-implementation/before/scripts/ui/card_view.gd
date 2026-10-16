extends Control
## 손패 카드 한 장의 화면 표현(하스스톤식). 게임 상태는 갖지 않고 CardHand가 목표(위치·회전·배율)를 준다.
## 스프링으로 따라가 약간 출렁이며, 드래그 중에는 속도에 따라 관성으로 기운다.
## 기준점 pos = 카드 아래 가운데(화면 좌표). 그림자·발광은 카드 뒤(show_behind_parent)에 그린다.

const MoonSkin := preload("res://scripts/ui/moon/moon_skin.gd")
const BURN := preload("res://shaders/card_burn.gdshader")
const BURN_GLOW_SHADER := preload("res://shaders/card_burn_glow.gdshader")

## 소모 연출: 섬광 뒤 BURN_TIME 동안 불꽃 띠가 아래에서 위로 타 올라간다
const BURN_DELAY := 0.12
const BURN_TIME := 0.9
## 소모 중 불꽃이 카드 밖으로 삐져나갈 여백(카드 폭 대비, 한쪽)
const BURN_PAD := 0.12
## 소모 중 카드 뒤 발광 색(셰이더 flame_color 와 맞춘 보라)
const BURN_GLOW := Color(0.6, 0.45, 0.95)
## 소모 중 카드 위 에디티브 글로우 층이 카드 밖으로 번질 여백(카드 폭 대비, 한쪽)
const GLOW_PAD := 0.3
## 연소선 여유(셰이더 burn_margin 과 같은 값: fire_thickness + wobble*0.15 + jaggedness*0.3 + 0.02)
const BURN_MARGIN := 0.14 + 0.865 * 0.15 + 0.164 * 0.3 + 0.02
## 재 입자: 연소선에서 떨어져 나와 위로 날리는 검은 조각. 카드가 사라진 뒤에도 남도록 카드의 형제 노드로 둔다
const ASH_AMOUNT := 36
const ASH_LIFETIME := 1.15

enum Mode { HAND, DRAG, REVEAL, LEAVING, DYING }

var uid := -1
var card_id := ""
var mode := Mode.HAND
var art: TextureRect
var shadow: TextureRect
var glow: TextureRect
var burn_glow: TextureRect   # 소모 중 카드 위에 겹치는 보랏빛 에디티브 글로우
var glow_mat: ShaderMaterial
var ash: CPUParticles2D      # 소모 중 날리는 검은 재(부모의 자식 = 카드의 형제)
var ash_y := 0.0             # 재가 나오는 연소선의 카드 기준 y(검증용)
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
	Mode.REVEAL: [230.0, 0.58],   # 공개 위치에 살짝 넘쳤다 돌아오는 텐션
	Mode.LEAVING: [120.0, 0.95],
	Mode.DYING: [300.0, 0.9],
}

static var _soft_tex: Texture2D
static var _ash_tex: Texture2D


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


## 재 조각 텍스처: 울퉁불퉁한 작은 덩어리(회전·크기 무작위로 써서 모양이 반복돼 보이지 않게)
static func ash_texture() -> Texture2D:
	if _ash_tex == null:
		var n := 10
		var img := Image.create(n, n, false, Image.FORMAT_RGBA8)
		var rng := RandomNumberGenerator.new()
		rng.seed = 7
		var c := Vector2(n - 1, n - 1) * 0.5
		for y in n:
			for x in n:
				var d := (Vector2(x, y) - c).length() / (n * 0.5)
				var bump := rng.randf_range(-0.28, 0.28)
				var a := clampf(1.0 - (d + bump) * 1.25, 0.0, 1.0)
				img.set_pixel(x, y, Color(1, 1, 1, 1.0 if a > 0.35 else 0.0))
		_ash_tex = ImageTexture.create_from_image(img)
	return _ash_tex


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
	mat.shader = BURN
	art.material = mat
	# 소모 중에만 보이는 에디티브 글로우 층(카드 위, 더 넓은 사각형)
	burn_glow = TextureRect.new()
	burn_glow.texture = tex
	burn_glow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	burn_glow.stretch_mode = TextureRect.STRETCH_SCALE
	burn_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	burn_glow.visible = false
	glow_mat = ShaderMaterial.new()
	glow_mat.shader = BURN_GLOW_SHADER
	burn_glow.material = glow_mat
	add_child(burn_glow)


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
	glow_mat.set_shader_parameter("card_size", card_size)


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
	if burn_glow.visible:
		glow_mat.set_shader_parameter("tilt", tilt)
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


## 소모: 섬광 → 살짝 커지며 아래에서 위로 불꽃 띠가 타 올라가 없어짐
func start_dissolve(done: Callable) -> void:
	mode = Mode.DYING
	timer = 0.0
	on_done = done
	t_tilt = Vector2.ZERO
	t_scl = maxf(scl * 1.3, 1.05)
	t_rot = rot * 0.5
	t_lift = 1.0
	t_glow = 0.8
	glow_color = BURN_GLOW
	# 그림 사각형을 넓혀 불꽃이 카드 밖으로 번질 자리를 만든다(셰이더가 카드 UV를 다시 맞춘다)
	var p := Vector2.ONE * size.x * BURN_PAD
	art.position = -p
	art.size = size + p * 2.0
	mat.set_shader_parameter("pad", p)
	# 보랏빛 에디티브 글로우 층: 불꽃보다 넓게 번지도록 더 큰 여백
	var gp := Vector2.ONE * size.x * GLOW_PAD
	burn_glow.position = -gp
	burn_glow.size = size + gp * 2.0
	glow_mat.set_shader_parameter("pad", gp)
	glow_mat.set_shader_parameter("tilt", tilt)
	glow_mat.set_shader_parameter("progress", 0.0)
	burn_glow.visible = true
	_spawn_ash()
	if badge != null:
		badge.get_parent().visible = false
	if person != null:
		person.get_parent().visible = false


## 재 입자 생성. 카드가 먼저 사라져도 재는 끝까지 날리도록 같은 부모 아래 형제로 붙인다(없으면 카드 자신).
func _spawn_ash() -> void:
	ash = CPUParticles2D.new()
	ash.texture = ash_texture()
	ash.amount = ASH_AMOUNT
	ash.lifetime = ASH_LIFETIME
	ash.lifetime_randomness = 0.4
	ash.explosiveness = 0.0
	ash.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	ash.emission_rect_extents = Vector2(size.x * 0.42, size.y * 0.02)
	ash.direction = Vector2(0, -1)
	ash.spread = 58.0                           # 좌우로 흩어지며 위로 날린다
	ash.initial_velocity_min = size.y * 0.55
	ash.initial_velocity_max = size.y * 1.25
	ash.gravity = Vector2(0, -size.y * 0.45)    # 뜨거운 공기 따라 연소선보다 빨리 위로 날아오른다
	ash.damping_min = size.y * 0.1
	ash.damping_max = size.y * 0.3
	# 접선 가속은 가로로 긴 발생 사각형에서 세로 방향이 되어 절반이 아래로 떨어진다 → 쓰지 않는다
	ash.linear_accel_min = -size.y * 0.25
	ash.linear_accel_max = size.y * 0.25
	ash.angle_min = 0.0
	ash.angle_max = 360.0
	ash.angular_velocity_min = -240.0
	ash.angular_velocity_max = 240.0
	ash.scale_amount_min = 0.3
	ash.scale_amount_max = 0.7
	var sc := Curve.new()
	sc.add_point(Vector2(0.0, 1.0))
	sc.add_point(Vector2(0.75, 0.8))
	sc.add_point(Vector2(1.0, 0.0))
	ash.scale_amount_curve = sc
	var ramp := Gradient.new()
	ramp.set_color(0, Color(0.38, 0.22, 0.55, 0.75))   # 연소선에서 막 떨어진 조각은 잠깐 보랏빛 잉걸
	ramp.set_color(1, Color(0.02, 0.01, 0.04, 0.0))
	ramp.add_point(0.12, Color(0.05, 0.03, 0.08, 0.92))
	ramp.add_point(0.7, Color(0.04, 0.02, 0.07, 0.8))
	ash.color_ramp = ramp
	var host: Node = get_parent() if get_parent() != null else self
	host.add_child(ash)
	ash.z_index = z_index + 1
	_place_ash(0.0)
	ash.emitting = true


## 연소선(아래→위)의 현재 카드 기준 y 에 재 발생 사각형을 맞춘다. p = 소모 진행 0..1
func _place_ash(p: float) -> void:
	var line := lerpf(-BURN_MARGIN, 1.0 + BURN_MARGIN, p)
	ash_y = size.y * (1.0 - line) + size.y * 0.03   # 연소선 바로 아래(탄 쪽)에서 떨어져 나온다
	ash.emitting = line >= -0.04 and line <= 1.02
	var local := Vector2(size.x * 0.5, clampf(ash_y, -size.y * 0.06, size.y * 1.06))
	ash.transform = get_transform() * Transform2D(0.0, local) if ash.get_parent() != self else Transform2D(0.0, local)


func _exit_tree() -> void:
	# 소모 도중 카드가 먼저 지워져도(장면 전환 등) 재가 계속 나오지 않게 한다
	_release_ash()


## 재 입자는 카드보다 오래 남는다: 발생을 멈추고 수명이 끝나면 지운다
func _release_ash() -> void:
	if ash == null:
		return
	var a := ash
	ash = null
	a.emitting = false
	var tree := a.get_tree()
	if tree == null:
		a.queue_free()
		return
	tree.create_timer(ASH_LIFETIME * 1.4 + 0.2, true, false, true).timeout.connect(func() -> void:
		if is_instance_valid(a):
			a.queue_free())


func tick_dissolve(delta: float) -> bool:
	timer += delta
	var m := art.material as ShaderMaterial
	var flash := clampf(1.0 - timer / 0.16, 0.0, 1.0) if timer < 0.16 else 0.0
	m.set_shader_parameter("flash", clampf(timer / 0.08, 0.0, 1.0) if timer < 0.08 else flash)
	var p := clampf((timer - BURN_DELAY) / BURN_TIME, 0.0, 1.0)
	m.set_shader_parameter("progress", p)
	glow_mat.set_shader_parameter("progress", p)
	shadow.visible = p < 0.35
	t_glow = maxf(0.0, 1.0 - p * 1.4)
	if ash != null:
		_place_ash(p)
	var done := timer >= BURN_DELAY + BURN_TIME
	if done:
		_release_ash()
	return done
