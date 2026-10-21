extends SceneTree
## 마녀 Q 번개 일격 실제 렌더 캡처(창 실행). 헤드리스 더미 렌더러로는 VisualShader 컴파일·가산 합성·줄기 모양을 볼 수 없어서 쓴다.
## 실행: .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_lightning.gd
## 결과: godot/screenshots/lightning/ 에 시전 시간순 장면(t_*.png, 게임 시간을 늦춰 정확한 시점을 잡는다)과 넓은 화면(wide.png).

const OUT := "res://screenshots/lightning/"
const SLOW := 0.12

var main


func _initialize() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	_run.call_deferred()


func _grab(path: String, rect: Rect2i) -> void:
	await RenderingServer.frame_post_draw
	var img := root.get_texture().get_image()
	img = img.get_region(rect.intersection(Rect2i(Vector2i.ZERO, img.get_size())))
	img.save_png(ProjectSettings.globalize_path(OUT + path))
	print("saved ", path)


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	root.size = Vector2i(1600, 900)
	while current_scene == null or current_scene.get("session") == null:
		await process_frame
	main = current_scene
	for i in 30:
		await process_frame
	main.session.start_wave()
	var foes: Array = []
	for i in 2400:
		await physics_frame
		foes = main.get_tree().get_nodes_in_group("enemies").filter(func(e): return not e.dead and e.get_script().resource_path.ends_with("monster.gd"))
		if foes.size() >= 2:
			break
	_hide_ui(root)
	for e in main.get_tree().get_nodes_in_group("enemies"):
		if not foes.slice(0, 2).has(e):
			e.visible = false
			e.process_mode = Node.PROCESS_MODE_DISABLED
	var p = main.player
	var o: Vector3 = p.global_position
	o.y = 0.0
	# 화면 오른쪽(카메라 오른쪽을 땅에 눕힌 방향)으로 적 둘을 줄 세우고 체력을 넉넉히 줘서 맞아도 남게 한다
	var right: Vector3 = main.world.camera.global_basis.x
	right.y = 0.0
	right = right.normalized()
	for k in 2:
		foes[k].global_position = o + right * (3.0 + k * 3.2)
		foes[k].hp = 9999.0
		foes[k].set_physics_process(false)
	main.world.player_camera.desired_height = 8.5
	# 평타 마법탄(보랏빛)이 섞이지 않게 평타를 막는다
	p.attack_cd = 999.0
	p.target_enemy = null
	await create_timer(1.4).timeout
	var cam: Camera3D = main.world.camera
	var a := cam.unproject_position(o - right * 0.8 + Vector3(0, 1.0, 0))
	var b := cam.unproject_position(o + right * 9.0 + Vector3(0, 1.0, 0))
	var box := Rect2(a, Vector2.ZERO).expand(b).grow_individual(60.0, 260.0, 60.0, 200.0)
	var rect := Rect2i(box)
	await _grab("t_before.png", rect)
	p.lightning_cd = 0.0
	Engine.time_scale = SLOW
	p.cast_lightning(o + right * 6.0)
	var t0 := Time.get_ticks_msec()
	for at in [0.02, 0.05, 0.09, 0.14, 0.2, 0.28, 0.36, 0.6, 1.1]:
		while (Time.get_ticks_msec() - t0) / 1000.0 * SLOW < at:
			await process_frame
		await _grab("t_%04d.png" % int(at * 1000.0), rect)
		if absf(at - 0.09) < 0.001:
			await _grab("wide.png", Rect2i(Vector2i.ZERO, root.size))
	Engine.time_scale = 1.0
	quit()


func _hide_ui(n: Node) -> void:
	if n is CanvasLayer:
		n.visible = false
	for ch in n.get_children():
		_hide_ui(ch)
