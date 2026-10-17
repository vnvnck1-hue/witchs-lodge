extends Control
## 타이틀 화면(main_scene, 첫 실행 플로우 보강 — 사용자 결정 2026-10-17): 새 이야기 · 이어하기(비활성) · 설정 · 끝내기.
## '새 이야기' 다음은 네 마녀 선택(지금은 이름 없는 '마녀' 한 칸만 고를 수 있고 셋은 '?'로 잠김, 방위 미정) → 게임(main.tscn, 도입 연출).
## 배경은 Codex 납품 그림(assets/ui/ftue/title_bg.png)을 천천히 패닝하고, 없으면 밤의 산장을 단순한 도형으로 그린다.
## 설정은 HUD의 소리 설정 부품을 그대로 빌려 쓴다(hud.gd는 세션이 없으면 짓지 않고 부품 함수만 내준다).
## 인자: -- --skip-title(또는 스크린샷 인자 --shot=…) 이면 곧장 게임으로 들어간다(기존 실행 방식 호환).

const Flow := preload("res://scripts/game/flow.gd")
const MoonSkin := preload("res://scripts/ui/moon/moon_skin.gd")
const Extension := preload("res://scripts/ui/moon/moon_extension.gd")
const SoundBankScript := preload("res://scripts/audio/sound_bank.gd")
const WindowMode := preload("res://scripts/visual/window_mode.gd")
const HudScript := preload("res://scripts/ui/hud.gd")
const ShotScript := preload("res://scripts/tools/screenshot_runner.gd")

const ART_DIR := "res://assets/ui/ftue/"
const PAN_TIME := 40.0
## [id, 이름, 설명, 선택 가능]
const WITCHES := [
	["witch", "마녀", "숲속 산장을 지키는 마녀.\n방위는 아직 모른다.", true],
	["locked_1", "?", "아직 만나지 못한 마녀", false],
	["locked_2", "?", "아직 만나지 못한 마녀", false],
	["locked_3", "?", "아직 만나지 못한 마녀", false],
]

var sounds              # HUD 설정 부품이 game.sounds 로 쓴다
var display             # 디스플레이 설정(WindowMode). HUD 디스플레이 부품이 있으면 game.display 로 쓴다
var settings_parts      # 부품만 빌려 쓰는 HUD 인스턴스(트리에 넣지만 짓지 않는다)
var bg: Control
var title_box: VBoxContainer
var menu: VBoxContainer
var new_btn: Button
var continue_btn: Button
var settings_btn: Button
var quit_btn: Button
var settings_panel: PanelContainer
var tutorial_toggle: CheckButton
var fullscreen_toggle: CheckButton
var select_panel: Control
var slot_buttons: Array = []
var start_btn: Button
var select_note: Label
var selected := -1
var music: AudioStreamPlayer
var _t := 0.0


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	theme = MoonSkin.make_theme()
	preload("res://scripts/ui/moon/moon_skin.gd").install_web_font_fallback()
	get_tree().paused = false
	var user := OS.get_cmdline_user_args()
	if "--skip-title" in user or not ShotScript.parse_args().is_empty():
		get_tree().change_scene_to_file.call_deferred(Flow.GAME_SCENE)
		return
	sounds = SoundBankScript.new()
	add_child(sounds)
	display = WindowMode.new()
	display.name = "WindowMode"
	add_child(display)
	settings_parts = HudScript.new()
	settings_parts.game = self
	add_child(settings_parts)
	_build_background()
	_build_title()
	_build_menu()
	_build_settings()
	_build_select()
	_start_music.call_deferred()
	new_btn.grab_focus.call_deferred()


# ───────────────────────── 배경 ─────────────────────────

