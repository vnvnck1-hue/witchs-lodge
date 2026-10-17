extends SceneTree
## Exercises real physics, keyboard, click/mini-map picking and the follow rig.
const Layout := preload("res://scripts/world/layout.gd")
const Cameras := preload("res://scripts/visual/camera_style.gd")
const Styles := preload("res://scripts/visual/screen_style.gd")
const OUT := "res://../output/exploration/"
var failures: Array[String] = []
var records: Array = []
var game
var render := "--render" in OS.get_cmdline_user_args()
var pack := "--pack" in OS.get_cmdline_user_args()


func _initialize() -> void:
	create_timer(60.0,true,false,true).timeout.connect(func(): push_error("Exploration check timed out"); quit(2))
	call_deferred("_run")


func check(ok: bool, message: String) -> void:
	if not ok:
		failures.append(message)
		push_error(message)


func ticks(count: int) -> void:
	for i in count: await physics_frame
	await process_frame


func capture(id: String) -> void:
	if not render: return
	var prior := Engine.time_scale
	Engine.time_scale = 1.0
	game.player.moving = false
	for i in 25: await process_frame
	await RenderingServer.frame_post_draw
	var folder := ProjectSettings.globalize_path(OUT)
	check(root.get_texture().get_image().save_png(folder+("pack-" if pack else "")+id+".png")==OK,"capture "+id)
	Engine.time_scale = prior


