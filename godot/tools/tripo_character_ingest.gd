extends SceneTree
## Tripo 파츠 분리(Segment) 캐릭터 GLB → 애니메이션용 묶음 피벗 장면(헤드리스).
## 절차 문서: docs/character-3d-pipeline.md
##
##   .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/tripo_character_ingest.gd -- \
##       res://art_sources/characters/<id>/parts.json [텍스처 최대 px=1024]
##
## parts.json: {"id", "label", "source"(res 기준 상대경로), "height_m", "groups": {묶음: {"parent", "pivot", "parts": [번호…]}}}
##   - parts 번호는 GLB 노드 이름 tripo_part_<번호>. 모든 파츠는 정확히 한 묶음에 들어가야 한다(빠지거나 겹치면 실패).
##   - "drop": [번호…] 는 일부러 빼는 파츠(같은 원본을 소품 없이 재활용할 때).
##   - "paint_override": res 기준 경로 — 원본 텍스처 대신 쓸 고친 그림(뺀 소품 자국 지우기 등).
##   - "extras": [{group, shape: sphere|cylinder, pos, size:[반지름, 높이], color, rot?, name?}] — 원본에 없는 단순 형태 추가.
##   - pivot: bottom(아래 중심) · top(위 중심) · shoulder(몸통 쪽 위) · front_top(앞쪽 위) — 묶음이 회전할 관절 자리.
##     자동 위치가 맞지 않으면(예: 긴 머리카락 때문에 목이 너무 낮음) [x, y, z] 로 직접 준다(결과 좌표, 발 아래 중심 원점).
##   - parent: 묶음 노드의 부모 묶음("" 이면 루트). 예: head·arm·backpack → torso, leg → 루트.
## 결과:
##   assets/characters/<id>/<id>_<묶음>.res   묶음별 메시(피벗 원점), <id>_paint.res, <id>_mat.tres, report.json
##   scenes/characters/<id>.tscn              루트(발 아래 중심, 지정 높이) → 묶음 피벗 Node3D → MeshInstance3D

const SHADER := "res://shaders/user_rock.gdshader"

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.is_empty():
		push_error("usage: -- res://art_sources/characters/<id>/parts.json [max_tex]")
		quit(2); return
	quit(ingest(args[0], int(args[1]) if args.size() > 1 else 1024))

func global_xform(node: Node) -> Transform3D:
	var t := Transform3D.IDENTITY
	while node is Node3D:
		t = (node as Node3D).transform * t
		node = node.get_parent()
	return t

func pivot_of(spec: Variant, box: AABB) -> Vector3:
	# 숫자 배열 [x, y, z] 이면 그 자리(발 아래 중심 원점·지정 높이 좌표)를 그대로 쓴다.
	if spec is Array and spec.size() == 3: return Vector3(spec[0], spec[1], spec[2])
	var kind := str(spec)
	var c := box.get_center()
	match kind:
		"top": return Vector3(c.x, box.end.y, c.z)
		"front_top": return Vector3(c.x, box.end.y, box.end.z)
		"shoulder":
			# 몸통(x=0) 쪽 가장자리에서 폭의 20% 안쪽, 위에서 높이의 15% 아래.
			var inner := box.end.x if c.x < 0.0 else box.position.x
			var outer := box.position.x if c.x < 0.0 else box.end.x
			return Vector3(lerpf(inner, outer, .2), box.end.y - box.size.y * .15, c.z)
		_: return Vector3(c.x, box.position.y, c.z)

