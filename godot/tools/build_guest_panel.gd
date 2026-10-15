extends SceneTree
## Rebuild editable VisualShader: UV -> slow edge warp -> rounded ink silhouette -> output.
const F := VisualShader.TYPE_FRAGMENT
var shader: VisualShader

func _initialize() -> void:
	shader = VisualShader.new()
	shader.resource_name = "Guest / Floating ink / slow organic silhouette"
	shader.set_mode(Shader.MODE_CANVAS_ITEM)
	var uv := VisualShaderNodeInput.new()
	uv.input_name = "uv"
	shader.add_node(F, uv, Vector2(-620, 40), 2)
	parameter("motion_time", 0.0, Vector2(-620, 180), 3)
	parameter("reveal", 1.0, Vector2(90, 420), 4)
	parameter("opacity", 0.98, Vector2(90, 540), 5)
	var warp := expression("Slow cloth / 2 waves", [[VisualShaderNode.PORT_TYPE_VECTOR_2D, "uv_in"], [VisualShaderNode.PORT_TYPE_SCALAR, "clock"]],
		[[VisualShaderNode.PORT_TYPE_VECTOR_2D, "warped"]], """
warped = uv_in;
warped.y += 0.018 * sin(uv_in.x * 12.0 + clock * 0.48)
          + 0.009 * sin(uv_in.x * 23.0 - clock * 0.31);
warped.x += 0.007 * sin(uv_in.y * 9.0 + clock * 0.37);
""")
	shader.add_node(F, warp, Vector2(-340, 40), 6)
	var silhouette := expression("Soft irregular silhouette", [[VisualShaderNode.PORT_TYPE_VECTOR_2D, "uv_shape"], [VisualShaderNode.PORT_TYPE_SCALAR, "reveal_amount"], [VisualShaderNode.PORT_TYPE_SCALAR, "alpha"]],
		[[VisualShaderNode.PORT_TYPE_SCALAR, "ink_alpha"]], """
vec2 p = (uv_shape - vec2(0.5)) * vec2(2.4, 1.0);
vec2 q = abs(p) - vec2(1.055, 0.335);
float d = length(max(q, vec2(0.0))) + min(max(q.x, q.y), 0.0) - 0.108;
float edge = 1.0 - smoothstep(-0.003, 0.003, d);
float wipe = 1.0 - smoothstep(reveal_amount * 1.16 - 0.12, reveal_amount * 1.16, uv_shape.x);
ink_alpha = edge * wipe * alpha;
""")
	shader.add_node(F, silhouette, Vector2(100, 30), 7)
	var pigment := expression("Near black violet pigment", [[VisualShaderNode.PORT_TYPE_VECTOR_2D, "uv_color"], [VisualShaderNode.PORT_TYPE_SCALAR, "clock"]],
		[[VisualShaderNode.PORT_TYPE_VECTOR_3D, "ink_color"]], """
float flow = 0.5 + 0.5 * sin(uv_color.x * 5.0 + uv_color.y * 3.0 + clock * 0.22);
ink_color = mix(vec3(0.032, 0.022, 0.049), vec3(0.051, 0.034, 0.073), flow * 0.5);
""")
	shader.add_node(F, pigment, Vector2(100, -250), 8)
	for connection in [[2,0,6,0], [3,0,6,1], [6,0,7,0], [4,0,7,1], [5,0,7,2], [2,0,8,0], [3,0,8,1], [8,0,0,0], [7,0,0,1]]:
		var error := shader.connect_nodes(F, connection[0], connection[1], connection[2], connection[3])
		if error != OK:
			push_error("VisualShader connection failed: " + str(connection))
			quit(1)
			return
	shader.set_node_position(F, 0, Vector2(640, 40))
	var result := ResourceSaver.save(shader, "res://shaders/guest_ink_panel.tres")
	print("GUEST_VISUAL_SHADER saved=", result, " nodes=", shader.get_node_list(F).size())
	quit(0 if result == OK else 1)

func parameter(id: String, value: float, at: Vector2, node_id: int) -> void:
	var node := VisualShaderNodeFloatParameter.new()
	node.parameter_name = id
	node.default_value_enabled = true
	node.default_value = value
	shader.add_node(F, node, at, node_id)

func expression(title: String, inputs: Array, outputs: Array, code: String) -> VisualShaderNodeExpression:
	var node := VisualShaderNodeExpression.new()
	node.resource_name = title
	for i in inputs.size(): node.add_input_port(i, inputs[i][0], inputs[i][1])
	for i in outputs.size(): node.add_output_port(i, outputs[i][0], outputs[i][1])
	node.expression = code
	return node

