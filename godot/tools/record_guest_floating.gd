extends SceneTree
## Capture the actual uninterrupted world + UI sequence as small frames for a review GIF.
var game
var out := ""

func _initialize() -> void:
	out = ProjectSettings.globalize_path("res://../output/guest-floating-v2/frames/")
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): out = arg.trim_prefix("--out=").trim_suffix("/") + "/"
	call_deferred("run")

func run() -> void:
	root.size = Vector2i(1600, 872)
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	for i in 4: await process_frame
	game.session.prep_elapsed = 4.7
	while not game.guest_arrival.active: await process_frame
	for index in 136:
		await RenderingServer.frame_post_draw
		var image := root.get_texture().get_image()
		image.resize(960, 524, Image.INTERPOLATE_LANCZOS)
		var error := image.save_png(out + "%03d.png" % index)
		if error != OK:
			push_error("Frame save failed: " + str(error))
			quit(1)
			return
		await create_timer(0.125, true, false, true).timeout
	print("FLOATING_RECORD frames=136 gameplay_time=", game.session.prep_elapsed)
	quit()
