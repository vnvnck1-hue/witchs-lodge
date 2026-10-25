extends SceneTree

# Asset-only staging. Never writes game assets unless --apply is explicit.
const IDS = ["crescent_moon", "half_moon", "full_moon"]
const VERTICES = {
	"crescent_moon": [Vector2(512, 302), Vector2(883, 677), Vector2(512, 1063), Vector2(142, 677)],
	"half_moon": [Vector2(512, 317), Vector2(879, 692), Vector2(510, 1084), Vector2(143, 692)],
	"full_moon": [Vector2(512, 324), Vector2(883, 698), Vector2(511, 1073), Vector2(139, 698)],
}
var task_root: String

func _initialize() -> void:
	task_root = ProjectSettings.globalize_path("res://../..").simplify_path()
	var apply_game = "--apply" in OS.get_cmdline_user_args()
	var records = []
	var sheet = Image.create(1024, 1360, false, Image.FORMAT_RGBA8)
	sheet.fill(Color("262033"))
	for i in range(IDS.size()):
		var id = IDS[i]
		var original = load_rgba("art/cards/wolf-blood-v02/previous/" + id + ".png")
		var generated = load_rgba("art/cards/wolf-blood-v02/drafts/" + id + "-selected.png")
		if generated.get_size() != original.get_size():
			generated.resize(original.get_width(), original.get_height(), Image.INTERPOLATE_LANCZOS)
		var composed = original.duplicate()
		var mask = Image.create(1024, 1536, false, Image.FORMAT_RGBA8)
		mask.fill(Color(0, 0, 0, 1))
		var vertices = VERTICES[id]
		var inside_pixels = 0
		for y in range(ceil(vertices[0].y), floor(vertices[2].y) + 1):
			var upper = y <= vertices[1].y
			var start = vertices[0] if upper else vertices[2]
			var left_t = float(y - start.y) / (vertices[3].y - start.y)
			var right_t = float(y - start.y) / (vertices[1].y - start.y)
			var lx = lerpf(start.x, vertices[3].x, left_t)
			var rx = lerpf(start.x, vertices[1].x, right_t)
			var left = int(ceil(lx))
			var right = int(floor(rx))
			# Tighten around actual visible black inner border; keep its pixels intact.
			for x in range(max(0, left - 5), min(left + 8, 1024)):
				if is_border(original.get_pixel(x, y)):
					left = max(left, x + 1)
			for x in range(max(0, right - 7), min(right + 6, 1024)):
				if is_border(original.get_pixel(x, y)):
					right = min(right, x - 1)
			for x in range(left, right + 1):
				var paint = generated.get_pixel(x, y)
				paint.a = original.get_pixel(x, y).a
				composed.set_pixel(x, y, paint)
				mask.set_pixel(x, y, Color.WHITE)
				inside_pixels += 1
		var out_path = "art/cards/wolf-blood-v02/" + id + ".png"
		composed.save_png(task_root.path_join(out_path))
		mask.save_png(task_root.path_join("output/wolf-blood-v02/" + id + "-window-mask.png"))
		var hand = composed.duplicate()
		hand.resize(256, 384, Image.INTERPOLATE_LANCZOS)
		hand.save_png(task_root.path_join("output/wolf-blood-v02/" + id + "-hand-staged.png"))
		if apply_game:
			composed.save_png(task_root.path_join("godot/assets/cards/" + id + ".png"))
			hand.save_png(task_root.path_join("godot/assets/cards/hand/" + id + ".png"))
		var outside_diff = 0
		var inside_diff = 0
		var alpha_diff = 0
		var max_delta = 0
		for y in range(1536):
			for x in range(1024):
				var a = original.get_pixel(x, y)
				var b = composed.get_pixel(x, y)
				if a.a != b.a:
					alpha_diff += 1
				if a != b:
					if mask.get_pixel(x, y).r > 0.5:
						inside_diff += 1
					else:
						outside_diff += 1
						max_delta = max(max_delta, int(round(255 * max(abs(a.r-b.r), abs(a.g-b.g), abs(a.b-b.b), abs(a.a-b.a)))))
		var corners = [composed.get_pixel(0,0).a, composed.get_pixel(1023,0).a, composed.get_pixel(0,1535).a, composed.get_pixel(1023,1535).a]
		records.append({"id": id, "path": out_path, "size": [1024,1536], "channels": "RGBA", "corner_alpha": corners, "window_mask_pixels": inside_pixels, "inside_changed_pixels": inside_diff, "outside_changed_pixels": outside_diff, "outside_max_channel_delta": max_delta, "alpha_changed_pixels": alpha_diff, "sha256": FileAccess.get_sha256(task_root.path_join(out_path)), "pixel_preservation_passed": outside_diff == 0 and alpha_diff == 0, "hand_staged_sha256": FileAccess.get_sha256(task_root.path_join("output/wolf-blood-v02/" + id + "-hand-staged.png"))})
		var old_thumb = original.duplicate()
		old_thumb.resize(320,480,Image.INTERPOLATE_LANCZOS)
		var new_thumb = composed.duplicate()
		new_thumb.resize(320,480,Image.INTERPOLATE_LANCZOS)
		sheet.blit_rect(old_thumb, Rect2i(0,0,320,480), Vector2i(16+i*336,16))
		sheet.blit_rect(new_thumb, Rect2i(0,0,320,480), Vector2i(16+i*336,512))
		sheet.blit_rect(hand, Rect2i(0,0,256,384), Vector2i(48+i*336,992))
		print(id + ": outside_changed_pixels=" + str(outside_diff) + ", alpha_changed_pixels=" + str(alpha_diff))
	var report = {"date": "2026-10-23", "method": "image_gen edit followed by original-pixel diamond-mask composite; Godot RGBA8 and Lanczos downsample", "applied_to_game": apply_game, "passed": false, "status": "staged; visual scope conflict awaits user clarification", "files": records}
	FileAccess.open(task_root.path_join("output/wolf-blood-v02/verification-staged.json"), FileAccess.WRITE).store_string(JSON.stringify(report, "\t"))
	sheet.save_png(task_root.path_join("output/wolf-blood-v02/strict-scope-review.png"))
	quit(0)

func is_border(c: Color) -> bool:
	return max(c.r, c.g, c.b) < 0.105

func load_rgba(path: String) -> Image:
	var im = Image.load_from_file(task_root.path_join(path))
	im.convert(Image.FORMAT_RGBA8)
	return im
