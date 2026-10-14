extends CanvasLayer
## HUD 컨트롤러: 달빛 마법 상시 HUD(scripts/ui/moon), 손패, 산장 관리창, 일시 정지(설정·지도·조작법),
## 종료 화면, 디버그 메뉴, 알림. 상시 패널의 그림·배치는 MoonHud가, 열기/닫기·시간 정지는 여기서 맡는다.

const Cfg := preload("res://scripts/config.gd")
const SessionScript := preload("res://scripts/game/game_session.gd")
const ScreenStyle := preload("res://scripts/visual/screen_style.gd")
const CameraStyle := preload("res://scripts/visual/camera_style.gd")
const AirStyle := preload("res://scripts/visual/aerial_perspective.gd")
const CardHandScript := preload("res://scripts/ui/card_hand.gd")
const ExplorationMap := preload("res://scripts/ui/exploration_map.gd")
const MoonHudScript := preload("res://scripts/ui/moon/moon_hud.gd")
const MoonLayout := preload("res://scripts/ui/moon/moon_layout.gd")
const MoonSkin := preload("res://scripts/ui/moon/moon_skin.gd")

const C_AMBER := MoonSkin.CREAM
const C_TEXT := Color(0.96, 0.93, 0.98)
const C_DIM := MoonSkin.LAVENDER

## 지도 창(접이식): 디자인 px, 오른쪽 위 기준. 중앙 플레이 영역(x350..1249)과 겹치지 않는다.
const MAP_SLOT := Rect2(1330, 128, 252, 270)

var game
var theme_res: Theme
var root: Control
var moon
var moon_ref: Control
var toast_box: VBoxContainer
var lodge_panel: PanelContainer
var lodge_timber: Label
var lodge_gold: Label
var shop_rows: Dictionary = {}
var pause_panel: PanelContainer
var pause_settings: VBoxContainer
var pause_help: Control
var settings_btn: Button
var help_btn: Button
var end_panel: PanelContainer
var end_title: Label
var end_body: Label
var debug_panel: PanelContainer
var overlay: Control
var style_select: OptionButton
var camera_select: OptionButton
var air_select: OptionButton
var time_select: OptionButton
var fog_toggle: CheckButton
var fog_select: OptionButton
var card_hand
var map_window: PanelContainer
var exploration_map


func _ready() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	theme_res = MoonSkin.make_theme()
	root = Control.new()
	root.name = "HUDRoot"
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.theme = theme_res
	add_child(root)
	overlay = HpOverlay.new()
	overlay.game = game
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(overlay)
	moon = MoonHudScript.new()
	moon.game = game
	moon.hud = self
	root.add_child(moon)
	_build_toasts()
	card_hand = CardHandScript.new()
	card_hand.name = "CardHand"
	card_hand.game = game
	card_hand.hud = self
	root.add_child(card_hand)
	_build_exploration_map()
	_build_lodge_panel()
	_build_pause()
	_build_end()
	_build_debug()
	if _ui_arg() == "moon_ref":
		show_reference(true)
	game.session.state_changed.connect(_on_state_changed)
	game.world.screen_style_changed.connect(_sync_screen_style)
	game.world.camera_style_changed.connect(_sync_camera_style)
	game.world.air_style_changed.connect(_sync_air_style)


func _ui_arg() -> String:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--ui="):
			return a.trim_prefix("--ui=")
	return ""


## 원본 재현 모드(개발용 비교): 승인 원본 8개 그룹만 보이고 동적 HUD·손패는 숨긴다.
func show_reference(on: bool) -> void:
	if on and moon_ref == null:
		moon_ref = MoonHudScript.Reference.new()
		root.add_child(moon_ref)
		root.move_child(moon_ref, moon.get_index() + 1)
	if moon_ref != null:
		moon_ref.visible = on
	moon.visible = not on
	card_hand.visible = not on


# ───────────────────────── 공용 부품(손패 UI도 사용) ─────────────────────────

func _sb(bg: Color, border := Color(0, 0, 0, 0), radius := 10, margin := 12) -> StyleBoxFlat:
	return MoonSkin.flat(bg, border, radius, margin)


func _label(text: String, size := 17, color := C_TEXT) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


