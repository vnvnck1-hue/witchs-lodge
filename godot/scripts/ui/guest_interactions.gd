extends CanvasLayer
## 좌상단 말 걸기, 중앙 선택형 대화, 산장 손님·기록 탭. 도착 알림과 분리된 자발적 대화 UI.
const SkinUI := preload("res://scripts/ui/moon/moon_skin.gd")
const Layout := preload("res://scripts/ui/moon/moon_layout.gd")
const Presenter := preload("res://scripts/ui/guest_arrival.gd")
const Cfg := preload("res://scripts/config.gd")
const Extension := preload("res://scripts/ui/moon/moon_extension.gd")
const OutsideClick := preload("res://scripts/ui/outside_click.gd")
const WaitGauge := preload("res://scripts/ui/wait_gauge.gd")
## 대화 조작부 배치(대화 패널 stage 좌표, 패널은 x 70~1200 · y 78~578)
const CONTROLS_SIZE := Vector2(1200, 760)
const REPLY_TOP := 596.0          # 패널 아래 '마녀의 대답' 머리글 줄
const CHOICE_X := 518.0           # 번호 칩이 대사 글 열(x 524)과 맞물리는 위치
const CHOICE_HEIGHT := 56.0
const CHOICE_GAP := 10.0
const CLOSE_AT := Vector2(1052, 104)  # 패널 안 오른쪽 위 구석
## 'side' 배치: 대화 패널을 오른쪽으로 SIDE_EXTEND 만큼 넓히고, 대사 글 열(x 524~1104) 오른쪽에 세로 대답 카드 두 장을 둔다.
const SIDE_EXTEND := 420.0        # 패널 x 70~1620
const SIDE_X := 1150.0
const SIDE_W := 430.0
const SIDE_TOP := 194.0           # 첫 카드 위쪽(머리글은 그 40 위). 카드 묶음이 패널 세로 가운데에 온다
const SIDE_CARD_H := 150.0
const SIDE_GAP := 18.0
## 선택지 배치: "side"(패널 오른쪽 열, 기본) · "below"(패널 아래 목록). 비교용으로 -- --choice-layout=below
var choice_layout := "side"
var game
var dialogue_active := false
var dialogue_phase := ""
var active_uid := -1
var selected_choice := ""
var transcript: Array = []
var return_to_lodge := false
var notification_uid := -1
var root: Control
var notification: Button
var notify_portrait: TextureRect
var _notify_portrait_path := ""  # 알림 초상에 지금 걸린 그림 경로(바뀔 때만 다시 불러온다)
var notify_text: Label
var notify_name: Label
var notify_gauge: Control
var _talk_total: Dictionary = {}  # visit_uid → 알림이 처음 보였을 때 남아 있던 시간(게이지 100%)
var notify_bubble: PanelContainer
var badge: PanelContainer
var badge_text: Label
var presenter
var shade_layer: CanvasLayer
var shade: ColorRect
var controls_layer: CanvasLayer
var controls: Control
var buttons: Control
var next_button: ReplyRow
var choices: Control
var choice_buttons: Array[ReplyRow] = []
var close_button: Button
var guest_list: VBoxContainer
var guest_summary: Label
var history_list: VBoxContainer
var guest_buttons: Dictionary = {}
var pulse_age := 10.0
var pulse: Control
var _clock := 0.0

func _ready() -> void:
	name = "GuestInteractions"
	layer = 16
	process_mode = Node.PROCESS_MODE_ALWAYS
	root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.theme = SkinUI.make_theme()
	add_child(root)
	_build_notification()
	_build_dialogue()
	_build_hub()
	game.guest_events.changed.connect(_on_changed)
	game.guest_events.admitted.connect(func(_profile): pulse_age = 0.0)
	game.economy.gold_changed.connect(func(_gold): _sync_hub())
	game.economy.offers_changed.connect(_sync_hub)
	game.session.state_changed.connect(func(state: int):
		if state != 0 and dialogue_active:
			return_to_lodge = false
			close_conversation(false))
	_on_changed()

