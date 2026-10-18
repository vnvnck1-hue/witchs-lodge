extends RefCounted
## 기본 도형으로 조립한 블록아웃 모델. 승인 원화의 실루엣·색면을 따르며
## 나중에 GLB로 교체할 때는 이 함수의 반환 노드만 바꾸면 된다(게임 로직은 래퍼에 있음).

const B := preload("res://scripts/visual/build.gd")
const Cfg := preload("res://scripts/config.gd")
const Mats := preload("res://scripts/visual/mats.gd")
const Painted := preload("res://scripts/visual/painted_models.gd")
const Nature := preload("res://scripts/visual/nature_models.gd")

# 팔레트 — 퍼플 설경, 짙은 초록 나무, 앰버 빛
const C_SNOW := Color("e0dcff")
const C_PINE := Color("3f9472")
const C_PINE_DARK := Color("16392f")
const C_TRUNK := Color("4b3026")
const C_ROCK := Color("9a9e8e")
const C_ROCK_DARK := Color("858a7c")
const C_STONE := Color("8e7f72")
const C_STONE_LIGHT := Color("a49a90")
const C_PLINTH := Color("807b78")
const C_TIMBER := Color("6e4229")
const C_TIMBER_DARK := Color("4a2b1c")
const C_DOOR := Color("5e3820")
const C_ROOF_SNOW := Color("f2f0ff")
const C_CHIMNEY := Color("8e8a88")
const C_WARM := Color(1.0, 0.68, 0.36)
const C_WINDOW := Color(1.0, 0.68, 0.32)
const C_HAY := Color("d8a646")
const C_FENCE := Color("6f4a31")
const C_WOOL := Color("efe7da")
const C_SHEEP_FACE := Color("3b3236")
const C_ROBE := Color("4d2f8a")
const C_HAT := Color("5b3aa8")
const C_SKIN := Color("f2c8a6")
const C_HAIR := Color("3a2456")
const C_GOLD := Color("e2b24e")
const C_STAFF := Color("6b4a2c")
const C_MONSTER := Color("2b2443")
const C_MONSTER_LIGHT := Color("4a3d6e")
const C_MONSTER_EYE := Color(0.6, 1.0, 0.45)
const C_DRAGON := Color("8c2433")
const C_DRAGON_DARK := Color("5e1724")
const C_BELLY := Color("d68c54")
const C_HORN := Color("eadcb8")
const C_TRAVELER := Color("7d5b3c")
const C_PACK := Color("8e5d2e")
const C_HOOD := Color("5d5070")
const C_SHRUB := Color("7b3b33")
const C_BERRY := Color("b8443a")
const C_BARREL := Color("7a4b2c")
const C_METAL := Color("3c3a40")


static func snow_mat() -> ShaderMaterial:
	return Mats.solid(C_SNOW, {"noise_amount": 0.04, "rim_strength": 0.3})


# ───────────────────────── 환경 프랍 ─────────────────────────

static func make_pine(h: float, rng: RandomNumberGenerator) -> Node3D:
	return Nature.pine(h, rng)


static func _blockout_pine(h: float, rng: RandomNumberGenerator) -> Node3D:
	var root := Node3D.new()
	var trunk_h := h * 0.22
	var s := h / 6.5
	B.cyl(root, 0.15 * s, 0.25 * s, trunk_h, Vector3(0, trunk_h * 0.5, 0), Mats.solid(C_TRUNK), 6)
	var tiers := 5
	var base_y := trunk_h * 0.6
	var span := h - base_y
	var green := Mats.solid(C_PINE, {"noise_amount": 0.1, "rim_strength": 0.25, "rim_color": Color(0.6, 0.9, 0.85)})
	var tree_snow := Mats.solid(C_SNOW, {"noise_amount": 0.04, "rim_strength": 0.3, "sky_fill": 0.4})
	for i in tiers:
		var t := float(i) / float(tiers - 1)
		var r := lerpf(1.65, 0.55, t) * s
		var top_r := 0.0 if i == tiers - 1 else r * 0.3
		var th := span * (0.3 if i < tiers - 1 else 0.34)
		var y0 := base_y + span * t * 0.68
		var yaw := rng.randf_range(0.0, 60.0)
		var tilt := Vector3(rng.randf_range(-4, 4), yaw, rng.randf_range(-4, 4))
		B.cyl(root, top_r, r, th, Vector3(0, y0 + th * 0.5, 0), green, 8, tilt)
		# 눈: 각 단의 윗어깨에만 얹은 각진 덩어리(초록 테두리가 남도록)
		var k := 0.62 if i < tiers - 2 else 0.8
		var sh := th * k
		var sr := (top_r + (r - top_r) * k) * 1.06
		# 눈은 화면 위(-X-Z) 쪽으로 살짝 치우쳐 쌓여, 카메라 쪽 아랫단에 초록이 더 드러난다
		var lean := Vector3(-0.07, 0, -0.07) * r
		B.cyl(root, top_r * 1.08, sr, sh, Vector3(0, y0 + th - sh * 0.5 + 0.035 * s, 0) + lean, tree_snow, 8, Vector3(tilt.x, yaw + 22.5, tilt.z))
	return root


static func make_rock(size: float, rng: RandomNumberGenerator) -> Node3D:
	return Nature.rock(size, rng)


