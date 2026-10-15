extends SceneTree
## Actual Godot shared-material preview with idle/grazing pivot poses.
func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	root.size=Vector2i(1400,1000)
	var world:=Node3D.new()
	root.add_child(world)
	var environment:=WorldEnvironment.new()
	environment.environment=Environment.new()
	environment.environment.background_mode=Environment.BG_COLOR
	environment.environment.background_color=Color("282638")
	environment.environment.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color=Color("dad6eb")
	environment.environment.ambient_light_energy=.65
	world.add_child(environment)
	var sun:=DirectionalLight3D.new()
	sun.rotation_degrees=Vector3(-42,-30,0)
	sun.light_energy=1.25
	sun.shadow_enabled=true
	world.add_child(sun)
	var ground:=MeshInstance3D.new()
	ground.mesh=PlaneMesh.new()
	ground.mesh.size=Vector2(20,20)
	var mat:=StandardMaterial3D.new()
	mat.albedo_color=Color("9b99b4")
	mat.roughness=1
	ground.material_override=mat
	world.add_child(ground)
	var animals:Array=[]
	for id in ["rabbit","deer"]:
		var animal:Node3D=load("res://scenes/props/nature/"+id+".tscn").instantiate()
		animal.position.x=-.7 if id=="rabbit" else .35
		animal.rotation.y=-.35
		world.add_child(animal)
		animals.append(animal)
	var camera:=Camera3D.new()
	camera.projection=Camera3D.PROJECTION_ORTHOGONAL
	camera.size=3.35
	camera.position=Vector3(2.8,2.1,4)
	world.add_child(camera)
	camera.look_at(Vector3(0,.65,0))
	for pose in ["idle","grazing"]:
		for animal:Node3D in animals:
			animal.get_node("Body/Head").rotation.x=0 if pose=="idle" else .45
		for frame in 8:await process_frame
		await RenderingServer.frame_post_draw
		var path:=ProjectSettings.globalize_path("res://../output/jobs-update-v01/wildlife-godot-"+pose+".png")
		var error:=root.get_texture().get_image().save_png(path)
		print("WILDLIFE_GODOT_PREVIEW ",pose," ",error)
		if error!=OK:
			quit(1)
			return
	quit()
