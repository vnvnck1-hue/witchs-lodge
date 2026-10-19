extends SceneTree

func _initialize() -> void:
	var checks: Array = []
	var passed := true
	for id in ["scrap", "junk_sack"]:
		for part in ["", "hand/"]:
			var path: String = "res://assets/cards/" + part + id + ".png"
			var expected := Vector2i(256, 384) if part != "" else Vector2i(1024, 1536)
			var texture := load(path) as Texture2D
			var ok := texture != null and texture.get_size() == Vector2(expected)
			var alpha: Array = []
			if ok:
				var image := texture.get_image()
				ok = image != null and image.get_size() == expected
				if ok:
					for point in [Vector2i.ZERO, Vector2i(expected.x - 1, 0), Vector2i(0, expected.y - 1), expected - Vector2i.ONE]:
						alpha.append(image.get_pixelv(point).a)
					ok = alpha.all(func(a): return a == 0.0) and image.get_pixelv(expected / 2).a == 1.0
			checks.append({"path": path, "expected_size": [expected.x, expected.y], "corner_alpha": alpha, "passed": ok})
			print(("PASS " if ok else "FAIL ") + path)
			passed = passed and ok
	var result := {"passed": passed, "checks": checks}
	var file := FileAccess.open("res://../output/scrap-rename-v01/texture-verification.json", FileAccess.WRITE)
	if file == null:
		printerr("Cannot write texture verification result")
		quit(1)
		return
	file.store_string(JSON.stringify(result, "  ") + "\n")
	file.close()
	print("RESULT %s/4" % checks.filter(func(check): return check.passed).size())
	quit(0 if passed else 1)
