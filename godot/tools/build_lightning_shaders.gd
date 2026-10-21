extends SceneTree
## 마녀 Q 번개 일격(Lightning Lance) VFX 용 VisualShader 그래프 3종을 다시 만든다(편집기에서 노드 그래프로 열어 조정 가능).
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/build_lightning_shaders.gd
## 결과: shaders/vfx/lightning/*.tres — 연출은 scripts/visual/vfx/lightning_vfx.gd
##   lt_bolt     번개 줄기: 꺾이는 등뼈 + 두꺼웠다 가늘어지는 칼날 같은 흰 심지 + 안쪽 푸른 구멍 + 잔가지 — 가산
##   lt_orb      끝점 구체: 하얗게 타는 핵 + 둘레를 할퀴는 갈고리 전호 + 빛무리 — 가산(카메라를 향한 판)
##   lt_scorch   지면 착탄: 전기 고리 + 갈라져 뻗는 방전선 + 그을음(식으며 남음) — 알파

const F := VisualShader.TYPE_FRAGMENT
const OUT_DIR := "res://shaders/vfx/lightning/"
const S := VisualShaderNode.PORT_TYPE_SCALAR
const V2 := VisualShaderNode.PORT_TYPE_VECTOR_2D
const V3 := VisualShaderNode.PORT_TYPE_VECTOR_3D
const V4 := VisualShaderNode.PORT_TYPE_VECTOR_4D
const O_ALBEDO := 0
const O_ALPHA := 1

## 그래프 공용 함수(전역 표현식 노드 한 개로 들어간다).
const GLOBALS := """
float lt_hash(vec2 p) {
	p = fract(p * vec2(127.13, 311.71));
	p += dot(p, p + 41.7);
	return fract(p.x * p.y);
}
float lt_hash1(float x) {
	return lt_hash(vec2(x, x * 0.37 + 1.3));
}
float lt_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(lt_hash(i), lt_hash(i + vec2(1.0, 0.0)), f.x),
		mix(lt_hash(i + vec2(0.0, 1.0)), lt_hash(i + vec2(1.0, 1.0)), f.x), f.y);
}
// 선형 보간 1D 노이즈 — 꺾인 직선 마디(번개의 지그재그)
float lt_zig(float x, float s) {
	float i = floor(x);
	float f = fract(x);
	return mix(lt_hash1(i + s * 13.1), lt_hash1(i + 1.0 + s * 13.1), f);
}
// 세 옥타브 지그재그(-0.5~0.5 근처)
float lt_path(float x, float s) {
	return (lt_zig(x * 5.0, s) - 0.5) * 0.62 + (lt_zig(x * 15.0, s + 3.0) - 0.5) * 0.24 + (lt_zig(x * 41.0, s + 7.0) - 0.5) * 0.09;
}
// 셀 경계까지 거리(F2-F1) — 방전선
float lt_cell(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	float d1 = 8.0;
	float d2 = 8.0;
	for (int y = -1; y <= 1; y++) {
		for (int x = -1; x <= 1; x++) {
			vec2 g = vec2(float(x), float(y));
			vec2 o = vec2(lt_hash(i + g), lt_hash(i + g + 17.3));
			float d = length(g + o - f);
			if (d < d1) { d2 = d1; d1 = d; } else if (d < d2) { d2 = d; }
		}
	}
	return d2 - d1;
}
"""

var shader: VisualShader
var next_id := 2
var srcs := {}
var stage_y := 0.0


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	var ok := true
	ok = _bolt() and ok
	ok = _orb() and ok
	ok = _scorch() and ok
	quit(0 if ok else 1)


# ---------------------------------------------------------------- 그래프 도우미(build_werewolf_shaders.gd 와 같은 방식)

func begin(title: String, modes: Dictionary) -> void:
	shader = VisualShader.new()
	shader.resource_name = title
	shader.set_mode(Shader.MODE_SPATIAL)
	for k in modes:
		shader.set(k, modes[k])
	next_id = 2
	srcs = {}
	stage_y = -200.0
	var g := VisualShaderNodeGlobalExpression.new()
	g.resource_name = "Lightning noise / zigzag"
	g.expression = GLOBALS
	shader.add_node(F, g, Vector2(-1500, -500), _id())


func _id() -> int:
	next_id += 1
	return next_id - 1


func input(name: String) -> void:
	var n := VisualShaderNodeInput.new()
	n.input_name = name
	var id := _id()
	shader.add_node(F, n, Vector2(-1200, -300 + srcs.size() * 110), id)
	srcs["input:" + name] = [id, 0]


