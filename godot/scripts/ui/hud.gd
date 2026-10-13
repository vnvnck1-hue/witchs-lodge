extends CanvasLayer
## HUD: 골드·체력·양·준비 시간·웨이브·구매·공물 버튼, 산장 패널, 일시 정지, 종료 화면, 디버그 메뉴.

const Cfg := preload("res://scripts/config.gd")
const SessionScript := preload("res://scripts/game/game_session.gd")

const C_PANEL := Color(0.11, 0.09, 0.23, 0.84)
const C_BORDER := Color(0.58, 0.48, 0.95, 0.45)
const C_AMBER := Color(1.0, 0.78, 0.4)
const C_TEXT := Color(0.94, 0.92, 1.0)
const C_DIM := Color(0.7, 0.66, 0.85)

var game
var theme_res: Theme
var root: Control
var gold_label: Label
var player_bar: ProgressBar
var player_val: Label
var lodge_bar: ProgressBar
var lodge_val: Label
var sheep_label: Label
var phase_label: Label
var sub_label: Label
var lodge_btn: Button
var dragon_btn: Button
var dragon_reason: Label
var toast_box: VBoxContainer
var lodge_panel: PanelContainer
var shop_rows: Dictionary = {}
var pause_panel: PanelContainer
var end_panel: PanelContainer
var end_title: Label
var end_body: Label
var debug_panel: PanelContainer
var overlay: Control


func _ready() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	theme_res = _make_theme()
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
	_build_status()
	_build_phase()
	_build_actions()
	_build_toasts()
	_build_hint()
	_build_lodge_panel()
	_build_pause()
	_build_end()
	_build_debug()
	game.session.state_changed.connect(_on_state_changed)


# ───────────────────────── 테마 ─────────────────────────

func _sb(bg: Color, border := Color(0, 0, 0, 0), radius := 10, margin := 12) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.set_corner_radius_all(radius)
	s.set_content_margin_all(margin)
	if border.a > 0.0:
		s.border_color = border
		s.set_border_width_all(1)
	return s


func _make_theme() -> Theme:
	var t := Theme.new()
	var f := SystemFont.new()
	f.font_names = PackedStringArray(["Malgun Gothic", "맑은 고딕", "Noto Sans KR", "Segoe UI"])
	f.font_weight = 500
	t.default_font = f
	t.default_font_size = 17
	t.set_stylebox("panel", "PanelContainer", _sb(C_PANEL, C_BORDER))
	t.set_color("font_color", "Label", C_TEXT)
	t.set_constant("outline_size", "Label", 0)
	t.set_stylebox("normal", "Button", _sb(Color(0.25, 0.18, 0.45, 0.95), Color(0.7, 0.6, 1.0, 0.5), 8, 9))
	t.set_stylebox("hover", "Button", _sb(Color(0.34, 0.25, 0.58, 1.0), Color(1.0, 0.8, 0.5, 0.8), 8, 9))
	t.set_stylebox("pressed", "Button", _sb(Color(0.45, 0.3, 0.2, 1.0), Color(1.0, 0.8, 0.5, 0.9), 8, 9))
	t.set_stylebox("disabled", "Button", _sb(Color(0.18, 0.16, 0.26, 0.85), Color(0.4, 0.38, 0.5, 0.4), 8, 9))
	t.set_stylebox("focus", "Button", StyleBoxEmpty.new())
	t.set_color("font_color", "Button", C_TEXT)
	t.set_color("font_hover_color", "Button", Color(1.0, 0.92, 0.75))
	t.set_color("font_disabled_color", "Button", Color(0.55, 0.52, 0.65))
	t.set_stylebox("background", "ProgressBar", _sb(Color(0.06, 0.05, 0.12, 0.9), Color(0, 0, 0, 0), 5, 0))
	t.set_stylebox("fill", "ProgressBar", _sb(Color(0.6, 0.85, 0.55), Color(0, 0, 0, 0), 5, 0))
	return t


func _label(text: String, size := 17, color := C_TEXT) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


func _bar(fill: Color) -> ProgressBar:
	var b := ProgressBar.new()
	b.show_percentage = false
	b.custom_minimum_size = Vector2(170, 14)
	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	b.add_theme_stylebox_override("fill", _sb(fill, Color(0, 0, 0, 0), 5, 0))
	b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return b


func _place(c: Control, al: float, at: float, ar: float, ab: float, ol: float, ot: float, orr: float, ob: float) -> void:
	c.anchor_left = al
	c.anchor_top = at
	c.anchor_right = ar
	c.anchor_bottom = ab
	c.offset_left = ol
	c.offset_top = ot
	c.offset_right = orr
	c.offset_bottom = ob


