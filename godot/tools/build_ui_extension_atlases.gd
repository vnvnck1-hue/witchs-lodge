extends SceneTree
## Create AtlasTexture resources; generated RGBA PNG pixels are kept untouched.
const DIR := "res://assets/ui/moon_runes/extension_v01/"
var records: Array = []
func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(DIR + "textures"))
	var header_ids := ["header", "victory_header", "defeat_header", "paper_header"]
	for i in 4: make("headers", header_ids[i], Rect2i((i % 2) * 1086, (i / 2) * 362, 1086, 362))
	var icons := ["extension", "pasture", "graves", "sheep", "repair", "heal", "scissors", "hourglass", "book", "quill", "envelope", "footsteps", "paw", "check", "warning", "arrow"]
	var xs := [0, 333, 630, 940, 1254]
	var ys := [0, 445, 720, 1003, 1254]
	for i in 16:
		var x: int = i % 4
		var y: int = i / 4
		make("icons", icons[i], Rect2i(xs[x], ys[y], xs[x + 1] - xs[x], ys[y + 1] - ys[y]))
	var widgets := [
		["bar_track", Rect2i(0, 80, 326, 230)], ["bar_fill", Rect2i(326, 80, 304, 230)],
		["speech", Rect2i(630, 80, 310, 230)], ["person", Rect2i(940, 80, 314, 230)],
		["action", Rect2i(0, 370, 410, 240)], ["relic", Rect2i(410, 370, 240, 240)],
		["badge", Rect2i(680, 370, 220, 240)], ["toast", Rect2i(900, 370, 354, 240)],
		["button_normal", Rect2i(0, 690, 321, 210)], ["button_hover", Rect2i(321, 690, 310, 210)],
		["button_pressed", Rect2i(631, 690, 307, 210)], ["button_disabled", Rect2i(938, 690, 316, 210)],
		["toggle_on", Rect2i(0, 960, 325, 260)], ["toggle_off", Rect2i(325, 960, 325, 260)],
		["close", Rect2i(680, 960, 230, 260)], ["plus", Rect2i(990, 960, 240, 260)],
	]
	for pair in widgets: make("widgets", pair[0], pair[1])
	var scroll_img := Image.load_from_file(ProjectSettings.globalize_path(DIR + "scrollbars.png"))
	var half := scroll_img.get_width() / 2
	make("scrollbars", "scroll_vertical_track", Rect2i(0, 0, half, scroll_img.get_height()))
	make("scrollbars", "scroll_vertical_thumb", Rect2i(half, 0, half, scroll_img.get_height()))
	var file := FileAccess.open(DIR + "atlas-regions.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(records, "\t"))
	print("UI_ATLAS PASS resources=", records.size())
	quit()
func make(sheet: String, id: String, cell: Rect2i) -> void:
	var path := DIR + sheet + ".png"
	var img := Image.load_from_file(ProjectSettings.globalize_path(path))
	# Near-transparent export dust must not become layout padding.
	var part := img.get_region(cell)
	var low := part.get_size()
	var high := Vector2i(-1, -1)
	for y in part.get_height():
		for x in part.get_width():
			if part.get_pixel(x, y).a >= 0.25:
				low = low.min(Vector2i(x, y))
				high = high.max(Vector2i(x, y))
	var used := Rect2i(low, high - low + Vector2i.ONE).grow(2).intersection(Rect2i(Vector2i.ZERO, cell.size))
	assert(used.size.x > 0 and used.size.y > 0, id + " empty atlas region")
	var region := Rect2(cell.position + used.position, used.size)
	var texture := AtlasTexture.new()
	texture.atlas = load(path)
	texture.region = region
	texture.filter_clip = true
	assert(ResourceSaver.save(texture, DIR + "textures/" + id + ".tres") == OK)
	records.append({"id": id, "sheet": sheet, "region": [region.position.x, region.position.y, region.size.x, region.size.y]})
