extends SceneTree
## Renders the real game twice, a moment apart, and checks that foliage sways while rocks stay put.
const OUT := "C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/output/vegetation-wind/"
var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _check(ok: bool, message: String) -> void:
	if not ok: failures.append(message); push_error(message)

func _meshes(node: Node, result: Array) -> void:
	if node is MeshInstance3D: result.append(node)
	for child in node.get_children(): _meshes(child, result)

## Mean absolute pixel change inside the screen-space footprint of a node.
func _change(a: Image, b: Image, camera: Camera3D, node: Node3D, height: float) -> float:
	var top := camera.unproject_position(node.global_position + Vector3(0, height, 0))
	var base := camera.unproject_position(node.global_position)
	var half := maxf(absf(base.y - top.y) * .35, 6.0)
	var rect := Rect2i(Vector2i(int(top.x - half), int(top.y)), Vector2i(int(half * 2), int(absf(base.y - top.y))))
	rect = rect.intersection(Rect2i(Vector2i.ZERO, a.get_size()))
	if rect.size.x <= 0 or rect.size.y <= 0: return -1.0
	var total := 0.0
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			var ca := a.get_pixel(x, y)
			var cb := b.get_pixel(x, y)
			total += absf(ca.r - cb.r) + absf(ca.g - cb.g) + absf(ca.b - cb.b)
	return total / float(rect.size.x * rect.size.y)

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	root.size = Vector2i(1600, 900)
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	for frame in 30: await process_frame
	# Freeze gameplay (actors) but keep shader TIME running so only wind changes the pixels.
	game.process_mode = Node.PROCESS_MODE_DISABLED
	var world = game.world
	var snow: Node = world.get_node_or_null("Snowfall")
	if snow: snow.visible = false
	var smoke: Node = world.get_node_or_null("ChimneySmoke")
	if smoke: smoke.visible = false
	var camera: Camera3D = world.camera
	# Pivots must sit on the ground so the sway is rooted at the trunk base.
	for tree in world.harvest_trees:
		var meshes: Array = []
		_meshes(tree.visual, meshes)
		for mi: MeshInstance3D in meshes:
			_check(absf(mi.global_position.y) < .05, "Mesh pivot off ground " + str(mi.global_position))
			_check(mi.material_override.get_shader_parameter("wind_strength") > 0.0, "Tree has no wind material")
	await RenderingServer.frame_post_draw
	var first := root.get_texture().get_image()
	first.save_png(OUT + "frame-a.png")
	await create_timer(1.6, true, false, true).timeout
	await RenderingServer.frame_post_draw
	var second := root.get_texture().get_image()
	second.save_png(OUT + "frame-b.png")
	var report := {"trees": [], "rocks": []}
	for tree in world.harvest_trees:
		report.trees.append(_change(first, second, camera, tree.body, 5.0))
	for body in world.nav_region.get_children():
		if body is StaticBody3D and body.get_child_count() > 1 and not body.get_meta("tree", false):
			var visual = body.get_child(1)
			if visual is Node3D and String(visual.get_meta("nature_id", "")).begins_with("rock"):
				report.rocks.append(_change(first, second, camera, body, 1.4))
	var visible_trees: Array = report.trees.filter(func(v): return v >= 0.0)
	var visible_rocks: Array = report.rocks.filter(func(v): return v >= 0.0)
	_check(not visible_trees.is_empty(), "No harvest tree on screen")
	var tree_mean := 0.0
	for v in visible_trees: tree_mean += v / visible_trees.size()
	var rock_max := 0.0
	for v in visible_rocks: rock_max = maxf(rock_max, v)
	_check(tree_mean > .01, "Trees did not move (%f)" % tree_mean)
	_check(rock_max < tree_mean * .25, "Rocks moved too (%f vs %f)" % [rock_max, tree_mean])
	var diff := Image.create(first.get_width(), first.get_height(), false, Image.FORMAT_RGB8)
	for y in first.get_height():
		for x in first.get_width():
			var d := first.get_pixel(x, y) - second.get_pixel(x, y)
			var m := clampf((absf(d.r) + absf(d.g) + absf(d.b)) * 4.0, 0.0, 1.0)
			diff.set_pixel(x, y, Color(m, m, m))
	diff.save_png(OUT + "diff.png")
	report["tree_mean"] = tree_mean
	report["rock_max"] = rock_max
	report["failures"] = failures
	var file := FileAccess.open(OUT + "verification.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t"))
	file.close()
	print("VEGETATION_WIND tree_mean=", tree_mean, " rock_max=", rock_max, " failures=", failures)
	quit(0 if failures.is_empty() else 1)
