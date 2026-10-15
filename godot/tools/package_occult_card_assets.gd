extends SceneTree
## Asset-only export. Preserve generated pixels/alpha; resize without painting.

const CARDS := {
	"sleeping_thorn_seed": ["잠자는 가시 씨앗", "식물 · 살아 있는 방책", "낮에 심으면 천천히 자랍니다.", "밤이 되면 가시로 적을 막습니다."],
	"black_sheep": ["목장의 검은 양", "가축 · 기묘한 양", "목장에 놓으면 검은 양이 옵니다.", "의식에 쓰는 검은 털을 얻습니다."],
	"black_wool": ["검은 털", "재료 · 의식의 공물", "가시 씨앗에 바치면 힘을 얻습니다.", "가시 방책을 강화하고 회복합니다."]
}

func _initialize() -> void:
	var report := {"schema_version": 1, "generator": "built-in image_gen", "date": "2026-10-15", "scope": "Three card assets; runtime integration documented in docs/occult-cards-runtime.md.", "prompt_set": "docs/prompts/cards/occult-cards-v01-prompts.md", "cards": [], "failures": []}
	for id in CARDS:
		var source := "res://../art/cards/rounded/%s.png" % id
		var image := Image.load_from_file(source)
		if image == null or image.is_empty():
			report.failures.append("Missing source: " + id)
			continue
		image.convert(Image.FORMAT_RGBA8)
		if image.get_size() != Vector2i(1024, 1536):
			report.failures.append("Unexpected source size: " + id)
			continue
		var paths := [source, "res://assets/cards/%s.png" % id, "res://assets/cards/hand/%s.png" % id]
		if image.save_png(paths[1]) != OK:
			report.failures.append("Full export failed: " + id)
		var hand: Image = image.duplicate()
		hand.resize(256, 384, Image.INTERPOLATE_LANCZOS)
		if hand.save_png(paths[2]) != OK:
			report.failures.append("Hand export failed: " + id)
		var entry := {"id": id, "name": CARDS[id][0], "category": CARDS[id][1], "printed_rules": [CARDS[id][2], CARDS[id][3]], "files": []}
		for i in paths.size():
			var saved := Image.load_from_file(paths[i])
			var expected := Vector2i(256, 384) if i == 2 else Vector2i(1024, 1536)
			if saved == null or saved.get_size() != expected or not saved.detect_alpha():
				report.failures.append("Invalid PNG: " + paths[i])
				continue
			var size := saved.get_size()
			var corners: Array = []
			for point in [Vector2i.ZERO, Vector2i(size.x - 1, 0), Vector2i(0, size.y - 1), size - Vector2i.ONE]:
				var alpha := roundi(saved.get_pixelv(point).a * 255)
				corners.append(alpha)
				if alpha > 16:
					report.failures.append("Corner alpha: " + paths[i])
			var center_alpha := roundi(saved.get_pixel(size.x / 2, size.y / 2).a * 255)
			if center_alpha < 230:
				report.failures.append("Center alpha: " + paths[i])
			var project_path: String = paths[i].replace("res://../", "") if i == 0 else paths[i].replace("res://", "godot/")
			entry.files.append({"path": project_path, "size": [size.x, size.y], "format": "RGBA8", "corner_alpha": corners, "center_alpha": center_alpha, "sha256": FileAccess.get_sha256(paths[i])})
		report.cards.append(entry)
	report["passed"] = report.failures.is_empty()
	var file := FileAccess.open("res://../art/cards/occult-cards-v01.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t") + "\n")
	file.close()
	print("OCCULT_CARD_ASSETS ", JSON.stringify(report))
	quit(0 if report.passed else 1)
