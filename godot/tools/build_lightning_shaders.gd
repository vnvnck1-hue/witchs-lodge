extends SceneTree
## 마녀 Q 번개 일격(Lightning Lance) VFX 용 VisualShader 그래프 3종을 다시 만든다(편집기에서 노드 그래프로 열어 조정 가능).
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/build_lightning_shaders.gd
## 결과: shaders/vfx/lightning/*.tres — 연출은 scripts/visual/vfx/lightning_vfx.gd
##   lt_bolt     번개 줄기: 꺾이는 등뼈 + 두꺼웠다 가늘어지는 칼날 같은 흰 심지 + 안쪽 푸른 구멍 + 잔가지 — 가산
##   lt_orb      끝점 구체: 하얗게 타는 핵 + 둘레를 할퀴는 갈고리 전호 + 빛무리 — 가산(카메라를 향한 판)
##   lt_scorch   지면 착탄: 전기 고리 + 갈라져 뻗는 방전선 + 그을음(식으며 남음) — 알파
## 프리셋 1 뇌창(Thunder Spear) — 금빛·흰빛 셀 음영, 딱 끊기는 경계(부드러운 빛무리 최소)
##   lt_spear    날아가는 창머리: 마름모 창날 + 가운데 능선 + 옆 미늘, 흰 심/금 띠/보라 외곽 — 가산
##   lt_helix    창이 지나간 자리: 꺾인 나선 두 가닥이 가운데 심을 감싸고, 꼬리부터 각지게 타서 사라짐 — 가산
##   lt_star     맞은 자리: 네 갈래 큰 별 + 45° 작은 별 + 날카로운 파편 삼각형 + 딱 끊긴 고리 — 가산
## 프리셋 2 흑뢰(Black Thunder) — 검보라 심 + 자홍·흰 테두리(뒤집힌 색), 땅이 찢기고 하늘에서 내리꽂힘
##   lt_rift     땅의 균열: 시전자에서 끝으로 찢겨 열리는 검은 틈 + 빛나는 가장자리 + 잔금 — 알파(빛나는 테두리는 HDR)
##   lt_pillar   하늘에서 꽂히는 번개 기둥: 검은 심 + 자홍 테두리 + 바닥 갈래 — 알파

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
	ok = _spear() and ok
	ok = _helix() and ok
	ok = _star() and ok
	ok = _rift() and ok
	ok = _pillar() and ok
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


const MIX := {"modes/blend": 0, "modes/cull": 2, "modes/depth_draw": 2, "flags/unshaded": true,
	"flags/shadows_disabled": true, "flags/fog_disabled": true}


# ---------------------------------------------------------------- 4. 프리셋 1 · 창머리

func _spear() -> bool:
	begin("Lightning / thunder spear / cel lance head", ADD)
	input("uv")
	fparam("flare", 1.0)          # 1 막 쏜 순간 → 0 날아가는 중(창날 뒤 불꽃 크기)
	fparam("fade", 1.0)
	fparam("seed", 0.0)
	cparam("color_core", Color(1.0, 1.0, 0.94))
	cparam("color_band", Color(1.0, 0.76, 0.22))
	cparam("color_edge", Color(0.62, 0.3, 1.0))
	var ok := stage("Lance head", -400,
		[[V2, "uv_in", "input:uv"], [S, "flare", "param:flare"], [S, "fade", "param:fade"], [S, "seed", "param:seed"],
		[V4, "c_core", "param:color_core"], [V4, "c_band", "param:color_band"], [V4, "c_edge", "param:color_edge"]],
		[[V3, "color"], [S, "alpha"]], """
// uv.x = 뒤(0) → 창끝(1), uv.y = 가로
float x = uv_in.x;
float y = (uv_in.y - 0.5) * 2.0;
// 창날 옆모습: 뒤로 길게 가늘어지다 0.72 에서 가장 넓고 창끝에서 뾰족
float h = x < 0.72 ? mix(0.03, 0.5, pow(x / 0.72, 1.8)) : 0.5 * (1.0 - (x - 0.72) / 0.28);
// 옆 미늘 두 쌍(뒤로 젖힌 삼각형)
for (int i = 0; i < 2; i++) {
	float bx = 0.42 - float(i) * 0.16;
	float t = (x - bx) / 0.12;
	float barb = (t > 0.0 && t < 1.0) ? (0.26 - float(i) * 0.06) * t : 0.0;
	h = max(h, barb);
}
float q = abs(y) / max(h, 0.001);
float aa = fwidth(q) * 1.2;
float edge = 1.0 - smoothstep(1.0 - aa, 1.0, q);
float band = 1.0 - smoothstep(0.68 - aa, 0.68, q);
float core = 1.0 - smoothstep(0.32 - aa, 0.32, q);
// 가운데 능선(셀 음영의 반사띠)
float ridge = (1.0 - smoothstep(0.05, 0.08, abs(y))) * step(0.2, x) * edge;
// 창날 뒤 꽁무니 불꽃(쏜 직후 크게)
float tail = exp(-abs(y) * 14.0) * smoothstep(0.0, 0.25, x) * (1.0 - step(0.3, x)) * (0.4 + flare);
vec3 col = c_edge.rgb * (edge - band) * 1.0 + c_band.rgb * (band - core) * 1.1 + c_core.rgb * (core + ridge) * 1.15 + c_band.rgb * tail * 0.8;
color = col;
alpha = clamp(edge + tail * 0.6, 0.0, 1.0) * fade;
""")
	return ok and finish("lt_spear", {O_ALBEDO: "stage:Lance head:color", O_ALPHA: "stage:Lance head:alpha"})


