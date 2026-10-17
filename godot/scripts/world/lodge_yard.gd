extends Node3D
## 산장 앞마당(A안): 중앙 모닥불 쉼터, 감시탑 건설 예약 공터 2곳, 제단 건설 예약 공터 1곳.
## 모닥불은 밤에 돌아온 일꾼·대기 용병이 모이는 생활 중심이다(Layout.rest_slots). 회복·버프·생산 기능은 없다.
## 공터는 모서리 돌·둘레 돌로 자리만 읽히게 한 빈 예약 공간이다(충돌 없음, 건설 규칙은 별도).

const Cfg := preload("res://scripts/config.gd")
const Layout := preload("res://scripts/world/layout.gd")
const B := preload("res://scripts/visual/build.gd")
const Mats := preload("res://scripts/visual/mats.gd")
const Models := preload("res://scripts/visual/models.gd")
const Nature := preload("res://scripts/visual/nature_models.gd")
const Fx := preload("res://scripts/visual/fx.gd")
const VfxPool := preload("res://scripts/visual/vfx/vfx_pool.gd")

const C_FLAME := Color(1.0, 0.62, 0.22)
const C_EMBER := Color(1.0, 0.42, 0.12)
const C_STONE := Color("8e8798")
const C_DIRT := Color("7f6d5c")

var campfire: Node3D
var fire_light: OmniLight3D
var site_nodes: Array = []
var _flames: Array = []
var _t := 0.0
var _spark_t := 0.0
var _rng := RandomNumberGenerator.new()


func build(world) -> void:
	name = "LodgeYard"
	_rng.seed = 20261018
	_build_campfire(world)
	for c in [Layout.TOWER_SITE_LEFT, Layout.TOWER_SITE_RIGHT]:
		site_nodes.append(_build_tower_site(c))
	site_nodes.append(_build_altar_site())


# ───────────────────────── 모닥불 쉼터 ─────────────────────────

func _build_campfire(world) -> void:
	campfire = B.node(self, Layout.CAMPFIRE, Vector3.ZERO, "Campfire")
	# 불·돌 둘레 충돌: 아무도 불 위를 지나지 않는다.
	var body := StaticBody3D.new()
	body.name = "CampfireBody"
	body.collision_layer = Cfg.L_OBSTACLE
	body.collision_mask = 0
	body.position = Layout.CAMPFIRE
	var cs := CollisionShape3D.new()
	var cyl := CylinderShape3D.new()
	cyl.radius = Layout.CAMPFIRE_RADIUS
	cyl.height = 1.0
	cs.shape = cyl
	cs.position.y = 0.5
	body.add_child(cs)
	world.nav_region.add_child(body)
	# 둘레 돌 8개
	for i in 8:
		var a := TAU * i / 8.0 + 0.3
		var stone := Models.make_stepping_stone(_rng)
		stone.scale = Vector3(0.55, 0.9, 0.5)
		stone.position = Vector3(cos(a), 0, sin(a)) * 0.78
		stone.rotation_degrees.y = rad_to_deg(-a) + _rng.randf_range(-15, 15)
		campfire.add_child(stone)
	# 장작과 불꽃
	var wood := Models.make_firewood()
	wood.scale = Vector3(0.8, 0.8, 0.8)
	wood.rotation_degrees.y = 25
	campfire.add_child(wood)
	var ember := Mats.glow(C_EMBER, 2.5)
	B.cyl(campfire, 0.3, 0.42, 0.12, Vector3(0, 0.26, 0), ember, 8)
	for i in 3:
		var a := TAU * i / 3.0
		var fl := B.cyl(campfire, 0.0, 0.22 - i * 0.03, 0.9 - i * 0.12, Vector3(cos(a) * 0.12, 0.7, sin(a) * 0.12), Mats.glow(C_FLAME, 5.0), 7)
		fl.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		_flames.append(fl)
	fire_light = B.omni(campfire, Vector3(0, 1.1, 0), Color(1.0, 0.64, 0.3), 1.3, 7.5)
	# 통나무 의자 둘, 도끼, 바구니 — 일꾼 쉼터 소품(소량)
	for seat in [[-1.75, 0.55, 78.0], [1.45, 1.15, -28.0]]:
		var log_prop := Models.make_log()
		log_prop.position = Vector3(seat[0], 0, seat[1])
		log_prop.rotation_degrees.y = seat[2]
		log_prop.scale = Vector3.ONE * 0.72
		campfire.add_child(log_prop)
	_axe(campfire, Vector3(-1.35, 0, -0.95), -40.0)
	_basket(campfire, Vector3(1.55, 0, -0.65))