func _build_background() -> void:
	var path := ART_DIR + "title_bg.png"
	if ResourceLoader.exists(path):
		var tr := TextureRect.new()
		tr.texture = load(path)
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		bg = tr
	else:
		bg = NightLodge.new()   # 플레이스홀더: 밤의 산장 실루엣
	bg.name = "Background"
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	var left := TextureRect.new()   # 메뉴 쪽(왼쪽)을 어둡게
	left.set_anchors_preset(Control.PRESET_FULL_RECT)
	left.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	left.stretch_mode = TextureRect.STRETCH_SCALE
	var g := Gradient.new()
	g.set_color(0, Color(0.03, 0.01, 0.08, 0.82))
	g.set_offset(1, 0.55)
	g.set_color(1, Color(0.03, 0.01, 0.08, 0.0))
	var gt := GradientTexture2D.new()
	gt.gradient = g
	gt.width = 256
	gt.height = 4
	left.texture = gt
	left.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(left)


func _process(delta: float) -> void:
	_t += delta
	if bg == null:
		return
	# 천천히 좌우로 도는 카메라처럼: 8% 넓게 두고 사인 곡선으로 패닝
	var vp := get_viewport_rect().size
	var over := vp.x * 0.08
	bg.size = vp + Vector2(over, vp.y * 0.04)
	bg.position = Vector2(-over * (0.5 + 0.5 * sin(_t * TAU / PAN_TIME)), -vp.y * 0.02)
	if bg is NightLodge:
		bg.t = _t
		bg.queue_redraw()


func _start_music() -> void:
	var list = sounds.streams.get("bgm_evening", sounds.streams.get("bgm_field", []))
	if list.is_empty():
		return
	music = AudioStreamPlayer.new()
	music.name = "TitleMusic"
	music.stream = list[0]
	music.bus = SoundBankScript.MUSIC_BUS
	music.volume_db = float(sounds.gains.get("bgm_evening", -10.0))
	add_child(music)
	music.play()


# ───────────────────────── 제목·메뉴 ─────────────────────────

func _build_title() -> void:
	var box := VBoxContainer.new()
	box.name = "TitleBox"
	title_box = box
	box.anchor_left = 0.0
	box.anchor_right = 1.0
	box.anchor_top = 0.07
	box.anchor_bottom = 0.07
	box.offset_bottom = 170
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(box)
	var logo_path := ART_DIR + "title_logo.png"
	if ResourceLoader.exists(logo_path):
		var logo := TextureRect.new()
		logo.texture = load(logo_path)
		logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		logo.custom_minimum_size = Vector2(600, 150)
		box.add_child(logo)
	else:
		var t := Label.new()
		t.name = "TitleText"
		t.text = "마녀산장"
		t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		t.add_theme_font_override("font", MoonSkin.font(true))
		t.add_theme_font_size_override("font_size", 84)
		t.add_theme_color_override("font_color", MoonSkin.CREAM)
		t.add_theme_color_override("font_shadow_color", Color(0.25, 0.1, 0.4, 0.9))
		t.add_theme_constant_override("shadow_offset_y", 5)
		t.add_theme_constant_override("shadow_outline_size", 10)
		box.add_child(t)
	var sub := Label.new()
	sub.text = "낮에는 나그네를, 밤에는 봉인석을"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 20)
	sub.add_theme_color_override("font_color", MoonSkin.LAVENDER)
	box.add_child(sub)


func _build_menu() -> void:
	menu = VBoxContainer.new()
	menu.name = "Menu"
	menu.anchor_left = 0.07
	menu.anchor_right = 0.07
	menu.anchor_top = 0.42
	menu.anchor_bottom = 0.42
	menu.offset_right = 320
	menu.add_theme_constant_override("separation", 12)
	add_child(menu)
	new_btn = _menu_button("새 이야기", _open_select)
	continue_btn = _menu_button("이어하기", func(): pass)
	continue_btn.disabled = true
	continue_btn.tooltip_text = "저장·이어하기는 아직 준비 중입니다"
	settings_btn = _menu_button("설정", _open_settings)
	quit_btn = _menu_button("끝내기", func(): get_tree().quit())
	var foot := Label.new()
	foot.text = "F11 전체 화면  ·  Esc 뒤로"
	foot.anchor_left = 0.07
	foot.anchor_top = 1.0
	foot.anchor_bottom = 1.0
	foot.offset_top = -48
	foot.add_theme_font_size_override("font_size", 14)
	foot.add_theme_color_override("font_color", MoonSkin.LAVENDER)
	foot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(foot)