static func _blockout_rock(size: float, rng: RandomNumberGenerator) -> Node3D:
	var root := Node3D.new()
	var rock := Mats.solid(C_ROCK, {"noise_amount": 0.08, "rim_strength": 0.3, "sky_fill": 0.3, "wrap": 0.7})
	var rock2 := Mats.solid(C_ROCK_DARK, {"noise_amount": 0.08, "rim_strength": 0.3, "sky_fill": 0.3, "wrap": 0.7})
	var snow := snow_mat()
	var s := size
	# [위치, 아래 덩어리 크기, 위 덩어리 크기]
	var chunks := [
		[Vector3(0, 0, 0), Vector3(1.7, 1.1, 1.5), Vector3(1.25, 0.75, 1.1), rock],
		[Vector3(1.0, 0, 0.7), Vector3(0.95, 0.7, 0.9), Vector3(0.65, 0.4, 0.6), rock2],
		[Vector3(-0.85, 0, 0.8), Vector3(0.6, 0.45, 0.55), Vector3.ZERO, rock2],
	]
	for c in chunks:
		var p: Vector3 = c[0] * s
		var lo: Vector3 = c[1] * s
		var hi: Vector3 = c[2] * s
		var n := B.node(root, p, Vector3(rng.randf_range(-6, 6), rng.randf_range(-30.0, 30.0), rng.randf_range(-6, 6)))
		B.box(n, lo, Vector3(0, lo.y * 0.5, 0), c[3])
		var top := lo.y
		var cap := lo
		if hi != Vector3.ZERO:
			var u := B.node(n, Vector3(rng.randf_range(-0.1, 0.1) * lo.x, lo.y, 0), Vector3(rng.randf_range(-5, 5), rng.randf_range(15, 30), rng.randf_range(-5, 5)))
			B.box(u, hi, Vector3(0, hi.y * 0.5 - 0.05 * s, 0), c[3])
			B.sphere(u, 0.5, Vector3(0, hi.y + 0.02 * s, 0), snow, Vector3(hi.x * 1.25, 0.36 * s, hi.z * 1.2), 8, 4)
		else:
			B.sphere(n, 0.5, Vector3(0, top + 0.02 * s, 0), snow, Vector3(cap.x * 1.2, 0.3 * s, cap.z * 1.15), 8, 4)
	return root


static func make_shrub(rng: RandomNumberGenerator) -> Node3D:
	return Nature.asset("berry_shrub")


static func _blockout_shrub(rng: RandomNumberGenerator) -> Node3D:
	var root := Node3D.new()
	var twig := Mats.solid(C_SHRUB, {"noise_amount": 0.0})
	var berry := Mats.solid(C_BERRY)
	for i in 7:
		var a := float(i) / 7.0 * 360.0 + rng.randf_range(-15, 15)
		var tilt := rng.randf_range(18.0, 38.0)
		var h := rng.randf_range(0.6, 0.95)
		var stem := B.node(root, Vector3.ZERO, Vector3(0, a, 0))
		var inner := B.node(stem, Vector3.ZERO, Vector3(tilt, 0, 0))
		B.cyl(inner, 0.015, 0.035, h, Vector3(0, h * 0.5, 0), twig, 5)
		B.sphere(inner, 0.05, Vector3(0, h, 0), berry, Vector3.ONE, 6, 3)
	B.sphere(root, 0.32, Vector3(0, 0.02, 0), snow_mat(), Vector3(1.3, 0.25, 1.3), 8, 4)
	return root


static func make_log() -> Node3D:
	return Nature.asset("fallen_log")


static func _blockout_log() -> Node3D:
	var root := Node3D.new()
	B.cyl(root, 0.32, 0.32, 2.4, Vector3(0, 0.32, 0), Mats.solid(C_TIMBER, {"noise_amount": 0.05}), 9, Vector3(0, 0, 90))
	for x: float in [-1.21, 1.21]:
		B.cyl(root, 0.27, 0.27, 0.04, Vector3(x, 0.32, 0), Mats.solid(Color("b48a5e")), 9, Vector3(0, 0, 90))
	B.box(root, Vector3(1.9, 0.12, 0.42), Vector3(0.1, 0.64, 0), snow_mat())
	B.sphere(root, 0.25, Vector3(0.6, 0.66, 0), snow_mat(), Vector3(2.0, 0.5, 1.1), 8, 4)
	return root


static func make_barrel() -> Node3D:
	return Painted.asset("barrel")


static func _blockout_barrel() -> Node3D:
	var root := Node3D.new()
	B.cyl(root, 0.3, 0.3, 0.82, Vector3(0, 0.41, 0), Mats.solid(C_BARREL), 10)
	B.cyl(root, 0.335, 0.335, 0.4, Vector3(0, 0.41, 0), Mats.solid(C_BARREL), 10)
	for y: float in [0.16, 0.66]:
		B.cyl(root, 0.322, 0.322, 0.06, Vector3(0, y, 0), Mats.solid(C_METAL), 10)
	B.cyl(root, 0.27, 0.29, 0.08, Vector3(0, 0.86, 0), snow_mat(), 10)
	return root


static func make_firewood() -> Node3D:
	return Painted.asset("firewood")


static func _blockout_firewood() -> Node3D:
	var root := Node3D.new()
	var wood := Mats.solid(C_TIMBER)
	var end := Mats.solid(Color("b48a5e"))
	var rows := [[-0.24, 0.0, 0.24], [-0.12, 0.12]]
	for r in rows.size():
		for z in rows[r]:
			var y := 0.12 + r * 0.21
			B.cyl(root, 0.11, 0.11, 0.9, Vector3(0, y, z), wood, 7, Vector3(0, 0, 90))
			B.cyl(root, 0.095, 0.095, 0.02, Vector3(0.455, y, z), end, 7, Vector3(0, 0, 90))
	B.box(root, Vector3(0.85, 0.06, 0.32), Vector3(0, 0.5, 0), snow_mat())
	return root


static func make_hay() -> Node3D:
	return Painted.asset("hay_bale")


static func _blockout_hay() -> Node3D:
	var root := Node3D.new()
	var hay := Mats.solid(C_HAY, {"noise_amount": 0.06, "rim_strength": 0.1})
	B.cyl(root, 0.38, 0.38, 0.95, Vector3(0, 0.38, 0), hay, 10, Vector3(0, 0, 90))
	B.box(root, Vector3(0.75, 0.08, 0.42), Vector3(0, 0.76, 0), snow_mat())
	return root


static func make_stepping_stone(rng: RandomNumberGenerator) -> Node3D:
	var v := Painted.asset("step_stone")
	v.rotation_degrees.y=rng.randf_range(-12,12)
	return v


