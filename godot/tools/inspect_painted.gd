extends SceneTree
const Painted = preload("res://scripts/visual/painted_models.gd")
func _initialize():
	call_deferred("capture")
func capture():
	var scene = Node3D.new()
	root.add_child(scene)
	var args = OS.get_cmdline_user_args()
	var id = "witch_body"
	for a in args:
		if a.begins_with("--asset="): id = a.substr(8)
	for i in range(2):
		var model: Node3D = load("res://assets/painted/"+id+".glb").instantiate() if i==0 else Painted.asset(id)
		model.position.x = (-3.5 if i==0 else 3.5) if id=="snow_pine" else (-1.1 if i==0 else 1.1)
		scene.add_child(model)
		for ch in model.get_children():
			if ch is MeshInstance3D: print(ch.name," ",ch.get_aabb())
	var env = Environment.new()
	env.background_mode=Environment.BG_COLOR
	env.background_color=Color(.17,.18,.23)
	env.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color=Color(.8,.8,.9)
	env.ambient_light_energy=.8
	var we=WorldEnvironment.new(); we.environment=env; scene.add_child(we)
	var light=DirectionalLight3D.new();light.rotation_degrees=Vector3(-50,130,0);scene.add_child(light)
	var cam=Camera3D.new();cam.projection=Camera3D.PROJECTION_ORTHOGONAL;cam.size=3.0;scene.add_child(cam)
	cam.position=Vector3(3,4,6);cam.look_at(Vector3(0,.7,0));cam.current=true
	if id=="snow_pine":
		cam.size=9.0;cam.position=Vector3(5,12,18);cam.look_at(Vector3(0,3.0,0))
	await create_timer(.5).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://screenshots/art-refinement/inspect-"+id+".png")
	quit()
