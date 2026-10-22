extends SceneTree
## Actual arrival/input/dialogue lifecycle, both answer branches, hub actions and viewport regression.
const Profiles := preload("res://scripts/ui/guest_profiles.gd")
const Stories := preload("res://scripts/game/guest_dialogues.gd")
const Layout := preload("res://scripts/ui/moon/moon_layout.gd")
const Cfg := preload("res://scripts/config.gd")
var game
var checks: Array = []
var failures: Array = []
var out := ""

func _initialize() -> void:
	out = ProjectSettings.globalize_path("res://../output/guest-events-v4/")
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): out = arg.trim_prefix("--out=").trim_suffix("/") + "/"
	DirAccess.make_dir_recursive_absolute(out)
	create_timer(100.0, true, false, true).timeout.connect(func(): push_error("Guest events timeout"); quit(2))
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	checks.append({"ok": ok, "check": message})
	print("GUEST_EVENT ", "PASS " if ok else "FAIL ", message)
	if not ok: failures.append(message)

func frames(count := 3) -> void:
	for i in count: await process_frame

func seconds(value: float) -> void:
	await create_timer(value, true, false, true).timeout

func until(condition: Callable, timeout := 12.0) -> void:
	var start := Time.get_ticks_msec()
	while not condition.call():
		await process_frame
		if Time.get_ticks_msec() - start > timeout * 1000:
			check(false, "wait timeout")
			return

func click_at(at: Vector2) -> void:
	var move := InputEventMouseMotion.new()
	move.position = at
	move.global_position = at
	root.push_input(move, true)
	await frames(2)
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.position = at
		event.global_position = at
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		root.push_input(event, true)
		await frames(2)

func click(control: Control) -> void:
	await click_at(control.get_global_rect().get_center())

func key(code: int) -> void:
	for pressed in [true, false]:
		var event := InputEventKey.new()
		event.keycode = code
		event.physical_keycode = code
		event.pressed = pressed
		root.push_input(event, true)
		await frames(2)

## 대사를 펜으로 적는 중이면 Space 로 남은 글을 마저 적는다(실제 조작과 같다, docs/dialogue-handwriting.md).
func written(presenter) -> void:
	if presenter.is_writing(): await key(KEY_SPACE)

func capture(id: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png(out + id + ".png") == OK, "capture " + id)

func check_text(presenter, text: String, name: String) -> void:
	var wrapped: Array = presenter._wrap_dialogue(text)
	var fits := wrapped.size() <= 3
	for line in wrapped:
		fits = fits and presenter.dialogue_lines[0].get_theme_font("font").get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, presenter.dialogue_font_size).x <= presenter.text_width
	check(fits, "full readable text: " + name)