# ---------------------------------------------------------------- 5. 프리셋 1 · 나선 꼬리

func _helix() -> bool:
	begin("Lightning / thunder spear / angular helix trail", ADD)
	input("uv")
	fparam("head", 1.0)           # 0→1 창머리 위치(여기까지 그려짐)
	fparam("burn", 0.0)           # 0→1 꼬리부터 각지게 타서 사라짐
	fparam("len", 8.0)            # 세계 길이(m) — 꼬임 간격을 길이와 무관하게 유지
	fparam("seed", 0.0)
	cparam("color_core", Color(1.0, 1.0, 0.94))
	cparam("color_band", Color(1.0, 0.76, 0.22))
	cparam("color_edge", Color(0.62, 0.3, 1.0))
	var ok := stage("Helix strands", -500,
		[[V2, "uv_in", "input:uv"], [S, "head", "param:head"], [S, "burn", "param:burn"], [S, "len", "param:len"], [S, "seed", "param:seed"]],
		[[S, "core"], [S, "band"], [S, "edge"], [S, "spark"]], """
float x = uv_in.x;
float y = (uv_in.y - 0.5) * 2.0;
float behind = (head - x) * len;           // 창머리에서 뒤로 몇 m
float drawn = step(0.0, behind);
// 창머리 근처가 가장 굵고 뒤로 갈수록 가늘다(최소 0.35)
float taper = clamp(1.0 - behind / 5.0, 0.35, 1.0) * smoothstep(0.0, 0.6, x * len);
// 각진 타서 사라짐: 꼬리(시작점)부터, 칸 단위로 끊긴다
float cell = floor(x * len * 3.0);
float n = lt_hash(vec2(cell, seed));
float alive = step(burn * 1.15, x * 0.75 + n * 0.25 + 0.001);
core = 0.0;
band = 0.0;
edge = 0.0;
for (int k = 0; k < 2; k++) {
	// 삼각파 = 꺾인 나선(사인 대신 직선 마디)
	float tri = abs(fract(x * len * 0.32 + float(k) * 0.5 + seed * 0.1) - 0.5) * 4.0 - 1.0;
	float off = tri * 0.7 * taper;
	float d = abs(y - off);
	float w = 0.14 * taper;
	float aa = fwidth(d) * 1.2;
	edge = max(edge, 1.0 - smoothstep(w * 1.7 - aa, w * 1.7, d));
	band = max(band, 1.0 - smoothstep(w - aa, w, d));
	core = max(core, 1.0 - smoothstep(w * 0.4 - aa, w * 0.4, d));
}
// 가운데 심
float d0 = abs(y);
float aa0 = fwidth(d0) * 1.2;
float w0 = 0.06 * taper;
edge = max(edge, 1.0 - smoothstep(w0 * 2.2 - aa0, w0 * 2.2, d0));
band = max(band, 1.0 - smoothstep(w0 * 1.4 - aa0, w0 * 1.4, d0));
core = max(core, 1.0 - smoothstep(w0 - aa0, w0, d0));
float m = drawn * alive;
core *= m;
band *= m;
edge *= m;
// 타는 경계의 불씨(각진 칸)
spark = 0.0;
""")
	ok = ok and stage("Helix color", 0,
		[[S, "core", "stage:Helix strands:core"], [S, "band", "stage:Helix strands:band"], [S, "edge", "stage:Helix strands:edge"],
		[S, "spark", "stage:Helix strands:spark"], [V4, "c_core", "param:color_core"], [V4, "c_band", "param:color_band"],
		[V4, "c_edge", "param:color_edge"]], [[V3, "color"], [S, "alpha"]], """
color = c_edge.rgb * (edge - band) * 0.95 + c_band.rgb * (band - core) * 1.0 + c_core.rgb * core * 1.05;
alpha = clamp(edge + spark, 0.0, 1.0);
""")
	return ok and finish("lt_helix", {O_ALBEDO: "stage:Helix color:color", O_ALPHA: "stage:Helix color:alpha"})