func label_at(parent: Node, text: String, at: Rect2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.position = at.position
	label.size = at.size
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label

func _build_notification() -> void:
	notification = Button.new()
	notification.name = "GuestSpeechNotification"
	notification.size = Vector2(400, 218)
	notification.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	for state in ["normal", "hover", "pressed", "disabled"]:
		notification.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	notification.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	root.add_child(notification)
	notify_portrait = TextureRect.new()
	notify_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	notify_portrait.size = Vector2(144, 180)
	notify_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	notify_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	notification.add_child(notify_portrait)
	# 말풍선은 글 길이에 맞춰 스스로 커진다(고정 크기로 글을 구겨 넣지 않는다). 꼬리는 초상 머리 쪽(왼쪽 아래)을 가리킨다.
	notify_bubble = SpeechBubble.new()
	notify_bubble.position = Vector2(150, 12)
	notify_bubble.mouse_filter = Control.MOUSE_FILTER_IGNORE
	notify_bubble.add_theme_stylebox_override("panel", Extension.speech())
	notification.add_child(notify_bubble)
	notify_text = Label.new()
	notify_text.add_theme_font_override("font", SkinUI.font(true))
	notify_text.add_theme_font_size_override("font_size", 17)
	notify_text.add_theme_color_override("font_color", SkinUI.PAPER_INK)
	notify_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	notify_text.custom_minimum_size.x = 186
	notify_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	notify_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	notify_bubble.add_child(notify_text)
	notify_name = label_at(notification, "", Rect2(0, 182, 400, 24), 15, SkinUI.CREAM)
	# 이야기 손님이 떠나기까지 남은 시간: 이름 줄 아래 작은 게이지
	notify_gauge = WaitGauge.new()
	notify_gauge.name = "TalkWaitGauge"
	notify_gauge.position = Vector2(4, 208)
	notify_gauge.size = Vector2(236, 6)
	notification.add_child(notify_gauge)
	notification.pressed.connect(func(): open_conversation(notification_uid))
	badge = PanelContainer.new()
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge.add_theme_stylebox_override("panel", Extension.box("badge", 40, Vector4(12, 12, 12, 12), Vector4(6, 4, 6, 4)))
	root.add_child(badge)
	badge_text = Label.new()
	badge_text.add_theme_font_override("font", SkinUI.font(true))
	badge_text.add_theme_font_size_override("font_size", 17)
	badge_text.add_theme_color_override("font_color", SkinUI.CREAM)
	badge_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.add_child(badge_text)
	pulse = ArrivalPulse.new()
	pulse.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(pulse)

func _build_dialogue() -> void:
	shade_layer = CanvasLayer.new()
	shade_layer.layer = 19
	add_child(shade_layer)
	shade = ColorRect.new()
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.025, 0.015, 0.055, 0.32)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	shade.visible = false
	shade.gui_input.connect(_on_shade_input)
	shade_layer.add_child(shade)
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--choice-layout="): choice_layout = arg.trim_prefix("--choice-layout=")
	var side := choice_layout == "side"
	presenter = Presenter.new()
	presenter.presentation_only = true
	if side: presenter.panel_extend = SIDE_EXTEND
	presenter.game = game
	add_child(presenter)
	presenter.progress.visible = false
	controls_layer = CanvasLayer.new()
	controls_layer.layer = 21
	add_child(controls_layer)
	controls = Control.new()
	controls.set_anchors_preset(Control.PRESET_FULL_RECT)
	controls.theme = SkinUI.make_theme()
	controls.mouse_filter = Control.MOUSE_FILTER_IGNORE
	controls.visible = false
	controls_layer.add_child(controls)
	# 대화 조작부는 대화 패널(stage) 좌표계로 짜고 _layout_dialogue 에서 stage 와 같은 배율로 옮긴다.
	# below: 손님 패널 아래 '마녀의 대답' 목록. side: 패널 오른쪽 끝에 걸친 세로 대답 카드 두 장.
	buttons = Control.new()
	buttons.size = CONTROLS_SIZE
	buttons.mouse_filter = Control.MOUSE_FILTER_IGNORE
	controls.add_child(buttons)
	next_button = ReplyRow.new()
	next_button.compact = true
	next_button.size = Vector2(SIDE_W, 64) if side else Vector2(330, 58)
	next_button.home = Vector2(SIDE_X, SIDE_TOP + SIDE_CARD_H * 2 + SIDE_GAP - 64) if side else Vector2(CONTROLS_SIZE.x - 330, REPLY_TOP + 8)
	next_button.position = next_button.home
	next_button.pressed.connect(advance_dialogue)
	buttons.add_child(next_button)
	# 줄 사이 틈을 누르면 어두운 막(밖 클릭 = 닫기)으로 새지 않게 목록 전체가 입력을 받는다.
	choices = Control.new()
	choices.name = "WitchReplies"
	choices.position = Vector2(SIDE_X, SIDE_TOP - 40) if side else Vector2(CHOICE_X, REPLY_TOP)
	choices.size = Vector2(SIDE_W, 40 + SIDE_CARD_H * 2 + SIDE_GAP) if side else Vector2(CONTROLS_SIZE.x - CHOICE_X, CONTROLS_SIZE.y - REPLY_TOP)
	choices.mouse_filter = Control.MOUSE_FILTER_STOP
	buttons.add_child(choices)
	var heading := HBoxContainer.new()
	heading.position = Vector2(2, 0)
	heading.add_theme_constant_override("separation", 8)
	heading.mouse_filter = Control.MOUSE_FILTER_IGNORE
	choices.add_child(heading)
	var quill := Extension.icon("quill", 24)
	quill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	heading.add_child(quill)
	var heading_text := Label.new()
	heading_text.text = "마녀의 대답"
	heading_text.add_theme_font_override("font", SkinUI.font(true))
	heading_text.add_theme_font_size_override("font_size", 19)
	heading_text.add_theme_color_override("font_color", SkinUI.CREAM)
	heading_text.add_theme_color_override("font_outline_color", Color(SkinUI.INK, 0.9))
	heading_text.add_theme_constant_override("outline_size", 7)
	heading.add_child(heading_text)
	var keys_hint := Label.new()
	keys_hint.text = "숫자 키 · ↑↓"
	keys_hint.size = Vector2(240, 28)
	keys_hint.position = Vector2(choices.size.x - 244, 2)
	keys_hint.visible = not side  # side 에선 그 자리에 닫기 버튼이 온다
	keys_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	keys_hint.add_theme_font_size_override("font_size", 15)
	keys_hint.add_theme_color_override("font_color", SkinUI.CREAM_DIM)
	keys_hint.add_theme_color_override("font_outline_color", Color(SkinUI.INK, 0.85))
	keys_hint.add_theme_constant_override("outline_size", 6)
	keys_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	choices.add_child(keys_hint)
	for index in 2:
		var button := ReplyRow.new()
		button.key = str(index + 1)
		button.tall = side
		button.size = Vector2(SIDE_W, SIDE_CARD_H) if side else Vector2(choices.size.x, CHOICE_HEIGHT)
		button.home = Vector2(0, 40 + index * (SIDE_CARD_H + SIDE_GAP)) if side else Vector2(0, 36 + index * (CHOICE_HEIGHT + CHOICE_GAP))
		button.position = button.home
		var selected: int = index
		button.pressed.connect(func(): choose(selected))
		choices.add_child(button)
		choice_buttons.append(button)
	close_button = Button.new()
	close_button.text = "✕  Esc"
	close_button.tooltip_text = "대화를 접고 돌아가기"
	close_button.size = Vector2(118, 44)
	close_button.add_theme_font_size_override("font_size", 20)
	close_button.add_theme_color_override("font_color", SkinUI.CREAM_DIM)
	close_button.add_theme_color_override("font_hover_color", SkinUI.CREAM)
	for state in ["normal", "pressed", "disabled", "focus"]:
		close_button.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	close_button.add_theme_stylebox_override("hover", SkinUI.flat(Color(SkinUI.INK_SOFT, 0.85), Color(SkinUI.CREAM, 0.25), 18, 8))
	close_button.focus_mode = Control.FOCUS_NONE
	close_button.position = Vector2(70 + 1130 + SIDE_EXTEND - 148, 104) if side else CLOSE_AT
	if side:
		# 대사와 대답 열을 가르는 옅은 세로 금줄
		var divider := ColorRect.new()
		divider.color = Color8(197, 165, 116, 70)
		divider.position = Vector2(SIDE_X - 24, SIDE_TOP - 30)
		divider.size = Vector2(1, SIDE_CARD_H * 2 + SIDE_GAP + 30)
		divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
		buttons.add_child(divider)
		buttons.move_child(divider, 0)
	close_button.pressed.connect(func(): close_conversation(false))
	buttons.add_child(close_button)

