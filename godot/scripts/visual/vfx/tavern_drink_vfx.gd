extends RefCounted
## 에린의 새 술 카드 v2 연출(표시 전용): 용의 숨결 불바다 · 서리 거인의 독주 얼음 덩어리 · 건배! 구토.
## 판정·수치는 tavern_cards / dragon_breath_fire 가 맡고, 여기서는 모양만 만든다. 텍스처: assets/vfx/tavern/ (Codex 납품).

const B := preload("res://scripts/visual/build.gd")
const Mats := preload("res://scripts/visual/mats.gd")
const Fx := preload("res://scripts/visual/fx.gd")

const TEX_FIRE := "res://assets/vfx/tavern/fire_pool.png"
const TEX_ICE := "res://assets/vfx/tavern/ice_block.png"
const TEX_VOMIT := "res://assets/vfx/tavern/vomit_puddle.png"

const C_FIRE := Color(1.0, 0.5, 0.18)
const C_ICE := Color(0.62, 0.88, 1.0)
const C_VOMIT := Color(0.86, 0.84, 0.42)


static func _tex(path: String) -> Texture2D:
	return load(path) as Texture2D if ResourceLoader.exists(path) else null


static func _decal(parent: Node3D, path: String, size: float, y: float, color := Color.WHITE, additive := false) -> MeshInstance3D:
	var mat := Mats.unshaded(color, true, additive)
	mat.albedo_texture = _tex(path)
	mat.render_priority = 1
	var plane := PlaneMesh.new()
	plane.size = Vector2(size, size)
	return B.mi(parent, plane, Vector3(0, y, 0), mat)


# ───────────────────────── 용의 숨결 ─────────────────────────

## 불바다 장판: 바닥 데칼 두 겹(반대로 돈다) + 낮은 불꽃 혀 + 빛. 반환: tick 에 넘길 상태.
static func fire_pool(root: Node3D, radius: float) -> Dictionary:
	var base := _decal(root, TEX_FIRE, radius * 2.1, 0.05)
	var top := _decal(root, TEX_FIRE, radius * 1.6, 0.07, Color(1, 1, 1, 0.7), true)
	top.rotation.y = 1.3
	var tongues: Array = []
	for i in 7:
		var a := TAU * i / 7.0 + randf() * 0.4
		var d := radius * (0.25 + randf() * 0.55)
		tongues.append(B.sphere(root, 0.18, Vector3(cos(a) * d, 0.22, sin(a) * d), Mats.glow(C_FIRE, 4.5), Vector3(1, 1.8, 1), 6, 3))
	var light := B.omni(root, Vector3(0, 0.9, 0), C_FIRE, 2.8, radius + 2.0)
	if root.is_inside_tree():
		Fx.burst(root.get_parent(), root.global_position + Vector3(0, 0.3, 0), C_FIRE, 26, 4.0, 0.22, 0.7)
	return {"root": root, "base": base, "top": top, "tongues": tongues, "light": light, "radius": radius, "t": 0.0, "ember": 0.0}


static func tick_fire_pool(s: Dictionary, delta: float, time_left: float) -> void:
	if s.is_empty():
		return
	s["t"] += delta
	var t: float = s["t"]
	s["base"].rotation.y += delta * 0.25
	s["top"].rotation.y -= delta * 0.4
	var fade := clampf(time_left / 0.6, 0.0, 1.0) * clampf(t / 0.25, 0.0, 1.0)
	s["base"].scale = Vector3.ONE * (0.6 + 0.4 * fade)
	s["top"].scale = Vector3.ONE * (0.6 + 0.4 * fade) * (1.0 + 0.05 * sin(t * 9.0))
	var i := 0
	for m in s["tongues"]:
		m.scale = Vector3(1, 1.4 + 0.7 * sin(t * 11.0 + i * 1.7), 1) * fade
		i += 1
	s["light"].light_energy = 2.8 * fade * (0.8 + randf() * 0.35)
	s["ember"] -= delta
	var root: Node3D = s["root"]
	if s["ember"] <= 0.0 and fade > 0.3 and root.is_inside_tree():
		s["ember"] = 0.18
		var a := randf() * TAU
		var p := root.global_position + Vector3(cos(a), 0, sin(a)) * randf() * float(s["radius"]) * 0.85
		Fx.burst(root.get_parent(), p + Vector3(0, 0.2, 0), C_FIRE, 3, 1.6, 0.14, 0.55, true, 2.5)


