extends SceneTree
## 보름달 늑대인간 스킬 VFX 용 VisualShader 그래프 5종을 다시 만든다(편집기에서 노드 그래프로 열어 조정 가능).
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/build_werewolf_shaders.gd
## 결과: shaders/vfx/werewolf/*.tres — 연출은 scripts/visual/vfx/werewolf_vfx.gd
##   ww_claw_rake     Q 할퀴기: 세 줄 발톱 자국이 휘둘러지며 그어지고 뜯긴 가장자리부터 타 사라진다 — 가산
##   ww_bite_snap     물기: 위아래 송곳니 턱이 닫히며 맞물리는 순간 섬광 — 가산
##   ww_ground_slam   E 덮치기 착지: 지면 충격 고리 + 방사 균열 + 네 줄 발톱 패임 — 알파(눈 위 그을림)
##   ww_moon_sigil    변신: 보름달 원반·늑대 울음 고리·빛살이 바닥에 그려짐 — 가산
##   ww_rage_wisp     변신·덮치기 몸 둘레로 솟는 보랏빛 광기 불꽃(원통) — 가산

const F := VisualShader.TYPE_FRAGMENT
const OUT_DIR := "res://shaders/vfx/werewolf/"
const S := VisualShaderNode.PORT_TYPE_SCALAR
const V2 := VisualShaderNode.PORT_TYPE_VECTOR_2D
const V3 := VisualShaderNode.PORT_TYPE_VECTOR_3D
const V4 := VisualShaderNode.PORT_TYPE_VECTOR_4D
const O_ALBEDO := 0
const O_ALPHA := 1

## 그래프 공용 함수(전역 표현식 노드 한 개로 들어간다).
const GLOBALS := """
float ww_hash(vec2 p) {
	p = fract(p * vec2(127.13, 311.71));
	p += dot(p, p + 41.7);
	return fract(p.x * p.y);
}
float ww_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(ww_hash(i), ww_hash(i + vec2(1.0, 0.0)), f.x),
		mix(ww_hash(i + vec2(0.0, 1.0)), ww_hash(i + vec2(1.0, 1.0)), f.x), f.y);
}
float ww_fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	for (int k = 0; k < 4; k++) {
		v += a * ww_noise(p);
		p = p * 2.07 + vec2(3.1, 7.7);
		a *= 0.5;
	}
	return v;
}
// 가장자리까지 거리(F2-F1) — 균열 선
float ww_crack(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	float d1 = 8.0;
	float d2 = 8.0;
	for (int y = -1; y <= 1; y++) {
		for (int x = -1; x <= 1; x++) {
			vec2 g = vec2(float(x), float(y));
			vec2 o = vec2(ww_hash(i + g), ww_hash(i + g + 17.3));
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
	ok = _claw_rake() and ok
	ok = _bite_snap() and ok
	ok = _ground_slam() and ok
	ok = _moon_sigil() and ok
	ok = _rage_wisp() and ok
	quit(0 if ok else 1)


# ---------------------------------------------------------------- 그래프 도우미(build_frost_rune_shaders.gd 와 같은 방식)

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
	g.resource_name = "Werewolf noise / cracks"
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
	print("WEREWOLF_VS %s saved=%d nodes=%d" % [file, err, shader.get_node_list(F).size()])
	return err == OK


const ADD := {"modes/blend": 1, "modes/cull": 2, "modes/depth_draw": 2, "flags/unshaded": true,
	"flags/shadows_disabled": true, "flags/fog_disabled": true}


# ---------------------------------------------------------------- 1. 할퀴기 발톱 자국

func _claw_rake() -> bool:
	begin("Werewolf / claw rake / three torn streaks", ADD)
	input("uv")
	input("time")
	fparam("progress", 1.0)       # 0→1 발톱이 그어지는 진행(왼쪽 → 오른쪽)
	fparam("burn", 0.0)           # 0→1 뜯긴 가장자리부터 타서 사라짐
	fparam("intensity", 1.0)
	fparam("seed", 0.0)
	cparam("color_core", Color(1.0, 0.93, 1.0))
	cparam("color_glow", Color(0.86, 0.32, 1.0))
	cparam("color_edge", Color(1.0, 0.36, 0.62))
	var ok := stage("Three claw streaks", -500,
		[[V2, "uv_in", "input:uv"], [S, "prog", "param:progress"], [S, "burn", "param:burn"], [S, "seed", "param:seed"],
		[S, "clock", "input:time"]],
		[[S, "core"], [S, "glow"], [S, "edge"], [S, "ember"]], """
