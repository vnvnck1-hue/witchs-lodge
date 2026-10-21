extends SceneTree
## 화살 포물선·꼬리 트레일과 적 피격 반동 실제 화면 캡처(창 실행: 리본 셰이더·호 모양은 헤드리스로 볼 수 없다).
## 실행: .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_arrow_trail.gd
## 결과: godot/screenshots/jobs/arrow-trail.png (비행 중 3순간 + 맞은 직후)

const ArrowScript := preload("res://scripts/actors/arrow.gd")
const OUT := "res://screenshots/jobs/"

var main


func _initialize() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	_run.call_deferred()


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	root.size = Vector2i(1600, 900)
	while current_scene == null or current_scene.get("session") == null:
		await process_frame
	main = current_scene
	for i in 30: await process_frame
	main.world.player_camera.desired_height = 8.0
	main.session.start_wave()
	var foe = null
	for i in 2400:
		await physics_frame
		for e in main.get_tree().get_nodes_in_group("enemies"):
			if not e.dead and e.get_script().resource_path.ends_with("monster.gd"):
				foe = e
				break
		if foe != null: break
	_hide_ui(root)
	for e in main.get_tree().get_nodes_in_group("enemies"):
		if e != foe:
			e.visible = false
			e.process_mode = Node.PROCESS_MODE_DISABLED
	foe.hp = 99999.0
	foe.set_physics_process(false)
	var p: Vector3 = main.player.global_position
	foe.global_position = p + Vector3(6.5, 0, -1.5)
	await create_timer(1.0).timeout
	var cam: Camera3D = main.world.camera
	var mid: Vector3 = (p + foe.global_position) * 0.5
	var c := cam.unproject_position(mid + Vector3(0, 0.8, 0))
	var rect := Rect2i(Vector2i(int(c.x) - 520, int(c.y) - 300), Vector2i(1040, 560))
	var arrow = ArrowScript.new()
	arrow.target = foe
	arrow.damage = 1.0
	main.actors.add_child(arrow)
	arrow.global_position = p + Vector3(0, 1.0, 0)
	var shots: Array[Image] = []
	var t0 := Time.get_ticks_msec()
	for at in [0.2, 0.42, 0.62, 0.78]:
		while (Time.get_ticks_msec() - t0) / 1000.0 < at:
			await process_frame
		await RenderingServer.frame_post_draw
		var img := root.get_texture().get_image().get_region(rect)
		img.convert(Image.FORMAT_RGBA8)
		shots.append(img)
		print("shot ", at)
	var sheet := Image.create(1040 * 2, 560 * 2, false, Image.FORMAT_RGBA8)
	for i in shots.size():
		sheet.blit_rect(shots[i], Rect2i(0, 0, 1040, 560), Vector2i((i % 2) * 1040, (i / 2) * 560))
	sheet.save_png(ProjectSettings.globalize_path(OUT + "arrow-trail.png"))
	print("SAVED")
	quit()


func _hide_ui(n: Node) -> void:
	if n is CanvasLayer:
		n.visible = false
	for ch in n.get_children():
		_hide_ui(ch)
