extends SceneTree
## 왼쪽 손님 말 걸기 알림(초상 메달 + 종이 말풍선 + 화살표, 시안 03) 실제 화면 캡처.
## 헤드리스로 확인할 수 없는 것: 둥글게 오린 초상의 실제 모습, 메달 테두리 호의 색, 꼬리와 몸통이 하나로 이어지는지,
## 눈밭 배경 위 말풍선 글의 대비.
## 실행(창 모드): .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_speech_notification.gd
## 결과: godot/screenshots/speech-notification/*.png (그라즈 · 가득 / 절반 / 1/4 아래)

const OUT := "res://screenshots/speech-notification/"
const GuestProfiles := preload("res://scripts/ui/guest_profiles.gd")
const Dialogues := preload("res://scripts/game/guest_dialogues.gd")
var game


func _initialize() -> void:
	# 첫 프레임의 셰이더 컴파일이 1분 넘게 걸릴 수 있어 넉넉히 기다린다
	create_timer(240.0, true, false, true).timeout.connect(func():
		print("TIMEOUT drawn=", Engine.get_frames_drawn(), " process=", Engine.get_process_frames(), " scene=", current_scene)
		quit(2))
	change_scene_to_file("res://scenes/main.tscn")
	_run.call_deferred()


func _wait(n: int) -> void:
	for i in n:
		await process_frame


func _shot(file: String) -> void:
	await _wait(6)  # 창이 가려져 frame_post_draw 가 오지 않을 수 있어 프레임 수로만 기다린다
	var err := root.get_viewport().get_texture().get_image().save_png(OUT + file + ".png")
	print("SHOT ", file, " err=", err)


func _run() -> void:
	while current_scene == null or current_scene.get("session") == null:
		await process_frame
	game = current_scene
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	root.size = Vector2i(1774, 887)
	await _wait(40)
	game.world.day_cycle.set_mode("day")
	# 실제 초대 묶음을 부르고, 알림이 머물 두 번째 손님을 그라즈로 바꾼다(시안의 인물).
	game.economy.invite_batch()
	await _wait(4)
	var visits: Array = game.guest_events.current_guests()
	if visits.size() < 2:
		print("FAIL no visits")
		quit(1)
		return
	var first: Dictionary = visits[visits.size() - 2]
	var second: Dictionary = visits[visits.size() - 1]
	var graz := GuestProfiles.character("graz")
	graz["character_id"] = "graz"
	graz["visit_uid"] = second.uid
	second.profile = graz
	second.story = Dialogues.story("graz")
	for e in [first, second]:
		game.guest_events.admit(e.profile)
	first.read = true
	second.ready = true
	second.read = false
	game.guest_arrival.finish()  # 손패 위 도착 소개는 끝낸 상태로 찍는다
	game.guest_events.changed.emit()
	for id in ["timber", "wool", "raw_meat", "old_spellbook"]:
		game.cards.add(id, 1)
	await create_timer(1.5, true, false, true).timeout
	for c in game.hud.toast_box.get_children(): c.queue_free()
	var ui = game.guest_ui
	await _wait(5)
	print("NOTIFICATION ", ui.notify_name.text, " | ", ui.notify_text.text, " | ratio=%.2f" % ui.notify_medal.ratio)
	await _shot("1-graz-full")
	ui.set_process(false)
	var r: Rect2 = ui.notification.get_global_rect()
	var img := root.get_viewport().get_texture().get_image()
	img = img.get_region(Rect2i(Vector2i(maxi(0, int(r.position.x) - 10), maxi(0, int(r.position.y) - 70)), Vector2i(int(r.size.x) + 40, int(r.size.y) + 80)))
	img.resize(img.get_width() * 2, img.get_height() * 2, Image.INTERPOLATE_LANCZOS)
	print("CROP err=", img.save_png(OUT + "2-graz-crop2x.png"))
	quit()