func _title(text: String, size := 26) -> Label:
	var l := _label(text, size, MoonSkin.CREAM)
	l.add_theme_font_override("font", MoonSkin.font(true))
	return l


func _place(c: Control, al: float, at: float, ar: float, ab: float, ol: float, ot: float, orr: float, ob: float) -> void:
	c.anchor_left = al
	c.anchor_top = at
	c.anchor_right = ar
	c.anchor_bottom = ab
	c.offset_left = ol
	c.offset_top = ot
	c.offset_right = orr
	c.offset_bottom = ob


## 공통 확장 모달(시안에 없는 팝업): 승인 패널의 인디고 바탕·크림 경계만 따른다.
func _modal(w: float, h: float) -> PanelContainer:
	var p := PanelContainer.new()
	_place(p, 0.5, 0.5, 0.5, 0.5, -w * 0.5, -h * 0.5, w * 0.5, h * 0.5)
	p.grow_horizontal = Control.GROW_DIRECTION_BOTH
	p.grow_vertical = Control.GROW_DIRECTION_BOTH
	p.add_theme_stylebox_override("panel", MoonSkin.modal_box())
	p.visible = false
	root.add_child(p)
	return p


func _button(text: String, h := 44.0) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, h)
	return b


# ───────────────────────── 구성 ─────────────────────────

func _build_toasts() -> void:
	toast_box = VBoxContainer.new()
	toast_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	toast_box.alignment = BoxContainer.ALIGNMENT_BEGIN
	toast_box.add_theme_constant_override("separation", 4)
	_place(toast_box, 0.5, 0, 0.5, 0, -260, 140, 260, 360)
	root.add_child(toast_box)


func _build_lodge_panel() -> void:
	lodge_panel = _modal(640, 690)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	lodge_panel.add_child(v)
	var head := HBoxContainer.new()
	v.add_child(head)
	var title := _title("산장 관리")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title)
	lodge_gold = _label("", 18, MoonSkin.CREAM)
	lodge_gold.add_theme_font_override("font", MoonSkin.font(true))
	head.add_child(lodge_gold)
	lodge_timber = _label("", 14, MoonSkin.CREAM)
	lodge_timber.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(lodge_timber)
	var items := [
		["extension", "객실 증축", "정원 2 → 3명 · 다음 손님 묶음부터 적용 (1회)"],
		["pasture", "목장 증축", "울타리를 넓혀 양 최대 수를 늘립니다"],
		["graves", "묘지 확장", "산장 뒤편 무덤 자리 +2 · 무덤이 가득 차면 새 용병을 고용할 수 없습니다"],
		["sheep", "양 구입", "목장 빈자리에 양 1마리 · 다음 낮부터 털 생산"],
		["repair", "산장 수리", "산장 체력 +%d (최대 체력까지)" % int(Cfg.REPAIR_AMOUNT)],
		["heal", "마녀 회복", "마녀 체력 +%d (최대 체력까지)" % int(Cfg.HEAL_AMOUNT)],
	]
	for it in items:
		var row := PanelContainer.new()
		row.add_theme_stylebox_override("panel", MoonSkin.row_box())
		v.add_child(row)
		var h := HBoxContainer.new()
		h.add_theme_constant_override("separation", 12)
		row.add_child(h)
		var info := VBoxContainer.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info.add_theme_constant_override("separation", 1)
		h.add_child(info)
		var name_row := HBoxContainer.new()
		info.add_child(name_row)
		var name_l := _label(it[1], 19, C_TEXT)
		name_l.add_theme_font_override("font", MoonSkin.font(true))
		name_row.add_child(name_l)
		var state := _label("", 14, MoonSkin.TEAL)
		state.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		state.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		name_row.add_child(state)
		var desc := _label(it[2], 13, C_DIM)
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		info.add_child(desc)
		var reason := _label("", 13, MoonSkin.BAD)
		info.add_child(reason)
		var btn := _button("", 44)
		btn.custom_minimum_size.x = 150
		btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		var kind: String = it[0]
		btn.pressed.connect(func(): game.economy.buy(kind))
		h.add_child(btn)
		shop_rows[kind] = {"button": btn, "reason": reason, "state": state}
	var close := _button("닫기", 42)
	close.pressed.connect(close_lodge_panel)
	v.add_child(close)


