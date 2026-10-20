extends SceneTree
## 대화 중 얻은 카드 보여 주기(card_spotlight.gd) 캡처. 실제 렌더러가 필요하다(헤드리스로는 카드가 대화 막·패널 위에 밝게 보이는지 볼 수 없다).
## 사용: Godot --path godot --script res://tools/capture_dialogue_card_spotlight.gd
var game
var out := "res://screenshots/dialogue-card-spotlight/"

func _initialize() -> void:
	create_timer(120.0, true, false, true).timeout.connect(func(): push_error("capture timed out"); quit(2))
	call_deferred("run")

func frames(n := 5) -> void:
	for i in n: await process_frame

func seconds(t: float) -> void:
	await create_timer(t, true, false, true).timeout

func capture(id: String) -> void:
	await frames(3)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(out + id + ".png")
	print("CAPTURE ", id)

func mouse(at: Vector2) -> void:
	var m := InputEventMouseMotion.new()
	m.position = at
	m.global_position = at
	root.push_input(m, true)

func run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out))
	root.size = Vector2i(1774, 887)
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await frames(12)
	game.session.set_process(false)
	game.world.day_cycle.set_mode("day")
	game.economy.update_prep(5.1)
	for id in ["timber", "wool", "raw_meat"]: game.cards.add(id, 2)
	for entry in game.guest_events.visits:
		game.guest_events.admit(entry.profile)
		entry.ready = true
	game.guest_arrival.finish()
	game.guest_events.changed.emit()
	await seconds(2.0)
	for c in game.hud.toast_box.get_children(): c.queue_free()
	var ui = game.guest_ui
	ui.open_conversation(game.guest_events.visits[0].uid)
	await seconds(1.5)
	ui.advance_dialogue()
	await seconds(0.6)
	ui.choose(0)
	await seconds(0.5)
	game.cards.add("old_spellbook", 1)
	await seconds(0.22)
	await capture("1-entering")
	await seconds(1.2)
	for c in game.hud.toast_box.get_children(): c.queue_free()
	await capture("2-held")
	var spot = game.hud.card_hand.spotlight
	mouse(spot.items[0]["rect"].get_center())
	await seconds(0.5)
	await capture("3-hover-tooltip")
	mouse(Vector2(30, 30))
	game.cards.add("timber", 1)
	await seconds(1.0)
	await capture("4-two-cards")
	ui.advance_dialogue()
	await seconds(0.6)
	ui.advance_dialogue()
	await seconds(0.3)
	await capture("5-flying-to-hand")
	await seconds(0.5)
	await capture("6-arrived-dimming")
	await seconds(1.4)
	await capture("7-in-hand")
	quit()