static func _blockout_stepping_stone(rng: RandomNumberGenerator) -> Node3D:
	var root := Node3D.new()
	var m := Mats.solid(Color("c4c2d6"), {"noise_amount": 0.05, "rim_strength": 0.1})
	B.box(root, Vector3(0.85, 0.1, 0.7), Vector3(0, 0.04, 0), m, Vector3(0, rng.randf_range(-12, 12), 0))
	return root


## 울타리 한 줄. 기둥 사이 1.3m 이하로 나눈다.
static func build_fence(parent: Node3D, a: Vector3, b: Vector3, skip_first_post := false) -> void:
	Painted.fence(parent,a,b,skip_first_post)


static func _blockout_fence(parent: Node3D, a: Vector3, b: Vector3, skip_first_post := false) -> void:
	var wood := Mats.solid(C_FENCE, {"noise_amount": 0.05, "top_snow": 0.7, "snow_color": C_SNOW})
	var dir := b - a
	var length := dir.length()
	var bays := maxi(1, ceili(length / 1.3))
	var yaw := rad_to_deg(atan2(dir.x, dir.z))
	for i in range(bays + 1):
		if i == 0 and skip_first_post:
			continue
		var p := a + dir * (float(i) / bays)
		B.box(parent, Vector3(0.16, 0.82, 0.16), p + Vector3(0, 0.41, 0), wood)
		B.box(parent, Vector3(0.2, 0.06, 0.2), p + Vector3(0, 0.85, 0), snow_mat())
	for y: float in [0.33, 0.62]:
		B.box(parent, Vector3(0.07, 0.11, length), (a + b) * 0.5 + Vector3(0, y, 0), wood, Vector3(0, yaw, 0))


# ───────────────────────── 산장 ─────────────────────────

## 박공지붕. 부모 로컬 좌표에서 용마루는 Z축을 따른다.
static func _gable_roof(parent: Node3D, run: float, rise: float, length: float, base_y: float,
		over := 0.55, thick := 0.34, gable_over := 0.35) -> void:
	var a := atan2(rise, run)
	var slope_len := sqrt(rise * rise + run * run)
	var L := slope_len + over
	var snow := Mats.solid(C_ROOF_SNOW, {"noise_amount": 0.05, "rim_strength": 0.3})
	var snow2 := Mats.solid(C_ROOF_SNOW.darkened(0.06), {"noise_amount": 0.05, "rim_strength": 0.3})
	var under := Mats.solid(C_TIMBER_DARK)
	var timber := Mats.solid(C_TIMBER)
	var depth := length + gable_over * 2.0
	for s: float in [-1.0, 1.0]:
		var down := Vector2(s * cos(a), -sin(a))
		var nrm := Vector2(s * sin(a), cos(a))
		var mid := Vector2(s * run * 0.5, base_y + rise * 0.5) + down * (over * 0.5 - 0.06) + nrm * (thick * 0.5)
		var rotz := -s * rad_to_deg(a)
		# 큰 눈 기와: 줄마다 살짝 들려 계단 모양, 줄 안은 넓은 판으로 나눈다(잔무늬 없이 큰 면)
		var rows := 4
		var seg := L / rows
		var tiles := 5
		for r in rows:
			var along := -0.08 + seg * (r + 0.5)
			var c := Vector2(0, base_y + rise) + down * along + nrm * (thick * 0.5)
			var tw := depth / tiles
			var shift := 0.0 if r % 2 == 0 else tw * 0.5
			for t in range(tiles + (1 if r % 2 == 1 else 0)):
				var z0 := clampf(-depth * 0.5 + t * tw - shift, -depth * 0.5, depth * 0.5)
				var z1 := clampf(z0 + tw, -depth * 0.5, depth * 0.5)
				if z1 - z0 < 0.1:
					continue
				var m := snow if (r + t) % 3 != 0 else snow2
				B.box(parent, Vector3(seg + 0.14, thick, z1 - z0 - 0.05), Vector3(c.x, c.y, (z0 + z1) * 0.5), m,
					Vector3(0, 0, -s * (rad_to_deg(a) - 4.0)))
		var mid2 := mid - nrm * (thick * 0.5 + 0.06)
		B.box(parent, Vector3(L - 0.04, 0.13, depth - 0.06), Vector3(mid2.x, mid2.y, 0), under, Vector3(0, 0, rotz))
		# 박공 끝의 두꺼운 나무판(바지보드)
		for zz in [depth * 0.5 + 0.02, -depth * 0.5 - 0.02]:
			B.box(parent, Vector3(L + 0.05, 0.3, 0.18), Vector3(mid2.x, mid2.y + 0.02, zz), timber, Vector3(0, 0, rotz))
		# 처마 끝 눈 덩어리
		var eave := Vector2(s * run, base_y) + down * (over - 0.06) + nrm * (thick * 0.6)
		B.cyl(parent, 0.17, 0.17, depth, Vector3(eave.x, eave.y, 0), snow, 7, Vector3(90, 0, 0))
	# 용마루 눈
	B.cyl(parent, 0.24, 0.24, depth + 0.05, Vector3(0, base_y + rise + thick * 0.95, 0), snow, 8, Vector3(90, 0, 0))
	# 박공 꼭대기의 엇갈린 나무 장식
	for zz in [depth * 0.5 + 0.06, -depth * 0.5 - 0.06]:
		B.box(parent, Vector3(0.26, 0.85, 0.24), Vector3(0, base_y + rise + 0.45, zz), timber, Vector3(0, 0, 0))
		B.box(parent, Vector3(0.62, 0.2, 0.2), Vector3(0, base_y + rise + 0.62, zz), timber, Vector3(0, 0, 0))


static func _window(parent: Node3D, pos: Vector3, yaw: float, w: float, h: float) -> void:
	var n := B.node(parent, pos, Vector3(0, yaw, 0))
	B.box(n, Vector3(w + 0.22, h + 0.22, 0.12), Vector3(0, 0, 0.0), Mats.solid(C_TIMBER))
	B.box(n, Vector3(w, h, 0.14), Vector3(0, 0, 0.01), Mats.glow(C_WINDOW, 2.6))
	B.box(n, Vector3(0.06, h, 0.18), Vector3(0, 0, 0.02), Mats.solid(C_TIMBER_DARK))
	B.box(n, Vector3(w, 0.06, 0.18), Vector3(0, 0, 0.02), Mats.solid(C_TIMBER_DARK))
	B.box(n, Vector3(w + 0.34, 0.08, 0.26), Vector3(0, -h * 0.5 - 0.13, 0.06), Mats.solid(C_TIMBER))
	B.box(n, Vector3(w + 0.3, 0.06, 0.22), Vector3(0, -h * 0.5 - 0.07, 0.07), snow_mat())