func _build_pause() -> void:
	pause_panel = _modal(420, 300)
	var v := VBoxContainer.new()
	v.custom_minimum_size.x = 360
	v.add_theme_constant_override("separation", 10)
	pause_panel.add_child(v)
	var t := _title("일시 정지")
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(t)
	var resume := _button("계속하기")
	resume.pressed.connect(_toggle_pause)
	v.add_child(resume)
	var map_btn := _button("지도 보기")
	map_btn.pressed.connect(_open_map_from_pause)
	v.add_child(map_btn)
	settings_btn = _button("화면 설정  ▾")
	settings_btn.pressed.connect(func(): _toggle_section(pause_settings))
	v.add_child(settings_btn)
	pause_settings = VBoxContainer.new()
	pause_settings.add_theme_constant_override("separation", 4)
	pause_settings.visible = false
	v.add_child(pause_settings)
	_build_screen_styles(pause_settings)
	help_btn = _button("조작법  ▾")
	help_btn.pressed.connect(func(): _toggle_section(pause_help))
	v.add_child(help_btn)
	pause_help = _label("WASD / 방향키 · 좌클릭: 이동  ·  휠: 줌\nC: 마녀 보기  ·  H: 산장으로 이동  ·  F4: 산장뷰\nM: 지도  ·  카드 드래그: 사용 (우클릭 취소)\n털 난 양 클릭: 수확  ·  손님 클릭: 고용\nEsc: 일시 정지  ·  F1: 디버그  ·  F2/F3/F5: 화면  ·  F11: 전체화면", 14, C_TEXT)
	pause_help.visible = false
	v.add_child(pause_help)
	v.add_child(HSeparator.new())
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	v.add_child(row)
	for pair in [["새 게임", _restart], ["종료", func(): get_tree().quit()]]:
		var b := _button(pair[0])
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.pressed.connect(pair[1])
		row.add_child(b)


func _toggle_section(section: Control) -> void:
	section.visible = not section.visible
	settings_btn.text = "화면 설정  " + ("▴" if pause_settings.visible else "▾")
	help_btn.text = "조작법  " + ("▴" if pause_help.visible else "▾")
	_recenter(pause_panel)


func _recenter(p: Control) -> void:
	p.reset_size()
	var sz := p.get_combined_minimum_size()
	p.offset_left = -sz.x * 0.5
	p.offset_right = sz.x * 0.5
	p.offset_top = -sz.y * 0.5
	p.offset_bottom = sz.y * 0.5


func _build_end() -> void:
	end_panel = _modal(540, 360)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 14)
	end_panel.add_child(v)
	end_title = _title("", 32)
	end_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(end_title)
	end_body = _label("", 16, C_TEXT)
	end_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	end_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	end_body.custom_minimum_size.x = 500
	v.add_child(end_body)
	var b := _button("새 게임", 48)
	b.pressed.connect(_restart)
	v.add_child(b)


func _build_debug() -> void:
	debug_panel = PanelContainer.new()
	debug_panel.add_theme_stylebox_override("panel", MoonSkin.tooltip_box())
	_place(debug_panel, 1, 0, 1, 0, -240, 136, -16, 556)
	debug_panel.visible = false
	root.add_child(debug_panel)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 5)
	debug_panel.add_child(v)
	v.add_child(_label("디버그 (F1)", 16, MoonSkin.GOOD))
	var entries := [
		["골드 +100", game.debug_gold],
		["웨이브 즉시 시작", game.debug_start_wave],
		["용 강제 소환", game.debug_force_dragon],
		["산장 피해 50", game.debug_damage_lodge],
		["마녀 피해 25", game.debug_damage_player],
		["적 전체 처치", game.debug_kill_all],
		["카드 지급", game.debug_cards],
		["적 경로·공격 지점 표시", game.debug_toggle_draw],
		["달빛 UI 원본 비교", func(): show_reference(moon.visible)],
	]
	for e in entries:
		var b := Button.new()
		b.text = e[0]
		b.add_theme_font_size_override("font_size", 14)
		b.pressed.connect(e[1])
		v.add_child(b)