func _menu_button(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(320, 54)
	b.add_theme_font_override("font", MoonSkin.font(true))
	b.add_theme_font_size_override("font_size", 22)
	b.pressed.connect(cb)
	menu.add_child(b)
	return b


# ───────────────────────── 설정 ─────────────────────────

func _build_settings() -> void:
	settings_panel = PanelContainer.new()
	settings_panel.name = "Settings"
	settings_panel.add_theme_stylebox_override("panel", MoonSkin.modal_box())
	settings_panel.anchor_left = 0.5
	settings_panel.anchor_right = 0.5
	settings_panel.anchor_top = 0.5
	settings_panel.anchor_bottom = 0.5
	settings_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	settings_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	settings_panel.visible = false
	add_child(settings_panel)
	var v := VBoxContainer.new()
	v.custom_minimum_size.x = 460
	v.add_theme_constant_override("separation", 10)
	settings_panel.add_child(v)
	var t := Label.new()
	t.text = "설정"
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.add_theme_font_override("font", MoonSkin.font(true))
	t.add_theme_font_size_override("font_size", 28)
	t.add_theme_color_override("font_color", MoonSkin.CREAM)
	v.add_child(t)
	v.add_child(_section("화면"))
	var screen := VBoxContainer.new()
	screen.name = "DisplaySettings"
	v.add_child(screen)
	if settings_parts.has_method("_build_display_settings"):
		# 디스플레이 설정 부품(화면 모드·창 크기 등)이 있는 HUD면 그대로 빌려 쓴다
		if "pause_display" in settings_parts:
			settings_parts.pause_display = screen
		settings_parts._build_display_settings(screen)
	else:
		fullscreen_toggle = CheckButton.new()
		fullscreen_toggle.name = "FullscreenToggle"
		fullscreen_toggle.text = "전체 화면  (F11)"
		fullscreen_toggle.add_theme_font_size_override("font_size", 15)
		fullscreen_toggle.toggled.connect(func(_on: bool): display.toggle_fullscreen())
		screen.add_child(fullscreen_toggle)
	v.add_child(_section("소리"))
	var sound := VBoxContainer.new()
	sound.name = "SoundSettings"
	sound.add_theme_constant_override("separation", 4)
	v.add_child(sound)
	settings_parts._build_sound_settings(sound)
	v.add_child(_section("안내"))
	tutorial_toggle = CheckButton.new()
	tutorial_toggle.name = "TutorialReplay"
	tutorial_toggle.text = "튜토리얼 다시 보기 (다음 새 이야기에서 첫 고용 안내)"
	tutorial_toggle.add_theme_font_size_override("font_size", 15)
	tutorial_toggle.toggled.connect(func(on: bool): Flow.set_tutorial_done(not on))
	v.add_child(tutorial_toggle)
	var close := Button.new()
	close.text = "닫기"
	close.custom_minimum_size = Vector2(0, 44)
	close.pressed.connect(close_settings)
	v.add_child(close)


func _section(text: String) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_override("font", MoonSkin.font(true))
	l.add_theme_font_size_override("font_size", 17)
	l.add_theme_color_override("font_color", MoonSkin.TEAL)
	return l


func _open_settings() -> void:
	tutorial_toggle.set_pressed_no_signal(not Flow.tutorial_done())
	if fullscreen_toggle != null:
		var w := get_window()
		fullscreen_toggle.set_pressed_no_signal(w.mode in [Window.MODE_FULLSCREEN, Window.MODE_EXCLUSIVE_FULLSCREEN])
	settings_panel.visible = true
	title_box.visible = false
	menu.visible = false
	sounds.play("panel_open")


func close_settings() -> void:
	settings_panel.visible = false
	title_box.visible = true
	menu.visible = true
	sounds.play("panel_close")
	settings_btn.grab_focus.call_deferred()


# ───────────────────────── 마녀 선택 ─────────────────────────

func _build_select() -> void:
	select_panel = Control.new()
	select_panel.name = "WitchSelect"
	select_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	select_panel.visible = false
	add_child(select_panel)
	var dim := ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.03, 0.01, 0.08, 0.72)
	select_panel.add_child(dim)
	var v := VBoxContainer.new()
	v.set_anchors_preset(Control.PRESET_FULL_RECT)
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override("separation", 18)
	select_panel.add_child(v)
	var head := Label.new()
	head.text = "누구의 이야기인가"
	head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	head.add_theme_font_override("font", MoonSkin.font(true))
	head.add_theme_font_size_override("font_size", 40)
	head.add_theme_color_override("font_color", MoonSkin.CREAM)
	v.add_child(head)
	var lead := Label.new()
	lead.text = "마녀사냥에서 살아남은 네 마녀. 지금은 한 사람의 이야기만 열려 있습니다."
	lead.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lead.add_theme_font_size_override("font_size", 17)
	lead.add_theme_color_override("font_color", MoonSkin.LAVENDER)
	v.add_child(lead)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 22)
	v.add_child(row)
	for i in WITCHES.size():
		row.add_child(_slot(i))
	select_note = Label.new()
	select_note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	select_note.add_theme_font_size_override("font_size", 16)
	select_note.add_theme_color_override("font_color", MoonSkin.CREAM_DIM)
	v.add_child(select_note)
	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 14)
	v.add_child(buttons)
	var back := Button.new()
	back.text = "뒤로"
	back.custom_minimum_size = Vector2(180, 50)
	back.pressed.connect(close_select)
	buttons.add_child(back)
	start_btn = Button.new()
	start_btn.text = "이 마녀로 시작"
	start_btn.custom_minimum_size = Vector2(260, 50)
	start_btn.add_theme_font_override("font", MoonSkin.font(true))
	start_btn.disabled = true
	start_btn.pressed.connect(start_story)
	buttons.add_child(start_btn)