## 본채. 반환: 앵커·발광 노드.
static func build_lodge(root: Node3D) -> Dictionary:
	return Painted.lodge(root)


static func _blockout_lodge(root: Node3D) -> Dictionary:
	var v := B.node(root, Vector3.ZERO, Vector3.ZERO, "LodgeVisual")
	var stone := Mats.solid(C_STONE, {"noise_amount": 0.07})
	var plinth := Mats.solid(C_PLINTH, {"top_snow": 0.75, "snow_color": C_SNOW, "noise_amount": 0.06})
	var timber := Mats.solid(C_TIMBER, {"noise_amount": 0.05})
	var wall_top := 2.4

	B.box(v, Vector3(4.9, 0.4, 5.9), Vector3(0, 0.2, 0), plinth)
	B.box(v, Vector3(4.6, 2.0, 5.6), Vector3(0, 1.4, 0), stone)
	# 모서리 기둥과 테두리 보
	for sx: float in [-1.0, 1.0]:
		for sz: float in [-1.0, 1.0]:
			B.box(v, Vector3(0.32, 2.1, 0.32), Vector3(sx * 2.3, 1.45, sz * 2.8), timber)
	B.box(v, Vector3(4.95, 0.26, 0.32), Vector3(0, wall_top + 0.05, 2.82), timber)
	B.box(v, Vector3(4.95, 0.26, 0.32), Vector3(0, wall_top + 0.05, -2.82), timber)
	B.box(v, Vector3(0.32, 0.26, 5.95), Vector3(2.32, wall_top + 0.05, 0), timber)
	B.box(v, Vector3(0.32, 0.26, 5.95), Vector3(-2.32, wall_top + 0.05, 0), timber)
	for sz: float in [-0.95, 0.95]:
		B.box(v, Vector3(0.22, 2.0, 0.22), Vector3(2.33, 1.4, sz * 1.9 - 0.2), timber)
		B.box(v, Vector3(0.22, 2.0, 0.22), Vector3(-2.33, 1.4, sz * 1.9), timber)
	# 박공 벽
	var rise := 1.9
	B.prism(v, Vector3(4.6, rise, 5.6), Vector3(0, wall_top + rise * 0.5, 0), stone)
	for zz: float in [2.82, -2.82]:
		B.box(v, Vector3(0.22, 1.55, 0.12), Vector3(0, wall_top + 0.85, zz), timber)
		B.box(v, Vector3(2.6, 0.18, 0.12), Vector3(0, wall_top + 0.5, zz), timber)
	var roof := B.node(v, Vector3.ZERO, Vector3.ZERO, "Roof")
	_gable_roof(roof, 2.3, rise, 5.6, wall_top)

	# 굴뚝
	var chim := Mats.solid(C_CHIMNEY, {"noise_amount": 0.08, "top_snow": 0.8, "snow_color": C_SNOW})
	B.box(v, Vector3(0.85, 2.9, 0.85), Vector3(1.25, 3.55, -1.4), chim)
	B.box(v, Vector3(1.05, 0.24, 1.05), Vector3(1.25, 5.05, -1.4), chim)
	B.box(v, Vector3(0.55, 0.06, 0.55), Vector3(1.25, 5.16, -1.4), Mats.solid(Color("1d1626")))

	# 문과 돌 아치
	var door_x := 0.5
	var arch := Mats.solid(C_STONE_LIGHT, {"noise_amount": 0.06})
	B.box(v, Vector3(1.28, 1.6, 0.1), Vector3(door_x, 1.2, 2.82), arch)
	B.cyl(v, 0.64, 0.64, 0.1, Vector3(door_x, 2.0, 2.82), arch, 14, Vector3(90, 0, 0))
	B.box(v, Vector3(0.92, 1.5, 0.12), Vector3(door_x, 1.15, 2.86), Mats.solid(C_DOOR))
	B.cyl(v, 0.46, 0.46, 0.12, Vector3(door_x, 1.9, 2.86), Mats.solid(C_DOOR), 14, Vector3(90, 0, 0))
	B.sphere(v, 0.05, Vector3(door_x + 0.3, 1.2, 2.95), Mats.solid(C_GOLD), Vector3.ONE, 6, 3)
	# 계단
	B.box(v, Vector3(1.55, 0.2, 0.55), Vector3(door_x, 0.1, 3.25), plinth)
	B.box(v, Vector3(1.35, 0.2, 0.32), Vector3(door_x, 0.3, 3.08), plinth)

	# 창문(발광 면) — 정면, 오른쪽(목장), 왼쪽, 뒤
	_window(v, Vector3(-1.35, 1.5, 2.82), 0.0, 0.62, 0.68)
	_window(v, Vector3(0.0, 3.25, 2.83), 0.0, 0.42, 0.42)
	_window(v, Vector3(2.33, 1.45, 0.55), 90.0, 0.9, 0.85)
	_window(v, Vector3(2.33, 1.45, -1.75), 90.0, 0.55, 0.65)
	_window(v, Vector3(-2.33, 1.45, 0.3), -90.0, 0.8, 0.8)
	_window(v, Vector3(0.8, 1.45, -2.82), 180.0, 0.7, 0.7)

	# 벽등
	var lantern_pos := Vector3(-0.35, 1.85, 3.02)
	B.box(v, Vector3(0.07, 0.07, 0.32), Vector3(-0.35, 2.12, 2.92), Mats.solid(C_METAL))
	B.box(v, Vector3(0.26, 0.05, 0.26), lantern_pos + Vector3(0, 0.2, 0), Mats.solid(C_METAL))
	B.box(v, Vector3(0.2, 0.3, 0.2), lantern_pos, Mats.glow(Color(1.0, 0.7, 0.35), 5.0))
	B.box(v, Vector3(0.24, 0.05, 0.24), lantern_pos - Vector3(0, 0.17, 0), Mats.solid(C_METAL))

	# 집 주변 생활 소품
	var barrel := make_barrel()
	barrel.position = Vector3(-2.05, 0, 3.45)
	v.add_child(barrel)
	var wood := make_firewood()
	wood.position = Vector3(1.85, 0, 3.35)
	wood.rotation_degrees.y = 8
	v.add_child(wood)

	# ── 조명: 작은 면적에 집중된 앰버 빛 ──
	var lights := B.node(v, Vector3.ZERO, Vector3.ZERO, "WarmLights")
	B.omni(lights, Vector3(-0.35, 1.65, 3.55), C_WARM, 1.35, 5.8, true, 1.3)
	B.omni(lights, Vector3(-1.35, 1.3, 3.6), C_WARM, 0.7, 4.5, false, 1.3)
	B.omni(lights, Vector3(3.3, 1.25, 0.55), C_WARM, 1.3, 5.0, false, 1.3)
	B.omni(lights, Vector3(3.0, 1.25, -1.75), C_WARM, 0.5, 3.8, false, 1.4)
	B.omni(lights, Vector3(-3.2, 1.25, 0.3), C_WARM, 0.7, 4.5, false, 1.3)
	B.omni(lights, Vector3(0.8, 1.25, -3.6), C_WARM, 0.6, 4.0, false, 1.3)

	return {"visual": v, "lights": lights}


