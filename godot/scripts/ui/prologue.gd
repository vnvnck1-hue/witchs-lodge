extends CanvasLayer
## 프롤로그: 정지 일러스트 4장 + 자막(사용자 결정 2026-10-17). 마녀사냥 이후 살아남은 마녀 → 숲속 산장 → 그 아래 봉인석 →
## 낮엔 나그네, 밤엔 괴물. 내용은 narrative.md §1 도입 초안과 world-races-card-formats-v01.md §1 역사를 실제 리듬에 맞춘 것이다.
## 클릭·Space·Enter = 다음 장, Esc·'건너뛰기' = 끝까지 건너뛰기. 각 장은 SLIDE_TIME초 뒤 저절로 넘어간다.
## 일러스트(assets/ui/ftue/prologue_0N.png, Codex 요청서 docs/handoff/codex-ftue-prologue-v01.md)가 없으면 단색 그라데이션으로 대신한다.
## 끝나면 화면을 검게 둔 채 finished 를 낸다 — 이어지는 새벽 연출(opening_director)이 검은 막을 걷는다.

signal finished(skipped: bool)

const MoonSkin := preload("res://scripts/ui/moon/moon_skin.gd")

const SLIDE_TIME := 5.5
const FADE := 0.6
const ART_DIR := "res://assets/ui/ftue/"
## [그림 파일, 자막, 플레이스홀더 위색, 아래색]
const SLIDES := [
	["prologue_01.png", "마녀사냥이 끝났을 때, 살아남은 마녀는 넷뿐이었다.\n넷은 동서남북으로 흩어져 몸을 숨겼다.", Color(0.32, 0.10, 0.12), Color(0.06, 0.03, 0.08)],
	["prologue_02.png", "마을에도 도시에도 마녀가 머물 자리는 없었다.\n당신은 깊은 숲에 작은 산장을 열었다.", Color(0.16, 0.13, 0.34), Color(0.04, 0.05, 0.12)],
	["prologue_03.png", "산장 아래에는 봉인석이 잠들어 있다.\n숲의 오래된 것들이 노리는 돌이다.", Color(0.06, 0.24, 0.28), Color(0.02, 0.03, 0.07)],
	["prologue_04.png", "낮에는 당신을 꺼리는 나그네들이 잠자리를 찾아오고,\n밤이면 숲의 괴물이 봉인석을 노린다.", Color(0.40, 0.20, 0.30), Color(0.05, 0.03, 0.12)],
]

var active := false
var index := -1
var shown_captions: Array = []   # 검증용: 실제로 화면에 나온 자막
var placeholder_used := false
var root: Control
var black: ColorRect
var art: TextureRect
var caption: Label
var skip_btn: Button
var pager: Label
var _t := 0.0
var _tween: Tween


func _ready() -> void:
	name = "Prologue"
	layer = 30
	process_mode = Node.PROCESS_MODE_ALWAYS
	root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	root.theme = MoonSkin.make_theme()
	root.visible = false
	root.gui_input.connect(_on_click)
	add_child(root)
	black = ColorRect.new()
	black.set_anchors_preset(Control.PRESET_FULL_RECT)
	black.color = Color(0, 0, 0, 1)
	black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(black)
	art = TextureRect.new()
	art.set_anchors_preset(Control.PRESET_FULL_RECT)
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art.pivot_offset = Vector2.ZERO
	root.add_child(art)
	var shade := TextureRect.new()   # 자막 뒤 아래쪽 어둠
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	shade.stretch_mode = TextureRect.STRETCH_SCALE
	shade.texture = _gradient(Color(0, 0, 0, 0), Color(0, 0, 0, 0.78), 0.55)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(shade)
	caption = Label.new()
	caption.anchor_left = 0.1
	caption.anchor_right = 0.9
	caption.anchor_top = 0.76
	caption.anchor_bottom = 0.95
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	caption.add_theme_font_override("font", MoonSkin.font(true))
	caption.add_theme_font_size_override("font_size", 30)
	caption.add_theme_color_override("font_color", MoonSkin.CREAM)
	caption.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	caption.add_theme_constant_override("shadow_offset_y", 2)
	caption.add_theme_constant_override("line_spacing", 8)
	caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(caption)
	pager = Label.new()
	pager.anchor_left = 0.0
	pager.anchor_top = 1.0
	pager.anchor_bottom = 1.0
	pager.offset_left = 28
	pager.offset_top = -46
	pager.offset_bottom = -18
	pager.add_theme_font_size_override("font_size", 15)
	pager.add_theme_color_override("font_color", MoonSkin.LAVENDER)
	pager.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(pager)
	skip_btn = Button.new()
	skip_btn.text = "건너뛰기  Esc"
	skip_btn.anchor_left = 1.0
	skip_btn.anchor_right = 1.0
	skip_btn.anchor_top = 1.0
	skip_btn.anchor_bottom = 1.0
	skip_btn.offset_left = -200
	skip_btn.offset_right = -24
	skip_btn.offset_top = -64
	skip_btn.offset_bottom = -20
	skip_btn.focus_mode = Control.FOCUS_NONE
	skip_btn.pressed.connect(skip)
	root.add_child(skip_btn)


