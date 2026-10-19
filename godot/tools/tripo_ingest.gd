extends SceneTree
## Tripo GLB → 게임 프랍 장면. 임포트 설정 없이 바로 쓰이는 자원만 만든다(헤드리스).
##
##   .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/tripo_ingest.gd -- \
##       <원본 GLB 절대경로> <id> <높이 m> [라벨] [yaw 도] [frost 0~1] [텍스처 최대 px]
##
## 결과(id 는 영문 snake_case, 보통 tripo_ 접두사):
##   assets/tripo/<id>/<id>_mesh.res        바닥 중심 피벗·지정 높이로 맞춘 메시(재질별 표면)
##   assets/tripo/<id>/<id>_paint<n>.res     원본 기본색 텍스처(WebP 손실 압축, 임포트 불필요)
##   assets/tripo/<id>/<id>_mat<n>.tres      user_rock.gdshader 재질(툰 라이팅·공기 원근)
##   assets/tripo/<id>/report.json           크기·삼각형 수·원본 정보
##   scenes/props/nature/<id>.tscn           nature_id 메타가 붙은 프랍 장면(Nature.asset(id) 로 불림)
## PBR 의 금속·거칠기·노멀 맵은 게임 툰 셰이더가 쓰지 않으므로 버린다.

const SHADER := "res://shaders/user_rock.gdshader"

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() < 3:
		push_error("usage: -- <glb> <id> <height_m> [label] [yaw_deg] [frost] [max_tex]")
		quit(2); return
	var code := ingest(args[0], args[1], float(args[2]),
		args[3] if args.size() > 3 else args[1],
		float(args[4]) if args.size() > 4 else 0.0,
		float(args[5]) if args.size() > 5 else 0.0,
		int(args[6]) if args.size() > 6 else 1024)
	quit(code)

func global_xform(node: Node) -> Transform3D:
	var t := Transform3D.IDENTITY
	while node is Node3D:
		t = (node as Node3D).transform * t
		node = node.get_parent()
	return t

func paint_image(mat: Material, max_px: int) -> Image:
	var img: Image
	if mat is BaseMaterial3D:
		var base := mat as BaseMaterial3D
		if base.albedo_texture: img = base.albedo_texture.get_image()
		if img == null:
			img = Image.create(4, 4, false, Image.FORMAT_RGB8)
			img.fill(base.albedo_color)
	if img == null:
		img = Image.create(4, 4, false, Image.FORMAT_RGB8)
		img.fill(Color(.7, .7, .7))
	if img.is_compressed(): img.decompress()
	img.convert(Image.FORMAT_RGB8)
	var big := maxi(img.get_width(), img.get_height())
	if big > max_px:
		var k := float(max_px) / big
		img.resize(maxi(1, int(img.get_width() * k)), maxi(1, int(img.get_height() * k)), Image.INTERPOLATE_LANCZOS)
	return img

