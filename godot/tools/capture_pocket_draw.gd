extends SceneTree
## 마녀의 주머니 연출 캡처(검토용): 시작 손패 고르기(3장 공개 → 1장 교체 → 손패로)와 아침 드로우(가운데 공개 → 손패 오른쪽 끝).
## 헤드리스로는 화면 결과를 볼 수 없어 실제 창에서 프레임을 저장한다.
## 실행(프로젝트 루트): .tools/Godot-4.7.2.exe --fixed-fps 60 --position -6000,-6000 --path godot --script res://tools/capture_pocket_draw.gd -- --out=<폴더>/

var game
var out_dir := ""
var frame_no := 0


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			out_dir = a.trim_prefix("--out=").trim_suffix("/") + "/"
	create_timer(120.0, true, false, true).timeout.connect(func(): quit(2))
	change_scene_to_file("res://scenes/main.tscn")
	call_deferred("_run")


func shot(label: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(out_dir + "%02d-%s.png" % [frame_no, label])
	print("SHOT ", frame_no, " ", label)
	frame_no += 1


func wait_frames(n: int) -> void:
	for i in n:
		await process_frame


func _run() -> void:
	while current_scene == null or current_scene.get("cards") == null:
		await process_frame
	game = current_scene
	await wait_frames(20)
	var mul = game.mulligan_ui
	game.grant_starter_cards()
	await wait_frames(14)
	await shot("mulligan-deal")
	while mul._phase != "pick":
		await process_frame
	await wait_frames(6)
	await shot("mulligan-pick")
	mul.toggle(1)
	await wait_frames(4)
	await shot("mulligan-marked")
	mul.confirm()
	await wait_frames(40)
	await shot("mulligan-swap")
	await wait_frames(55)
	await shot("mulligan-new-card")
	await wait_frames(40)
	await shot("mulligan-deliver")
	while mul.active:
		await process_frame
	await wait_frames(40)
	await shot("hand-after-mulligan")
	# 아침 드로우: 낮 전환을 직접 호출
	game.session.wave_index = 1
	game.session._enter_prep()
	await wait_frames(10)
	await shot("morning-draw-fly")
	await wait_frames(18)
	await shot("morning-draw-reveal")
	await wait_frames(45)
	await shot("morning-draw-landed")
	print("POCKET_CAPTURE done frames=", frame_no)
	quit(0)
