extends SceneTree
## Native Control-layout previews over an unmodified shipped-game screenshot.
## Generated transparent artwork is an atlas; none of these previews changes runtime HUD.
const FOLDER := "C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/output/ui-style-concepts-v01/"
const VARIANTS := [
	{"id":"01-ink-storybook", "parts":[Rect2(5,8,565,185),Rect2(15,195,420,130),Rect2(610,5,585,185),Rect2(1200,30,468,135),Rect2(1668,35,102,125),Rect2(433,545,917,334),Rect2(8,650,243,229),Rect2(1353,650,420,229)]},
	{"id":"02-cozy-lodge", "parts":[Rect2(8,8,600,175),Rect2(6,182,420,173),Rect2(658,5,448,170),Rect2(1155,27,503,128),Rect2(1660,30,112,127),Rect2(466,575,858,302),Rect2(10,690,215,189),Rect2(1315,705,458,174)]},
	{"id":"03-moon-runes", "parts":[Rect2(6,6,577,195),Rect2(5,197,398,148),Rect2(625,7,526,175),Rect2(1197,29,468,143),Rect2(1668,34,105,116),Rect2(460,539,856,340),Rect2(3,694,195,185),Rect2(1315,696,458,183)]}
]
const SLOTS := [Rect2(18,16,312,108),Rect2(22,132,238,89),Rect2(640,16,320,100),Rect2(1140,25,350,85),Rect2(1510,30,64,72),Rect2(540,622,520,176),Rect2(24,681,106,109),Rect2(1310,687,265,107)]

func _initialize() -> void:
	call_deferred("_render")

func _render() -> void:
	var source_path := FOLDER+"pack-toon-default-clean.png"
	var output_folder := FOLDER
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--source="): source_path = arg.trim_prefix("--source=")
		if arg.begins_with("--output="): output_folder = arg.trim_prefix("--output=").trim_suffix("/")+"/"
	root.size = Vector2i(1600,800)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	var canvas := Control.new()
	root.add_child(canvas)
	var source := Image.load_from_file(source_path)
	if source == null: quit(1); return
	var background := TextureRect.new()
	background.texture = ImageTexture.create_from_image(source)
	background.position = Vector2.ZERO
	background.size = Vector2(1600,800)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	canvas.add_child(background)
	for f in 3: await process_frame
	await RenderingServer.frame_post_draw
	var baseline := root.get_texture().get_image()
	var records := []
	var passed := true
	for variant in VARIANTS:
		var art := Image.load_from_file(FOLDER+variant.id+"-overlay.png")
		var alpha_center := art.get_pixel(art.get_width()/2, art.get_height()/2).a
		if alpha_center != 0.0: passed = false
		var texture := ImageTexture.create_from_image(art)
		var controls := []
		for i in SLOTS.size():
			var atlas := AtlasTexture.new()
			atlas.atlas = texture
			atlas.region = variant.parts[i]
			atlas.filter_clip = true
			var control := TextureRect.new()
			control.texture = atlas
			control.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
			control.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			control.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			control.position = SLOTS[i].position
			control.size = SLOTS[i].size
			canvas.add_child(control)
			controls.append(control)
		for f in 3: await process_frame
		await RenderingServer.frame_post_draw
		var final := root.get_texture().get_image()
		var changed := 0
		for y in range(225,620):
			for x in range(350,1250):
				if final.get_pixel(x,y) != baseline.get_pixel(x,y): changed += 1
		var error := final.save_png(output_folder+variant.id+"-mockup.png")
		passed = passed and changed == 0 and error == OK
		records.append({"id":variant.id,"overlay_size":[art.get_width(),art.get_height()],"transparent_center":alpha_center==0.0,"unmodified_gameplay_rect":[350,225,900,395],"changed_gameplay_pixels":changed,"save_error":error,"image":variant.id+"-mockup.png"})
		for control in controls: control.queue_free()
		await process_frame
	var report := {"passed":passed,"source":source_path,"source_size":[source.get_width(),source.get_height()],"viewport":[1600,800],"method":"Native Godot TextureRect/AtlasTexture layout over actual game capture, existing imagegen transparent UI art","variants":records}
	var file := FileAccess.open(output_folder+"composition-verification.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t"))
	print("UI_COMPOSITION ",JSON.stringify(report))
	quit(0 if passed else 1)