func _axe(parent: Node3D, at: Vector3, yaw: float) -> void:
	var root := B.node(parent, at, Vector3(0, yaw, 0), "Axe")
	var wood := Mats.solid(Color("7a5236"), {"noise_amount": 0.05})
	var steel := Mats.solid(Color("a9adb8"), {"rim_strength": 0.3})
	var stump := Models.make_firewood()
	stump.scale = Vector3(0.55, 0.9, 0.55)
	root.add_child(stump)
	B.box(root, Vector3(0.07, 0.07, 0.78), Vector3(0.0, 0.52, 0.0), wood, Vector3(-55, 0, 0))
	B.box(root, Vector3(0.05, 0.26, 0.2), Vector3(0.0, 0.8, 0.26), steel, Vector3(-55, 0, 0))


func _basket(parent: Node3D, at: Vector3) -> void:
	var root := B.node(parent, at, Vector3.ZERO, "Basket")
	var wicker := Mats.solid(Color("b48a5e"), {"noise_amount": 0.1})
	B.cyl(root, 0.3, 0.24, 0.34, Vector3(0, 0.17, 0), wicker, 9)
	B.cyl(root, 0.33, 0.3, 0.05, Vector3(0, 0.36, 0), Mats.solid(Color("8e6a44")), 9)
	B.sphere(root, 0.1, Vector3(0.05, 0.4, -0.04), Mats.solid(Color("c94f3f")), Vector3.ONE, 8, 4)
	B.sphere(root, 0.09, Vector3(-0.1, 0.4, 0.06), Mats.solid(Color("d8b35a")), Vector3.ONE, 8, 4)


# ───────────────────────── 건설 예약 공터 ─────────────────────────

func _build_tower_site(center: Vector2) -> Node3D:
	var site := B.node(self, Vector3(center.x, 0, center.y), Vector3.ZERO, "TowerSite")
	site.set_meta("reserved_site", "tower")
	var half := Layout.TOWER_SITE_SIZE * 0.5
	var dirt := Mats.solid(C_DIRT, {"noise_amount": 0.22, "rim_strength": 0.0})
	var patch := B.box(site, Vector3(Layout.TOWER_SITE_SIZE - 0.5, 0.03, Layout.TOWER_SITE_SIZE - 0.5), Vector3(0, 0.012, 0), dirt)
	patch.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var stone := Mats.solid(C_STONE, {"noise_amount": 0.08, "rim_strength": 0.15, "top_snow": 0.7, "snow_color": Color("f2f0ff")})
	for sx in [-1.0, 1.0]:
		for sz in [-1.0, 1.0]:
			var h := _rng.randf_range(0.36, 0.5)
			B.bevel_box(site, Vector3(0.5, h, 0.5), Vector3(sx * half, h * 0.5, sz * half), stone, 0.05,
				Vector3(0, _rng.randf_range(-12, 12), 0))
	return site


func _build_altar_site() -> Node3D:
	var c := Layout.ALTAR_SITE
	var site := B.node(self, Vector3(c.x, 0, c.y), Vector3.ZERO, "AltarSite")
	site.set_meta("reserved_site", "altar")
	var dirt := Mats.solid(C_DIRT, {"noise_amount": 0.22, "rim_strength": 0.0})
	var disc := B.cyl(site, Layout.ALTAR_SITE_RADIUS - 0.35, Layout.ALTAR_SITE_RADIUS - 0.35, 0.035, Vector3(0, 0.015, 0), dirt, 20)
	disc.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for i in 8:
		var a := TAU * i / 8.0 + 0.15
		var stone := Models.make_stepping_stone(_rng)
		stone.scale = Vector3(0.95, 1.6, 0.8)
		stone.position = Vector3(cos(a), 0, sin(a)) * Layout.ALTAR_SITE_RADIUS
		stone.rotation_degrees.y = rad_to_deg(-a) + 90 + _rng.randf_range(-10, 10)
		site.add_child(stone)
	return site


# ───────────────────────── 불꽃 애니메이션 ─────────────────────────

func _process(delta: float) -> void:
	_t += delta
	for i in _flames.size():
		var f: MeshInstance3D = _flames[i]
		var s := 1.0 + sin(_t * 9.0 + i * 2.1) * 0.14 + sin(_t * 23.0 + i) * 0.05
		f.scale = Vector3(1.0 + sin(_t * 7.0 + i) * 0.06, s, 1.0 - sin(_t * 7.0 + i) * 0.06)
		f.rotation.y = _t * 1.6 + i
	if fire_light != null:
		fire_light.light_energy = 1.3 + sin(_t * 11.0) * 0.12 + sin(_t * 27.0) * 0.06
	_spark_t -= delta
	if _spark_t <= 0.0 and Fx.pool != null:
		_spark_t = _rng.randf_range(0.18, 0.4)
		var at: Vector3 = Layout.CAMPFIRE + Vector3(_rng.randf_range(-0.15, 0.15), 0.9, _rng.randf_range(-0.15, 0.15))
		Fx.pool.emit(VfxPool.SPARKLE, at, Vector3(_rng.randf_range(-0.3, 0.3), _rng.randf_range(1.4, 2.4), _rng.randf_range(-0.3, 0.3)),
			_rng.randf_range(0.6, 1.1), 0.09, C_EMBER, {"additive": true, "drag": 1.2, "gravity": -0.6})