// uv.x = 휘두르는 방향(0 시작 → 1 끝), uv.y = 줄 간격 방향. 세 줄은 조금씩 늦게 출발하고 살짝 휜다.
core = 0.0;
glow = 0.0;
edge = 0.0;
ember = 0.0;
for (int i = 0; i < 3; i++) {
	float fi = float(i);
	float lag = fi * 0.09;
	float head = clamp(prog * 1.35 - lag, 0.0, 1.0);
	float u = uv_in.x;
	// 휘는 궤적: 가운데가 바깥으로 불룩
	float cy = 0.28 + fi * 0.22 + 0.1 * sin(u * 3.14159) - 0.05;
	float taper = sin(clamp(u, 0.0, 1.0) * 3.14159);
	// 앞머리(새로 그어진 부분)가 가장 두껍고 지나간 자리는 가늘어진다
	float age = clamp((head - u) / 0.6, 0.0, 1.0);
	float w = 0.055 * pow(taper, 0.6) * (1.0 - 0.55 * age);
	// 뜯긴 가장자리
	float torn = (ww_fbm(vec2(u * 9.0 + seed * 5.0 + fi * 3.3, fi * 2.0)) - 0.5) * 0.035;
	float d = abs(uv_in.y - cy - torn);
	float drawn = step(u, head) * smoothstep(0.0, 0.04, u) * (1.0 - smoothstep(0.96, 1.0, u));
	// 타서 사라짐: 노이즈 문턱 + 앞머리에서 먼 곳(오래된 곳)부터
	float erode = ww_fbm(vec2(u * 14.0, uv_in.y * 22.0) + seed * 9.0) * 0.7 + (1.0 - age) * 0.3;
	float alive = smoothstep(burn - 0.02, burn + 0.05, erode);
	float c = (1.0 - smoothstep(w * 0.35, w * 0.6, d)) * drawn * alive;
	float g = exp(-max(d - w * 0.3, 0.0) * 34.0) * drawn * alive;
	// 타들어 가는 경계의 불씨
	float e = (1.0 - smoothstep(w * 0.6, w * 1.05, d)) * drawn * smoothstep(burn - 0.12, burn, erode) * (1.0 - alive);
	core = max(core, c);
	glow = max(glow, g);
	edge = max(edge, (1.0 - smoothstep(w * 0.55, w * 1.0, d)) * drawn * alive - c);
	ember = max(ember, e * step(0.001, burn));
}
""")
	ok = ok and stage("Claw rake color", 0,
		[[S, "core", "stage:Three claw streaks:core"], [S, "glow", "stage:Three claw streaks:glow"],
		[S, "edge", "stage:Three claw streaks:edge"], [S, "ember", "stage:Three claw streaks:ember"],
		[S, "intensity", "param:intensity"], [V4, "c_core", "param:color_core"], [V4, "c_glow", "param:color_glow"],
		[V4, "c_edge", "param:color_edge"]], [[V3, "color"], [S, "alpha"]], """
vec3 col = c_glow.rgb * glow * 0.9 + c_edge.rgb * max(edge, 0.0) * 1.2 + c_core.rgb * core * 1.6;
col += vec3(1.0, 0.55, 0.85) * ember * 1.5;
color = col * intensity;
alpha = clamp(core + glow * 0.7 + max(edge, 0.0) + ember, 0.0, 1.0);
""")
	return ok and finish("ww_claw_rake", {O_ALBEDO: "stage:Claw rake color:color", O_ALPHA: "stage:Claw rake color:alpha"})


# ---------------------------------------------------------------- 2. 물기 턱

func _bite_snap() -> bool:
	begin("Werewolf / bite snap / fang jaws", ADD)
	input("uv")
	fparam("close", 1.0)          # 0 벌림 → 1 맞물림
	fparam("flash", 0.0)          # 맞물리는 순간 섬광
	fparam("fade", 1.0)
	cparam("color_fang", Color(1.0, 0.95, 1.0))
	cparam("color_glow", Color(0.9, 0.3, 0.8))
	var ok := stage("Fang jaws", -400,
		[[V2, "uv_in", "input:uv"], [S, "close", "param:close"], [S, "flash", "param:flash"], [S, "fade", "param:fade"],
		[V4, "c_fang", "param:color_fang"], [V4, "c_glow", "param:color_glow"]], [[V3, "color"], [S, "alpha"]], """
