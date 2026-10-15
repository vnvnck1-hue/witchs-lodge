extends SceneTree
var scene: Node3D
var camera: Camera3D
func _initialize() -> void: call_deferred("_run")
func capture(id: String) -> void:
	for i in 12: await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../output/user-cottage/"+id+".png"))
func _run() -> void:
	scene=Node3D.new()
	root.add_child(scene)
	var env:=Environment.new()
	env.background_mode=Environment.BG_COLOR
	env.background_color=Color("aeb7c8")
	env.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color=Color("c9d6ed")
	env.ambient_light_energy=.65
	var we:=WorldEnvironment.new()
	we.environment=env
	scene.add_child(we)
	var sun:=DirectionalLight3D.new()
	sun.rotation_degrees=Vector3(-50,-30,0)
	sun.light_energy=1.2
	sun.shadow_enabled=true
	scene.add_child(sun)
	var names:=["left","middle","right"]
	for i in 3:
		var state:=GLTFState.new()
		var doc:=GLTFDocument.new()
		var path:=ProjectSettings.globalize_path("res://../art/models/user-cottage/candidate-"+names[i]+".glb")
		assert(doc.append_from_file(path,state)==OK)
		var model:=doc.generate_scene(state)
		model.scale=Vector3.ONE*17.0
		model.position.x=(i-1)*7.0
		scene.add_child(model)
		var label:=Label3D.new()
		label.text=names[i]
		label.font_size=72
		label.pixel_size=.006
		label.position=Vector3((i-1)*7.0,5.9,0)
		label.billboard=BaseMaterial3D.BILLBOARD_ENABLED
		scene.add_child(label)
	camera=Camera3D.new()
	camera.projection=Camera3D.PROJECTION_ORTHOGONAL
	camera.size=12.0
	scene.add_child(camera)
	camera.position=Vector3(0,12,22)
	camera.look_at(Vector3(0,2,0))
	await capture("candidates-front")
	camera.position=Vector3(0,12,-22)
	camera.look_at(Vector3(0,2,0))
	await capture("candidates-back")
	print("COTTAGE_INSPECTION complete")
	quit()
