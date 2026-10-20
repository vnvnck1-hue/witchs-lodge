extends SceneTree
## 손님 대화의 선택지 레이아웃 캡처. 실제 렌더러가 필요하다(헤드리스 더미 렌더러로는 배치·색·글 겹침을 볼 수 없다).
## 사용: Godot --path godot --script res://tools/capture_dialogue_choices.gd -- --out=res://screenshots/dialogue-choices/after
var game
var out := "res://screenshots/dialogue-choices/after/"
var size := Vector2i(1774, 887)

func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="): out = a.trim_prefix("--out=").trim_suffix("/") + "/"
		if a.begins_with("--size="):
			var p := a.trim_prefix("--size=").split("x")
			size = Vector2i(int(p[0]), int(p[1]))
	create_timer(120.0, true, false, true).timeout.connect(func(): push_error("capture timed out"); quit(2))
	call_deferred("run")

func frames(n := 5) -> void:
	for i in n: await process_frame

func seconds(t: float) -> void:
	await create_timer(t, true, false, true).timeout

func capture(id: String) -> void:
	await frames(5)
	await RenderingServer.frame_post_draw
	var error := root.get_texture().get_image().save_png(out + id + ".png")
	if error != OK: push_error("Capture failed: " + id); quit(1); return
	print("CAPTURE ", id)

func run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out))
	root.size = size
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
	for c in game.hud.toast_box.get_children(): c.queue_free()
	var uid: int = game.guest_events.visits[0].uid
	game.guest_ui.open_conversation(uid)
	await seconds(1.7)
	await capture("1-opening")
	game.guest_ui.advance_dialogue()
	await seconds(0.8)
	await capture("2-choices")
	game.guest_ui.choice_buttons[1].grab_focus()
	await seconds(0.4)
	await capture("3-choices-focus-2")
	game.guest_ui.choose(1)
	await seconds(0.8)
	await capture("4-reply")
	quit()
