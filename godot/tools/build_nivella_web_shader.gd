extends SceneTree
## 니벨라 둥지의 서리 거미줄 막·서리 알 VisualShader 2종을 다시 만든다(편집기에서 노드 그래프로 열어 조정 가능).
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/build_nivella_web_shader.gd
## 결과: shaders/vfx/nivella/nv_frost_web.tres, nv_frost_egg.tres — 메시·흔들림 연결은 scripts/visual/vfx/nivella_web.gd
## 기준(사용자 레퍼런스 2026-10-23, 알을 감싼 끈적한 막): 막이 위에서 아래로 흐르며 길고 짧은 가닥으로 갈라져
## 뾰족하게 박히고, 흐름 방향으로 늘어난 구멍이 숭숭 뚫려 속(알)이 비친다. 가장자리·구멍 테두리가 밝게 맺힌다.
##
## nv_frost_web(막): UV.x = 가닥 좌표(정수 하나가 가닥 하나), UV.y = 흐름(0 붙은 쪽 → 1 가닥 끝).
##   정점색 R = 흔들림 가중치. 알파 가위질(0.5)로 가장자리가 또렷하고 그림자도 구멍 모양대로 진다.
## nv_frost_egg(알): 속이 비치는 듯한 얼음 젤리 — 가운데 밝은 서리빛, 가장자리 깊은 청록, 떠다니는 기포, 느린 맥동.
## 정점(둘 다): 바람 살랑임 + 충격파 4개(shock_a~d: xyz 위치, w 경과 초 / shock_amp)가 거리만큼 늦게 닿아 출렁인다.

const F := VisualShader.TYPE_FRAGMENT
const VX := VisualShader.TYPE_VERTEX
const DIR := "res://shaders/vfx/nivella/"
const S := VisualShaderNode.PORT_TYPE_SCALAR
const V2 := VisualShaderNode.PORT_TYPE_VECTOR_2D
const V3 := VisualShaderNode.PORT_TYPE_VECTOR_3D
const V4 := VisualShaderNode.PORT_TYPE_VECTOR_4D
const T := VisualShaderNode.PORT_TYPE_TRANSFORM

const GLOBALS := """
float nvw_hash(vec2 p) {
	p = fract(p * vec2(127.13, 311.71));
	p += dot(p, p + 41.7);
	return fract(p.x * p.y);
}
float nvw_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(nvw_hash(i), nvw_hash(i + vec2(1.0, 0.0)), f.x),
		mix(nvw_hash(i + vec2(0.0, 1.0)), nvw_hash(i + vec2(1.0, 1.0)), f.x), f.y);
}
// 보로노이: x = 가장 가까운 점까지, y = 두 번째와의 차(칸 안쪽일수록 큼), zw = 칸 id
vec4 nvw_cells(vec2 p) {
	vec2 g = floor(p);
	vec2 f = fract(p);
	float d1 = 8.0;
	float d2 = 8.0;
	vec2 id = vec2(0.0);
	for (int y = -1; y <= 1; y++) {
		for (int x = -1; x <= 1; x++) {
			vec2 o = vec2(float(x), float(y));
			vec2 q = o + vec2(nvw_hash(g + o), nvw_hash(g + o + 17.3)) * 0.8 + 0.1 - f;
			float d = length(q);
			if (d < d1) { d2 = d1; d1 = d; id = g + o; } else if (d < d2) { d2 = d; }
		}
	}
	return vec4(d1, d2 - d1, id);
}
// 충격파 하나: 거리/속도만큼 늦게 닿아 감쇠 진동한다. s.xyz = 발생 위치, s.w = 경과 초.
float nvw_shock(vec3 wp, vec4 s, float amp) {
	if (amp <= 0.0) return 0.0;
	float d = length(wp.xz - s.xz);
	float tt = s.w - d / 16.0;
	if (tt <= 0.0) return 0.0;
	return amp * exp(-tt * 2.0) * sin(tt * 12.0) * exp(-d * 0.035);
}
"""

