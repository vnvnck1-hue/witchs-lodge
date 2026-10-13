extends Node3D
## World: 바닥·본채·목장·숲·조명·카메라·내비게이션.
## 라이팅 구성(승인 원화 기준):
##  - 환경광(보라·인디고)이 그림자 쪽 전체를 채워 "그림자 = 짙은 보라"가 되게 한다.
##  - 달빛(연한 라벤더) 방향광 하나로 넓은 명암과 부드러운 그림자.
##  - 창문·벽등의 앰버 옴니 라이트를 작은 범위에 모아 눈밭에 따뜻한 빛 웅덩이를 만든다.
##  - 글로우로 창문 번짐, 후처리로 가장자리 인디고 비네트.

const Cfg := preload("res://scripts/config.gd")
const Layout := preload("res://scripts/world/layout.gd")
const B := preload("res://scripts/visual/build.gd")
const Mats := preload("res://scripts/visual/mats.gd")
const Models := preload("res://scripts/visual/models.gd")
const LodgeScript := preload("res://scripts/world/lodge.gd")
const PastureScript := preload("res://scripts/world/pasture.gd")
const GROUND_SHADER := preload("res://shaders/painted_ground.gdshader")
const GROUND_PAINT := preload("res://assets/painted/ground_cleanplate.png")
const POST_SHADER := preload("res://shaders/post_grade.gdshader")
const OUTLINE_SHADER := preload("res://shaders/toon_outline.gdshader")
const ScreenStyle := preload("res://scripts/visual/screen_style.gd")
signal screen_style_changed(id: String)

# 기존 화면 초기화 값. 실제 런타임 값은 visual/screen_style.gd의 프리셋에서 조정.
# 원화 측정값(sRGB) 기준: 햇빛 든 눈 ≈ (145,142,228), 그림자 눈 ≈ (83,93,198), 문 앞 빛 웅덩이 ≈ (237,175,133)
# → 선형 공간에서 그림자 = 알베도×환경광, 밝은 면 = 알베도×(환경광+달빛)이 되도록 역산한 값.
const AMBIENT_COLOR := Color(0.65, 0.69, 0.93)
const AMBIENT_ENERGY := 0.65
const MOON_COLOR := Color(0.94, 0.92, 1.0)
const MOON_ENERGY := 0.60
const MOON_ROT := Vector3(-64.0, 145.0, 0.0)

var game
var camera: Camera3D
var nav_region: NavigationRegion3D
var lodge
var pasture
var sun: DirectionalLight3D
var env: Environment
var ground_mat: ShaderMaterial
var post_mat: ShaderMaterial
var outline_mat: ShaderMaterial
var outline_mesh: MeshInstance3D
var debug_draw := false
## 벌목 가능한 자원 나무(장식 숲 전체가 아님). {pos, body, visual, remaining, reserved}
var harvest_trees: Array = []
var _shake_t := 0.0
var _shake_amp := 0.0
var _rng := RandomNumberGenerator.new()


func build(g) -> void:
	game = g
	_rng.seed = 20261013
	_build_environment()
	_build_camera()
	nav_region = NavigationRegion3D.new()
	nav_region.name = "NavRegion"
	add_child(nav_region)
	var nm := NavigationMesh.new()
	nm.geometry_parsed_geometry_type = NavigationMesh.PARSED_GEOMETRY_STATIC_COLLIDERS
	nm.geometry_collision_mask = Cfg.L_GROUND | Cfg.L_OBSTACLE | Cfg.L_BOUNDARY
	nm.agent_radius = 0.5
	nm.agent_height = 1.25
	nm.agent_max_climb = 0.25
	nm.cell_size = 0.25
	nm.cell_height = 0.25
	nm.filter_baking_aabb = AABB(Vector3(-32, -2, -32), Vector3(64, 6, 64))
	nav_region.navigation_mesh = nm
	_build_ground()
	lodge = LodgeScript.new()
	lodge.name = "Lodge"
	lodge.game = game
	nav_region.add_child(lodge)
	pasture = PastureScript.new()
	pasture.game = game
	nav_region.add_child(pasture)
	_build_forest()
	_build_props()
	_build_boundary()
	_build_fx()
	_build_post()
	set_screen_style(ScreenStyle.current_id)
	bake_nav()


func set_screen_style(id: String) -> bool:
	if not ScreenStyle.apply(self,id): return false
	screen_style_changed.emit(id)
	return true


func bake_nav() -> void:
	nav_region.bake_navigation_mesh(false)


# ───────────────────────── 환경·조명·카메라 ─────────────────────────

