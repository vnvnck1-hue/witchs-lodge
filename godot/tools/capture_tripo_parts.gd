extends SceneTree
## Tripo 파츠 분리 GLB 를 파츠마다 다른 색 + 번호 라벨로 4방향 캡처(창 필요: 파츠가 몸의 어디인지는 눈으로만 판단 가능).
##   .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_tripo_parts.gd -- res://<glb> <출력 png> [제외 파츠,…]
## 제외 파츠는 그리지 않는다(몸과 떨어진 꼬리 등).

func global_xform(node: Node) -> Transform3D:
	var t := Transform3D.IDENTITY
	while node is Node3D:
		t = (node as Node3D).transform * t
		node = node.get_parent()
	return t

func _initialize() -> void: call_deferred("_run")

func _run() -> void:
	var args := OS.get_cmdline_user_args()
	var exclude := {}
	if args.size() > 2:
		for s in args[2].split(","): exclude[int(s)] = true
	var doc := GLTFDocument.new()
	var state := GLTFState.new()
	doc.append_from_file(ProjectSettings.globalize_path(args[0]), state)
	var scene := doc.generate_scene(state)
	get_root().size = Vector2i(700, 700)
	var stage := Node3D.new()
	get_root().add_child(stage)
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color(.12, .12, .14)
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color(.6, .6, .6)
	stage.add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-40, -20, 0)
	stage.add_child(sun)
	var holder := Node3D.new()
	stage.add_child(holder)
	var raw := AABB()
	var first := true
	var parts := []
	for node in scene.find_children("tripo_part_*", "MeshInstance3D", true, false):
		var n := int(str(node.name).get_slice("_", 2))
		if exclude.has(n): continue
		var box: AABB = global_xform(node) * (node as MeshInstance3D).mesh.get_aabb()
		raw = box if first else raw.merge(box)
		first = false
		parts.append([n, node])
	var k := 1.0 / raw.size.y
	var c := raw.get_center()
	var fit := Transform3D(Basis.from_scale(Vector3.ONE * k), Vector3(-c.x * k, -raw.position.y * k, -c.z * k))
	for p in parts:
		var mi := MeshInstance3D.new()
		mi.mesh = (p[1] as MeshInstance3D).mesh
		mi.transform = fit * global_xform(p[1])
		var m := StandardMaterial3D.new()
		m.albedo_color = Color.from_hsv(fmod(p[0] * 0.381966, 1.0), .75, .95)
		mi.material_override = m
		holder.add_child(mi)
		var lb := Label3D.new()
		lb.text = str(p[0])
		lb.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		lb.no_depth_test = true
		lb.font_size = 40
		lb.pixel_size = 0.0015
		lb.outline_size = 10
		lb.position = (fit * global_xform(p[1]) * (p[1] as MeshInstance3D).mesh.get_aabb()).get_center()
		holder.add_child(lb)
	var cam := Camera3D.new()
	stage.add_child(cam)
	cam.fov = 40
	var shots: Array[Image] = []
	for dir: Vector3 in [Vector3(0, .3, 2.2), Vector3(2.2, .3, 0), Vector3(0, .3, -2.2), Vector3(-2.2, .3, 0)]:
		cam.look_at_from_position(dir + Vector3(0, .5, 0), Vector3(0, .5, 0))
		for i in 6: await process_frame
		await RenderingServer.frame_post_draw
		shots.append(get_root().get_texture().get_image())
	var sheet := Image.create(1400, 1400, false, shots[0].get_format())
	for i in 4: sheet.blit_rect(shots[i], Rect2i(0, 0, 700, 700), Vector2i((i % 2) * 700, (i / 2) * 700))
	sheet.save_png(ProjectSettings.globalize_path(args[1]))
	print("SAVED ", args[1], "  (왼쪽 위 앞 +Z · 오른쪽 위 +X 쪽 · 왼쪽 아래 뒤 · 오른쪽 아래 -X 쪽)")
	scene.free()
	quit(0)