var shader: VisualShader
var next_id := 2
var srcs := {}
var ys := {}


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(DIR))
	var ok := _membrane()
	ok = _egg() and ok
	quit(0 if ok else 1)


# ---------------------------------------------------------------- 그래프 도우미

func begin(title: String, modes: Dictionary) -> void:
	shader = VisualShader.new()
	shader.resource_name = title
	shader.set_mode(Shader.MODE_SPATIAL)
	for k in modes:
		shader.set(k, modes[k])
	next_id = 2
	srcs = {}
	ys = {}
	var g := VisualShaderNodeGlobalExpression.new()
	g.resource_name = "Web helpers"
	g.expression = GLOBALS
	shader.add_node(F, g, Vector2(-1600, -600), _id())


func _id() -> int:
	next_id += 1
	return next_id - 1


func input(type: int, name: String) -> void:
	var n := VisualShaderNodeInput.new()
	n.input_name = name
	var id := _id()
	shader.add_node(type, n, Vector2(-1200, -300 + srcs.size() * 100), id)
	srcs["%d:input:%s" % [type, name]] = [id, 0]


func param(type: int, name: String, value) -> void:
	var n
	if value is Color:
		n = VisualShaderNodeColorParameter.new()
	elif value is Vector4:
		n = VisualShaderNodeVec4Parameter.new()
	else:
		n = VisualShaderNodeFloatParameter.new()
	n.parameter_name = name
	n.default_value_enabled = true
	n.default_value = value
	var id := _id()
	shader.add_node(type, n, Vector2(-1200, -300 + srcs.size() * 100), id)
	srcs["%d:param:%s" % [type, name]] = [id, 0]


func stage(type: int, title: String, x: float, ins: Array, outs: Array, code: String) -> bool:
	var n := VisualShaderNodeExpression.new()
	n.resource_name = title
	for i in ins.size():
		n.add_input_port(i, ins[i][0], ins[i][1])
	for i in outs.size():
		n.add_output_port(i, outs[i][0], outs[i][1])
	n.expression = code
	var id := _id()
	shader.add_node(type, n, Vector2(x, ys.get(type, -200.0)), id)
	n.size = Vector2(560, 380)
	ys[type] = ys.get(type, -200.0) + 160.0
	for i in ins.size():
		if not _link(type, ins[i][2], id, i):
			return false
	for i in outs.size():
		srcs["%d:stage:%s:%s" % [type, title, outs[i][1]]] = [id, i]
	return true


func _link(type: int, src: String, to_id: int, to_port: int) -> bool:
	var key := "%d:%s" % [type, src]
	if not srcs.has(key):
		push_error("unknown source " + key)
		return false
	var s: Array = srcs[key]
	if shader.connect_nodes(type, s[0], s[1], to_id, to_port) != OK:
		push_error("connect failed %s -> %d:%d" % [key, to_id, to_port])
		return false
	return true


## 출력 노드의 입력 포트를 내장 출력 이름(albedo, alpha_scissor_threshold …)으로 찾는다.
## 포트 목록을 스크립트에서 읽을 수 없어, 임시 셰이더의 각 포트에 값을 이어 생성 코드에 어떤 출력이 쓰이는지로 알아낸다.
static var _port_cache := {}

static func _port_index(type: int, port_name: String) -> int:
	var key := "%d:%s" % [type, port_name]
	if _port_cache.has(key):
		return _port_cache[key]
	for i in 40:
		var probe := VisualShader.new()
		probe.set_mode(Shader.MODE_SPATIAL)
		probe.add_node(type, VisualShaderNodeFloatConstant.new(), Vector2.ZERO, 2)
		probe.add_node(type, VisualShaderNodeVec3Constant.new(), Vector2.ZERO, 3)
		var src := 2 if probe.can_connect_nodes(type, 2, 0, 0, i) else (3 if probe.can_connect_nodes(type, 3, 0, 0, i) else -1)
		if src < 0 or probe.connect_nodes(type, src, 0, 0, i) != OK:
			continue
		for line in probe.get_code().split("\n"):
			var l := line.strip_edges()
			var head := l.get_slice(" ", 0)
			if ("n_out%dp0" % src) in l and l.contains(" = ") and head == head.to_upper() and head.length() > 1:
				_port_cache["%d:%s" % [type, l.get_slice(" ", 0).to_lower()]] = i
	return _port_cache.get(key, -1)


