extends Node
## Depth fog after lighting, including particles. Keeps the playable focus clear.
## Camera-relative range follows the focus/zoom rather than a fixed camera distance.
const Layout := preload("res://scripts/world/layout.gd")
const Styles := preload("res://scripts/visual/screen_style.gd")
const IDS := ["off", "soft", "dramatic"]
const NAMES := ["없음 · 비교용", "은은한 공기", "극적인 공기"]
const DEFAULT_ID := "dramatic"
static var current_id := DEFAULT_ID
var world
var _last_params := Vector4(-1,-1,-1,-1)
var color_bleed_enabled := true
var light_sources: Array = []
var base_color := Color(.43,.49,.65)
var _color_elapsed := 1.0

static func profile(id: String) -> Dictionary:
	if id == "soft":
		return {"begin_offset":1.0,"end_offset":18.0,"curve":1.2,"density":.48,"color":Color(.43,.49,.65)}
	return {"begin_offset":-2.0,"end_offset":12.0,"curve":1.1,"density":.76 if id == "dramatic" else 0.0,"color":Color(.43,.49,.65)}

func bind(owner_world) -> void:
	world = owner_world
	process_mode = Node.PROCESS_MODE_ALWAYS
	process_priority = 20 # after the existing follow camera (10)
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--air=") and arg.trim_prefix("--air=") in IDS:
			current_id = arg.trim_prefix("--air=")
		if arg == "--air-color=uniform": color_bleed_enabled = false
	configure(current_id)

func configure(id: String) -> bool:
	if id not in IDS: return false
	current_id = id
	var p := profile(id)
	world.env.fog_enabled = id != "off"
	world.env.fog_mode = Environment.FOG_MODE_DEPTH
	world.env.fog_density = p.density
	world.env.fog_depth_curve = p.curve
	world.env.fog_light_color = p.color
	world.env.fog_light_energy = 1.0
	world.env.fog_sun_scatter = 0.0
	world.env.fog_aerial_perspective = 0.0 # BG_COLOR has no sky radiance to sample.
	world.env.fog_height_density = 0.0
	sync_colors()
	sync_camera()
	return true

func sync_camera() -> void:
	if world == null: return
	var focus := Layout.CAMERA_TARGET
	if world.player_camera != null and world.player_camera.follow_enabled:
		focus = world.player_camera.focus
	var distance: float = world.camera.global_position.distance_to(focus)
	var p := profile(current_id)
	var params := Vector4(maxf(1.0,distance+p.begin_offset),distance+p.end_offset,p.curve,p.density)
	if params.is_equal_approx(_last_params): return
	_last_params = params
	world.env.fog_depth_begin = params.x
	world.env.fog_depth_end = params.y
	# Screen-space outlines must fade with the actual surface depth, not the quad depth.
	world.outline_mat.set_shader_parameter("air_fog_params",params)
	RenderingServer.global_shader_parameter_set("air_depth_params",params)

func sync_colors() -> void:
	if world == null: return
	var style := Styles.profile(Styles.current_id)
	base_color = Color(.44,.34,.65).lerp(style.ambient_color,.35) if color_bleed_enabled else Color(.43,.49,.65)
	if world.day_cycle != null and color_bleed_enabled:
		# Keep depth/range/density exactly as selected; only track the changing ambient hue.
		base_color = world.env.ambient_light_color.lerp(base_color,world.day_cycle.night_amount)
	var linear := base_color.srgb_to_linear()
	RenderingServer.global_shader_parameter_set("air_base_color",Vector4(linear.r,linear.g,linear.b,1.0 if color_bleed_enabled else 0.0))
	light_sources.clear()
	var focus: Vector3 = world.player_camera.focus if world.player_camera != null and world.player_camera.follow_enabled else Layout.CAMERA_TARGET
	var lights: Array = world.find_children("*","OmniLight3D",true,false)
	lights.sort_custom(func(a,b): return a.light_energy/(1.0+a.global_position.distance_to(focus)/maxf(a.omni_range,.01)) > b.light_energy/(1.0+b.global_position.distance_to(focus)/maxf(b.omni_range,.01)))
	for light in lights:
		if not light.is_visible_in_tree() or light.light_energy <= 0.0: continue
		var c: Color = light.light_color.srgb_to_linear()
		light_sources.append({"position":light.global_position,"range":light.omni_range*2.0,"color":c,"energy":clampf(light.light_energy*.30,0.0,1.1)})
		if light_sources.size() == 12: break
	for packet in 3:
		var positions: Array[Vector4] = []
		var colors: Array[Vector4] = []
		for i in 4:
			var index := packet*4+i
			if index < light_sources.size():
				var source: Dictionary = light_sources[index]
				var p: Vector3 = source.position
				var c: Color = source.color
				positions.append(Vector4(p.x,p.y,p.z,source.range))
				colors.append(Vector4(c.r,c.g,c.b,source.energy))
			else:
				positions.append(Vector4.ZERO)
				colors.append(Vector4.ZERO)
		var suffix: String = ["a","b","c"][packet]
		RenderingServer.global_shader_parameter_set("air_positions_"+suffix,Projection(positions[0],positions[1],positions[2],positions[3]))
		RenderingServer.global_shader_parameter_set("air_colors_"+suffix,Projection(colors[0],colors[1],colors[2],colors[3]))
	# Standard materials/particles use a focus-area average of the same light colors.
	world.env.fog_light_color = color_at(focus-world.camera.global_basis.z*8.0).linear_to_srgb()

func color_at(pos: Vector3) -> Color:
	var sum := Vector3.ZERO
	var weight := 0.0
	for source in light_sources:
		var t: float = clampf(pos.distance_to(source.position)/source.range,0.0,1.0)
		var falloff := 1.0-t*t*(3.0-2.0*t)
		var w: float = falloff*falloff*source.energy
		var c: Color = source.color
		sum += Vector3(c.r,c.g,c.b)*w
		weight += w
	var base := base_color.srgb_to_linear()
	var tint := Color(sum.x/maxf(weight,.001),sum.y/maxf(weight,.001),sum.z/maxf(weight,.001))
	return base.lerp(tint,(1.0-exp(-weight*1.5))*.8 if color_bleed_enabled else 0.0)

func _process(delta: float) -> void:
	sync_camera()
	_color_elapsed += delta
	if _color_elapsed >= .25:
		_color_elapsed = 0.0
		sync_colors()
