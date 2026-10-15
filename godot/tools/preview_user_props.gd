extends SceneTree
## Real play-camera captures of user prop placements (default night toon look).
## Args: -- <comma-separated nature_id prefixes, default "user_"> <output folder under output/, default user-rocks>
var OUT := "res://../output/user-rocks/"
func _initialize() -> void: call_deferred("_run")

func wanted(id: String) -> bool:
	var args := OS.get_cmdline_user_args()
	for prefix in (args[0] if args.size()>0 else "user_").split(","):
		if id.begins_with(prefix): return true
	return false

func shot(name: String) -> void:
	for i in 40: await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT+name+".png"))

func _run() -> void:
	if OS.get_cmdline_user_args().size()>1: OUT = "res://../output/"+OS.get_cmdline_user_args()[1]+"/"
	var game=load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	for i in 20: await physics_frame
	game.session.set_process(false)
	game.economy.set_process(false)
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/environment/forest_layout.json"))
	var found := 0
	var report := []
	for node in game.world.find_children("*","Node3D",true,false):
		if wanted(str(node.get_meta("nature_id",""))):
			found += 1
			report.append({"cluster":node.get_meta("forest_cluster",""),"position":str(node.global_position)})
	print("USER_PROPS_RUNTIME ",found," ",JSON.stringify(report))
	await shot("start-view")
	var index := 0
	for group in data.groups:
		for part in group.parts:
			if not wanted(str(part.asset)): continue
			index += 1
			# Stand the witch on the nearest trail side so the camera frames rock + lane like real play.
			var at := Vector3(part.position[0],0,part.position[1])
			var Layout = load("res://scripts/world/layout.gd")
			var best := at
			var best_d := 1e9
			for a in 24:
				var p: Vector3 = at+Vector3(cos(a*TAU/24),0,sin(a*TAU/24))*(part.collider_radius+1.6)
				var d: float = Layout.dist_to_trails(Vector2(p.x,p.z))
				if d<best_d: best_d=d; best=p
			game.player.global_position=best
			game.player.moving=false
			game.world.player_camera.recenter()
			await shot("%02d-%s-%s" % [index,group.id,part.asset])
	quit()