vec2 p = (uv_in - vec2(0.5)) * 2.0;
p.y = -p.y;
float open = (1.0 - close) * 0.62;
// 턱 윤곽: 위아래 초승달(입 모양으로 휜 띠)
float curve = 0.32 * p.x * p.x;
float jaw_u = p.y - (open + 0.04 - curve);    // 위턱 아래 가장자리 기준
float jaw_l = -(p.y + (open + 0.04 - curve)); // 아래턱 위 가장자리 기준
float span = 1.0 - smoothstep(0.78, 0.92, abs(p.x));
// 송곳니 줄: 톱니(가운데 두 개가 길다)
float n = 7.0;
float cell = fract(p.x * n * 0.5 + 0.5) - 0.5;
float big = 1.0 + 1.1 * (1.0 - smoothstep(0.18, 0.42, abs(p.x)));
float tooth_h = 0.17 * big * (1.0 - abs(cell) * 2.0);
float upper = smoothstep(-0.015, 0.015, jaw_u + tooth_h) * (1.0 - smoothstep(0.1, 0.16, jaw_u));
float lower = smoothstep(-0.015, 0.015, jaw_l + tooth_h * 0.8) * (1.0 - smoothstep(0.1, 0.16, jaw_l));
float fang = max(upper, lower) * span;
float g = exp(-min(abs(jaw_u), abs(jaw_l)) * 9.0) * span;
float flash_ring = exp(-abs(length(p) - 0.35 - flash * 0.4) * 18.0) * flash;
color = c_fang.rgb * fang * 1.4 + c_glow.rgb * g * 0.8 + vec3(1.0, 0.8, 1.0) * flash_ring * 1.6;
alpha = clamp(fang + g * 0.5 + flash_ring, 0.0, 1.0) * fade * (1.0 - smoothstep(0.9, 1.0, length(p)));
""")
	return ok and finish("ww_bite_snap", {O_ALBEDO: "stage:Fang jaws:color", O_ALPHA: "stage:Fang jaws:alpha"})


# ---------------------------------------------------------------- 3. 덮치기 착지 지면 충격

func _ground_slam() -> bool:
	begin("Werewolf / pounce landing / cracked ground + claw gouges", {"modes/blend": 0, "modes/cull": 2,
		"modes/depth_draw": 2, "flags/unshaded": true, "flags/shadows_disabled": true})
	input("uv")
	input("time")
	fparam("wave", 1.0)           # 0→1 충격 고리 반지름
	fparam("crack", 1.0)          # 0→1 균열이 바깥으로 뻗음
	fparam("cool", 0.0)           # 0 달아오름 → 1 식어 어두운 자국
	fparam("fade", 1.0)
	fparam("seed", 0.0)
	cparam("color_hot", Color(0.95, 0.45, 1.0))
	cparam("color_scorch", Color(0.16, 0.12, 0.22))
	cparam("color_snow", Color(0.9, 0.92, 1.0))
	var ok := stage("Slam coverage", -500,
		[[V2, "uv_in", "input:uv"], [S, "wave", "param:wave"], [S, "crack", "param:crack"], [S, "seed", "param:seed"]],
		[[S, "ring"], [S, "cracks"], [S, "gouge"], [S, "dent"], [S, "spray"]], """