func ingest(src: String, id: String, height: float, label: String, yaw: float, frost: float, max_px: int) -> int:
	var doc := GLTFDocument.new()
	var state := GLTFState.new()
	if doc.append_from_file(src, state) != OK:
		push_error("GLB 를 읽지 못했습니다: " + src); return 1
	var scene := doc.generate_scene(state)
	var parts: Array = []   # [mesh, surface, transform, material]
	var raw := AABB()
	var first := true
	var rot := Transform3D(Basis(Vector3.UP, deg_to_rad(yaw)), Vector3.ZERO)
	for node in scene.find_children("*", "MeshInstance3D", true, false):
		var mi := node as MeshInstance3D
		if mi.mesh == null: continue
		var xf := rot * global_xform(mi)
		var box := xf * mi.mesh.get_aabb()
		raw = box if first else raw.merge(box)
		first = false
		for s in mi.mesh.get_surface_count():
			var mat := mi.get_active_material(s)
			parts.append([mi.mesh, s, xf, mat])
	if parts.is_empty():
		push_error("메시가 없습니다: " + src); return 1
	var k := height / maxf(raw.size.y, 1e-4)
	var center := raw.get_center()
	var fit := Transform3D(Basis.from_scale(Vector3.ONE * k), Vector3(-center.x * k, -raw.position.y * k, -center.z * k))

	var dir := "res://assets/tripo/%s/" % id
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
	for old in DirAccess.get_files_at(dir):   # 다시 받을 때 이전 표면 수의 남은 파일을 지운다
		DirAccess.remove_absolute(ProjectSettings.globalize_path(dir + old))
	# 같은 원본 재질끼리 한 표면으로 합친다.
	var by_mat := {}
	for p in parts:
		var key: Variant = p[3]
		if not by_mat.has(key): by_mat[key] = []
		by_mat[key].append(p)
	var mesh := ArrayMesh.new()
	var tris := 0
	var index := 0
	var tex_info := []
	for key in by_mat:
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		for p in by_mat[key]: st.append_from(p[0], p[1], fit * p[2])
		var arrays := st.commit_to_arrays()
		var idx: PackedInt32Array = arrays[Mesh.ARRAY_INDEX] if arrays[Mesh.ARRAY_INDEX] != null else PackedInt32Array()
		tris += (idx.size() if idx.size() > 0 else (arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array).size()) / 3
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

		var img := paint_image(key, max_px)
		img.generate_mipmaps()
		var tex := PortableCompressedTexture2D.new()
		tex.keep_compressed_buffer = true   # 헤드리스(더미 렌더러)에서도 저장 데이터를 남긴다
		tex.create_from_image(img, PortableCompressedTexture2D.COMPRESSION_MODE_LOSSY, false, 0.92)
		var tex_path := dir + "%s_paint%d.res" % [id, index]
		ResourceSaver.save(tex, tex_path)
		tex.take_over_path(tex_path)
		var mat := ShaderMaterial.new()
		mat.resource_name = "%s_%d" % [id, index]
		mat.shader = load(SHADER)
		mat.set_shader_parameter("rock_paint", tex)
		mat.set_shader_parameter("frost_amount", frost)
		mat.set_shader_parameter("moss_saturation", 1.0)
		mat.set_shader_parameter("paint_brightness", 1.1)
		var mat_path := dir + "%s_mat%d.tres" % [id, index]
		ResourceSaver.save(mat, mat_path)
		mat.take_over_path(mat_path)
		mesh.surface_set_material(index, mat)
		tex_info.append({"texture": tex_path, "size": [img.get_width(), img.get_height()], "material": mat_path})
		index += 1
	var mesh_path := dir + "%s_mesh.res" % id
	ResourceSaver.save(mesh, mesh_path)
	mesh.take_over_path(mesh_path)

	var root := Node3D.new()
	root.name = id.to_pascal_case()
	root.set_meta("nature_id", id)
	root.set_meta("label", label)
	root.set_meta("tripo_source", src.get_file())
	var mi := MeshInstance3D.new()
	mi.name = "Model"
	mi.mesh = mesh
	root.add_child(mi)
	mi.owner = root
	var packed := PackedScene.new()
	packed.pack(root)
	var scene_path := "res://scenes/props/nature/%s.tscn" % id
	ResourceSaver.save(packed, scene_path)

	var box := mesh.get_aabb()
	var report := {
		"id": id, "label": label, "source": src, "height_m": height, "yaw_deg": yaw, "frost": frost,
		"scale_from_source": k, "triangles": tris, "surfaces": index, "textures": tex_info,
		"size_m": [snappedf(box.size.x, .001), snappedf(box.size.y, .001), snappedf(box.size.z, .001)],
		"bottom_y": snappedf(box.position.y, .0001), "scene": scene_path, "mesh": mesh_path,
	}
	var f := FileAccess.open(dir + "report.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(report, "  "))
	f.close()
	scene.free()
	root.free()
	print("TRIPO_INGEST ", JSON.stringify(report))
	return 0
