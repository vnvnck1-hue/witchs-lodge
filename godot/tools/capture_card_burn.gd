extends SceneTree
## 카드 소모 연출(보랏빛 에디티브 글로우·검은 재) 실제 렌더 캡처. 셰이더 컴파일과 화면 결과는 헤드리스로 확인할 수
## 없으므로 꼭 필요할 때만 창을 띄워 실행한다. 카드 한 장을 산장에 놓아 소모시키고 연속 프레임을 저장한다.
## 실행(프로젝트 루트): .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_card_burn.gd -- --out=<폴더>

var out_dir := "screenshots/card-burn/"
var frame_no := 0


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			out_dir = a.trim_prefix("--out=").trim_suffix("/") + "/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_dir) if out_dir.begins_with("res://") else out_dir)
	create_timer(60.0, true, false, true).timeout.connect(func() -> void: quit(2))
	call_deferred("_run")


func shot(tag := "") -> void:
	await RenderingServer.frame_post_draw
	var img := root.get_texture().get_image()
	img.save_png(out_dir + "f%03d%s.png" % [frame_no, tag])
	frame_no += 1


func _run() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	for i in 40:
		await physics_frame
	var game = current_scene
	var hand = game.hud.card_hand
	paused = false
	game.cards.add("timber", 5)
	for i in 200:
		await physics_frame
		if not hand.views.is_empty() and hand.views.values()[0].mode == hand.CardViewScript.Mode.HAND:
			break
	var uid: int = game.cards.hand()[0]["uid"]
	var v = hand.views[uid]
	game.world.lodge.take_damage(150.0)
	hand.begin_drag(uid)
	# 카드를 화면 가운데 가까이 들어 올려 소모 연출이 잘 보이게 한다
	var at: Vector2 = game.world.camera.unproject_position(game.world.lodge.global_position + Vector3(0, 2, 0))
	for i in 12:
		hand.drag_pos = hand.drag_pos.lerp(at, 0.35)
		hand._update_drag()
		await process_frame
	hand.drag_pos = at
	hand._end_drag()
	print("CONSUME at ", at, " dying=", v.mode == hand.CardViewScript.Mode.DYING)
	# 1.3초 동안 3프레임마다 저장 → 약 26장
	var t := 0.0
	var k := 0
	while t < 1.35:
		await process_frame
		t += root.get_process_delta_time()
		k += 1
		if k % 2 == 0:
			await shot()
	print("DONE frames=", frame_no, " dir=", out_dir)
	quit(0)
