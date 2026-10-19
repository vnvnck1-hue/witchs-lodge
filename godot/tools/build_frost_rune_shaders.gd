extends SceneTree
## 서리 룬 VFX 용 VisualShader 그래프 5종을 다시 만든다(편집기에서 노드 그래프로 열어 조정 가능).
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/build_frost_rune_shaders.gd
## 결과: shaders/vfx/frost_rune/*.tres
##   frost_sigil   지면 룬 문양(바깥 고리·회전하는 룬 띠·여섯 갈래 서리 결정) — 가산, 그려지듯 나타남
##   frost_rime    지면 서리 번짐(결정 세포·반짝임) — 퍼졌다가 바깥부터 녹는다. 감속 표식도 같은 셰이더
##   frost_shock   톱니 결정 앞머리를 가진 충격 고리 — 가산
##   frost_pillar  짧게 솟는 냉기 빛기둥 — 가산, 위로 흐르는 줄무늬
##   frost_crystal 솟아오르는 얼음 결정 — 3단 툰 명암·프레넬 테두리·안쪽 굴절 줄무늬·녹아내리는 디졸브

const F := VisualShader.TYPE_FRAGMENT
const OUT_DIR := "res://shaders/vfx/frost_rune/"
const S := VisualShaderNode.PORT_TYPE_SCALAR
const V2 := VisualShaderNode.PORT_TYPE_VECTOR_2D
const V3 := VisualShaderNode.PORT_TYPE_VECTOR_3D
const V4 := VisualShaderNode.PORT_TYPE_VECTOR_4D
# 공간 셰이더 프래그먼트 출력 포트
const O_ALBEDO := 0
const O_ALPHA := 1
const O_SCISSOR := 19

## 그래프 공용 함수(전역 표현식 노드 한 개로 들어간다).
const GLOBALS := """
float fr_hash(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}
float fr_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(fr_hash(i), fr_hash(i + vec2(1.0, 0.0)), f.x),
		mix(fr_hash(i + vec2(0.0, 1.0)), fr_hash(i + vec2(1.0, 1.0)), f.x), f.y);
}
float fr_fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	for (int k = 0; k < 4; k++) {
		v += a * fr_noise(p);
		p = p * 2.03 + vec2(1.7, 9.2);
		a *= 0.5;
	}
	return v;
}
// 결정 세포: x = 가장 가까운 점까지 거리, y = 경계까지 거리(F2-F1), z = 세포 고유값
vec3 fr_cells(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	float d1 = 8.0;
	float d2 = 8.0;
	float id = 0.0;
	for (int y = -1; y <= 1; y++) {
		for (int x = -1; x <= 1; x++) {
			vec2 g = vec2(float(x), float(y));
			vec2 o = vec2(fr_hash(i + g), fr_hash(i + g + 19.7));
			float d = length(g + o - f);
			if (d < d1) {
				d2 = d1;
				d1 = d;
				id = fr_hash(i + g + 3.1);
			} else if (d < d2) {
				d2 = d;
			}
		}
	}
	return vec3(d1, d2 - d1, id);
}
float fr_seg(vec2 p, vec2 a, vec2 b) {
	vec2 pa = p - a;
	vec2 ba = b - a;
	float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
	return length(pa - ba * h);
}
"""

var shader: VisualShader
var next_id := 2
var srcs := {}        # "input:uv" / "param:x" / "stage:<title>:<port>" -> [node_id, port]
var stage_y := 0.0


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	var ok := true
	ok = _sigil() and ok
	ok = _rime() and ok
	ok = _shock() and ok
	ok = _pillar() and ok
	ok = _crystal() and ok
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
	stage_y = -200.0
	var g := VisualShaderNodeGlobalExpression.new()
	g.resource_name = "Frost noise / cells / segment"
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
	var e := shader.connect_nodes(F, s[0], s[1], to_id, to_port)
	if e != OK:
		push_error("connect failed %s -> %d:%d" % [src, to_id, to_port])
		return false
	return true


