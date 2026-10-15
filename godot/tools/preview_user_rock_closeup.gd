extends SceneTree
## Close-up of one placed user rock formation (day light, perspective) for shape/material review.
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	var game=load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	for i in 15: await physics_frame
	game.session.set_process(false)
	game.economy.set_process(false)
	game.world.player_camera.set_process(false)
	game.hud.visible=false
	var args := OS.get_cmdline_user_args()
	var at := Vector3(float(args[0]),0,float(args[1]))
	var cam: Camera3D=game.world.camera
	cam.projection=Camera3D.PROJECTION_PERSPECTIVE
	cam.fov=40
	cam.position=at+Vector3(5,6,7)
	cam.look_at(at+Vector3(0,.6,0))
	for i in 40: await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../output/user-rocks/closeup-"+args[2]+".png"))
	quit()