func run() -> void:
	root.size = Vector2i(1600, 872)
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	# 첫 손님이 브람(인간 전투용병)이 되도록 이번 판의 주요 종족을 인간으로 고정한다(판마다 무작위, world_setting.gd).
	game.world_setting.force(["human", "dwarf"])
	await frames(6)
	game.world.day_cycle.set_mode("day")
	game.cards.add("timber", 3)
	var intro = game.guest_arrival
	var ui = game.guest_ui
	var events = game.guest_events
	check(not intro.active and not ui.dialogue_active and not paused, "normal initial gameplay")
	for profile in Profiles.all_profiles():
		for greeting in profile.lines: check_text(intro, greeting, profile.id + " greeting")
		var story := Stories.story(profile.id)
		check(story.choices.size() == 2 and story.prompt != "", "individual event and two choices: " + profile.id)
		check_text(ui.presenter, story.opening, profile.id + " opening")
		for branch in story.choices:
			check_text(ui.presenter, branch.reply, profile.id + " reply")
			check(ui.choice_buttons[0].get_theme_font("font").get_string_size(branch.text, HORIZONTAL_ALIGNMENT_LEFT, -1, 21).x <= 550, "choice label fits: " + profile.id)
		check_text(ui.presenter, story.closing, profile.id + " closing")
	game.session.prep_elapsed = 4.8
	await until(func(): return intro.phase == "guest" and intro.phase_time > 1.1)
	check(intro.profiles.size() == 2 and events.current_guests().size() == 2, "actual two-person arrival registered once")
	check(intro.name_label.text == "브람", "correct first guest")
	var rect: Rect2 = intro.stage.get_global_rect()
	var view := root.get_visible_rect().size
	var hand_top: float = Layout.to_view(Vector2(800, game.hud.card_hand.CARD_BOTTOM), Vector2(0.5, 1), view).y - game.hud.card_hand.CARD_DESIGN.y * Layout.ui_scale(view)
	check(rect.end.y < hand_top and hand_top - rect.end.y < 30, "compact arrival immediately above resting card hand")
	check(rect.size.x / view.x < 0.34, "compact arrival about one-third viewport width")
	check(intro.guest_duration >= 3.4 and intro.guest_duration <= maxf(5.0, intro.write_start + intro.writing.total + 1.7), "short readable introduction duration")
	check(not paused and game.movement_input_allowed() and intro.root.mouse_filter == Control.MOUSE_FILTER_IGNORE, "arrival keeps world and player input live")
	await capture("01-compact-arrival")
	var elapsed: float = game.session.play_time
	# Music uses two crossfading decks; background_players now holds ambience only.
	var deck: Dictionary = game.sounds._decks["bgm_field"]
	var bgm: AudioStreamPlayer = deck[deck.cur]
	var bgm_id: int = bgm.get_instance_id()
	var music_time: float = bgm.get_playback_position()
	# 한 대화창에서 차례로: 첫 손님은 패널 위 작은 초상으로 줄을 서고, 패널은 닫히지 않는다(2026-10-22). 줄 선 초상 위치는 헤드리스로 볼 수 없어 실제 창 캡처 01b(screenshots/guest-intro-single-panel/)로 확인
	await until(func(): return intro.phase == "swap")
	check(intro.stage.modulate.a > 0.99 and intro.lineup.size() == 1 and not intro.portrait.visible, "first guest joins the lineup inside the same panel")
	await until(func(): return intro.phase == "guest" and intro.guest_index == 1 and intro.phase_time > 0.4)
	check(intro.name_label.text != "브람" and intro.panel_time > intro.phase_time + 1.0 and intro.stage.modulate.a > 0.99, "second guest greets in the same panel without reopening it")
	check(not events.current_guests()[0].admitted, "nobody flies to management before every guest has greeted")
	await capture("01b-same-panel-second-guest")
	await until(func(): return intro.phase == "flight" and intro.flight_time > 0.23)
	check(intro.flights.size() == 2 and intro.flyers[0].visible and intro.flyers[1].visible, "all guests fly to management together")
	check(intro.flying_portrait.visible and intro.stage.modulate.a < 0.05, "panel fades while detached portrait stays visible")
	check(intro.flying_portrait.size.x < intro.flight_size.x, "portrait shrinks toward lodge management")
	await capture("02-portrait-flight")
	root.size = Vector2i(1440, 900)
	await until(func(): return events.current_guests()[0].admitted)
	check(intro.last_landing.distance_to(game.hud.moon.lodge_btn.get_global_rect().get_center()) < 1.0, "flight lands at real management button after viewport resize")
	check(game.session.play_time > elapsed + 1.0 and bgm.get_instance_id() == bgm_id and bgm.get_playback_position() > music_time, "world clock and same BGM continue through arrival")
	root.size = Vector2i(1600, 872)
	await until(func(): return not intro.active)
	await until(func(): return ui.notification.visible)
	check(events.current_guests().all(func(entry): return entry.admitted), "both portraits admitted after sequence")
	check(not ui.dialogue_active and not paused, "event only notifies and never opens dialogue automatically")
	check(ui.notification.get_global_rect().position.y > Layout.slot_rect("objective", root.size).end.y, "speech notice below upper-left objective")
	check(ui.notify_text.size.x > 120 and ui.notify_text.get_line_count() <= 2, "speech bubble lays out complete readable horizontal prompt")
	check(ui.badge.visible and ui.badge_text.text.begins_with("2"), "management badge tracks two present guests")
	await capture("03-speech-notification")
	var first_uid: int = ui.notification_uid
	music_time = bgm.get_playback_position()
	await click(ui.notification)
	var prep_before: float = game.session.prep_elapsed
	check(ui.dialogue_active and ui.active_uid == first_uid and paused, "real speech notification click opens matching centered modal")
	check(ui.presenter.presentation_only and ui.presenter.stage.get_global_rect().size.x > rect.size.x * 1.4, "conversation reuses large centered portrait presentation")
	await seconds(1.7)
	check(is_equal_approx(game.session.prep_elapsed, prep_before), "voluntary conversation freezes preparation clock")
	check(bgm.playing and bgm.get_instance_id() == bgm_id and bgm.get_playback_position() > music_time + 0.7, "same BGM continues during paused dialogue")
	check(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Background")) < -8.5, "dialogue lowers BGM volume instead of stopping it")
	await capture("04-centered-conversation")
	var was_writing: bool = ui.presenter.is_writing()
	await click(ui.next_button)
	check(was_writing and ui.dialogue_phase == "opening" and not ui.presenter.is_writing(), "next while writing finishes the handwritten line first")
	await click(ui.next_button)
	check(ui.dialogue_phase == "choices" and ui.choices.visible, "continue opens both player responses")
	await capture("05-dialogue-choices")
	var presentation_time: float = ui.presenter.phase_time
	var portrait_id: int = ui.presenter.portrait.texture.get_instance_id()
	await click(ui.choice_buttons[0])
	check(ui.dialogue_phase == "reply" and ui.selected_choice == events.visit(first_uid).story.choices[0].text, "real first choice selects authored response")
	check(ui.presenter.phase_time >= presentation_time and ui.presenter.name_label.modulate.a > 0.99 and ui.presenter.portrait.modulate.a > 0.99 and ui.presenter.portrait.texture.get_instance_id() == portrait_id, "reply preserves portrait and information without replaying entrance")
	check(ui.presenter.dialogue_lines[0].text == ui.presenter._wrap_dialogue(events.visit(first_uid).story.choices[0].reply)[0], "reply immediately replaces dialogue text")
	await seconds(1.5)
	await capture("06-npc-answer")
	await written(ui.presenter)
	presentation_time = ui.presenter.phase_time
	await key(KEY_ENTER)
	check(ui.dialogue_phase == "closing", "Enter advances NPC closing")
	check(ui.presenter.phase_time >= presentation_time and ui.presenter.name_label.modulate.a > 0.99 and ui.presenter.panel_material.get_shader_parameter("reveal") > 0.99, "closing preserves information and revealed panel")
	check(ui.presenter.dialogue_lines[0].text == ui.presenter._wrap_dialogue(events.visit(first_uid).story.closing)[0], "closing immediately replaces dialogue text")
	await written(ui.presenter)
	await key(KEY_SPACE)
	check(not ui.dialogue_active and not paused and events.history.size() == 1, "finish resumes gameplay and records exactly one conversation")
	check(events.visit(first_uid).read and events.history[0].transcript.size() == 4, "completed transcript keeps NPC/player/response/closing")
	await seconds(0.5)
	check(bgm.playing and AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Background")) > -0.1, "conversation end restores BGM volume")
	var second_uid: int = events.current_guests().filter(func(entry): return entry.uid != first_uid)[0].uid
	await seconds(2.5)
	check(Cfg.GUEST_STORY_EVERY == 2 and not ui.notification.visible and events.visit(second_uid).read and not events.visit(second_uid).ready, "second guest of the pair gets no dialogue notice (half rate)")
	# 아래 Esc·키보드·관리 탭 흐름 검증을 위해 두 번째 손님 이벤트를 수동으로 켠다.
	events.visit(second_uid).read = false
	events.visit(second_uid).ready = true
	events.changed.emit()
	await until(func(): return ui.notification.visible and ui.notification_uid == second_uid)
	await click(ui.notification)
	await key(KEY_ESCAPE)
	check(not ui.dialogue_active and not events.visit(second_uid).read and events.history.size() == 1, "Esc cancellation leaves unread event available")
	await frames(3)
	await click(ui.notification)
	await written(ui.presenter)
	await key(KEY_ENTER)
	await key(KEY_DOWN)
	check(root.gui_get_focus_owner() == ui.choice_buttons[1], "keyboard arrow selects second response")
	await key(KEY_ENTER)
	check(ui.dialogue_phase == "reply" and ui.selected_choice == events.visit(second_uid).story.choices[1].text, "keyboard Enter activates focused response")
	await key(KEY_ESCAPE)
	check(events.history.size() == 1 and not paused, "cancelled reply neither completes nor keeps world paused")
	await click(game.hud.moon.lodge_btn)
	check(game.hud.lodge_panel.visible and game.hud.lodge_tabs.current_tab == 1 and paused, "management button opens actual guest hub")
	check(game.hud.lodge_tabs.get_tab_count() == 4 and ui.guest_buttons.size() == 2, "facility/guest/history/contract tabs with two live guest actions")
	await frames(6)
	await capture("07-lodge-guests")
	await click(ui.guest_buttons[second_uid])
	check(ui.dialogue_active and not game.hud.lodge_panel.visible, "guest hub talk button opens conversation")
	await written(ui.presenter)
	await click(ui.next_button)
	await click(ui.choice_buttons[1])
	check(ui.selected_choice == events.visit(second_uid).story.choices[1].text and ui.dialogue_phase == "reply", "second branch works through real choice button")
	await written(ui.presenter)
	await key(KEY_ENTER)
	await written(ui.presenter)
	await key(KEY_ENTER)
	check(game.hud.lodge_panel.visible and paused and game.hud.lodge_tabs.current_tab == 1, "closing hub conversation returns to paused guest tab")
	game.hud.lodge_tabs.current_tab = 2
	await frames(8)
	check(events.history.size() == 2 and ui.history_list.get_child_count() == 2, "history tab shows both completed conversations")
	await capture("08-conversation-history")
	game.hud.lodge_tabs.current_tab = 0
	game.world.lodge.take_damage(30.0)
	game.economy.debug_add_gold(100)
	await frames(4)
	var hp: float = game.world.lodge.hp
	# 시설 목록이 길어 수리 버튼이 화면 아래로 밀릴 수 있다: 스크롤해 화면 안으로 가져온 뒤 누른다
	var repair_btn: Button = game.hud.shop_rows.repair.button
	var scroll: Node = repair_btn.get_parent()
	while scroll != null and not scroll is ScrollContainer:
		scroll = scroll.get_parent()
	if scroll != null:
		(scroll as ScrollContainer).ensure_control_visible(repair_btn)
		await frames(3)
	await click(repair_btn)
	check(game.world.lodge.hp > hp, "existing facility repair still purchases through hub")
	await capture("09-lodge-facilities")
	game.hud.close_lodge_panel()
	var gold_before: int = game.economy.gold
	game.session.prep_elapsed = 25.05
	await until(func(): return game.economy.batches[0].paid)
	check(game.economy.gold == gold_before + 2 * Cfg.GUEST_FEE, "lodging fee remains exactly two guest payments")
	check(events.current_guests().size() == 1 and events.pending_events().is_empty(), "departure removes stale guest event")
	game.hud.open_lodge_panel(1)
	await frames(4)
	var hire: Button = ui.guest_list.get_child(0).get_child(0).get_child(2).get_child(1)
	check(hire.text == "고용 · %dG" % Cfg.CONTRACT_COST and not hire.disabled, "guest hub exposes live mercenary contract")
	gold_before = game.economy.gold
	await click(hire)
	check(game.economy.gold == gold_before - Cfg.CONTRACT_COST and game.cards.persons_in_use().has("브람"), "hub hire grants same named contract for exact existing cost")
	check(events.current_guests().is_empty(), "hired guest leaves current lodging list")
	game.hud.close_lodge_panel()
	game.session.prep_elapsed = 30.05
	await until(func(): return intro.active)
	for size in [Vector2i(960, 540), Vector2i(1280, 720), Vector2i(1920, 1080)]:
		root.size = size
		await frames(5)
		check(root.get_visible_rect().encloses(intro.stage.get_global_rect()), "compact UI fits viewport " + str(size))
	root.size = Vector2i(1600, 872)
	# 한 창에서 모두 인사한 뒤 함께 입실하므로 첫 말 걸기까지 손님 수만큼 더 걸린다
	await until(func(): return ui.notification.visible, 40.0)
	await click(ui.notification)
	check(ui.dialogue_active, "next actual batch also offers dialogue")
	game.session.report_defeat("대화 전환 검증")
	await frames(4)
	check(not ui.dialogue_active and paused and game.hud.end_panel.visible and not intro.active, "defeat closes dialogue and arrival while preserving end-screen pause")
	var file := FileAccess.open(out + "verification.json", FileAccess.WRITE)
	if file != null: file.store_string(JSON.stringify({"checks": checks, "failures": failures, "renderer": DisplayServer.get_name()}, "\t"))
	print("GUEST_EVENTS_VERIFY ", "PASS" if failures.is_empty() else "FAIL", " checks=", checks.size())
	quit(0 if failures.is_empty() else 1)