func finish(file: String, outputs: Dictionary) -> bool:
	for port in outputs:
		if not _link(outputs[port], 0, port):
			return false
	shader.set_node_position(F, 0, Vector2(900, 0))
	var code := shader.get_code()
	var rm := ""
	for line in code.split("\n"):
		if line.begins_with("render_mode"):
			rm = line
	var path := OUT_DIR + file + ".tres"
	var err := ResourceSaver.save(shader, path)
	print("FROST_VS %s saved=%d nodes=%d %s" % [file, err, shader.get_node_list(F).size(), rm])
	return err == OK


const ADD := {"modes/blend": 1, "modes/cull": 2, "modes/depth_draw": 2, "flags/unshaded": true,
	"flags/shadows_disabled": true, "flags/fog_disabled": true}


# ---------------------------------------------------------------- 1. 룬 문양

func _sigil() -> bool:
	begin("Frost rune / ground sigil / draw-on + spin", ADD)
	input("uv")
	input("time")
	fparam("extent", 1.12)       # 평면 반지름 / 룬 반지름
	fparam("reveal", 1.0)        # 0→1 그려지며 나타남
	fparam("intensity", 1.0)     # 폭발 순간 섬광
	fparam("fade", 1.0)          # 전체 투명도
	fparam("seed", 0.0)
	cparam("color_core", Color(0.86, 0.97, 1.0))
	cparam("color_glow", Color(0.36, 0.7, 1.0))
	cparam("color_rune", Color(0.74, 0.62, 1.0))
	var ok := stage("Polar rune space", -800, [[V2, "uv_in", "input:uv"], [S, "ext", "param:extent"]],
		[[V2, "p"], [S, "r"], [S, "a"]], """
p = (uv_in - vec2(0.5)) * 2.0 * ext;
r = length(p);
a = atan(p.y, p.x);
""")
	ok = ok and stage("Rune sigil lines", -380,
		[[V2, "p", "stage:Polar rune space:p"], [S, "r", "stage:Polar rune space:r"], [S, "a", "stage:Polar rune space:a"],
		[S, "clock", "input:time"], [S, "reveal", "param:reveal"], [S, "seed", "param:seed"]],
		[[S, "core"], [S, "rune"], [S, "glow"], [S, "fill"], [S, "shimmer"]], """
float aa = 0.012;
// 그려지는 순서: 고리·룬 띠는 위에서부터 시계 방향으로, 결정 갈래는 중심에서 바깥으로.
float ang01 = fract(-a / 6.2831853 + 0.25);
float sweep = 1.0 - smoothstep(reveal * 1.12 - 0.12, reveal * 1.12 - 0.04, ang01);
float grow = 1.0 - smoothstep(reveal * 1.1 - 0.1, reveal * 1.1, r);
// 고리
float d_ring = abs(r - 0.975) - 0.02;
d_ring = min(d_ring, abs(r - 0.80) - 0.006);
d_ring = min(d_ring, abs(r - 0.56) - 0.005);
// 안쪽 육각형(30도 돌린 별 형태와 겹친다)
vec2 hp = abs(p);
float hex = max(hp.x * 0.866 + hp.y * 0.5, hp.y);
float d_hex = abs(hex - 0.3) - 0.008;
vec2 hp2 = abs(vec2(p.y, p.x));
float hex2 = max(hp2.x * 0.866 + hp2.y * 0.5, hp2.y);
d_hex = min(d_hex, abs(hex2 - 0.3) - 0.004);
// 여섯 갈래 서리 결정(60도 접기)
float a6 = mod(a + 0.5235988, 1.0471976) - 0.5235988;
vec2 q = r * vec2(cos(a6), abs(sin(a6)));
float d_arm = fr_seg(q, vec2(0.1, 0.0), vec2(0.76, 0.0)) - 0.011;
d_arm = min(d_arm, fr_seg(q, vec2(0.34, 0.0), vec2(0.47, 0.12)) - 0.007);
d_arm = min(d_arm, fr_seg(q, vec2(0.55, 0.0), vec2(0.65, 0.09)) - 0.006);
d_arm = min(d_arm, fr_seg(q, vec2(0.18, 0.0), vec2(0.25, 0.06)) - 0.005);
d_arm = min(d_arm, (abs(q.x - 0.77) + abs(q.y) * 1.7) - 0.045);
// 가운데 작은 별
float a12 = mod(a + 0.2617994, 0.5235988) - 0.2617994;
vec2 c12 = r * vec2(cos(a12), abs(sin(a12)));
float d_star = fr_seg(c12, vec2(0.0), vec2(0.09, 0.0)) - 0.006;
// 회전하는 룬 띠(0.82~0.95): 칸마다 다른 획
float N = 16.0;
float ar = a + clock * 0.35;
float ca = ar / 6.2831853 * N;
float k = floor(ca);
vec2 g = vec2((fract(ca) - 0.5) * r * 6.2831853 / N, r - 0.885) / 0.055;
float h = fr_hash(vec2(k, seed * 17.0 + 3.0));
float dg = fr_seg(g, vec2(0.0, -0.75), vec2(0.0, 0.75));
if (h < 0.33) {
	dg = min(dg, fr_seg(g, vec2(0.0, 0.45), vec2(0.6, 0.0)));
	dg = min(dg, fr_seg(g, vec2(0.6, 0.0), vec2(0.0, -0.45)));
} else if (h < 0.66) {
	dg = min(dg, fr_seg(g, vec2(-0.55, 0.65), vec2(0.55, -0.15)));
} else {
	dg = min(dg, fr_seg(g, vec2(0.0, 0.75), vec2(0.5, 0.3)));
	dg = min(dg, fr_seg(g, vec2(0.0, 0.75), vec2(-0.5, 0.3)));
}
dg = min(dg, length(g - vec2(0.0, -0.98)) - 0.02);
float d_rune = (dg - 0.11) * 0.055;
// 합치기
float d_main = min(min(d_ring, d_hex), d_star);
float c_ring = (1.0 - smoothstep(0.0, aa, d_main)) * sweep;
float c_arm = (1.0 - smoothstep(0.0, aa, d_arm)) * grow;
core = max(c_ring, c_arm);
rune = (1.0 - smoothstep(0.0, aa * 0.8, d_rune)) * sweep;
float d_all = min(min(d_main, d_arm), d_rune);
glow = exp(-max(d_all, 0.0) * 26.0) * max(sweep, grow);
// 문양 안쪽의 얇은 서리 막
fill = (1.0 - smoothstep(0.95, 1.0, r)) * (0.05 + 0.1 * fr_fbm(p * 5.0 + seed)) * grow;
// 고리를 따라 흐르는 반짝임
shimmer = pow(0.5 + 0.5 * sin(a * 3.0 - clock * 4.0), 10.0) * c_ring;
""")
	ok = ok and stage("Frost glow color", 80,
		[[S, "core", "stage:Rune sigil lines:core"], [S, "rune", "stage:Rune sigil lines:rune"],
		[S, "glow", "stage:Rune sigil lines:glow"], [S, "fill", "stage:Rune sigil lines:fill"],
		[S, "shimmer", "stage:Rune sigil lines:shimmer"], [S, "intensity", "param:intensity"], [S, "fade", "param:fade"],
		[V4, "c_core", "param:color_core"], [V4, "c_glow", "param:color_glow"], [V4, "c_rune", "param:color_rune"]],
		[[V3, "color"], [S, "alpha"]], """
vec3 col = c_glow.rgb * glow * 0.75 + c_core.rgb * core + c_rune.rgb * rune * 1.3 + c_glow.rgb * fill;
col += vec3(1.0) * shimmer * 0.8;
col *= intensity;
color = col;
alpha = clamp(max(core, rune) + glow * 0.6 + fill, 0.0, 1.0) * fade;
""")
	return ok and finish("frost_sigil", {O_ALBEDO: "stage:Frost glow color:color", O_ALPHA: "stage:Frost glow color:alpha"})