## 객실 증축 모듈(목장 반대쪽 -X). 본채는 유지한 채 덧붙인다.
static func build_extension(root: Node3D) -> Node3D:
	return Painted.extension(root)

static func _blockout_extension(root: Node3D) -> Node3D:
	var v := B.node(root, Vector3(-3.85, 0, 0), Vector3.ZERO, "ExtensionVisual")
	var stone := Mats.solid(C_STONE, {"noise_amount": 0.07})
	var plinth := Mats.solid(C_PLINTH, {"top_snow": 0.75, "snow_color": C_SNOW, "noise_amount": 0.06})
	var timber := Mats.solid(C_TIMBER, {"noise_amount": 0.05})
	B.box(v, Vector3(3.2, 0.35, 3.4), Vector3(0, 0.175, 0), plinth)
	B.box(v, Vector3(3.0, 1.7, 3.2), Vector3(0, 1.2, 0), stone)
	for sx: float in [-1.0]:
		for sz: float in [-1.0, 1.0]:
			B.box(v, Vector3(0.28, 1.8, 0.28), Vector3(sx * 1.5, 1.25, sz * 1.6), timber)
	B.box(v, Vector3(3.1, 0.22, 0.28), Vector3(0, 2.07, 1.62), timber)
	B.box(v, Vector3(3.1, 0.22, 0.28), Vector3(0, 2.07, -1.62), timber)
	var roof := B.node(v, Vector3.ZERO, Vector3(0, 90, 0), "Roof")
	B.prism(roof, Vector3(3.2, 1.25, 3.0), Vector3(0, 2.05 + 0.625, 0), stone)
	_gable_roof(roof, 1.6, 1.25, 3.0, 2.05, 0.45, 0.3, 0.25)
	_window(v, Vector3(-0.3, 1.2, 1.61), 0.0, 0.7, 0.7)
	_window(v, Vector3(-1.51, 1.2, 0.0), -90.0, 0.6, 0.6)
	B.omni(v, Vector3(-0.3, 1.1, 2.4), C_WARM, 0.8, 4.8, false, 1.3)
	B.omni(v, Vector3(-2.3, 1.1, 0.0), C_WARM, 0.6, 4.0, false, 1.3)
	return v


# ───────────────────────── 캐릭터 ─────────────────────────

## SD 마녀(모자 포함 약 1.3m). 정면 +Z.
static func make_witch() -> Dictionary:
	return Painted.witch()


static func _blockout_witch() -> Dictionary:
	var root := Node3D.new()
	var body := B.node(root, Vector3.ZERO, Vector3.ZERO, "Body")
	var robe := Mats.solid(C_ROBE, {"rim_strength": 0.35})
	var hat := Mats.solid(C_HAT, {"rim_strength": 0.4})
	B.sphere(body, 0.075, Vector3(-0.09, 0.05, 0.04), Mats.solid(Color("2a1e30")), Vector3(1, 0.7, 1.4), 8, 4)
	B.sphere(body, 0.075, Vector3(0.09, 0.05, 0.04), Mats.solid(Color("2a1e30")), Vector3(1, 0.7, 1.4), 8, 4)
	B.cyl(body, 0.13, 0.29, 0.46, Vector3(0, 0.27, 0), robe, 10)
	B.cyl(body, 0.2, 0.26, 0.08, Vector3(0, 0.46, -0.02), Mats.solid(Color("3a2268")), 10)
	# 머리(큰 머리)
	var head := B.node(body, Vector3(0, 0.66, 0), Vector3.ZERO, "Head")
	B.sphere(head, 0.21, Vector3.ZERO, Mats.solid(C_SKIN, {"rim_strength": 0.2}))
	B.sphere(head, 0.225, Vector3(0, 0.03, -0.045), Mats.solid(C_HAIR), Vector3(1.0, 0.95, 0.95))
	B.sphere(head, 0.03, Vector3(-0.075, 0.0, 0.195), Mats.solid(Color("2a1e30")), Vector3.ONE, 6, 3)
	B.sphere(head, 0.03, Vector3(0.075, 0.0, 0.195), Mats.solid(Color("2a1e30")), Vector3.ONE, 6, 3)
	# 모자
	B.cyl(head, 0.32, 0.32, 0.045, Vector3(0, 0.15, 0), hat, 16)
	B.cyl(head, 0.205, 0.215, 0.07, Vector3(0, 0.2, 0), Mats.solid(C_GOLD), 14)
	var cone := B.node(head, Vector3(0, 0.18, 0), Vector3(-14, 0, 6))
	B.cyl(cone, 0.07, 0.2, 0.42, Vector3(0, 0.21, 0), hat, 12)
	B.cyl(cone, 0.0, 0.075, 0.26, Vector3(0.02, 0.5, -0.06), hat, 10, Vector3(-30, 0, -12))
	# 손
	B.sphere(body, 0.065, Vector3(-0.24, 0.32, 0.06), Mats.solid(Color("3a2268")))
	var hand_r := B.node(body, Vector3(0.24, 0.33, 0.07), Vector3.ZERO, "StaffGrip")
	B.sphere(hand_r, 0.065, Vector3.ZERO, Mats.solid(Color("3a2268")))
	# 지팡이(나무 갈고리 + 금테 고리)
	var staff := B.node(hand_r, Vector3.ZERO, Vector3(8, 0, 0), "Staff")
	B.cyl(staff, 0.022, 0.026, 1.05, Vector3(0, 0.12, 0), Mats.solid(C_STAFF), 6)
	B.torus(staff, 0.05, 0.085, Vector3(0, 0.7, 0), Mats.solid(C_GOLD), Vector3(90, 0, 0))
	B.sphere(staff, 0.045, Vector3(0, 0.7, 0), Mats.glow(Color(1.0, 0.75, 0.4), 4.0), Vector3.ONE, 8, 4)
	var tip := B.node(staff, Vector3(0, 0.72, 0), Vector3.ZERO, "Tip")
	return {"root": root, "body": body, "tip": tip, "head": head, "staff": staff}


