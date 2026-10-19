extends SceneTree
## 서리 룬 VFX 실제 렌더 캡처(창 실행). 헤드리스 더미 렌더러로는 VisualShader 컴파일·가산 합성·문양 모양을 볼 수 없어서 쓴다.
## 실행: .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_frost_rune.gd
## 결과: godot/screenshots/frost_rune/ 에 폭발 시간순 확대 장면(t_*.png)과 넓은 화면(wide.png), 감속 자국(slow_mark.png).

const OUT := "res://screenshots/frost_rune/"
const Cfg := preload("res://scripts/config.gd")
const FrostRune := preload("res://scripts/actors/frost_rune.gd")

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
		foes = main.get_tree().get_nodes_in_group("enemies").filter(func(e): return not e.dead and e.has_method("_sync_frost_mark") and e.get_script().resource_path.ends_with("monster.gd"))
		if foes.size() >= 2:
			break
	_hide_ui(root)
	# 화면을 가리는 독벌레(지역 거주 적)는 숨기고, 카메라를 조금 당긴다.
	for e in main.get_tree().get_nodes_in_group("enemies"):
		if not e.get_script().resource_path.ends_with("monster.gd"):
			e.visible = false
			e.process_mode = Node.PROCESS_MODE_DISABLED
	main.world.player_camera.desired_height = 8.0
	await create_timer(1.2).timeout
	var cam: Camera3D = main.world.camera
	# 화면 가운데 지면을 폭발 지점으로 잡고 적 몇 마리를 그 둘레로 옮긴다.
	var vp := Vector2(root.size) * 0.5
	var o := cam.project_ray_origin(vp)
	var d := cam.project_ray_normal(vp)
	var center := o + d * (-o.y / d.y)
	center.y = 0
	for k in mini(foes.size(), 3):
		var a := TAU * k / 3.0
		foes[k].global_position = center + Vector3(cos(a), 0, sin(a)) * Cfg.FROST_RADIUS * 0.55
	await create_timer(0.3).timeout
	var c := cam.unproject_position(center)
	var px := absf(cam.unproject_position(center + cam.global_basis.x * Cfg.FROST_RADIUS).x - c.x)
	var rect := Rect2i(Vector2i(int(c.x - px * 1.6), int(c.y - px * 1.25)), Vector2i(int(px * 3.2), int(px * 2.1)))
	print("center px ", c, " radius px ", px)
	await _grab("t_before.png", rect)
	var rune := FrostRune.new()
	rune.game = main
	rune.position = center
	main.actors.add_child(rune)
	var t0 := Time.get_ticks_msec()
	for at in [0.06, 0.14, 0.25, 0.45, 0.8, 1.3, 1.7, 2.1, 2.45]:
		while (Time.get_ticks_msec() - t0) / 1000.0 < at:
			await process_frame
		await _grab("t_%04d.png" % int(at * 1000.0), rect)
		if absf(at - 0.45) < 0.01:
			var wide := Rect2i(Vector2i(int(c.x - px * 3.2), int(c.y - px * 2.0)), Vector2i(int(px * 6.4), int(px * 3.6)))
			await _grab("wide.png", wide)
	await create_timer(0.6).timeout
	await _grab("slow_mark.png", rect)
	quit()


func _hide_ui(n: Node) -> void:
	if n is CanvasLayer:
		n.visible = false
	for ch in n.get_children():
		_hide_ui(ch)