# ───────────────────────── 구성 ─────────────────────────

func _build_status() -> void:
	var p := PanelContainer.new()
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_place(p, 0, 0, 0, 0, 16, 16, 300, 150)
	root.add_child(p)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 6)
	p.add_child(v)
	gold_label = _label("◆ 0 G", 24, C_AMBER)
	v.add_child(gold_label)
	var rows := [["마녀", Color(0.75, 0.6, 1.0)], ["산장", Color(1.0, 0.72, 0.4)]]
	for i in rows.size():
		var h := HBoxContainer.new()
		h.add_theme_constant_override("separation", 8)
		v.add_child(h)
		var name_l := _label(rows[i][0], 15, C_DIM)
		name_l.custom_minimum_size.x = 36
		h.add_child(name_l)
		var bar := _bar(rows[i][1])
		h.add_child(bar)
		var val := _label("", 14, C_TEXT)
		h.add_child(val)
		if i == 0:
			player_bar = bar
			player_val = val
		else:
			lodge_bar = bar
			lodge_val = val
	sheep_label = _label("", 16, C_TEXT)
	v.add_child(sheep_label)


func _build_phase() -> void:
	var p := PanelContainer.new()
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_place(p, 0.5, 0, 0.5, 0, -230, 14, 230, 92)
	p.grow_horizontal = Control.GROW_DIRECTION_BOTH
	root.add_child(p)
	var v := VBoxContainer.new()
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	p.add_child(v)
	phase_label = _label("", 24, C_TEXT)
	phase_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(phase_label)
	sub_label = _label("", 15, C_DIM)
	sub_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(sub_label)


func _build_actions() -> void:
	var v := VBoxContainer.new()
	v.alignment = BoxContainer.ALIGNMENT_END
	v.add_theme_constant_override("separation", 8)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_place(v, 1, 1, 1, 1, -300, -200, -18, -18)
	root.add_child(v)
	lodge_btn = Button.new()
	lodge_btn.text = "산장 관리"
	lodge_btn.custom_minimum_size = Vector2(0, 46)
	lodge_btn.pressed.connect(open_lodge_panel)
	v.add_child(lodge_btn)
	dragon_btn = Button.new()
	dragon_btn.text = "용에게 공물 — %dG" % Cfg.COST_DRAGON
	dragon_btn.custom_minimum_size = Vector2(0, 58)
	dragon_btn.add_theme_font_size_override("font_size", 20)
	dragon_btn.add_theme_stylebox_override("normal", _sb(Color(0.55, 0.16, 0.18, 0.95), Color(1.0, 0.65, 0.35, 0.8), 8, 9))
	dragon_btn.add_theme_stylebox_override("hover", _sb(Color(0.7, 0.24, 0.2, 1.0), Color(1.0, 0.8, 0.45, 1.0), 8, 9))
	dragon_btn.pressed.connect(func(): game.economy.buy("dragon"))
	v.add_child(dragon_btn)
	dragon_reason = _label("", 14, C_DIM)
	dragon_reason.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	v.add_child(dragon_reason)


func _build_toasts() -> void:
	toast_box = VBoxContainer.new()
	toast_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	toast_box.alignment = BoxContainer.ALIGNMENT_BEGIN
	_place(toast_box, 0.5, 0, 0.5, 0, -260, 104, 260, 320)
	root.add_child(toast_box)


func _build_hint() -> void:
	var l := _label("좌클릭: 이동   ·   산장 클릭: 관리(준비 중)   ·   Esc: 일시 정지   ·   F1: 디버그", 14, Color(0.85, 0.82, 1.0, 0.75))
	_place(l, 0, 1, 0, 1, 18, -34, 700, -12)
	root.add_child(l)


func _modal(w: float, h: float) -> PanelContainer:
	var p := PanelContainer.new()
	_place(p, 0.5, 0.5, 0.5, 0.5, -w * 0.5, -h * 0.5, w * 0.5, h * 0.5)
	p.add_theme_stylebox_override("panel", _sb(Color(0.1, 0.08, 0.2, 0.95), Color(1.0, 0.75, 0.45, 0.6), 14, 20))
	p.visible = false
	root.add_child(p)
	return p