func _build_screen_styles(box: VBoxContainer) -> void:
	box.add_child(_label("셰이딩 · F2", 14, C_DIM))
	style_select = OptionButton.new()
	style_select.name = "ScreenStyleSelect"
	for label in ScreenStyle.NAMES: style_select.add_item(label)
	style_select.item_selected.connect(func(index: int): game.world.set_screen_style(ScreenStyle.IDS[index]))
	box.add_child(style_select)
	_sync_screen_style(ScreenStyle.current_id)
	box.add_child(_label("카메라 · F3", 14, C_DIM))
	camera_select = OptionButton.new()
	camera_select.name = "CameraStyleSelect"
	for label in CameraStyle.NAMES: camera_select.add_item(label)
	camera_select.item_selected.connect(func(index: int): game.world.set_camera_style(CameraStyle.IDS[index]))
	box.add_child(camera_select)
	_sync_camera_style(CameraStyle.current_id)
	box.add_child(_label("공기 원근 · F5", 14, C_DIM))
	air_select = OptionButton.new()
	air_select.name = "AirStyleSelect"
	for label in AirStyle.NAMES: air_select.add_item(label)
	air_select.item_selected.connect(func(index: int): game.world.set_air_style(AirStyle.IDS[index]))
	box.add_child(air_select)
	_sync_air_style(AirStyle.current_id)
	box.add_child(_label("시간대 · 라이팅 비교", 14, C_DIM))
	time_select = OptionButton.new()
	var cycle := preload("res://scripts/visual/day_cycle.gd")
	for label in cycle.NAMES: time_select.add_item(label)
	time_select.item_selected.connect(func(index: int): game.world.day_cycle.set_mode(cycle.IDS[index]))
	box.add_child(time_select)
	fog_toggle = CheckButton.new()
	fog_toggle.text = "전장의 안개"
	fog_toggle.button_pressed = true
	fog_toggle.toggled.connect(func(value: bool): game.world.fog_of_war.set_enabled(value))
	box.add_child(fog_toggle)
	fog_select = OptionButton.new()
	fog_select.name = "FogStyleSelect"
	var fog := preload("res://scripts/visual/fog_of_war.gd")
	for label in fog.NAMES: fog_select.add_item(label)
	fog_select.item_selected.connect(func(index: int): game.world.fog_of_war.configure(fog.IDS[index]))
	box.add_child(fog_select)


func _sync_screen_style(id: String) -> void:
	style_select.select(ScreenStyle.IDS.find(id))


func _sync_camera_style(id: String) -> void:
	camera_select.select(CameraStyle.IDS.find(id))


func _sync_air_style(id: String) -> void:
	air_select.select(AirStyle.IDS.find(id))


## 기존 탐색 지도는 그대로 쓰되 상시 표시하지 않는다. 일시 정지 '지도 보기' 또는 M으로 열고, 재개 후에도 접을 수 있다.
func _build_exploration_map() -> void:
	map_window = PanelContainer.new()
	map_window.name = "MapWindow"
	map_window.add_theme_stylebox_override("panel", MoonSkin.flat(Color(MoonSkin.INK, 0.9), Color(MoonSkin.CREAM, 0.6), 12, 6, 1))
	map_window.visible = false
	root.add_child(map_window)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 4)
	map_window.add_child(v)
	var head := HBoxContainer.new()
	v.add_child(head)
	var t := _label("  지도 · 클릭해 이동", 14, MoonSkin.CREAM)
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(t)
	var close := Button.new()
	close.text = "✕"
	close.tooltip_text = "지도 접기 · M"
	close.custom_minimum_size = Vector2(30, 26)
	close.add_theme_font_size_override("font_size", 13)
	close.pressed.connect(func(): set_map_visible(false))
	head.add_child(close)
	exploration_map = ExplorationMap.new()
	exploration_map.game = game
	exploration_map.custom_minimum_size = Vector2(240, 228)
	v.add_child(exploration_map)
	root.resized.connect(_place_map)
	_place_map()


func _place_map() -> void:
	var view := root.size
	var at := MoonLayout.to_view(MAP_SLOT.position, Vector2(1, 0), view)
	var w := map_window.get_combined_minimum_size().x
	map_window.position = Vector2(minf(at.x, view.x - w - 12.0), at.y)


func set_map_visible(on: bool) -> void:
	map_window.visible = on
	if on:
		_place_map()


func _open_map_from_pause() -> void:
	set_map_visible(true)
	_toggle_pause()


