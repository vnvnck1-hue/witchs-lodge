extends SceneTree

# Isolated image utility, never imports/runs the actual game project.
const IDS = ["crescent_moon", "half_moon", "full_moon"]
var task_root: String

func _initialize() -> void:
	task_root = ProjectSettings.globalize_path("res://../..").simplify_path()
	var sheet = Image.create(1024, 1392, false, Image.FORMAT_RGBA8)
	sheet.fill(Color("262033"))
	var hands = Image.create(800, 416, false, Image.FORMAT_RGBA8)
	hands.fill(Color("262033"))
	for i in range(IDS.size()):
		var id = IDS[i]
		var before = read_image("art/cards/wolf-blood-v02/previous/" + id + ".png")
		var after = read_image("output/wolf-blood-v02/" + id + "-round2-staged.png")
		var hand = after.duplicate()
		hand.resize(256, 384, Image.INTERPOLATE_LANCZOS)
		hand.save_png(task_root.path_join("output/wolf-blood-v02/" + id + "-hand-staged.png"))
		before.resize(320, 480, Image.INTERPOLATE_LANCZOS)
		after.resize(320, 480, Image.INTERPOLATE_LANCZOS)
		sheet.blit_rect(before, Rect2i(0, 0, 320, 480), Vector2i(16 + i * 336, 16))
		sheet.blit_rect(after, Rect2i(0, 0, 320, 480), Vector2i(16 + i * 336, 512))
		sheet.blit_rect(hand, Rect2i(0, 0, 256, 384), Vector2i(48 + i * 336, 1000))
		hands.blit_rect(hand, Rect2i(0, 0, 256, 384), Vector2i(8 + i * 264, 16))
	sheet.save_png(task_root.path_join("godot/screenshots/wolf-blood-cards/moon-v02-sheet.png"))
	hands.save_png(task_root.path_join("output/wolf-blood-v02/round2-hand-review.png"))
	print("Three RGBA 256x384 hand images and uncropped comparison sheets saved.")
	quit(0)

func read_image(p: String) -> Image:
	var im = Image.load_from_file(task_root.path_join(p))
	im.convert(Image.FORMAT_RGBA8)
	return im