vec2 p = (uv_in - vec2(0.5)) * 2.0;
float r = length(p);
float a = atan(p.y, p.x);
// 충격 고리
float edge = wave * (1.0 + 0.06 * (ww_noise(vec2(a * 5.0, seed)) - 0.5));
ring = (1.0 - smoothstep(0.0, 0.05, abs(r - edge))) * (1.0 - wave * 0.6);
// 방사 균열: 각도 방향으로 늘린 세포 경계 + 중심에서 crack 반지름까지
vec2 polar = vec2(a * 2.6 + seed, r * 7.0);
float cl = 1.0 - smoothstep(0.0, 0.06, ww_crack(polar));
// 굵은 방사 균열 7갈래(각도 칸의 경계 근처만, 바깥으로 갈수록 가늘게)
float lane = abs(fract(a * 7.0 / 6.2831853 + (ww_noise(vec2(r * 5.0, seed)) - 0.5) * 0.12) - 0.5);
float radial = smoothstep(0.47 - 0.025 * (1.0 - r), 0.495, lane);
cracks = max(cl * 0.55 * smoothstep(0.55, 0.2, r), radial) * (1.0 - smoothstep(crack * 0.95 - 0.08, crack * 0.95, r)) * smoothstep(0.08, 0.16, r);
// 네 줄 발톱 패임(덮친 방향 = +y)
gouge = 0.0;
for (int i = 0; i < 4; i++) {
	float x0 = -0.27 + float(i) * 0.18;
	float along = p.y + 0.15;
	float bend = 0.06 * along * along;
	float d = abs(p.x - x0 - bend);
	float len_ok = smoothstep(-0.55, -0.4, along) * (1.0 - smoothstep(0.55, 0.75, along));
	gouge = max(gouge, (1.0 - smoothstep(0.012, 0.03, d)) * len_ok * smoothstep(0.0, 0.3, crack));
}
// 가운데 움푹 꺼진 자국과 흩뿌린 눈
dent = (1.0 - smoothstep(0.12, 0.3, r)) * smoothstep(0.0, 0.25, crack);
// 고리 안쪽에 흩뿌린 눈(둥근 점)
vec2 sc = p * 13.0 + seed;
vec2 sid = floor(sc);
float sh = ww_hash(sid);
float sd = length(fract(sc) - 0.5 - (vec2(ww_hash(sid + 3.0), ww_hash(sid + 7.0)) - 0.5) * 0.5);
spray = step(0.8, sh) * (1.0 - smoothstep(0.08, 0.14, sd)) * smoothstep(0.3, 0.45, r) * (1.0 - smoothstep(edge - 0.1, edge, r));
""")
	ok = ok and stage("Slam color", 0,
		[[S, "ring", "stage:Slam coverage:ring"], [S, "cracks", "stage:Slam coverage:cracks"],
		[S, "gouge", "stage:Slam coverage:gouge"], [S, "dent", "stage:Slam coverage:dent"],
		[S, "spray", "stage:Slam coverage:spray"], [S, "cool", "param:cool"], [S, "fade", "param:fade"],
		[V4, "c_hot", "param:color_hot"], [V4, "c_scorch", "param:color_scorch"], [V4, "c_snow", "param:color_snow"]],
		[[V3, "color"], [S, "alpha"]], """
float mark = max(cracks, gouge);
vec3 hot = mix(c_hot.rgb * 1.6, vec3(1.0, 0.9, 1.0), mark * 0.3);
vec3 lines = mix(hot, c_scorch.rgb, cool);
vec3 col = mix(c_scorch.rgb * 1.6, lines, mark);
col = mix(col, c_snow.rgb, spray);
col = mix(col, vec3(1.0, 0.85, 1.0), ring * (1.0 - cool));
color = col;
alpha = clamp(mark * 0.95 + dent * 0.45 + ring * 0.8 * (1.0 - cool) + spray * 0.8, 0.0, 1.0) * fade;
""")
	return ok and finish("ww_ground_slam", {O_ALBEDO: "stage:Slam color:color", O_ALPHA: "stage:Slam color:alpha"})


# ---------------------------------------------------------------- 4. 변신 보름달 문양

func _moon_sigil() -> bool:
	begin("Werewolf / transform / full moon sigil", ADD)
	input("uv")
	input("time")
	fparam("reveal", 1.0)
	fparam("intensity", 1.0)
	fparam("fade", 1.0)
	cparam("color_moon", Color(0.95, 0.9, 1.0))
	cparam("color_glow", Color(0.62, 0.36, 1.0))
	var ok := stage("Moon sigil", -400,
		[[V2, "uv_in", "input:uv"], [S, "clock", "input:time"], [S, "reveal", "param:reveal"], [S, "intensity", "param:intensity"],
		[S, "fade", "param:fade"], [V4, "c_moon", "param:color_moon"], [V4, "c_glow", "param:color_glow"]],
		[[V3, "color"], [S, "alpha"]], """