func _out(type: int, src: String, port_name: String) -> bool:
	var i := _port_index(type, port_name)
	if i < 0:
		push_error("no output port " + port_name)
		return false
	return _link(type, src, 0, i)


func finish(file: String) -> bool:
	shader.set_node_position(F, 0, Vector2(900, 0))
	shader.set_node_position(VX, 0, Vector2(400, 0))
	var err := ResourceSaver.save(shader, DIR + file + ".tres")
	print("NIVELLA_WEB_VS %s saved=%d fragment_nodes=%d vertex_nodes=%d" % [file, err, shader.get_node_list(F).size(), shader.get_node_list(VX).size()])
	return err == OK


## 공통 정점 단계: 바람 + 충격파.
func _sway_stage(wind: float, gain: float) -> bool:
	input(VX, "vertex")
	input(VX, "normal")
	input(VX, "color")
	input(VX, "time")
	input(VX, "model_matrix")
	param(VX, "sway", wind)
	param(VX, "shock_gain", gain)
	for k in ["a", "b", "c", "d"]:
		param(VX, "shock_" + k, Vector4(0, -100, 0, 99.0))
	param(VX, "shock_amp", Vector4.ZERO)
	var ok := stage(VX, "Wind and shock sway", -400,
		[[V3, "v", "input:vertex"], [V3, "n", "input:normal"], [V4, "col", "input:color"], [S, "t", "input:time"],
		[T, "model", "input:model_matrix"], [S, "sway", "param:sway"], [S, "gain", "param:shock_gain"],
		[V4, "sa", "param:shock_a"], [V4, "sb", "param:shock_b"], [V4, "sc", "param:shock_c"], [V4, "sd", "param:shock_d"],
		[V4, "amp", "param:shock_amp"]],
		[[V3, "moved"]], """
// 붙은 곳(가중치 0)은 그대로, 늘어진 곳일수록 크게 흔들린다.
vec3 wp = (model * vec4(v, 1.0)).xyz;
float pin = col.r;
float wind = sin(t * 1.15 + wp.x * 0.31 + wp.z * 0.23) * 0.65 + sin(t * 2.6 + wp.x * 0.9 - wp.y * 0.7) * 0.35;
float push = nvw_shock(wp, sa, amp.x) + nvw_shock(wp, sb, amp.y) + nvw_shock(wp, sc, amp.z) + nvw_shock(wp, sd, amp.w);
moved = v + n * (wind * sway + push * gain) * pin;
""")
	return ok and _out(VX, "stage:Wind and shock sway:moved", "vertex")


# ---------------------------------------------------------------- 1. 막·가닥 거미줄

