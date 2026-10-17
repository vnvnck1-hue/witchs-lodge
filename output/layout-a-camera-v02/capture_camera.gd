extends SceneTree
## Reference only: the actual default gameplay camera, without changing game resources.
const OUT := "res://../output/layout-a-camera-v02/"
var game

func _initialize() -> void:
	_run.call_deferred()
	create_timer(90.0, true, false, true).timeout.connect(func(): quit(2))

func _frames(count: int) -> void:
	for i in count:
		await process_frame

func _hide_canvas(node: Node) -> void:
	if node is CanvasLayer:
		node.visible = false
	for child in node.get_children():
		_hide_canvas(child)

func _grab(filename: String) -> void:
	print("CAPTURE_BEGIN ", filename)
	RenderingServer.force_draw(true)
	var image := root.get_texture().get_image()
	var error := image.save_png(ProjectSettings.globalize_path(OUT + filename))
	if error != OK:
		push_error("capture failed " + filename)
		quit(1)
	print("CAPTURE ", filename, " size=", image.get_size())

func _run() -> void:
	print("CAPTURE_INIT")
	OS.low_processor_usage_mode = false
	root.size = Vector2i(1600, 800)
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	print("GAME_READY")
	game.world.day_cycle.set_mode("day")
	# Hidden capture windows may not emit subsequent process frames; draw explicitly.
	for child in game.hud.toast_box.get_children():
		child.queue_free()
	paused = true
	await _grab("01-current-game-hud.png")
	_hide_canvas(game)
	await _grab("02-current-game-camera.png")
	var cam: Camera3D = game.world.camera
	var meta := {
		"viewport": [root.size.x, root.size.y],
		"projection": "perspective" if cam.projection == Camera3D.PROJECTION_PERSPECTIVE else "orthographic",
		"preset": preload("res://scripts/visual/camera_style.gd").current_id,
		"fov": cam.fov,
		"rotation_degrees": [cam.rotation_degrees.x, cam.rotation_degrees.y, cam.rotation_degrees.z],
		"position": [cam.global_position.x, cam.global_position.y, cam.global_position.z],
		"follow_height": game.world.player_camera.height,
		"follow_enabled": game.world.player_camera.follow_enabled,
		"player": [game.player.position.x, game.player.position.y, game.player.position.z],
		"note": "Current default camera; no zoom/overview/pose override; comparison capture uses day lighting."
	}
	var file := FileAccess.open(ProjectSettings.globalize_path(OUT + "camera.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(meta, "\t"))
	file.close()
	print("CAMERA ", JSON.stringify(meta))
	quit()
