extends CanvasLayer
## 도입의 '산장 주변 소식' 패널(판마다 바뀌는 월드 설정, scripts/game/world_setting.gd).
## 1일차 새벽 뒤 시작 손패 전에 이번 판의 주요 종족 둘(마을·손님의 결·대표 초상)과 가끔 오는 종족을 보여 주고,
## 플레이어가 '산장 문을 연다'를 누르면 닫힌다. 게임은 도입이 멈춰 둔 상태 그대로다.

signal confirmed

const MoonSkin := preload("res://scripts/ui/moon/moon_skin.gd")
const Extension := preload("res://scripts/ui/moon/moon_extension.gd")
const Races := preload("res://scripts/game/races.gd")
const GuestProfiles := preload("res://scripts/ui/guest_profiles.gd")

const PANEL_SIZE := Vector2(980, 600)
const FACES_PER_RACE := 4
const COLUMN_TEXT := 400.0   # 종족 칸 안의 글 폭

var active := false
var root: Control
var panel: PanelContainer
var title: Label
var columns: HBoxContainer
var minor_label: Label
var confirm_btn: Button
var shown_majors: Array = []   # 검증용
var _on_done: Callable


func _ready() -> void:
	name = "WorldSettingPanel"
	layer = 28
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.theme = MoonSkin.make_theme()
	add_child(root)
	var dim := ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.02, 0.0, 0.06, 0.55)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(dim)
	panel = PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.07, 0.045, 0.12, 0.96)
	sb.border_color = Color(MoonSkin.TEAL, 0.55)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(18)
	sb.set_content_margin_all(28)
	sb.shadow_color = Color(0, 0, 0, 0.5)
	sb.shadow_size = 18
	panel.add_theme_stylebox_override("panel", sb)
	panel.custom_minimum_size = Vector2(PANEL_SIZE.x, 0)
	root.add_child(panel)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 14)
	panel.add_child(v)
	title = _label("이번 겨울, 산장 주변", 34, MoonSkin.CREAM, true)
	v.add_child(title)
	v.add_child(_label("가까운 마을의 손님이 자주 찾아옵니다. 누구를 맞고 누구를 고용할지 미리 그려 보세요.", 17, MoonSkin.LAVENDER))
	columns = HBoxContainer.new()
	columns.add_theme_constant_override("separation", 22)
	v.add_child(columns)
	minor_label = _label("", 17, MoonSkin.CREAM_DIM)
	v.add_child(minor_label)
	confirm_btn = Button.new()
	confirm_btn.text = "산장 문을 연다"
	confirm_btn.custom_minimum_size = Vector2(280, 50)
	confirm_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	confirm_btn.add_theme_font_override("font", MoonSkin.font(true))
	confirm_btn.add_theme_font_size_override("font_size", 20)
	confirm_btn.pressed.connect(confirm)
	v.add_child(confirm_btn)
	root.resized.connect(_center)


func _label(text: String, size: int, color: Color, bold := false, width := PANEL_SIZE.x - 60.0) -> Label:
	var l := Label.new()
	# 줄바꿈 라벨은 최소 폭이 없으면 글자마다 줄이 바뀌어 세로로 늘어난다.
	l.custom_minimum_size.x = width
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_override("font", MoonSkin.font(bold))
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	return l


func _center() -> void:
	var vp := root.get_viewport_rect().size
	panel.reset_size()
	var s := minf(1.0, minf((vp.x - 32.0) / panel.size.x, (vp.y - 32.0) / panel.size.y))
	panel.scale = Vector2(s, s)
	panel.position = (vp - panel.size * s) * 0.5


## 이번 판의 설정을 펼친다. on_done은 '산장 문을 연다'를 누르면 한 번 불린다.
func show_setting(setting, on_done: Callable = Callable()) -> void:
	_on_done = on_done
	shown_majors = setting.majors.duplicate()
	for c in columns.get_children():
		columns.remove_child(c)
		c.queue_free()
	for race in setting.majors:
		columns.add_child(_race_column(race, setting))
	var minor_names: Array = setting.minors().map(func(r): return Races.name_of(r))
	minor_label.text = "그 밖에 %s 손님은 가끔 찾아옵니다." % "·".join(minor_names)
	visible = true
	active = true
	_center()
	panel.modulate.a = 0.0
	create_tween().tween_property(panel, "modulate:a", 1.0, 0.35)
	confirm_btn.grab_focus.call_deferred()


func _race_column(race: String, setting) -> Control:
	var accent: Color = Races.accent(race)
	var box := PanelContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(accent.r * 0.18, accent.g * 0.14, accent.b * 0.16 + 0.04, 0.9)
	sb.border_color = Color(accent, 0.7)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(12)
	sb.set_content_margin_all(16)
	box.add_theme_stylebox_override("panel", sb)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	box.add_child(v)
	var head := _label("%s  ·  %s" % [Races.name_of(race), Races.emblem_of(race)], 30, accent, true, COLUMN_TEXT)
	head.name = "RaceName"
	v.add_child(head)
	var village: Dictionary = setting.village(race)
	v.add_child(_label(village.get("place", ""), 19, MoonSkin.CREAM, true, COLUMN_TEXT))
	var faces := HBoxContainer.new()
	faces.alignment = BoxContainer.ALIGNMENT_CENTER
	faces.add_theme_constant_override("separation", 4)
	faces.custom_minimum_size.y = 150
	v.add_child(faces)
	var members: Array = GuestProfiles.profiles_of_race(race)
	for i in mini(FACES_PER_RACE, members.size()):
		var tr := TextureRect.new()
		tr.texture = load(members[i]["portrait"])
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tr.custom_minimum_size = Vector2(98, 146)
		tr.tooltip_text = "%s · %s" % [members[i]["person"], members[i]["role"]]
		faces.add_child(tr)
	v.add_child(_label(str(village.get("hint", "")).replace(". ", ".\n"), 16, MoonSkin.LAVENDER, false, COLUMN_TEXT))
	return box


func confirm() -> void:
	if not active:
		return
	active = false
	visible = false
	confirmed.emit()
	if _on_done.is_valid():
		var cb := _on_done
		_on_done = Callable()
		cb.call()


func _unhandled_input(event: InputEvent) -> void:
	if not active:
		return
	var k := event as InputEventKey
	if k != null and k.pressed and not k.echo and k.keycode in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE, KEY_ESCAPE]:
		confirm()
		get_viewport().set_input_as_handled()
