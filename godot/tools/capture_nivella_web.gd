extends SceneTree
## 서리 거미줄 VisualShader 단독 캡처(창 실행): 무늬(바퀴살·나선·허브·이슬)와 충격파 출렁임을 본다.
## 헤드리스 더미 렌더러로는 셰이더 컴파일·외형·정점 흔들림을 볼 수 없어 짧게 찍는다. 결과: godot/screenshots/nivella_web/
## 실행: .tools/Godot-4.7.2.exe --path godot --resolution 1400x800 --script res://tools/capture_nivella_web.gd
const Web := preload("res://scripts/visual/vfx/nivella_web.gd")
const OUT := "res://screenshots/nivella_web/"


func _initialize() -> void:
	create_timer(40.0, true, false, true).timeout.connect(func(): quit(2))
	call_deferred("_run")


func _wait(sec: float) -> void:
	var end := Time.get_ticks_msec() + int(sec * 1000.0)
	while Time.get_ticks_msec() < end:
		Web.tick(1.0 / 60.0)
		await process_frame


func _shot(n: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + n + ".png"))
	print("SHOT ", n)


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var w := Node3D.new()
	root.add_child(w)
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color("1c1f45")
	w.add_child(env)
	var ground := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(40, 40)
	ground.mesh = pm
	var fm := StandardMaterial3D.new()
	fm.albedo_color = Color("2c3a6e")
	fm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ground.material_override = fm
	w.add_child(ground)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, 30, 0)
	sun.light_color = Color("aab8ff")
	sun.shadow_enabled = true
	w.add_child(sun)
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color("5a66b0")
	# 기둥을 덮은 막(보스 쪽으로 가닥이 길게) + 기둥 끝에서 보스 쪽 바닥으로 걸린 실 + 알 무더기 + 바닥 막
	var boss := Vector3(1.5, 0, 6.0)
	for pl in [Vector3(-5, 0, -1), Vector3(5, 0, -2)]:
		var pillar := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(1.2, 7.0, 1.2)
		pillar.mesh = bm
		pillar.position = pl + Vector3(0, 3.5, 0)
		w.add_child(pillar)
		var to: Vector3 = (boss - pl).normalized()
		w.add_child(Web.make_shroud(pl, 1.0, 7.4, 3.2, 8, pl.x, to, 1.2, 0.3))
		for k in 3:
			var g: Vector3 = boss + Vector3(randf_range(-3, 3), 0, randf_range(-2, 1))
			w.add_child(Web.make_strand(pl + Vector3(0, 6.6, 0), g, 0.5 if k == 0 else 0.28, k == 0))
	w.add_child(Web.make_splat(Vector3(6, 0, 6), 3.2, 9))
	for spec in [[Vector3(-4.5, 0, 5.5), 1.25, 3.3, 2.6], [Vector3(-2.3, 0, 6.8), 0.95, 2.5, 2.0], [Vector3(-5.6, 0, 7.6), 0.8, 2.0, 1.6]]:
		w.add_child(Web.make_egg(spec[0], spec[1], spec[2]))
		w.add_child(Web.make_shroud(spec[0], spec[1], spec[2], spec[3], 7, spec[1] * 7.0, (boss - spec[0]).normalized(), 0.8, 0.48))
	var cam := Camera3D.new()
	w.add_child(cam)
	cam.position = Vector3(4, 12, 20)
	cam.look_at(Vector3(-0.5, 2.0, 3.0))
	cam.current = true
	await _wait(0.5)
	await _shot("01-idle")
	var cam2 := Camera3D.new()
	w.add_child(cam2)
	cam2.position = Vector3(-1.0, 4.0, 13.0)
	cam2.look_at(Vector3(-4.0, 1.4, 6.0))
	cam2.current = true
	await _wait(0.2)
	await _shot("02-close")
	cam.current = true
	Web.shock(Vector3(2, 0, 4), 1.2)
	for i in 6:
		await _wait(0.12)
		await _shot("03-shock-%d" % i)
	quit()
