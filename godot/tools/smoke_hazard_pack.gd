extends SceneTree
## This source script runs externally against the exported PCK's actual resources.
const Sites:=preload("res://scripts/world/hazard_sites.gd")
var game
var failures: Array[String]=[]

func _initialize() -> void:
	create_timer(30.0,true,false,true).timeout.connect(func(): quit(2))
	call_deferred("_run")

func check(ok: bool,message: String) -> void:
	if not ok: failures.append(message); push_error(message)

func _run() -> void:
	game=load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	for i in 180:
		await physics_frame
		if game.world.hazard_regions.inhabitants.size()==15: break
	game.session.set_process(false)
	check(get_nodes_in_group("hazard_insects").size()==15,"packed residents")
	check(game.waves.alive()==0,"packed wave roster isolation")
	check(game.world.hazard_regions.smoke_emitters.size()==3,"packed smoke emitters")
	var texture: Texture2D=game.world.ground_mat.get_shader_parameter("toxic_ground")
	check(texture!=null and texture.get_width()>1000,"packed dedicated terrain")
	for resident in game.world.hazard_regions.inhabitants:
		check(Vector2(resident.home.x,resident.home.z).distance_to(resident.site.center)<6.0,"packed spawn inside habitat")
	var subject=game.world.hazard_regions.inhabitants[0]
	subject.take_damage(1000.0)
	check(subject.dead and get_nodes_in_group("venom_puddles").size()>=5,"packed fluid/death effects")
	var at: Vector2=Sites.SITES[0].center
	game.player.position=Vector3(at.x,0,at.y)
	game.player.set_physics_process(false)
	for resident in game.world.hazard_regions.inhabitants: resident.set_physics_process(false)
	for i in 100: await physics_frame
	check(game.world.hazard_regions.influence>.97,"packed regional grade")
	game.hud.set_map_visible(true)
	for i in 6: await process_frame
	print("HAZARD_PACK_SMOKE passed=",failures.is_empty()," failures=",failures)
	quit(0 if failures.is_empty() else 1)