# ---------------------------------------------------------------- 2. 서리 번짐

func _rime() -> bool:
	begin("Frost rune / ground rime / spread + melt", {"modes/blend": 0, "modes/cull": 2, "modes/depth_draw": 2,
		"flags/unshaded": true, "flags/shadows_disabled": true})
	input("uv")
	input("time")
	fparam("extent", 1.0)
	fparam("spread", 1.0)         # 0→1 서리 앞머리 반지름
	fparam("melt", 0.0)           # 0→1 바깥부터 녹아 사라짐
	fparam("opacity", 0.78)
	fparam("cell_scale", 7.0)     # 반지름 1당 결정 세포 수
	fparam("seed", 0.0)
	cparam("color_frost", Color(0.62, 0.74, 1.0))
	cparam("color_edge", Color(0.95, 0.98, 1.0))
	var ok := stage("Rime coverage", -500,
		[[V2, "uv_in", "input:uv"], [S, "ext", "param:extent"], [S, "spread", "param:spread"], [S, "melt", "param:melt"],
		[S, "cells_n", "param:cell_scale"], [S, "seed", "param:seed"], [S, "clock", "input:time"]],
		[[S, "cover"], [S, "crack"], [S, "facet"], [S, "rim"], [S, "glint"], [S, "wet"]], """
vec2 p = (uv_in - vec2(0.5)) * 2.0 * ext;
float r = length(p);
float a = atan(p.y, p.x);
// 들쭉날쭉한 서리 앞머리
float jag = fr_fbm(vec2(cos(a), sin(a)) * 2.2 + seed * 7.0);
float spike = pow(abs(sin(a * 11.0 + seed * 5.0)), 18.0) * 0.08;
float front = spread * (0.8 + 0.3 * jag + spike);
float wob = (fr_fbm(p * 3.0 + seed * 11.0) - 0.5) * 0.16;
float body = 1.0 - smoothstep(front - 0.04, front, r + wob);
// 결정 세포
vec3 c = fr_cells(p * cells_n + seed * 13.0);
crack = 1.0 - smoothstep(0.0, 0.07, c.y);
facet = c.z;
rim = smoothstep(front - 0.28, front - 0.02, r + wob) * body;
// 바깥과 성긴 부분부터 녹는다
float m = fr_fbm(p * 2.2 + seed * 5.0 + 3.0) * 0.72 + (1.0 - clamp(r / ext, 0.0, 1.0)) * 0.28;
float alive = smoothstep(melt, melt + 0.06, m);
wet = alive * (1.0 - smoothstep(melt + 0.06, melt + 0.13, m)) * step(0.001, melt);
cover = body * alive * (1.0 - smoothstep(ext * 0.94, ext, r));
// 세포 하나씩 깜빡이는 반짝임
vec2 gc = floor(p * cells_n * 3.0 + seed * 3.0);
float gh = fr_hash(gc);
glint = step(0.955, gh) * pow(0.5 + 0.5 * sin(clock * 5.0 + gh * 60.0), 6.0) * cover;
""")
	ok = ok and stage("Rime color", -20,
		[[S, "cover", "stage:Rime coverage:cover"], [S, "crack", "stage:Rime coverage:crack"],
		[S, "facet", "stage:Rime coverage:facet"], [S, "rim", "stage:Rime coverage:rim"],
		[S, "glint", "stage:Rime coverage:glint"], [S, "wet", "stage:Rime coverage:wet"],
		[S, "opacity", "param:opacity"], [V4, "c_frost", "param:color_frost"], [V4, "c_edge", "param:color_edge"]],
		[[V3, "color"], [S, "alpha"]], """
vec3 col = mix(c_frost.rgb * (0.86 + 0.22 * facet), c_edge.rgb, clamp(crack * 0.75 + rim * 0.55, 0.0, 1.0));
col += vec3(1.0) * glint * 1.2;
col = mix(col, vec3(0.5, 0.66, 0.95), wet * 0.6);
color = col;
alpha = clamp(cover * opacity * (0.5 + 0.2 * facet + 0.35 * crack + 0.3 * rim) + glint * 0.6, 0.0, 1.0);
""")
	return ok and finish("frost_rime", {O_ALBEDO: "stage:Rime color:color", O_ALPHA: "stage:Rime color:alpha"})


