extends CanvasLayer
## 비차단 도착 소개는 손패 위에 표시한 뒤 초상을 관리 버튼으로 보낸다.
## presentation_only 모드에서는 중앙 대화창의 인물·대사 표현만 담당한다.
const MoonSkin := preload("res://scripts/ui/moon/moon_skin.gd")
const Extension := preload("res://scripts/ui/moon/moon_extension.gd")
const InkShader := preload("res://shaders/guest_ink_panel.tres")
const PortraitShader := preload("res://shaders/guest_portrait.gdshader")
const Session := preload("res://scripts/game/game_session.gd")
const MoonLayout := preload("res://scripts/ui/moon/moon_layout.gd")
const DESIGN_SIZE := Vector2(1200, 600)
const NOTICE_DURATION := 0.6
const PORTRAIT_RECT := Rect2(0, 0, 480, 600)
const PANEL_RECT := Rect2(70, 78, 1130, 500)
const TEXT_X := 524.0
const TEXT_WIDTH := 580.0
const EXIT_DURATION := 0.5
const TEXT_IN_TIME := 0.46     # 줄마다 올라오는 모션 시간(_animate_guest와 같은 값)
const PORTRAIT_IN_TIME := 0.69

signal introduction_finished
signal guest_admitted(profile: Dictionary)
var game
var presentation_only := false
var dialogue_font_size := 28
var text_width := TEXT_WIDTH
var portrait_home := PORTRAIT_RECT.position
var rule_home := Vector2(TEXT_X, 337)
var flight_time := 0.0
var flight_start := Vector2.ZERO
var flight_size := Vector2.ZERO
var last_landing := Vector2.ZERO
var flying_portrait: TextureRect
var active := false
var phase := "idle"
var profiles: Array = []
var guest_index := -1
var pending: Array = []
var clock := 0.0
var phase_time := 0.0
var guest_duration := 7.0
var ready_time := 0.0          # 이 시각(phase_time) 전에는 클릭으로 넘기지 않는다: 글이 다 나올 때까지 최소 표시
var hint: Label
var root: Control
var stage: Control
var notice: Control
var panel: ColorRect
var panel_material: ShaderMaterial
var shadow: ColorRect
var shadow_material: ShaderMaterial
var portrait: TextureRect
var name_label: Label
var role_label: Label
var detail_label: Label
var count_label: Label
var dialogue_lines: Array[Label] = []
var rule: ColorRect
var progress: ColorRect
var chime: AudioStreamPlayer
var text_motion: Array = []
var _texture_cache: Dictionary = {}

func _ready() -> void:
	name = "GuestArrival"
	layer = 20 if presentation_only else 8
	process_mode = Node.PROCESS_MODE_ALWAYS if presentation_only else Node.PROCESS_MODE_PAUSABLE
	root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.theme = MoonSkin.make_theme()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.visible = false
	add_child(root)
	stage = Control.new()
	stage.name = "FloatingGuest"
	stage.size = DESIGN_SIZE
	stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(stage)
	_build_story()
	_build_hint()
	_build_notice()
	_build_chime()
	flying_portrait = TextureRect.new()
	flying_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	flying_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	flying_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flying_portrait.visible = false
	root.add_child(flying_portrait)
	get_viewport().size_changed.connect(_layout)
	if not presentation_only:
		game.economy.batch_arrived.connect(enqueue)
		game.session.state_changed.connect(_on_session_changed)
	_layout()

func _ink(at: Rect2, opacity: float) -> ColorRect:
	var rect := ColorRect.new()
	rect.position = at.position
	rect.size = at.size
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var mat := ShaderMaterial.new()
	mat.shader = InkShader
	mat.set_shader_parameter("reveal", 0.0)
	mat.set_shader_parameter("opacity", opacity)
	rect.material = mat
	stage.add_child(rect)
	return rect