func _build_hub() -> void:
	var target: VBoxContainer = game.hud.lodge_guests
	guest_summary = game.hud._label("", 17, SkinUI.CREAM)
	guest_summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	target.add_child(guest_summary)
	guest_list = _scroll_list(target)
	history_list = _scroll_list(game.hud.lodge_history)

func _scroll_list(parent: Control) -> VBoxContainer:
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	parent.add_child(scroll)
	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 9)
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)
	return list

func _clear(container: Node) -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()

func _sync_hub() -> void:
	if guest_list == null: return
	_clear(guest_list)
	_clear(history_list)
	guest_buttons.clear()
	var guests: Array = game.guest_events.current_guests()
	guest_summary.text = "숙박 %d / 정원 %d명    ·    기다리는 대화 %d건" % [game.economy.guests_inside(), game.economy.capacity, game.guest_events.pending_events().size()]
	if guests.is_empty():
		var empty: Label = game.hud._label("아직 손님이 없습니다. 숲길을 따라 찾아올 손님을 기다려 보세요.", 16, SkinUI.LAVENDER)
		empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		guest_list.add_child(empty)
	for entry in guests:
		var row := PanelContainer.new()
		row.add_theme_stylebox_override("panel", SkinUI.row_box())
		guest_list.add_child(row)
		var h := HBoxContainer.new()
		h.add_theme_constant_override("separation", 13)
		row.add_child(h)
		var portrait := TextureRect.new()
		portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		portrait.texture = load(entry.profile.portrait)
		portrait.custom_minimum_size = Vector2(72, 94)
		portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		h.add_child(portrait)
		var info := VBoxContainer.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		h.add_child(info)
		var race_name: String = str(entry.profile.get("race_name", ""))
		info.add_child(game.hud._label(entry.profile.person + "  ·  " + (race_name + " " if race_name != "" else "") + entry.profile.role, 18, SkinUI.CREAM))
		var detail: Label = game.hud._label(entry.profile.detail, 14, SkinUI.LAVENDER)
		detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		info.add_child(detail)
		info.add_child(game.hud._label(entry.status + (" · 이야기하고 싶어 합니다" if entry.ready and not entry.read else ""), 14, SkinUI.TEAL))
		var actions := VBoxContainer.new()
		h.add_child(actions)
		var talk: Button = game.hud._button("대화 완료" if entry.get("completed_this_visit", false) else ("안부 묻기" if entry.read else "이야기 듣기"), 40)
		talk.custom_minimum_size.x = 126
		var uid: int = entry.uid
		talk.disabled = not game.guest_events.can_talk(uid) or entry.get("completed_this_visit", false)
		talk.pressed.connect(func(): open_conversation(uid, true))
		actions.add_child(talk)
		guest_buttons[uid] = talk
		for offer in game.economy.offers:
			if is_instance_valid(offer.guest) and int(offer.guest.profile.get("visit_uid", -1)) == uid:
				var hire: Button = game.hud._button("고용 · %dG" % game.economy.contract_cost(), 36)
				hire.disabled = game.economy.hire_block_reason(offer) != ""
				hire.tooltip_text = game.economy.hire_block_reason(offer)
				hire.pressed.connect(func(): game.economy.hire(offer))
				actions.add_child(hire)
	if game.guest_events.history.is_empty():
		var empty: Label = game.hud._label("아직 나눈 이야기가 없습니다. 말풍선을 누르거나 손님 탭에서 대화를 시작하세요.", 16, SkinUI.LAVENDER)
		empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		history_list.add_child(empty)
	for record in game.guest_events.history.duplicate():
		var panel := PanelContainer.new()
		panel.add_theme_stylebox_override("panel", Extension.paper(18))
		history_list.add_child(panel)
		var list := VBoxContainer.new()
		panel.add_child(list)
		var heading := HBoxContainer.new()
		heading.add_child(Extension.icon("quill", 26))
		heading.add_child(game.hud._label("%d일차 · %s — %s" % [record.day, record.person, record.title], 18, SkinUI.PAPER_INK))
		list.add_child(heading)
		for line in record.transcript:
			var label: Label = game.hud._label(line, 15, SkinUI.PAPER_INK)
			label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			list.add_child(label)

