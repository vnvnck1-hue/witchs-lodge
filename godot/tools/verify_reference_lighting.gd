extends SceneTree
## Rendered integration checks using the real game and HUD; also accepts --main-pack.
const Styles := preload("res://scripts/visual/screen_style.gd")
const FOLDER := "C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/output/reference-lighting/"
var folder := FOLDER
var preset_ids := ["neon_moon","midnight_magic"]
var hybrid := false
var failures: Array[String] = []
var records: Array = []

func _initialize() -> void:
	if "--hybrid" in OS.get_cmdline_user_args():
		hybrid = true
		preset_ids = ["toon_neon","toon_midnight"]
		folder = FOLDER.replace("reference-lighting/","toon-reference-lighting/")
	call_deferred("_run")

func _check(ok: bool, message: String) -> void:
	if not ok:
		failures.append(message)
		push_error(message)

func _capture(game, name: String, ui: bool = true) -> Image:
	game.hud.visible = ui
	for frame in 8: await process_frame
	await RenderingServer.frame_post_draw
	var result := root.get_texture().get_image()
	_check(result.save_png(folder+name+".png") == OK, "Capture failed: "+name)
	return result

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(folder)
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	for frame in 3: await process_frame
	_check(Styles.current_id == Styles.DEFAULT_ID, "Existing default changed")
	_check(game.hud.style_select.item_count == 11, "HUD must expose all eleven styles")
	game.process_mode = Node.PROCESS_MODE_DISABLED
	game.hud.process_mode = Node.PROCESS_MODE_ALWAYS
	var state := [game.economy.gold,game.world.lodge.hp,game.player.hp,game.player.position,game.session.state,game.session.prep_elapsed,game.cards.hand().duplicate(true)]
	var baseline := await _capture(game,"source-baseline")
	var clean_images: Array[Image] = []
	var rig = game.world.reference_lighting
	var node_count: int = rig.get_child_count()
	for id in preset_ids:
		paused = true
		game.hud.style_select.item_selected.emit(Styles.IDS.find(id))
		_check(paused and Styles.current_id == id, "Paused dropdown failed: "+id)
		_check(game.hud.style_select.selected == Styles.IDS.find(id), "HUD selection mismatch: "+id)
		var p := Styles.profile(id)
		if hybrid:
			var strong := Styles.profile("toon_strong")
			_check(p.shading == strong.shading and p.surface == strong.surface and p.ink == strong.ink, "Hybrid lost exact strong toon settings: "+id)
			# For the same atmosphere, remove only the hard bands to prove they affect geometry.
			game.hud.visible = false
			var sharp := await _capture(game,"source-"+id+"-bands",false)
			RenderingServer.global_shader_parameter_set("card_style_shading", Vector4(0,.005,0,1))
			var continuous := await _capture(game,"source-"+id+"-continuous",false)
			var band_difference := _difference(sharp,continuous,Rect2(.30,.20,.38,.42))
			_check(band_difference > .005, "Strong toon bands not visible in actual geometry: "+id)
			game.world.set_screen_style(id)
			records.append({"id":id,"strong_toon_geometry_difference":band_difference})
		for light in rig.lights:
			_check(light.visible and light.light_energy > 0.0 and not light.shadow_enabled, "Color light not active: "+id)
		for haze in rig.haze_meshes: _check(haze.visible, "Haze not active: "+id)
		_check(is_equal_approx(game.world.ground_mat.get_shader_parameter("ground_emission"),p.ground_emission), "Ground fill mismatch: "+id)
		_check(is_equal_approx(game.world.env.glow_intensity,p.glow), "Glow mismatch: "+id)
		_check(not game.world.outline_mesh.visible, "Unrequested outline active: "+id)
		var full := await _capture(game,"source-"+id)
		_check(_difference(baseline,full,Rect2(.047,.0825,.08,.0075)) < .0001, "Lighting affected opaque HUD health bar: "+id)
		var clean := await _capture(game,"source-"+id+"-clean",false)
		clean_images.append(clean)
		# Removing only actual lights proves they illuminate opaque snow and stone.
		for light in rig.lights: light.visible = false
		for haze in rig.haze_meshes: haze.visible = false
		var without := await _capture(game,"source-"+id+"-without-pools",false)
		var ground_change := _difference(clean,without,Rect2(.69,.47,.07,.07))
		var stone_change := _difference(clean,without,Rect2(.28,.25,.04,.05))
		_check(ground_change > .01, "Real lights did not illuminate ground: "+id)
		_check(stone_change > .01, "Real lights did not illuminate props: "+id)
		game.world.set_screen_style(id)
		records.append({"id":id,"settings":p,"ground_light_difference":ground_change,"prop_light_difference":stone_change,"clearing_luminance":_luminance(clean),"light_count":rig.lights.size(),"haze_count":rig.haze_meshes.size()})
	_check(_luminance(clean_images[1]) < _luminance(clean_images[0])*.95, "Midnight must have a darker clearing than neon")
	# F2 uses the same runtime control even while paused.
	game.world.set_screen_style(preset_ids[0])
	var key := InputEventKey.new()
	key.keycode = KEY_F2
	key.pressed = true
	game.hud._unhandled_input(key)
	_check(Styles.current_id == preset_ids[1] and paused, "Paused F2 failed")
	paused = false
	for cycle in 3:
		for id in Styles.IDS: game.world.set_screen_style(id)
	_check(rig.get_child_count() == node_count, "Repeated switching created duplicate lighting nodes")
	game.world.set_screen_style(Styles.DEFAULT_ID)
	for light in rig.lights: _check(not light.visible and light.light_energy == 0.0, "Color light leaked into existing style")
	for haze in rig.haze_meshes: _check(not haze.visible, "Haze leaked into existing style")
	_check(is_equal_approx(game.world.ground_mat.get_shader_parameter("ground_emission"),.44), "Original ground fill not restored")
	_check(state == [game.economy.gold,game.world.lodge.hp,game.player.hp,game.player.position,game.session.state,game.session.prep_elapsed,game.cards.hand()], "Switching changed gameplay state")
	var restored := await _capture(game,"source-restored")
	# Stable small roof tile: the wider roof region includes animated chimney smoke.
	var restored_difference := _difference(baseline,restored,Rect2(.486,.353,.007,.014))
	_check(restored_difference < .001, "Existing opaque roof render not restored")
	game.world.set_screen_style(preset_ids[1])
	game.queue_free()
	await process_frame
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	_check(Styles.current_id == preset_ids[1] and game.hud.style_select.selected == Styles.IDS.find(preset_ids[1]), "Restart lost chosen lighting")
	_check(game.world.reference_lighting.lights.size() == 5 and game.world.reference_lighting.lights[0].visible, "Restart lost color lights")
	game.world.set_screen_style(Styles.DEFAULT_ID)
	var report := {"passed":failures.is_empty(),"engine":Engine.get_version_info(),"default":Styles.DEFAULT_ID,"hybrid":hybrid,"presets":records,"restored_roof_difference":restored_difference,"checks":["eleven HUD entries","paused dropdown","paused F2","actual ground/prop lighting","HUD preserved","game state preserved","switch cleanup","baseline render restored","restart persistence"],"failures":failures}
	var file := FileAccess.open(folder+"verification.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t"))
	print("REFERENCE_LIGHTING_VERIFICATION ",JSON.stringify(report))
	quit(0 if failures.is_empty() else 1)

func _difference(a: Image,b: Image,region: Rect2) -> float:
	var rect := Rect2i(region.position*Vector2(a.get_size()),region.size*Vector2(a.get_size()))
	var total := 0.0
	for y in range(rect.position.y,rect.end.y):
		for x in range(rect.position.x,rect.end.x):
			var ca := a.get_pixel(x,y)
			var cb := b.get_pixel(x,y)
			total += absf(ca.r-cb.r)+absf(ca.g-cb.g)+absf(ca.b-cb.b)
	return total/float(rect.get_area()*3)

func _luminance(image: Image) -> float:
	var total := 0.0
	var count := 0
	for y in range(int(image.get_height()*.25),int(image.get_height()*.70),4):
		for x in range(int(image.get_width()*.25),int(image.get_width()*.75),4):
			var c := image.get_pixel(x,y)
			total += c.r*.2126+c.g*.7152+c.b*.0722
			count += 1
	return total/float(count)