## 사용자 제공 양 GLB + 부품 피벗·자동 스키닝 모션(visual/sheep_visual.gd). 이전 채색 양은 Painted.sheep().
static func make_sheep() -> Node3D:
	return preload("res://scripts/visual/sheep_visual.gd").new()


static func _blockout_sheep() -> Node3D:
	var root := Node3D.new()
	var body := B.node(root, Vector3.ZERO, Vector3.ZERO, "Body")
	var wool := Mats.solid(C_WOOL, {"rim_strength": 0.3, "noise_amount": 0.03})
	var face := Mats.solid(C_SHEEP_FACE)
	for x: float in [-0.12, 0.12]:
		for z: float in [-0.2, 0.2]:
			B.cyl(body, 0.045, 0.05, 0.26, Vector3(x, 0.13, z), face, 6)
	B.sphere(body, 0.32, Vector3(0, 0.42, -0.02), wool, Vector3(1.0, 0.88, 1.3))
	B.sphere(body, 0.17, Vector3(0.0, 0.66, -0.12), wool, Vector3.ONE, 10, 5)
	B.sphere(body, 0.15, Vector3(0.1, 0.62, 0.12), wool, Vector3.ONE, 10, 5)
	B.sphere(body, 0.14, Vector3(-0.12, 0.6, 0.08), wool, Vector3.ONE, 10, 5)
	var head := B.node(body, Vector3(0, 0.5, 0.4), Vector3.ZERO, "Head")
	B.sphere(head, 0.14, Vector3.ZERO, face, Vector3(0.9, 1.0, 1.15), 10, 5)
	B.sphere(head, 0.1, Vector3(0, 0.1, -0.04), wool, Vector3(1.2, 0.8, 1.0), 8, 4)
	for x: float in [-0.13, 0.13]:
		B.sphere(head, 0.05, Vector3(x, 0.03, -0.02), face, Vector3(1.6, 0.6, 0.9), 6, 3)
	return root


## 숲에서 오는 그림자 괴물(기능 검증용 1종).
static func make_monster() -> Node3D:
	return Painted.monster()

## 큰 숲의 괴물: 카드로 변환되는 개체. 기본 괴물보다 덩치가 크고 등에서 이끼 낀 가지가 튀어나와 있다.
## 뒤쪽은 -Z(괴물은 +Z를 바라본다). 가지는 Body 아래에 붙어 걸음 흔들림을 함께 탄다.
static func make_big_monster() -> Node3D:
	var root := Painted.monster()
	var body: Node3D = root.get_node("Body")
	var bark := Mats.solid(Color("4a3226"), {"noise_amount": 0.08, "rim_strength": 0.3, "rim_color": Color(0.6, 0.5, 1.0)})
	var bark_light := Mats.solid(Color("6b4a33"), {"noise_amount": 0.06, "rim_strength": 0.2})
	var moss := Mats.solid(Color("3f6a3a"), {"noise_amount": 0.1, "rim_strength": 0.3})
	var leaf := Mats.solid(Color("5f8f3e"), {"noise_amount": 0.08, "rim_strength": 0.35})
	var leaf_warm := Mats.solid(Color("a8822f"), {"noise_amount": 0.08})
	var back := B.node(body, Vector3(0, 0.88, -0.3), Vector3.ZERO, "BackBranches")
	# 가지 밑동을 감싼 작은 이끼 뭉치
	for m in [Vector3(-0.1, 0.0, 0.03), Vector3(0.12, -0.04, 0.02), Vector3(0.0, -0.12, 0.06)]:
		B.sphere(back, 0.09, m, moss, Vector3(1.3, 0.7, 1.0), 8, 4)
	# [밑동 위치, 회전(도), 길이, 굵기]: 등에서 위·뒤로 솟은 굵은 가지 셋 + 옆으로 삐친 짧은 가지 둘
	var limbs := [
		[Vector3(-0.12, 0.02, 0.0), Vector3(-34, 0, 26), 0.62, 0.055],
		[Vector3(0.03, 0.06, -0.02), Vector3(-26, 0, -6), 0.78, 0.065],
		[Vector3(0.15, 0.0, 0.0), Vector3(-40, 0, -30), 0.55, 0.05],
		[Vector3(-0.2, -0.1, 0.04), Vector3(-72, 0, 55), 0.32, 0.035],
		[Vector3(0.22, -0.12, 0.04), Vector3(-75, 0, -52), 0.3, 0.032],
	]
	for i in limbs.size():
		var l: Array = limbs[i]
		var limb := B.node(back, l[0], l[1], "Limb%d" % i)
		var length: float = l[2]
		var thick: float = l[3]
		var mat := bark if i % 2 == 0 else bark_light
		# 중간에서 꺾이는 두 마디 가지
		var half := length * 0.55
		B.cyl(limb, thick * 0.7, thick, half, Vector3(0, half * 0.5, 0), mat, 6)
		var upper := B.node(limb, Vector3(0, half, 0), Vector3(-14, 0, (12.0 if i % 2 == 0 else -12.0)), "Upper")
		B.cyl(upper, thick * 0.3, thick * 0.7, length - half, Vector3(0, (length - half) * 0.5, 0), mat, 6)
		if i < 3:
			# 갈래 잔가지와 끝의 작은 잎
			var twig := B.node(limb, Vector3(0, half * 0.8, 0), Vector3(-10, 0, (-50.0 if i % 2 == 0 else 50.0)), "Twig")
			B.cyl(twig, thick * 0.18, thick * 0.4, length * 0.32, Vector3(0, length * 0.16, 0), bark_light, 5)
			B.sphere(twig, 0.05, Vector3(0, length * 0.33, 0), leaf_warm if i == 1 else leaf, Vector3(1.3, 0.6, 0.9), 6, 3)
			B.sphere(upper, 0.06, Vector3(0, length - half, 0), leaf, Vector3(1.4, 0.65, 1.0), 6, 3)
			B.sphere(upper, 0.045, Vector3(0.04, (length - half) * 0.6, 0.02), leaf_warm if i == 0 else leaf, Vector3(1.3, 0.6, 0.9), 6, 3)
	root.scale = Vector3.ONE * Cfg.BIG_MONSTER_SCALE
	root.set_meta("big", true)
	return root