func _on_changed() -> void:
	if dialogue_active:
		var entry: Dictionary = game.guest_events.visit(active_uid)
		if entry.is_empty() or not entry.present: close_conversation(false)
	_sync_hub()

func _available_for_notification() -> bool:
	var hud = game.hud
	return game.session.state == 0 and not dialogue_active and not (hud.pause_panel.visible or hud.lodge_panel.visible or hud.end_panel.visible or hud.debug_panel.visible or hud.card_hand.sale_panel.visible or hud.card_hand.pocket_panel.visible)

func _process(delta: float) -> void:
	_clock += delta
	var view := get_viewport().get_visible_rect().size
	var s := Layout.ui_scale(view)
	var pending: Array = game.guest_events.pending_events()
	notification.visible = not pending.is_empty() and _available_for_notification()
	if not pending.is_empty():
		var entry: Dictionary = pending[0]
		notification_uid = entry.uid
		if _notify_portrait_path != entry.profile.portrait:
			_notify_portrait_path = entry.profile.portrait
			notify_portrait.texture = load(entry.profile.portrait)
		if notify_text.text != entry.story.prompt:
			notify_text.text = entry.story.prompt
		notify_bubble.reset_size()
		# 풍선 아래(꼬리)가 초상의 얼굴 높이에 오도록 세로 위치를 맞춘다.
		notify_bubble.position = Vector2(150, clampf(118.0 - notify_bubble.size.y, 4.0, 60.0))
		notify_name.text = entry.profile.person + " · " + ("이야기 듣기" if pending.size() == 1 else "대화 %d건" % pending.size())
		notification.tooltip_text = entry.profile.person + "와 대화 · " + entry.story.title
		var left: float = game.economy.guest_time_left(entry.uid)
		notify_gauge.visible = left >= 0.0
		if left >= 0.0:
			var full: float = maxf(float(_talk_total.get(entry.uid, 0.0)), left)
			_talk_total[entry.uid] = full
			notify_gauge.ratio = left / maxf(full, 0.01)
			notification.tooltip_text += "\n%d초 뒤 산장을 떠납니다" % int(ceil(left))
	var factor := 0.8 if not game.economy.offers.is_empty() else 1.0
	notification.scale = Vector2.ONE * s * factor
	notification.position = Vector2(20 * s, Layout.slot_rect("objective", view).end.y + 10 * s + sin(_clock * 1.4) * 1.5)
	var target: Rect2 = game.hud.moon.lodge_btn.get_global_rect()
	var count := 0
	for entry in game.guest_events.current_guests():
		if entry.admitted: count += 1
	badge.visible = count > 0
	badge_text.text = str(count) + (" !" if not pending.is_empty() else "")
	badge.position = target.position + Vector2(target.size.x * 0.74, target.size.y * 0.10)
	badge.scale = Vector2.ONE * s
	badge.size = Vector2(29, 29)
	var was_pulsing := pulse_age < 0.7
	pulse_age += delta
	pulse.position = target.get_center()
	pulse.set("age", pulse_age)
	# 고리는 0.7초 동안만 그린다. 그 뒤 한 번 더 그려 지우고는 다시 그리지 않는다.
	if was_pulsing:
		pulse.queue_redraw()
	if dialogue_active: _layout_dialogue()