func _membrane() -> bool:
	begin("Nivella / frost web membrane", {"modes/cull": 2})
	var ok := _sway_stage(0.05, 0.5)
	input(F, "uv")
	input(F, "color")
	param(F, "hole_amount", 0.8)
	param(F, "seed", 0.0)
	param(F, "pale", Color(0.90, 0.96, 0.98))
	param(F, "deep", Color(0.36, 0.56, 0.74))
	param(F, "glow", Color(0.55, 0.80, 1.0))
	ok = ok and stage(F, "Strands, taper, holes", -500,
		[[V2, "uv_in", "input:uv"], [V4, "vcol", "input:color"], [S, "holes_k", "param:hole_amount"], [S, "seed", "param:seed"]],
		[[S, "body"], [S, "rim"], [S, "v"], [S, "accent"], [S, "bulge"]], """
float x = uv_in.x;
v = uv_in.y;
float ti = floor(x);
float fx = fract(x) - 0.5;
float h = nvw_hash(vec2(ti, seed));
// 리듬(강약): 셋 중 하나는 굵은 주 가닥, 나머지 둘은 가는 가닥. 모두 끝까지 뻗어 바늘처럼 땅에 박힌다
accent = step(fract(ti / 3.0 + 0.01), 0.34);
float len = mix(mix(0.86, 0.97, h), 1.0, accent);
// 방향성: 가닥 중심선이 흐름을 따라 한쪽으로 휘며 내려간다
float cx = v * v * 0.35 * (h - 0.5) + sin(v * 3.0 + h * 6.28) * 0.06 * v + (nvw_noise(vec2(ti * 3.1, v * 2.5)) - 0.5) * 0.22 * v;
// 막 → 가닥: 붙은 곳은 이웃과 이어진 막, 곧 갈라져 주 가닥은 넓게 시작해 천천히, 가는 가닥은 빨리 바늘처럼 가늘어진다
// 정점색 G = 메시가 정한 막 길이(알·기둥을 덮는 덮개는 길게, 실 한 가닥은 0)
float mem_end = max(0.06 + h * 0.08, vcol.g + h * 0.08);
float t2 = clamp((v - mem_end) / max(len - mem_end, 0.01), 0.0, 1.0);
// 굵은 주 가닥은 넓게 시작해 끝까지 힘 있게, 가는 가닥은 가늘게 시작해 빨리 바늘이 된다(폭 차이를 크게 둬 강약이 분명하게)
float wide = mix(0.13, 0.38, accent);
float half_w = mix(0.62, wide, smoothstep(0.0, 0.16, t2)) * pow(1.0 - t2, mix(2.0, 1.1, accent));
float d = abs(fx - cx);
float aa = fwidth(x) * 1.2 + 1e-4;
body = (1.0 - smoothstep(half_w - aa, half_w + aa, d)) * step(v, len);
// 가닥 사이 연결 실: 군데군데 이웃 가닥으로 가는 실이 처지며 걸린다(위쪽에 많고 아래로 갈수록 드묾)
float row = floor(v * 7.0 + h * 3.0);
float by = fract(v * 7.0 + h * 3.0) - 0.5 + sin((fx + 0.5) * 3.14159) * 0.18;
float bw = fwidth(v * 7.0) * 1.1 + 1e-4;
float bridge = (1.0 - smoothstep(bw * 0.5, bw * 1.6, abs(by))) * step(0.86, nvw_hash(vec2(ti, row) + seed + 9.1)) * smoothstep(mem_end, mem_end + 0.05, v) * (1.0 - smoothstep(mem_end + 0.1, mem_end + 0.3, v));
body = max(body, bridge);
// 구멍: 흐름 방향으로 길쭉한 둥근 구멍. 막과 넓은 가닥 윗부분에만 뚫린다.
vec4 c = nvw_cells(vec2(x * 1.7, v * 2.4 + seed));
float band = smoothstep(0.03, 0.08, v) * (1.0 - smoothstep(mem_end + 0.18, mem_end + 0.36, v)) * smoothstep(0.14, 0.3, half_w);
float pick = step(1.0 - holes_k, nvw_hash(c.zw + seed));
float hr = mix(0.22, 0.4, nvw_hash(c.zw + seed + 1.7));
float hole = (1.0 - smoothstep(hr - 0.05, hr, c.x)) * band * pick;
body *= 1.0 - hole;
// 두께감: 가닥 가운데가 볼록, 가장자리와 구멍 둘레가 두툼하게 맺힌다
bulge = clamp(1.0 - pow(d / max(half_w, 1e-3), 2.0), 0.0, 1.0);
float edge_out = 1.0 - smoothstep(0.0, 0.06, half_w - d);
float edge_hole = (1.0 - smoothstep(0.0, 0.07, c.x - hr)) * band * pick;
rim = clamp(max(edge_out, edge_hole), 0.0, 1.0);
""")
	ok = ok and stage(F, "Frost membrane color", 150,
		[[S, "body", "stage:Strands, taper, holes:body"], [S, "rim", "stage:Strands, taper, holes:rim"],
		[S, "v", "stage:Strands, taper, holes:v"], [S, "accent", "stage:Strands, taper, holes:accent"],
		[S, "bulge", "stage:Strands, taper, holes:bulge"],
		[V3, "pale", "param:pale"], [V3, "deep", "param:deep"], [V3, "glow", "param:glow"]],
		[[V3, "col"], [S, "alpha"], [V3, "emit"], [S, "rough"]], """
// 볼록한 가운데·맺힌 테두리는 밝은 서리빛, 오목한 사이와 가닥 끝은 깊은 청록으로 가라앉는다.
col = mix(deep, pale, clamp(0.3 + bulge * 0.35 + rim * 0.4 - v * 0.22 + accent * 0.05, 0.0, 1.0));
alpha = body;
emit = glow * (0.12 + rim * 0.3) * mix(1.0, 0.6, v);
rough = mix(0.5, 0.22, rim);
""")
	ok = ok and _out(F, "stage:Frost membrane color:col", "albedo")
	ok = ok and _out(F, "stage:Frost membrane color:alpha", "alpha")
	ok = ok and _out(F, "stage:Frost membrane color:emit", "emission")
	ok = ok and _out(F, "stage:Frost membrane color:rough", "roughness")
	param(F, "scissor", 0.5)
	ok = ok and _out(F, "param:scissor", "alpha_scissor_threshold")
	return ok and finish("nv_frost_web")