# ---------------------------------------------------------------- 6. 프리셋 1 · 별 파열

func _star() -> bool:
	begin("Lightning / thunder spear / cel star burst + shards", ADD)
	input("uv")
	fparam("burst", 1.0)          # 0→1 별이 펼쳐지고 파편이 날아감
	fparam("fade", 1.0)
	fparam("seed", 0.0)
	cparam("color_core", Color(1.0, 1.0, 0.94))
	cparam("color_band", Color(1.0, 0.76, 0.22))
	cparam("color_edge", Color(0.62, 0.3, 1.0))
	var ok := stage("Star burst", -400,
		[[V2, "uv_in", "input:uv"], [S, "burst", "param:burst"], [S, "fade", "param:fade"], [S, "seed", "param:seed"],
		[V4, "c_core", "param:color_core"], [V4, "c_band", "param:color_band"], [V4, "c_edge", "param:color_edge"]],
		[[V3, "color"], [S, "alpha"]], """
vec2 p = (uv_in - vec2(0.5)) * 2.0;
float rot = seed * 0.7;
p = mat2(vec2(cos(rot), sin(rot)), vec2(-sin(rot), cos(rot))) * p;
float r = length(p);
float a = atan(p.y, p.x);
// 큰 별: 아스트로이드(네 갈래 뾰족) — 펼쳐졌다 줄어듦
float grow = sin(clamp(burst, 0.0, 1.0) * 3.14159) * 0.9 + 0.1;
float s1 = pow(abs(p.x), 0.5) + pow(abs(p.y), 0.5);
float f1 = fwidth(s1) * 1.2;
float big = 1.0 - smoothstep(0.0, f1, s1 - 0.95 * grow);
float bigc = 1.0 - smoothstep(0.0, f1, s1 - 0.55 * grow);
float core = 1.0 - smoothstep(0.0, f1, s1 - 0.28 * grow);
// 45° 작은 별
vec2 p2 = mat2(vec2(0.7071, 0.7071), vec2(-0.7071, 0.7071)) * p;
float s2 = pow(abs(p2.x), 0.5) + pow(abs(p2.y), 0.5);
float f2 = fwidth(s2) * 1.2;
float small = 1.0 - smoothstep(0.0, f2, s2 - 0.6 * grow);
float smallc = 1.0 - smoothstep(0.0, f2, s2 - 0.38 * grow);
// 딱 끊긴 고리(바깥으로 퍼짐)
float rr = 0.25 + 0.6 * burst;
float ring = (1.0 - smoothstep(0.0, fwidth(r) * 1.5, abs(r - rr) - 0.035 * (1.0 - burst))) * (1.0 - burst);
// 날카로운 파편 삼각형 8개(바깥을 향해 뾰족)
float shard = 0.0;
for (int i = 0; i < 8; i++) {
	float fi = float(i);
	float ang = (fi + lt_hash1(fi + seed)) * 0.785398;
	float r0 = 0.2 + 0.65 * burst * (0.7 + 0.3 * lt_hash1(fi * 3.1 + seed));
	float ln = 0.22 * (1.0 - burst * 0.6);
	float da = abs(mod(a - ang + 3.14159, 6.2831853) - 3.14159) * r;
	float t = (r - r0) / ln;
	float wdt = 0.06 * (1.0 - t);
	shard = max(shard, step(0.0, t) * step(t, 1.0) * (1.0 - smoothstep(wdt - 0.01, wdt, da)));
}
float edge = max(max(big, small), max(ring, shard));
float band = max(bigc, smallc);
color = c_edge.rgb * max(edge - band, 0.0) * 1.0 + c_band.rgb * max(band - core, 0.0) * 1.1 + c_core.rgb * core * 1.2 + c_band.rgb * shard * 0.3;
alpha = clamp(edge, 0.0, 1.0) * fade;
""")
	return ok and finish("lt_star", {O_ALBEDO: "stage:Star burst:color", O_ALPHA: "stage:Star burst:alpha"})


