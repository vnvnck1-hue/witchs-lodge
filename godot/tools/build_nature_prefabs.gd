extends SceneTree
## Generates ordinary editable PackedScenes, no runtime generator dependency.
const FOLDER := "res://scenes/props/nature/"
const NatureShader := preload("res://shaders/nature_prop.gdshader")
const WIND := {"tree": "nature_wind_tree", "dead_snag": "nature_wind_bare", "fern_clump": "nature_wind_undergrowth", "berry_shrub": "nature_wind_undergrowth"}
var report: Array = []

## Living plants get a wind-idle variant of the shared shader; rocks, logs and fungi stay static.
static func material_id(entry: Dictionary) -> String:
	return WIND.get(entry.id, WIND.get(entry.category, "nature_paint"))

func _initialize() -> void:
	call_deferred("_run")

func _own(node: Node, owner_node: Node) -> void:
	node.owner = owner_node
	for child in node.get_children(): _own(child, owner_node)

func _paint(node: Node, mat: Material) -> void:
	if node is MeshInstance3D: node.material_override = mat
	for child in node.get_children(): _paint(child, mat)

func _save(node: Node3D, id: String) -> void:
	for child in node.get_children(): _own(child, node)
	var packed := PackedScene.new()
	assert(packed.pack(node) == OK, "Cannot pack " + id)
	assert(ResourceSaver.save(packed, FOLDER + id + ".tscn") == OK)
	node.free()

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(FOLDER)
	DirAccess.make_dir_recursive_absolute("res://assets/nature/materials/")
	var mat := ShaderMaterial.new()
	mat.shader = NatureShader
	mat.resource_name = "Nature vertex painted toon"
	assert(ResourceSaver.save(mat, "res://assets/nature/materials/nature_paint.tres") == OK)
	mat = load("res://assets/nature/materials/nature_paint.tres")
	var catalog: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/nature/catalog.json"))
	for entry in catalog.assets:
		# Reference the imported scene directly: do not embed/copy glTF ArrayMeshes.
		var text := '[gd_scene load_steps=3 format=3]\n\n'
		text += '[ext_resource type="PackedScene" path="res://assets/nature/%s.glb" id="1"]\n' % entry.id
		text += '[ext_resource type="Material" path="res://assets/nature/materials/nature_paint.tres" id="2"]\n\n'
		text += '[node name="%s" type="Node3D"]\nmetadata/nature_id = "%s"\nmetadata/label = "%s"\n\n' % [entry.id.to_pascal_case(),entry.id,entry.label]
		text += '[node name="Model" parent="." instance=ExtResource("1")]\n\n'
		text += '[node name="%s" parent="Model" index="0"]\nmaterial_override = ExtResource("2")\n\n[editable path="Model"]\n' % entry.id
		var file := FileAccess.open(FOLDER + entry.id + ".tscn", FileAccess.WRITE)
		file.store_string(text)
		file.close()
		assert(entry.non_manifold_edges == 0, "Open edges in " + entry.id)
		report.append({"id": entry.id, "triangles": entry.triangles})
	# Reuse saved assets for clusters: each constituent remains individually movable.
	var clusters := {
		"cluster_spire_grove": [["rock_spire", Vector3.ZERO, 0.0, 1.0], ["pine_swept", Vector3(-1.45,0,-.72), -.35, .78], ["pine_sapling", Vector3(1.2,0,.18), .6, .90], ["fern_clump", Vector3(-.6,0,1.35), 0.0, .70]],
		"cluster_ledge_forest": [["rock_ledge", Vector3.ZERO, 0.0, 1.0], ["pine_broad", Vector3(-1.5,0,-.85), .8, .78], ["pine_sparse", Vector3(1.2,0,-.8), -.5, .61], ["berry_shrub", Vector3(.82,0,1.0), .3, .80]],
		"cluster_ancient_log": [["fallen_log", Vector3.ZERO, 0.0, 1.0], ["dead_snag", Vector3(-1.4,0,-.7), -.45, .72], ["pine_sapling", Vector3(1.3,0,-.8), .8, 1.0], ["mushroom_cluster", Vector3(.7,0,.85), 0.0, 1.0]],
		"cluster_snow_spire": [["rock_spire_snow", Vector3.ZERO, 0.0, 1.0], ["pine_swept_snow", Vector3(-1.4,0,-.8), -.35, .78], ["pine_sapling_snow", Vector3(1.3,0,.0), .6, .9]],
		"cluster_snow_ledge": [["rock_ledge_snow", Vector3.ZERO, 0.0, 1.0], ["pine_broad_snow", Vector3(-1.5,0,-.9), .8, .78], ["pine_sparse_snow", Vector3(1.3,0,-.8), -.5, .61]],
	}
	for id in clusters:
		var parts: Array = clusters[id]
		var text := '[gd_scene load_steps=%d format=3]\n\n' % (parts.size()+1)
		for i in parts.size():
			text += '[ext_resource type="PackedScene" path="%s%s.tscn" id="%d"]\n' % [FOLDER,parts[i][0],i+1]
		text += '\n[node name="%s" type="Node3D"]\nmetadata/nature_id = "%s"\n' % [id.to_pascal_case(),id]
		for i in parts.size():
			var part: Array = parts[i]
			text += '\n[node name="%s" parent="." instance=ExtResource("%d")]\nposition = Vector3(%f,%f,%f)\nrotation = Vector3(0,%f,0)\nscale = Vector3(%f,%f,%f)\n' % [part[0].to_pascal_case(),i+1,part[1].x,part[1].y,part[1].z,part[2],part[3],part[3],part[3]]
		var file := FileAccess.open(FOLDER + id + ".tscn", FileAccess.WRITE)
		file.store_string(text)
		file.close()
		report.append({"id": id, "parts": clusters[id].size()})
	var f := FileAccess.open("res://assets/nature/prefab_manifest.json", FileAccess.WRITE)
	f.store_string(JSON.stringify({"prefabs":report,"count":report.size()}, "\t"))
	print("NATURE_PREFABS_READY ", report.size())
	quit()