# ---------------------------------------------------------------- 3. 충격 고리

func _shock() -> bool:
	begin("Frost rune / crystal shock ring", ADD)
	input("uv")
	fparam("wave", 0.5)           # 0→1 고리 반지름
	fparam("energy", 1.0)
	fparam("seed", 0.0)
	cparam("color", Color(0.55, 0.85, 1.0))
	var ok := stage("Toothed shock front", -400,
		[[V2, "uv_in", "input:uv"], [S, "wave", "param:wave"], [S, "energy", "param:energy"], [S, "seed", "param:seed"],
		[V4, "c", "param:color"]], [[V3, "color"], [S, "alpha"]], """
vec2 p = (uv_in - vec2(0.5)) * 2.0;
float r = length(p);
float a = atan(p.y, p.x);
// 톱니 모양 결정 앞머리
float tooth = abs(fract(a * 28.0 / 6.2831853 + seed) - 0.5) * 2.0;
float tooth2 = abs(fract(a * 11.0 / 6.2831853 + seed * 2.0) - 0.5) * 2.0;
float edge = wave * (1.0 + 0.045 * tooth + 0.03 * tooth2);
float thick = mix(0.22, 0.04, wave);
float d = edge - r;
float band = smoothstep(0.0, 0.012, d) * (1.0 - smoothstep(0.0, thick, d));
float lead = 1.0 - smoothstep(0.0, 0.018, abs(d));
float streak = 0.55 + 0.45 * fr_noise(vec2(a * 9.0, r * 7.0 - wave * 9.0));
alpha = clamp(band * streak * 0.85 + lead, 0.0, 1.0) * energy * (1.0 - smoothstep(0.92, 1.0, r));
color = mix(c.rgb, vec3(1.0), lead * 0.75);
""")
	return ok and finish("frost_shock", {O_ALBEDO: "stage:Toothed shock front:color", O_ALPHA: "stage:Toothed shock front:alpha"})


