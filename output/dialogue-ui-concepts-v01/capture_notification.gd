extends SceneTree
var game
const OUT := "C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/output/dialogue-ui-concepts-v01/captures/"

func _initialize() -> void:
	create_timer(100.0, true, false, true).timeout.connect(func(): quit(2))
	call_deferred("run")

func frames(n: int) -> void:
	for i in n: await process_frame

func shot(id: String) -> void:
	await RenderingServer.frame_post_draw
	var result := root.get_texture().get_image().save_png(OUT + id + ".png")
	print("CAPTURE ", id, " result=", result)

func run() -> void:
	root.size = Vector2i(1774, 887)
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await frames(16)
	game.session.set_process(false)
	game.world.day_cycle.set_mode("day")
	game.economy.update_prep(5.1)
	for entry in game.guest_events.visits:
		game.guest_events.admit(entry.profile)
		entry.ready = true
	game.guest_arrival.finish()
	game.guest_events.changed.emit()
	for id in ["timber", "wool", "raw_meat", "old_spellbook"]:
		game.cards.add(id, 1)
	await create_timer(2.5, true, false, true).timeout
	for c in game.hud.toast_box.get_children(): c.queue_free()
	await frames(5)
	print("NOTIFICATION ", game.guest_ui.notify_name.text, " | ", game.guest_ui.notify_text.text)
	await shot("5-notification-current")
	game.guest_ui.notification.visible = false
	game.guest_ui.set_process(false)
	await frames(3)
	await shot("6-notification-cleanplate")
	quit()
