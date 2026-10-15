extends SceneTree
## Real navigation/combat integration and rendered reference views. No mocked movement.
const Sites:=preload("res://scripts/world/hazard_sites.gd")
const Insect:=preload("res://scripts/actors/venom_insect.gd")
const Bolt:=preload("res://scripts/actors/magic_bolt.gd")
const Layout:=preload("res://scripts/world/layout.gd")
const OUT:="res://../output/toxic-regions/"
var game
var failures: Array[String]=[]
var evidence: Dictionary={}
var render: bool="--render" in OS.get_cmdline_user_args()

func _initialize() -> void:
	create_timer(150.0,true,false,true).timeout.connect(func(): push_error("HAZARD_VERIFY timeout"); quit(2))
	call_deferred("_run")

func check(ok: bool, message: String) -> void:
	if not ok:
		failures.append(message)
		push_error(message)

func ticks(count: int) -> void:
	for i in count: await physics_frame
	await process_frame

func frames(count: int) -> void:
	for i in count: await process_frame

func capture(id: String) -> void:
	if not render: return
	await frames(18)
	await RenderingServer.frame_post_draw
	var path:=ProjectSettings.globalize_path(OUT+id+".png")
	check(root.get_texture().get_image().save_png(path)==OK,"capture "+id)

func place(at: Vector3) -> void:
	game.player.position=at
	game.player.velocity=Vector3.ZERO
	game.player.moving=false
	game.world.player_camera.recenter()

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	game=load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await ticks(12)
	for startup_wait in 150:
		if game.world.hazard_regions.inhabitants.size()==15: break
		await physics_frame
	game.session.set_process(false)
	game.economy.set_process(false)
	game.player.set_physics_process(false)
	game.world.day_cycle.set_mode("day")
	check(game.get_tree().get_nodes_in_group("hazard_insects").size()==15,"15 territorial residents")
	check(game.waves.alive()==0,"residents excluded from wave roster")
	var regions=game.world.hazard_regions
	check(regions.smoke_emitters.size()==3,"three poisonous smoke emitters")
	check(regions.fissure_materials.size()==3,"three independently pulsing fissure networks")
	check(not game.world.ground_mat.get_shader_parameter("toxic_ground")==null,"dedicated ground texture bound")
	var nav_map: RID=game.get_world_3d().navigation_map
	NavigationServer3D.map_force_update(nav_map)
	var paths:=[]
	for site in Sites.SITES:
		var target:=Vector3(site.center.x,0,site.center.y)
		var path:=NavigationServer3D.map_get_path(nav_map,Layout.PLAYER_START,target,true)
		check(path.size()>1 and path[-1].distance_to(target)<.8,"walkable connected site "+str(site.id))
		paths.append({"id":site.id,"nav_points":path.size()})
	evidence["navigation"]=paths
	check(regions.influence<.001,"home starts clean")
	await capture("00-lodge-safe")
	# Isolate one resident to exercise the actual AI without other residents obscuring its state.
	var subject=regions.inhabitants[0]
	for resident in regions.inhabitants:
		resident.set_physics_process(false)
		resident.visible=true
	game.world.fog_of_war.set_enabled(false)
	var home: Vector3=subject.home
	var goal:=home+Vector3(3.8,0,0)
	goal=NavigationServer3D.map_get_closest_point(nav_map,goal)
	goal.y=0.0
	place(goal)
	subject.set_physics_process(true)
	var previous: Vector3=subject.position
	await ticks(45)
	check(subject.state==Insect.State.CHASE,"detect and chase player")
	check(subject.position.distance_to(previous)>.3,"chase actually moves along navigation")
	var before_hp: float=game.player.hp
	place(subject.position+Vector3(.7,0,0))
	await ticks(90)
	check(game.player.hp<before_hp,"melee deals real damage")
	game.player.hp=game.player.max_hp
	place(Layout.PLAYER_START)
	await ticks(3)
	check(subject.state==Insect.State.RETURN,"leash forces return")
	var returned:=false
	Engine.time_scale=3.0
	for i in 300:
		await physics_frame
		if subject.state==Insect.State.IDLE and subject.position.distance_to(home)<.7:
			returned=true
			break
	Engine.time_scale=1.0
	check(returned,"actually returns to own spawn")
	subject.set_physics_process(false)
	# Invalid/dead targets cannot trap CHASE or keep attacking; RETURN ignores nearby targets.
	place(subject.position+Vector3(.7,0,0))
	subject.state=Insect.State.RETURN
	subject.position=home+Vector3(3,0,0)
	subject.set_physics_process(true)
	await ticks(2)
	check(subject.state==Insect.State.RETURN and subject.target==null,"return cannot be interrupted by aggro")
	subject.set_physics_process(false)
	subject.position=home
	subject.state=Insect.State.CHASE
	subject.target=game.player
	game.player.dead=true
	subject.set_physics_process(true)
	await ticks(1)
	check(subject.target==null,"dead target released")
	game.player.dead=false
	subject.set_physics_process(false)
	# Slow interface is compatible with frost rune and ward lantern.
	subject.apply_slow("check",.4,.1)
	check(is_equal_approx(subject.slow_factor(),.4),"slow accepts source/factor/duration")
	subject._tick_slows(.2)
	check(is_equal_approx(subject.slow_factor(),1.0),"slow expires")
	# Post grade changes continuously with real player position and restores on exit, in day/night.
	for clock in ["day","night"]:
		game.world.day_cycle.set_mode(clock)
		place(Vector3(Sites.SITES[0].center.x,0,Sites.SITES[0].center.y))
		await ticks(100)
		check(regions.influence>.97,"full toxic grade "+clock)
		check(float(game.world.post_mat.get_shader_parameter("toxic_amount"))>.97,"post shader bound "+clock)
		await capture("01-hollow-"+clock)
		place(Layout.PLAYER_START)
		await ticks(100)
		check(regions.influence<.001,"grade restores "+clock)
	game.world.day_cycle.set_mode("day")
	for i in range(1,Sites.SITES.size()):
		var site: Dictionary=Sites.SITES[i]
		place(Vector3(site.center.x,0,site.center.y))
		await ticks(95)
		await capture("02-"+str(site.id))
	# Projectiles target the actual height of airborne residents.
	var flyer=regions.inhabitants[1]
	flyer.hp=flyer.max_hp
	place(flyer.position+Vector3(1.5,0,1.5))
	var projectile:=Bolt.new()
	projectile.target=flyer
	projectile.position=game.player.position+Vector3(0,1.0,0)
	game.actors.add_child(projectile)
	await ticks(35)
	check(flyer.hp<flyer.max_hp,"magic bolt hits airborne creature")
	var pools_before:=get_nodes_in_group("venom_puddles").size()
	var particles_before: int=game.world.vfx_pool.active_count()
	flyer.take_damage(1.0)
	check(get_nodes_in_group("venom_puddles").size()>pools_before,"hit leaves green spatter")
	check(game.world.vfx_pool.active_count()>particles_before,"hit emits green fluid droplets")
	var hp_before: float=flyer.hp
	flyer.take_damage(0.0)
	check(flyer.hp==hp_before,"zero damage ignored")
	flyer.take_damage(1000.0)
	check(flyer.dead and not flyer.is_in_group("enemies"),"death removes combat target")
	check(get_nodes_in_group("venom_puddles").size()>=pools_before+5,"death spreads green ichor")
	var puddles_after:=get_nodes_in_group("venom_puddles").size()
	flyer.take_damage(1000.0)
	check(get_nodes_in_group("venom_puddles").size()==puddles_after,"duplicate death gives no extra effects")
	await ticks(40)
	check(flyer.visual.position.y<.1,"flyer falls to floor on death")
	await capture("03-ichor-and-corpse")
	# Separate wave roster allows the actual session to finish its wave with living residents.
	game.waves.active=true
	game.waves.total=0
	game.waves.spawn_index=0
	check(game.waves.is_wave_done(),"wave clears while residents remain")
	game.waves.active=false
	# Curated model closeup in a real, lit habitat.
	if render:
		var camera: Camera3D=game.world.camera
		game.hud.visible=false
		game.world.player_camera.set_process(false)
		var model=regions.inhabitants[2]
		var at: Vector3=model.position+Vector3(0,.7,0)
		camera.projection=Camera3D.PROJECTION_ORTHOGONAL
		camera.size=5.8
		camera.position=at+Vector3(4,4,6)
		camera.look_at(at)
		model.visual.rotation.y=.4
		await capture("04-insect-closeup")
	evidence.merge({"passed":failures.is_empty(),"sites":3,"residents":15,"walkers":10,"flyers":5,
		"checks":["navigation connectivity","actual chase and melee","leash and actual return","return aggro lock","dead target release","slow compatibility","day/night local grade and restoration","airborne projectile hit","hit fluid spray","death pool and falling flyer","idempotent death","wave clear with residents"],"failures":failures,"rendered":render})
	var report:=FileAccess.open(OUT+("render-verification.json" if render else "verification.json"),FileAccess.WRITE)
	report.store_string(JSON.stringify(evidence,"\t"))
	print("HAZARD_VERIFY passed=",failures.is_empty()," failures=",failures)
	quit(0 if failures.is_empty() else 1)
