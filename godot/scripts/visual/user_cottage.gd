extends RefCounted
## User's left-hand cottage, isolated without changing its UVs, texture or geometry.
const COTTAGE := preload("res://assets/cottage/user_cottage.glb")
const SHADER := preload("res://shaders/user_cottage.gdshader")
const B := preload("res://scripts/visual/build.gd")
static var _material: ShaderMaterial
const MODEL_SCALE := 17.0
const MODEL_OFFSET := Vector3(0,0,.35)
const CHIMNEY := Vector3(1.20,5.23,1.28)

static func build(root: Node3D) -> Dictionary:
	var visual:=B.node(root,Vector3.ZERO,Vector3.ZERO,"LodgeVisual")
	var cottage: Node3D=COTTAGE.instantiate()
	cottage.name="UserCottage"
	cottage.scale=Vector3.ONE*MODEL_SCALE
	cottage.position=MODEL_OFFSET
	visual.add_child(cottage)
	cottage.set_meta("source_variant","left")
	for mesh: MeshInstance3D in cottage.find_children("*","MeshInstance3D",true,false):
		for i in mesh.mesh.get_surface_count():
			var source: StandardMaterial3D=mesh.mesh.surface_get_material(i)
			if _material==null:
				_material=ShaderMaterial.new()
				_material.resource_name="UserCottageOriginalPaint"
				_material.shader=SHADER
				_material.set_shader_parameter("cottage_paint",source.albedo_texture)
			mesh.set_surface_override_material(i,_material)
	var lights:=B.node(visual,Vector3.ZERO,Vector3.ZERO,"WarmLights")
	var warm:=Color(1.0,.65,.32)
	B.omni(lights,Vector3(-.72,1.45,2.66),warm,1.0,4.5,true,1.3)
	B.omni(lights,Vector3(2.36,1.35,.0),warm,.7,4.1,false,1.3)
	return {"visual":visual,"lights":lights}