# ---------------------------------------------------------------- 7. 프리셋 2 · 땅의 균열

func _rift() -> bool:
	begin("Lightning / black thunder / torn ground rift", {"modes/blend": 0, "modes/cull": 2, "modes/depth_draw": 2, "flags/unshaded": true,
		"flags/shadows_disabled": true, "flags/fog_disabled": true, "flags/depth_test_disabled": true})
	input("uv")
	input("time")
	fparam("reach", 1.0)          # 0→1 찢기는 앞머리
	fparam("open", 1.0)           # 0→1 틈이 벌어진 정도
	fparam("fade", 1.0)
	fparam("len", 8.0)
	fparam("seed", 0.0)
	cparam("color_void", Color(0.05, 0.0, 0.1))
	cparam("color_rim", Color(1.0, 0.35, 0.95))
	cparam("color_hot", Color(1.0, 0.9, 1.0))
	var ok := stage("Rift shape", -500,
		[[V2, "uv_in", "input:uv"], [S, "clock", "input:time"], [S, "reach", "param:reach"], [S, "open", "param:open"],
		[S, "len", "param:len"], [S, "seed", "param:seed"]],
		[[S, "gap"], [S, "rim"], [S, "veins"], [S, "halo"], [S, "swirl"]], """
float x = uv_in.x;
float y = (uv_in.y - 0.5) * 2.0;
float drawn = 1.0 - smoothstep(reach - 0.02, reach, x);
float pin = smoothstep(0.0, 0.05, x) * (1.0 - smoothstep(0.93, 1.0, x));
float off = lt_path(x * len * 0.28, seed) * 0.5;
float d = abs(y - off);
// 틈 폭: 마디마다 들쭉날쭉, 앞머리 쪽은 아직 덜 벌어짐
float jag = 0.45 + 0.55 * lt_zig(x * len * 1.3, seed + 3.0);
float front = smoothstep(0.0, 0.12, reach - x);
float w = 0.17 * open * jag * pin * (0.3 + 0.7 * front);
float aa = fwidth(d) * 1.2;
gap = (1.0 - smoothstep(w - aa, w, d)) * drawn;
rim = max((1.0 - smoothstep(w * 1.45 + 0.012 - aa, w * 1.45 + 0.012, d)) * drawn * pin * step(0.002, open) - gap, 0.0);
// 틈에서 갈라져 나간 잔금
float c = lt_cell(vec2(x * len * 1.4 + seed, y * 4.0));
veins = (1.0 - smoothstep(0.0, 0.06, c)) * (1.0 - smoothstep(w + 0.05, w + 0.45, d)) * drawn * pin * open;
halo = exp(-max(d - w, 0.0) * 6.0) * drawn * pin * open;
// 틈 안쪽에서 흐르는 가는 자홍 전기 줄(노이즈 등고선)
float sn = lt_noise(vec2(x * len * 0.9 - clock * 4.0, (y - off) * 3.0) + seed) * 0.65 + lt_noise(vec2(x * len * 2.3 + clock * 2.0, (y - off) * 7.0) - seed) * 0.35;
swirl = (1.0 - smoothstep(0.0, 0.045, abs(sn - 0.5))) * gap;
""")
	ok = ok and stage("Rift color", 0,
		[[S, "gap", "stage:Rift shape:gap"], [S, "rim", "stage:Rift shape:rim"], [S, "veins", "stage:Rift shape:veins"],
		[S, "halo", "stage:Rift shape:halo"], [S, "swirl", "stage:Rift shape:swirl"], [S, "fade", "param:fade"],
		[V4, "c_void", "param:color_void"], [V4, "c_rim", "param:color_rim"], [V4, "c_hot", "param:color_hot"]],
		[[V3, "color"], [S, "alpha"]], """
vec3 col = c_rim.rgb * 0.5 * halo;
col = mix(col, c_rim.rgb * 2.2, veins);
col = mix(col, c_hot.rgb * 2.6, rim);
col = mix(col, mix(c_void.rgb, c_rim.rgb * 1.8, swirl), gap);
color = col;
alpha = clamp(max(max(gap, rim), max(veins * 0.9, halo * 0.45)), 0.0, 1.0) * fade;
""")
	return ok and finish("lt_rift", {O_ALBEDO: "stage:Rift color:color", O_ALPHA: "stage:Rift color:alpha"})


