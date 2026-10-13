extends SceneTree
## Render the actual imported shipping PNGs over light and dark backgrounds.

const Catalog = preload("res://scripts/ui/card_catalog.gd")
var screenshot := "res://screenshots/cards/asset-gallery.png"

func _initialize() -> void:
	call_deferred("_run")

func _label(text: String, position: Vector2, width: float, font_size: int, color := Color("f4ebd6")) -> void:
	var label := Label.new()
	label.text = text
	label.position = position
	label.size.x = width
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	root.add_child(label)

func _run() -> void:
	root.size = Vector2i(1774, 887)
	var background := ColorRect.new()
	background.color = Color("211e31")
	background.size = root.size
	root.add_child(background)
	_label("마녀산장 · 카드 에셋", Vector2(0, 20), 1774, 30)
	_label("도끼 용병 · 양털 · 목재 · 숲의 괴물 · 공용 뒷면", Vector2(0, 65), 1774, 17, Color("bfb0cd"))
	var entries: Array = Catalog.read().get("cards", [])
	entries.append({"id": "card_back", "name": "공용 뒷면"})
	for i in entries.size():
		var entry: Dictionary = entries[i]
		var x := 85.0 + i * 324.0
		var light := ColorRect.new()
		light.position = Vector2(x - 8, 125)
		light.size = Vector2(308, 442)
		light.color = Color("dbd5e1") if i % 2 == 0 else Color("514861")
		root.add_child(light)
		var image := TextureRect.new()
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		image.texture = Catalog.back() if entry.id == "card_back" else Catalog.texture(entry.id)
		root.add_child(image)
		image.position = Vector2(x, 127)
		image.size = Vector2(292, 438)
		_label(entry.name, Vector2(x, 579), 292, 22)
		var hand := TextureRect.new()
		hand.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		hand.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		hand.texture = Catalog.back(true) if entry.id == "card_back" else Catalog.texture(entry.id, true)
		root.add_child(hand)
		hand.position = Vector2(x + 80, 628)
		hand.size = Vector2(132, 198)
	_label("실제 PNG · 투명 라운드 외곽 · 아래는 손패 크기 미리보기", Vector2(0, 850), 1774, 16, Color("bfb0cd"))
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(screenshot.get_base_dir()))
	var error := root.get_texture().get_image().save_png(screenshot)
	print("CARD_ASSET_GALLERY ", screenshot, " result=", error)
	quit(0 if error == OK else 1)
