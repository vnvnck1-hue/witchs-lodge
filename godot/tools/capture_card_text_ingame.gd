extends SceneTree
## 실제 게임 경로(Catalog.texture → CardFace 굽기)로 손패 카드에 글자가 그려지는지 확인하는 캡처. 창 필요.
## 실행(프로젝트 루트): .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_card_text_ingame.gd
## 이어서 F8(카드 언어)을 눌러 같은 손패가 그 자리에서 영문(A안 폰트)으로 다시 구워지는지 ingame_en.png 로 찍고, F8 을 한 번 더 눌러 원래 언어로 되돌린다.
var out := "res://screenshots/card-face/ingame.png"

func _initialize() -> void:
	create_timer(60.0, true, false, true).timeout.connect(func() -> void: quit(2))
	call_deferred("_run")

func _run() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	for i in 40:
		await physics_frame
	var game = current_scene
	game.cards.add("lumberjack", 1)
	game.cards.add("frost_rune", 1)
	game.cards.add("crest_banner", 1)
	for i in 90:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(out))
	print("SAVED ", out)
	var start: String = preload("res://scripts/ui/card_face.gd").language()
	_press_f8()
	for i in 60:
		await process_frame
	await RenderingServer.frame_post_draw
	var out2 := out.trim_suffix(".png") + "_" + preload("res://scripts/ui/card_face.gd").language() + ".png"
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(out2))
	print("SAVED ", out2)
	_press_f8()   # 원래 언어로(설정 파일도 되돌아간다)
	await process_frame
	print("LANG ", start, " -> back ", preload("res://scripts/ui/card_face.gd").language())
	quit(0)

func _press_f8() -> void:
	var e := InputEventKey.new()
	e.keycode = KEY_F8
	e.pressed = true
	Input.parse_input_event(e)
	var up := e.duplicate()
	up.pressed = false
	Input.parse_input_event(up)