# ---------------------------------------------------------------- 2. 서리 알

func _egg() -> bool:
	begin("Nivella / frost egg", {})
	var ok := _sway_stage(0.0, 0.18)
	input(F, "uv")
	input(F, "time")
	input(F, "normal")
	input(F, "view")
	param(F, "core", Color(0.82, 1.0, 0.98))
	param(F, "deep", Color(0.20, 0.46, 0.58))
	param(F, "rim_color", Color(0.85, 0.95, 1.0))
	param(F, "seed", 0.0)
	ok = ok and stage(F, "Jelly ice egg", -300,
		[[V2, "uv_in", "input:uv"], [S, "t", "input:time"], [V3, "n", "input:normal"], [V3, "view", "input:view"],
		[V3, "core", "param:core"], [V3, "deep", "param:deep"], [V3, "rim_c", "param:rim_color"], [S, "seed", "param:seed"]],
		[[V3, "col"], [V3, "emit"], [S, "rough"]], """
// 가운데(정면)는 속이 비치는 밝은 서리빛, 둘레로 갈수록 깊은 청록, 맨 가장자리는 희게 빛난다.
float facing = clamp(dot(normalize(n), normalize(view)), 0.0, 1.0);
float fres = pow(1.0 - facing, 2.4);
vec3 c = mix(deep, core, pow(facing, 1.3));
// 속의 그림자(자라는 새끼): 아래쪽 가운데가 흐리게 어둡다
float shade = smoothstep(0.55, 0.95, facing) * smoothstep(0.2, 0.6, 1.0 - uv_in.y) * (0.5 + 0.5 * nvw_noise(uv_in * vec2(6.0, 4.0) + seed));
c *= 1.0 - shade * 0.35;
// 떠다니는 기포: 작은 고리
vec4 b = nvw_cells(uv_in * vec2(14.0, 8.0) + vec2(seed, t * 0.04));
float bubble = (1.0 - smoothstep(0.0, 0.14, b.x)) * step(0.8, nvw_hash(b.zw + seed)) * 0.6;
// 느린 맥동
float pulse = 0.5 + 0.5 * sin(t * 1.4 + seed * 5.0);
// 겉빛은 낮추고 속빛(발광)을 키워 안에서 비치는 젤리처럼
col = c * 0.4 + rim_c * fres * 0.35 + vec3(1.0) * bubble * 0.2;
emit = core * (0.45 + 0.9 * pow(facing, 2.0) * (0.75 + 0.25 * pulse)) + rim_c * fres * 0.5 + vec3(0.8, 0.95, 1.0) * bubble * 0.3;
rough = 0.12;
""")
	ok = ok and _out(F, "stage:Jelly ice egg:col", "albedo")
	ok = ok and _out(F, "stage:Jelly ice egg:emit", "emission")
	ok = ok and _out(F, "stage:Jelly ice egg:rough", "roughness")
	return ok and finish("nv_frost_egg")