# ---------------------------------------------------------------- 8. 프리셋 2 · 하늘에서 꽂히는 기둥

func _pillar() -> bool:
	begin("Lightning / black thunder / dark sky bolt", MIX)
	input("uv")
	fparam("drop", 1.0)           # 0→1 위에서 아래로 내리꽂힌 정도
	fparam("fade", 1.0)
	fparam("flash", 0.0)          # 바닥에 닿는 순간 섬광
	fparam("seed", 0.0)
	cparam("color_void", Color(0.06, 0.0, 0.14))
	cparam("color_rim", Color(1.0, 0.35, 0.95))
	cparam("color_glow", Color(0.45, 0.35, 1.0))
	var ok := stage("Sky bolt", -500,
		[[V2, "uv_in", "input:uv"], [S, "drop", "param:drop"], [S, "seed", "param:seed"], [S, "flash", "param:flash"]],
		[[S, "inner"], [S, "rim"], [S, "glow"], [S, "burst"]], """
// uv.y = 위(0) → 땅(1), uv.x = 가로
float y = uv_in.y;
float x = (uv_in.x - 0.5) * 2.0;
float drawn = 1.0 - smoothstep(drop - 0.01, drop, y);
float off = lt_path(y * 1.6, seed) * 0.55 * (0.4 + 0.6 * y);
float d = abs(x - off);
float w = (0.1 + 0.13 * lt_zig(y * 7.0 + seed, seed + 2.0)) * smoothstep(0.0, 0.2, y);
// 땅 가까이에서 갈라지는 갈래
float fk = smoothstep(0.72, 0.85, y);
float off2 = off + (y - 0.78) * 1.6 * fk + lt_path(y * 4.0, seed + 9.0) * 0.12;
float off3 = off - (y - 0.78) * 1.3 * fk + lt_path(y * 4.0, seed + 4.0) * 0.12;
float df = min(abs(x - off2), abs(x - off3));
float wf = 0.05 * fk;
float aa = fwidth(d) * 1.2;
inner = (1.0 - smoothstep(w * 0.66 - aa, w * 0.66, d)) * drawn;
rim = max((1.0 - smoothstep(w - aa, w, d)) * drawn - inner, 0.0);
rim = max(rim, (1.0 - smoothstep(wf - 0.01, wf, df)) * drawn * fk);
glow = exp(-max(d - w, 0.0) * 7.0) * drawn;
burst = exp(-(1.0 - y) * 14.0) * exp(-abs(x - off) * 3.5) * flash;
""")
	ok = ok and stage("Sky bolt color", 0,
		[[S, "inner", "stage:Sky bolt:inner"], [S, "rim", "stage:Sky bolt:rim"], [S, "glow", "stage:Sky bolt:glow"],
		[S, "burst", "stage:Sky bolt:burst"], [S, "fade", "param:fade"], [V4, "c_void", "param:color_void"],
		[V4, "c_rim", "param:color_rim"], [V4, "c_glow", "param:color_glow"]], [[V3, "color"], [S, "alpha"]], """
vec3 col = c_glow.rgb * 0.9 * glow;
col = mix(col, c_rim.rgb * 1.8 + vec3(0.25), rim);
col = mix(col, c_void.rgb, inner);
col += vec3(1.0, 0.85, 1.0) * burst * 2.5;
color = col;
alpha = clamp(max(max(inner, rim), glow * 0.5) + burst, 0.0, 1.0) * fade;
""")
	return ok and finish("lt_pillar", {O_ALBEDO: "stage:Sky bolt color:color", O_ALPHA: "stage:Sky bolt color:alpha"})
