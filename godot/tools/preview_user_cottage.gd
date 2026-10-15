extends SceneTree
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	var game=load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	for i in 15: await physics_frame
	game.session.set_process(false)
	game.economy.set_process(false)
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
	for i in 30: await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../output/user-cottage/installed-main-cottage.png"))
	quit()