func open_conversation(uid: int, from_hub := false) -> void:
	if dialogue_active or not game.guest_events.can_talk(uid) or game.session.is_over(): return
	var entry: Dictionary = game.guest_events.visit(uid)
	if entry.get("completed_this_visit", false):
		game.sounds.play("talk_open")
		return
	# 대화가 열리면 알림음 대신 그 인물의 목소리
	game.sounds.voice(entry.profile, "talk_open")
	active_uid = uid
	return_to_lodge = from_hub or game.hud.lodge_panel.visible
	dialogue_active = true
	dialogue_phase = "opening"
	selected_choice = ""
	transcript = [entry.profile.person + ": " + entry.story.opening.replace("\n", " ")]
	game.hud.card_hand.close_all()
	game.hud.close_lodge_panel()
	game.hud.pause_panel.visible = false
	game.guest_arrival.root.visible = false
	notification.visible = false
	shade.visible = true
	controls.visible = true
	game.hud.refresh_pause()
	_show_dialogue(entry.story.opening, true)

func _show_dialogue(text: String, initial := false) -> void:
	if initial:
		var entry: Dictionary = game.guest_events.visit(active_uid)
		presenter.show_profile(entry.profile, text, entry.story.title)
	else:
		presenter.update_dialogue(text)
	next_button.visible = dialogue_phase != "choices"
	choices.visible = dialogue_phase == "choices"
	next_button.text = {"opening": "대답하기", "reply": "이야기 이어 듣기", "closing": "대화 마치기"}.get(dialogue_phase, "다음")
	if dialogue_phase != "choices":
		next_button.play_enter(0.35)
		next_button.grab_focus()
	_layout_dialogue()

