extends SceneTree
## External script: inspect every shipped card in the exported pack.
## Args: absolute expected JSON, absolute result JSON. No gameplay is run.
func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 2:
		push_error("Expected manifest and report paths")
		quit(1)
		return
	var expected: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(args[0]))
	var catalog: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/cards/catalog.json"))
	var failures: Array[String] = []
	var checked: Array = []
	var catalog_matches: bool = FileAccess.get_sha256("res://assets/cards/catalog.json") == str(expected.get("catalog_sha256", ""))
	if not catalog_matches:
		failures.append("Exported catalogue differs from unchanged source catalogue")
	if catalog.get("cards", []).size() != 25:
		failures.append("Expected 25 active catalogue fronts")
	for entry in expected.assets:
		for key in ["full", "hand"]:
			var relative: String = entry[key].path
			var path := "res://" + relative.trim_prefix("godot/")
			var texture = load(path)
			if not texture is Texture2D:
				failures.append("Missing texture: " + path)
				continue
			var actual: Image = texture.get_image()
			if actual.is_compressed():
				actual.decompress()
			actual.convert(Image.FORMAT_RGBA8)
			# Ignore hidden RGB modified by Godot's alpha-border import.
			var pixels := actual.get_data()
			for offset in range(0, pixels.size(), 4):
				if pixels[offset + 3] < 244:
					for channel in 4:
						pixels[offset + channel] = 0
			var hash_context := HashingContext.new()
			hash_context.start(HashingContext.HASH_SHA256)
			hash_context.update(pixels)
			var actual_hash := hash_context.finish().hex_encode()
			var wanted: String = entry[key].opaque_pixel_sha256
			if actual_hash != wanted:
				failures.append("Pixel hash differs from new delivery: " + path)
			checked.append({"path":path, "pixel_sha256":actual_hash, "matches":actual_hash == wanted})
	if checked.size() != 54:
		failures.append("Expected 54 exported textures")
	var result := {"passed":failures.is_empty(), "texture_count":checked.size(), "catalog_matches":catalog_matches, "checked":checked, "failures":failures}
	FileAccess.open(args[1], FileAccess.WRITE).store_string(JSON.stringify(result, "  ") + "\n")
	for failure in failures:
		push_error(failure)
	print("ROLE_FORMAT_EXPORT ", checked.size(), "/54 textures; failures=", failures.size())
	quit(0 if failures.is_empty() else 1)
