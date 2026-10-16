extends SceneTree
## 마녀의 주머니 갤러리 캡처(검토용): 넓게 펼친 카드, 마우스를 올린 카드의 확대·들어 올림·어둠, 툴팁 배치.
## 헤드리스로는 화면 결과(어둠 블렌딩·그림자·툴팁 외형)를 볼 수 없어 실제 창에서 프레임을 저장한다.
## 실행(프로젝트 루트): .tools/Godot-4.7.2.exe --fixed-fps 60 --position -6000,-6000 --path godot --script res://tools/capture_pocket_gallery.gd -- --out=godot/screenshots/pocket-gallery/

var game
var out_dir := ""
var frame_no := 0


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			out_dir = a.trim_prefix("--out=").trim_suffix("/") + "/"
	create_timer(90.0, true, false, true).timeout.connect(func(): quit(2))
	change_scene_to_file("res://scenes/main.tscn")
	call_deferred("_run")


func shot(label: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(out_dir + "%02d-%s.png" % [frame_no, label])
	print("SHOT ", frame_no, " ", label)
	frame_no += 1


func wait_frames(n: int) -> void:
	for i in n:
		await process_frame


func _run() -> void:
	while current_scene == null or current_scene.get("cards") == null or current_scene.get("hud") == null:
		await process_frame
	game = current_scene
	await wait_frames(20)
	var mul = game.mulligan_ui
	if mul != null and mul.active:
		while mul._phase != "pick":
			await process_frame
		mul.confirm()
		while mul.active:
			await process_frame
	game.cards.entries.clear()
	game.cards.in_play.clear()
	game.cards.discard.clear()
	game.cards.last_drawn.clear()
	for id in ["frost_rune", "ward_lantern", "timber", "raw_meat", "wool", "rabbit_pelt", "treasure_chest", "old_spellbook", "poison_mushroom", "guest_invitation", "lamb", "forest_monster", "sleeping_thorn_seed", "axe_mercenary", "black_sheep"]:
		game.cards.add(id, 1 if id != "timber" else 4)
	game.cards.changed.emit()
	await wait_frames(4)
	var hand = game.hud.card_hand
	var gal = hand.pocket_gallery
	hand.open_pocket()
	await wait_frames(6)
	await shot("gallery-open")
	gal.hover_index(1)
	await wait_frames(3)
	await shot("hover-rising")
	await wait_frames(40)
	await shot("hover-lifted")
	gal.hover_index(gal.tiles.size() - 1)
	await wait_frames(40)
	await shot("hover-last-card")
	gal.hover_index(-1)
	await wait_frames(30)
	await shot("hover-released")
	hand.close_pocket()
	await wait_frames(2)
	quit(0)
