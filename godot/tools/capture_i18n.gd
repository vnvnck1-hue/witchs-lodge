extends SceneTree
## 영문판(F8 → English) 실제 화면 캡처: 타이틀·게임 시작·조금 진행한 화면·손님 대화·일시 정지. 창 필요.
## 헤드리스 더미 렌더러로는 글꼴 외형(Alegreya)과 글자 넘침을 볼 수 없어 창을 띄운다. 설정 파일은 건드리지 않는다.
## 실행(프로젝트 루트): .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_i18n.gd
const OUT := "res://screenshots/i18n/"


func _initialize() -> void:
	create_timer(120.0, true, false, true).timeout.connect(func() -> void: quit(2))
	call_deferred("_run")


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	await _shot("res://scenes/title.tscn", "title_en.png", 0)
	await _shot("res://scenes/main.tscn", "game_en.png", 0)
	# 낮(준비 시간)에 손님 대화창(영문 대사·선택지)과 일시 정지 메뉴
	var game = current_scene
	var profile: Dictionary = preload("res://scripts/ui/guest_profiles.gd").all_profiles()[0].duplicate(true)
	profile["character_id"] = profile["id"]
	game.guest_events._on_batch([profile])
	game.guest_events.admit(profile)
	game.guest_ui.open_conversation(int(profile["visit_uid"]))
	for i in 40:
		await process_frame
	game.guest_ui.advance_dialogue()
	for i in 40:
		await process_frame
	await _save("dialogue_en.png")
	game.guest_ui.close_conversation(false)
	game.hud._toggle_pause()
	for i in 20:
		await process_frame
	await _save("pause_en.png")
	game.hud._toggle_pause()
	# 같은 판을 시간만 빨리 돌려 손님·알림이 뜬 화면
	Engine.time_scale = 6.0
	for i in 900:
		await physics_frame
	Engine.time_scale = 1.0
	await _save("game_en_later.png")
	preload("res://scripts/ui/game_language.gd").apply(preload("res://scripts/ui/card_face.gd").language())
	quit(0)


func _shot(scene: String, file: String, extra: int) -> void:
	change_scene_to_file(scene)
	for i in 60:
		await physics_frame
	var cl = current_scene.get_node_or_null("CardLanguage")
	if cl != null:
		cl.set_language("en", false)
	for i in 40 + extra:
		await process_frame
	await _save(file)


func _save(file: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + file))
	print("SAVED ", OUT + file)