func _build_lodge_panel() -> void:
	lodge_panel = _modal(560, 430)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	lodge_panel.add_child(v)
	var title := _label("산장 관리", 26, C_AMBER)
	v.add_child(title)
	var note := _label("패널을 여는 동안 준비 시간이 멈춥니다.", 14, C_DIM)
	v.add_child(note)
	var items := [
		["extension", "객실 증축", "정원 2 → 3명 · 다음 손님 묶음부터 적용 (1회)"],
		["repair", "산장 수리", "산장 체력 +%d (최대 체력까지)" % int(Cfg.REPAIR_AMOUNT)],
		["heal", "마녀 회복", "마녀 체력 +%d (최대 체력까지)" % int(Cfg.HEAL_AMOUNT)],
		["sheep", "양 구입", "빈자리에 체력 최대의 양 1마리 (최대 3마리)"],
	]
	for it in items:
		var h := HBoxContainer.new()
		h.add_theme_constant_override("separation", 12)
		v.add_child(h)
		var info := VBoxContainer.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		h.add_child(info)
		info.add_child(_label(it[1], 19, C_TEXT))
		info.add_child(_label(it[2], 13, C_DIM))
		var reason := _label("", 13, Color(1.0, 0.6, 0.6))
		info.add_child(reason)
		var btn := Button.new()
		btn.text = "%dG" % game.economy.cost_of(it[0])
		btn.custom_minimum_size = Vector2(96, 44)
		var kind: String = it[0]
		btn.pressed.connect(func(): game.economy.buy(kind))
		h.add_child(btn)
		shop_rows[kind] = {"button": btn, "reason": reason}
	var close := Button.new()
	close.text = "닫기"
	close.custom_minimum_size = Vector2(0, 42)
	close.pressed.connect(close_lodge_panel)
	v.add_child(close)


func _build_pause() -> void:
	pause_panel = _modal(340, 260)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	pause_panel.add_child(v)
	var t := _label("일시 정지", 26, C_AMBER)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(t)
	for pair in [["계속하기", _toggle_pause], ["새 게임", _restart], ["종료", func(): get_tree().quit()]]:
		var b := Button.new()
		b.text = pair[0]
		b.custom_minimum_size = Vector2(0, 44)
		b.pressed.connect(pair[1])
		v.add_child(b)


func _build_end() -> void:
	end_panel = _modal(460, 300)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 14)
	end_panel.add_child(v)
	end_title = _label("", 30, C_AMBER)
	end_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(end_title)
	end_body = _label("", 16, C_TEXT)
	end_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	end_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(end_body)
	var b := Button.new()
	b.text = "새 게임"
	b.custom_minimum_size = Vector2(0, 48)
	b.pressed.connect(_restart)
	v.add_child(b)


func _build_debug() -> void:
	debug_panel = PanelContainer.new()
	_place(debug_panel, 1, 0, 1, 0, -230, 16, -16, 400)
	debug_panel.visible = false
	root.add_child(debug_panel)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 5)
	debug_panel.add_child(v)
	v.add_child(_label("디버그 (F1)", 16, Color(0.6, 1.0, 0.7)))
	var entries := [
		["골드 +100", game.debug_gold],
		["웨이브 즉시 시작", game.debug_start_wave],
		["용 강제 소환", game.debug_force_dragon],
		["산장 피해 50", game.debug_damage_lodge],
		["마녀 피해 25", game.debug_damage_player],
		["적 전체 처치", game.debug_kill_all],
		["적 경로·공격 지점 표시", game.debug_toggle_draw],
	]
	for e in entries:
		var b := Button.new()
		b.text = e[0]
		b.add_theme_font_size_override("font_size", 14)
		b.pressed.connect(e[1])
		v.add_child(b)


# ───────────────────────── 동작 ─────────────────────────

func open_lodge_panel() -> void:
	if game.session.state != SessionScript.State.PREP or pause_panel.visible or end_panel.visible:
		return
	lodge_panel.visible = true
	get_tree().paused = true


func close_lodge_panel() -> void:
	if not lodge_panel.visible:
		return
	lodge_panel.visible = false
	if not pause_panel.visible and not game.session.is_over():
		get_tree().paused = false


func _toggle_pause() -> void:
	if end_panel.visible:
		return
	pause_panel.visible = not pause_panel.visible
	if pause_panel.visible:
		get_tree().paused = true
	elif not lodge_panel.visible:
		get_tree().paused = false


func _restart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func toast(text: String, color := Color.WHITE) -> void:
	var p := PanelContainer.new()
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_theme_stylebox_override("panel", _sb(Color(0.1, 0.08, 0.2, 0.72), Color(0, 0, 0, 0), 8, 7))
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
				else:
					_toggle_pause()
				get_viewport().set_input_as_handled()
			KEY_F1:
				debug_panel.visible = not debug_panel.visible
				get_viewport().set_input_as_handled()


