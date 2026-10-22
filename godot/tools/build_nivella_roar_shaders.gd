extends SceneTree
## 니벨라 포효 눈보라 VFX 용 VisualShader 그래프 2종을 다시 만든다(편집기에서 노드 그래프로 열어 조정 가능).
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/build_nivella_roar_shaders.gd
## 결과: shaders/vfx/nivella/*.tres — 연출은 scripts/visual/vfx/nivella_roar_vfx.gd
##   nv_roar_ground_burst  바닥: 보스 발밑에서 휘몰아친 눈 띠가 고리로 밀려 나가고, 뒤로 방사형 눈발 줄기·서리 안개가 남는다 — 알파
##   nv_roar_snow_wall     바닥 고리를 따라 솟는 눈보라 벽(뚜껑 없는 원통): 아래가 짙고 위로 흩날리며 사라진다 — 알파
## 강도는 사용자 요청(2026-10-22, "참고 이미지보다 약하게")에 맞춰 화면을 덮지 않는 선에서 멈춘다(intensity 기본 0.8).

const F := VisualShader.TYPE_FRAGMENT
const OUT_DIR := "res://shaders/vfx/nivella/"
const S := VisualShaderNode.PORT_TYPE_SCALAR
const V2 := VisualShaderNode.PORT_TYPE_VECTOR_2D
const V3 := VisualShaderNode.PORT_TYPE_VECTOR_3D
const O_ALBEDO := 0
const O_ALPHA := 1
const O_EMISSION := 5

## 그래프 공용 함수(전역 표현식 노드 한 개로 들어간다).
const GLOBALS := """
float nv_hash(vec2 p) {
	p = fract(p * vec2(127.13, 311.71));
	p += dot(p, p + 41.7);
	return fract(p.x * p.y);
}
float nv_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(nv_hash(i), nv_hash(i + vec2(1.0, 0.0)), f.x),
		mix(nv_hash(i + vec2(0.0, 1.0)), nv_hash(i + vec2(1.0, 1.0)), f.x), f.y);
}
float nv_fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	for (int k = 0; k < 4; k++) {
		v += a * nv_noise(p);
		p = p * 2.07 + vec2(3.1, 7.7);
		a *= 0.5;
	}
	return v;
}
"""

var shader: VisualShader
var next_id := 2
var srcs := {}
var stage_y := 0.0


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	var ok := true
	ok = _ground_burst() and ok
	ok = _snow_wall() and ok
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
	g.resource_name = "Nivella snow noise"
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
	print("NIVELLA_VS %s saved=%d nodes=%d" % [file, err, shader.get_node_list(F).size()])
	return err == OK


const ALPHA := {"modes/blend": 0, "modes/cull": 2, "modes/depth_draw": 2, "flags/unshaded": true,
	"flags/shadows_disabled": true, "flags/fog_disabled": true}


# ---------------------------------------------------------------- 1. 바닥 눈보라 폭발

