extends SceneTree
## Normalize generated PNGs for shipping; keep their generated alpha and artwork.
## No painting, colour replacement, corner masking or content generation here.

const IDS := ["axe_mercenary", "wool", "timber", "forest_monster", "frost_rune", "ward_lantern", "guest_invitation", "lamb", "card_back"]

func _initialize() -> void:
	var source_dir := ProjectSettings.globalize_path("res://../art/cards/rounded")
	var output_dir := ProjectSettings.globalize_path("res://assets/cards")
	DirAccess.make_dir_recursive_absolute(output_dir.path_join("hand"))
	var report: Array = []
	for id in IDS:
		var source := source_dir.path_join(id + ".png")
		var image := Image.load_from_file(source)
		if image == null or image.is_empty() or not image.detect_alpha():
			push_error("Missing transparent image: " + source)
			quit(1)
			return
		image.convert(Image.FORMAT_RGBA8)
		var bounds := _card_bounds(image)
		if bounds.size == Vector2i.ZERO:
			push_error("No opaque card body: " + source)
			quit(1)
			return
		var aspect := float(bounds.size.x) / bounds.size.y
		if absf(aspect - 2.0 / 3.0) > 0.025:
			push_error("Unexpected card aspect: " + source + " " + str(bounds))
			quit(1)
			return
		# Remove the transparent outside margin, then standardize the same card size.
		image = image.get_region(bounds)
		image.convert(Image.FORMAT_RGBA8)
		image.resize(1024, 1536, Image.INTERPOLATE_LANCZOS)
		if image.save_png(output_dir.path_join(id + ".png")) != OK:
			quit(1)
			return
		var small: Image = image.duplicate()
		small.resize(256, 384, Image.INTERPOLATE_LANCZOS)
		if small.save_png(output_dir.path_join("hand").path_join(id + ".png")) != OK:
			quit(1)
			return
		report.append({"id": id, "source_bounds": [bounds.position.x, bounds.position.y, bounds.size.x, bounds.size.y], "full": [1024, 1536], "hand": [256, 384]})
	var file := FileAccess.open(output_dir.path_join("packaging.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t") + "\n")
	print("CARD_PACKAGING ", JSON.stringify(report))
	quit()

func _card_bounds(image: Image) -> Rect2i:
	# Ignore stray near-zero alpha pixels when locating the actual card body.
	# This changes crop coordinates only; generated alpha pixels are not masked.
	var pixels := image.get_data()
	var width := image.get_width()
	var height := image.get_height()
	var left := width
	var right := -1
	var top := height
	var bottom := -1
	for y in height:
		for x in width:
			if pixels[(y * width + x) * 4 + 3] >= 230:
				left = mini(left, x)
				right = maxi(right, x)
				top = mini(top, y)
				bottom = maxi(bottom, y)
	if right < left:
		return Rect2i()
	return Rect2i(left, top, right - left + 1, bottom - top + 1)