vec2 p = (uv_in - vec2(0.5)) * 2.0;
float r = length(p);
float a = atan(p.y, p.x);
float grow = 1.0 - smoothstep(reveal - 0.1, reveal, r);
// 보름달 원반(살짝 얼룩진 바다 무늬)
float disc = (1.0 - smoothstep(0.24, 0.26, r)) * (0.75 + 0.25 * ww_fbm(p * 7.0));
// 울음 고리 두 겹
float rings = (1.0 - smoothstep(0.0, 0.012, abs(r - 0.42))) + (1.0 - smoothstep(0.0, 0.008, abs(r - 0.9)));
// 늑대 송곳니처럼 뾰족한 빛살 12개
float a12 = mod(a + clock * 0.4, 0.5235988) - 0.2617994;
float ray = (1.0 - smoothstep(0.0, 0.02 + 0.05 * (1.0 - (r - 0.45) / 0.45), abs(a12) * r)) * smoothstep(0.44, 0.5, r) * (1.0 - smoothstep(0.84, 0.88, r));
float glow = exp(-abs(r - 0.42) * 10.0) * 0.6 + exp(-r * 3.0) * 0.5;
float m = max(max(disc, rings), ray) * grow;
color = (c_moon.rgb * m * 1.4 + c_glow.rgb * glow * grow) * intensity;
alpha = clamp(m + glow * 0.6 * grow, 0.0, 1.0) * fade;
""")
	return ok and finish("ww_moon_sigil", {O_ALBEDO: "stage:Moon sigil:color", O_ALPHA: "stage:Moon sigil:alpha"})


# ---------------------------------------------------------------- 5. 광기 불꽃(원통)

func _rage_wisp() -> bool:
	begin("Werewolf / rage wisps / rising violet flames", ADD)
	input("uv")
	input("time")
	input("normal")
	input("view")
	fparam("rise", 1.0)
	fparam("fade", 1.0)
	fparam("seed", 0.0)
	cparam("color", Color(0.7, 0.35, 1.0))
	var ok := stage("Rising rage flames", -400,
		[[V2, "uv_in", "input:uv"], [S, "clock", "input:time"], [V3, "n", "input:normal"], [V3, "v", "input:view"],
		[S, "rise", "param:rise"], [S, "fade", "param:fade"], [S, "seed", "param:seed"], [V4, "c", "param:color"]],
		[[V3, "color"], [S, "alpha"]], """
// uv.x = 둘레, uv.y = 높이(0 바닥 → 1 꼭대기)
float h = uv_in.y;
float n1 = ww_fbm(vec2(uv_in.x * 8.0 + seed, h * 2.0 - clock * 3.2));
float n2 = ww_noise(vec2(uv_in.x * 19.0 + seed * 3.0, h * 4.0 - clock * 5.0));
float tongue = smoothstep(0.42, 0.75, n1 + (1.0 - h) * 0.45 - h * 0.25);
float lick = smoothstep(0.6, 0.9, n2) * (1.0 - h);
float top = 1.0 - smoothstep(rise - 0.3, rise, h);
float side = 1.0 - abs(dot(normalize(n), normalize(v)));
alpha = clamp((tongue * 0.8 + lick * 0.5) * (0.35 + 0.65 * side) * top * fade, 0.0, 1.0);
color = mix(c.rgb, vec3(1.0, 0.85, 1.0), lick * 0.7 + (1.0 - h) * 0.15) * 1.4;
""")
	return ok and finish("ww_rage_wisp", {O_ALBEDO: "stage:Rising rage flames:color", O_ALPHA: "stage:Rising rage flames:alpha"})