func _text(text: String, at: Rect2, pixels: int, color: Color, delay: float, bold := false) -> Label:
	# 줄별 클리핑 + 위치/알파: 타자기 대신 정돈된 모션 그래픽으로 올라온다.
	var clip := Control.new()
	clip.position = at.position
	clip.size = at.size
	clip.clip_contents = true
	clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage.add_child(clip)
	var label := Label.new()
	label.text = text
	label.size = at.size
	label.add_theme_font_override("font", MoonSkin.font(bold))
	label.add_theme_font_size_override("font_size", pixels)
	label.add_theme_color_override("font_color", color)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip.add_child(label)
	text_motion.append({"label": label, "delay": delay, "travel": 18.0 if bold else 12.0})
	return label

func _build_story() -> void:
	if not presentation_only:
		_build_compact_story()
		return
	shadow = _ink(Rect2(PANEL_RECT.position + Vector2(-9, 16), PANEL_RECT.size + Vector2(14, 15)), 0.22)
	shadow_material = shadow.material
	panel = _ink(PANEL_RECT, 0.985)
	panel.name = "LivingInkPanel"
	panel_material = panel.material
	portrait = TextureRect.new()
	portrait.name = "CutoutPortrait"
	portrait.position = PORTRAIT_RECT.position
	portrait.size = PORTRAIT_RECT.size
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var mat := ShaderMaterial.new()
	mat.shader = PortraitShader
	portrait.material = mat
	stage.add_child(portrait)
	count_label = _text("", Rect2(TEXT_X, 119, TEXT_WIDTH, 32), 17, Color8(172, 156, 184), 0.26)
	name_label = _text("", Rect2(TEXT_X - 3, 164, TEXT_WIDTH, 76), 54, Color8(250, 230, 188), 0.4, true)
	role_label = _text("", Rect2(TEXT_X, 245, TEXT_WIDTH, 34), 23, Color8(167, 199, 194), 0.55)
	detail_label = _text("", Rect2(TEXT_X, 284, TEXT_WIDTH, 32), 19, Color8(177, 167, 186), 0.67)
	rule = ColorRect.new()
	rule.position = Vector2(TEXT_X, 337)
	rule.color = Color8(197, 165, 116, 160)
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage.add_child(rule)
	for i in 3:
		var label := _text("", Rect2(TEXT_X, 359 + i * 45, TEXT_WIDTH, 45), 28, Color8(236, 227, 216), 0.94 + i * 0.15)
		label.name = "DialogueLine%d" % i
		dialogue_lines.append(label)
	progress = ColorRect.new()
	progress.position = Vector2(TEXT_X, 526)
	progress.color = Color8(179, 151, 120, 95)
	progress.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage.add_child(progress)

func _build_compact_story() -> void:
	stage.size = Vector2(1100, 380)
	text_width = 715.0
	dialogue_font_size = 33
	portrait_home = Vector2.ZERO
	rule_home = Vector2(328, 139)
	shadow = _ink(Rect2(89, 66, 1014, 320), 0.2)
	shadow_material = shadow.material
	panel = _ink(Rect2(100, 48, 1000, 325), 0.985)
	panel_material = panel.material
	portrait = TextureRect.new()
	portrait.name = "CutoutPortrait"
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.size = Vector2(304, 380)
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var mat := ShaderMaterial.new()
	mat.shader = PortraitShader
	portrait.material = mat
	stage.add_child(portrait)
	count_label = _text("", Rect2(866, 88, 180, 27), 17, MoonSkin.LAVENDER, 0.12)
	name_label = _text("", Rect2(326, 70, 210, 62), 41, MoonSkin.CREAM, 0.12, true)
	role_label = _text("", Rect2(540, 87, 320, 35), 25, Color8(170, 202, 196), 0.2)
	detail_label = _text("", Rect2(0, 0, 0, 0), 18, MoonSkin.LAVENDER, 0.2)
	detail_label.get_parent().visible = false
	rule = ColorRect.new()
	rule.position = rule_home
	rule.color = Color8(197, 165, 116, 130)
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage.add_child(rule)
	for i in 3:
		var label := _text("", Rect2(328, 156 + i * 47, text_width, 47), dialogue_font_size, Color8(244, 235, 221), 0.3 + i * 0.08)
		dialogue_lines.append(label)
	progress = ColorRect.new()
	progress.position = Vector2(328, 324)
	progress.color = Color8(179, 151, 120, 90)
	progress.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage.add_child(progress)

