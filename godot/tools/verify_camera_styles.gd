extends SceneTree
## Both real HUD controls, all 55 combinations, projected picking and rendered lens checks.
const Cameras := preload("res://scripts/visual/camera_style.gd")
const Styles := preload("res://scripts/visual/screen_style.gd")
const Layout := preload("res://scripts/world/layout.gd")
const FOLDER := "C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/output/camera-presets/"
var failures: Array[String] = []
var combinations: Array = []
var lens_records: Array = []

func _initialize() -> void:
	create_timer(60.0,true,false,true).timeout.connect(func(): push_error("Camera verification timed out"); quit(2))
	call_deferred("_run")

func _check(ok: bool, message: String) -> void:
	if not ok:
		failures.append(message)
		push_error(message)

func _camera_state(camera: Camera3D) -> Array:
	return [camera.transform,camera.projection,camera.fov,camera.size,camera.keep_aspect,camera.near,camera.far]

func _lighting_state(world) -> Array:
	var result := [Styles.current_id,world.env.ambient_light_color,world.env.ambient_light_energy,world.sun.light_color,world.sun.light_energy,world.env.glow_intensity,world.env.glow_hdr_threshold,world.outline_mesh.visible,world.post_mat.get_shader_parameter("saturation"),world.ground_mat.get_shader_parameter("ground_emission")]
	for light in world.reference_lighting.lights: result.append([light.visible,light.light_energy,light.light_color])
	return result

