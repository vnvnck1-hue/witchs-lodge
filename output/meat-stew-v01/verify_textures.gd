extends SceneTree

func _init() -> void:
	var entries: Array = []
	var passed := true
	for spec in [["res://assets/cards/meat_stew.png", 1024, 1536], ["res://assets/cards/hand/meat_stew.png", 256, 384]]:
		var texture = load(spec[0]) as Texture2D
		var ok := texture != null
		var corner_alpha: Array = []
		if ok:
			var img: Image = texture.get_image()
			if img.is_compressed():
				img.decompress()
			ok = img.get_width() == spec[1] and img.get_height() == spec[2]
			for xy in [Vector2i(0, 0), Vector2i(spec[1] - 1, 0), Vector2i(0, spec[2] - 1), Vector2i(spec[1] - 1, spec[2] - 1)]:
				var alpha := img.get_pixelv(xy).a
				corner_alpha.append(alpha)
				ok = ok and is_zero_approx(alpha)
			ok = ok and is_equal_approx(img.get_pixel(spec[1] / 2, spec[2] / 2).a, 1.0)
		entries.append({"path": spec[0], "expected_width": spec[1], "expected_height": spec[2], "corner_alpha": corner_alpha, "passed": ok})
		passed = passed and ok
		print(("PASS " if ok else "FAIL ") + spec[0])
	var args := OS.get_cmdline_user_args()
	var f := FileAccess.open(args[0], FileAccess.WRITE)
	f.store_string(JSON.stringify({"files": entries, "passed": passed}, "  ") + "\n")
	f.close()
	print("RESULT %d/2" % (2 if passed else 0))
	quit(0 if passed else 1)
