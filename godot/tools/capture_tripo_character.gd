extends SceneTree
## Tripo 묶음 캐릭터 확인 캡처(창 필요: 묶음 배정이 맞는지는 눈으로만 판단 가능).
## 실행: .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_tripo_character.gd -- <id>
## 결과: godot/screenshots/characters/<id>/textured.png, groups-posed.png

const COLORS := {"head": Color(.95, .75, .2), "torso": Color(.3, .6, .95), "arm_r": Color(.9, .25, .3),
	"arm_l": Color(.95, .5, .75), "leg_r": Color(.3, .8, .4), "leg_l": Color(.2, .55, .3), "backpack": Color(.6, .4, .9),
	"cape": Color(.55, .3, .85), "lantern": Color(1.0, .55, .15)}

func _initialize() -> void: call_deferred("_run")

func shot(path: String) -> void:
	for i in 8: await process_frame
	await RenderingServer.frame_post_draw
	get_root().get_texture().get_image().save_png(ProjectSettings.globalize_path(path))

func _run() -> void:
	var id: String = OS.get_cmdline_user_args()[0] if OS.get_cmdline_user_args().size() > 0 else "goblin_nib"
	var out := "res://screenshots/characters/%s/" % id
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out))
	get_root().size = Vector2i(900, 900)
	var stage := Node3D.new()
	get_root().add_child(stage)
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color(.16, .15, .2)
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color(.75, .75, .8)
	stage.add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-45, -30, 0)
	stage.add_child(sun)
	var cam := Camera3D.new()
	stage.add_child(cam)
	cam.look_at_from_position(Vector3(1.1, 1.0, 1.9), Vector3(0, .48, 0))
	cam.fov = 35
	var ch: Node3D = load("res://scenes/characters/%s.tscn" % id).instantiate()
	stage.add_child(ch)
	await shot(out + "textured.png")
	for n in ch.find_children("*", "Node3D", true, false):
		if not n.has_meta("part_group"): continue
		var g := str(n.get_meta("part_group"))
		var m := StandardMaterial3D.new()
		m.albedo_color = COLORS.get(g, Color.WHITE)
		(n.get_node("Mesh") as MeshInstance3D).material_override = m
		match g:
			"arm_r": n.rotation_degrees = Vector3(0, 0, -50)
			"arm_l": n.rotation_degrees = Vector3(0, 0, 50)
			"head": n.rotation_degrees = Vector3(0, 25, 10)
			"leg_r": n.rotation_degrees = Vector3(30, 0, 0)
			"backpack": n.rotation_degrees = Vector3(-15, 0, 0)
			"cape": n.rotation_degrees = Vector3(-25, 0, 0)
			"lantern": n.rotation_degrees = Vector3(30, 0, 15)
	await shot(out + "groups-posed.png")
	print("CAPTURED ", ProjectSettings.globalize_path(out))
	quit()
