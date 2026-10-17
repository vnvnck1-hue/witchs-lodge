extends SceneTree
## Capture the current source game with its actual renderer, camera, models and lighting.
const OUT := "../output/gameplay-blizzard-concepts-v01/captures/"
var game
var canvas_states: Dictionary = {}

func _initialize() -> void:
	_run.call_deferred()
	create_timer(120.0, true, false, true).timeout.connect(func(): quit(2))

func _frames(count: int) -> void:
	for i in count:
		await process_frame

func _canvas_visible(node: Node, value: bool) -> void:
	if node is CanvasLayer:
		if not value:
			canvas_states[node] = node.visible
			node.visible = false
		elif canvas_states.has(node):
			node.visible = canvas_states[node]
	for child in node.get_children():
		_canvas_visible(child, value)

func _capture(filename: String) -> void:
	if "--hud-only" in OS.get_cmdline_user_args() and "clean" in filename:
		return
	await _frames(6)
	await RenderingServer.frame_post_draw
	var path := ProjectSettings.globalize_path("res://" + OUT + filename)
	var result := root.get_texture().get_image().save_png(path)
	if result != OK:
		push_error("CAPTURE_FAILED " + filename)
		quit(1)
	print("CAPTURE ", filename, " time=", game.world.day_cycle.mode,
		" camera=", game.world.camera.global_transform,
		" size=", root.size)

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://" + OUT))
	root.size = Vector2i(1920, 1080)
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.world.day_cycle.set_mode("day")
	# Script runs intentionally omit starter-card reveal animations for environment capture.
	await create_timer(7.0, true, false, true).timeout
	for child in game.hud.toast_box.get_children():
		child.queue_free()
	paused = true
	await _capture("01-day-ingame.png")
	_canvas_visible(game, false)
	await _capture("02-day-clean.png")
	game.session.start_wave()
	game.world.day_cycle.set_mode("night")
	_canvas_visible(game, true)
	for child in game.hud.toast_box.get_children():
		child.queue_free()
	await _capture("03-night-ingame.png")
	_canvas_visible(game, false)
	await _capture("04-night-clean.png")
	print("CAPTURE_COMPLETE default style/camera/air; current source assets; no gameplay source edits")
	quit()