func fparam(name: String, value: float) -> void:
	var n := VisualShaderNodeFloatParameter.new()
	n.parameter_name = name
	n.default_value_enabled = true
	n.default_value = value
	var id := _id()
	shader.add_node(F, n, Vector2(-1200, -300 + srcs.size() * 110), id)
	srcs["param:" + name] = [id, 0]


func cparam(name: String, value: Color) -> void:
	var n := VisualShaderNodeColorParameter.new()
	n.parameter_name = name
	n.default_value_enabled = true
	n.default_value = value
	var id := _id()
	shader.add_node(F, n, Vector2(-1200, -300 + srcs.size() * 110), id)
	srcs["param:" + name] = [id, 0]


## 표현식 노드 한 단계. ins = [[타입, 포트이름, 출처]], outs = [[타입, 포트이름]].
func stage(title: String, x: float, ins: Array, outs: Array, code: String) -> bool:
	var n := VisualShaderNodeExpression.new()
	n.resource_name = title
	for i in ins.size():
		n.add_input_port(i, ins[i][0], ins[i][1])
	for i in outs.size():
		n.add_output_port(i, outs[i][0], outs[i][1])
	n.expression = code
	var id := _id()
	shader.add_node(F, n, Vector2(x, stage_y), id)
	n.size = Vector2(520, 360)
	stage_y += 140.0
	for i in ins.size():
		if not _link(ins[i][2], id, i):
			return false
	for i in outs.size():
		srcs["stage:%s:%s" % [title, outs[i][1]]] = [id, i]
	return true


func _link(src: String, to_id: int, to_port: int) -> bool:
	if not srcs.has(src):
		push_error("unknown source " + src)
		return false
	var s: Array = srcs[src]
	if shader.connect_nodes(F, s[0], s[1], to_id, to_port) != OK:
		push_error("connect failed %s -> %d:%d" % [src, to_id, to_port])
		return false
	return true


func finish(file: String, outputs: Dictionary) -> bool:
	for port in outputs:
		if not _link(outputs[port], 0, port):
			return false
	shader.set_node_position(F, 0, Vector2(900, 0))
	var path := OUT_DIR + file + ".tres"
	var err := ResourceSaver.save(shader, path)
	print("LIGHTNING_VS %s saved=%d nodes=%d" % [file, err, shader.get_node_list(F).size()])
	return err == OK


const ADD := {"modes/blend": 1, "modes/cull": 2, "modes/depth_draw": 2, "flags/unshaded": true,
	"flags/shadows_disabled": true, "flags/fog_disabled": true}


# ---------------------------------------------------------------- 1. 번개 줄기

