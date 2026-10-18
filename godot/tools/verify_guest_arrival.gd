extends SceneTree
## 실제 도착 / 비차단 입력 / BGM 연속 재생 / 시안 비율 / 투명 초상 / VisualShader 움직임 / 순차 모션 검증.
var game
var records: Array = []
var failures: Array = []
var out := ""
var render := true

func _initialize() -> void:
	out = ProjectSettings.globalize_path("res://../output/guest-floating-v2/")
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): out = arg.trim_prefix("--out=").trim_suffix("/") + "/"
	render = DisplayServer.get_name() != "headless"
	create_timer(100.0, true, false, true).timeout.connect(func(): push_error("Floating guest timeout"); quit(2))
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	records.append({"ok": ok, "check": message})
	print("GUEST_FLOAT ", "PASS " if ok else "FAIL ", message)
	if not ok: failures.append(message)

func frames(count := 3) -> void:
	for i in count: await process_frame

func wait_for(condition: Callable, seconds := 12.0) -> bool:
	var start := Time.get_ticks_msec()
	while not condition.call():
		await process_frame
		if (Time.get_ticks_msec() - start) / 1000.0 > seconds:
			check(false, "condition timeout")
			return false
	return true

func wait_seconds(seconds: float) -> void:
	await create_timer(seconds, true, false, true).timeout

func key(code: int) -> void:
	await key_state(code, true)
	await key_state(code, false)

func key_state(code: int, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)
	await frames(2)

func mouse(at: Vector2, button: int, pressed: bool) -> void:
	var move := InputEventMouseMotion.new()
	move.position = at
	move.global_position = at
	root.push_input(move, true)
	await frames(2)
	var event := InputEventMouseButton.new()
	event.position = at
	event.global_position = at
	event.button_index = button
	event.pressed = pressed
	root.push_input(event, true)
	await frames(2)

func capture(id: String) -> void:
	if not render: return
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png(out + id + ".png") == OK, "capture " + id)

func alpha_cutout(texture: Texture2D) -> bool:
	var image := texture.get_image()
	if image.is_compressed(): image.decompress()
	var transparent := 0
	var opaque := 0
	var total := 0
	for y in range(0, image.get_height(), 12):
		for x in range(0, image.get_width(), 12):
			var a := image.get_pixel(x, y).a
			if a < 0.01: transparent += 1
			if a > 0.98: opaque += 1
			total += 1
	return transparent > total * 0.1 and opaque > total * 0.4

func verify_shader() -> void:
	var shader = load("res://shaders/guest_ink_panel.tres")
	check(shader is VisualShader and shader.get_node_list(VisualShader.TYPE_FRAGMENT).size() == 8, "editable eight-node VisualShader resource is used")
	if not render: return
	var view := SubViewport.new()
	view.size = Vector2i(640, 280)
	view.transparent_bg = true
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(view)
	var rect := ColorRect.new()
	rect.size = Vector2(640, 280)
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("reveal", 1.0)
	material.set_shader_parameter("opacity", 1.0)
	material.set_shader_parameter("motion_time", 0.0)
	rect.material = material
	view.add_child(rect)
	await frames(5)
	await RenderingServer.frame_post_draw
	var before := view.get_texture().get_image()
	material.set_shader_parameter("motion_time", 3.0)
	await frames(5)
	await RenderingServer.frame_post_draw
	var after := view.get_texture().get_image()
	var edge_changed := 0
	for y in before.get_height():
		for x in range(0, before.get_width(), 2):
			if absf(before.get_pixel(x, y).a - after.get_pixel(x, y).a) > 0.15: edge_changed += 1
	check(edge_changed > 100, "rendered silhouette actually undulates over time (%d edge samples)" % edge_changed)
	check(before.get_pixel(320, 140).r < 0.08 and before.get_pixel(320, 140).b < 0.1, "text backing is near-black violet as in reference")
	check(before.get_pixel(0, 0).a < 0.01, "panel has a transparent organic silhouette, no rectangular plate")
	before.save_png(out + "shader-time-0.png")
	after.save_png(out + "shader-time-3.png")
	view.queue_free()

