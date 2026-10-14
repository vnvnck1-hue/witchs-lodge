extends SceneTree
## Covers full-map texture presence, world anchoring, preset changes and exported resources.
const OUT := "C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/output/painted-ground/"
var failures: Array[String] = []
var samples: Array = []
var packed := false

func _initialize() -> void:
	packed = "--pack" in OS.get_cmdline_user_args()
	call_deferred("_run")

func check(ok: bool, message: String) -> void:
	if not ok: failures.append(message); push_error(message)

func frame_image() -> Image:
	for frame in 10: await process_frame
	await RenderingServer.frame_post_draw
	return root.get_texture().get_image()

func hide_geometry(node: Node, keep: Node) -> void:
	if node != keep and node is GeometryInstance3D: node.visible = false
	for child in node.get_children(): hide_geometry(child,keep)

func luminance_variation(image: Image) -> float:
	var total := 0.0
	var count := 0
	for y in range(64,448,4):
		for x in range(64,448,4):
			var a := image.get_pixel(x,y)
			var b := image.get_pixel(x+3,y+2)
			total += absf(a.get_luminance()-b.get_luminance())
			count += 1
	return total / count

func difference(a: Image, b: Image) -> float:
	var total := 0.0
	for y in range(64,448,8):
		for x in range(64,448,8):
			var ca := a.get_pixel(x,y)
			var cb := b.get_pixel(x,y)
			total += absf(ca.r-cb.r)+absf(ca.g-cb.g)+absf(ca.b-cb.b)
	return total/(48*48*3)

func _run() -> void:
	if packed:
		check(ProjectSettings.load_resource_pack("C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/build/WitchsLodge-painted-ground.pck",true),"Pack could not mount")
	root.size = Vector2i(512,512)
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	for frame in 15: await process_frame
	game.process_mode = Node.PROCESS_MODE_DISABLED
	game.hud.visible = false
	var world = game.world
	var material: ShaderMaterial = world.ground_mat
	for name in ["painted_snow","painted_trail","painted_forest","prop_blend_mask"]:
		var tex: Texture2D = material.get_shader_parameter(name)
		check(tex != null and tex.get_width() >= 1024,"Missing texture " + name)
		check(tex.get_image().has_mipmaps(),"Missing mipmaps " + name)
	check(material.shader.code.contains("world_pos.xz / texture_world_size"),"Ground is not world anchored")
	check(material.get_shader_parameter("painted_ground_enabled") > .99,"Painted terrain disabled")
	world.set_air_style("off")
	hide_geometry(world,world.get_node("SnowGround"))
	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 10.0
	camera.rotation_degrees = Vector3(-90,0,0)
	world.add_child(camera)
	camera.current = true
	var sites := {
		"logging":Vector2(-24,5),"shrine":Vector2(8,-26),"camp":Vector2(-20,23),"lookout":Vector2(23,18),
		"west-edge":Vector2(-34,0),"east-edge":Vector2(34,0),"north-edge":Vector2(0,-34),"south-edge":Vector2(0,34),
		"north-trail":Vector2(-8,-24),"south-trail":Vector2(-6,28)
	}
	for id in sites:
		var at: Vector2 = sites[id]
		camera.global_position = Vector3(at.x,30,at.y)
		var image := await frame_image()
		var detail := luminance_variation(image)
		check(detail > .002,"Terrain looks flat at " + id + ": " + str(detail))
		samples.append({"site":id,"world_position":[at.x,at.y],"neighbor_luminance_variation":detail})
		image.save_png(OUT+("pack-" if packed else "")+"ground-only-"+id+".png")
	# Camera height changes keep the same orthographic world pixels identical.
	camera.global_position = Vector3(23,30,18)
	var anchor_a := await frame_image()
	camera.global_position.y = 45.0
	var anchor_b := await frame_image()
	var anchor_error := difference(anchor_a,anchor_b)
	check(anchor_error < .002,"Camera movement changed world texture: " + str(anchor_error))
	var preset_records: Array = []
	var textures: Array = []
	for name in ["painted_snow","painted_trail","painted_forest","prop_blend_mask"]: textures.append(material.get_shader_parameter(name))
	var styles := load("res://scripts/visual/screen_style.gd")
	for style in styles.IDS:
		world.set_screen_style(style)
		var image := await frame_image()
		var detail := luminance_variation(image)
		check(detail > .001,"Preset hid all terrain detail: " + style)
		var current: Array = []
		for name in ["painted_snow","painted_trail","painted_forest","prop_blend_mask"]: current.append(material.get_shader_parameter(name))
		check(current == textures,"Preset replaced terrain bindings: " + style)
		preset_records.append({"style":style,"detail":detail})
	var file := FileAccess.open(OUT+("pack-" if packed else "")+"verification.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"failures":failures,"coverage":samples,"presets":preset_records,"anchor_error":anchor_error,"packed":packed},"\t"))
	file.close()
	print("PAINTED_GROUND_VERIFY ","pack" if packed else "source"," sites=",samples.size()," presets=",preset_records.size()," failures=",failures)
	game.queue_free()
	for frame in 3: await process_frame
	quit(0 if failures.is_empty() else 1)
