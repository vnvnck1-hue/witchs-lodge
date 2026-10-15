extends SceneTree
## Presentation-only gallery, rendered directly from the five actual transparent game assets.
const Profiles := preload("res://scripts/ui/guest_profiles.gd")
const SkinUI := preload("res://scripts/ui/moon/moon_skin.gd")

func _initialize() -> void:
	call_deferred("run")

func label_at(parent: Node, text: String, at: Rect2, font_size: int, color: Color, bold := false) -> Label:
	var label := Label.new()
	label.text = text
	label.position = at.position
	label.size = at.size
	label.add_theme_font_override("font", SkinUI.font(bold))
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label

func run() -> void:
	root.size = Vector2i(1440, 680)
	root.content_scale_size = Vector2i(1440, 680)
	var back := ColorRect.new()
	back.size = Vector2(1440, 680)
	back.color = Color8(28, 20, 43)
	root.add_child(back)
	label_at(root, "산장을 찾아온 새로운 얼굴들", Rect2(34, 24, 1360, 58), 35, SkinUI.CREAM, true)
	label_at(root, "다섯 명의 새 손님 · 투명 초상과 인물별 첫인사", Rect2(36, 83, 1360, 32), 18, SkinUI.LAVENDER)
	var index := 0
	for id in ["olaf", "torbin", "neri", "oswin", "sera"]:
		var profile := Profiles.character(id)
		var x := 28.0 + index * 278.0
		var panel := Panel.new()
		panel.position = Vector2(x, 146)
		panel.size = Vector2(270, 500)
		panel.add_theme_stylebox_override("panel", SkinUI.flat(Color8(18, 12, 29), Color8(184, 151, 109, 64), 18, 0, 1))
		root.add_child(panel)
		var portrait := TextureRect.new()
		portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		portrait.texture = load(profile.portrait)
		portrait.position = Vector2(x + 3, 128)
		portrait.size = Vector2(264, 346)
		portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		root.add_child(portrait)
		label_at(root, profile.person, Rect2(x + 16, 486, 240, 43), 29, SkinUI.CREAM, true)
		label_at(root, profile.role, Rect2(x + 16, 533, 240, 29), 17, SkinUI.TEAL)
		var quote := label_at(root, profile.lines[0].split("\n")[0], Rect2(x + 16, 577, 238, 52), 16, Color8(222, 213, 228))
		quote.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		index += 1
	for i in 8: await process_frame
	await RenderingServer.frame_post_draw
	var path := ProjectSettings.globalize_path("res://../output/guest-roster-v3/new-guests.png")
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): path = arg.trim_prefix("--out=")
	var result := root.get_texture().get_image().save_png(path)
	print("GUEST_GALLERY ", result, " ", path)
	quit(0 if result == OK else 1)
