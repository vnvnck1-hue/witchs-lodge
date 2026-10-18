extends SceneTree
## 실제 렌더러에서 기본/최대 손패, 확대, 화면 비율을 검토하는 캡처 도구.

var game
var out := "res://../output/hand-workbench-runtime-v04/"
var snapshots: Dictionary = {}


func _initialize() -> void:
	print("WORKBENCH_CAPTURE initialize")
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out = arg.trim_prefix("--out=").trim_suffix("/") + "/"
	create_timer(300.0, true, false, true).timeout.connect(func(): quit(2))
	change_scene_to_file("res://scenes/main.tscn")
	run.call_deferred()


func frames(count: int) -> void:
	for i in count:
		await process_frame


func shot(id: String) -> void:
	await frames(30)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(out + id + ".png")
	if id == "06-hand-three-ultrawide":
		root.get_texture().get_image().get_region(Rect2i(1000,1098,1440,342)).save_png(out + "06-props-detail.png")
	var decor: Control = game.hud.moon.get_node("HandWorkbench")
	var bounds: Dictionary = {}
	for pic in decor.pieces:
		var r: Rect2 = pic.get_global_rect()
		bounds[pic.name] = [r.position.x, r.position.y, r.size.x, r.size.y]
	snapshots[id] = {"hand_count": game.cards.hand().size(), "props": bounds,
		"cards_drawn_after_props": game.hud.card_hand.get_index() > game.hud.moon.get_index()}
	print("WORKBENCH_CAPTURE ", id)


func run() -> void:
	while current_scene == null or current_scene.get("cards") == null:
		await process_frame
	game = current_scene
	print("WORKBENCH_CAPTURE scene ready")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out))
	root.size = Vector2i(1600, 800)
	await frames(30)
	print("WORKBENCH_CAPTURE granting starter cards")
	game.session.set_process(false)
	game.grant_starter_cards(false)
	await frames(100)
	await shot("01-hand-three")
	var hand = game.hud.card_hand
	var entries: Array = game.cards.hand()
	hand.set_hover(entries[0].uid, true)
	await shot("02-hand-hover")
	hand.set_hover(entries[0].uid, false)
	for id in ["timber", "wool", "raw_meat", "rabbit_pelt", "treasure_chest"]:
		game.cards.add(id)
	await frames(100)
	await shot("03-hand-eight")
	hand.set_hover(game.cards.hand()[7].uid, true)
	await shot("03b-hand-eight-hover")
	hand.set_hover(game.cards.hand()[7].uid, false)
	hand.begin_drag(game.cards.hand()[0].uid)
	hand.drag_pos = Vector2(790, 480)
	await shot("03c-hand-drag")
	hand._cancel_drag()
	root.size = Vector2i(1280, 720)
	await shot("04-hand-1280x720")
	root.size = Vector2i(3440, 1440)
	await shot("05-hand-ultrawide")
	while game.cards.hand().size() > 3:
		var removed_uid: int = game.cards.hand().back().uid
		game.cards.entries = game.cards.entries.filter(func(e): return e.uid != removed_uid)
	game.cards.changed.emit()
	await frames(100)
	await shot("06-hand-three-ultrawide")
	var report := FileAccess.open(out + "layout-snapshots.json", FileAccess.WRITE)
	report.store_string(JSON.stringify(snapshots, "\t"))
	quit(0)
