extends SceneTree
## Full-map, playable camera and regional frames from the actual game.
const OUT := "C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/output/forest-composition/"
const Layout := preload("res://scripts/world/layout.gd")
var label := "before"

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--label="): label = arg.trim_prefix("--label=")
	call_deferred("_run")

func _capture(game, id: String, at: Vector2, view: String) -> void:
	var cam: Camera3D = game.world.camera
	var focus := Vector3(at.x,0,at.y)
	game.world.player_camera.follow_enabled = true
	game.world.player_camera.focus = focus
	game.player.global_position = focus if id != "home" else Layout.PLAYER_START
	game.world.set_air_style("off" if view == "map" else "soft")
	if view == "map":
		root.size = Vector2i(1600,1600)
		cam.projection = Camera3D.PROJECTION_ORTHOGONAL
		cam.size = 100.0
		cam.rotation_degrees = Vector3(-90,0,0)
		cam.global_position = Vector3(0,65,0)
	else:
		root.size = Vector2i(1600,900)
		game.world.set_camera_style("lens_wide")
		cam.size = 18.0
		var distance := 9.0/tan(deg_to_rad(cam.fov)*.5)
		cam.global_position = focus+cam.global_basis.z*distance
	game.world.aerial_perspective.sync_camera()
	game.world.aerial_perspective.sync_colors()
	for frame in 16: await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(OUT+label+"-"+id+".png") == OK)

func _collect(node: Node, parts: Array) -> void:
	if node is Node3D and node.has_meta("nature_id"):
		var pos: Vector3 = node.global_position
		var scale: Vector3 = node.global_basis.get_scale()
		parts.append({"id":node.get_meta("nature_id"),"position":[pos.x,pos.z],"scale":scale.y})
	for child in node.get_children(): _collect(child,parts)

func _run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	for frame in 16: await process_frame
	game.process_mode = Node.PROCESS_MODE_DISABLED
	game.hud.visible = false
	await _capture(game,"map",Vector2.ZERO,"map")
	await _capture(game,"home",Vector2(1,3),"play")
	for landmark in Layout.LANDMARKS: await _capture(game,landmark.id,landmark.pos,"play")
	for frame in [["west-bend",Vector2(-29,-5)],["north-bend",Vector2(22,-22)],["south-bend",Vector2(0,28)],["east-bend",Vector2(27,2)]]:
		await _capture(game,frame[0],frame[1],"play")
	var parts: Array = []
	_collect(game.world,parts)
	var file := FileAccess.open(OUT+label+"-layout.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"props":parts},"\t"))
	file.close()
	print("FOREST_REVIEW ",label," props=",parts.size())
	game.queue_free()
	for frame in 3: await process_frame
	quit()
