extends SceneTree
## 실제 창으로 화면 모드 전환과 가운데 정렬을 캡처한다(헤드리스 더미 DisplayServer로는 실제 전체 화면 전환·
## 모니터 해상도 결과를 확인할 수 없어서). 1600×800 창에서 시작 손패를 연 뒤 전체 화면(테두리 없음)으로 바꿔
## 사용자가 겪은 상황(F11)을 재현하고, 바뀐 뒤 화면을 저장한다. 설정 파일은 저장하지 않는다.
## 실행(프로젝트 루트): .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_display.gd
## 결과: godot/screenshots/display/

const OUT := "res://screenshots/display/"


func _initialize() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	_run.call_deferred()


func _wait(sec: float) -> void:
	await create_timer(sec, true, false, true).timeout


func _shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	var img := root.get_texture().get_image()
	img.save_png(ProjectSettings.globalize_path(OUT + name + ".png"))
	print("SHOT %s window=%s ui=%s mode=%d" % [name, root.size, root.get_visible_rect().size, root.mode])


func _run() -> void:
	while current_scene == null or current_scene.get("hud") == null:
		await process_frame
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var main = current_scene
	var ds = main.display
	ds.apply_window = true
	ds.set_mode("windowed", false)
	ds.set_window_size(Vector2i(1600, 800), false)
	await _wait(0.6)
	main.grant_starter_cards(true)
	await _wait(5.0)  # 첫 실행은 셰이더 컴파일로 배분 연출이 늦다
	await _shot("1_windowed_1600x800")
	ds.set_mode("borderless", false)
	await _wait(1.5)
	await _shot("2_after_fullscreen")
	ds.set_mode("windowed", false)
	await _wait(0.4)
	quit()
