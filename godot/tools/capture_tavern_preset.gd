extends SceneTree
## 디버그 패널(F1)의 '에린·술 카드 지급' 프리셋 화면 캡처(패널 배치·손패 모습은 화면으로만 판단 가능).
## 실행(프로젝트 루트): .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_tavern_preset.gd
## 결과: res://screenshots/legendary/preset_panel.png, preset_hand.png

func _initialize() -> void:
	create_timer(120.0, true, false, true).timeout.connect(func(): quit(2))
	call_deferred("_run")


func _run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	for i in 40:
		await process_frame
	game.hud.debug_panel.visible = true
	for b in game.hud.debug_panel.find_children("*", "Button", true, false):
		if b.text == "에린·술 카드 지급":
			b.pressed.emit()
	for i in 120:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://screenshots/legendary/preset_panel.png"))
	print("DONE")
	quit(0)
