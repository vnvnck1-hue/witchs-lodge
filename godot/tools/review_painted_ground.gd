extends SceneTree
## Actual current game, camera at every landmark. Exports authoritative prop positions.
const OUT := "C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/output/painted-ground/"
const Layout := preload("res://scripts/world/layout.gd")
var label := "before"
var props: Array = []

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--label="): label = arg.trim_prefix("--label=")
	call_deferred("_run")

func _collect(node: Node) -> void:
	if node is Node3D and node.has_meta("nature_id"):
		var id: String = node.get_meta("nature_id")
		if not id.begins_with("cluster"):
			var p: Vector3 = node.global_position
			props.append({"id":id,"position":[p.x,p.z],"scale":node.global_basis.get_scale().y})
	for child in node.get_children(): _collect(child)

func _capture(game, id: String, at: Vector2, air: String, style := "toon_strong") -> void:
	game.world.set_screen_style(style)
	game.world.set_air_style(air)
	var camera: Camera3D = game.world.camera
	var focus := Vector3(at.x,0,at.y)
	game.player.global_position = focus
	game.world.player_camera.follow_enabled = true
	camera.size = 18.0
	camera.global_position = focus + camera.global_basis.z * Layout.CAMERA_DISTANCE
	game.world.player_camera.focus = focus
	game.world.aerial_perspective.sync_camera()
	if game.world.aerial_perspective.has_method("sync_colors"):
		game.world.aerial_perspective.sync_colors()
	for frame in 12: await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	assert(image.save_png(OUT+label+"-"+id+"-"+air+".png") == OK)

func _run() -> void:
	root.size = Vector2i(1600,900)
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	for frame in 12: await process_frame
	game.process_mode = Node.PROCESS_MODE_DISABLED
	game.hud.visible = false
	game.world.player_camera.follow_enabled = false
	if label == "before":
		var original := Shader.new()
		original.code = FileAccess.get_file_as_string(OUT+"before-ground.gdshader")
		game.world.ground_mat.shader = original
	_collect(game.world)
	var paths: Array = []
	for path in Layout.EXPLORATION_PATHS:
		var points: Array = []
		for p in path: points.append([p.x,p.y])
		paths.append(points)
	var landmarks: Array = []
	for landmark in Layout.LANDMARKS:
		landmarks.append({"id":landmark.id,"position":[landmark.pos.x,landmark.pos.y]})
	var file := FileAccess.open(OUT+"ground-layout.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"props":props,"paths":paths,"landmarks":landmarks,"mask_bounds":[-60,-60,120,120]},"\t"))
	file.close()
	await _capture(game,"lodge",Layout.MAP_CENTER,"dramatic")
	for landmark in Layout.LANDMARKS:
		await _capture(game,landmark.id,landmark.pos,"dramatic")
		await _capture(game,landmark.id,landmark.pos,"off")
	await _capture(game,"north-path",Vector2(-8,-24),"dramatic")
	await _capture(game,"south-path",Vector2(-6,28),"dramatic")
	print("GROUND_REVIEW ",label," captures=11 props=",props.size())
	game.queue_free()
	for frame in 3: await process_frame
	quit()
