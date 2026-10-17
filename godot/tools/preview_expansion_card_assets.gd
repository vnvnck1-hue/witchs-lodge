extends SceneTree
## Actual renderer checks imported card alpha against alternating light/dark panels.
const Package = preload("res://tools/package_card_assets.gd")

func _initialize() -> void:
	call_deferred("_run")

func _label(text: String, pos: Vector2, width: float, size: int, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.position = pos
	label.size.x = width
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	root.add_child(label)

func _run() -> void:
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	root.content_scale_size = Vector2i.ZERO
	var rows := ceili(Package.IDS.size() / 4.0)
	root.size = Vector2i(1840, 130 + rows * 526)
	var bg := ColorRect.new()
	bg.size = root.size
	bg.color = Color("211e31")
	root.add_child(bg)
	_label("마녀산장 · 카드 앞면 38종 + 공용 뒷면 · 총 39장", Vector2(0, 20), 1840, 30, Color("f4ebd6"))
	for i in Package.IDS.size():
		var id: String = Package.IDS[i]
		var pos := Vector2(18 + (i % 4) * 456, 88 + floori(i / 4.0) * 526)
		var panel := ColorRect.new()
		panel.position = pos
		panel.size = Vector2(438, 510)
		panel.color = Color("ddd7e4") if i % 2 == 0 else Color("514861")
		root.add_child(panel)
		for small in [false, true]:
			var image := TextureRect.new()
			image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			image.texture = load("res://assets/cards/" + ("hand/" if small else "") + id + ".png")
			image.position = pos + (Vector2(329, 286) if small else Vector2(12, 12))
			image.size = Vector2(96, 144) if small else Vector2(288, 432)
			root.add_child(image)
		var ink := Color("302a3a") if i % 2 == 0 else Color("f4ebd6")
		_label(id, pos + Vector2(0, 464), 438, 19, ink)
		_label("256×384", pos + Vector2(310, 253), 125, 16, ink)
	_label("실제 Godot 임포트 텍스처 · 밝은/어두운 패널 · 각 카드 오른쪽 손패", Vector2(0, root.size.y - 30), 1840, 18, Color("c8bbd4"))
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var error := root.get_texture().get_image().save_png("res://screenshots/cards/asset-gallery.png")
	print("EXPANSION_CARD_GALLERY ", root.get_texture().get_size(), " result=", error)
	quit(0 if error == OK else 1)
