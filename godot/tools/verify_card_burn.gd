extends SceneTree
## 카드 소모 연출 업그레이드 검증(헤드리스): 보랏빛 에디티브 글로우 층과 검은 재 입자가
## 실제 카드 사용(드래그 → 산장에 놓기)과 복제본 소모(스택 일부 소모) 두 경로에서 모두 동작하는지 확인한다.
## 셰이더 컴파일·화면 결과는 헤드리스에서 확인할 수 없다 → tools/capture_card_burn.gd 로 실제 렌더 캡처.
## 실행(프로젝트 루트): .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_card_burn.gd
var results: Array = []
var failed := false


func _initialize() -> void:
	create_timer(60.0, true, false, true).timeout.connect(func() -> void:
		print("FAIL 시간 초과")
		quit(2))
	call_deferred("run")


func check(label: String, passed: bool, detail := "") -> void:
	results.append({"check": label, "passed": passed, "detail": detail})
	failed = failed or not passed
	print(("PASS " if passed else "FAIL ") + label + ("  — " + detail if detail != "" else ""))


func wait_frames(n: int) -> void:
	for i in n:
		await physics_frame


func run() -> void:
	# 1. 셰이더·공용 include 파일
	var inc := FileAccess.get_file_as_string("res://shaders/card_burn_noise.gdshaderinc")
	check("공용 노이즈 include 에 burn_edge 가 있음", inc.find("float burn_edge(") != -1)
	var burn := load("res://shaders/card_burn.gdshader") as Shader
	var glow := load("res://shaders/card_burn_glow.gdshader") as Shader
	check("card_burn 셰이더가 include 를 쓰고 자체 노이즈 정의를 없앰", burn != null and burn.code.find("card_burn_noise.gdshaderinc") != -1 and burn.code.find("float vnoise(") == -1)
	check("card_burn_glow 셰이더: 에디티브 블렌드 + 같은 연소선", glow != null and glow.code.find("render_mode blend_add") != -1 and glow.code.find("burn_edge(") != -1)
	var m := BURN_MARGIN_FROM(burn.code)
	var CardView = load("res://scripts/ui/card_view.gd")
	check("GDScript 의 연소선 여유가 셰이더 기본값과 같음", is_equal_approx(m, CardView.BURN_MARGIN), "shader=%.4f script=%.4f" % [m, CardView.BURN_MARGIN])

	# 2. 실제 게임: 카드 획득 → 산장에 놓아 사용 → 소모 연출
	change_scene_to_file("res://scenes/main.tscn")
	await wait_frames(40)
	var game = current_scene
	var hand = game.hud.card_hand
	paused = false
	game.cards.add("timber", 5)
	await wait_frames(3)
	for i in 180:
		await physics_frame
		if not hand.views.is_empty() and hand.views.values()[0].mode == hand.CardViewScript.Mode.HAND:
			break
	var uid: int = game.cards.hand()[0]["uid"]
	var v = hand.views[uid]
	check("소모 전: 글로우 층 숨김·재 없음", not v.burn_glow.visible and v.ash == null)
	var parent: Node = v.get_parent()
	var ash_before := _count_ash(parent)

	game.world.lodge.take_damage(150.0)
	hand.begin_drag(uid)
	await create_timer(0.15).timeout
	hand.drag_pos = game.world.camera.unproject_position(game.world.lodge.global_position + Vector3(0, 2, 0))
	hand._end_drag()
	await process_frame
	check("산장에 놓아 사용 → 카드가 소모(DYING) 상태로 떠남", v.mode == hand.CardViewScript.Mode.DYING and hand._leaving.has(v))
	check("글로우 층이 켜지고 카드 위(그림 뒤 순서)에 있음", v.burn_glow.visible and v.burn_glow.get_index() > v.art.get_index())
	var gp: Vector2 = v.glow_mat.get_shader_parameter("pad")
	var fp: Vector2 = v.mat.get_shader_parameter("pad")
	check("글로우 사각형이 불꽃 사각형보다 넓게 번짐", gp.x > fp.x and v.burn_glow.size.x > v.art.size.x, "glow pad=%s flame pad=%s" % [gp, fp])
	check("재 입자가 카드의 형제로 생성되어 발생 중", v.ash != null and v.ash.get_parent() == parent and v.ash.emitting and _count_ash(parent) == ash_before + 1)
	var ash = v.ash
	check("재 입자: 검은색 램프·위로 뜨는 중력·회전", ash.color_ramp.get_color(ash.color_ramp.get_point_count() - 1).v < 0.1 and ash.gravity.y < 0.0 and ash.angular_velocity_max > 0.0)

	# 연소선이 아래에서 위로 올라간다: 재 발생 위치 y 가 줄어든다
	await create_timer(0.3).timeout
	var y0: float = v.ash_y
	var p0: float = v.glow_mat.get_shader_parameter("progress")
	await create_timer(0.3).timeout
	var y1: float = v.ash_y
	var p1: float = v.glow_mat.get_shader_parameter("progress")
	check("글로우 progress 가 카드 셰이더와 같이 증가", p1 > p0 and is_equal_approx(p1, v.mat.get_shader_parameter("progress")), "%.2f → %.2f" % [p0, p1])
	check("재 발생 위치가 아래에서 위로 이동", y1 < y0 and y0 <= v.size.y * 1.06, "y %.1f → %.1f (카드 높이 %.0f)" % [y0, y1, v.size.y])
	check("재 입자가 카드 변환(회전·배율)을 따라감", ash.transform.origin.distance_to(v.get_transform() * Vector2(v.size.x * 0.5, clampf(v.ash_y, -v.size.y * 0.06, v.size.y * 1.06))) < 0.5)

	# 끝: 카드는 지워지고 재는 남아 멈춘 뒤 수명이 끝나면 지워진다
	await create_timer(0.7).timeout
	check("소모가 끝나 카드 뷰가 지워짐", not is_instance_valid(v) or not hand._leaving.has(v))
	check("재 입자는 남아 있고 발생만 멈춤", is_instance_valid(ash) and not ash.emitting)
	await create_timer(CardView.ASH_LIFETIME * 1.4 + 0.5).timeout
	check("재 입자가 수명 뒤 지워짐", not is_instance_valid(ash))

	# 3. 복제본 소모 경로(스택 일부 소모): FX 레이어에 재가 붙는다
	var fx = hand.fx
	var fx_ash_before := _count_ash(fx)
	fx.dissolve_copy(hand._surface("timber"), Vector2(400, 500), Vector2(hand.CW, hand.CH), 0.0, 1.0)
	await process_frame
	check("복제본 소모에도 재 입자가 FX 레이어에 생성", _count_ash(fx) == fx_ash_before + 1)
	await create_timer(1.3).timeout
	var left := 0
	for c in fx.get_children():
		if c is CPUParticles2D and c.emitting:
			left += 1
	check("복제본 소모가 끝나면 재 발생이 멈춤", left == 0)

	var n_pass := 0
	for r in results:
		if r["passed"]:
			n_pass += 1
	print("RESULT %d/%d" % [n_pass, results.size()])
	quit(1 if failed else 0)


func _count_ash(node: Node) -> int:
	var n := 0
	for c in node.get_children():
		if c is CPUParticles2D:
			n += 1
	return n


## 셰이더 소스의 Burn 기본값으로 연소선 여유를 계산한다(스크립트 상수와 대조)
func BURN_MARGIN_FROM(code: String) -> float:
	return _u(code, "fire_thickness") + _u(code, "edge_wobble") * 0.15 + _u(code, "edge_jaggedness") * 0.3 + 0.02


func _u(code: String, name: String) -> float:
	var re := RegEx.new()
	re.compile("uniform float " + name + "[^=]*=\\s*([0-9.]+)")
	var r := re.search(code)
	return float(r.get_string(1)) if r != null else NAN
