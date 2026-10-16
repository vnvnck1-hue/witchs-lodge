extends CanvasLayer
## 좌상단 말 걸기, 중앙 선택형 대화, 산장 손님·기록 탭. 도착 알림과 분리된 자발적 대화 UI.
const SkinUI := preload("res://scripts/ui/moon/moon_skin.gd")
const Layout := preload("res://scripts/ui/moon/moon_layout.gd")
const Presenter := preload("res://scripts/ui/guest_arrival.gd")
const Cfg := preload("res://scripts/config.gd")
const Extension := preload("res://scripts/ui/moon/moon_extension.gd")
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
var notify_text: Label
var notify_name: Label
var notify_bubble: PanelContainer
var badge: PanelContainer
var badge_text: Label
var presenter
var shade_layer: CanvasLayer
var shade: ColorRect
var controls_layer: CanvasLayer
var controls: Control
var buttons: VBoxContainer
var next_button: Button
var choices: VBoxContainer
var choice_buttons: Array[Button] = []
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
	notification.size = Vector2(400, 206)
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
	shade_layer.add_child(shade)
	presenter = Presenter.new()
	presenter.presentation_only = true
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
	buttons = VBoxContainer.new()
	buttons.size = Vector2(580, 144)
	buttons.add_theme_constant_override("separation", 8)
	controls.add_child(buttons)
	next_button = Button.new()
	next_button.custom_minimum_size = Vector2(580, 52)
	next_button.add_theme_font_size_override("font_size", 23)
	next_button.pressed.connect(advance_dialogue)
	buttons.add_child(next_button)
	choices = VBoxContainer.new()
	choices.add_theme_constant_override("separation", 8)
	buttons.add_child(choices)
	for index in 2:
		var button := Button.new()
		button.custom_minimum_size = Vector2(580, 52)
		button.add_theme_font_size_override("font_size", 21)
		var selected: int = index
		button.pressed.connect(func(): choose(selected))
		choices.add_child(button)
		choice_buttons.append(button)
	close_button = Button.new()
	close_button.text = "돌아가기 · Esc"
	close_button.size = Vector2(210, 44)
	close_button.add_theme_font_size_override("font_size", 18)
	close_button.pressed.connect(func(): close_conversation(false))
	controls.add_child(close_button)

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
		info.add_child(game.hud._label(entry.profile.person + "  ·  " + entry.profile.role, 18, SkinUI.CREAM))
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
				var hire: Button = game.hud._button("고용 · %dG" % Cfg.CONTRACT_COST, 36)
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
		notify_portrait.texture = load(entry.profile.portrait)
		if notify_text.text != entry.story.prompt:
			notify_text.text = entry.story.prompt
		notify_bubble.reset_size()
		# 풍선 아래(꼬리)가 초상의 얼굴 높이에 오도록 세로 위치를 맞춘다.
		notify_bubble.position = Vector2(150, clampf(118.0 - notify_bubble.size.y, 4.0, 60.0))
		notify_name.text = entry.profile.person + " · " + ("이야기 듣기" if pending.size() == 1 else "대화 %d건" % pending.size())
		notification.tooltip_text = entry.profile.person + "와 대화 · " + entry.story.title
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
	pulse_age += delta
	pulse.position = target.get_center()
	pulse.set("age", pulse_age)
	pulse.queue_redraw()
	if dialogue_active: _layout_dialogue()

func open_conversation(uid: int, from_hub := false) -> void:
	if dialogue_active or not game.guest_events.can_talk(uid) or game.session.is_over(): return
	game.sounds.play("talk_open")
	var entry: Dictionary = game.guest_events.visit(uid)
	if entry.get("completed_this_visit", false): return
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
	next_button.text = {"opening": "대답하기  →", "reply": "이야기 이어 듣기  →", "closing": "대화 마치기"}.get(dialogue_phase, "다음")
	if dialogue_phase != "choices": next_button.grab_focus()
	_layout_dialogue()

func advance_dialogue() -> void:
	if not dialogue_active: return
	game.sounds.play("talk_next")
	var entry: Dictionary = game.guest_events.visit(active_uid)
	match dialogue_phase:
		"opening":
			dialogue_phase = "choices"
			for i in choice_buttons.size(): choice_buttons[i].text = entry.story.choices[i].text
			next_button.visible = false
			choices.visible = true
			choice_buttons[0].grab_focus()
		"reply":
			dialogue_phase = "closing"
			transcript.append(entry.profile.person + ": " + entry.story.closing.replace("\n", " "))
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
	transcript.append(entry.profile.person + ": " + branch.reply.replace("\n", " "))
	dialogue_phase = "reply"
	_show_dialogue(branch.reply)

func _layout_dialogue() -> void:
	var stage: Control = presenter.stage
	var s: float = stage.scale.x
	buttons.position = stage.position + Vector2(524, 520) * s
	buttons.scale = Vector2.ONE * s
	close_button.position = stage.position + Vector2(75, 608) * s
	close_button.scale = Vector2.ONE * s

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

func _input(event: InputEvent) -> void:
	if not dialogue_active or not event is InputEventKey: return
	if event.keycode == KEY_F11: return
	if event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE: close_conversation(false)
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

class SpeechBubble extends PanelContainer:
	func _draw() -> void:
		pass # Tail is part of the approved RGBA speech-bubble texture.

class ArrivalPulse extends Control:
	var age := 10.0
	func _draw() -> void:
		if age >= 0.7: return
		var t := age / 0.7
		draw_arc(Vector2.ZERO, 22.0 + t * 52.0, 0, TAU, 48, Color(0.95, 0.8, 0.5, 1.0 - t), 3.0, true)