func _build_environment() -> void:
	env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("2b2552")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = AMBIENT_COLOR
	env.ambient_light_energy = AMBIENT_ENERGY
	env.reflected_light_source = Environment.REFLECTION_SOURCE_DISABLED
	env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	env.tonemap_exposure = 1.0
	env.glow_enabled = true
	env.glow_intensity = 0.55
	env.glow_strength = 1.0
	env.glow_bloom = 0.0
	env.glow_hdr_threshold = 1.0
	env.glow_hdr_scale = 2.0
	env.glow_blend_mode = Environment.GLOW_BLEND_MODE_SCREEN
	for i in 7:
		env.set_glow_level(i, 1.0 if i in [1, 2, 3, 4] else 0.0)
	env.ssao_enabled = true
	env.ssao_radius = 1.4
	env.ssao_intensity = 1.8
	env.ssao_power = 1.4
	env.ssao_detail = 0.4
	env.ssao_light_affect = 0.15
	env.adjustment_enabled = true
	env.adjustment_saturation = 1.0
	env.adjustment_contrast = 1.0
	env.adjustment_brightness = 1.0
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)

	sun = DirectionalLight3D.new()
	sun.name = "Moonlight"
	sun.light_color = MOON_COLOR
	sun.light_energy = MOON_ENERGY
	sun.light_specular = 0.0
	sun.rotation_degrees = MOON_ROT
	sun.shadow_enabled = true
	sun.shadow_opacity = 0.85
	sun.shadow_blur = 1.6
	sun.light_angular_distance = 2.5
	sun.shadow_bias = 0.18
	sun.shadow_normal_bias = 1.2
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	sun.directional_shadow_max_distance = 90.0
	add_child(sun)


func _build_camera() -> void:
	camera = Camera3D.new()
	camera.name = "Camera"
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = Layout.CAMERA_SIZE
	camera.near = 1.0
	camera.far = 140.0
	camera.rotation_degrees = Vector3(-Layout.CAMERA_PITCH, Layout.CAMERA_YAW, 0)
	add_child(camera)
	camera.position = Layout.CAMERA_TARGET + camera.transform.basis.z * Layout.CAMERA_DISTANCE
	camera.current = true


func shake(amount: float, duration: float) -> void:
	_shake_amp = maxf(_shake_amp, amount)
	_shake_t = maxf(_shake_t, duration)


func _process(delta: float) -> void:
	if _shake_t > 0.0:
		_shake_t -= delta
		var a := _shake_amp * clampf(_shake_t / 0.3, 0.0, 1.0)
		camera.h_offset = randf_range(-a, a)
		camera.v_offset = randf_range(-a, a)
		if _shake_t <= 0.0:
			camera.h_offset = 0.0
			camera.v_offset = 0.0
			_shake_amp = 0.0


# ───────────────────────── 바닥·숲·프랍 ─────────────────────────

func _build_ground() -> void:
	var body := StaticBody3D.new()
	body.name = "Ground"
	body.collision_layer = Cfg.L_GROUND
	body.collision_mask = 0
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(64, 1, 64)
	cs.shape = bs
	# 내비메시는 걷는 면 위로 2칸(0.5m) 올라가 구워지므로, 바닥 충돌을 0.5m 내려 경로 높이를 y=0에 맞춘다
	cs.position.y = -1.0
	body.add_child(cs)
	nav_region.add_child(body)

	var plane := PlaneMesh.new()
	plane.size = Vector2(120, 120)
	ground_mat = ShaderMaterial.new()
	ground_mat.shader = GROUND_SHADER
	ground_mat.set_shader_parameter("cleanplate", GROUND_PAINT)
	ground_mat.set_shader_parameter("reference_center", Layout.CAMERA_TARGET)
	ground_mat.set_shader_parameter("reference_right", camera.transform.basis.x)
	ground_mat.set_shader_parameter("reference_up", camera.transform.basis.y)
	ground_mat.set_shader_parameter("reference_size", Vector2(Layout.CAMERA_SIZE*2.0,Layout.CAMERA_SIZE))
	var mi := MeshInstance3D.new()
	mi.name = "SnowGround"
	mi.mesh = plane
	mi.material_override = ground_mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)


## 화면 좌표(오른쪽 sx, 아래 sy; 지면 기준 m)로 변환 — 보이는 영역 판단용.
func _screen_xy(p: Vector2) -> Vector2:
	var d := p - Vector2(Layout.CAMERA_TARGET.x, Layout.CAMERA_TARGET.z)
	return Vector2((d.x - d.y) * 0.7071, (d.x + d.y) * 0.7071)