func _ground_burst() -> bool:
	begin("Nivella / roar / ground snow burst", ALPHA)
	input("uv")
	input("time")
	fparam("progress", 0.0)      # 0→1 눈 띠가 가운데에서 가장자리로 밀려 나감(감속)
	fparam("fade", 1.0)          # 1→0 전체가 흩어져 사라짐
	fparam("intensity", 0.8)
	fparam("seed", 0.0)
	fparam("band_width", 1.0)    # 띠 두께 배율 — 멀리 퍼지는 연속 눈보라는 얇게 해 고리가 겹을 이뤄 보이게
	fparam("haze", 1.0)          # 고리 안쪽 서리 안개 배율 — 연속으로 겹치면 화면이 하얗게 덮이지 않게 줄인다
	cparam("color_snow", Color(0.93, 0.96, 1.0))
	cparam("color_shade", Color(0.55, 0.66, 0.95))
	cparam("color_glow", Color(0.62, 0.82, 1.0))
	var ok := stage("Polar snow front", -700,
		[[V2, "uv_in", "input:uv"], [S, "prog", "param:progress"], [S, "seed", "param:seed"], [S, "clock", "input:time"]],
		[[S, "r"], [S, "front"], [V2, "dir"], [S, "churn"]], """
// 평면 UV 를 보스 중심 극좌표로. 무늬는 바깥으로 밀려 나가도록 반경 방향으로 끌어 늘린다.
vec2 p = uv_in * 2.0 - 1.0;
r = length(p);
dir = p / max(r, 0.0001);
front = mix(0.06, 0.93, 1.0 - pow(1.0 - clamp(prog, 0.0, 1.0), 2.4));
vec2 flow = p * 3.2 - dir * prog * 5.0 + vec2(seed * 7.1, seed * 3.3);
churn = nv_fbm(flow + vec2(0.0, clock * 0.6));
""")
	ok = ok and stage("Snow band, streaks, haze", -150,
		[[S, "r", "stage:Polar snow front:r"], [S, "front", "stage:Polar snow front:front"],
		[V2, "dir", "stage:Polar snow front:dir"], [S, "churn", "stage:Polar snow front:churn"],
		[S, "prog", "param:progress"], [S, "seed", "param:seed"], [S, "bw", "param:band_width"], [S, "haze_k", "param:haze"]],
		[[S, "band"], [S, "streak"], [S, "haze"]], """
// 앞머리 눈 띠: 들쭉날쭉한 가장자리, 뒤로 갈수록 두께가 붙는다.
float edge = r + (churn - 0.5) * 0.2;
float w = (0.05 + 0.12 * prog) * bw;
float lead = exp(-pow((edge - front) / w, 2.0));
float behind = smoothstep(front + 0.02, front - w * 2.5, edge) * smoothstep(0.0, front, edge);
// 띠를 매끈한 고리가 아니라 찢긴 눈덩이로: 반경 방향으로 늘어난 잘게 끊긴 덩이만 남긴다.
float clumps = nv_fbm(dir * 7.0 + vec2(r * 9.0 - prog * 6.0, seed));
float torn = smoothstep(0.38, 0.62, clumps + lead * 0.25);
band = clamp(lead * torn * 1.25 + behind * 0.22 * churn, 0.0, 1.0);
// 방사형 눈발 줄기: 방향 벡터로 잡음을 뽑아 이음매가 없다. 고리 뒤쪽에만, 바깥으로 달리는 대시로 끊긴다.
float rays = smoothstep(0.55, 0.85, nv_noise(dir * 12.0 + seed * 5.0)) * 0.7
	+ smoothstep(0.62, 0.9, nv_noise(dir * 31.0 + seed * 2.0)) * 0.55;
float dash = smoothstep(0.15, 0.55, fract(r * 3.2 - prog * 3.5 + nv_noise(dir * 17.0) * 0.6));
streak = rays * dash * smoothstep(front + 0.03, front * 0.3, r) * smoothstep(0.04, 0.2, r);
// 가운데 서리 안개: 처음에 짙고 고리가 지나가면 옅어진다.
haze = smoothstep(front, 0.0, r) * (0.45 - prog * 0.25) * (0.5 + churn * 0.5) * haze_k;
streak *= mix(1.0, 0.6, 1.0 - haze_k);
""")
	ok = ok and stage("Snow color", 400,
		[[S, "band", "stage:Snow band, streaks, haze:band"], [S, "streak", "stage:Snow band, streaks, haze:streak"],
		[S, "haze", "stage:Snow band, streaks, haze:haze"], [S, "churn", "stage:Polar snow front:churn"],
		[S, "r", "stage:Polar snow front:r"], [S, "fade", "param:fade"], [S, "intensity", "param:intensity"],
		[V3, "snow", "param:color_snow"], [V3, "shade", "param:color_shade"], [V3, "glow", "param:color_glow"]],
		[[V3, "col"], [S, "alpha"], [V3, "emit"]], """
float body = max(band, max(streak * 0.75, haze));
col = mix(shade, snow, clamp(churn * 1.3 + band * 0.4, 0.0, 1.0));
float outer = 1.0 - smoothstep(0.9, 1.0, r);
alpha = clamp(body * intensity * fade * outer, 0.0, 0.85);
emit = glow * band * 0.35 * fade;
""")
	return ok and finish("nv_roar_ground_burst", {O_ALBEDO: "stage:Snow color:col", O_ALPHA: "stage:Snow color:alpha",
		O_EMISSION: "stage:Snow color:emit"})


# ---------------------------------------------------------------- 2. 고리를 따라 솟는 눈보라 벽

func _snow_wall() -> bool:
	begin("Nivella / roar / rising snow wall", ALPHA)
	input("uv")
	input("time")
	fparam("progress", 0.0)
	fparam("fade", 1.0)
	fparam("intensity", 0.8)
	fparam("seed", 0.0)
	cparam("color_snow", Color(0.93, 0.96, 1.0))
	cparam("color_shade", Color(0.58, 0.68, 0.96))
	var ok := stage("Swirling sheet", -500,
		[[V2, "uv_in", "input:uv"], [S, "prog", "param:progress"], [S, "seed", "param:seed"], [S, "clock", "input:time"]],
		[[S, "dens"], [S, "tone"]], """
// uv.x = 둘레(0~1, 이어짐), uv.y = 위(0) → 아래(1). 둘레는 원 위의 점으로 잡음을 뽑아 이음매가 없다.
float a = uv_in.x * 6.28318;
vec2 ring = vec2(cos(a), sin(a));
float h = 1.0 - uv_in.y;
float rise = clock * 1.4 + prog * 3.0;
float n1 = nv_fbm(ring * 2.6 + vec2(h * 2.2 - rise, seed * 3.0));
float n2 = nv_noise(ring * 9.0 + vec2(h * 6.0 - rise * 2.0, seed));
// 아래가 짙고 위로 갈수록 찢겨 흩어진다. 진행할수록 위쪽부터 비어 간다.
float top = smoothstep(1.0, 0.25 + prog * 0.15, h);
float tatter = smoothstep(0.28 + h * 0.38, 0.7, n1 * 0.75 + n2 * 0.38);
dens = tatter * top * smoothstep(0.0, 0.06, h) * 1.2;
tone = n1;
""")
	ok = ok and stage("Wall color", 100,
		[[S, "dens", "stage:Swirling sheet:dens"], [S, "tone", "stage:Swirling sheet:tone"], [S, "fade", "param:fade"],
		[S, "intensity", "param:intensity"], [V3, "snow", "param:color_snow"], [V3, "shade", "param:color_shade"]],
		[[V3, "col"], [S, "alpha"]], """
col = mix(shade, snow, clamp(tone * 1.4, 0.0, 1.0));
alpha = clamp(dens * intensity * fade, 0.0, 0.75);
""")
	return ok and finish("nv_roar_snow_wall", {O_ALBEDO: "stage:Wall color:col", O_ALPHA: "stage:Wall color:alpha"})
