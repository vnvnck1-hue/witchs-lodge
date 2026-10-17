extends SceneTree
## 거미 GLB 부품 식별용 캡처(창 실행): 부품마다 색을 입혀 위·옆·앞에서 찍고 이름을 출력한다.
func _initialize() -> void: call_deferred("_run")

func _run() -> void:
	var scene: PackedScene = load("res://assets/monsters/spider/frozen_spider.glb")
	var model: Node3D = scene.instantiate()
	root.add_child(model)
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color(0.15, 0.15, 0.18)
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color(0.8, 0.8, 0.8)
	root.add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, 30, 0)
	root.add_child(sun)
	var cam := Camera3D.new()
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.size = 1.0
	root.add_child(cam)
	var mode := OS.get_cmdline_user_args()[0] if OS.get_cmdline_user_args().size() > 0 else "tex"
	var i := 0
	for mi in model.find_children("*", "MeshInstance3D", true, false):
		var aabb: AABB = mi.global_transform * mi.get_aabb()
		print("PART %s center=%s size=%s" % [mi.get_parent().name if mi.name.begins_with("Mesh") else mi.name, aabb.get_center(), aabb.size])
		if mode == "color":
			var m := StandardMaterial3D.new()
			m.albedo_color = Color.from_hsv(fmod(i * 0.137, 1.0), 0.8, 1.0)
			mi.material_override = m
			var l := Label3D.new()
			l.text = str(mi.get_parent().name if mi.name.begins_with("Mesh") else mi.name).replace("tripo_part_", "")
			l.pixel_size = 0.0015
			l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			l.no_depth_test = true
			l.outline_size = 8
			l.position = aabb.get_center() + Vector3(0, 0.02, 0)
			root.add_child(l)
		i += 1
	var views := {"top": [Vector3(0, 2, 0.05), Vector3(0, 0.3, 0)], "side": [Vector3(2, 0.35, 0.05), Vector3(0, 0.35, 0.05)], "front": [Vector3(0, 0.35, 2), Vector3(0, 0.35, 0)], "persp": [Vector3(1.0, 1.0, 1.3), Vector3(0, 0.3, 0.05)]}
	for v in views:
		cam.position = views[v][0]
		cam.look_at(views[v][1], Vector3.UP if v != "top" else Vector3(0, 0, -1))
		for f in 10: await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://screenshots/spider/inspect-%s-%s.png" % [mode, v]))
	quit()
