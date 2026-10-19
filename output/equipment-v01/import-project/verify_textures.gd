extends SceneTree

func pixel_digest(im: Image) -> String:
	im.convert(Image.FORMAT_RGBA8)
	var bytes := im.get_data()
	# Alpha-edge RGB padding can be changed by Godot's importer.
	for i in range(0, bytes.size(), 4):
		if bytes[i + 3] < 244:
			bytes[i] = 0
			bytes[i + 1] = 0
			bytes[i + 2] = 0
	var ctx := HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	ctx.update(bytes)
	return ctx.finish().hex_encode()

func _initialize() -> void:
	var ids := ["rusty_longsword", "oak_staff", "quilted_gambeson", "traveler_boots", "rowan_charm"]
	var files: Array = []
	for id in ids:
		files.append({"path": "res://assets/cards/%s.png" % id, "width": 1024, "height": 1536})
		files.append({"path": "res://assets/cards/hand/%s.png" % id, "width": 256, "height": 384})
	var passed := true
	for entry in files:
		var tex := load(entry.path) as Texture2D
		var ok := tex != null
		if ok:
			var im := tex.get_image()
			var original := Image.load_from_file(entry.path)
			ok = tex.get_width() == entry.width and tex.get_height() == entry.height
			ok = ok and im.get_pixel(0, 0).a == 0.0 and im.get_pixel(entry.width - 1, 0).a == 0.0
			ok = ok and im.get_pixel(0, entry.height - 1).a == 0.0 and im.get_pixel(entry.width - 1, entry.height - 1).a == 0.0
			ok = ok and im.get_pixel(entry.width / 2, entry.height / 2).a == 1.0
			entry["source_pixel_sha256"] = pixel_digest(original)
			entry["imported_pixel_sha256"] = pixel_digest(im)
			ok = ok and entry.source_pixel_sha256 == entry.imported_pixel_sha256
		entry["passed"] = ok
		passed = passed and ok
		print(("PASS " if ok else "FAIL ") + entry.path)
	var f := FileAccess.open("res://texture-verification.json", FileAccess.WRITE)
	f.store_string(JSON.stringify({"passed": passed, "textures": files}, "\t"))
	f.close()
	print("RESULT %s/10" % files.filter(func(e): return e.passed).size())
	quit(0 if passed else 1)