func _bolt() -> bool:
	begin("Lightning / lance bolt / jagged blade beam", ADD)
	input("uv")
	fparam("reach", 1.0)          # 0→1 시전점에서 끝점으로 뻗는 머리 위치
	fparam("dissolve", 0.0)       # 0→1 꼬리(시전점)부터 끊어지며 사라짐
	fparam("intensity", 1.0)
	fparam("thickness", 1.0)      # 칼날 굵기 배율(곁가지 줄기는 가늘게)
	fparam("seed", 0.0)           # 바꿀 때마다 모양이 새로 튄다(지직거림)
	cparam("color_core", Color(0.88, 1.0, 1.0))
	cparam("color_glow", Color(0.12, 0.78, 1.0))
	cparam("color_deep", Color(0.04, 0.3, 1.0))
	var ok := stage("Bolt shape", -500,
		[[V2, "uv_in", "input:uv"], [S, "reach", "param:reach"], [S, "dis", "param:dissolve"], [S, "thick", "param:thickness"],
		[S, "seed", "param:seed"]],
		[[S, "core"], [S, "glow"], [S, "hole"], [S, "branch"], [S, "head"]], """
// uv.x = 줄기 방향(0 시전점 → 1 끝점), uv.y = 가로(0.5 가 가운데).
float x = uv_in.x;
float y = (uv_in.y - 0.5) * 2.0;
// 양 끝은 가운데로 모이고 가운데에서 크게 꺾인다
float pin = pow(clamp(sin(x * 3.14159), 0.0, 1.0), 0.45);
float off = lt_path(x * 2.2, seed) * 1.15 * pin;
float d = abs(y - off);
// 칼날: 마디마다 두꺼웠다 가늘어진다(참고 원화의 길게 늘어진 날 모양)
float blade = lt_zig(x * 5.5 + seed * 1.7, seed + 11.0);
blade = blade * blade;
float w = (0.035 + 0.28 * blade) * thick * (0.3 + 0.7 * pin);
// 뻗는 머리와 사라지는 꼬리
float drawn = 1.0 - smoothstep(reach - 0.015, reach, x);
float erode = lt_noise(vec2(x * 26.0 + seed * 3.0, y * 3.0)) * 0.35 + x * 0.65;
float alive = smoothstep(dis * 1.1 - 0.06, dis * 1.1, erode);
float vis = drawn * alive;
core = (1.0 - smoothstep(w * 0.7, w * 0.85, d)) * vis;
glow = exp(-max(d - w * 0.7, 0.0) * 16.0) * vis;
// 두꺼운 날 안쪽의 푸른 타원 구멍
float hn = lt_noise(vec2(x * 9.0 + seed * 5.0, (y - off) / max(w, 0.02) * 0.8));
hole = smoothstep(0.6, 0.68, hn) * smoothstep(0.08, 0.15, w) * (1.0 - smoothstep(w * 0.35, w * 0.6, d)) * core;
// 잔가지: 다른 씨앗의 가는 지그재그가 군데군데에서만 보인다
float boff = off + lt_path(x * 3.4, seed + 5.0) * 1.1 * pin;
float bmask = smoothstep(0.55, 0.68, lt_zig(x * 3.0 + seed * 2.3, seed + 19.0));
float bd = abs(y - boff);
branch = (1.0 - smoothstep(0.01, 0.024, bd)) * bmask * vis + exp(-bd * 55.0) * bmask * vis * 0.35;
// 뻗어 나가는 머리의 섬광
head = exp(-abs(x - reach) * 30.0) * exp(-d * 6.0) * step(x, reach + 0.03) * (1.0 - step(0.999, reach));
""")
	ok = ok and stage("Bolt color", 0,
		[[S, "core", "stage:Bolt shape:core"], [S, "glow", "stage:Bolt shape:glow"], [S, "hole", "stage:Bolt shape:hole"],
		[S, "branch", "stage:Bolt shape:branch"], [S, "head", "stage:Bolt shape:head"], [S, "intensity", "param:intensity"],
		[V4, "c_core", "param:color_core"], [V4, "c_glow", "param:color_glow"], [V4, "c_deep", "param:color_deep"]],
		[[V3, "color"], [S, "alpha"]], """
float c = clamp(core - hole, 0.0, 1.0);
float rim = clamp(glow - core, 0.0, 1.0);
vec3 col = c_deep.rgb * rim * 0.55 + c_glow.rgb * (rim * rim * 0.9 + hole * 0.55 + branch * 0.9) + c_core.rgb * (c * 1.15 + head * 1.4);
color = col * intensity;
alpha = clamp(c + rim * 0.6 + hole * 0.4 + branch + head, 0.0, 1.0);
""")
	return ok and finish("lt_bolt", {O_ALBEDO: "stage:Bolt color:color", O_ALPHA: "stage:Bolt color:alpha"})


# ---------------------------------------------------------------- 2. 끝점 구체

func _orb() -> bool:
	begin("Lightning / impact orb / hooked arcs", ADD)
	input("uv")
	fparam("pulse", 1.0)          # 0→1 핵이 부풀었다 터짐
	fparam("arcs", 1.0)           # 0→1 둘레 전호가 튀어나가는 반지름
	fparam("fade", 1.0)
	fparam("seed", 0.0)
	cparam("color_core", Color(0.95, 1.0, 1.0))
	cparam("color_glow", Color(0.25, 0.8, 1.0))
	var ok := stage("Orb", -400,
		[[V2, "uv_in", "input:uv"], [S, "pulse", "param:pulse"], [S, "arcs", "param:arcs"], [S, "fade", "param:fade"],
		[S, "seed", "param:seed"], [V4, "c_core", "param:color_core"], [V4, "c_glow", "param:color_glow"]],
		[[V3, "color"], [S, "alpha"]], """
vec2 p = (uv_in - vec2(0.5)) * 2.0;
float r = length(p);
float a = atan(p.y, p.x);
// 하얗게 타는 핵(가장자리가 살짝 일렁인다)
float cr = 0.26 + 0.12 * pulse + (lt_noise(vec2(a * 3.0 + seed, seed)) - 0.5) * 0.06;
float core = 1.0 - smoothstep(cr * 0.8, cr, r);
float halo = exp(-max(r - cr, 0.0) * 5.5) * (1.0 - core);
// 갈고리 전호 4~5개: 반지름을 따라 휘감기며 군데군데만 그려진다
float arc = 0.0;
for (int i = 0; i < 5; i++) {
	float fi = float(i);
	float rad = (0.42 + 0.34 * lt_hash1(fi + seed * 7.0)) * (0.55 + 0.5 * arcs);
	float twist = (lt_hash1(fi * 3.3 + seed) - 0.5) * 2.4;
	float ang = a + twist * (r - rad) * 3.0;
	float jag = (lt_zig(ang * 4.0 + fi * 5.0, seed + fi) - 0.5) * 0.08;
	float ring = 1.0 - smoothstep(0.012, 0.032, abs(r - rad - jag));
	float start = lt_hash1(fi * 7.1 + seed * 3.0) * 6.2831853;
	float span = 0.7 + 1.1 * lt_hash1(fi * 1.9 + seed);
	float da = mod(a - start + 6.2831853, 6.2831853);
	float on = step(da, span) * smoothstep(0.0, 0.2, da) * (1.0 - smoothstep(span - 0.25, span, da));
	arc = max(arc, ring * on);
}
float edge = 1.0 - smoothstep(0.82, 1.0, r);
color = (c_core.rgb * (core * 2.2 + arc * 1.4) + c_glow.rgb * (halo * 1.4 + arc * 0.6)) * (0.7 + 0.6 * pulse);
alpha = clamp(core + halo * 0.85 + arc, 0.0, 1.0) * fade * edge;
""")
	return ok and finish("lt_orb", {O_ALBEDO: "stage:Orb:color", O_ALPHA: "stage:Orb:alpha"})


