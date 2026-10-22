extends SceneTree
## 바닥 풀 잎 형태(2026-10-22): 레고 같은 노 모양 잎 대신 잎맥을 따라 접힌 창 모양 잎 포기.
## 메시 구조(종류 수·잎맥 UV·뾰족한 끝·접힌 양쪽 면 법선·높이에 비례한 퍼짐)와 셰이더 손그림 질감 유니폼을 헤드리스로 확인한다.
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_grass_leaf.gd

var passed := 0
var total := 0


func _check(ok: bool, message: String) -> void:
	total += 1
	if ok: passed += 1
	print(("PASS " if ok else "FAIL ") + message)


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var grass := GrassField.new()
	grass.size = Vector2(16, 16)
	grass.height_range = Vector2(.3, 1.0)
	grass.clump_density = 4.0
	grass.visibility_end = 0.0
	root.add_child(grass) # _ready() builds the chunks
	await process_frame
	var by_kind := {}
	for c in grass.get_children():
		if c is MultiMeshInstance3D:
			var kind := int(String(c.name).get_slice("_", 3))
			by_kind[kind] = c.multimesh
	_check(GrassField.Kind.size() == 4, "4 plant kinds (rosette, broad-leaf, flower, spear)")
	_check(by_kind.has(GrassField.Kind.GRASS) and by_kind.has(GrassField.Kind.SPEAR),
		"rosettes and spear plants both placed: kinds %s" % [by_kind.keys()])
	_check(grass.instance_count > 100, "plants generated: %d" % grass.instance_count)

	if not by_kind.has(GrassField.Kind.GRASS):
		print("RESULT %d/%d" % [passed, total])
		quit(1)
		return
	var rosette: Mesh = by_kind[GrassField.Kind.GRASS].mesh
	var arrays := rosette.surface_get_arrays(0)
	var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
	var uvs: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
	_check(verts.size() / 3 >= 6 * 6 * 4, "rosette has 6 folded leaves x 6 segments (%d tris)" % (verts.size() / 3))
	var has_mid := false
	var has_edges := false
	var max_y := 0.0
	var reach := 0.0
	for i in uvs.size():
		if is_equal_approx(uvs[i].x, .5): has_mid = true
		if uvs[i].x == 0.0 or uvs[i].x == 1.0: has_edges = true
		max_y = maxf(max_y, verts[i].y)
		reach = maxf(reach, Vector2(verts[i].x, verts[i].z).length())
	_check(has_mid and has_edges, "leaf UV.x runs edge 0 .. midrib .5 .. edge 1 (shader paints the midrib)")
	_check(reach > max_y * .9, "leaves arch outwards: reach %.2f vs height %.2f" % [reach, max_y])

	# Pointed tips: in every triangle touching UV.y = 1, the tip vertices coincide.
	var tip_width := 0.0
	var tip_tris := 0
	for i in range(0, uvs.size(), 3):
		var at_tip: Array[Vector3] = []
		for k in 3:
			if uvs[i + k].y > .999: at_tip.append(verts[i + k])
		if at_tip.size() >= 2:
			tip_tris += 1
			tip_width = maxf(tip_width, at_tip[0].distance_to(at_tip[1]))
	_check(tip_tris > 0 and tip_width < .001, "leaf tips come to a point (%d tip triangles, gap %.4f)" % [tip_tris, tip_width])

	# Each segment is emitted as 2 left-half triangles then 2 right-half triangles (vertices 0..5, 6..11).
	var fold := rad_to_deg(normals[0].angle_to(normals[6]))
	_check(uvs[0].x == 0.0 and uvs[7].x == 1.0 and fold > 15.0, "leaf halves face apart along the midrib fold (%.0f°)" % fold)

	# Spread follows height (_add scales width by height x SPREAD[kind]). The headless dummy renderer keeps no
	# MultiMesh transforms, so check the per-kind tables instead of the instances.
	_check(GrassField.SPREAD.size() == GrassField.Kind.size() and GrassField.STIFFNESS.size() == GrassField.Kind.size(),
		"per-kind spread and stiffness tables cover every kind")
	_check(GrassField.SPREAD[GrassField.Kind.WEED] > GrassField.SPREAD[GrassField.Kind.SPEAR],
		"broad-leaf plants spread wider than upright spear plants")

	var shader := (grass.shader_material as ShaderMaterial).shader
	var names := []
	for u in shader.get_shader_uniform_list(): names.append(u.name)
	for u in ["midrib_light", "vein_shade", "edge_shade", "half_tone", "brush_amount", "tip_glow", "root_shade", "normal_flatten"]:
		_check(u in names, "shader paints leaves: uniform %s" % u)

	# Shape presets: the old paddle-blade look stays available (Shift+F6 / grass_shape=classic).
	var Meadow := load("res://scripts/world/grass_meadow.gd")
	var ids := []
	for sh in Meadow.SHAPES: ids.append(sh.id)
	_check(ids == ["leaf", "classic"], "shape presets leaf (default) and classic: %s" % [ids])
	var paint_ok := true
	for sh in Meadow.SHAPES:
		for k in sh.paint:
			if not k in names: paint_ok = false
		for k in sh.outer:
			if not k in grass: paint_ok = false
	_check(paint_ok, "every preset key is a real shader uniform / GrassField property")
	var old := GrassField.new()
	old.size = Vector2(16, 16)
	old.classic = true
	old.spear_ratio = .5
	root.add_child(old)
	await process_frame
	var old_kinds := {}
	for c in old.get_children():
		if c is MultiMeshInstance3D: old_kinds[int(String(c.name).get_slice("_", 3))] = c.multimesh
	_check(not old_kinds.has(GrassField.Kind.SPEAR), "classic places no spear plants")
	var old_tris: int = old_kinds[GrassField.Kind.GRASS].mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX].size() / 3
	_check(old_tris == 36, "classic tuft is the old 3 round-tipped paddle blades (%d tris)" % old_tris)

	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)
