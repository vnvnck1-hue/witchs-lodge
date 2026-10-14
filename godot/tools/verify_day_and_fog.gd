extends SceneTree
const Styles := preload("res://scripts/visual/screen_style.gd")
const Cameras := preload("res://scripts/visual/camera_style.gd")
const Air := preload("res://scripts/visual/aerial_perspective.gd")
const Layout := preload("res://scripts/world/layout.gd")
const Session := preload("res://scripts/game/game_session.gd")
var game
var failures: Array[String] = []
var checks: Array = []
var output := ""

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): output = arg.trim_prefix("--out=").trim_suffix("/")+"/"
	create_timer(90.0,true,false,true).timeout.connect(func(): push_error("Day/sight verification timeout");quit(2))
	call_deferred("_run")

func check(ok: bool, text: String) -> void:
	checks.append({"check":text,"passed":ok})
	if not ok: failures.append(text);push_error(text)

func frames(n := 4) -> void:
	for i in n: await process_frame

func capture(id: String) -> void:
	await frames(8)
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png(output+id+".png")==OK,"capture "+id)

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(output)
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await frames(15)
	game.session.set_process(false)
	game.player.set_physics_process(false)
	var cycle = game.world.day_cycle
	var fog = game.world.fog_of_war
	check(Styles.current_id=="toon_midnight" and Cameras.current_id=="lens_wide" and Air.current_id=="dramatic","approved independent defaults")
	check(cycle.mode=="auto" and fog.enabled,"automatic daylight and fog default")
	game.session.prep_elapsed = 0.0
	cycle.refresh()
	check(is_zero_approx(cycle.progress),"fresh preparation starts in daylight")
	var daylight: float = game.world.env.ambient_light_energy
	var sun_rotation: Vector3 = game.world.sun.rotation_degrees
	await capture("source-day")
	game.session.prep_elapsed = 61.2
	cycle.refresh()
	check(is_equal_approx(cycle.progress,.68) and game.world.sun.light_color.r > game.world.sun.light_color.b,"timer reaches warm sunset")
	check(sun_rotation.distance_to(game.world.sun.rotation_degrees)>20.0,"sun direction moves across sky")
	await capture("source-sunset")
	game.session.prep_elapsed = 73.8
	cycle.refresh()
	await capture("source-dusk")
	game.session.prep_elapsed = 90.0
	cycle.refresh()
	var baseline := Styles.profile("toon_midnight")
	check(daylight > game.world.env.ambient_light_energy*3,"day and night differ materially")
	check(is_equal_approx(game.world.env.ambient_light_energy,baseline.ambient) and game.world.env.ambient_light_color.is_equal_approx(baseline.ambient_color),"night equals approved ambient")
	check(is_equal_approx(game.world.sun.light_energy,baseline.moon) and game.world.sun.light_color.is_equal_approx(baseline.moon_color),"night equals approved moonlight")
	check(game.world.sun.rotation_degrees.is_equal_approx(game.world.MOON_ROT),"night equals approved light direction")
	check(game.world.ground_mat.get_shader_parameter("ground_tint").is_equal_approx(baseline.ground_tint),"night equals approved ground")
	check(is_equal_approx(game.world.reference_lighting.lights[0].light_energy,baseline.rig_energy*3.8),"night restores approved local colored lights")
	check(is_equal_approx(game.world.env.fog_density,.76) and is_equal_approx(game.world.env.fog_depth_curve,1.1),"aerial perspective density and curve preserved")
	await capture("source-night")
	# Tiny timer steps around all color keys must never jump visibly.
	var continuous := true
	for progress in [0.45,.68,.82,1.0]:
		game.session.prep_elapsed = (progress-.0001)*90.0
		cycle.refresh()
		var a: Color = game.world.sun.light_color
		var energy: float = game.world.sun.light_energy
		game.session.prep_elapsed = progress*90.0
		cycle.refresh()
		var b: Color = game.world.sun.light_color
		continuous = continuous and Vector3(a.r,a.g,a.b).distance_to(Vector3(b.r,b.g,b.b))<.005 and absf(game.world.sun.light_energy-energy)<.005
	check(continuous,"continuous light across every phase boundary")
	game.world.set_screen_style("toon_neon")
	check(is_equal_approx(game.world.sun.light_energy,Styles.profile("toon_neon").moon),"style switching updates night baseline")
	game.world.set_screen_style("toon_midnight")
	cycle.set_mode("night")
	game.world.aerial_perspective.sync_camera()
	var air_begin: float = game.world.env.fog_depth_begin
	fog.set_enabled(false)
	check(game.world.env.fog_enabled and is_equal_approx(game.world.env.fog_depth_begin,air_begin),"fog of war toggles independently of aerial perspective")
	await capture("source-night-fow-off")
	fog.set_enabled(true)
	fog.refresh()
	check(fog.is_visible_at(game.player.global_position),"witch is visible")
	check(fog.is_visible_at(Vector3.ZERO),"lodge remains visible")
	var place := Vector3(23,0,18)
	check(not fog.is_explored_at(place) and not fog.is_visible_at(place),"unvisited forest is concealed")
	game.player.position = place
	game.world.player_camera.recenter()
	fog.refresh()
	check(fog.is_visible_at(place) and fog.is_explored_at(place),"movement reveals and remembers new terrain")
	await capture("source-forest-revealed")
	game.player.position = Layout.PLAYER_START
	game.world.player_camera.recenter()
	fog.refresh()
	check(not fog.is_visible_at(place) and fog.is_explored_at(place),"explored terrain stays remembered after leaving")
	# A controlled blocker verifies actual line of sight independently of authored trees.
	game.player.position = Vector3(25,0,-20)
	var wall := StaticBody3D.new()
	wall.collision_layer = 2
	wall.position = Vector3(28,1,-20)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(.5,4,7)
	shape.shape = box
	wall.add_child(shape)
	game.add_child(wall)
	await physics_frame
	await physics_frame
	fog.refresh()
	check(fog.is_visible_at(Vector3(26,0,-20)) and not fog.is_visible_at(Vector3(31,0,-20)),"obstacles block player line of sight")
	wall.queue_free()
	game.player.position = Layout.PLAYER_START
	game.world.player_camera.recenter()
	game.session.start_wave()
	game.waves.set_process(false)
	await frames(2)
	fog.refresh()
	var enemies := get_nodes_in_group("enemies")
	check(not enemies.is_empty(),"real wave spawns enemies")
	var enemy = enemies[0]
	enemy.set_physics_process(false)
	check(not enemy.visible and not fog.is_visible_at(enemy.global_position) and enemy.hp>0 and not enemy.dead,"unseen enemy hidden without changing combat state")
	enemy.position = game.player.position+Vector3(2,0,0)
	fog.refresh()
	check(enemy.visible,"enemy appears on entering sight")
	enemy.position = place
	fog.refresh()
	check(not enemy.visible and fog.is_explored_at(place),"enemy is hidden in remembered terrain too")
	check(game.resolver.enemy_at(game.world.camera.unproject_position(place+Vector3(0,.7,0)))==null,"hidden enemies cannot leak through card hover picking")
	game.hud.set_map_visible(true)
	await capture("source-map-memory")
	game.hud.set_map_visible(false)
	# Automatic clock follows combat, pauses and rises gradually on the next preparation.
	cycle.set_mode("auto")
	cycle.refresh()
	check(cycle.progress==1.0,"combat uses full night")
	paused = true
	var before: float = cycle.progress
	await create_timer(.25,true,false,true).timeout
	check(cycle.progress==before,"pause freezes environmental clock")
	paused = false
	game.session._enter_prep()
	cycle.refresh()
	check(cycle.progress>.99,"next preparation begins with a continuous dawn")
	cycle._process(6.0)
	check(cycle.progress>.3 and cycle.progress<.7,"dawn transitions gradually")
	cycle._process(6.0)
	check(cycle.progress<.01,"dawn reaches daylight before next sunset")
	cycle.set_mode("night")
	game.hud._toggle_pause()
	game.hud._toggle_section(game.hud.pause_settings)
	await capture("source-settings")
	paused = false
	var file := FileAccess.open(output+"verification.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"passed":failures.is_empty(),"checks":checks,"failures":failures},"\t"))
	print("DAY_AND_FOG passed=",failures.is_empty()," checks=",checks.size()," failures=",failures)
	quit(0 if failures.is_empty() else 1)
