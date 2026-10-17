extends SceneTree
## 거미 머리(part_0) 텍스처에서 청록 눈 픽셀에 해당하는 정점을 찾아 눈 4개의 중심·반경을 출력한다(셰이더 상수 산출용).
func _initialize() -> void: call_deferred("_run")

func _run() -> void:
	var model: Node3D = load("res://assets/monsters/spider/frozen_spider.glb").instantiate()
	root.add_child(model)
	var mi: MeshInstance3D
	for m in model.find_children("*", "MeshInstance3D", true, false):
		if str(m.get_parent().name) == "tripo_part_0" or str(m.name) == "tripo_part_0":
			mi = m
	var mat: StandardMaterial3D = mi.mesh.surface_get_material(0)
	var img: Image = mat.albedo_texture.get_image()
	if img.is_compressed(): img.decompress()
	print("tex ", img.get_size())
	var arr := mi.mesh.surface_get_arrays(0)
	var pos: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
	var uv: PackedVector2Array = arr[Mesh.ARRAY_TEX_UV]
	var off: Vector3 = mi.global_position
	var pts: Array = []
	for i in pos.size():
		var c := img.get_pixelv(Vector2i(clampi(int(uv[i].x * img.get_width()), 0, img.get_width() - 1), clampi(int(uv[i].y * img.get_height()), 0, img.get_height() - 1)))
		if c.b > 0.7 and c.g > 0.55 and c.r < 0.55:
			pts.append(pos[i] + off)
	print("eye verts ", pts.size())
	# k-means 4
	var cs: Array = []
	pts.sort_custom(func(a, b): return a.x < b.x)
	for k in 4: cs.append(pts[int((k + 0.5) * pts.size() / 4)])
	for it in 30:
		var sums := [Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, Vector3.ZERO]
		var cnt := [0, 0, 0, 0]
		for p in pts:
			var best := 0
			for k in 4:
				if p.distance_to(cs[k]) < p.distance_to(cs[best]): best = k
			sums[best] += p; cnt[best] += 1
		for k in 4:
			if cnt[k] > 0: cs[k] = sums[k] / cnt[k]
	for k in 4:
		var mn := Vector3(9, 9, 9); var mx := -mn
		for p in pts:
			var best := 0
			for j in 4:
				if p.distance_to(cs[j]) < p.distance_to(cs[best]): best = j
			if best == k:
				mn = mn.min(p); mx = mx.max(p)
		print("EYE %d center=%s min=%s max=%s" % [k, cs[k], mn, mx])
	# 픽셀 샘플 색
	print("sample eye color ", img.get_pixelv(Vector2i(int(uv[0].x*img.get_width()), int(uv[0].y*img.get_height()))))
	quit()