func _slot(i: int) -> Control:
	var w: Array = WITCHES[i]
	var b := Button.new()
	b.name = "Witch_%s" % w[0]
	b.toggle_mode = true
	b.custom_minimum_size = Vector2(230, 400)
	b.focus_mode = Control.FOCUS_ALL
	var v := VBoxContainer.new()
	v.set_anchors_preset(Control.PRESET_FULL_RECT)
	v.offset_left = 12
	v.offset_right = -12
	v.offset_top = 12
	v.offset_bottom = -12
	v.add_theme_constant_override("separation", 8)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(v)
	var art_path := ART_DIR + ("witch_portrait.png" if w[3] else "witch_locked.png")
	var pic: Control
	if ResourceLoader.exists(art_path):
		var tr := TextureRect.new()
		tr.texture = load(art_path)
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		pic = tr
	else:
		var sil := WitchSilhouette.new()   # 플레이스홀더 실루엣
		sil.locked = not w[3]
		pic = sil
	pic.custom_minimum_size = Vector2(200, 270)
	pic.size_flags_vertical = Control.SIZE_EXPAND_FILL
	pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(pic)
	if not w[3] and pic is TextureRect:
		var q := Label.new()   # 잠긴 칸의 '?'는 그림 위에 게임이 그린다
		q.text = "?"
		q.set_anchors_preset(Control.PRESET_FULL_RECT)
		q.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		q.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		q.add_theme_font_override("font", MoonSkin.font(true))
		q.add_theme_font_size_override("font_size", 96)
		q.add_theme_color_override("font_color", Color(MoonSkin.LAVENDER, 0.85))
		q.mouse_filter = Control.MOUSE_FILTER_IGNORE
		pic.add_child(q)
	var name_l := Label.new()
	name_l.text = w[1] if w[3] else ""   # 잠긴 칸의 '?'는 그림 위에 크게 하나만
	name_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_l.add_theme_font_override("font", MoonSkin.font(true))
	name_l.add_theme_font_size_override("font_size", 26)
	name_l.add_theme_color_override("font_color", MoonSkin.CREAM if w[3] else MoonSkin.LAVENDER)
	name_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(name_l)
	var desc := Label.new()
	desc.text = w[2]
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.add_theme_font_size_override("font_size", 13)
	desc.add_theme_color_override("font_color", MoonSkin.CREAM_DIM)
	desc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(desc)
	if not w[3]:
		b.modulate = Color(0.72, 0.68, 0.82)
		b.tooltip_text = "잠김 — 아직 만나지 못한 마녀"
	b.pressed.connect(func(): select_witch(i))
	slot_buttons.append(b)
	return b


