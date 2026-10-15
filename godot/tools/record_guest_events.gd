extends SceneTree
## Record the live arrival, portrait flight, speech notification and voluntary conversation.
var game
var out := ""
var started := -1.0
var done := -1.0

func _initialize() -> void:
	out = ProjectSettings.globalize_path("res://../output/guest-events-v4/frames/")
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): out = arg.trim_prefix("--out=").trim_suffix("/") + "/"
	call_deferred("run")

func click(button: Control) -> void:
	var at := button.get_global_rect().get_center()
	var move := InputEventMouseMotion.new()
	move.position = at
	move.global_position = at
	root.push_input(move, true)
	for i in 2: await process_frame
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.position = at
		event.global_position = at
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		root.push_input(event, true)
		for i in 2: await process_frame

func run() -> void:
	root.size = Vector2i(1600, 872)
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	for i in 6: await process_frame
	game.world.day_cycle.set_mode("day")
	game.cards.add("timber", 3)
	game.session.prep_elapsed = 4.8
	var clock := Time.get_ticks_msec()
	for index in 240:
		var elapsed := (Time.get_ticks_msec() - clock) / 1000.0
		var ui = game.guest_ui
		if not game.guest_arrival.active and ui.notification.visible and started < 0.0:
			await click(ui.notification)
			started = elapsed
		if started > 0:
			var age := elapsed - started
			if age > 2.4 and ui.dialogue_phase == "opening": await click(ui.next_button)
			if age > 4.2 and ui.dialogue_phase == "choices": await click(ui.choice_buttons[0])
			if age > 6.6 and ui.dialogue_phase == "reply": await click(ui.next_button)
			if age > 8.4 and ui.dialogue_phase == "closing":
				await click(ui.next_button)
				done = elapsed
		await RenderingServer.frame_post_draw
		var image := root.get_texture().get_image()
		image.resize(960, 523, Image.INTERPOLATE_LANCZOS)
		if image.save_png(out + "%03d.png" % index) != OK:
			push_error("Recording save failed")
			quit(1)
			return
		if done > 0 and elapsed - done > 1.3:
			print("GUEST_EVENTS_RECORD frames=", index + 1, " completed_dialogues=", game.guest_events.history.size())
			quit(0)
			return
		await create_timer(0.1, true, false, true).timeout
	push_error("Recording did not reach completed conversation")
	quit(1)