func ingest(plan_path: String, max_px: int) -> int:
	var plan: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(plan_path))
	var id: String = plan.id
	var doc := GLTFDocument.new()
	var state := GLTFState.new()
	var src := ProjectSettings.globalize_path("res://" + str(plan.source))
	if doc.append_from_file(src, state) != OK:
		push_error("GLB 를 읽지 못했습니다: " + src); return 1
	var scene := doc.generate_scene(state)
	var parts := {}   # 번호 → MeshInstance3D
	for node in scene.find_children("tripo_part_*", "MeshInstance3D", true, false):
		parts[int(str(node.name).get_slice("_", 2))] = node
	# 파츠 배정 검사: 모든 파츠가 정확히 한 묶음에.
	var owner_of := {}
	for g in plan.groups:
		for n in plan.groups[g].parts:
			if owner_of.has(int(n)):
				push_error("파츠 %d 가 %s·%s 두 묶음에 있습니다" % [n, owner_of[int(n)], g]); return 1
			if not parts.has(int(n)):
				push_error("GLB 에 tripo_part_%d 가 없습니다 (%s)" % [n, g]); return 1
			owner_of[int(n)] = g
	# "drop": 일부러 빼는 파츠(같은 원본을 다른 캐릭터로 재활용할 때 소품 제거). 묶음과 겹치면 실패.
	for n in plan.get("drop", []):
		if owner_of.has(int(n)):
			push_error("파츠 %d 가 drop 과 묶음(%s)에 모두 있습니다" % [n, owner_of[int(n)]]); return 1
		if parts.has(int(n)):
			parts[int(n)].free()
			parts.erase(int(n))
	for n in parts:
		if not owner_of.has(n):
			push_error("tripo_part_%d 가 어느 묶음에도 없습니다(뺄 거면 drop 에)" % n); return 1

	# 전체 크기 → 발 아래 중심 원점, 지정 높이.
	var raw := AABB()
	var first := true
	for n in parts:
		var box: AABB = global_xform(parts[n]) * parts[n].mesh.get_aabb()
		raw = box if first else raw.merge(box)
		first = false
	var height := float(plan.get("height_m", 1.0))
	var k := height / raw.size.y
	var c := raw.get_center()
	var fit := Transform3D(Basis.from_scale(Vector3.ONE * k), Vector3(-c.x * k, -raw.position.y * k, -c.z * k))

	# 묶음별 경계와 피벗.
	var boxes := {}
	var pivots := {}
	for g in plan.groups:
		var gb := AABB()
		var gf := true
		for n in plan.groups[g].parts:
			var mi: MeshInstance3D = parts[int(n)]
			var box: AABB = fit * global_xform(mi) * mi.mesh.get_aabb()
			gb = box if gf else gb.merge(box)
			gf = false
		boxes[g] = gb
		pivots[g] = pivot_of(plan.groups[g].get("pivot", "bottom"), gb)

	var dir := "res://assets/characters/%s/" % id
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
	for old in DirAccess.get_files_at(dir):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(dir + old))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://scenes/characters"))

	# 공유 텍스처·재질(Pack UV 로 한 장).
	var any_mi: MeshInstance3D = parts[parts.keys()[0]]
	var src_mat := any_mi.get_active_material(0)
	var img: Image = (src_mat as BaseMaterial3D).albedo_texture.get_image() if src_mat is BaseMaterial3D and (src_mat as BaseMaterial3D).albedo_texture else null
	if plan.has("paint_override"):
		# 원본 텍스처 대신 고친 그림(예: 뺀 소품 자국을 지운 것). UV 는 원본과 같아야 한다.
		img = Image.load_from_file(ProjectSettings.globalize_path("res://" + str(plan.paint_override)))
	if img == null:
		push_error("기본색 텍스처가 없습니다(Export 때 Pack UV 를 켰는지 확인)"); return 1
	if img.is_compressed(): img.decompress()
	img.convert(Image.FORMAT_RGB8)
	if maxi(img.get_width(), img.get_height()) > max_px:
		var s := float(max_px) / maxi(img.get_width(), img.get_height())
		img.resize(int(img.get_width() * s), int(img.get_height() * s), Image.INTERPOLATE_LANCZOS)
	img.generate_mipmaps()
	var tex := PortableCompressedTexture2D.new()
	tex.keep_compressed_buffer = true
	tex.create_from_image(img, PortableCompressedTexture2D.COMPRESSION_MODE_LOSSY, false, 0.92)
	ResourceSaver.save(tex, dir + id + "_paint.res")
	tex.take_over_path(dir + id + "_paint.res")
	var mat := ShaderMaterial.new()
	mat.resource_name = id
	mat.shader = load(SHADER)
	mat.set_shader_parameter("rock_paint", tex)
	mat.set_shader_parameter("frost_amount", 0.0)
	mat.set_shader_parameter("moss_saturation", 1.0)
	mat.set_shader_parameter("paint_brightness", float(plan.get("paint_brightness", 1.1)))   # 어두운 옷 캐릭터는 parts.json 에서 올린다
	ResourceSaver.save(mat, dir + id + "_mat.tres")
	mat.take_over_path(dir + id + "_mat.tres")

	# 장면: 루트 → 묶음 피벗(부모 순서대로) → 메시.
	var root := Node3D.new()
	root.name = id.to_pascal_case()
	root.set_meta("character_id", id)
	root.set_meta("label", str(plan.get("label", id)))
	root.set_meta("tripo_task", str(plan.get("tripo_task", "")))
	var nodes := {}
	var report_groups := {}
	var pending: Array = plan.groups.keys()
	var total_tris := 0
	while not pending.is_empty():
		var progressed := false
		for g in pending.duplicate():
			var parent_name := str(plan.groups[g].get("parent", ""))
			if parent_name != "" and not nodes.has(parent_name): continue
			var st := SurfaceTool.new()
			st.begin(Mesh.PRIMITIVE_TRIANGLES)
			var to_local := Transform3D(Basis.IDENTITY, -pivots[g]) * fit
			for n in plan.groups[g].parts:
				var mi: MeshInstance3D = parts[int(n)]
				for s in mi.mesh.get_surface_count(): st.append_from(mi.mesh, s, to_local * global_xform(mi))
			var mesh := st.commit()
			mesh.surface_set_material(0, mat)
			var tris := mesh.surface_get_array_index_len(0) / 3 if mesh.surface_get_array_index_len(0) > 0 else mesh.surface_get_array_len(0) / 3
			total_tris += tris
			var mesh_path := dir + "%s_%s.res" % [id, g]
			ResourceSaver.save(mesh, mesh_path)
			mesh.take_over_path(mesh_path)
			var pivot := Node3D.new()
			pivot.name = str(g).to_pascal_case()
			pivot.set_meta("part_group", g)
			var parent: Node3D = root if parent_name == "" else nodes[parent_name]
			pivot.position = pivots[g] - (Vector3.ZERO if parent_name == "" else pivots[parent_name])
			parent.add_child(pivot)
			pivot.owner = root
			var body := MeshInstance3D.new()
			body.name = "Mesh"
			body.mesh = mesh
			pivot.add_child(body)
			body.owner = root
			# "extras": 원본에 없는 단순 형태(예: 바꾼 머리 모양의 상투)를 묶음에 붙인다. 위치·크기는 결과 좌표(발 아래 중심 원점).
			for ex in plan.get("extras", []):
				if str(ex.group) != g: continue
				var shape := MeshInstance3D.new()
				shape.name = str(ex.get("name", "Extra"))
				var sz: Array = ex.size
				if str(ex.shape) == "cylinder":
					var cyl := CylinderMesh.new()
					cyl.top_radius = sz[0]; cyl.bottom_radius = sz[0]; cyl.height = sz[1]; cyl.radial_segments = 16
					shape.mesh = cyl
				else:
					var sph := SphereMesh.new()
					sph.radius = sz[0]; sph.height = sz[1]; sph.radial_segments = 16; sph.rings = 8
					shape.mesh = sph
				var tint := Image.create(4, 4, false, Image.FORMAT_RGB8)
				tint.fill(Color(str(ex.color)))
				var ex_mat := mat.duplicate() as ShaderMaterial
				ex_mat.set_shader_parameter("rock_paint", ImageTexture.create_from_image(tint))
				shape.material_override = ex_mat
				shape.position = Vector3(ex.pos[0], ex.pos[1], ex.pos[2]) - pivots[g]
				if ex.has("rot"): shape.rotation_degrees = Vector3(ex.rot[0], ex.rot[1], ex.rot[2])
				pivot.add_child(shape)
				shape.owner = root
			nodes[g] = pivot
			var gb: AABB = boxes[g]
			report_groups[g] = {"parent": parent_name, "parts": plan.groups[g].parts, "triangles": tris,
				"pivot": [snappedf(pivots[g].x, .001), snappedf(pivots[g].y, .001), snappedf(pivots[g].z, .001)],
				"size": [snappedf(gb.size.x, .001), snappedf(gb.size.y, .001), snappedf(gb.size.z, .001)]}
			pending.erase(g)
			progressed = true
		if not progressed:
			push_error("parent 순환 또는 없는 묶음: %s" % [pending]); return 1
	var packed := PackedScene.new()
	packed.pack(root)
	var scene_path := "res://scenes/characters/%s.tscn" % id
	ResourceSaver.save(packed, scene_path)
	var report := {"id": id, "source": plan.source, "height_m": height, "scale_from_source": k,
		"source_parts": parts.size(), "triangles": total_tris, "texture": [img.get_width(), img.get_height()],
		"scene": scene_path, "groups": report_groups}
	var f := FileAccess.open(dir + "report.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(report, "  "))
	f.close()
	scene.free()
	root.free()
	print("TRIPO_CHARACTER ", JSON.stringify(report))
	return 0