func _open_select() -> void:
	select_panel.visible = true
	menu.visible = false
	title_box.visible = false
	sounds.play("panel_open")
	select_witch(0)
	start_btn.grab_focus.call_deferred()


func close_select() -> void:
	select_panel.visible = false
	menu.visible = true
	title_box.visible = true
	new_btn.grab_focus.call_deferred()


## 잠긴 칸은 고를 수 없다. 반환: 실제로 선택됐는지.
func select_witch(i: int) -> bool:
	var ok: bool = WITCHES[i][3]
	if ok:
		selected = i
		select_note.text = "선택: %s" % WITCHES[i][1]
	else:
		select_note.text = "아직 잠겨 있습니다 — 다른 마녀의 이야기는 나중에 열립니다"
		sounds.play("card_deny")
	for k in slot_buttons.size():
		slot_buttons[k].set_pressed_no_signal(k == selected)
	start_btn.disabled = selected < 0
	return ok


## 새 이야기 시작: 프롤로그부터.
func start_story() -> void:
	if selected < 0:
		return
	Flow.witch_id = WITCHES[selected][0]
	if music != null:
		var tw := create_tween()
		tw.tween_property(music, "volume_db", -40.0, 0.4)
	Flow.start_game(get_tree(), true)


func _unhandled_input(event: InputEvent) -> void:
	var k := event as InputEventKey
	if k == null or not k.pressed or k.echo or k.keycode != KEY_ESCAPE:
		return
	if settings_panel.visible:
		close_settings()
	elif select_panel.visible:
		close_select()
	get_viewport().set_input_as_handled()


# ───────────────────────── 플레이스홀더 그림 ─────────────────────────

