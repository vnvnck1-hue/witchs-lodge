extends SceneTree
const DIR := "res://scenes/props/nature/"
const OUT := "C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/output/nature-kit/"
var failures: Array[String] = []
var records: Array = []

func _initialize() -> void:
	call_deferred("_run")

func _check(ok: bool, message: String) -> void:
	if not ok: failures.append(message); push_error(message)

func _meshes(node: Node, result: Array) -> void:
	if node is MeshInstance3D: result.append(node)
	for child in node.get_children(): _meshes(child, result)

func _run() -> void:
	root.size = Vector2i(1600,1000)
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/nature/prefab_manifest.json"))
	var builder := load("res://tools/build_nature_prefabs.gd")
	var catalog: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/nature/catalog.json"))
	var expected := {}
	for asset in catalog.assets: expected[asset.id] = load("res://assets/nature/materials/%s.tres" % builder.material_id(asset))
	for entry in manifest.prefabs:
		var packed: PackedScene = load(DIR+entry.id+".tscn")
		_check(packed != null,"Missing prefab "+entry.id)
		if packed == null: continue
		var node: Node3D = packed.instantiate()
		var nodes: Array = []
		_meshes(node,nodes)
		_check(not nodes.is_empty(),"Empty model "+entry.id)
		var triangles := 0
		for mi: MeshInstance3D in nodes:
			if expected.has(entry.id): _check(mi.material_override == expected[entry.id],"Material not shared "+entry.id)
			else: _check(mi.material_override.shader == load("res://shaders/nature_prop.gdshader"),"Cluster part off nature shader "+entry.id)
			_check(mi.mesh.get_surface_count() == 1,"Unexpected surfaces "+entry.id)
			var arrays: Array = mi.mesh.surface_get_arrays(0)
			_check(not arrays[Mesh.ARRAY_COLOR].is_empty(),"Lost vertex painting "+entry.id)
			_check(not arrays[Mesh.ARRAY_TEX_UV].is_empty(),"Missing UV "+entry.id)
			triangles += arrays[Mesh.ARRAY_INDEX].size()/3
		records.append({"id":entry.id,"meshes":nodes.size(),"triangles":triangles,"shared_material":true,"vertex_colors":true})
		node.free()
	_check(records.size() == 26,"Expected 26 prefabs")
	var demo: Node3D = load(DIR+"nature_showcase.tscn").instantiate()
	root.add_child(demo)
	var camera: Camera3D = demo.get_node("Camera")
	camera.position = Vector3(10,18,23)
	camera.look_at(Vector3(0,1.5,0))
	# Neutral soft studio profile; then check exact game's strong toon settings.
	var styles := load("res://scripts/visual/screen_style.gd")
	if DisplayServer.get_name() != "headless":
		for style in ["soft","toon_strong"]:
			var p: Dictionary = styles.profile(style)
			RenderingServer.global_shader_parameter_set("card_style_shading",p.shading)
			RenderingServer.global_shader_parameter_set("card_style_surface",p.surface)
			RenderingServer.global_shader_parameter_set("card_style_palette",p.palette)
			RenderingServer.global_shader_parameter_set("card_style_ink",p.ink)
			for frame in 12: await process_frame
			await RenderingServer.frame_post_draw
			var image := root.get_texture().get_image()
			_check(not image.is_empty(),"Empty render "+style)
			image.save_png(OUT+"showcase-"+style+".png")
		demo.queue_free()
		await process_frame
		# Real current gameplay smoke: visual swaps preserve wrapper collisions/resources.
		var game_scene: PackedScene = load("res://scenes/main.tscn")
		_check(game_scene != null,"Main game cannot load")
		if game_scene != null:
			var game = game_scene.instantiate()
			root.add_child(game)
			for frame in 40: await process_frame
			game.process_mode = Node.PROCESS_MODE_DISABLED
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(OUT+"in-game.png")
			_check(game.world.harvest_trees.size() > 0,"Missing harvest tree wrappers")
			for tree in game.world.harvest_trees:
				_check(tree.visual.get_meta("nature_id","").begins_with("pine_"),"Harvest visual not from nature kit")
				_check(tree.body.collision_layer != 0,"Harvest collider removed")
			game.queue_free()
			await process_frame
	else:
		demo.free()
	var file := FileAccess.open(OUT+"verification.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"prefabs":records,"count":records.size(),"failures":failures},"\t"))
	file.close()
	print("NATURE_VERIFY ",records.size()," prefabs; failures=",failures)
	for frame in 3: await process_frame
	quit(0 if failures.is_empty() else 1)