# ---------------------------------------------------------------- 4. 냉기 빛기둥

func _pillar() -> bool:
	begin("Frost rune / cold light pillar", ADD)
	input("uv")
	input("time")
	input("normal")
	input("view")
	fparam("rise", 1.0)           # 0→1 기둥 높이
	fparam("fade", 1.0)
	cparam("color", Color(0.5, 0.78, 1.0))
	var ok := stage("Rising cold streaks", -400,
		[[V2, "uv_in", "input:uv"], [S, "clock", "input:time"], [V3, "n", "input:normal"], [V3, "v", "input:view"],
		[S, "rise", "param:rise"], [S, "fade", "param:fade"], [V4, "c", "param:color"]], [[V3, "color"], [S, "alpha"]], """
// uv.x = 둘레, uv.y = 높이(0 바닥 → 1 꼭대기)
float h = uv_in.y;
float s1 = fr_noise(vec2(uv_in.x * 22.0, h * 2.5 - clock * 4.0));
float s2 = fr_noise(vec2(uv_in.x * 9.0 + 3.0, h * 1.3 - clock * 2.2));
float streak = smoothstep(0.35, 0.85, s1 * 0.6 + s2 * 0.6);
float base = pow(1.0 - h, 1.8);
float top = 1.0 - smoothstep(rise - 0.35, rise, h);
float side = 1.0 - abs(dot(normalize(n), normalize(v)));
alpha = clamp((base * (0.25 + 0.5 * side) + streak * base * 0.9) * top * fade, 0.0, 1.0);
color = mix(c.rgb, vec3(1.0), streak * 0.6 + (1.0 - h) * 0.2);
""")
	return ok and finish("frost_pillar", {O_ALBEDO: "stage:Rising cold streaks:color", O_ALPHA: "stage:Rising cold streaks:alpha"})


