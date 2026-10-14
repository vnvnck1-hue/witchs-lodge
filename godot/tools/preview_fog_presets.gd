extends SceneTree
## Only the three new fog variants, at the existing default camera/shading/air.
const Fog := preload("res://scripts/visual/fog_of_war.gd")
var game
var output := ""
var failures: Array[String] = []
var captures: Array[Image] = []

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): output = arg.trim_prefix("--out=").trim_suffix("/")+"/"
	create_timer(45.0,true,false,true).timeout.connect(func():push_error("Fog preview timed out");quit(2))
	call_deferred("_run")

func check(ok: bool, msg: String) -> void:
	if not ok: failures.append(msg);push_error(msg)

func frames(count := 6) -> void:
	for i in count: await process_frame

func capture(id: String) -> Image:
	await frames()
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	check(image.save_png(output+id+".png")==OK,"capture "+id)
	return image

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(output)
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await frames(15)
	game.world.day_cycle.set_mode("night")
	game.world.aerial_perspective.sync_colors()
	var fog = game.world.fog_of_war
	check(fog.current_id=="snow_mist","soft snow mist is default")
	var lens: Transform3D = game.world.camera.global_transform
	var air := Vector4(game.world.env.fog_depth_begin,game.world.env.fog_depth_end,game.world.env.fog_depth_curve,game.world.env.fog_density)
	var visible_before: float = fog.visibility_at(game.player.global_position)
	var remembered_before: PackedByteArray = fog.explored.duplicate()
	game.hud.visible = false
	paused = true
	for i in Fog.IDS.size():
		game.hud.fog_select.select(i)
		game.hud.fog_select.item_selected.emit(i)
		check(fog.current_id==Fog.IDS[i],"fog menu selects "+Fog.IDS[i])
		captures.append(await capture(Fog.IDS[i]))
	check(game.world.camera.global_transform.is_equal_approx(lens),"fog choice preserves camera")
	check(Vector4(game.world.env.fog_depth_begin,game.world.env.fog_depth_end,game.world.env.fog_depth_curve,game.world.env.fog_density).is_equal_approx(air),"fog choice preserves aerial perspective")
	check(is_equal_approx(fog.visibility_at(game.player.global_position),visible_before) and fog.explored==remembered_before,"fog choice preserves logical sight and exploration")
	paused = false
	game.session.start_wave()
	game.waves.set_process(false)
	await frames(2)
	fog.refresh()
	var enemies := get_nodes_in_group("enemies")
	check(not enemies.is_empty() and not enemies[0].visible,"soft transparent fog still hides unseen enemies")
	paused = true
	game.hud.visible = true
	game.hud.pause_panel.visible = true
	game.hud.pause_settings.visible = true
	fog.configure(Fog.DEFAULT_ID)
	game.hud.refresh_pause()
	game.hud._recenter(game.hud.pause_panel)
	await capture("settings")
	check(root.get_visible_rect().encloses(game.hud.pause_panel.get_global_rect()),"settings panel fits viewport")
	game.hud.visible = false
	await _gallery()
	var file := FileAccess.open(output+"verification.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"passed":failures.is_empty(),"presets":Fog.IDS,"camera":"lens_wide","shading":"toon_midnight","air":"dramatic","failures":failures},"\t"))
	print("FOG_PREVIEWS passed=",failures.is_empty()," presets=",Fog.IDS," failures=",failures)
	quit(0 if failures.is_empty() else 1)

func _gallery() -> void:
	# Native comparison panel renders actual game captures.
	root.mode = Window.MODE_WINDOWED
	root.size = Vector2i(1600,440)
	root.content_scale_size = Vector2i(1600,440)
	await frames(3)
	var layer := CanvasLayer.new()
	layer.layer = 100
	root.add_child(layer)
	var background := ColorRect.new()
	background.color = Color(.045,.04,.075)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(background)
	var width := root.get_visible_rect().size.x
	var height := root.get_visible_rect().size.y
	var title := Label.new()
	title.text = "전장의 안개 · 밝기와 경계 비교"
	title.position = Vector2(24,12)
	title.add_theme_font_size_override("font_size",22)
	background.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "동일한 심야 라이팅 · 넓은 원근 34° · 극적인 공기"
	subtitle.position = Vector2(24,46)
	subtitle.add_theme_color_override("font_color",Color(.67,.67,.77))
	background.add_child(subtitle)
	var notes := ["가장 옅고 밝은 설무 · 기본값","보랏빛 색감 · 은은한 긴장감","푸른 달빛 · 넓게 퍼지는 몽환적인 안개"]
	for i in 3:
		var x := 24.0+i*(width-32.0)/3.0
		var w := (width-80.0)/3.0
		var label := Label.new()
		label.text = Fog.NAMES[i]
		label.position = Vector2(x,92)
		label.add_theme_font_size_override("font_size",22)
		background.add_child(label)
		var picture := TextureRect.new()
		picture.texture = ImageTexture.create_from_image(captures[i])
		picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		picture.position = Vector2(x,130)
		picture.size = Vector2(w,minf(w*.5,height-180))
		background.add_child(picture)
		var description := Label.new()
		description.text = notes[i]
		description.position = Vector2(x,130+picture.size.y+12)
		description.add_theme_font_size_override("font_size",16)
		description.add_theme_color_override("font_color",Color(.8,.8,.87))
		background.add_child(description)
	await capture("comparison")
