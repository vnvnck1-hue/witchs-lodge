extends SceneTree
## Tripo 파츠 묶음 캐릭터 헤드리스 검증(docs/character-3d-pipeline.md).
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_tripo_character.gd -- <id>
## 묶음 피벗·메시·재질·전체 크기(발 y=0, 지정 높이)·삼각형 보존·피벗 회전 시 메시가 따라 도는지 확인한다.

var passed := 0
var total := 0

func check(ok: bool, label: String) -> void:
	total += 1
	if ok: passed += 1
	print(("PASS " if ok else "FAIL ") + label)

func mesh_world_aabb(root: Node3D) -> AABB:
	var out := AABB()
	var first := true
	for mi in root.find_children("*", "MeshInstance3D", true, false):
		if not (mi as MeshInstance3D).visible: continue
		var box: AABB = (mi as MeshInstance3D).global_transform * (mi as MeshInstance3D).mesh.get_aabb()
		out = box if first else out.merge(box)
		first = false
	return out

func _initialize() -> void: call_deferred("_run")

func _run() -> void:
	var args := OS.get_cmdline_user_args()
	var id: String = args[0] if args.size() > 0 else "goblin_nib"
	var plan: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://art_sources/characters/%s/parts.json" % id))
	var report: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/characters/%s/report.json" % id))
	var packed: PackedScene = load("res://scenes/characters/%s.tscn" % id)
	check(packed != null, "%s 장면 로드" % id)
	if packed == null:
		print("RESULT %d/%d" % [passed, total]); quit(1); return
	var root: Node3D = packed.instantiate()
	get_root().add_child(root)   # global_transform 계산을 위해 트리에 넣는다
	check(str(root.get_meta("character_id", "")) == id, "character_id 메타")

	var pivots := {}
	for n in root.find_children("*", "Node3D", true, false):
		if n.has_meta("part_group"): pivots[str(n.get_meta("part_group"))] = n
	for g in plan.groups:
		var p: Node3D = pivots.get(g)
		check(p != null and p.get_node_or_null("Mesh") is MeshInstance3D, "묶음 %s 피벗·메시" % g)
		if p == null: continue
		var want_parent := str(plan.groups[g].get("parent", ""))
		var got_parent: Node = p.get_parent()
		var ok_parent := got_parent == root if want_parent == "" else (got_parent.has_meta("part_group") and str(got_parent.get_meta("part_group")) == want_parent)
		check(ok_parent, "묶음 %s 부모 = %s" % [g, want_parent if want_parent != "" else "루트"])
	check(pivots.size() == plan.groups.size(), "묶음 수 %d" % pivots.size())

	var source_parts := 0
	for g in plan.groups: source_parts += plan.groups[g].parts.size()
	check(source_parts == int(report.source_parts), "원본 파츠 %d개 모두 배정" % source_parts)
	var tris := 0
	for g in report.groups: tris += int(report.groups[g].triangles)
	check(tris == int(report.triangles) and tris > 0, "삼각형 %d 보존" % tris)

	# extras(원본에 없는 단순 형태, 예: 상투)는 크기·텍스처 검사에서 뺀다 — 원본 메시만 지정 높이로 맞춘다.
	var extras := []
	for mi in root.find_children("*", "MeshInstance3D", true, false):
		if mi.name != "Mesh": extras.append(mi); mi.visible = false
	var box := mesh_world_aabb(root)
	for mi in extras: mi.visible = true
	var h := float(plan.get("height_m", 1.0))
	check(absf(box.position.y) < .005 and absf(box.size.y - h) < h * .01, "발 y=%.3f · 높이 %.3fm (목표 %.2f)" % [box.position.y, box.size.y, h])
	check(absf(box.get_center().x) < .02 and absf(box.get_center().z) < .02, "XZ 중심 원점")

	var tex_ok := true
	for mi in root.find_children("*", "MeshInstance3D", true, false):
		if mi.name != "Mesh": continue
		var mat := (mi as MeshInstance3D).mesh.surface_get_material(0) as ShaderMaterial
		var tex: Texture2D = mat.get_shader_parameter("rock_paint") if mat else null
		if tex == null or tex.get_width() < 256: tex_ok = false
	check(tex_ok, "모든 묶음 재질·공유 텍스처")

	# 관절 회전: 팔을 돌리면 팔 메시는 움직이고 몸통 메시는 그대로.
	for g in ["arm_r", "arm_l", "head"]:
		if not pivots.has(g): continue
		var p: Node3D = pivots[g]
		var mesh: MeshInstance3D = p.get_node("Mesh")
		var torso_mesh: MeshInstance3D = pivots["torso"].get_node("Mesh")
		var before := (mesh.global_transform * mesh.mesh.get_aabb()).get_center()
		var torso_before := torso_mesh.global_transform.origin
		p.rotation_degrees.x = 40.0
		var after := (mesh.global_transform * mesh.mesh.get_aabb()).get_center()
		check(before.distance_to(after) > .01 and torso_mesh.global_transform.origin.is_equal_approx(torso_before), "%s 피벗 회전 시 해당 묶음만 움직임" % g)
		p.rotation_degrees.x = 0.0
	root.queue_free()
	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)
