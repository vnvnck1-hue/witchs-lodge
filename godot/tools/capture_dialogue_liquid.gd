extends SceneTree
## 대답 버튼의 액체 일렁임이 시간에 따라 어떻게 흐르는지 연속 캡처한다(1.5초 간격 4장, 버튼 영역만).
## 실제 렌더러가 필요하다: 셰이더 윤곽·농담이 움직이는 모양은 헤드리스 더미 렌더러로 볼 수 없다.
## 사용: Godot --path godot --script res://tools/capture_dialogue_liquid.gd
var game
var out := "res://screenshots/dialogue-choices/liquid-flow/"

func _initialize() -> void:
	create_timer(120.0, true, false, true).timeout.connect(func(): push_error("capture timed out"); quit(2))
	call_deferred("run")

func frames(n := 5) -> void:
	for i in n: await process_frame

func run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out))
	root.size = Vector2i(1774, 887)
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await frames(12)
	game.session.set_process(false)
	game.world.day_cycle.set_mode("day")
	game.economy.update_prep(5.1)
	for entry in game.guest_events.visits:
		game.guest_events.admit(entry.profile)
		entry.ready = true
	game.guest_arrival.finish()
	game.guest_events.changed.emit()
	await frames()
	game.guest_ui.open_conversation(game.guest_events.visits[0].uid)
	await create_timer(1.7, true, false, true).timeout
	game.guest_ui.advance_dialogue()
	await create_timer(0.8, true, false, true).timeout
	game.guest_ui.choice_buttons[1].grab_focus()
	var area := Rect2i()
	for i in 4:
		await create_timer(1.5 if i > 0 else 0.4, true, false, true).timeout
		await frames(2)
		await RenderingServer.frame_post_draw
		var r: Rect2 = game.guest_ui.choices.get_global_rect().grow(30)
		if i == 0: area = Rect2i(r)
		var image := root.get_texture().get_image().get_region(area)
		image.save_png(out + "t%d.png" % i)
		print("CAPTURE t%d" % i)
	quit()