## 글이 다 나온 뒤 패널 오른쪽 아래에 뜨는 안내.
func _build_hint() -> void:
	hint = Label.new()
	hint.text = "클릭하여 계속 ▸"
	hint.size = Vector2(220, 32)
	hint.position = panel.position + panel.size - Vector2(hint.size.x + 30, hint.size.y + 18)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hint.add_theme_font_override("font", MoonSkin.font(true))
	hint.add_theme_font_size_override("font_size", 21)
	hint.add_theme_color_override("font_color", MoonSkin.LAVENDER)
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hint.modulate.a = 0.0
	hint.visible = not presentation_only
	stage.add_child(hint)


func _build_notice() -> void:
	notice = Control.new()
	notice.size = Vector2(680, 58)
	notice.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(notice)
	var back := Panel.new()
	back.size = notice.size
	back.mouse_filter = Control.MOUSE_FILTER_IGNORE
	back.add_theme_stylebox_override("panel", Extension.toast())
	notice.add_child(back)
	var footsteps := Extension.icon("footsteps", 32)
	footsteps.position = Vector2(15, 12)
	footsteps.size = Vector2(32, 32)
	notice.add_child(footsteps)
	var label := Label.new()
	label.name = "Count"
	label.position = Vector2(16, 0)
	label.size = Vector2(648, 58)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", MoonSkin.CREAM)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	notice.add_child(label)

func _layout() -> void:
	var view := get_viewport().get_visible_rect().size
	var s := minf(view.x / 2540.0, view.y / 1150.0) if presentation_only else minf(view.x / 3400.0, view.y / 1600.0)
	stage.scale = Vector2.ONE * s
	if presentation_only:
		stage.position = Vector2(view.x * 0.5, view.y * 0.48) - stage.size * s * 0.5
	else:
		var hud_scale := MoonLayout.ui_scale(view)
		var hand_bottom := MoonLayout.to_view(Vector2(800, game.hud.card_hand.CARD_BOTTOM), Vector2(0.5, 1), view).y
		var hand_top: float = hand_bottom - game.hud.card_hand.CARD_DESIGN.y * hud_scale
		stage.position = Vector2((view.x - stage.size.x * s) * 0.5, hand_top - 14.0 * hud_scale - stage.size.y * s)
	notice.scale = Vector2.ONE * s
	notice.position = Vector2((view.x - notice.size.x * s) * 0.5, stage.position.y + 80.0 * s)

func enqueue(arriving: Array) -> void:
	if OS.get_cmdline_user_args().has("--guest-intros=off"): return
	if arriving.is_empty() or game.session.is_over(): return
	pending.append(arriving.duplicate(true))
	if not active: _begin_next()

func _begin_next() -> void:
	profiles = pending.pop_front()
	guest_index = -1
	active = true
	phase = "notice"
	phase_time = 0.0
	root.visible = true
	stage.visible = false
	notice.visible = true
	notice.modulate.a = 0.0
	notice.get_node("Count").text = "✧  손님 %d명이 산장을 찾아옵니다" % profiles.size()
	# 선택된 도착음이 있으면 그것을, 없으면 예전 합성 차임을 쓴다
	if game != null and game.sounds != null and game.sounds.streams.has("guest_arrive"):
		game.sounds.play("guest_arrive")
	else:
		chime.play()

func _show_guest() -> void:
	guest_index += 1
	if game != null and game.sounds != null:
		game.sounds.play("guest_card")
	phase = "guest"
	phase_time = 0.0
	notice.visible = false
	stage.visible = true
	stage.modulate.a = 1.0
	portrait.visible = true
	flying_portrait.visible = false
	var profile: Dictionary = profiles[guest_index]
	var path: String = profile["portrait"]
	if not _texture_cache.has(path): _texture_cache[path] = load(path)
	portrait.texture = _texture_cache[path]
	name_label.text = profile["person"]
	role_label.text = profile["role"]
	detail_label.text = profile["detail"]
	count_label.text = ("산장의 이야기" if presentation_only else "손님 %d / %d" % [guest_index + 1, profiles.size()])
	update_dialogue(profile["line"])
	ready_time = PORTRAIT_IN_TIME
	for entry in text_motion:
		ready_time = maxf(ready_time, float(entry["delay"]) + TEXT_IN_TIME)
	guest_duration = 99999.0 if presentation_only else 0.6 + clampf(str(profile["line"]).replace("\n", "").length() / 12.0 + 1.0, 2.8, 4.4)
	_animate_guest()
	_layout()

