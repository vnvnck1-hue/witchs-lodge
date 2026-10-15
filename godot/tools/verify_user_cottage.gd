extends SceneTree
const Layout:=preload("res://scripts/world/layout.gd")
const UserCottage:=preload("res://scripts/visual/user_cottage.gd")
var game
var failures: Array[String]=[]
var packed:="--packed" in OS.get_cmdline_user_args()

func _initialize() -> void:
	create_timer(60.0,true,false,true).timeout.connect(func(): quit(2))
	call_deferred("_run")

func check(ok: bool,label: String) -> void:
	if not ok: failures.append(label);push_error(label)

func ticks(count: int) -> void:
	for i in count: await physics_frame
	await process_frame

func capture(id: String) -> void:
	if packed: return
	for i in 15: await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../output/user-cottage/"+id+".png"))

func _run() -> void:
	game=load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await ticks(15)
	game.session.set_process(false)
	game.economy.set_process(false)
	var lodge=game.world.lodge
	check(lodge.visual.get_node_or_null("UserCottage")!=null,"selected cottage is active")
	check(lodge.visual.find_children("*","MeshInstance3D",true,false).size()==1,"exactly one isolated cottage mesh")
	var cottage: Node3D=lodge.visual.get_node("UserCottage")
	check(cottage.get_meta("source_variant")=="left","front-door variant selected")
	check(cottage.scale.is_equal_approx(Vector3.ONE*17.0),"correct game scale")
	check(cottage.position==UserCottage.MODEL_OFFSET,"base alignment")
	var mesh: MeshInstance3D=cottage.find_children("*","MeshInstance3D",true,false)[0]
	check(mesh.get_surface_override_material(0).get_shader_parameter("cottage_paint")!=null,"original painted texture retained")
	check(Layout.CHIMNEY_TOP==UserCottage.CHIMNEY,"chimney effects aligned")
	check(game.world.get_node("ChimneySmoke").position==UserCottage.CHIMNEY,"smoke at actual chimney")
	# Ray picking must still resolve to the existing interactive lodge wrapper.
	var query:=PhysicsRayQueryParameters3D.create(Vector3(0,7,0),Vector3(0,0,0),2)
	var hit: Dictionary=game.get_world_3d().direct_space_state.intersect_ray(query)
	check(not hit.is_empty() and hit.collider==lodge,"lodge collision and click target")
	var health: float=lodge.hp
	lodge.take_damage(11)
	check(lodge.hp==health-11,"damage intact")
	lodge.repair(11)
	check(lodge.hp==health,"repair intact")
	await ticks(15)
	check(lodge.visual.position==Vector3.ZERO,"shake restores stable model origin")
	# Check a real route to the existing entrance and around the building.
	var nav: RID=game.get_world_3d().navigation_map
	NavigationServer3D.map_force_update(nav)
	var path:=NavigationServer3D.map_get_path(nav,game.player.position,Layout.DOOR_FRONT,true)
	check(path.size()>1 and path[-1].distance_to(Layout.DOOR_FRONT)<.6,"entrance navigation")
	game.player.set_destination(Layout.DOOR_FRONT)
	for i in 240:
		await physics_frame
		if game.player.position.distance_to(Layout.DOOR_FRONT)<.6: break
	check(game.player.position.distance_to(Layout.DOOR_FRONT)<.6,"player actually reaches entrance")
	game.player.position=Layout.PLAYER_START
	game.player.moving=false
	game.world.player_camera.recenter()
	game.world.day_cycle.set_mode("day")
	await ticks(20)
	await capture("in-game-day")
	game.world.day_cycle.set_mode("night")
	await ticks(20)
	await capture("in-game-night")
	game.economy.debug_add_gold(200)
	game.cards.add("timber",10)
	var capacity_before: int=game.economy.capacity
	game.economy.buy("extension")
	await ticks(70)
	check(lodge.extension_built and game.economy.capacity>capacity_before,"extension still builds and increases capacity")
	check(lodge.visual.get_node_or_null("UserCottage")!=null,"extension retains selected main lodge")
	await capture("in-game-extension")
	if not packed:
		game.world.day_cycle.set_mode("day")
		game.world.player_camera.set_process(false)
		game.world.aerial_perspective.configure("off")
		game.world.fog_of_war.set_enabled(false)
		game.hud.visible=false
		var cam: Camera3D=game.world.camera
		cam.projection=Camera3D.PROJECTION_ORTHOGONAL
		cam.size=7.2
		cam.position=Vector3(8,7,12)
		cam.look_at(Vector3(0,2.1,.35))
		await capture("installed-model-closeup")
		var report:=FileAccess.open("res://../output/user-cottage/verification.json",FileAccess.WRITE)
		report.store_string(JSON.stringify({"passed":failures.is_empty(),"selected":"left","triangles":3157,"failures":failures},"\t"))
	print("USER_COTTAGE_VERIFY packed=",packed," passed=",failures.is_empty()," failures=",failures)
	quit(0 if failures.is_empty() else 1)