# ---------------------------------------------------------------- 3. 지면 착탄 자국

func _scorch() -> bool:
	begin("Lightning / ground strike / discharge cracks + scorch", {"modes/blend": 0, "modes/cull": 2,
		"modes/depth_draw": 2, "flags/unshaded": true, "flags/shadows_disabled": true})
	input("uv")
	fparam("wave", 1.0)           # 0→1 전기 고리 반지름
	fparam("spread", 1.0)         # 0→1 방전선이 바깥으로 뻗음
	fparam("cool", 0.0)           # 0 달아오름 → 1 식어 그을음만
	fparam("fade", 1.0)
	fparam("seed", 0.0)
	cparam("color_hot", Color(0.55, 0.95, 1.0))
	cparam("color_scorch", Color(0.1, 0.12, 0.2))
	var ok := stage("Scorch coverage", -500,
		[[V2, "uv_in", "input:uv"], [S, "wave", "param:wave"], [S, "spread", "param:spread"], [S, "seed", "param:seed"]],
		[[S, "ring"], [S, "lines"], [S, "burn"]], """
vec2 p = (uv_in - vec2(0.5)) * 2.0;
float r = length(p);
float a = atan(p.y, p.x);
float edge = wave * (1.0 + 0.08 * (lt_noise(vec2(a * 6.0, seed)) - 0.5));
ring = (1.0 - smoothstep(0.0, 0.045, abs(r - edge))) * (1.0 - wave * 0.7);
// 셀 경계를 각도 방향으로 늘려 바깥으로 갈라지는 방전선
float cl = 1.0 - smoothstep(0.0, 0.05, lt_cell(vec2(a * 2.2 + seed, r * 6.0 - seed)));
float lane = abs(fract(a * 6.0 / 6.2831853 + lt_path(r * 1.5, seed) * 0.35) - 0.5);
float radial = smoothstep(0.46, 0.49, lane);
lines = max(cl * 0.6 * (1.0 - smoothstep(0.2, 0.7, r)), radial) * (1.0 - smoothstep(spread * 0.92 - 0.1, spread * 0.92, r)) * smoothstep(0.06, 0.14, r);
burn = (1.0 - smoothstep(0.15, 0.42, r + (lt_noise(p * 5.0 + seed) - 0.5) * 0.15)) * smoothstep(0.0, 0.3, spread);
""")
	ok = ok and stage("Scorch color", 0,
		[[S, "ring", "stage:Scorch coverage:ring"], [S, "lines", "stage:Scorch coverage:lines"], [S, "burn", "stage:Scorch coverage:burn"],
		[S, "cool", "param:cool"], [S, "fade", "param:fade"], [V4, "c_hot", "param:color_hot"], [V4, "c_scorch", "param:color_scorch"]],
		[[V3, "color"], [S, "alpha"]], """
vec3 hot = mix(c_hot.rgb * 1.8, vec3(1.0), lines * 0.35);
vec3 col = mix(c_scorch.rgb, mix(hot, c_scorch.rgb * 1.4, cool), lines);
col = mix(col, vec3(0.85, 1.0, 1.0) * 1.6, ring * (1.0 - cool));
color = col;
alpha = clamp(lines * (1.0 - cool * 0.45) + burn * 0.55 + ring * (1.0 - cool), 0.0, 1.0) * fade;
""")
	return ok and finish("lt_scorch", {O_ALBEDO: "stage:Scorch color:color", O_ALPHA: "stage:Scorch color:alpha"})
