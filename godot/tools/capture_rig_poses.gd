extends SceneTree
## 파츠 캐릭터 애니메이션 자세 근접 캡처(창 필요: 자세는 눈으로만 판단 가능).
## 실행: .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_rig_poses.gd -- <character_id(손님 id 또는 witch_north)>
## 결과: godot/screenshots/characters/<scene id>/poses-<state>-<n>.png

const CharacterModels := preload("res://scripts/visual/character_models.gd")

func _initialize() -> void: call_deferred("_run")

func _run() -> void:
	var cid: String = OS.get_cmdline_user_args()[0] if OS.get_cmdline_user_args().size() > 0 else "nib"
	# 플레이어 마녀는 지팡이까지 붙인 실제 플레이어 모델로 찍는다.
	var made := CharacterModels.make_player_witch() if cid == "witch_north" else CharacterModels.make(cid)
	var states: Array = ["idle", "walk", "windup", "cast", "work", "hurt"] if cid == "witch_north" else ["walk", "greet", "wave", "idle"]
	var scene_id := str(CharacterModels.CATALOG[cid].scene).get_file().get_basename()
	var out := "res://screenshots/characters/%s/" % scene_id
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out))
	get_root().size = Vector2i(600, 600)
	var stage := Node3D.new()
	get_root().add_child(stage)
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color(.18, .17, .23)
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color(.7, .7, .78)
	stage.add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, -25, 0)
	stage.add_child(sun)
	var cam := Camera3D.new()
	stage.add_child(cam)
	cam.fov = 32
	cam.look_at_from_position(Vector3(1.0, 0.95, 1.7), Vector3(0, .4, 0))
	stage.add_child(made.root)
	var anim = made.anim
	anim.set_process(false)
	for st in states:
		anim.play(st)
		anim.amount = 1.0
		for k in 4:
			for i in 7: anim._process(1.0 / 60.0)   # 상태별 시간을 정확히 진행(약 0.12초 간격)
			for i in 3: await process_frame
			await RenderingServer.frame_post_draw
			get_root().get_texture().get_image().save_png(ProjectSettings.globalize_path(out + "poses-%s-%d.png" % [st, k]))
	print("CAPTURED ", ProjectSettings.globalize_path(out))
	quit()