static func _gradient(top: Color, bottom: Color, from := 0.0) -> GradientTexture2D:
	var g := Gradient.new()
	g.set_offset(0, from)
	g.set_color(0, top)
	g.set_offset(1, 1.0)
	g.set_color(1, bottom)
	var t := GradientTexture2D.new()
	t.gradient = g
	t.fill_from = Vector2(0, 0)
	t.fill_to = Vector2(0, 1)
	t.width = 8
	t.height = 256
	return t


## 슬라이드 그림: 납품된 일러스트, 없으면 그라데이션 플레이스홀더.
static func slide_texture(i: int) -> Texture2D:
	var path: String = ART_DIR + SLIDES[i][0]
	if ResourceLoader.exists(path):
		var tex := load(path) as Texture2D
		if tex != null:
			return tex
	return _gradient(SLIDES[i][2], SLIDES[i][3])


static func has_art(i: int) -> bool:
	return ResourceLoader.exists(ART_DIR + SLIDES[i][0])


func play() -> void:
	active = true
	index = -1
	root.visible = true
	black.color.a = 1.0
	_show(0)


func _show(i: int) -> void:
	index = i
	_t = 0.0
	if not has_art(i):
		placeholder_used = true
	art.texture = slide_texture(i)
	art.scale = Vector2.ONE
	art.modulate.a = 0.0
	caption.text = SLIDES[i][1]
	caption.modulate.a = 0.0
	pager.text = "%d / %d" % [i + 1, SLIDES.size()]
	shown_captions.append(SLIDES[i][1])
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = create_tween().set_parallel(true)
	_tween.tween_property(art, "modulate:a", 1.0, FADE)
	_tween.tween_property(caption, "modulate:a", 1.0, FADE).set_delay(0.35)


func _process(delta: float) -> void:
	if not active:
		return
	_t += delta
	# 아주 느린 확대(1.00 → 1.05)로 정지 그림에 숨을 불어넣는다
	var vp := root.get_viewport_rect().size
	art.pivot_offset = vp * 0.5
	art.scale = Vector2.ONE * lerpf(1.0, 1.05, clampf(_t / SLIDE_TIME, 0.0, 1.0))
	if _t >= SLIDE_TIME:
		next()


func next() -> void:
	if not active:
		return
	if index + 1 >= SLIDES.size():
		_finish(false)
	else:
		_show(index + 1)


func skip() -> void:
	if active:
		_finish(true)


func _finish(skipped: bool) -> void:
	active = false
	if _tween != null and _tween.is_valid():
		_tween.kill()
	var tw := create_tween().set_parallel(true)
	tw.tween_property(art, "modulate:a", 0.0, 0.35)
	tw.tween_property(caption, "modulate:a", 0.0, 0.25)
	skip_btn.visible = false
	pager.visible = false
	tw.chain().tween_callback(func():
		root.mouse_filter = Control.MOUSE_FILTER_IGNORE
		finished.emit(skipped))


## 검은 막까지 걷고 숨긴다(새벽 연출이 따로 막을 걷을 때는 부르지 않아도 된다).
func dismiss() -> void:
	root.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if not active:
		return
	var k := event as InputEventKey
	if k != null and k.pressed and not k.echo:
		if k.keycode == KEY_ESCAPE:
			skip()
		elif k.keycode in [KEY_SPACE, KEY_ENTER, KEY_KP_ENTER]:
			next()
		get_viewport().set_input_as_handled()


func _on_click(event: InputEvent) -> void:
	var mb := event as InputEventMouseButton
	if active and mb != null and mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
		next()
		root.accept_event()