# ───────────────────────── 동작 ─────────────────────────

## 시간 정지는 열린 창으로부터 한 곳에서 계산한다. 낮의 관리·창고·판매 창과 Esc 메뉴는 정지, 전투 중 창고는 정지하지 않는다.
func refresh_pause() -> void:
	if game.world.day_cycle != null:
		time_select.select(preload("res://scripts/visual/day_cycle.gd").IDS.find(game.world.day_cycle.mode))
		fog_toggle.set_pressed_no_signal(game.world.fog_of_war.enabled)
		fog_select.select(preload("res://scripts/visual/fog_of_war.gd").IDS.find(game.world.fog_of_war.current_id))
	var prep: bool = game.session.state == SessionScript.State.PREP
	var hold: bool = pause_panel.visible or lodge_panel.visible or game.session.is_over()
	if card_hand != null:
		hold = hold or card_hand.sale_panel.visible or (prep and card_hand.storage_panel.visible)
	get_tree().paused = hold


func open_lodge_panel() -> void:
	if game.session.state != SessionScript.State.PREP or pause_panel.visible or end_panel.visible:
		return
	card_hand.close_all()
	lodge_panel.visible = true
	_refresh_shop()
	refresh_pause()


func close_lodge_panel() -> void:
	if not lodge_panel.visible:
		return
	lodge_panel.visible = false
	refresh_pause()


func _toggle_pause() -> void:
	if end_panel.visible:
		return
	pause_panel.visible = not pause_panel.visible
	if pause_panel.visible:
		_recenter(pause_panel)
	refresh_pause()


func _restart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func toast(text: String, color := Color.WHITE) -> void:
	var p := PanelContainer.new()
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_theme_stylebox_override("panel", MoonSkin.toast_box())
	var l := _label(text, 17, color)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	p.add_child(l)
	toast_box.add_child(p)
	if toast_box.get_child_count() > 4:
		toast_box.get_child(0).queue_free()
	var tw := p.create_tween()
	tw.tween_interval(2.4)
	tw.tween_property(p, "modulate:a", 0.0, 0.6)
	tw.tween_callback(p.queue_free)


func _unhandled_input(event: InputEvent) -> void:
	var k := event as InputEventKey
	if k != null and k.pressed and not k.echo:
		match k.keycode:
			KEY_ESCAPE:
				if lodge_panel.visible:
					close_lodge_panel()
				elif card_hand.sale_panel.visible:
					card_hand.close_sale()
				elif card_hand.storage_panel.visible:
					card_hand.close_storage()
				else:
					_toggle_pause()
				get_viewport().set_input_as_handled()
			KEY_F1:
				debug_panel.visible = not debug_panel.visible
				get_viewport().set_input_as_handled()
			KEY_F2:
				var index := ScreenStyle.IDS.find(ScreenStyle.current_id)
				game.world.set_screen_style(ScreenStyle.IDS[(index+1)%ScreenStyle.IDS.size()])
				get_viewport().set_input_as_handled()
			KEY_F3:
				var index := CameraStyle.IDS.find(CameraStyle.current_id)
				game.world.set_camera_style(CameraStyle.IDS[(index+1)%CameraStyle.IDS.size()])
				get_viewport().set_input_as_handled()
			KEY_F4:
				game.world.player_camera.toggle_overview()
				get_viewport().set_input_as_handled()
			KEY_F5:
				var index := AirStyle.IDS.find(AirStyle.current_id)
				game.world.set_air_style(AirStyle.IDS[(index+1)%AirStyle.IDS.size()])
				get_viewport().set_input_as_handled()
			KEY_M:
				if not get_tree().paused:
					set_map_visible(not map_window.visible)
					get_viewport().set_input_as_handled()


func _on_state_changed(state: int) -> void:
	if state == SessionScript.State.VICTORY or state == SessionScript.State.DEFEAT:
		lodge_panel.visible = false
		pause_panel.visible = false
		card_hand.close_all()
		end_panel.visible = true
		var s = game.session
		var stats := "플레이 시간 %d:%02d  ·  번 골드 %dG  ·  잃은 양 %d마리" % [int(s.play_time) / 60, int(s.play_time) % 60, game.economy.total_earned, game.sheep_lost]
		var cs: Dictionary = game.cards.stats
		var ct: Dictionary = game.contracts.stats
		stats += "
