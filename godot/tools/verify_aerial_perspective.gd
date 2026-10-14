extends SceneTree
## Actual fog render, separate controls, every camera/style, follow/zoom and outline fading.
const Air := preload("res://scripts/visual/aerial_perspective.gd")
const Cameras := preload("res://scripts/visual/camera_style.gd")
const Styles := preload("res://scripts/visual/screen_style.gd")
const Layout := preload("res://scripts/world/layout.gd")
var OUT := "C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/output/aerial-perspective/"
var failures: Array[String] = []
var probes: Array = []
var combinations := 0

func _initialize() -> void:
	if "--colored" in OS.get_cmdline_user_args(): OUT=OUT.replace("aerial-perspective/","colored-air/")
	create_timer(90.0,true,false,true).timeout.connect(func(): push_error("Air check timed out"); quit(2))
	call_deferred("_run")

func check(ok: bool, message: String) -> void:
	if not ok:
		failures.append(message)
		push_error(message)

func render() -> Image:
	for i in 3: await process_frame
	await RenderingServer.frame_post_draw
	return root.get_texture().get_image()

func lens_state(camera: Camera3D) -> Array:
	return [camera.transform,camera.projection,camera.fov,camera.size]

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	for i in 5: await process_frame
	check(Air.current_id == "dramatic" and game.world.env.fog_enabled,"Dramatic air default missing")
	game.world.player_camera.toggle_overview()
	game.process_mode = Node.PROCESS_MODE_DISABLED
	game.hud.process_mode = Node.PROCESS_MODE_ALWAYS
	check(game.hud.air_select.item_count==3 and game.hud.camera_select.item_count==5 and game.hud.style_select.item_count==11,"Independent menus missing")
	# 달빛 UI: 화면 설정은 일시 정지 하위 패널, 지도는 접이식 창. 둘을 함께 펼쳐도 겹치지 않아야 한다.
	game.hud.pause_panel.visible = true
	game.hud.pause_settings.visible = true
	game.hud.set_map_visible(true)
	for f in 3: await process_frame
	check(game.hud.air_select.get_global_rect().size.x > 0 and not game.hud.air_select.get_global_rect().intersects(game.hud.exploration_map.get_global_rect()),"Air menu overlaps minimap")
	game.hud.pause_settings.visible = false
	game.hud.pause_panel.visible = false
	game.hud.set_map_visible(false)
	var state := [game.economy.gold,game.player.hp,game.player.position,game.world.lodge.hp,game.session.state,game.session.prep_elapsed,game.cards.hand().duplicate(true),game.player.agent.target_position]
	game.world.set_air_style("off")
	var baseline := await render()
	for style in Styles.IDS:
		for lens in Cameras.IDS:
			paused=true
			game.hud.style_select.item_selected.emit(Styles.IDS.find(style))
			game.hud.camera_select.item_selected.emit(Cameras.IDS.find(lens))
			var camera_before := lens_state(game.world.camera)
			var lighting_before := [game.world.env.ambient_light_color,game.world.env.ambient_light_energy,game.world.sun.light_color,game.world.sun.light_energy,game.world.env.glow_intensity]
			for air in Air.IDS:
				game.hud.air_select.item_selected.emit(Air.IDS.find(air))
				check(Air.current_id==air and game.hud.air_select.selected==Air.IDS.find(air) and paused,"Paused air selection failed")
				check(lens_state(game.world.camera)==camera_before and Cameras.current_id==lens,"Air changed lens")
				check(Styles.current_id==style and lighting_before==[game.world.env.ambient_light_color,game.world.env.ambient_light_energy,game.world.sun.light_color,game.world.sun.light_energy,game.world.env.glow_intensity],"Air changed lighting")
				var image := await render()
				check(not image.is_empty(),"Combination render failed")
				check(region_difference(baseline,image,Rect2(.118,.067,.03,.004)) < .0001,"Fog altered opaque HUD health bar")
				combinations+=1
	paused=false
	check(state==[game.economy.gold,game.player.hp,game.player.position,game.world.lodge.hp,game.session.state,game.session.prep_elapsed,game.cards.hand(),game.player.agent.target_position],"Air controls changed gameplay")
	game.world.set_screen_style("toon_neon")
	# Isolate depth probes in layer 20 so moving foliage cannot occlude the measurement.
	var camera: Camera3D = game.world.camera
	var old_mask := camera.cull_mask
	camera.cull_mask = 1 << 19
	for lens in Cameras.IDS:
		game.world.set_camera_style(lens)
		var nodes: Array = []
		var distance: float = camera.global_position.distance_to(Layout.CAMERA_TARGET)
		for row in 2:
			var depth := distance+12.0 if row==1 else distance-6.0
			for col in 3:
				var pos := Vector2(.35+col*.15,.34 if row==1 else .65)*root.get_visible_rect().size
				var mesh := MeshInstance3D.new()
				mesh.layers=1 << 19
				var quad := QuadMesh.new()
				var size := camera.size*.08 if camera.projection==Camera3D.PROJECTION_ORTHOGONAL else depth*tan(deg_to_rad(camera.fov)*.5)*.16
				quad.size=Vector2(size,size)
				mesh.mesh=quad
				var material := StandardMaterial3D.new()
				material.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
				material.albedo_color=[Color(.02,.02,.02),Color(.92,.92,.92),Color(1.0,.18,.045)][col]
				mesh.material_override=material
				mesh.transform=Transform3D(camera.global_basis,camera.project_position(pos,depth))
				game.add_child(mesh)
				nodes.append(mesh)
		game.world.set_air_style("off")
		var without := await render()
		game.world.set_air_style("dramatic")
		var with_air := await render()
		var near_change := 0.0
		for col in 3:
			near_change=maxf(near_change,color_difference(sample(without,Vector2(.35+col*.15,.65)),sample(with_air,Vector2(.35+col*.15,.65))))
		var contrast_before := luminance(sample(without,Vector2(.50,.34)))-luminance(sample(without,Vector2(.35,.34)))
		var contrast_after := luminance(sample(with_air,Vector2(.50,.34)))-luminance(sample(with_air,Vector2(.35,.34)))
		var saturation_before := chroma(sample(without,Vector2(.65,.34)))
		var saturation_after := chroma(sample(with_air,Vector2(.65,.34)))
		check(near_change<.005,"Near geometry changed: "+lens)
		check(contrast_after<contrast_before*.60,"Far contrast not compressed: "+lens)
		check(saturation_after<saturation_before*.70,"Far color not desaturated: "+lens)
		check(contrast_after>contrast_before*.08,"Far silhouettes lost: "+lens)
		probes.append({"lens":lens,"near_rgb_change":near_change,"far_contrast_ratio":contrast_after/contrast_before,"far_chroma_ratio":saturation_after/saturation_before})
		for node in nodes: node.queue_free()
		await process_frame
	camera.cull_mask=old_mask
	game.world.set_camera_style("lens_balanced")
	for air in Air.IDS:
		game.world.set_air_style(air)
		var image := await render()
		check(image.save_png(OUT+"source-"+air+".png")==OK,"Scene capture failed")
	game.world.set_screen_style("toon_outline")
	game.world.set_air_style("dramatic")
	check((await render()).save_png(OUT+"source-outline.png")==OK,"Outline capture failed")
	var params: Vector4=game.world.outline_mat.get_shader_parameter("air_fog_params")
	check(is_equal_approx(params.w,.76) and is_equal_approx(params.x,game.world.env.fog_depth_begin) and is_equal_approx(params.y,game.world.env.fog_depth_end),"Far outline fog not synchronized")
	game.world.set_air_style("off")
	check(not game.world.env.fog_enabled and is_zero_approx(game.world.outline_mat.get_shader_parameter("air_fog_params").w),"Air off leaves fog/outline fading")
	var old_id:=Air.current_id
	check(not game.world.set_air_style("invalid") and Air.current_id==old_id,"Invalid air preset accepted")
	paused=true
	var key:=InputEventKey.new()
	key.keycode=KEY_F5
	key.pressed=true
	game.hud._unhandled_input(key)
	check(Air.current_id=="soft" and paused,"Paused F5 failed")
	paused=false
	# Follow focuses in world space; zoom changes fog thresholds by the same camera distance.
	game.world.player_camera.toggle_overview()
	game.world.set_screen_style("toon_neon")
	game.world.set_air_style("dramatic")
	for place in [Vector3(-24,0,5),Vector3(8,0,-25),Layout.PLAYER_START]:
		game.player.position=place
		game.world.player_camera.recenter()
		game.world.aerial_perspective.sync_camera()
		var distance: float=camera.global_position.distance_to(game.world.player_camera.focus)
		check(is_equal_approx(game.world.env.fog_depth_begin,distance-2.0),"Follow fog range shifted")
		var target: Vector3=place+Vector3(1,0,1)
		var picked: Vector3=game.resolver._ground_at(camera.unproject_position(target))
		check(picked.distance_to(target)<.001,"Fog/follow changed ground picking")
	for height in [12.0,28.0,18.0]:
		game.world.player_camera.height=height
		game.world.player_camera._place()
		game.world.aerial_perspective.sync_camera()
		var distance: float=camera.global_position.distance_to(game.world.player_camera.focus)
		check(is_equal_approx(game.world.env.fog_depth_end,distance+12.0),"Zoom fog range shifted")
	check((await render()).save_png(OUT+"source-follow.png")==OK,"Follow capture failed")
	game.world.set_air_style("soft")
	game.queue_free()
	await process_frame
	game=load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	check(Air.current_id=="soft" and game.hud.air_select.selected==1 and is_equal_approx(game.world.env.fog_density,.48),"Restart lost air selection")
	var report:={"passed":failures.is_empty(),"combinations":combinations,"depth_probes":probes,"default":"dramatic","checks":["independent air/shading/camera menus","165 actual renders","near geometry preserved","far contrast and chroma reduced","far silhouettes retained","HUD preserved","paused F5","outline depth fade","off cleanup","follow and zoom range","ground picking","scene restart"],"failures":failures}
	var file:=FileAccess.open(OUT+"verification.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t"))
	print("AERIAL_VERIFICATION passed=",failures.is_empty()," combinations=",combinations," failures=",failures)
	quit(0 if failures.is_empty() else 1)

func sample(image: Image,uv: Vector2) -> Color:
	var center:=Vector2i(uv*Vector2(image.get_size()))
	var result:=Color(0,0,0,0)
	for y in range(-3,4):
		for x in range(-3,4): result+=image.get_pixelv(center+Vector2i(x,y))
	return result/49.0

func luminance(c: Color) -> float:
	return c.r*.2126+c.g*.7152+c.b*.0722

func chroma(c: Color) -> float:
	return (maxf(c.r,maxf(c.g,c.b))-minf(c.r,minf(c.g,c.b)))/maxf(.001,maxf(c.r,maxf(c.g,c.b)))

func color_difference(a: Color,b: Color) -> float:
	return (absf(a.r-b.r)+absf(a.g-b.g)+absf(a.b-b.b))/3.0

func region_difference(a: Image,b: Image,region: Rect2) -> float:
	var rect:=Rect2i(region.position*Vector2(a.get_size()),region.size*Vector2(a.get_size()))
	var total:=0.0
	for y in range(rect.position.y,rect.end.y):
		for x in range(rect.position.x,rect.end.x): total+=color_difference(a.get_pixel(x,y),b.get_pixel(x,y))
	return total/float(rect.get_area())