func show_profile(profile: Dictionary, text: String, title: String = "산장의 이야기") -> void:
	profiles = [profile.duplicate(true)]
	profiles[0]["line"] = text
	guest_index = -1
	active = true
	root.visible = true
	_show_guest()
	count_label.text = title

func update_dialogue(text: String) -> void:
	# 같은 인물과 대화하는 동안 초상·정보·패널의 등장 타임라인은 유지한다.
	var lines := _wrap_dialogue(text)
	for i in dialogue_lines.size(): dialogue_lines[i].text = lines[i] if i < lines.size() else ""

func _wrap_dialogue(text: String) -> Array[String]:
	var lines: Array[String] = []
	var font: Font = MoonSkin.font()
	for paragraph in text.split("\n"):
		var line := ""
		for word in paragraph.split(" ", false):
			var candidate: String = word if line.is_empty() else line + " " + word
			if not line.is_empty() and font.get_string_size(candidate, HORIZONTAL_ALIGNMENT_LEFT, -1, dialogue_font_size).x > text_width - 4.0:
				lines.append(line.strip_edges())
				line = ""
			# 보통은 단어 사이에서 줄바꿈. 패널보다 긴 단어만 글자 단위로 나눈다.
			if not line.is_empty(): line += " "
			for character in word:
				if font.get_string_size(line + character, HORIZONTAL_ALIGNMENT_LEFT, -1, dialogue_font_size).x > text_width - 4.0:
					lines.append(line.strip_edges())
					line = ""
				line += character
		if not line.is_empty(): lines.append(line.strip_edges())
	return lines

func ease_out(value: float) -> float:
	var t := clampf(value, 0.0, 1.0)
	return 1.0 - pow(1.0 - t, 3.0)

func _animate_guest() -> void:
	var enter := ease_out(phase_time / (0.55 if presentation_only else 0.3))
	var leave := 1.0
	panel_material.set_shader_parameter("motion_time", clock)
	shadow_material.set_shader_parameter("motion_time", clock)
	panel_material.set_shader_parameter("reveal", enter)
	shadow_material.set_shader_parameter("reveal", enter)
	panel_material.set_shader_parameter("opacity", 0.985 * leave)
	shadow_material.set_shader_parameter("opacity", 0.22 * leave)
	var portrait_k := ease_out((phase_time - 0.06) / 0.63)
	portrait.modulate.a = portrait_k * leave
	portrait.position = portrait_home + Vector2(-22.0 * (1.0 - portrait_k), 14.0 * (1.0 - portrait_k) + sin(clock * 0.7) * 2.0)
	for entry in text_motion:
		var k := ease_out((phase_time - float(entry["delay"])) / TEXT_IN_TIME)
		var label: Label = entry["label"]
		label.modulate.a = k * leave
		label.position = Vector2(0, float(entry["travel"]) * (1.0 - k) - 4.0 * (1.0 - leave))
	rule.size = Vector2(76.0 * ease_out((phase_time - 0.22) / 0.35), 1.0)
	rule.modulate.a = leave
	progress.size = Vector2(54.0 * clampf(1.0 - phase_time / guest_duration, 0.0, 1.0), 1.0)
	progress.modulate.a = ease_out((phase_time - 1.4) / 0.5) * leave
	if hint != null and hint.visible:
		hint.modulate.a = ease_out((phase_time - ready_time) / 0.25) * (0.75 + 0.25 * sin(clock * 4.0)) * leave