static func _blockout_monster() -> Node3D:
	var root := Node3D.new()
	var body := B.node(root, Vector3.ZERO, Vector3.ZERO, "Body")
	var skin := Mats.solid(C_MONSTER, {"rim_strength": 0.55, "rim_color": Color(0.6, 0.5, 1.0)})
	var skin2 := Mats.solid(C_MONSTER_LIGHT, {"rim_strength": 0.4})
	var horn := Mats.solid(Color("cfc6e0"))
	for x: float in [-0.15, 0.15]:
		B.cyl(body, 0.07, 0.1, 0.38, Vector3(x, 0.19, -0.05), skin, 6)
	B.sphere(body, 0.36, Vector3(0, 0.6, -0.05), skin, Vector3(1.0, 0.95, 1.15), 10, 5)
	B.sphere(body, 0.26, Vector3(0, 0.55, 0.12), skin2, Vector3(1.0, 0.9, 0.8), 8, 4)
	var head := B.node(body, Vector3(0, 0.88, 0.22), Vector3.ZERO, "Head")
	B.sphere(head, 0.24, Vector3.ZERO, skin, Vector3(1.0, 0.9, 1.0), 10, 5)
	for s: float in [-1.0, 1.0]:
		B.cyl(head, 0.0, 0.07, 0.36, Vector3(s * 0.15, 0.25, -0.05), horn, 6, Vector3(-25, 0, -s * 28))
		B.sphere(head, 0.045, Vector3(s * 0.09, 0.02, 0.2), Mats.glow(C_MONSTER_EYE, 5.0), Vector3(1, 0.7, 1), 6, 3)
		var arm := B.node(body, Vector3(s * 0.33, 0.72, 0.05), Vector3(25, 0, s * 18), "Arm")
		B.cyl(arm, 0.05, 0.08, 0.6, Vector3(0, -0.3, 0), skin, 6)
		B.cyl(arm, 0.0, 0.05, 0.16, Vector3(0, -0.66, 0.02), horn, 5, Vector3(180, 0, 0))
	return root


static func make_traveler(rng: RandomNumberGenerator) -> Node3D:
	return Painted.traveler()

static func _blockout_traveler(rng: RandomNumberGenerator) -> Node3D:
	var root := Node3D.new()
	var body := B.node(root, Vector3.ZERO, Vector3.ZERO, "Body")
	var tint := rng.randf_range(-0.06, 0.06)
	var cloak := Mats.solid(Color(C_TRAVELER.r + tint, C_TRAVELER.g + tint, C_TRAVELER.b), {"rim_strength": 0.3})
	var hood := Mats.solid(C_HOOD, {"rim_strength": 0.3})
	B.sphere(body, 0.07, Vector3(-0.08, 0.05, 0.03), Mats.solid(Color("2f2422")), Vector3(1, 0.7, 1.4), 8, 4)
	B.sphere(body, 0.07, Vector3(0.08, 0.05, 0.03), Mats.solid(Color("2f2422")), Vector3(1, 0.7, 1.4), 8, 4)
	B.cyl(body, 0.13, 0.26, 0.48, Vector3(0, 0.28, 0), cloak, 10)
	B.box(body, Vector3(0.32, 0.36, 0.2), Vector3(0, 0.42, -0.2), Mats.solid(C_PACK))
	B.cyl(body, 0.08, 0.08, 0.34, Vector3(0, 0.64, -0.2), Mats.solid(Color("b9a27c")), 8, Vector3(0, 0, 90))
	var head := B.node(body, Vector3(0, 0.68, 0), Vector3.ZERO, "Head")
	B.sphere(head, 0.19, Vector3.ZERO, Mats.solid(C_SKIN))
	B.sphere(head, 0.215, Vector3(0, 0.04, -0.05), hood, Vector3(1.0, 1.0, 1.0))
	B.cyl(head, 0.0, 0.12, 0.2, Vector3(0, 0.22, -0.08), hood, 8, Vector3(-25, 0, 0))
	B.cyl(body, 0.018, 0.022, 0.95, Vector3(0.24, 0.45, 0.08), Mats.solid(C_STAFF), 6)
	return root


## 거대한 용. 원점 = 지붕 용마루 위 발 접점. 정면 +Z.
static func make_dragon() -> Dictionary:
	return Painted.dragon()

