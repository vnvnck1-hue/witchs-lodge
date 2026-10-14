extends SceneTree
## An unlit neutral surface changes color only through the custom fog, never direct lighting.
const OUT := "C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/output/colored-air/"
var failures: Array[String] = []

func _initialize() -> void:
	create_timer(45.0,true,false,true).timeout.connect(func(): push_error("Color air check timed out"); quit(2))
	call_deferred("_run")

func check(ok: bool,message: String) -> void:
	if not ok: failures.append(message); push_error(message)

func capture(name: String) -> Image:
	for frame in 4: await process_frame
	await RenderingServer.frame_post_draw
	var image:=root.get_texture().get_image()
	check(image.save_png(OUT+name+".png")==OK,"Capture failed")
	return image

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	var game=load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	for frame in 3: await process_frame
	game.world.player_camera.toggle_overview()
	game.process_mode=Node.PROCESS_MODE_DISABLED
	var air=game.world.aerial_perspective
	air.set_process(false)
	game.world.set_camera_style("lens_balanced")
	game.world.set_screen_style("toon_neon")
	game.world.set_air_style("dramatic")
	var camera: Camera3D=game.world.camera
	var old_mask:=camera.cull_mask
	camera.cull_mask=1 << 19
	var depth: float=camera.global_position.distance_to(Vector3(1,0,1.3))+12.0
	var pos:=camera.project_position(root.get_visible_rect().size*Vector2(.50,.40),depth)
	var mesh:=MeshInstance3D.new()
	mesh.layers=1 << 19
	var quad:=QuadMesh.new()
	quad.size=Vector2(3,3)
	mesh.mesh=quad
	mesh.transform=Transform3D(camera.global_basis,pos)
	var shader:=Shader.new()
	shader.code="shader_type spatial; render_mode unshaded;\n#include \"res://shaders/colored_air.gdshaderinc\"\nvoid fragment(){ ALBEDO=vec3(.5); FOG=colored_air((INV_VIEW_MATRIX*vec4(VERTEX,1.0)).xyz,VERTEX,INV_VIEW_MATRIX[3].xyz); }"
	var material:=ShaderMaterial.new()
	material.shader=shader
	mesh.material_override=material
	game.add_child(mesh)
	var light:=OmniLight3D.new()
	light.name="AirTestLight"
	light.light_energy=20.0
	light.omni_range=12.0
	light.position=pos
	game.world.add_child(light)
	light.light_color=Color(1,.04,.45)
	air.sync_colors()
	var magenta:=sample(await capture("probe-magenta"))
	light.light_color=Color(.03,.65,1)
	air.sync_colors()
	var cyan:=sample(await capture("probe-cyan"))
	check(magenta.r-cyan.r > .08 and cyan.g-magenta.g > .08,"Local light did not tint actual unlit fog surface")
	air.color_bleed_enabled=false
	light.light_color=Color(1,.04,.45)
	air.sync_colors()
	var uniform_magenta:=sample(await capture("probe-uniform-magenta"))
	light.light_color=Color(.03,.65,1)
	air.sync_colors()
	var uniform_cyan:=sample(await capture("probe-uniform-cyan"))
	check(delta(uniform_magenta,uniform_cyan)<.001,"Uniform comparison still responds to light")
	air.color_bleed_enabled=true
	game.world.set_air_style("off")
	light.light_color=Color(1,.04,.45)
	air.sync_colors()
	var clear_magenta:=sample(await capture("probe-off-magenta"))
	light.light_color=Color(.03,.65,1)
	air.sync_colors()
	var clear_cyan:=sample(await capture("probe-off-cyan"))
	check(delta(clear_magenta,clear_cyan)<.001,"Air off leaves colored tint")
	light.queue_free()
	mesh.queue_free()
	await process_frame
	camera.cull_mask=old_mask
	game.world.set_air_style("dramatic")
	game.world.set_screen_style("toon_neon")
	var neon_color: Color=air.base_color
	var neon_sources: int=air.light_sources.size()
	game.world.set_screen_style("toon_strong")
	check(not air.base_color.is_equal_approx(neon_color),"Style did not refresh base air color")
	check(air.light_sources.size()<neon_sources,"Disabled neon sources leaked into strong toon")
	game.world.set_screen_style("toon_neon")
	var sources: Array=air.light_sources.duplicate(true)
	game.world.set_camera_style("lens_soft")
	air.sync_colors()
	check(air.light_sources==sources,"Lens moved world-space air colors")
	game.world.set_camera_style("lens_balanced")
	air.color_bleed_enabled=false
	air.sync_colors()
	await capture("source-uniform")
	air.color_bleed_enabled=true
	air.sync_colors()
	await capture("source-local-color")
	var report:={"passed":failures.is_empty(),"neutral_surface_magenta":magenta,"neutral_surface_cyan":cyan,"color_difference":delta(magenta,cyan),"uniform_color_difference":delta(uniform_magenta,uniform_cyan),"air_off_color_difference":delta(clear_magenta,clear_cyan),"light_sources":air.light_sources.size(),"checks":["actual fog responds to light color","unlit surface isolates fog","uniform comparison stable","air off has no tint","style refresh","disabled light cleanup","lens preserves world color field"],"failures":failures}
	var file:=FileAccess.open(OUT+"color-verification.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t"))
	print("COLORED_AIR passed=",failures.is_empty()," difference=",delta(magenta,cyan)," failures=",failures)
	quit(0 if failures.is_empty() else 1)

func sample(image: Image) -> Color:
	var at:=Vector2i(Vector2(image.get_size())*Vector2(.50,.40))
	var sum:=Color(0,0,0,0)
	for y in range(-4,5):
		for x in range(-4,5): sum+=image.get_pixelv(at+Vector2i(x,y))
	return sum/81.0

func delta(a: Color,b: Color) -> float:
	return (absf(a.r-b.r)+absf(a.g-b.g)+absf(a.b-b.b))/3.0
