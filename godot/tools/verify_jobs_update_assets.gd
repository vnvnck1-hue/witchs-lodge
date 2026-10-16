extends SceneTree
## Validate this handoff's UI PNGs, wildlife imports, wrappers and motion pivots.
const ICONS := ["icon_timber","icon_raw_meat","icon_rabbit_pelt","icon_treasure_chest","icon_relic_unknown","icon_moonlit_charm","icon_hearth_ember","icon_old_tree_heart","icon_wolf_fang_pendant","icon_frost_queen_tear","icon_arrow"]
var failures:Array[String]=[]
var records:Array=[]

func _initialize() -> void:
	call_deferred("_run")

func _check(ok:bool,message:String) -> void:
	if not ok:
		failures.append(message)
		push_error(message)

func _meshes(node:Node,result:Array) -> void:
	if node is MeshInstance3D:
		result.append(node)
	for child in node.get_children():
		_meshes(child,result)

func _bounds(node:Node3D) -> AABB:
	var meshes:Array=[]
	_meshes(node,meshes)
	var bounds := AABB()
	var first:=true
	for mi:MeshInstance3D in meshes:
		var box:AABB=node.global_transform.affine_inverse()*mi.global_transform*mi.get_aabb()
		bounds=box if first else bounds.merge(box)
		first=false
	return bounds

func _png(path:String,size:Vector2i) -> void:
	var im:=Image.load_from_file(ProjectSettings.globalize_path(path))
	if im==null or im.is_empty():
		_check(false,"Missing UI PNG: "+path)
		return
	_check(im.get_size()==size and im.get_format()==Image.FORMAT_RGBA8,"Wrong UI format/size: "+path)
	for pos in [Vector2i.ZERO,Vector2i(size.x-1,0),Vector2i(0,size.y-1),size-Vector2i.ONE]:
		_check(im.get_pixelv(pos).a<.02,"UI corner not transparent: "+path)
	_check(im.detect_alpha(),"UI alpha missing: "+path)
	var t=load(path)
	_check(t is Texture2D,"UI import failed: "+path)

func _run() -> void:
	for id in ICONS:
		_png("res://assets/ui/icons/"+id+".png",Vector2i(96,96))
	for id in ["chest_closed","chest_open"]:
		_png("res://assets/ui/"+id+".png",Vector2i(512,512))
	for id in ["rabbit","deer"]:
		for wrapper in [false,true]:
			var path:String=("res://scenes/props/nature/"+id+".tscn") if wrapper else ("res://assets/nature/"+id+".glb")
			var packed=load(path)
			_check(packed is PackedScene,"Wildlife import failed: "+path)
			if not packed is PackedScene:continue
			var node:Node3D=packed.instantiate()
			root.add_child(node)
			var prefix:String=""
			_check(node.has_node(prefix+"Body"),"Missing Body: "+path)
			_check(node.has_node(prefix+"Body/Head"),"Missing Body/Head: "+path)
			_check(node.transform.is_equal_approx(Transform3D.IDENTITY),"Nonidentity root: "+path)
			var meshes:Array=[]
			_meshes(node,meshes)
			_check(meshes.size()==2,"Expected body and head draw meshes: "+path)
			var triangles:=0
			for mi:MeshInstance3D in meshes:
				_check(mi.mesh.get_surface_count()==1,"Unexpected surfaces: "+path)
				var arrays:Array=mi.mesh.surface_get_arrays(0)
				_check(not arrays[Mesh.ARRAY_COLOR].is_empty(),"Missing vertex colors: "+path)
				triangles+=arrays[Mesh.ARRAY_INDEX].size()/3
				if wrapper:
					_check(mi.material_override==load("res://assets/nature/materials/nature_paint.tres"),"Lost shared nature material: "+str(mi.get_path()))
			var box:=_bounds(node)
			var expected_length:float=.45 if id=="rabbit" else 1.5
			var expected_height:float=.35 if id=="rabbit" else 1.6
			_check(absf(box.size.z-expected_length)<.005,"Wrong length: "+path+" "+str(box))
			_check(absf(box.size.y-expected_height)<.005,"Wrong height: "+path+" "+str(box))
			_check(absf(box.position.y)<.001,"Feet off ground: "+path)
			if node.has_node(prefix+"Body/Head"):
				var body:Node3D=node.get_node(prefix+"Body")
				var head:Node3D=node.get_node(prefix+"Body/Head")
				var original_head:Transform3D=head.transform
				var before:Vector3=head.global_position
				body.position.y+=.04
				_check(absf(head.global_position.y-before.y-.04)<.001,"Head does not follow Body: "+path)
				body.position.y-=.04
				var initial_box:=_bounds(node)
				head.rotation.x=deg_to_rad(45)
				_check(not _bounds(node).is_equal_approx(initial_box),"Head pivot does not move geometry: "+path)
				head.transform=original_head
			records.append({"path":path,"meshes":meshes.size(),"triangles":triangles,"bounds":{"min":[box.position.x,box.position.y,box.position.z],"size":[box.size.x,box.size.y,box.size.z]},"body_head_motion":true,"vertex_colors":true,"shared_nature_material":wrapper})
			node.free()
	var report:={"passed":failures.is_empty(),"engine":Engine.get_version_info().string,"icons":ICONS,"ui_png_count":13,"wildlife":records,"failures":failures}
	var path:=ProjectSettings.globalize_path("res://../output/jobs-update-v01/asset-verification.json")
	var file:=FileAccess.open(path,FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t")+"\n")
	print("JOBS_UPDATE_ASSETS_VERIFY ",JSON.stringify(report))
	quit(0 if failures.is_empty() else 1)