func _add_tree(p: Vector2, h: float) -> Dictionary:
	var body := StaticBody3D.new()
	body.collision_layer = Cfg.L_OBSTACLE
	body.collision_mask = 0
	body.position = Vector3(p.x, 0, p.y)
	var cs := CollisionShape3D.new()
	var cyl := CylinderShape3D.new()
	cyl.radius = 0.4
	cyl.height = 2.0
	cs.shape = cyl
	cs.position.y = 1.0
	body.add_child(cs)
	var v := Models.make_pine(h, _rng)
	v.rotation_degrees.y = _rng.randf_range(0, 360)
	body.add_child(v)
	nav_region.add_child(body)
	return {"pos": body.position, "body": body, "visual": v, "remaining": 0, "reserved": null}


func _build_forest() -> void:
	for t in Layout.TREES:
		var p := Vector2(t[0], t[1])
		var tree := _add_tree(p, t[2])
		for h in Cfg.HARVEST_TREES:
			if p.distance_to(Vector2(h[0], h[1])) < 0.05:
				tree["remaining"] = Cfg.TREE_TIMBER
				harvest_trees.append(tree)


## 목재가 바닥난 자원 나무: 눈에 띄게 줄어든 그루터기 쪽으로 낮춘다(충돌·경로는 그대로).
func deplete_tree(tree: Dictionary) -> void:
	var v: Node3D = tree["visual"]
	var tw := v.create_tween()
	tw.tween_property(v, "scale", Vector3(0.85, 0.55, 0.85), 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _build_props() -> void:
	for r in Layout.ROCKS:
		var body := StaticBody3D.new()
		body.collision_layer = Cfg.L_OBSTACLE
		body.collision_mask = 0
		body.position = Vector3(r[0], 0, r[1])
		var cs := CollisionShape3D.new()
		var cyl := CylinderShape3D.new()
		cyl.radius = 1.35 * r[2]
		cyl.height = 1.6 * r[2]
		cs.shape = cyl
		cs.position.y = 0.8 * r[2]
		body.add_child(cs)
		body.add_child(Models.make_rock(r[2], _rng))
		nav_region.add_child(body)
	var decor := B.node(self, Vector3.ZERO, Vector3.ZERO, "Decor")
	for s in Layout.SHRUBS:
		var shrub := Models.make_shrub(_rng)
		shrub.position = Vector3(s[0], 0, s[1])
		decor.add_child(shrub)
	for l in Layout.LOGS:
		var lg := Models.make_log()
		lg.position = Vector3(l[0], 0, l[1])
		lg.rotation_degrees.y = l[2]
		decor.add_child(lg)
	for st in Layout.STEPPING_STONES:
		var stone := Models.make_stepping_stone(_rng)
		stone.scale = Vector3(1.5,1.0,1.4)
		stone.position = Vector3(st[0], 0, st[1])
		decor.add_child(stone)


## 숲 경계: 반지름 16m 원을 따라 보이지 않는 벽. 두 숲길의 안쪽 끝만 열어 둔다.
func _build_boundary() -> void:
	var body := StaticBody3D.new()
	body.name = "ForestBoundary"
	body.collision_layer = Cfg.L_BOUNDARY
	body.collision_mask = 0
	nav_region.add_child(body)
	var n := 72
	var c := Vector2(Layout.CAMERA_TARGET.x, Layout.CAMERA_TARGET.z)
	for i in n:
		var a := TAU * (i + 0.5) / n
		var p := c + Vector2(cos(a), sin(a)) * Layout.BOUNDARY_RADIUS
		if Layout.dist_to_paths(p, 2) < 2.6:
			continue
		var cs := CollisionShape3D.new()
		var bs := BoxShape3D.new()
		bs.size = Vector3(0.6, 2.0, TAU * Layout.BOUNDARY_RADIUS / n + 0.3)
		cs.shape = bs
		cs.position = Vector3(p.x, 1.0, p.y)
		cs.rotation.y = -a
		body.add_child(cs)


# ───────────────────────── 눈·연기·후처리 ─────────────────────────

func _build_fx() -> void:
	# 눈 내림: 작고 성긴 입자. 플레이 영역 가독성을 해치지 않게 밀도를 낮게 유지.
	var snow := GPUParticles3D.new()
	snow.name = "Snowfall"
	snow.process_mode = Node.PROCESS_MODE_ALWAYS
	snow.amount = 120
	snow.lifetime = 10.0
	snow.preprocess = 10.0
	snow.visibility_aabb = AABB(Vector3(-40, -20, -40), Vector3(80, 40, 80))
	var pm := ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = Vector3(26, 0.5, 26)
	pm.direction = Vector3(0.25, -1, 0.1)
	pm.spread = 12.0
	pm.initial_velocity_min = 1.0
	pm.initial_velocity_max = 1.6
	pm.gravity = Vector3(0, -0.15, 0)
	pm.turbulence_enabled = true
	pm.turbulence_noise_strength = 0.6
	pm.turbulence_noise_scale = 6.0
	pm.turbulence_influence_min = 0.02
	pm.turbulence_influence_max = 0.06
	pm.scale_min = 0.3
	pm.scale_max = 0.65
	snow.process_material = pm
	var q := QuadMesh.new()
	q.size = Vector2(0.11, 0.11)
	q.material = Mats.particle(Color(0.95, 0.94, 1.0, 0.85))
	snow.draw_pass_1 = q
	snow.position = Layout.CAMERA_TARGET + Vector3(0, 13, 0)
	add_child(snow)

	# 굴뚝 연기: 따뜻한 빛을 머금은 복숭아색 → 라벤더로 흩어짐
	var smoke := GPUParticles3D.new()
	smoke.name = "ChimneySmoke"
	smoke.process_mode = Node.PROCESS_MODE_ALWAYS
	smoke.amount = 70
	smoke.lifetime = 6.5
	smoke.preprocess = 6.5
	smoke.local_coords = false
	smoke.visibility_aabb = AABB(Vector3(-6, -2, -6), Vector3(12, 14, 12))
	var spm := ParticleProcessMaterial.new()
	spm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	spm.emission_sphere_radius = 0.12
	spm.direction = Vector3(0, 1, 0)
	spm.spread = 8.0
	spm.initial_velocity_min = 0.9
	spm.initial_velocity_max = 1.15
	spm.gravity = Vector3(-0.1, 0.08, -0.16)
	spm.turbulence_enabled = true
	spm.turbulence_noise_strength = 1.4
	spm.turbulence_noise_scale = 3.0
	spm.turbulence_noise_speed_random = 0.2
	spm.turbulence_influence_min = 0.06
	spm.turbulence_influence_max = 0.12
	spm.scale_min = 0.8
	spm.scale_max = 1.1
	var sc := Curve.new()
	sc.add_point(Vector2(0.0, 0.3))
	sc.add_point(Vector2(0.5, 0.75))
	sc.add_point(Vector2(1.0, 1.3))
	var sct := CurveTexture.new()
	sct.curve = sc
	spm.scale_curve = sct
	var grad := Gradient.new()
	grad.set_color(0, Color(1.0, 0.72, 0.45, 0.0))
	grad.set_color(1, Color(0.7, 0.66, 0.95, 0.0))
	grad.add_point(0.1, Color(1.0, 0.66, 0.4, 0.7))
	grad.add_point(0.5, Color(0.95, 0.68, 0.6, 0.42))
	var gt := GradientTexture1D.new()
	gt.gradient = grad
	spm.color_ramp = gt
	smoke.process_material = spm
	var sq := QuadMesh.new()
	sq.size = Vector2(0.7, 0.7)
	sq.material = Mats.particle(Color(1, 1, 1, 1))
	smoke.draw_pass_1 = sq
	smoke.position = Layout.CHIMNEY_TOP
	add_child(smoke)


func _build_post() -> void:
	outline_mesh = MeshInstance3D.new()
	outline_mesh.name = "ToonOutline"
	var quad := QuadMesh.new()
	quad.size = Vector2(2,2)
	outline_mesh.mesh = quad
	outline_mesh.extra_cull_margin = 16384.0
	outline_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	outline_mesh.position.z = -2.0
	outline_mat = ShaderMaterial.new()
	outline_mat.shader = OUTLINE_SHADER
	outline_mat.render_priority = 127
	outline_mesh.material_override = outline_mat
	outline_mesh.visible = false
	camera.add_child(outline_mesh)
	var layer := CanvasLayer.new()
	layer.name = "PostGrade"
	layer.layer = 1
	add_child(layer)
	var rect := ColorRect.new()
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var m := ShaderMaterial.new()
	m.shader = POST_SHADER
	post_mat = m
	rect.material = m
	layer.add_child(rect)


# ───────────────────────── 입력 도우미 ─────────────────────────

func show_click_marker(pos: Vector3) -> void:
	var m := Mats.unshaded(Color(0.85, 0.8, 1.0, 0.9), true, true)
	var ring := B.torus(self, 0.32, 0.42, pos + Vector3(0, 0.05, 0), m)
	ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	ring.scale = Vector3(1.2, 0.2, 1.2)
	var tw := ring.create_tween().set_parallel(true)
	tw.tween_property(ring, "scale", Vector3(0.4, 0.2, 0.4), 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(m, "albedo_color:a", 0.0, 0.45)
	tw.chain().tween_callback(ring.queue_free)