고용 %d명 · 목재 %d · 양털 %d(판매 %d) · 괴물 카드 %d
남은 용병 %d · 무덤 %d기 · 시든 하수인 %d · 남은 카드 %d장" % [cs["hired"], cs["timber"], cs["wool"], cs["wool_sold"], cs["monster"], game.contracts.mercs_alive(), game.world.graveyard.count(), ct["withered"], game.cards.entries.size()]
		if state == SessionScript.State.VICTORY:
			end_title.text = "시연 완료!"
			end_body.text = "3웨이브를 모두 막아 냈습니다. 산장의 창문은 오늘 밤도 따뜻합니다.\n\n" + stats
		else:
			end_title.text = "게임 오버"
			end_body.text = "%s.\n(웨이브 %d)\n\n%s" % [s.defeat_reason, s.wave_index, stats]
		_recenter(end_panel)
	if state != SessionScript.State.PREP:
		lodge_panel.visible = false
		refresh_pause()


func _process(_delta: float) -> void:
	if lodge_panel.visible:
		_refresh_shop()


## 관리창: 실제 가격·골드·체력·완료 여부(명세 §4.7). 판정·차감은 economy가 한다.
func _refresh_shop() -> void:
	var eco = game.economy
	lodge_gold.text = "보유 %dG" % eco.gold
	lodge_timber.text = "목재 %d개 보유 · 건물의 생성·증축·확장에는 목재가 듭니다. 관리창을 여는 동안 준비 시간이 멈춥니다." % eco.timber()
	var lo = game.world.lodge
	var pl = game.player
	var pa = game.world.pasture
	var gy = game.world.graveyard
	var states := {
		"extension": "완료" if lo.extension_built else "정원 %d명" % eco.capacity,
		"pasture": "%d단계 · 양 최대 %d" % [pa.level + 1, pa.capacity()],
		"graves": "무덤 %d/%d" % [gy.count(), gy.capacity()],
		"repair": "산장 %d/%d" % [int(ceil(lo.hp)), int(lo.max_hp)],
		"heal": "마녀 %d/%d" % [int(ceil(pl.hp)), int(pl.max_hp)],
		"sheep": "양 %d/%d" % [pa.alive_count(), pa.capacity()],
	}
	for kind in shop_rows:
		var row: Dictionary = shop_rows[kind]
		var r: String = eco.block_reason(kind)
		row["button"].disabled = r != ""
		row["button"].text = eco.price_text(kind)
		row["reason"].text = r
		row["state"].text = states.get(kind, "")


# ───────────────────────── 체력 바 오버레이 ─────────────────────────