func _on_state_changed(state: int) -> void:
	if state == SessionScript.State.VICTORY or state == SessionScript.State.DEFEAT:
		lodge_panel.visible = false
		pause_panel.visible = false
		end_panel.visible = true
		var s = game.session
		var stats := "플레이 시간 %d:%02d  ·  번 골드 %dG  ·  잃은 양 %d마리" % [int(s.play_time) / 60, int(s.play_time) % 60, game.economy.total_earned, game.sheep_lost]
		if state == SessionScript.State.VICTORY:
			end_title.text = "시연 완료!"
			end_body.text = "3웨이브를 모두 막아 냈습니다. 산장의 창문은 오늘 밤도 따뜻합니다.\n\n" + stats
		else:
			end_title.text = "게임 오버"
			end_body.text = "%s.\n(웨이브 %d)\n\n%s" % [s.defeat_reason, s.wave_index, stats]
	if state != SessionScript.State.PREP:
		lodge_panel.visible = false


func _process(_delta: float) -> void:
	var s = game.session
	var eco = game.economy
	gold_label.text = "◆ %d G" % eco.gold
	var pl = game.player
	var lo = game.world.lodge
	player_bar.max_value = pl.max_hp
	player_bar.value = pl.hp
	player_val.text = "%d/%d" % [int(ceil(pl.hp)), int(pl.max_hp)]
	lodge_bar.max_value = lo.max_hp
	lodge_bar.value = lo.hp
	lodge_val.text = "%d/%d" % [int(ceil(lo.hp)), int(lo.max_hp)]
	var alive: int = game.world.pasture.alive_count()
	sheep_label.text = "양  " + "●".repeat(alive) + "○".repeat(Cfg.SHEEP_MAX - alive) + "   (%d/%d)" % [alive, Cfg.SHEEP_MAX]

	match s.state:
		SessionScript.State.PREP:
			var rem: float = s.prep_remaining()
			phase_label.text = "준비 시간  %d:%02d" % [int(rem) / 60, int(rem) % 60]
			var parts: Array = []
			parts.append("숙박 %d명 / 정원 %d" % [eco.guests_inside(), eco.capacity])
			var na: float = eco.next_arrival_in(s.prep_elapsed)
			if na >= 0.0:
				parts.append("다음 손님 %d초" % int(ceil(na)))
			var np: float = eco.next_payment_in(s.prep_elapsed)
			if np >= 0.0:
				parts.append("숙박비 %d초 후" % int(ceil(np)))
			parts.append("다음 웨이브 %d/%d" % [s.wave_index + 1, Cfg.WAVES.size()])
			sub_label.text = "  ·  ".join(parts)
		SessionScript.State.COMBAT:
			phase_label.text = "웨이브 %d / %d" % [s.wave_index, Cfg.WAVES.size()]
			sub_label.text = "남은 적 %d  ·  출현 대기 %d" % [game.waves.alive(), game.waves.pending()]
		SessionScript.State.CLEARING:
			phase_label.text = "웨이브 %d 정리" % s.wave_index
			sub_label.text = "용이 떠나는 중…" if game.dragon.is_present() else "숨을 고르는 중…"
		SessionScript.State.VICTORY:
			phase_label.text = "시연 완료"
			sub_label.text = ""
		SessionScript.State.DEFEAT:
			phase_label.text = "게임 오버"
			sub_label.text = s.defeat_reason

	lodge_btn.disabled = s.state != SessionScript.State.PREP
	lodge_btn.text = "산장 관리" if s.state == SessionScript.State.PREP else "산장 관리 (준비 시간에만)"
	var dr: String = eco.block_reason("dragon")
	dragon_btn.disabled = dr != ""
	dragon_reason.text = dr if dr != "" else "지붕 위에 용이 내려와 불덩이를 쏩니다"
	for kind in shop_rows:
		var row: Dictionary = shop_rows[kind]
		var r: String = eco.block_reason(kind)
		row["button"].disabled = r != ""
		row["reason"].text = r


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
			var r := Rect2(sp - Vector2(w * 0.5, 0), Vector2(w, h))
			draw_rect(r.grow(1.5), Color(0.05, 0.03, 0.1, 0.8))
			draw_rect(Rect2(r.position, Vector2(w * frac, h)), col)
		if game.world.debug_draw:
			_draw_debug(cam)

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