func walk_to(dest: Vector3, label: String) -> void:
	game.player.set_destination(dest)
	var arrived := false
	for frame in 900:
		await physics_frame
		var at: Vector3 = game.player.global_position
		check(Vector2(at.x,at.z).distance_to(Layout.MAP_CENTER)<=Layout.BOUNDARY_RADIUS,"outside map "+label)
		if at.distance_to(dest)<.65:
			arrived=true
			break
	await ticks(12)
	var screen: Vector2 = game.world.camera.unproject_position(game.player.global_position+Vector3(0,.8,0))
	var norm := screen/Vector2(root.get_visible_rect().size)
	check(arrived,"failed to reach "+label+": "+str(game.player.global_position))
	check(norm.x>.25 and norm.x<.75 and norm.y>.25 and norm.y<.75,"camera lost player "+label)
	records.append({"place":label,"arrived":arrived,"position":game.player.global_position,"player_screen":norm})
	await capture(label)


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	game=load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await ticks(6)
	# Freeze the countdown only; actor movement, collision, camera and HUD still run.
	game.session.set_process(false)
	Engine.time_scale=4.0
	check(game.world.player_camera.follow_enabled,"follow default missing")
	check(Layout.BOUNDARY_RADIUS==38.0,"map not expanded")
	check(game.world.nav_region.navigation_mesh.get_polygon_count()>0,"empty navigation bake")
	await capture("start")
	var nav_map: RID = game.get_world_3d().navigation_map
	# A안 이후 충돌체가 늘어 내비메시 동기화가 몇 프레임 더 걸린다. 경로가 실제로 나올 때까지 기다린다.
	for i in 400:
		NavigationServer3D.map_force_update(nav_map)
		if NavigationServer3D.map_get_path(nav_map,Layout.DOOR_FRONT,Layout.DOOR_FRONT+Vector3(0,0,4),true).size()>1: break
		await physics_frame
	var home := Layout.DOOR_FRONT
	for landmark in Layout.LANDMARKS:
		var p: Vector2=landmark.pos
		var dest:=Vector3(p.x,0,p.y)
		var path := NavigationServer3D.map_get_path(nav_map,home,dest,true)
		check(path.size()>1 and Vector2(path[-1].x,path[-1].z).distance_to(p)<.7,"disconnected landmark "+landmark.id)
		await walk_to(dest,landmark.id)
	await walk_to(home,"home")
	# Projected real click and card ground picking at an expanded map location, all five lenses.
	game.player.position=Vector3(-24,0,5)
	game.player.moving=false
	game.world.player_camera.recenter()
	for lens in Cameras.IDS:
		game.world.set_camera_style(lens)
		await ticks(3)
		var cam: Camera3D=game.world.camera
		var p:=Vector3(-22,0,7)
		var event:=InputEventMouseButton.new()
		event.button_index=MOUSE_BUTTON_LEFT
		event.pressed=true
		event.position=cam.unproject_position(p)
		game._unhandled_input(event)
		check(game.player.agent.target_position.distance_to(p)<.7,"expanded click pick "+lens)
		var resolved: Vector3=game.resolver._ground_at(cam.unproject_position(p))
		check(resolved.distance_to(p)<.001,"expanded card ground pick "+lens)
		var pos:=cam.global_position
		game.world.set_screen_style("toon_neon")
		check(pos.distance_to(cam.global_position)<.001,"style moved camera")
		game.player.moving=false
	game.world.set_camera_style(Cameras.DEFAULT_ID)
	game.world.set_screen_style(Styles.DEFAULT_ID)
	# Real keyboard action state: camera-relative movement, normalized diagonal and click cancellation.
	game.player.position=Vector3(-24,0,5)
	game.world.player_camera.recenter()
	game.player.set_destination(home)
	var before: Vector3=game.player.position
	Input.action_press("walk_right")
	await ticks(12)
	Input.action_release("walk_right")
	var moved: Vector3=game.player.position-before
	check(moved.dot(game.world.camera.global_basis.x)>.7,"keyboard not camera relative")
	check(not game.player.moving,"keyboard did not cancel click path")
	Input.action_press("walk_up")
	Input.action_press("walk_right")
	await ticks(1)
	check(game.player.velocity.length()<=3.501,"diagonal speed boost")
	Input.action_release("walk_up")
	Input.action_release("walk_right")
	await ticks(2)
	before=game.player.position
	await ticks(8)
	check(game.player.position.distance_to(before)<.01,"keyboard release left movement")
	# Tree collision on a near-home trunk; keyboard cannot cross the obstacle.
	var near_tree := Vector3(Layout.TREES[0][0],0,Layout.TREES[0][1])
	game.player.position=near_tree+Vector3(0,0,-2.1)
	game.world.player_camera.recenter()
	var tree_at:=near_tree
	for i in 45:
		game.player.velocity=(tree_at-game.player.position).normalized()*3.5
		game.player.move_and_slide()
		check(Vector2(game.player.position.x-tree_at.x,game.player.position.z-tree_at.z).length()>.65,"tree collision failed")
	# Closed ring: attempt to move out at eight directions.
	for i in 8:
		var d:=Vector2.from_angle(TAU*i/8.0)
		game.player.position=Vector3(Layout.MAP_CENTER.x+d.x*36.5,0,Layout.MAP_CENTER.y+d.y*36.5)
		for step in 18:
			game.player.velocity=Vector3(d.x,0,d.y)*3.5
			game.player.move_and_slide()
		check(Vector2(game.player.position.x,game.player.position.z).distance_to(Layout.MAP_CENTER)<38.1,"boundary collision failed")
	game.player.position=Vector3(-24,0,5)
	game.player.velocity=Vector3.ZERO
	game.world.player_camera.recenter()
	# Trees between lens and witch fade individually and restore in overview.
	var down: Vector3 = game.world.camera.global_basis.z
	down.y=0.0
	game.player.position=near_tree-down.normalized()*2.6
	game.world.player_camera.recenter()
	await ticks(10)
	var faded:=false
	for tree in game.world.camera_occluders:
		if tree.fade>.5: faded=true
	check(faded,"tree occlusion did not fade")
	game.world.player_camera.toggle_overview()
	await ticks(10)
	for tree in game.world.camera_occluders: check(tree.fade<.01,"tree fade not restored in overview")
	game.world.player_camera.recenter()
	game.player.position=Vector3(-24,0,5)
	game.world.player_camera.recenter()
	# Minimap uses its actual GUI handler and inverse screen-aligned coordinates.
	var mini=game.hud.exploration_map
	var mb:=InputEventMouseButton.new()
	mb.button_index=MOUSE_BUTTON_LEFT
	mb.pressed=true
	mb.position=mini._map_point(Vector2(8,-26))
	mini._gui_input(mb)
	check(game.player.agent.target_position.distance_to(Vector3(8,0,-26))<.7,"mini-map target failed")
	game.player.moving=false
	# Wheel bounds, F4 overview, lens changes, and return to follow.
	game.world.player_camera.zoom(-100)
	await ticks(25)
	check(is_equal_approx(game.world.player_camera.desired_height,12.0),"min zoom")
	game.world.player_camera.zoom(100)
	await ticks(25)
	check(is_equal_approx(game.world.player_camera.desired_height,28.0),"max zoom")
	var f4:=InputEventKey.new()
	f4.keycode=KEY_F4
	f4.pressed=true
	game.hud._unhandled_input(f4)
	check(not game.world.player_camera.follow_enabled,"F4 overview")
	check(game.world.camera.unproject_position(Layout.CAMERA_TARGET).distance_to(Vector2(root.get_visible_rect().size)*.5)<.01,"overview focus")
	game.world.set_camera_style("lens_balanced")
	game.hud._unhandled_input(f4)
	check(game.world.player_camera.follow_enabled and game.world.camera.projection==Camera3D.PROJECTION_PERSPECTIVE,"lens/follow restore")
	# Pause blocks action polling and direct movement commands.
	paused=true
	before=game.player.position
	var prior_target: Vector3=game.player.agent.target_position
	Input.action_press("walk_up")
	await ticks(5)
	game._unhandled_input(mb)
	check(game.player.position==before and game.player.agent.target_position==prior_target,"pause accepted movement")
	Input.action_release("walk_up")
	paused=false
	# HUD controls remain visible and mini-map stays separate at narrower/wider sizes.
	for viewport_size in [Vector2i(1200,900),Vector2i(1920,1080)]:
		root.size=viewport_size
		await ticks(3)
		check(mini.get_global_rect().end.x<=root.get_visible_rect().size.x+1,"mini-map outside viewport")
		check(not mini.get_global_rect().intersects(game.hud.camera_select.get_global_rect()),"mini-map/menu overlap")
	root.size=Vector2i(1774,887)
	game.player.position=Layout.PLAYER_START
	game.world.player_camera.height=18.0
	game.world.player_camera.desired_height=18.0
	game.world.set_camera_style(Cameras.DEFAULT_ID)
	game.world.player_camera.recenter()
	await capture("final-start")
	var report:={"passed":failures.is_empty(),"radius":Layout.BOUNDARY_RADIUS,"walks":records,
		"rendered":render,"checks":["landmark navigation connectivity","actual walking to four clearings and home","five lenses + click + card ground picking","WASD camera direction","normalized diagonals","keyboard release and click cancellation","tree collision","closed boundary at eight directions","tree occlusion fade/restore","mini-map click","zoom bounds","F4 overview/lens restore","pause","resized HUD"],"failures":failures}
	report["packed_runtime"]=pack
	var file:=FileAccess.open(OUT+("pack-verification.json" if pack else "verification.json"),FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t"))
	print("EXPLORATION_VERIFY passed=",failures.is_empty()," walks=",records.size()," failures=",failures)
	quit(0 if failures.is_empty() else 1)