class HpOverlay extends Control:
	var game

	func _process(_delta: float) -> void:
		queue_redraw()

	func _draw() -> void:
		var cam: Camera3D = game.world.camera
		for n in get_tree().get_nodes_in_group("show_hp"):
			if not is_instance_valid(n) or n.dead:
				continue
			var is_enemy: bool = n.is_in_group("enemies")
			if game.world.fog_of_war != null and not game.world.fog_of_war.is_visible_at(n.global_position): continue
			var is_player: bool = n == game.player
			if not is_enemy and n.hp >= n.max_hp:
				continue
			var wp: Vector3 = n.global_position + Vector3(0, n.hp_offset, 0)
			if cam.is_position_behind(wp):
				continue
			var sp := cam.unproject_position(wp)
			var w := 44.0 if is_enemy else 54.0
			if n == game.world.lodge:
				w = 120.0
			var h := 6.0
			var frac := clampf(n.hp / n.max_hp, 0.0, 1.0)
			var col := Color(0.95, 0.35, 0.45)
			if is_player:
				col = Color(0.75, 0.6, 1.0)
			elif n == game.world.lodge:
				col = Color(1.0, 0.72, 0.4)
			elif n.is_in_group("sheep"):
				col = Color(0.95, 0.95, 0.85)
			elif n.is_in_group("allies"):
				col = Color(0.6, 1.0, 0.6)
			var r := Rect2(sp - Vector2(w * 0.5, 0), Vector2(w, h))
			draw_rect(r.grow(1.5), Color(0.05, 0.03, 0.1, 0.8))
			draw_rect(Rect2(r.position, Vector2(w * frac, h)), col)
		_draw_cards_world(cam)
		if game.world.debug_draw:
			_draw_debug(cam)

	func _tag(cam: Camera3D, wp: Vector3, text: String, col: Color, size := 14) -> void:
		if game.world.fog_of_war != null and not game.world.fog_of_war.is_visible_at(wp): return
		if cam.is_position_behind(wp):
			return
		var font := get_theme_default_font()
		var sp := cam.unproject_position(wp)
		var w := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
		var at := sp + Vector2(-w * 0.5, 0)
		draw_rect(Rect2(at + Vector2(-6, -size - 2), Vector2(w + 12, size + 8)), Color(0.08, 0.05, 0.16, 0.78))
		draw_string(font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, col)

	## 카드와 연결된 월드 정보: 아군 임무·털 난 양·고용을 기다리는 손님·카드 표식 괴물.
	func _draw_cards_world(cam: Camera3D) -> void:
		for a in get_tree().get_nodes_in_group("allies"):
			if a.dead:
				continue
			_tag(cam, a.global_position + Vector3(0, a.hp_offset + 0.5, 0), "%s · %s" % [a.display_name(), a.status_text()], Color(1.0, 0.9, 0.7), 13)
		if game.session.state == 0:
			for s in game.world.pasture.slots:
				if s != null and not s.dead and s.wool_ready and not s.shearing 						and not (game.player.shearing and s.global_position.distance_to(game.player.global_position) < 1.6):
					_tag(cam, s.global_position + Vector3(0, 1.2, 0), "털 수확", Color(1.0, 0.97, 0.85), 13)
			_draw_shear_gauge(cam)
			for o in game.economy.offers:
				var g = o["guest"]
				if is_instance_valid(g):
					_tag(cam, g.global_position + Vector3(0, 2.1, 0), "%s · 고용 %dG" % [o["person"], Cfg.CONTRACT_COST], Color(1.0, 0.82, 0.5), 14)
		for e in get_tree().get_nodes_in_group("enemies"):
			if not e.dead and e.card_drop != "":
				_tag(cam, e.global_position + Vector3(0, 2.35, 0), "처치 시 카드", Color(0.65, 1.0, 0.55), 13)

	## 털 깎기 진행: 마녀 머리 위의 작은 게이지.
	func _draw_shear_gauge(cam: Camera3D) -> void:
		var pl = game.player
		if not pl.shearing:
			return
		var wp: Vector3 = pl.global_position + Vector3(0, pl.hp_offset + 0.35, 0)
		if cam.is_position_behind(wp):
			return
		var sp := cam.unproject_position(wp)
		var w := 46.0
		var h := 7.0
		var frac := clampf(pl.harvest_t / Cfg.HARVEST_TIME, 0.0, 1.0)
		var r := Rect2(sp - Vector2(w * 0.5, 0), Vector2(w, h))
		draw_rect(r.grow(2.0), Color(0.08, 0.05, 0.16, 0.85))
		draw_rect(r, Color(0.3, 0.28, 0.4, 0.9))
		draw_rect(Rect2(r.position, Vector2(w * frac, h)), Color(1.0, 0.95, 0.78))
		var font := get_theme_default_font()
		draw_string(font, sp + Vector2(-w * 0.5 - 22, h), "✂", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(1.0, 0.97, 0.85))

	func _draw_debug(cam: Camera3D) -> void:
		var lodge = game.world.lodge
		for p in lodge.attack_points:
			draw_circle(cam.unproject_position(p), 4.0, Color(1, 0.8, 0.2, 0.9))
		for e in get_tree().get_nodes_in_group("enemies"):
			var a := cam.unproject_position(e.global_position)
			var path: PackedVector3Array = e.agent.get_current_navigation_path()
			var prev := a
			for i in range(e.agent.get_current_navigation_path_index(), path.size()):
				var b := cam.unproject_position(path[i])
				draw_line(prev, b, Color(0.4, 1.0, 0.6, 0.7), 1.5)
				prev = b
			if e.path_failed:
				draw_circle(a, 9.0, Color(1, 0.1, 0.1, 0.8))
				draw_string(get_theme_default_font(), a + Vector2(10, -6), "경로 실패", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(1, 0.4, 0.4))
