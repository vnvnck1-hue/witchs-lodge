extends SceneTree
## 늑대인간 스킬 VFX·자세 실제 게임 화면 캡처(창 실행). 헤드리스 더미 렌더러로는 VisualShader 컴파일·가산 합성·
## 발톱 자국·지면 균열 모양을 볼 수 없어서 쓴다.
## 실행: .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_werewolf_ingame.gd
## 결과: godot/screenshots/characters/werewolf_witch/ingame_*.png 와 한 장으로 모은 ingame-sheet.png

const OUT := "res://screenshots/characters/werewolf_witch/"

var main
var player
var cam: Camera3D
var shots: Array[Image] = []
var labels: Array[String] = []


func _initialize() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	_run.call_deferred()


func _grab(label: String) -> void:
	await RenderingServer.frame_post_draw
	var img := root.get_texture().get_image()
	var c := cam.unproject_position(player.global_position + Vector3(0, 0.8, 0))
	var rect := Rect2i(Vector2i(int(c.x) - 420, int(c.y) - 300), Vector2i(840, 560)).intersection(Rect2i(Vector2i.ZERO, img.get_size()))
	img = img.get_region(rect)
	img.convert(Image.FORMAT_RGBA8)
	img.save_png(ProjectSettings.globalize_path(OUT + "ingame_%02d.png" % shots.size()))
	shots.append(img)
	labels.append(label)
	print("shot ", shots.size() - 1, " ", label)


func _wait(sec: float) -> void:
	var t0 := Time.get_ticks_msec()
	while (Time.get_ticks_msec() - t0) / 1000.0 < sec:
		await process_frame


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	root.size = Vector2i(1600, 900)
	while current_scene == null or current_scene.get("session") == null:
		await process_frame
	main = current_scene
	for i in 30:
		await process_frame
	player = main.player
	cam = main.world.camera
	main.world.player_camera.desired_height = 7.0
	main.session.start_wave()
	var foes: Array = []
	for i in 2400:
		await physics_frame
		foes = main.get_tree().get_nodes_in_group("enemies").filter(func(e): return not e.dead and e.get_script().resource_path.ends_with("monster.gd"))
		if foes.size() >= 3:
			break
	_hide_ui(root)
	for e in main.get_tree().get_nodes_in_group("enemies"):
		if not foes.has(e):
			e.visible = false
			e.process_mode = Node.PROCESS_MODE_DISABLED
	# 적은 맞아도 죽지 않게 체력을 크게, 움직이지 않게 멈춘다(자세·효과만 본다)
	for e in foes:
		e.hp = 99999.0
		e.set_physics_process(false)
	player.hp = 99999.0
	player.max_hp = 99999.0
	var p: Vector3 = player.global_position
	var fwd := Vector3(0, 0, 1)
	player.visual.rotation.y = 0.0
	foes[0].global_position = p + fwd * 1.3 + Vector3(0.3, 0, 0)
	foes[1].global_position = p + fwd * 1.5 + Vector3(-0.8, 0, 0)
	foes[2].global_position = p + Vector3(4.5, 0, 3.0)
	await _wait(1.0)
	# 1) 변신
	player.apply_moon("full")
	await _wait(0.12)
	await _grab("transform 0.12s")
	await _wait(0.35)
	await _grab("transform howl 0.5s")
	await _wait(1.4)
	await _grab("idle (panting)")
	# 2) 할퀴기
	player.cast_claw(foes[0].global_position)
	await _wait(0.06)
	await _grab("claw 1st rake")
	await _wait(0.14)
	await _grab("claw 2nd~3rd")
	await _wait(0.35)
	await _grab("claw marks burning out")
	await _wait(0.5)
	# 3) 물기
	player._bite(foes[0])
	await _wait(0.05)
	await _grab("bite snap")
	await _wait(0.6)
	# 4) 덮치기
	player.claw_cd = 0.0
	player.cast_pounce(foes[2])
	await _wait(0.12)
	await _grab("pounce in flight")
	await _wait(0.2)
	await _grab("pounce landing slam")
	await _wait(0.5)
	await _grab("slam cooling")
	_sheet()
	quit()


func _sheet() -> void:
	var w := shots[0].get_width()
	var h := shots[0].get_height()
	var cols := 3
	var rows := int(ceil(shots.size() / float(cols)))
	var sheet := Image.create(w * cols, h * rows, false, Image.FORMAT_RGBA8)
	for i in shots.size():
		var img := shots[i]
		if img.get_size() != Vector2i(w, h):
			img.resize(w, h)
		sheet.blit_rect(img, Rect2i(Vector2i.ZERO, Vector2i(w, h)), Vector2i((i % cols) * w, (i / cols) * h))
	sheet.save_png(ProjectSettings.globalize_path(OUT + "ingame-sheet.png"))
	print("SAVED ", labels)


func _hide_ui(n: Node) -> void:
	if n is CanvasLayer:
		n.visible = false
	for ch in n.get_children():
		_hide_ui(ch)
