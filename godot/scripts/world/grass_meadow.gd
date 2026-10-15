extends RefCounted
## Wind-waved grass clumps poking through the snow around the lodge (GrassField).
## Built after the forest so tree/rock colliders can be kept clear. Visual only: no collision, no nav effect.
const Layout := preload("res://scripts/world/layout.gd")
const Cfg := preload("res://scripts/config.gd")
const GraveyardScript := preload("res://scripts/world/graveyard.gd")
const WeatherVfx := preload("res://scripts/visual/vfx/weather_vfx.gd")

const FIELD_SIZE := 60.0 # round field, radius 30 m around the map centre
const TRAIL_CLEAR := 1.8 # m kept clear on each side of trail centre lines
const WALK_CLEAR := 1.5 # door -> stepping stones -> east trail, the path the witch walks most
## Colour tones, cycled in game with F6 (HUD) or chosen with the `grass_tone=<id>` user arg.
## Waves read through small value/hue shifts and darker troughs; only `frost` keeps the old white glint.
const TONES := [
	{"id": "moss", "name": "이끼 숲", "color_root": Color(.035, .09, .09), "color_tip": Color(.20, .38, .30),
		"color_dry": Color(.33, .38, .30), "color_sheen": Color(.28, .47, .34), "flower_a": Color(.66, .62, .82),
		"flower_b": Color(.62, .72, .86), "sheen_amount": .5, "trough_shade": .22, "toon_mix": .45, "translucency": .25, "variation": .4},
	{"id": "winter_straw", "name": "겨울 마른풀", "color_root": Color(.05, .10, .10), "color_tip": Color(.33, .42, .29),
		"color_dry": Color(.62, .51, .32), "color_sheen": Color(.55, .55, .38), "flower_a": Color(.86, .82, .70),
		"flower_b": Color(.76, .70, .82), "sheen_amount": .45, "trough_shade": .25, "toon_mix": .4, "translucency": .35, "variation": .6},
	{"id": "dusk_sage", "name": "황혼 세이지", "color_root": Color(.06, .07, .14), "color_tip": Color(.30, .44, .38),
		"color_dry": Color(.50, .42, .58), "color_sheen": Color(.40, .52, .48), "flower_a": Color(.72, .62, .86),
		"flower_b": Color(.60, .70, .88), "sheen_amount": .45, "trough_shade": .2, "toon_mix": .5, "translucency": .2, "variation": .5},
	{"id": "evergreen", "name": "깊은 상록", "color_root": Color(.02, .07, .07), "color_tip": Color(.12, .30, .26),
		"color_dry": Color(.19, .28, .28), "color_sheen": Color(.18, .39, .33), "flower_a": Color(.64, .72, .92),
		"flower_b": Color(.78, .66, .90), "sheen_amount": .55, "trough_shade": .3, "toon_mix": .6, "translucency": .3, "variation": .35},
	{"id": "frost", "name": "서리 청록 (이전)", "color_root": Color(.04, .11, .12), "color_tip": Color(.22, .48, .41),
		"color_dry": Color(.46, .48, .62), "color_sheen": Color(.80, .87, 1.0), "flower_a": Color(.70, .82, 1.0),
		"flower_b": Color(.86, .64, 1.0), "sheen_amount": .7, "trough_shade": 0.0, "toon_mix": 1.0, "translucency": 0.0, "variation": .45},
]
static var tone_index := 0

static func apply_tone(grass: GrassField, index: int) -> String:
	tone_index = posmod(index, TONES.size())
	var tone: Dictionary = TONES[tone_index]
	for k in tone:
		if k != "id" and k != "name": grass.shader_material.set_shader_parameter(k, tone[k])
	return tone.name

static func build(world) -> GrassField:
	var blocked := _obstacles(world)
	var pasture_rect: Rect2 = Cfg.PASTURE_LEVELS[-1].rect
	var keep := [Layout.LODGE_RECT.grow(.7), Layout.EXTENSION_RECT.grow(.7), pasture_rect.grow(.6),
		Rect2(1.7, -6.3, 5.3, 2.7)] # graveyard plots
	for p: Vector3 in GraveyardScript.PLOTS:
		keep[3] = keep[3].expand(Vector2(p.x, p.z))
	var walk := [Vector2(Layout.DOOR_FRONT.x, Layout.DOOR_FRONT.z)]
	for s in Layout.STEPPING_STONES: walk.append(Vector2(s[0], s[1]))
	walk.append(Layout.PATH_B[0])
	var grass := GrassField.new()
	grass.name = "GrassMeadow"
	grass.size = Vector2(FIELD_SIZE, FIELD_SIZE)
	grass.position = Vector3(Layout.MAP_CENTER.x, 0, Layout.MAP_CENTER.y)
	grass.round_edge = true
	grass.chunk_size = 15.0 # sparse field: fewer, larger chunks keep draw calls low
	grass.height_range = Vector2(.13, .58) # knee height for the SD witch
	grass.clump_spacing = 3.4
	grass.open_ground = .38 # leave plenty of snow showing
	grass.clump_density = 16.0 # tight clumps with snow between them
	grass.meadow_density = .15
	grass.visibility_end = 0.0 # the game camera sits ~45 m away; the field is bounded anyway
	grass.keep_out = func(p: Vector2) -> bool:
		if preload("res://scripts/world/hazard_sites.gd").clearing_at(p): return true
		for r: Rect2 in keep:
			if r.has_point(p): return true
		if p.distance_to(Vector2(Layout.DOOR_FRONT.x, Layout.DOOR_FRONT.z)) < 1.8: return true
		if Layout.dist_to_path(p, walk) < WALK_CLEAR: return true
		for landmark in Layout.LANDMARKS:
			if p.distance_to(landmark.pos) < 4.0: return true
		for o: Vector3 in blocked:
			if p.distance_to(Vector2(o.x, o.y)) < o.z: return true
		return Layout.dist_to_trails(p) < TRAIL_CLEAR
	world.add_child(grass)
	var m := grass.shader_material
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("grass_tone="):
			var id := arg.get_slice("=", 1)
			for i in TONES.size():
				if TONES[i].id == id: tone_index = i
	apply_tone(grass, tone_index)
	m.set_shader_parameter("wind_direction", Vector2(WeatherVfx.WIND.x, WeatherVfx.WIND.z)) # same drift as the snowfall
	m.set_shader_parameter("fade_distance", Vector2(90, 110))
	return grass

## Trees and rocks as (x, z, clear radius).
static func _obstacles(world) -> Array[Vector3]:
	var out: Array[Vector3] = []
	for body in world.nav_region.get_children():
		if not (body is StaticBody3D) or not (body.collision_layer & Cfg.L_OBSTACLE): continue
		var radius := .5
		for cs in body.get_children():
			if cs is CollisionShape3D and cs.shape is CylinderShape3D: radius = maxf(radius, cs.shape.radius)
		out.append(Vector3(body.position.x, body.position.z, radius + .45))
	return out
