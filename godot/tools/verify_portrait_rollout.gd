extends SceneTree
## Production portrait bindings, alpha edges, actual UI screenshots and exported texture parity.
const Profiles := preload("res://scripts/ui/guest_profiles.gd")
const SkinUI := preload("res://scripts/ui/moon/moon_skin.gd")
var out := ""
var expected := {}
var textures := {}
var checks: Array = []
var failures: Array = []
var render := false

func _initialize() -> void:
	out = ProjectSettings.globalize_path("res://../output/portrait-card-style-v01/source/")
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): out = arg.trim_prefix("--out=").trim_suffix("/") + "/"
		if arg.begins_with("--expect="):
			var record = JSON.parse_string(FileAccess.get_file_as_string(arg.trim_prefix("--expect=")))
			if record is Dictionary: expected = record.get("textures", {})
	DirAccess.make_dir_recursive_absolute(out)
	render = DisplayServer.get_name() != "headless"
	create_timer(100.0, true, false, true).timeout.connect(func(): push_error("Portrait review timeout"); quit(2))
	run.call_deferred()

func check(ok: bool, message: String) -> void:
	checks.append({"ok": ok, "check": message})
	print("PORTRAIT ", "PASS " if ok else "FAIL ", message)
	if not ok: failures.append(message)

func frames(count := 5) -> void:
	for i in count: await process_frame

func screenshot(id: String) -> void:
	if not render: return
	await frames()
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png(out + id + ".png") == OK, "capture " + id)

func inspect_texture(id: String, path: String, min_height := 1000) -> void:
	var tex := load(path) as Texture2D
	check(tex != null and tex.get_height() > min_height, "production texture " + id)
	if tex == null: return
	var image := tex.get_image()
	if image.is_compressed(): image.decompress()
	image.convert(Image.FORMAT_RGBA8)
	var hash := HashingContext.new()
	hash.start(HashingContext.HASH_SHA256)
	hash.update(image.get_data())
	var digest := hash.finish().hex_encode()
	textures[id] = {"path": path, "width": image.get_width(), "height": image.get_height(), "pixel_sha256": digest}
	if not expected.is_empty():
		check(expected.has(id) and expected[id].pixel_sha256 == digest, "exported pixels match reviewed source " + id)
	var edge_max := 0.0
	for x in image.get_width():
		edge_max = maxf(edge_max, maxf(image.get_pixel(x, 0).a, image.get_pixel(x, image.get_height() - 1).a))
	for y in image.get_height():
		edge_max = maxf(edge_max, maxf(image.get_pixel(0, y).a, image.get_pixel(image.get_width() - 1, y).a))
	check(edge_max <= 8.0 / 255.0, "no visible illustration cut by canvas " + id)
	var clear := 0
	var solid := 0
	for y in range(0, image.get_height(), 20):
		for x in range(0, image.get_width(), 20):
			var alpha := image.get_pixel(x, y).a
			clear += int(alpha < 0.01)
			solid += int(alpha > 0.98)
	check(clear > 100 and solid > 100, "genuine transparent and opaque regions " + id)

func label_at(parent: Node, text: String, at: Rect2, font_size: int, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.position = at.position
	label.size = at.size
	label.add_theme_font_override("font", SkinUI.font(true))
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)

func gallery() -> void:
	root.size = Vector2i(1600, 1120)
	root.content_scale_size = Vector2i(1600, 1120)
	var canvas := Control.new()
	root.add_child(canvas)
	var back := ColorRect.new()
	back.color = Color8(28, 20, 43)
	back.size = Vector2(1600, 1120)
	canvas.add_child(back)
	label_at(canvas, "마녀산장 · 카드 화풍 포트레이트", Rect2(32, 16, 1500, 56), 34, SkinUI.CREAM)
	var entries := Profiles.all_profiles()
	entries.append({"person": "마녀", "role": "산장지기", "portrait": "res://assets/ui/ftue/witch_portrait.png"})
	for i in entries.size():
		var entry: Dictionary = entries[i]
		var p := Vector2(24 + (i % 4) * 395, 86 + (i / 4) * 510)
		var panel := Panel.new()
		panel.position = p
		panel.size = Vector2(370, 488)
		panel.add_theme_stylebox_override("panel", SkinUI.flat(Color8(18, 12, 29), Color8(143, 112, 91), 12, 0, 1))
		canvas.add_child(panel)
		var pic := TextureRect.new()
		pic.texture = load(entry.portrait)
		pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		pic.position = p + Vector2(12, 6)
		pic.size = Vector2(346, 414)
		canvas.add_child(pic)
		label_at(canvas, entry.person, Rect2(p + Vector2(20, 424), Vector2(145, 40)), 27, SkinUI.CREAM)
		label_at(canvas, entry.role, Rect2(p + Vector2(173, 434), Vector2(185, 32)), 18, SkinUI.LAVENDER)
	await screenshot("00-all-portraits")
	canvas.queue_free()
	await frames()