# ---------------------------------------------------------------- 5. 얼음 결정

func _crystal() -> bool:
	begin("Frost rune / ice crystal / toon facets + melt", {"modes/blend": 0, "modes/cull": 2, "modes/depth_draw": 0,
		"flags/unshaded": true, "flags/shadows_disabled": true})
	input("uv")
	input("normal")
	input("view")
	fparam("melt", 0.0)           # 0→1 꼭대기부터 녹아 사라짐
	fparam("flash", 0.0)          # 솟는 순간 하얗게
	fparam("seed", 0.0)
	cparam("color_deep", Color(0.14, 0.26, 0.66))
	cparam("color_light", Color(0.55, 0.82, 1.0))
	cparam("color_rim", Color(0.92, 0.98, 1.0))
	var ok := stage("Ice facets", -500,
		[[V2, "uv_in", "input:uv"], [V3, "n", "input:normal"], [V3, "v", "input:view"], [S, "seed", "param:seed"],
		[S, "flash", "param:flash"], [V4, "c_deep", "param:color_deep"], [V4, "c_light", "param:color_light"],
		[V4, "c_rim", "param:color_rim"]], [[V3, "color"]], """
// uv.x = 면 번호 비율, uv.y = 높이(0 바닥 → 1 끝). 법선은 면마다 평평하다.
vec3 nn = normalize(n);
vec3 vv = normalize(v);
float lam = dot(nn, normalize(vec3(-0.45, 0.75, 0.5)));
float tone = smoothstep(-0.08, 0.02, lam) * 0.5 + smoothstep(0.5, 0.58, lam) * 0.5;
float fres = pow(1.0 - clamp(dot(nn, vv), 0.0, 1.0), 2.2);
vec3 col = mix(c_deep.rgb, c_light.rgb, clamp(uv_in.y * 0.45 + tone * 0.45, 0.0, 1.0));
// 안쪽 굴절 줄무늬
float streak = smoothstep(0.6, 0.68, fr_noise(vec2(uv_in.x * 11.0 + seed * 13.0, uv_in.y * 2.2 + seed)));
col += streak * vec3(0.16, 0.2, 0.24);
col = mix(col, c_rim.rgb, fres * 0.55);
col += smoothstep(0.82, 1.0, uv_in.y) * 0.22;
color = mix(col, vec3(1.0), flash);
""")
	ok = ok and stage("Melt dissolve", -500,
		[[V2, "uv_in", "input:uv"], [S, "melt", "param:melt"], [S, "seed", "param:seed"], [V3, "col_in", "stage:Ice facets:color"]],
		[[V3, "color"], [S, "alpha"], [S, "scissor"]], """
float nz = fr_fbm(vec2(uv_in.x * 6.0 + seed * 7.0, uv_in.y * 4.0 + seed));
float k = nz * 0.55 + (1.0 - uv_in.y) * 0.45;   // 끝(위)이 먼저 녹는다
float e = 1.0 - smoothstep(0.0, 0.07, k - melt);
color = mix(col_in, vec3(0.9, 0.97, 1.0) * 1.25, e * step(0.001, melt));
alpha = clamp(k - melt + 0.5, 0.0, 1.0);
scissor = 0.5;
""")
	return ok and finish("frost_crystal", {O_ALBEDO: "stage:Melt dissolve:color", O_ALPHA: "stage:Melt dissolve:alpha",
		O_SCISSOR: "stage:Melt dissolve:scissor"})
