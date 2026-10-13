extends RefCounted
## Runtime screen presets. Shader globals also cover actors spawned after switching.

const IDS := ["soft", "warm", "moon", "toon", "toon_strong", "toon_outline", "original"]
const NAMES := ["부드러운 명암", "따뜻한 산장", "차가운 숲", "툰 셰이딩", "강렬한 툰 셰이딩", "두꺼운 툰 외곽선", "기존 화면"]
static var current_id := "soft"

static func profile(id: String) -> Dictionary:
	var p := {
		"ambient": .42, "moon": .88, "ambient_color": Color(.65,.69,.93),
		"moon_color": Color(.94,.92,1.0), "glow": .22, "ao": 1.0, "ao_radius": .85,
		"shadow_blur": 1.1, "angular": 1.4, "shadow_opacity": .90,
		"shading": Vector4(.58,.065,.08,0.0),
		"surface": Vector4(.28,.60,.65,.075),
		"palette": Vector4(1,1,1,.10), "saturation": 1.0,
		"warm_ground": 1.0, "ink": Vector4(.16,1,0,0), "outline_width": 0.0
	}
	match id:
		"warm":
			p.merge({"ambient": .46, "moon": .84, "moon_color": Color(1.0,.96,.91),
				"glow": .30, "shading": Vector4(.48,.085,.12,0),
				"palette": Vector4(1.04,1.01,.97,.18), "warm_ground": 1.10}, true)
		"moon":
			p.merge({"ambient": .34, "moon": .94, "ambient_color": Color(.58,.64,.91),
				"moon_color": Color(.86,.92,1.0), "glow": .18,
				"shading": Vector4(.68,.055,.05,0), "surface": Vector4(.32,.62,.55,.10),
				"palette": Vector4(.97,1.01,1.04,.06), "warm_ground": .90}, true)
		"toon":
			p.merge({"ambient": .27, "moon": 1.05, "glow": .12,
				"ao": .65, "ao_radius": .65, "angular": .9, "shadow_blur": .9,
				"shading": Vector4(1.0,.018,.015,1.0),
				"surface": Vector4(.72,.85,.40,.22), "palette": Vector4(1.02,1.02,1.02,.16),
				"saturation": 1.06}, true)
		"original":
			p.merge({"ambient": .65, "moon": .60, "glow": .55, "ao": 1.8,
				"ao_radius": 1.4, "angular": 2.5, "shadow_blur": 1.6, "shadow_opacity": .85,
				"shading": Vector4(0,.065,.32,0), "surface": Vector4(1,1,1,0),
				"palette": Vector4(1,1,1,0)}, true)
		"toon_strong", "toon_outline":
			p.merge({"ambient": .12, "moon": 1.16, "glow": .06,
				"ao": .45, "ao_radius": .55, "angular": .45, "shadow_blur": .65,
				"shading": Vector4(1,.005,0,1), "surface": Vector4(1,1,.10,.32),
				"palette": Vector4(1.04,1.02,1.04,.22), "saturation": 1.17,
				"ink": Vector4(.035,.45,0,0),
				"outline_width": 3.0 if id == "toon_outline" else 0.0}, true)
	return p

static func apply(world, id: String) -> bool:
	if id not in IDS: return false
	current_id = id
	var p := profile(id)
	RenderingServer.global_shader_parameter_set("card_style_shading", p.shading)
	RenderingServer.global_shader_parameter_set("card_style_surface", p.surface)
	RenderingServer.global_shader_parameter_set("card_style_palette", p.palette)
	RenderingServer.global_shader_parameter_set("card_style_ink", p.ink)
	world.outline_mesh.visible = p.outline_width > 0.0
	world.outline_mat.set_shader_parameter("width_pixels", p.outline_width)
	world.env.ambient_light_color = p.ambient_color
	world.env.ambient_light_energy = p.ambient
	world.sun.light_color = p.moon_color
	world.sun.light_energy = p.moon
	world.sun.shadow_opacity = p.shadow_opacity
	world.sun.shadow_blur = p.shadow_blur
	world.sun.light_angular_distance = p.angular
	world.env.glow_intensity = p.glow
	world.env.ssao_radius = p.ao_radius
	world.env.ssao_intensity = p.ao
	world.env.ssao_power = 1.4 if id == "original" else 1.2
	world.ground_mat.set_shader_parameter("warm_enabled", p.warm_ground)
	world.post_mat.set_shader_parameter("saturation", p.saturation)
	return true