# ───────────────────────── 서리 거인의 독주 ─────────────────────────

## 적 몸 전체를 감싸는 반투명 얼음 덩어리. 반환: 녹을 때 shatter 에 넘길 노드.
static func ice_block(enemy: Node3D) -> Node3D:
	var box := _bounds(enemy)
	# 몸 전체를 얼음빛으로 덮는다(몬스터 자체가 얼음이 된 것처럼). 녹을 때 되돌린다.
	var skin := Mats.unshaded(Color(0.62, 0.86, 1.0, 0.72), true)
	skin.albedo_texture = _tex(TEX_ICE)
	skin.uv1_triplanar = true
	var covered: Array = []
	for g in enemy.find_children("*", "GeometryInstance3D", true, false):
		if g is Label3D or g is Sprite3D or g is GPUParticles3D or g is CPUParticles3D:
			continue
		covered.append([g, g.material_overlay])
		g.material_overlay = skin
	var root := B.node(enemy, Vector3.ZERO, Vector3.ZERO, "TavernIce")
	root.set_meta("covered", covered)
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = _tex(TEX_ICE)
	mat.albedo_color = Color(0.85, 0.95, 1.0, 0.6)
	mat.rim_enabled = true
	mat.rim = 0.8
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.uv1_triplanar = true
	mat.uv1_scale = Vector3.ONE * 0.6
	mat.roughness = 0.15
	mat.metallic_specular = 0.9
	mat.emission_enabled = true
	mat.emission = Color(0.35, 0.6, 0.8)
	mat.emission_energy_multiplier = 0.35
	mat.render_priority = 2
	var size: Vector3 = box.size * Vector3(1.25, 1.12, 1.25) + Vector3(0.15, 0.1, 0.15)
	var center: Vector3 = box.get_center() - enemy.global_position
	B.bevel_box(root, size, center, mat, 0.08, Vector3(0, randf() * TAU, 0))
	# 덩어리에 붙은 뾰족한 결정 몇 개
	var crystal := Mats.unshaded(Color(C_ICE, 0.85), true)
	for i in 5:
		var a := TAU * i / 5.0 + randf() * 0.5
		var off := Vector3(cos(a) * size.x * 0.5, randf() * size.y * 0.4, sin(a) * size.z * 0.5)
		B.cyl(root, 0.0, 0.12 + randf() * 0.08, 0.5 + randf() * 0.4, center - Vector3(0, size.y * 0.3, 0) + off, crystal,
			6, Vector3(randf_range(-0.5, 0.5), 0, randf_range(-0.5, 0.5)))
	root.scale = Vector3(1, 0.05, 1)
	var tw := root.create_tween()
	tw.tween_property(root, "scale", Vector3.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if enemy.is_inside_tree():
		Fx.burst(enemy.get_parent(), enemy.global_position + Vector3(0, 0.6, 0), C_ICE, 10, 2.5, 0.16, 0.5)
	return root


## 얼음이 깨지며 녹는다.
static func shatter(ice: Node3D) -> void:
	if ice == null or not is_instance_valid(ice):
		return
	for c in ice.get_meta("covered", []):
		if is_instance_valid(c[0]):
			c[0].material_overlay = c[1]
	if ice.is_inside_tree():
		Fx.burst(ice.get_tree().current_scene if ice.get_tree().current_scene != null else ice.get_parent(), ice.global_position + Vector3(0, 0.7, 0), C_ICE, 16, 3.5, 0.15, 0.6, false, -9.0)
	ice.queue_free()


## 얼음 술병이 터진 자리: 바닥 서리 고리.
static func frost_splash(parent: Node, pos: Vector3, radius: float) -> void:
	if parent == null or not parent.is_inside_tree():
		return
	var ring := B.node(parent, pos, Vector3.ZERO, "FrostSplash")
	B.torus(ring, radius - 0.12, radius, Vector3(0, 0.05, 0), Mats.unshaded(Color(C_ICE, 0.6), true, true))
	Fx.burst(parent, pos + Vector3(0, 0.3, 0), C_ICE, 22, 4.0, 0.2, 0.6)
	var tw := ring.create_tween()
	tw.tween_property(ring, "scale", Vector3(1.15, 1, 1.15), 0.5)
	tw.tween_callback(ring.queue_free)


static func _bounds(n: Node3D) -> AABB:
	var out := AABB()
	var first := true
	var stack: Array = [n]
	while not stack.is_empty():
		var c = stack.pop_back()
		if c is VisualInstance3D and c.visible and not (c is Light3D) and c.name != "TavernIce":
			var b: AABB = c.global_transform * c.get_aabb()
			out = b if first else out.merge(b)
			first = false
		for k in c.get_children():
			if k is Node3D and k.name != "TavernIce" and not (k is Label3D):
				stack.append(k)
	if first or out.size.length() < 0.2 or out.size.length() > 12.0:
		out = AABB(n.global_position + Vector3(-0.5, 0, -0.5), Vector3(1.0, 1.6, 1.0))
	return out


# ───────────────────────── 건배! ─────────────────────────

## 취기 5초: 머리 위로 맥주 거품이 튄다.
static func cheers_pop(a: Node3D) -> void:
	if a != null and a.is_inside_tree():
		Fx.burst(a.get_parent(), a.global_position + Vector3(0, 1.9, 0), Color(1.0, 0.85, 0.4), 10, 2.4, 0.14, 0.6, false, -6.0)
		Fx.float_text(a.get_parent(), a.global_position + Vector3(0, 2.2, 0), "건배!", Color(1.0, 0.85, 0.45))


## 전투불능 2초 시작: 발 앞에 토사물 웅덩이. 반환: vomit_tick / vomit_end 에 넘길 상태.
static func vomit_start(a: Node3D) -> Dictionary:
	if a == null or not a.is_inside_tree():
		return {}
	var fwd := _forward(a)
	var puddle := Node3D.new()
	puddle.name = "VomitPuddle"
	a.get_parent().add_child(puddle, true)
	puddle.global_position = a.global_position + fwd * 0.8
	puddle.rotation.y = randf() * TAU
	var d := _decal(puddle, TEX_VOMIT, 1.15, 0.06)
	d.scale = Vector3(0.2, 1, 0.2)
	var tw := d.create_tween()
	tw.tween_property(d, "scale", Vector3.ONE, 0.6)
	Fx.float_text(a.get_parent(), a.global_position + Vector3(0, 2.6, 0), "우웩…", Color(0.8, 0.9, 0.5))
	return {"ally": a, "puddle": puddle, "t": 0.0}


## 몸을 앞으로 숙이고 입에서 줄기가 흘러내린다.
static func vomit_tick(s: Dictionary, delta: float) -> void:
	if s.is_empty() or not is_instance_valid(s["ally"]):
		return
	var a: Node3D = s["ally"]
	s["t"] += delta
	var body = a.get("body")
	var rig = a.get("rig")
	if rig != null:
		rig.play("pick")
		rig.amount = 0.55 + 0.08 * sin(float(s["t"]) * 14.0)
	elif body != null:
		body.rotation.x = 0.7 + 0.08 * sin(float(s["t"]) * 14.0)
	if fmod(float(s["t"]), 0.09) < delta and a.is_inside_tree():
		var fwd := _forward(a)
		Fx.burst(a.get_parent(), a.global_position + fwd * 0.45 + Vector3(0, 1.0, 0), C_VOMIT, 4, 1.1, 0.14, 0.45, false, -12.0)


## 일어선다. 웅덩이는 잠시 남았다가 사라진다.
static func vomit_end(s: Dictionary) -> void:
	if s.is_empty():
		return
	var a = s["ally"]
	if is_instance_valid(a) and a.get("rig") == null and a.get("body") != null:
		a.body.rotation.x = 0.0
	var p = s["puddle"]
	if is_instance_valid(p):
		var tw: Tween = p.create_tween()
		tw.tween_interval(3.0)
		tw.tween_property(p, "scale", Vector3(0.01, 1, 0.01), 1.0)
		tw.tween_callback(p.queue_free)


static func _forward(a: Node3D) -> Vector3:
	var v = a.get("visual")
	var f: Vector3 = (v as Node3D).global_basis.z if v is Node3D else a.global_basis.z
	f.y = 0.0
	return f.normalized() if f.length() > 0.01 else Vector3.FORWARD