func run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await frames(4)
	var intro = game.guest_arrival
	var economy = game.economy
	check(not intro.active and not paused, "normal gameplay before actual guest arrival")
	await wait_for(func(): return intro.active)
	check(intro.phase == "notice" and intro.profiles.size() == 2, "real first pair starts with compact arrival notification")
	check(not paused and game.movement_input_allowed(), "arrival never pauses gameplay or blocks movement")
	check(game.hud.root.visible, "existing HUD remains visible")
	check(intro.root.mouse_filter == Control.MOUSE_FILTER_IGNORE and not intro.has_method("_input"), "floating notification does not capture mouse or keyboard")
	var start_time: float = game.session.prep_elapsed
	var bgm = game.sounds.background_players.get("bgm_field")
	check(bgm != null and bgm.playing, "existing field BGM is playing at arrival")
	var music_id: int = bgm.get_instance_id() if bgm != null else -1
	var music_time: float = bgm.get_playback_position() if bgm != null else 0.0
	var music_volume: float = bgm.volume_db if bgm != null else 0.0
	await capture("01-notice")
	await wait_for(func(): return intro.phase == "guest" and intro.phase_time >= 0.22)
	check(intro.portrait.modulate.a > 0.0 and intro.name_label.modulate.a < 0.01, "portrait appears before name")
	await capture("02-portrait-enter")
	await wait_for(func(): return intro.phase_time >= 0.51)
	check(intro.name_label.modulate.a > 0.0 and intro.role_label.modulate.a < 0.01, "name enters before role and details")
	await capture("03-name-enter")
	await wait_for(func(): return intro.phase_time >= 0.86)
	check(intro.detail_label.modulate.a > 0.0 and intro.dialogue_lines[0].modulate.a < 0.01, "information enters before dialogue")
	await wait_for(func(): return intro.phase_time >= 1.35)
	check(intro.dialogue_lines[0].modulate.a > intro.dialogue_lines[1].modulate.a, "dialogue rows enter in a staggered motion sequence")
	check(intro.name_label.text == "브람" and intro.role_label.text == "도끼 용병", "first actual guest information is preserved")
	check(alpha_cutout(intro.portrait.texture), "mercenary portrait contains a real background-free alpha silhouette")
	var stage_rect: Rect2 = intro.stage.get_global_rect()
	var screen := root.get_visible_rect().size
	check(absf(stage_rect.size.x / screen.x - 1200.0 / 2540.0) < 0.01, "floating layout retains reference width ratio (47.2%)")
	check(absf(stage_rect.get_center().y / screen.y - 0.48) < 0.01, "floating layout retains reference vertical placement")
	check(intro.portrait.position.y < intro.panel.position.y and intro.portrait.position.x < intro.panel.position.x, "cutout portrait protrudes above and left of the backing panel")
	await wait_for(func(): return intro.phase_time >= 1.9)
	await capture("04-bram")
	check(game.session.prep_elapsed > start_time + 2.0, "night countdown keeps advancing during introduction")
	if bgm != null:
		check(bgm.get_instance_id() == music_id and bgm.playing and bgm.get_playback_position() > music_time + 1.0, "same BGM player continues playback without restart")
		check(absf(bgm.volume_db - music_volume) < 0.1, "arrival does not duck or change BGM gain")
	var position: Vector3 = game.player.position
	await key_state(KEY_DOWN, true)  # 롤식 조작: S는 정지, 키보드 이동은 방향키
	await wait_seconds(0.45)
	await key_state(KEY_DOWN, false)
	check(game.player.position.distance_to(position) > 0.25, "arrow-key movement works during floating introduction")
	var previous_height: float = game.world.player_camera.desired_height
	var over_panel: Vector2 = intro.panel.get_global_rect().get_center()
	await mouse(over_panel, MOUSE_BUTTON_WHEEL_UP, true)
	await mouse(over_panel, MOUSE_BUTTON_WHEEL_UP, false)
	check(game.world.player_camera.desired_height < previous_height, "wheel over notification reaches live world zoom")
	game.world.player_camera.zoom(1.0)
	await key(KEY_ESCAPE)
	check(paused and game.hud.pause_panel.visible, "Esc retains normal pause-menu behavior")
	var frozen: float = intro.phase_time
	await wait_seconds(0.25)
	check(is_equal_approx(intro.phase_time, frozen), "explicit player pause also holds notification timeline")
	await key(KEY_ESCAPE)
	check(not paused and intro.active, "closing normal pause menu continues the notification")
	game.cards.add("timber", 3)
	await frames(12)
	var entry: Dictionary = game.cards.entries[0]
	var view: Control = game.hud.card_hand.views[entry.uid]
	await wait_for(func(): return view.mode == 0, 3.0)
	game.hud.card_hand._compute_rest()
	var card_pos: Vector2 = game.hud.card_hand.rest[entry.uid]["pos"] - Vector2(0, game.hud.card_hand.CH * 0.55)
	await wait_seconds(0.25)
	await mouse(card_pos, MOUSE_BUTTON_LEFT, true)
	print("CARD_NOTIFICATION_INPUT point=", card_pos, " drag=", game.hud.card_hand.drag_uid, " expected=", entry.uid, " hovered=", root.gui_get_hovered_control())
	check(game.hud.card_hand.drag_uid == entry.uid, "card pickup remains usable during guest notification")
	await mouse(card_pos, MOUSE_BUTTON_RIGHT, true)
	await mouse(card_pos, MOUSE_BUTTON_RIGHT, false)
	await mouse(card_pos, MOUSE_BUTTON_LEFT, false)
	check(game.hud.card_hand.drag_uid == -1, "existing card cancel still works")
	await wait_for(func(): return intro.guest_index == 1 and intro.phase_time >= 1.9)
	check(intro.name_label.text == "미라" and alpha_cutout(intro.portrait.texture), "second guest automatically uses transparent herbalist portrait")
	await capture("05-mira")
	for label in intro.dialogue_lines:
		check(label.get_theme_font("font").get_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, 28).x <= intro.TEXT_WIDTH, "dialogue row fits inside dark panel")
	root.size = Vector2i(960, 540)
	await frames(8)
	check(root.get_visible_rect().encloses(intro.stage.get_global_rect()), "floating layout fits 960x540 window")
	await capture("06-small-window")
	root.size = Vector2i(1600, 800)
	await frames(5)
	await wait_for(func(): return not intro.active, 10.0)
	check(not paused and game.hud.root.visible, "automatic two-person introduction exits without touching gameplay")
	await capture("07-back-to-play")
	var gold_before_payment: int = economy.gold
	game.session.prep_elapsed = 25.05
	await wait_for(func(): return economy.batches[0].paid, 3.0)
	check(economy.gold == gold_before_payment + 30, "lodging payment remains exactly 30G")
	check(economy.offers.size() == 1 and economy.offers[0].person == "브람", "introduced identity still reaches actual hiring")
	if not economy.offers.is_empty(): check(economy.hire(economy.offers[0]), "introduced mercenary remains hireable")
	# 다음 실제 묶음은 증축 정원 3명을 모두 알린다.
	economy.capacity = 3
	game.session.prep_elapsed = 30.05
	await wait_for(func(): return intro.active, 3.0)
	check(intro.profiles.size() == 3, "expanded actual lodging batch retains all three introductions")
	game.session.start_wave()
	check(not intro.active and intro.pending.is_empty() and not paused, "wave transition dismisses stale guest notifications without pausing combat")
	await verify_shader()
	game.session.report_defeat("검증")
	check(paused and game.hud.end_panel.visible, "normal defeat pause is preserved")
	var output := {"checks": records, "failures": failures, "renderer": DisplayServer.get_name()}
	var file := FileAccess.open(out + "verification.json", FileAccess.WRITE)
	if file != null: file.store_string(JSON.stringify(output, "\t"))
	print("GUEST_FLOATING_VERIFY ", "PASS" if failures.is_empty() else "FAIL", " checks=", records.size())
	quit(0 if failures.is_empty() else 1)