static func _blockout_dragon() -> Dictionary:
	var root := Node3D.new()
	var hide := Mats.solid(C_DRAGON, {"rim_strength": 0.45, "rim_color": Color(1.0, 0.6, 0.5), "noise_amount": 0.05})
	var dark := Mats.solid(C_DRAGON_DARK, {"rim_strength": 0.35, "rim_color": Color(1.0, 0.55, 0.5)})
	var belly := Mats.solid(C_BELLY, {"rim_strength": 0.2})
	var horn := Mats.solid(C_HORN)
	var body := B.node(root, Vector3.ZERO, Vector3.ZERO, "Body")
	B.sphere(body, 1.0, Vector3(0, 1.25, -0.3), hide, Vector3(1.45, 1.2, 2.2), 16, 8)
	B.sphere(body, 1.0, Vector3(0, 1.0, 0.15), belly, Vector3(1.1, 0.92, 1.75), 14, 7)
	for i in 5:
		var z := 0.9 - i * 0.65
		B.cyl(body, 0.0, 0.2 - i * 0.02, 0.5, Vector3(0, 2.45 - abs(i - 1) * 0.12, z), horn, 5, Vector3(-20, 0, 0))
	# 다리: 용마루 양쪽 경사면을 움켜쥔다
	for s: float in [-1.0, 1.0]:
		for zz: float in [0.9, -1.3]:
			B.cyl(body, 0.28, 0.36, 1.3, Vector3(s * 0.95, 0.15, zz), hide, 8, Vector3(0, 0, s * 18))
			B.sphere(body, 0.3, Vector3(s * 1.15, -0.5, zz + 0.15), dark, Vector3(1.0, 0.6, 1.3), 8, 4)
	# 꼬리: 용마루를 따라 뒤로
	var tail := B.node(body, Vector3(0, 0.95, -2.3), Vector3(-10, 0, 0), "Tail")
	var r := 0.55
	var p := Vector3.ZERO
	for i in 5:
		B.cyl(tail, r * 0.8, r, 1.0, p + Vector3(0, 0, -0.5), hide, 8, Vector3(90, 0, 0))
		p += Vector3(0, -0.12 - i * 0.05, -0.9)
		r *= 0.78
	B.prism(tail, Vector3(0.7, 0.6, 0.1), p + Vector3(0, 0, -0.2), dark, Vector3(-90, 0, 0))
	# 목·머리
	var neck := B.node(body, Vector3(0, 1.75, 0.95), Vector3(32, 0, 0), "Neck")
	B.cyl(neck, 0.45, 0.72, 2.4, Vector3(0, 1.2, 0), hide, 10)
	B.cyl(neck, 0.3, 0.5, 2.2, Vector3(0, 1.1, 0.32), belly, 8)
	var head := B.node(neck, Vector3(0, 2.45, 0), Vector3(-30, 0, 0), "Head")
	B.box(head, Vector3(0.95, 0.75, 1.25), Vector3(0, 0.1, 0.2), hide)
	B.box(head, Vector3(0.72, 0.42, 0.85), Vector3(0, -0.02, 1.15), hide)
	B.box(head, Vector3(0.66, 0.2, 0.95), Vector3(0, -0.36, 0.95), dark, Vector3(10, 0, 0))
	B.box(head, Vector3(0.5, 0.12, 0.6), Vector3(0, -0.22, 1.05), Mats.glow(Color(1.0, 0.45, 0.15), 3.0))
	for s: float in [-1.0, 1.0]:
		B.cyl(head, 0.0, 0.13, 0.95, Vector3(s * 0.33, 0.55, -0.35), horn, 6, Vector3(-60, 0, -s * 15))
		B.sphere(head, 0.1, Vector3(s * 0.38, 0.22, 0.6), Mats.glow(Color(1.0, 0.85, 0.3), 6.0), Vector3(0.7, 0.6, 1.0), 8, 4)
		B.box(head, Vector3(0.16, 0.08, 0.5), Vector3(s * 0.4, 0.38, 0.45), dark, Vector3(0, 0, s * 10))
	var mouth := B.node(head, Vector3(0, -0.15, 1.7), Vector3.ZERO, "Mouth")
	# 날개
	var wings: Array = []
	for s: float in [-1.0, 1.0]:
		var pivot := B.node(body, Vector3(s * 1.0, 2.0, 0.2), Vector3(0, s * -12.0, s * -24.0), "Wing")
		B.cyl(pivot, 0.12, 0.2, 2.8, Vector3(s * 1.4, 0, 0), hide, 7, Vector3(0, 0, 90))
		var fore := B.node(pivot, Vector3(s * 2.8, 0, 0), Vector3(0, s * 20.0, s * 18.0))
		B.cyl(fore, 0.08, 0.12, 2.6, Vector3(s * 1.3, 0, 0), hide, 6, Vector3(0, 0, 90))
		B.cyl(fore, 0.0, 0.1, 0.4, Vector3(s * 2.75, 0, 0), horn, 5, Vector3(0, 0, -s * 90))
		B.prism(pivot, Vector3(3.0, 3.0, 0.08), Vector3(s * 1.5, -0.05, -1.5), dark, Vector3(-90, 0, 0), 0.92 if s > 0 else 0.08)
		B.prism(fore, Vector3(2.7, 3.4, 0.08), Vector3(s * 1.15, -0.05, -1.7), dark, Vector3(-90, 0, 0), 0.0 if s > 0 else 1.0)
		for k in 2:
			var bone := B.node(fore, Vector3(s * (0.6 + k * 1.0), 0, 0), Vector3(0, s * (30 + k * 25), 0))
			B.cyl(bone, 0.03, 0.06, 3.0, Vector3(0, 0, -1.5), hide, 5, Vector3(90, 0, 0))
		wings.append(pivot)
	# 가슴 속 불씨 빛(지붕을 따뜻하게 비춤)
	var ember := B.omni(root, Vector3(0, 1.2, 1.9), Color(1.0, 0.5, 0.2), 2.0, 7.0, false, 1.2)
	return {"root": root, "body": body, "neck": neck, "head": head, "mouth": mouth, "wings": wings, "ember": ember}
