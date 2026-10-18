extends SceneTree

func _initialize() -> void:
	var ids := ["wolf_blood", "crescent_moon", "half_moon", "full_moon"]
	var files: Array = []
	for id in ids:
		files.append({"path": "res://assets/cards/%s.png" % id, "width": 1024, "height": 1536})
		files.append({"path": "res://assets/cards/hand/%s.png" % id, "width": 256, "height": 384})
	for id in ["wolf_claw", "wolf_pounce"]:
		files.append({"path": "res://assets/ui/skills/%s.png" % id, "width": 128, "height": 128})
	var passed := true
	for entry in files:
		var tex := load(entry.path) as Texture2D
		var ok := tex != null
		if ok:
			var im := tex.get_image()
			ok = tex.get_width() == entry.width and tex.get_height() == entry.height and im.get_pixel(0, 0).a == 0.0 and im.get_pixel(entry.width - 1, entry.height - 1).a == 0.0 and im.get_pixel(entry.width / 2, entry.height / 2).a == 1.0
		entry["passed"] = ok
		passed = passed and ok
		print(("PASS " if ok else "FAIL ") + entry.path)
	var report := {"passed": passed, "textures": files}
	var f := FileAccess.open("res://texture-verification.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(report, "\t"))
	f.close()
	print("RESULT %s/10" % files.filter(func(e): return e.passed).size())
	quit(0 if passed else 1)