func _render() -> Image:
	for frame in 5: await process_frame
	await RenderingServer.frame_post_draw
	return root.get_texture().get_image()

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(FOLDER)
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	for frame in 4: await process_frame
	# This suite verifies the original lens profiles; exploration owns the follow framing.
	game.world.player_camera.toggle_overview()
	game.process_mode = Node.PROCESS_MODE_DISABLED
	game.hud.process_mode = Node.PROCESS_MODE_ALWAYS
	_check(Cameras.current_id == "lens_wide" and Styles.current_id == "toon_midnight", "Approved defaults missing")
	_check(game.hud.camera_select.item_count == 5 and game.hud.style_select.item_count == 11, "Independent preset menus missing")
	var original_camera := _camera_state(game.world.camera)
	var original_state := [game.economy.gold,game.player.hp,game.player.position,game.world.lodge.hp,game.session.state,game.session.prep_elapsed,game.cards.hand().duplicate(true),game.player.agent.target_position]
	var anchored_ground := [game.world.ground_mat.get_shader_parameter("reference_center"),game.world.ground_mat.get_shader_parameter("reference_right"),game.world.ground_mat.get_shader_parameter("reference_up"),game.world.ground_mat.get_shader_parameter("reference_size")]
	var original_image := await _render()
	original_image.save_png(FOLDER+"source-default.png")
	# 화면 설정은 일시 정지 메뉴의 하위 패널(달빛 UI): 펼친 상태에서 겹침을 확인한 뒤 닫고 렌더한다.
	game.hud.pause_panel.visible = true
	game.hud.pause_settings.visible = true
	for f in 3: await process_frame
	var ui_rects := [game.hud.style_select.get_global_rect(),game.hud.camera_select.get_global_rect()]
	_check(ui_rects[0].size.x > 0 and not ui_rects[0].intersects(ui_rects[1]), "Preset controls overlap")
	game.hud.pause_settings.visible = false
	game.hud.pause_panel.visible = false
	for style in Styles.IDS:
		for lens in Cameras.IDS:
			paused = true
			var before_camera := _camera_state(game.world.camera)
			game.hud.style_select.item_selected.emit(Styles.IDS.find(style))
			_check(_camera_state(game.world.camera) == before_camera and Cameras.current_id == Cameras.IDS[game.hud.camera_select.selected], "Shading changed lens: "+style+"/"+lens)
			var before_lighting := _lighting_state(game.world)
			game.hud.camera_select.item_selected.emit(Cameras.IDS.find(lens))
			_check(_lighting_state(game.world) == before_lighting, "Lens changed lighting: "+style+"/"+lens)
			_check(Cameras.current_id == lens and game.hud.camera_select.selected == Cameras.IDS.find(lens) and paused, "Paused lens selection failed: "+lens)
			_check(Styles.current_id == style and game.hud.style_select.selected == Styles.IDS.find(style), "Shading selection lost")
			var image := await _render()
			_check(not image.is_empty(), "Combination failed to render: "+style+"/"+lens)
			_check(_difference(original_image,image,Rect2(.118,.067,.03,.004)) < .0001, "Combination altered opaque HUD health bar")
			combinations.append({"shading":style,"camera":lens,"rendered":true})
	paused = false
	_check(original_state == [game.economy.gold,game.player.hp,game.player.position,game.world.lodge.hp,game.session.state,game.session.prep_elapsed,game.cards.hand(),game.player.agent.target_position], "Menu combinations changed gameplay state")
	_check(anchored_ground == [game.world.ground_mat.get_shader_parameter("reference_center"),game.world.ground_mat.get_shader_parameter("reference_right"),game.world.ground_mat.get_shader_parameter("reference_up"),game.world.ground_mat.get_shader_parameter("reference_size")], "Lens reprojected painted ground")
	game.world.set_screen_style("toon_neon")
	var ratios: Array[float] = []
	var images: Array[Image] = []
	game.cards.add("lumberjack",1,"렌즈 검증")
	var card_uid: int = game.cards.entries.back()["uid"]
	for lens in Cameras.IDS:
		game.hud.camera_select.item_selected.emit(Cameras.IDS.find(lens))
		var camera: Camera3D = game.world.camera
		var focus := camera.unproject_position(Layout.CAMERA_TARGET)
		_check(focus.distance_to(root.get_visible_rect().size*.5) < .01, "Ground focus shifted: "+lens)
		var forward := camera.transform.basis.z
		forward.y = 0.0
		forward = forward.normalized()
		var right := camera.transform.basis.x
		var near_center := Layout.CAMERA_TARGET+forward*10.0
		var far_center := Layout.CAMERA_TARGET-forward*10.0
		var near_width := camera.unproject_position(near_center+right).distance_to(camera.unproject_position(near_center-right))
		var far_width := camera.unproject_position(far_center+right).distance_to(camera.unproject_position(far_center-right))
		var ratio := near_width/far_width
		ratios.append(ratio)
		_check(is_equal_approx(ratio,1.0) if lens == "orthographic" else ratio > 1.10, "Perspective convergence missing: "+lens)
		var largest_pick_error := 0.0
		for pos in [Vector3(-3,0,6),Vector3(4,0,8),Vector3(-8,0,5),Vector3(8,0,-5)]:
			var resolved: Vector3 = game.resolver._ground_at(camera.unproject_position(pos))
			largest_pick_error = maxf(largest_pick_error,resolved.distance_to(pos))
		_check(largest_pick_error < .001, "Ground picking shifted: "+lens)
		var tree: Dictionary = game.world.harvest_trees[0]
		var plan: Dictionary = game.resolver.evaluate(card_uid,camera.unproject_position(tree.pos+Vector3(0,1.6,0)))
		_check(plan.get("ok",false) and plan.get("action","") == "chop" and plan.get("tree",{}).get("pos") == tree.pos, "Card tree target shifted: "+lens)
		var old_target: Vector3 = game.player.agent.target_position
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = true
		event.position = camera.unproject_position(Vector3(-3,0,6))
		game._unhandled_input(event)
		_check(game.player.agent.target_position.distance_to(Vector3(-3,0,6)) < 1.0, "Actual click move missed: "+lens)
		game.player.agent.target_position = old_target
		game.player.moving = false
		var image := await _render()
		_check(image.save_png(FOLDER+"source-"+lens+".png") == OK, "Lens capture failed")
		images.append(image)
		lens_records.append({"id":lens,"profile":Cameras.profile(lens),"near_far_width_ratio":ratio,"ground_pick_error":largest_pick_error,"tree_preview":plan.get("action",""),"click_move":true})
	_check(ratios[1] < ratios[2] and ratios[2] < ratios[3], "Soft/balanced/wide lenses do not increase convergence")
	for i in range(1,images.size()):
		_check(_difference(images[0],images[i],Rect2(.25,.25,.50,.45)) > .01, "Lens did not visibly change geometry")
	game.cards.consume(card_uid)
	var previous_camera := _camera_state(game.world.camera)
	var previous_id := Cameras.current_id
	_check(not game.world.set_camera_style("invalid") and Cameras.current_id == previous_id and _camera_state(game.world.camera) == previous_camera, "Invalid lens changed camera")
	game.world.set_camera_style("lens_soft")
	game.world.set_screen_style("toon_neon")
	paused = true
	var f3 := InputEventKey.new()
	f3.keycode = KEY_F3
	f3.pressed = true
	game.hud._unhandled_input(f3)
	_check(Cameras.current_id == "lens_balanced" and Styles.current_id == "toon_neon" and paused, "Paused F3 changed shading or pause")
	var before_f2 := _camera_state(game.world.camera)
	var f2 := InputEventKey.new()
	f2.keycode = KEY_F2
	f2.pressed = true
	game.hud._unhandled_input(f2)
	_check(_camera_state(game.world.camera) == before_f2 and Cameras.current_id == "lens_balanced" and Styles.current_id == "toon_midnight" and paused, "Paused F2 changed lens or pause")
	paused = false
	# Wider/portrait viewports retain vertical framing and the same two independent controls.
	var initial_size := root.size
	for viewport_size in [Vector2i(1920,1080),Vector2i(1200,900)]:
		root.size = viewport_size
		for frame in 4: await process_frame
		_check(game.hud.camera_select.get_global_rect().end.x <= root.get_visible_rect().size.x+1 and game.hud.camera_select.get_global_rect().position.y >= 0, "Camera menu outside resized viewport")
		_check(game.world.camera.unproject_position(Layout.CAMERA_TARGET).distance_to(root.get_visible_rect().size*.5) < .01, "Resized viewport lost center")
	root.size = initial_size
	game.world.set_screen_style(Styles.DEFAULT_ID)
	game.world.set_camera_style(Cameras.DEFAULT_ID)
	_check(_camera_state(game.world.camera) == original_camera, "Original camera not restored exactly")
	game.world.set_screen_style("toon_neon")
	game.world.set_camera_style("lens_balanced")
	game.queue_free()
	await process_frame
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	_check(Styles.current_id == "toon_neon" and Cameras.current_id == "lens_balanced" and game.hud.style_select.selected == Styles.IDS.find("toon_neon") and game.hud.camera_select.selected == Cameras.IDS.find("lens_balanced"), "Scene reload lost independent selections")
	_check(game.world.camera.projection == Camera3D.PROJECTION_PERSPECTIVE and is_equal_approx(game.world.camera.fov,26.0), "Scene reload lost lens")
	var report := {"passed":failures.is_empty(),"engine":Engine.get_version_info(),"combinations":combinations,"lenses":lens_records,"checks":["separate menus","55 rendered combinations","independent lighting/camera state","paused F2/F3","ground texture anchored","ground ray roundtrip","card tree preview","actual move click","increasing convergence","exact default restoration","viewport resize","scene reload"],"failures":failures}
	var file := FileAccess.open(FOLDER+"verification.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t"))
	print("CAMERA_STYLE_VERIFICATION passed=",failures.is_empty()," combinations=",combinations.size()," failures=",failures)
	quit(0 if failures.is_empty() else 1)

func _difference(a: Image,b: Image,region: Rect2) -> float:
	var rect := Rect2i(region.position*Vector2(a.get_size()),region.size*Vector2(a.get_size()))
	var total := 0.0
	for y in range(rect.position.y,rect.end.y,2):
		for x in range(rect.position.x,rect.end.x,2):
			var ca := a.get_pixel(x,y)
			var cb := b.get_pixel(x,y)
			total += absf(ca.r-cb.r)+absf(ca.g-cb.g)+absf(ca.b-cb.b)
	return total/float(ceili(rect.size.x/2.0)*ceili(rect.size.y/2.0)*3)
