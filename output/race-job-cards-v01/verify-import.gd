extends SceneTree

func _initialize() -> void:
	var races := ["dwarf", "fairy", "goblin", "beastfolk", "orc"]
	var jobs := ["warrior", "hunter", "lumberjack", "gatherer"]
	var records: Array = []
	var all_passed := true
	for race in races:
		for job in jobs:
			for hand in [false, true]:
				var path: String = "res://assets/cards/races/%s/%s%s.png" % [race, "hand/" if hand else "", job]
				var texture := load(path) as Texture2D
				var image := texture.get_image() if texture != null else null
				var source := Image.load_from_file(path)
				var expected_size := Vector2i(256, 384) if hand else Vector2i(1024, 1536)
				var passed := image != null and source != null
				var actual_sha := ""
				var expected_sha := ""
				if passed:
					image.convert(Image.FORMAT_RGBA8)
					source.convert(Image.FORMAT_RGBA8)
					source.fix_alpha_edges()
					actual_sha = hash_bytes(image.get_data())
					expected_sha = hash_bytes(source.get_data())
					passed = image.get_size() == expected_size and actual_sha == expected_sha
				records.append({"path": path, "expected_size": [expected_size.x, expected_size.y], "source_png_sha256": hash_bytes(FileAccess.get_file_as_bytes(path)), "imported_rgba_sha256": actual_sha, "source_with_fix_alpha_edges_sha256": expected_sha, "passed": passed})
				all_passed = all_passed and passed
				print("%s %s" % ["PASS" if passed else "FAIL", path])
	var report := {"count": records.size(), "records": records, "passed": all_passed}
	var file := FileAccess.open("res://../godot-import-verification.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t"))
	file.close()
	print("RESULT %d/40" % records.filter(func(r): return r.passed).size())
	quit(0 if all_passed else 1)

func hash_bytes(data: PackedByteArray) -> String:
	var ctx := HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	ctx.update(data)
	return ctx.finish().hex_encode()
