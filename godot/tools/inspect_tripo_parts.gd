extends SceneTree
## Tripo 파츠 분리 GLB 의 파츠별 실제 경계(전체 높이 1.0·발 아래 중심 원점 좌표)를 출력한다(헤드리스). parts.json 묶음을 정할 때 쓴다.
##
##   .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/inspect_tripo_parts.gd -- res://art_sources/.../model.glb [제외 파츠 번호,…]
##
## 제외 파츠(예: 몸과 떨어져 놓인 꼬리)는 전체 경계 계산에서 뺀다 — 몸 기준 좌표로 보기 위해.

func global_xform(node: Node) -> Transform3D:
	var t := Transform3D.IDENTITY
	while node is Node3D:
		t = (node as Node3D).transform * t
		node = node.get_parent()
	return t

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var exclude := {}
	if args.size() > 1:
		for s in args[1].split(","): exclude[int(s)] = true
	var doc := GLTFDocument.new()
	var state := GLTFState.new()
	if doc.append_from_file(ProjectSettings.globalize_path(args[0]), state) != OK:
		push_error("GLB 를 읽지 못했습니다"); quit(1); return
	var scene := doc.generate_scene(state)
	var boxes := {}
	var raw := AABB()
	var first := true
	for node in scene.find_children("tripo_part_*", "MeshInstance3D", true, false):
		var n := int(str(node.name).get_slice("_", 2))
		var box: AABB = global_xform(node) * (node as MeshInstance3D).mesh.get_aabb()
		boxes[n] = box
		if exclude.has(n): continue
		raw = box if first else raw.merge(box)
		first = false
	var k := 1.0 / raw.size.y
	var c := raw.get_center()
	var fit := Transform3D(Basis.from_scale(Vector3.ONE * k), Vector3(-c.x * k, -raw.position.y * k, -c.z * k))
	var keys := boxes.keys()
	keys.sort()
	for n in keys:
		var b: AABB = fit * boxes[n]
		var bc := b.get_center()
		print("part %2d  c=(%+.3f %+.3f %+.3f)  min=(%+.3f %+.3f %+.3f)  max=(%+.3f %+.3f %+.3f)%s" % [n, bc.x, bc.y, bc.z,
			b.position.x, b.position.y, b.position.z, b.end.x, b.end.y, b.end.z, "  [제외]" if exclude.has(n) else ""])
	scene.free()
	quit(0)
