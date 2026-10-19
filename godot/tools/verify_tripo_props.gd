extends SceneTree
## Tripo 프랍 파이프라인 헤드리스 검증(docs/tripo-pipeline.md).
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_tripo_props.gd
## 1) assets/tripo/<id>/ 마다 장면·메시·재질·텍스처·크기·피벗·삼각형 예산
## 2) forest_layout.json 의 tripo_* 부품이 배치 규칙(맹독 지역·마당·길 여유)을 지키는지
## 3) 실제 main.tscn 을 띄워 배치 수만큼 프랍(·충돌체)이 생기는지

const Layout := preload("res://scripts/world/layout.gd")
const Hazards := preload("res://scripts/world/hazard_sites.gd")
const TRI_BUDGET := 20000
var passed := 0
var total := 0

func check(ok: bool, label: String) -> void:
	total += 1
	if ok: passed += 1
	print(("PASS " if ok else "FAIL ") + label)

func _initialize() -> void: call_deferred("_run")

func _run() -> void:
	var ids := []
	if DirAccess.dir_exists_absolute("res://assets/tripo"):
		for d in DirAccess.get_directories_at("res://assets/tripo"): ids.append(d)
	check(true, "Tripo 프랍 %d종: %s" % [ids.size(), ", ".join(ids)])
	for id in ids:
		var report_path := "res://assets/tripo/%s/report.json" % id
		if not FileAccess.file_exists(report_path):
			check(false, "%s report.json" % id); continue
		var report: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(report_path))
		var scene_path := "res://scenes/props/nature/%s.tscn" % id
		var packed: PackedScene = load(scene_path) if ResourceLoader.exists(scene_path) else null
		check(packed != null, "%s 장면 로드" % id)
		if packed == null: continue
		var node := packed.instantiate()
		check(str(node.get_meta("nature_id", "")) == id, "%s nature_id 메타" % id)
		var meshes := node.find_children("*", "MeshInstance3D", true, false)
		check(meshes.size() > 0 and meshes[0].mesh != null, "%s 메시" % id)
		if meshes.is_empty() or meshes[0].mesh == null: node.free(); continue
		var mesh: Mesh = meshes[0].mesh
		var box := mesh.get_aabb()
		var h := float(report.height_m)
		check(absf(box.position.y) < .01 and absf(box.size.y - h) < h * .02,
			"%s 바닥 피벗·높이 %.2fm (목표 %.2fm, 바닥 %.3f)" % [id, box.size.y, h, box.position.y])
		var cx := box.get_center()
		check(absf(cx.x) < .02 * maxf(box.size.x, 1.0) and absf(cx.z) < .02 * maxf(box.size.z, 1.0), "%s XZ 중심 피벗" % id)
		check(int(report.triangles) <= TRI_BUDGET, "%s 삼각형 %d ≤ %d" % [id, report.triangles, TRI_BUDGET])
		var tex_ok := true
		for s in mesh.get_surface_count():
			var mat := mesh.surface_get_material(s) as ShaderMaterial
			var tex: Texture2D = mat.get_shader_parameter("rock_paint") if mat else null
			if mat == null or tex == null or tex.get_width() < 4: tex_ok = false
		check(tex_ok, "%s 표면 %d개 재질·텍스처" % [id, mesh.get_surface_count()])
		node.free()

	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/environment/forest_layout.json"))
	var parts := []
	for g in data.groups:
		for part in g.parts:
			if str(part.asset).begins_with("tripo_"): parts.append(part)
	for part in parts:
		var at := Vector2(part.position[0], part.position[1])
		var r := float(part.collider_radius)
		check(ResourceLoader.exists("res://scenes/props/nature/%s.tscn" % part.asset), "배치 %s 장면 존재" % part.asset)
		check(not Hazards.clearing_at(at) and not Layout.in_yard_reserve(at, r),
			"배치 %s %s 맹독 지역·마당 밖" % [part.asset, at])
		check(Layout.dist_to_trails(at) >= r + 1.0, "배치 %s 길 여유 %.1fm" % [part.asset, Layout.dist_to_trails(at) - r])

	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	for i in 20: await physics_frame
	var spawned := 0
	for n in game.world.find_children("*", "Node3D", true, false):
		if str(n.get_meta("nature_id", "")).begins_with("tripo_"): spawned += 1
	check(spawned == parts.size(), "실행 중 Tripo 프랍 %d개 / 배치 %d개" % [spawned, parts.size()])
	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)
