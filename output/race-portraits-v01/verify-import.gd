extends SceneTree

const IDS = ["harald", "brynhild", "thorgrim", "durga", "ormu", "ketil", "signy", "thistle", "tilia", "larch", "fern", "willow", "pip", "nivel", "graz", "pikl", "rusk", "tak", "nib", "grik", "mala", "fargh", "saya", "urso", "momi", "luka", "tass", "selen", "garok", "kranya", "moga", "shaga", "ulma", "bardu", "eshka"]

func digest(bytes: PackedByteArray) -> String:
	var context = HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(bytes)
	return context.finish().hex_encode()

func _initialize() -> void:
	var records: Array = []
	var passed = true
	for id in IDS:
		var path = "res://assets/portraits/guest_%s_cutout.png" % id
		var texture = load(path) as Texture2D
		var record = {"id": id, "path": path, "import_descriptor_exists": FileAccess.file_exists(path + ".import"), "passed": false}
		if texture != null:
			var imported = texture.get_image()
			var source = Image.load_from_file(ProjectSettings.globalize_path(path))
			if imported != null and source != null:
				imported.convert(Image.FORMAT_RGBA8)
				source.convert(Image.FORMAT_RGBA8)
				record["width"] = imported.get_width()
				record["height"] = imported.get_height()
				record["imported_rgba_sha256"] = digest(imported.get_data())
				record["source_rgba_sha256"] = digest(source.get_data())
				# The default texture importer dilates RGB into fully transparent
				# border pixels to prevent filtering fringes. Reproduce that exact
				# engine transform before comparing; delivered PNGs stay untouched.
				source.fix_alpha_edges()
				record["expected_after_default_alpha_border_sha256"] = digest(source.get_data())
				record["passed"] = record["import_descriptor_exists"] and imported.get_width() == 1122 and imported.get_height() == 1402 and record["imported_rgba_sha256"] == record["expected_after_default_alpha_border_sha256"]
		passed = passed and record["passed"]
		records.append(record)
	var report = {"expected_count": 35, "actual_count": records.size(), "records": records, "passed": passed, "scope": "Godot imported texture decode and exact RGBA equality after reproducing the default process/fix_alpha_border=true transform on a decoded copy of the delivered PNG. Source PNG bytes stay untouched. No gameplay/UI claim."}
	var target = ProjectSettings.globalize_path("res://../output/race-portraits-v01/godot-import-verification.json")
	var file = FileAccess.open(target, FileAccess.WRITE)
	if file == null:
		push_error("Cannot write verification report: " + target)
		quit(2)
		return
	file.store_string(JSON.stringify(report, "\t"))
	file.close()
	print("RACE_PORTRAIT_IMPORT_VERIFIED count=", records.size(), " passed=", passed)
	quit(0 if passed else 1)
