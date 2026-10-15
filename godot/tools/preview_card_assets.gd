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
	root.size = Vector2i(1774, 2070)
	var background := ColorRect.new()
	background.color = Color("211e31")
	background.size = root.size
	root.add_child(background)
	_label("마녀산장 · 카드 에셋", Vector2(0, 20), 1774, 30)
	_label("도끼 용병 · 양털 · 목재 · 숲의 괴물 · 서리 룬 · 수호 등불 · 숙박 초대장 · 새끼양 · 공용 뒷면", Vector2(0, 65), 1774, 17, Color("bfb0cd"))
	var entries: Array = Catalog.read().get("cards", [])
	entries.append({"id": "card_back", "name": "공용 뒷면"})
	for i in entries.size():
		var entry: Dictionary = entries[i]
		var x := 45.0 + (i % 3) * 575.0
		var y := 125.0 + (i / 3) * 630.0
		var light := ColorRect.new()
		light.position = Vector2(x - 8, y)
		light.size = Vector2(550, 610)
		light.color = Color("dbd5e1") if i % 2 == 0 else Color("514861")
		root.add_child(light)
		var caption_color := Color("352b41") if i % 2 == 0 else Color("f4ebd6")
		var image := TextureRect.new()
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		image.texture = Catalog.back() if entry.id == "card_back" else Catalog.texture(entry.id)
		root.add_child(image)
		image.position = Vector2(x, y + 12)
		image.size = Vector2(340, 510)
		_label(entry.name, Vector2(x, y + 540), 532, 23, caption_color)
		var hand := TextureRect.new()
		hand.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		hand.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		hand.texture = Catalog.back(true) if entry.id == "card_back" else Catalog.texture(entry.id, true)
		root.add_child(hand)
		hand.position = Vector2(x + 375, y + 305)
		hand.size = Vector2(132, 198)
		_label("손패", Vector2(x + 375, y + 265), 132, 18, caption_color)
	_label("실제 Godot 텍스처 · 투명 라운드 외곽 · 각 칸 오른쪽은 손패 미리보기", Vector2(0, 2040), 1774, 16, Color("bfb0cd"))
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(screenshot.get_base_dir()))
	var error := root.get_texture().get_image().save_png(screenshot)
	print("CARD_ASSET_GALLERY ", screenshot, " result=", error)
	var proof_error := _save_text_proof()
	quit(0 if error == OK and proof_error == OK else 1)

func _save_text_proof() -> Error:
	# Inspection sheet only: unscaled crops from the final shipping PNGs.
	var proof := Image.create(2048, 1360, false, Image.FORMAT_RGBA8)
	proof.fill(Color("514861"))
	var ids := ["frost_rune", "ward_lantern", "guest_invitation", "lamb"]
	for i in ids.size():
		var png := Image.load_from_file(ProjectSettings.globalize_path("res://assets/cards/" + ids[i] + ".png"))
		var position := Vector2i((i % 2) * 1024, (i / 2) * 680)
		proof.blit_rect(png, Rect2i(0, 0, 1024, 300), position)
		proof.blit_rect(png, Rect2i(0, 1176, 1024, 360), position + Vector2i(0, 310))
	var path := "res://screenshots/cards/new-cards-v01-text-proof.png"
	var error := proof.save_png(ProjectSettings.globalize_path(path))
	print("CARD_TEXT_PROOF ", path, " result=", error)
	return error
