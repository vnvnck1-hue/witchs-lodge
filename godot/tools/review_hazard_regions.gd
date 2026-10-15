extends SceneTree
## Render actual game views and a clear authored-model detail after behavior verification.
const Sites:=preload("res://scripts/world/hazard_sites.gd")
const Cfg:=preload("res://scripts/config.gd")
const OUT:="res://../output/toxic-regions/"
var game

func _initialize() -> void:
	create_timer(60.0,true,false,true).timeout.connect(func(): quit(2))
	call_deferred("_run")

func ticks(count: int) -> void:
	for i in count: await physics_frame
	await process_frame

func capture(id: String) -> void:
	for i in 20: await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT+id+".png"))

func _run() -> void:
	game=load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	for i in 150:
		await physics_frame
		if game.world.hazard_regions.inhabitants.size()==15: break
	game.session.set_process(false)
	game.economy.set_process(false)
	game.player.set_physics_process(false)
	game.world.fog_of_war.set_enabled(false)
	game.world.fog_of_war.set_process(false)
	for resident in game.world.hazard_regions.inhabitants: resident.set_physics_process(false)
	for pair in Cfg.STARTER_CARDS: game.cards.add(pair[0],pair[1])
	game.world.day_cycle.set_mode("day")
	await ticks(15)
	await capture("review-safe-lodge")
	for site in Sites.SITES:
		game.player.position=Vector3(site.center.x,0,site.center.y)+Vector3(1.0,0,1.2)
		game.world.player_camera.recenter()
		for resident in game.world.hazard_regions.inhabitants:
			resident._phase+=.21
			resident._animate(0.0)
		await ticks(100)
		await capture("review-"+str(site.id))
		if site.id=="venom_hollow":
			game.world.day_cycle.set_mode("night")
			await ticks(20)
			await capture("review-venom-hollow-night")
			game.world.day_cycle.set_mode("day")
	# Isolated detail: same geometry/materials with depth fog disabled to inspect the mesh.
	var model=game.world.hazard_regions.inhabitants[0]
	for resident in game.world.hazard_regions.inhabitants: resident.visible=false
	model.visible=true
	game.player.visual.visible=false
	var site: Dictionary=Sites.SITES[0]
	model.position=Vector3(site.center.x,0,site.center.y)
	model.visual.rotation.y=.28
	game.player.position=model.position+Vector3(0,0,4)
	game.world.aerial_perspective.configure("off")
	game.world.player_camera.set_process(false)
	game.hud.visible=false
	var cam: Camera3D=game.world.camera
	var at: Vector3=model.position+Vector3(0,.8,0)
	cam.projection=Camera3D.PROJECTION_ORTHOGONAL
	cam.size=3.6
	cam.position=at+Vector3(2.5,2.4,4)
	cam.look_at(at)
	await ticks(6)
	await capture("review-insect-model")
	print("HAZARD_REVIEW complete")
	quit()
