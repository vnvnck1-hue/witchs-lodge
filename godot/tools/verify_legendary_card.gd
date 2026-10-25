extends SceneTree
## 전설 카드 포맷·셰이더 연결 헤드리스 검증(첫 전설 카드: 술 주정뱅이 에린, docs/tavern-cards-v01.md).
## 실행(프로젝트 루트): .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_legendary_card.gd
## 셰이더의 실제 빛·반짝임 외형은 헤드리스로 볼 수 없어 tools/capture_legendary_card.gd 로 렌더 캡처한다.

const Catalog := preload("res://scripts/ui/card_catalog.gd")
const CardFace := preload("res://scripts/ui/card_face.gd")
const CardView := preload("res://scripts/ui/card_view.gd")

var passed := 0
var total := 0


func _check(ok: bool, label: String, detail := "") -> void:
	total += 1
	if ok:
		passed += 1
	print("%s %s%s" % ["PASS" if ok else "FAIL", label, ("  — " + detail) if detail != "" else ""])


func _initialize() -> void:
	var erin := Catalog.find("drunken_erin")
	_check(erin.get("frame", "") == "legendary", "에린 카드는 전설 프레임(frame=legendary)")
	_check(PackedStringArray(erin.get("printed_rules", [])).size() == 2, "에린 설명 문구 2줄이 카탈로그에 있음")
	var t := Catalog.texture("drunken_erin")
	var h := Catalog.texture("drunken_erin", true)
	_check(t != null and t.get_width() == 1024 and h != null and h.get_width() == 256, "전설 에린 그림 1024·손패 256")
	var others := 0
	for d in Catalog.read().get("cards", []):
		if String(d.get("frame", "")) == "legendary":
			others += 1
	_check(others == 6, "지금 전설 카드는 에린 + 전설 5장(docs/legend-cards-v01.md)", str(others))
	# 글자 칸: 전설 그림에서 잰 크림판 프로파일(text_layout.json)에 맞춰 런타임 글꼴로 채운다
	var pl := CardFace.plates_for(String(erin["texture"]))
	_check(pl != CardFace.DEFAULT and pl.has("title") and pl.has("rules"), "전설 에린 그림의 판 프로파일(제목·설명)이 있음")
	var plan := CardFace.layout(String(erin["name"]), String(erin["category"]), "", PackedStringArray(erin["printed_rules"]), pl, 1.0)
	var tl: Array = plan.get("title", {}).get("lines", [])
	var rl: Array = plan.get("rules", {}).get("lines", [])
	_check(tl.size() == 2 and tl[0]["text"] == erin["name"] and tl[1]["text"] == erin["category"], "제목 한 줄 + 분류 한 줄이 위 타원 판에 들어감", str(tl.map(func(x): return x["text"])))
	_check(rl.size() == 2 and int(plan["rules"]["fit"]["used"]) == int(plan["rules"]["fit"]["target"]), "설명 2줄이 기준 크기 그대로 들어감", str(plan["rules"]["fit"]))
	_check(int(plan["title"]["fit"]["used"]) >= 80 and tl[0]["pos"].y < 240.0, "제목은 위 타원 안에 80px 이상", str(plan["title"]["fit"]))
	# 마스크
	var mask := load(CardView.LEGEND_MASK) as Texture2D
	_check(mask != null and mask.get_width() * 3 == mask.get_height() * 2, "전설 프레임 마스크(2:3)")
	# CardView 연결과 회전 반응
	var v := CardView.new()
	root.add_child(v)
	v.setup("drunken_erin", t)
	v.resize(Vector2(160, 240))
	_check(v.legendary and v.mat.get_shader_parameter("legendary") == true and v.mat.get_shader_parameter("legend_mask") != null, "에린 카드 뷰에서 전설 셰이더가 켜짐")
	var plain := CardView.new()
	root.add_child(plain)
	plain.setup("timber", Catalog.texture("timber"))
	plain.resize(Vector2(160, 240))
	_check(not plain.legendary and plain.mat.get_shader_parameter("legendary") != true, "일반 카드(목재)는 전설 셰이더 꺼짐")
	for i in 30:
		v.step(1.0 / 60.0)
	var rest := v.legend_motion
	_check(rest < 0.05, "가만히 있으면 빛 반응이 거의 0", "%.3f" % rest)
	v.t_rot = 18.0
	var peak := 0.0
	for i in 20:
		v.step(1.0 / 60.0)
		peak = maxf(peak, v.legend_motion)
	_check(peak > 0.35, "카드가 회전하면 빛 반응이 오름", "%.2f" % peak)
	var ang: float = v.mat.get_shader_parameter("legend_angle")
	_check(absf(ang) > 0.05, "회전 각도가 광택 띠 위치로 전달됨", "%.2f" % ang)
	v.t_rot = v.rot
	for i in 180:
		v.step(1.0 / 60.0)
	_check(v.legend_motion < peak * 0.4, "회전이 멈추면 빛 반응이 천천히 가라앉음", "%.2f → %.2f" % [peak, v.legend_motion])
	_check(v.pivot_offset == v.size * 0.5 and plain.pivot_offset == Vector2(plain.size.x * 0.5, plain.size.y), "전설 카드는 카드 중앙을 축으로 회전(일반 카드는 기존대로 아래 가운데)")
	v.t_tilt = Vector2(0.3, 0.1)
	v.step(1.0 / 60.0)
	_check(v.tilt == Vector2.ZERO and v.mat.get_shader_parameter("tilt") == Vector2.ZERO, "전설 카드는 셰이더 원근 기울기를 쓰지 않음")
	v.t_tilt = Vector2.ZERO
	_check(v.glow.modulate.a > 0.05 and plain.glow.modulate.a < 0.01, "전설 카드만 뒤에 금빛 후광", "%.2f / %.2f" % [v.glow.modulate.a, plain.glow.modulate.a])
	# 손패 자리(사용자 지적 2026-10-20): 가운데 축이어도 부채꼴 각도·확대·축소에서 화면 위 카드 자리가 일반 카드와 같다
	var worst := 0.0
	for pose in [[Vector2(400, 600), -9.0, 1.0], [Vector2(520, 620), 6.0, 0.62], [Vector2(640, 560), 0.0, 1.55], [Vector2(300, 500), 12.0, 1.3]]:
		for c in [v, plain]:
			c.snap(pose[0], pose[1], pose[2])
		for corner in [Vector2.ZERO, Vector2(160, 0), Vector2(160, 240), Vector2(0, 240), Vector2(80, 120)]:
			worst = maxf(worst, (v.get_global_transform() * corner).distance_to(plain.get_global_transform() * corner))
	_check(worst < 0.5, "손패 각도·크기에서 전설 카드의 화면 자리가 일반 카드와 같음(어긋남 없음)", "최대 %.2fpx" % worst)
	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)