func _process(delta: float) -> void:
	if not active: return
	clock += delta
	phase_time += delta
	if phase == "notice":
		notice.modulate.a = ease_out(phase_time / 0.12) * (1.0 - smoothstep(0.42, NOTICE_DURATION, phase_time))
		if phase_time >= NOTICE_DURATION: _show_guest()
	elif phase == "guest":
		_animate_guest()
		if not presentation_only and phase_time >= guest_duration: _start_flight()
	elif phase == "flight":
		_animate_flight(delta)

## 손님 소개 패널을 클릭하면 다음 동작(산장으로 날아감)으로 바로 넘어간다.
## 글이 다 나오기 전(ready_time 전)의 클릭은 넘기지 않지만, 패널 위 클릭이 월드로 새지 않도록 소비한다.
func _input(event: InputEvent) -> void:
	if presentation_only or not active or phase != "guest":
		return
	var mb := event as InputEventMouseButton
	if mb == null or not mb.pressed or mb.button_index != MOUSE_BUTTON_LEFT:
		return
	if not _panel_hit(mb.position):
		return
	get_viewport().set_input_as_handled()
	if phase_time >= ready_time:
		_start_flight()


func _panel_hit(p: Vector2) -> bool:
	for c: Control in [panel, portrait]:
		if (c.get_global_transform() * Rect2(Vector2.ZERO, c.size)).has_point(p):
			return true
	return false


func _start_flight() -> void:
	phase = "flight"
	flight_time = 0.0
	var rect := portrait.get_global_rect()
	flight_start = rect.get_center()
	flight_size = rect.size
	flying_portrait.texture = portrait.texture
	flying_portrait.size = flight_size
	flying_portrait.position = rect.position
	flying_portrait.modulate = Color.WHITE
	flying_portrait.visible = true
	portrait.visible = false

func _animate_flight(delta: float) -> void:
	flight_time += delta
	var t := clampf(flight_time / 0.65, 0.0, 1.0)
	var target: Vector2 = game.hud.moon.lodge_btn.get_global_rect().get_center()
	var middle := flight_start.lerp(target, 0.55) + Vector2(0, -70.0)
	var k := t * t
	var center := flight_start.lerp(middle, k).lerp(middle.lerp(target, k), k)
	flying_portrait.size = flight_size.lerp(Vector2(14, 18), k)
	flying_portrait.position = center - flying_portrait.size * 0.5
	flying_portrait.modulate.a = 1.0 - smoothstep(0.85, 1.0, t)
	var fade := 1.0 - smoothstep(0.0, 0.2, flight_time)
	stage.modulate.a = fade
	panel_material.set_shader_parameter("opacity", 0.985 * fade)
	shadow_material.set_shader_parameter("opacity", 0.22 * fade)
	if t >= 1.0:
		last_landing = target
		flying_portrait.visible = false
		if game != null and game.sounds != null:
			game.sounds.play("guest_enter")
		guest_admitted.emit(profiles[guest_index])
		if guest_index + 1 < profiles.size(): _show_guest()
		else: finish()

func finish() -> void:
	if not active: return
	active = false
	phase = "idle"
	root.visible = false
	flying_portrait.visible = false
	introduction_finished.emit()
	if not pending.is_empty(): _begin_next()

func _on_session_changed(state: int) -> void:
	if state != Session.State.PREP:
		pending.clear()
		finish()

func _build_chime() -> void:
	var data := PackedByteArray()
	var rate := 22050
	var samples := int(rate * 1.3)
	data.resize(samples * 2)
	for i in samples:
		var t := float(i) / rate
		var value := (sin(TAU * 659.25 * t) + 0.42 * sin(TAU * 1320.0 * t) + 0.18 * sin(TAU * 1840.0 * t))
		value *= exp(-t * 4.7) * minf(t * 150.0, 1.0) * 0.23
		data.encode_s16(i * 2, int(clampf(value, -1.0, 1.0) * 32767.0))
	var sound := AudioStreamWAV.new()
	sound.format = AudioStreamWAV.FORMAT_16_BITS
	sound.mix_rate = rate
	sound.data = data
	chime = AudioStreamPlayer.new()
	chime.stream = sound
	chime.volume_db = -16.0
	add_child(chime)

