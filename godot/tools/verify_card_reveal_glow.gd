extends SceneTree
## 카드 공개 글로우(card_reveal_glow) 헤드리스 검증: 셰이더 로드, FX 노드 구성, 진행도 이징, 수명, 호출처 교체.
## 실행(프로젝트 루트): .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_card_reveal_glow.gd

const FX := preload("res://scripts/ui/card_fx.gd")

var passed := 0
var total := 0


func check(name: String, ok: bool, extra := "") -> void:
	total += 1
	if ok:
		passed += 1
	print(("PASS " if ok else "FAIL ") + name + ("" if extra.is_empty() else "  (" + extra + ")"))


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var sh = load("res://shaders/card_reveal_glow.gdshader")
	check("셰이더 로드", sh is Shader)
	var code: String = sh.code if sh is Shader else ""
	check("에디티브 블렌딩", code.contains("render_mode blend_add"))
	check("둥근 사각형 SDF", code.contains("float rbox("))
	check("텐션 이징(expo/quart)", code.contains("ease_out_expo") and code.contains("ease_out_quart"))
	for u in ["card_size", "pad", "corner", "progress", "color_core", "color_mid", "color_edge"]:
		check("uniform " + u, code.contains("uniform") and code.contains(" " + u))

	var fx = FX.new()
	root.add_child(fx)
	var card := Vector2(120.0, 180.0)
	var at := Vector2(400.0, 300.0)
	fx.card_glow(at, card, 12.0)
	await process_frame
	var g: ColorRect = null
	var g2: ColorRect = null
	var n_layers := 0
	for c in fx.get_children():
		if c is ColorRect:
			n_layers += 1
			if g == null:
				g = c
			else:
				g2 = c
	check("글로우 두 겹 생성", n_layers == 2, str(n_layers))
	check("둘째 겹은 시간차(처음엔 숨김)", g2 != null and not g2.visible and float(g2.get_meta("glow_delay", 0.0)) > 0.0)
	check("둘째 겹은 파동이 더 작음", g2 != null and float((g2.material as ShaderMaterial).get_shader_parameter("spread")) < float((g.material as ShaderMaterial).get_shader_parameter("spread")))
	check("파동 거리 ≤ 카드 폭의 절반(작게 퍼짐)", g != null and float((g.material as ShaderMaterial).get_shader_parameter("spread")) <= 0.5)
	if g != null:
		var m := g.material as ShaderMaterial
		check("ShaderMaterial 사용", m != null and m.shader == sh)
		var pad := Vector2.ONE * card.x * 0.6
		check("사각형 = 카드 + pad*2", g.size.is_equal_approx(card + pad * 2.0), str(g.size))
		check("카드 중심에 정렬", (g.position + g.pivot_offset).is_equal_approx(at))
		check("카드 회전 따라감", is_equal_approx(g.rotation_degrees, 12.0))
		check("카드 크기 uniform", (m.get_shader_parameter("card_size") as Vector2).is_equal_approx(card))
		check("시작 배율 < 1(백 이징으로 넘쳐 돌아옴)", g.scale.x < 1.0, str(g.scale.x))
		var p0: float = g.get_meta("glow_progress", -1.0)
		# 0.2초 뒤: sine-out 이면 선형(0.25)보다 앞서 있어야 한다
		var t0 := Time.get_ticks_msec()
		while Time.get_ticks_msec() - t0 < 200:
			await process_frame
		var p1: float = g.get_meta("glow_progress", -1.0)
		var sx := g.scale.x
		check("진행도 증가", p1 > p0 and p1 > 0.0, "%.2f → %.2f" % [p0, p1])
		check("진행도 선형보다 앞섬(이즈 아웃)", p1 > 0.26, "%.3f" % p1)
		check("배율 백 이징으로 1 넘김 또는 접근", sx > 0.95, "%.3f" % sx)
		check("둘째 겹 지연 뒤 표시", is_instance_valid(g2) and g2.visible)
		var alive := true
		t0 = Time.get_ticks_msec()
		while Time.get_ticks_msec() - t0 < 1200:
			await process_frame
			if not is_instance_valid(g) and not is_instance_valid(g2):
				alive = false
				break
		check("수명 뒤 두 겹 모두 해제", not alive)

	for path in ["res://scripts/ui/card_hand.gd", "res://scripts/ui/mulligan_screen.gd", "res://scripts/ui/card_fx.gd"]:
		var src := FileAccess.get_file_as_string(path)
		check(path.get_file() + " 원형 ring 호출 없음", not src.contains("fx.ring(") and not src.contains("RingFx"))
	var hand := FileAccess.get_file_as_string("res://scripts/ui/card_hand.gd")
	check("공개 도착 시 card_glow", hand.contains("fx.card_glow(c, Vector2(CW, CH) * v.t_scl"))
	var cv := FileAccess.get_file_as_string("res://scripts/ui/card_view.gd")
	check("REVEAL 스프링 감쇠 < 0.7(텐션)", cv.contains("Mode.REVEAL: [230.0, 0.58]"))

	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)