func run() -> void:
	# 이 검증은 카드 화풍으로 교체한 인간 손님 7명이 대상이다(종족 손님 35명은 tools/verify_races.gd).
	var roster := Profiles.profiles_of_race("human")
	check(roster.size() == 7, "all seven human guest identities covered")
	for profile in roster: inspect_texture(profile.id, profile.portrait)
	inspect_texture("witch", "res://assets/ui/ftue/witch_portrait.png")
	inspect_texture("witch_locked", "res://assets/ui/ftue/witch_locked.png")
	inspect_texture("hud_frame", "res://assets/ui/moon_runes/runtime/player_status.png", 190)
	if not expected.is_empty(): check(expected.size() == textures.size(), "complete exported portrait set matches source")
	if render: await gallery()
	root.size = Vector2i(1600, 800)
	root.content_scale_size = Vector2i(1774, 887)
	var title = load("res://scenes/title.tscn").instantiate()
	root.add_child(title)
	await frames(10)
	title._open_select()
	await frames(10)
	check(title.slot_buttons.size() == 4, "all witch selection slots available")
	for i in title.slot_buttons.size():
		var slot: Control = title.slot_buttons[i]
		var pics := slot.find_children("*", "TextureRect", true, false)
		check(pics.size() == 1 and pics[0].texture.resource_path == "res://assets/ui/ftue/" + ("witch_portrait.png" if i == 0 else "witch_locked.png"), "selection portrait binding " + str(i))
		check(pics.size() == 1 and pics[0].stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED, "selection keeps complete portrait proportions " + str(i))
	await screenshot("01-witch-selection")
	title.queue_free()
	await frames()
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await frames(10)
	game.session.set_process(false)
	var hud_pic: TextureRect = game.hud.moon.groups.player_status.get_node("StatusPortrait")
	check(hud_pic.texture.resource_path == "res://assets/ui/ftue/witch_portrait.png", "HUD reuses new witch portrait")
	check(SkinUI.source_of("player_status") == "runtime", "HUD uses background without old baked portrait")
	check(hud_pic.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED and not hud_pic.clip_contents, "HUD keeps entire half-body without clipping")
	check(game.guest_arrival.portrait.material == null and game.guest_ui.presenter.portrait.material == null, "arrival and dialogue preserve authored lower finish")
	for viewport in [Vector2i(960, 540), Vector2i(1280, 720), Vector2i(1920, 1080)]:
		root.size = viewport
		await frames()
		check(root.get_visible_rect().encloses(hud_pic.get_global_rect()), "HUD portrait fits viewport " + str(viewport))
	root.size = Vector2i(1600, 800)
	await screenshot("02-hud")
	# Every portrait in the actual compact arrival presenter and full conversation presenter.
	var intro = game.guest_arrival
	intro.set_process(false)
	for profile in roster:
		intro.show_profile(profile, profile.lines[0])
		intro.phase_time = 2.0
		intro._animate_guest()
		check(intro.portrait.texture.resource_path == profile.portrait, "actual arrival portrait " + profile.id)
		check(intro.portrait.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED, "arrival keeps full silhouette " + profile.id)
		await screenshot("arrival-" + profile.id)
	intro.finish()
	var presenter = game.guest_ui.presenter
	presenter.set_process(false)
	presenter.show_profile(roster[1], roster[1].lines[0])
	presenter.phase_time = 2.0
	presenter._animate_guest()
	await screenshot("03-dialogue-mira")
	var report := {"checks": checks, "failures": failures, "textures": textures, "renderer": DisplayServer.get_name()}
	var file := FileAccess.open(out + "verification.json", FileAccess.WRITE)
	if file != null: file.store_string(JSON.stringify(report, "\t"))
	print("PORTRAIT_ROLLOUT ", "PASS" if failures.is_empty() else "FAIL", " checks=", checks.size())
	quit(0 if failures.is_empty() else 1)