## 밤의 산장(타이틀 배경 그림이 오기 전): 하늘 그라데이션·달·숲 실루엣·눈밭·창문 불빛.
class NightLodge extends Control:
	var t := 0.0

	func _draw() -> void:
		var s := size
		var sky_top := Color(0.08, 0.05, 0.20)
		var sky_low := Color(0.26, 0.16, 0.40)
		for i in 24:
			var y0 := s.y * i / 24.0
			draw_rect(Rect2(0, y0, s.x, s.y / 24.0 + 1), sky_top.lerp(sky_low, i / 23.0))
		draw_circle(Vector2(s.x * 0.74, s.y * 0.2), s.y * 0.06, Color(0.98, 0.94, 0.82))
		draw_circle(Vector2(s.x * 0.74, s.y * 0.2), s.y * 0.11, Color(0.9, 0.85, 1.0, 0.08))
		var rng := RandomNumberGenerator.new()
		rng.seed = 7
		for layer in 3:
			var base := s.y * (0.62 + layer * 0.07)
			var col := Color(0.10, 0.08, 0.22).lerp(Color(0.03, 0.03, 0.09), layer / 2.0)
			var x := -40.0
			while x < s.x + 40.0:
				var h := s.y * rng.randf_range(0.16, 0.3) * (1.0 - layer * 0.15)
				var w := h * 0.42
				draw_colored_polygon(PackedVector2Array([Vector2(x, base), Vector2(x + w * 0.5, base - h), Vector2(x + w, base)]), col)
				x += w * rng.randf_range(0.55, 0.9)
			draw_rect(Rect2(0, base - 1, s.x, s.y - base + 1), col)
		# 눈밭
		draw_rect(Rect2(0, s.y * 0.8, s.x, s.y * 0.2), Color(0.42, 0.40, 0.62))
		# 산장
		var lx := s.x * 0.58
		var ly := s.y * 0.8
		var lw := s.x * 0.16
		var lh := s.y * 0.13
		draw_rect(Rect2(lx, ly - lh, lw, lh), Color(0.16, 0.10, 0.18))
		draw_colored_polygon(PackedVector2Array([Vector2(lx - lw * 0.08, ly - lh), Vector2(lx + lw * 0.5, ly - lh * 2.0), Vector2(lx + lw * 1.08, ly - lh)]), Color(0.78, 0.76, 0.92))
		draw_rect(Rect2(lx + lw * 0.72, ly - lh * 2.0, lw * 0.1, lh * 0.6), Color(0.2, 0.14, 0.2))
		var flicker := 0.85 + 0.15 * sin(t * 7.0) * sin(t * 3.1)
		for wx in [0.18, 0.62]:
			var r := Rect2(lx + lw * wx, ly - lh * 0.68, lw * 0.2, lh * 0.34)
			draw_rect(r.grow(lw * 0.06), Color(1.0, 0.7, 0.3, 0.12 * flicker))
			draw_rect(r, Color(1.0, 0.76, 0.38) * flicker)
		# 굴뚝 연기
		for k in 5:
			var p := fmod(t * 0.12 + k * 0.2, 1.0)
			draw_circle(Vector2(lx + lw * 0.77 + sin(p * 6.0 + k) * 10.0, ly - lh * 2.0 - p * s.y * 0.18), 8.0 + p * 18.0, Color(0.7, 0.66, 0.85, 0.18 * (1.0 - p)))


## 마녀 실루엣(선택 칸 그림이 오기 전): 후드 쓴 상반신. 잠긴 칸은 단색 + '?'.
class WitchSilhouette extends Control:
	var locked := false

	func _draw() -> void:
		var s := size
		var c := Vector2(s.x * 0.5, s.y * 0.5)
		var col := Color(0.16, 0.13, 0.28) if locked else Color(0.36, 0.24, 0.55)
		var cloak := PackedVector2Array([Vector2(c.x - s.x * 0.38, s.y), Vector2(c.x - s.x * 0.2, c.y - s.y * 0.05), Vector2(c.x, c.y - s.y * 0.36), Vector2(c.x + s.x * 0.2, c.y - s.y * 0.05), Vector2(c.x + s.x * 0.38, s.y)])
		draw_colored_polygon(cloak, col)
		draw_circle(Vector2(c.x, c.y - s.y * 0.12), s.x * 0.15, col.darkened(0.25))
		if locked:
			var font := get_theme_default_font()
			var fs := 96
			var w := font.get_string_size("?", HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
			draw_string(font, Vector2(c.x - w * 0.5, c.y + fs * 0.35), "?", HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(0.75, 0.68, 0.95, 0.9))
		else:
			draw_circle(Vector2(c.x + s.x * 0.17, c.y + s.y * 0.22), s.x * 0.05, Color(1.0, 0.76, 0.38))
			draw_circle(Vector2(c.x + s.x * 0.17, c.y + s.y * 0.22), s.x * 0.11, Color(1.0, 0.7, 0.3, 0.18))
