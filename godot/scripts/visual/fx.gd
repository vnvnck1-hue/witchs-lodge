extends RefCounted
## 짧은 연출 효과 모음(피격 번쩍임, 파편, 폭발). 게임 판정과 분리된 표시 전용 코드.

const Mats := preload("res://scripts/visual/mats.gd")
const B := preload("res://scripts/visual/build.gd")


static func _collect(n: Node, out: Array) -> void:
	if n is MeshInstance3D:
		var painted := n.material_override is ShaderMaterial
		for i in n.mesh.get_surface_count():
			painted = painted or n.get_surface_override_material(i) is ShaderMaterial
		if painted: out.append(n)
	for c in n.get_children():
		_collect(c, out)


static func flash(root: Node3D, strength := 1.0) -> void:
	if root == null or not root.is_inside_tree():
		return
	var meshes: Array = []
	_collect(root, meshes)
	if meshes.is_empty():
		return
	var tw := root.create_tween().set_parallel(true)
	for m: MeshInstance3D in meshes:
		m.set_instance_shader_parameter("hit_flash", strength)
		tw.tween_property(m, "instance_shader_parameters/hit_flash", 0.0, 0.22)


## 한 번 터지는 파티클 묶음.
static func burst(parent: Node, pos: Vector3, color: Color, amount := 16, speed := 3.0,
		size := 0.18, lifetime := 0.6, additive := true, gravity := -4.0) -> void:
	var p := GPUParticles3D.new()
	p.one_shot = true
	p.amount = amount
	p.lifetime = lifetime
	p.explosiveness = 0.95
	p.local_coords = false
	var pm := ParticleProcessMaterial.new()
	pm.direction = Vector3(0, 1, 0)
	pm.spread = 80.0
	pm.initial_velocity_min = speed * 0.5
	pm.initial_velocity_max = speed
	pm.gravity = Vector3(0, gravity, 0)
	pm.scale_min = 0.6
	pm.scale_max = 1.2
	var curve := Curve.new()
	curve.add_point(Vector2(0, 1))
	curve.add_point(Vector2(1, 0))
	var ct := CurveTexture.new()
	ct.curve = curve
	pm.scale_curve = ct
	p.process_material = pm
	var q := QuadMesh.new()
	q.size = Vector2(size, size)
	q.material = Mats.particle(color, additive)
	p.draw_pass_1 = q
	parent.add_child(p)
	p.global_position = pos
	p.emitting = true
	p.get_tree().create_timer(lifetime + 0.5, false).timeout.connect(p.queue_free)


## 죽음: 작게 줄어들며 사라짐 + 보랏빛 연기.
static func vanish(node: Node3D, color := Color(0.35, 0.28, 0.6, 0.8), duration := 0.35) -> void:
	burst(node.get_parent(), node.global_position + Vector3(0, 0.5, 0), color, 14, 1.6, 0.45, 0.8, false, 0.8)
	var tw := node.create_tween()
	tw.tween_property(node, "scale", Vector3(0.05, 0.05, 0.05), duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tw.tween_callback(node.queue_free)


## 불덩이 폭발: 섬광(광원) + 팽창하는 불 구체 + 불씨.
static func explosion(parent: Node, pos: Vector3, radius: float) -> void:
	var root := Node3D.new()
	parent.add_child(root)
	root.global_position = pos
	var light := B.omni(root, Vector3(0, 1.5, 0), Color(1.0, 0.45, 0.14), 2.0, radius * 1.6, false, 1.2)
	var ball_mat := Mats.unshaded(Color(1.0, 0.38, 0.10, 0.28), true, false)
	var ball := B.sphere(root, 1.0, Vector3(0, 0.3, 0), ball_mat, Vector3.ONE * 0.3, 18, 9)
	ball.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var ring_mat := Mats.unshaded(Color(1.0, 0.52, 0.22, 0.13), true, false)
	var ring := B.cyl(root, 1.0, 1.0, 0.05, Vector3(0, 0.08, 0), ring_mat, 32)
	ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	ring.scale = Vector3(0.2, 1, 0.2)
	burst(root, pos + Vector3(0, 0.4, 0), Color(1.0, 0.6, 0.25), 24, 5.0, 0.24, 0.7, true, -6.0)
	burst(root, pos + Vector3(0, 0.6, 0), Color(0.37, 0.29, 0.46, 0.5), 12, 1.6, 0.9, 1.1, false, 1.2)
	var tw := root.create_tween().set_parallel(true)
	tw.tween_property(ball, "scale", Vector3.ONE * radius * 0.38, 0.28).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tw.tween_property(ball_mat, "albedo_color:a", 0.0, 0.45).set_delay(0.1)
	tw.tween_property(ring, "scale", Vector3(radius, 1, radius), 0.4).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tw.tween_property(ring_mat, "albedo_color:a", 0.0, 0.5)
	tw.tween_property(light, "light_energy", 0.0, 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	root.get_tree().create_timer(2.0, false).timeout.connect(root.queue_free)