func advance_dialogue() -> void:
	if not dialogue_active: return
	game.sounds.play("talk_next")
	var entry: Dictionary = game.guest_events.visit(active_uid)
	match dialogue_phase:
		"opening":
			dialogue_phase = "choices"
			next_button.visible = false
			choices.visible = true
			# 대답 줄이 위에서부터 차례로 스며 나온다. 첫 줄에 포커스를 두되 아직 고르지는 않는다.
			for i in choice_buttons.size():
				choice_buttons[i].set_line(entry.story.choices[i].text)
				choice_buttons[i].play_enter(0.06 + i * 0.09)
			choice_buttons[0].grab_focus()
		"reply":
			dialogue_phase = "closing"
			transcript.append(entry.profile.person + ": " + entry.story.closing.replace("\n", " "))
			game.sounds.voice(entry.profile)
			_show_dialogue(entry.story.closing)
		"closing":
			close_conversation(true)

func choose(index: int) -> void:
	if not dialogue_active or dialogue_phase != "choices" or index < 0 or index > 1: return
	game.sounds.play("talk_next")
	var entry: Dictionary = game.guest_events.visit(active_uid)
	var branch: Dictionary = entry.story.choices[index]
	selected_choice = branch.text
	transcript.append("마녀: " + branch.text)
	# 효과가 있는 선택지(늑대의 피): 검은 양을 내주고 카드를 받는다. 그사이 양이 없어졌으면 실패 대사
	var reply: String = branch.reply
	if branch.has("effect") and not game.guest_events.apply_effect(active_uid, branch.effect):
		reply = branch.get("fail_reply", branch.reply)
	transcript.append(entry.profile.person + ": " + reply.replace("\n", " "))
	dialogue_phase = "reply"
	game.sounds.voice(entry.profile)
	_show_dialogue(reply)

func _layout_dialogue() -> void:
	var stage: Control = presenter.stage
	var s: float = stage.scale.x
	buttons.position = stage.position
	buttons.scale = Vector2.ONE * s

func close_conversation(completed: bool) -> void:
	if not dialogue_active: return
	game.sounds.play("talk_open")
	var reopen: bool = return_to_lodge and game.session.state == 0 and not game.session.is_over()
	dialogue_active = false
	shade.visible = false
	controls.visible = false
	presenter.finish()
	game.guest_arrival.root.visible = game.guest_arrival.active
	if completed: game.guest_events.complete(active_uid, selected_choice, transcript)
	active_uid = -1
	dialogue_phase = ""
	if reopen: game.hud.open_lodge_panel(1)
	else: game.hud.refresh_pause()
	_sync_hub()

## 대화창(초상·글 패널)·버튼 밖의 어두운 막을 클릭하면 '돌아가기'처럼 닫는다.
func _on_shade_input(event: InputEvent) -> void:
	if dialogue_active and OutsideClick.is_press(event) and not presenter._panel_hit(event.position):
		shade.accept_event()
		close_conversation(false)

