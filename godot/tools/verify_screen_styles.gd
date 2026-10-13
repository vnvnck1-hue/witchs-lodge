extends SceneTree
## Integration and visual checks through the shipped game's actual preset controls.
const Styles := preload("res://scripts/visual/screen_style.gd")
var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)

func _run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	await process_frame
	_check(Styles.current_id == "soft", "Default preset must be soft")
	game.process_mode = Node.PROCESS_MODE_DISABLED
	game.hud.process_mode = Node.PROCESS_MODE_ALWAYS
	var state := [game.economy.gold, game.world.lodge.hp, game.player.hp, game.session.state, game.session.prep_elapsed]
	var records: Array = []
	var roof_samples: Array[Color] = []
	var strong_image: Image
	var outline_image: Image
	var folder := "res://screenshots/screen-presets"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	for i in Styles.IDS.size():
		var id: String = Styles.IDS[i]
		# Exercise the same signal emitted by the visible dropdown.
		game.hud.style_select.item_selected.emit(i)
		var p := Styles.profile(id)
		_check(Styles.current_id == id, "Dropdown did not set " + id)
		_check(game.hud.style_select.selected == i, "Dropdown did not synchronize " + id)
		_check(is_equal_approx(game.world.env.ambient_light_energy,p.ambient), "Ambient mismatch " + id)
		_check(is_equal_approx(game.world.sun.light_energy,p.moon), "Moon mismatch " + id)
		_check(game.world.outline_mesh.visible == (id == "toon_outline"), "Outline visibility mismatch " + id)
		_check(is_equal_approx(game.world.outline_mat.get_shader_parameter("width_pixels"),p.outline_width), "Outline width mismatch " + id)
		for frame in 8: await process_frame
		await RenderingServer.frame_post_draw
		var path := folder + "/" + id + ".png"
		var image := root.get_texture().get_image()
		if id == "toon_strong": strong_image = image
		if id == "toon_outline": outline_image = image
		_check(image.save_png(path) == OK, "Capture failed " + id)
		var sample := _sample_roof(image)
		roof_samples.append(sample)
		records.append({"id":id,"name":Styles.NAMES[i],"image":path,"settings":p,"roof_sample":sample})
	for i in roof_samples.size():
		for j in range(i+1,roof_samples.size()):
			# The outline preset intentionally uses the same interior lighting as strong toon.
			if Styles.IDS[i] == "toon_strong" and Styles.IDS[j] == "toon_outline": continue
			_check(not roof_samples[i].is_equal_approx(roof_samples[j]), "Rendered roof did not change between presets")
	var ink_pixels := _count_ink_pixels(strong_image,outline_image)
	_check(ink_pixels > 1500, "Thick outline failed to darken enough geometry boundary pixels")
	# Opaque health-bar pixels must stay identical. Translucent panels legitimately
	# show the changed world behind them, so they are not a valid unchanged-pixel probe.
	_check(_region_difference(strong_image,outline_image,Rect2i(75,66,130,6)) < .00001, "Outline affected HUD")
	_check(state == [game.economy.gold, game.world.lodge.hp, game.player.hp, game.session.state, game.session.prep_elapsed], "Style switch changed game state")
	var previous := Styles.current_id
	_check(not game.world.set_screen_style("invalid"), "Invalid preset accepted")
	_check(Styles.current_id == previous, "Invalid preset changed current selection")
	# F2 works even while paused, and consumes the key without changing pause state.
	paused = true
	var key := InputEventKey.new()
	key.keycode = KEY_F2
	key.pressed = true
	game.hud._unhandled_input(key)
	_check(Styles.current_id == "soft" and paused, "F2 failed while paused")
	paused = false
	# A newly spawned monster uses the same global shader path after a switch.
	game.world.set_screen_style("toon_outline")
	var actor = load("res://scripts/visual/painted_models.gd").monster()
	game.actors.add_child(actor)
	_check(actor.get_child_count() > 0, "New actor failed after switching")
	actor.queue_free()
	await process_frame
	# Rebuilding the normal scene keeps the chosen preset; cached materials must not reset it.
	game.queue_free()
	await process_frame
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	_check(Styles.current_id == "toon_outline" and game.hud.style_select.selected == Styles.IDS.find("toon_outline"), "Scene reload lost preset")
	_check(game.world.outline_mesh.visible, "Scene reload lost outline")
	game.world.set_screen_style("soft")
	_check(game.hud.style_select.selected == 0, "Default restoration failed")
	var report := {"engine":Engine.get_version_info(),"presets":records,"outline_ink_pixels":ink_pixels,"failures":failures,"passed":failures.is_empty()}
	var file := FileAccess.open(folder+"/verification.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t"))
	print("SCREEN_STYLE_VERIFICATION ",JSON.stringify(report))
	quit(0 if failures.is_empty() else 1)

func _sample_roof(image: Image) -> Color:
	# A small stable opaque roof patch; avoids animated smoke/particles and UI.
	var center := Vector2i(int(image.get_width()*.49),int(image.get_height()*.36))
	var sum := Color(0,0,0,0)
	for x in range(-5,6):
		for y in range(-5,6): sum += image.get_pixelv(center+Vector2i(x,y))
	return sum/121.0

func _count_ink_pixels(a: Image,b: Image) -> int:
	var count := 0
	for y in range(int(a.get_height()*.20),int(a.get_height()*.75)):
		for x in range(int(a.get_width()*.20),int(a.get_width()*.80)):
			var ca := a.get_pixel(x,y)
			var cb := b.get_pixel(x,y)
			if (ca.r+ca.g+ca.b)-(cb.r+cb.g+cb.b) > .18: count += 1
	return count

func _region_difference(a: Image,b: Image,rect: Rect2i) -> float:
	var difference := 0.0
	for y in range(rect.position.y,rect.end.y):
		for x in range(rect.position.x,rect.end.x):
			var ca := a.get_pixel(x,y)
			var cb := b.get_pixel(x,y)
			difference += absf(ca.r-cb.r)+absf(ca.g-cb.g)+absf(ca.b-cb.b)
	return difference/float(rect.get_area()*3)
