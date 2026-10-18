extends SceneTree
## 승인 원화와 실제 손패 캡처를 같은 카드 배율로 나란히 렌더링한다.

var OUT := "res://../output/hand-workbench-runtime-v03/"

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			OUT = arg.trim_prefix("--out=").trim_suffix("/") + "/"
	run.call_deferred()

func run() -> void:
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	root.size = Vector2i(1640, 500)
	var review := Control.new()
	review.set_script(null)
	root.add_child(review)
	var bg := ColorRect.new()
	bg.color = Color8(24, 19, 35)
	bg.size = Vector2(1640, 500)
	review.add_child(bg)
	var approved: Texture2D = load("res://assets/ui/hand_workbench/approved/layout-v04.png")
	for row in 2:
		var y := 40 + row * 240
		var label := Label.new()
		label.text = "승인 원화 · %d장" % (3 if row == 0 else 8)
		label.position = Vector2(16, y - 32)
		review.add_child(label)
		var actual_label := Label.new()
		actual_label.text = "실제 게임 · %d장" % (3 if row == 0 else 8)
		actual_label.position = Vector2(836, y - 32)
		review.add_child(actual_label)
		var ref := RegionPic.new()
		ref.texture = approved
		ref.region = Rect2(0, 202 if row == 0 else 745, 1448, 341)
		ref.position = Vector2(16, y)
		ref.size = Vector2(796.4, 187.55)
		review.add_child(ref)
		var shot := ImageTexture.create_from_image(Image.load_from_file(OUT + ("01-hand-three.png" if row == 0 else "03-hand-eight.png")))
		var actual := RegionPic.new()
		actual.texture = shot
		actual.region = Rect2(400, 610, 800, 190)
		actual.position = Vector2(836, y)
		actual.size = Vector2(800, 190)
		review.add_child(actual)
	for i in 6:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT + "approved-vs-game.png")
	quit()

class RegionPic extends Control:
	var texture: Texture2D
	var region: Rect2
	func _draw() -> void:
		draw_texture_rect_region(texture, Rect2(Vector2.ZERO, size), region)