func _input(event: InputEvent) -> void:
	if not dialogue_active or not event is InputEventKey: return
	if event.keycode == KEY_F11: return
	if event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE: close_conversation(false)
		elif dialogue_phase == "choices" and event.keycode in [KEY_1, KEY_2, KEY_KP_1, KEY_KP_2]:
			choose(1 if event.keycode in [KEY_2, KEY_KP_2] else 0)
		elif dialogue_phase == "choices":
			var selected := choice_buttons.find(get_viewport().gui_get_focus_owner())
			if event.keycode in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE]:
				choose(maxi(selected, 0))
			elif event.keycode in [KEY_TAB, KEY_DOWN, KEY_RIGHT, KEY_UP, KEY_LEFT]:
				var direction := -1 if event.keycode in [KEY_UP, KEY_LEFT] or (event.keycode == KEY_TAB and event.shift_pressed) else 1
				choice_buttons[posmod(selected + direction, choice_buttons.size())].grab_focus()
		elif event.keycode in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE]:
			advance_dialogue()
	get_viewport().set_input_as_handled()

## '마녀의 대답' 한 줄: 왼쪽 번호 칩 + 왼쪽 정렬 대사. 포커스(마우스를 올려도 포커스가 따라온다)된 줄만
## 금빛 테두리·밝은 바탕·▸ 표시로 떠오르고 나머지는 가라앉아, 지금 고를 줄이 한눈에 보인다.
## compact 는 번호 없이 오른쪽에 놓이는 '다음' 줄이다.
class ReplyRow extends Button:
	const INK := Color8(22, 12, 40)
	const INK_LIT := Color8(52, 32, 84)
	const CREAM := Color8(252, 231, 176)
	const GOLD := Color8(226, 186, 112)
	const LAVENDER := Color8(167, 150, 205)
	const STATES := ["normal", "hover", "pressed", "disabled", "focus", "hover_pressed"]
	var key := ""
	var compact := false
	var tall := false    # side 배치의 세로 카드: 글이 여러 줄로 감기고 바탕이 패널보다 한 톤 밝다
	var line := ""       # 원문 대답(줄바꿈 전)
	var lit := 0.0       # 0 평소 → 1 포커스
	var enter := 1.0     # 등장 0 → 1
	var _delay := 0.0
	var _clock := 0.0
	var home := Vector2.ZERO  # 배치된 자리. 등장·포커스 때 이 자리에서 가로로만 밀린다.
	var _back := StyleBoxFlat.new()
	var _edge := StyleBoxFlat.new()
	var _art: Control  # 바탕·칩은 글자 뒤(show_behind_parent)에서 그린다. Button 의 _draw 는 글 위에 덮인다.

	func _init() -> void:
		focus_mode = Control.FOCUS_ALL
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		clip_text = true
		add_theme_font_override("font", preload("res://scripts/ui/moon/moon_skin.gd").font(true))
		mouse_entered.connect(func(): if not disabled: grab_focus())
		_back.set_corner_radius_all(12)
		_edge.set_corner_radius_all(12)
		_edge.draw_center = false
		_art = Control.new()
		_art.show_behind_parent = true
		_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_art.set_anchors_preset(Control.PRESET_FULL_RECT)
		_art.draw.connect(_paint)
		add_child(_art)

	func _ready() -> void:
		alignment = HORIZONTAL_ALIGNMENT_CENTER if compact else HORIZONTAL_ALIGNMENT_LEFT
		for state in STATES:
			var box := StyleBoxEmpty.new()
			box.content_margin_left = 22.0 if compact else 66.0
			box.content_margin_right = 44.0
			add_theme_stylebox_override(state, box)
		add_theme_font_size_override("font_size", 22 if compact else (24 if tall else 23))
		if tall: clip_text = false
		_apply_colors()

	## 대답 문구를 건다. 세로 카드는 띄어쓰기에서만 줄을 바꾼다(한글 단어 중간이 잘리지 않게).
	func set_line(value: String) -> void:
		line = value
		if not tall:
			text = value
			return
		var font: Font = get_theme_font("font")
		var font_size := get_theme_font_size("font_size")
		var box := get_theme_stylebox("normal")
		var room := size.x - box.content_margin_left - box.content_margin_right - 4.0
		var lines: Array[String] = []
		var current := ""
		for word in value.split(" ", false):
			var candidate: String = word if current.is_empty() else current + " " + word
			if not current.is_empty() and font.get_string_size(candidate, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > room:
				lines.append(current)
				candidate = word
			current = candidate
		if not current.is_empty(): lines.append(current)
		text = "\n".join(lines)

	func play_enter(delay: float) -> void:
		enter = 0.0
		_delay = delay
		_clock = 0.0
		lit = 0.0
		modulate.a = 0.0
		_apply_colors()
		_art.queue_redraw()

	func _process(delta: float) -> void:
		if not is_visible_in_tree(): return
		var changed := false
		if enter < 1.0:
			_clock += delta
			enter = clampf((_clock - _delay) / 0.28, 0.0, 1.0)
			modulate.a = enter
			changed = true
		var goal := 1.0 if has_focus() else 0.0
		if not is_equal_approx(lit, goal):
			lit = move_toward(lit, goal, delta * 7.0)
			changed = true
		if changed:
			_apply_colors()
			# 등장할 때 왼쪽에서 살짝 밀려 들어오고, 포커스되면 6px 앞으로 나온다(글과 칩이 함께 움직인다).
			position = home + Vector2((1.0 - (1.0 - pow(1.0 - enter, 3.0))) * -18.0 + lit * 6.0, 0)
			_art.queue_redraw()

	func _apply_colors() -> void:
		var text_color := LAVENDER.lerp(CREAM, 0.4 + 0.6 * lit)
		for color_name in ["font_color", "font_hover_color", "font_focus_color", "font_pressed_color", "font_hover_pressed_color"]:
			add_theme_color_override(color_name, text_color)

	func _paint() -> void:
		var canvas := _art
		var r := Rect2(Vector2.ZERO, size)
		if tall:
			_back.bg_color = Color(0, 0, 0, 0.35)
			canvas.draw_style_box(_back, Rect2(r.position + Vector2(-6, 10), r.size))
		var back := (Color8(36, 22, 62) if tall else INK).lerp(INK_LIT, lit)
		back.a = 0.82 + 0.14 * lit
		_back.bg_color = back
		canvas.draw_style_box(_back, r)
		_edge.border_color = Color(LAVENDER, 0.22).lerp(Color(GOLD, 0.9), lit)
		_edge.set_border_width_all(2 if lit > 0.5 else 1)
		canvas.draw_style_box(_edge, r)
		var font: Font = get_theme_font("font")
		if lit > 0.01:
			canvas.draw_string(font, Vector2(r.end.x - 32, r.size.y * 0.5 + 8), "▸", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color(GOLD, lit))
		if compact: return
		# 번호 칩: 평소엔 금빛 테두리만, 포커스되면 금빛으로 채워지고 숫자가 어두워진다.
		var c := Vector2(r.position.x + 34, r.size.y * 0.5)
		if lit > 0.01: canvas.draw_circle(c, 15.0, Color(GOLD, lit))
		canvas.draw_arc(c, 15.0, 0, TAU, 32, Color(GOLD, 0.55 + 0.45 * lit), 1.6, true)
		var w := font.get_string_size(key, HORIZONTAL_ALIGNMENT_LEFT, -1, 19).x
		canvas.draw_string(font, c + Vector2(-w * 0.5, 7), key, HORIZONTAL_ALIGNMENT_LEFT, -1, 19, GOLD.lerp(INK, lit))

class SpeechBubble extends PanelContainer:
	func _draw() -> void:
		pass # Tail is part of the approved RGBA speech-bubble texture.

class ArrivalPulse extends Control:
	var age := 10.0
	func _draw() -> void:
		if age >= 0.7: return
		var t := age / 0.7
		draw_arc(Vector2.ZERO, 22.0 + t * 52.0, 0, TAU, 48, Color(0.95, 0.8, 0.5, 1.0 - t), 3.0, true)
