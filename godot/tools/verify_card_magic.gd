extends SceneTree
## 마법 카드 연출(휘기·말기·비틀기·360° 회전) 헤드리스 검증: 실제 게임 손패에서
## 뽑기(draw)·마우스 올림(hover + 3D 기울기)·집기(pickup)·끌기(속도에 따른 휨)·취소(return)·주머니로(stash 두루마리)·사용(use)이
## CardView 의 연출 동작과 셰이더 값으로 이어지는지 확인한다. 화면 결과는 tools/capture_card_magic.gd(창 실행)로 본다.
## 실행(프로젝트 루트): .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_card_magic.gd

var total := 0
var passed := 0


func _initialize() -> void:
	create_timer(90.0, true, false, true).timeout.connect(func() -> void:
		print("FAIL 시간 초과")
		quit(2))
	call_deferred("run")


func check(label: String, ok: bool, detail := "") -> void:
	total += 1
	if ok:
		passed += 1
	print(("PASS " if ok else "FAIL ") + label + ("  — " + detail if detail != "" else ""))


func frames(n: int) -> void:
	for i in n:
		await process_frame


func run() -> void:
	# 1. 셰이더·메시
	var inc := FileAccess.get_file_as_string("res://shaders/card_warp.gdshaderinc")
	check("변형 include 에 휘기·말기·비틀기·회전·뒷면 값이 있음", inc.find("warp_bend") != -1 and inc.find("warp_roll") != -1 and inc.find("warp_twist") != -1 and inc.find("warp_yaw") != -1 and inc.find("card_back") != -1)
	var burn := load("res://shaders/card_burn.gdshader") as Shader
	var glow := load("res://shaders/card_burn_glow.gdshader") as Shader
	check("카드 그림·소모 글로우 셰이더가 같은 변형을 씀", burn.code.find("card_warp.gdshaderinc") != -1 and glow.code.find("card_warp.gdshaderinc") != -1)
	var Surface = load("res://scripts/ui/card_surface.gd")
	var mesh: ArrayMesh = Surface.grid(Vector2(100, 150))
	var arr := mesh.surface_get_arrays(0)
	check("카드 그림이 격자 메시(13×19 정점)로 그려짐", (arr[Mesh.ARRAY_VERTEX] as PackedVector2Array).size() == (Surface.COLS + 1) * (Surface.ROWS + 1))

	# 2. 실제 게임 손패
	change_scene_to_file("res://scenes/main.tscn")
	await frames(40)
	var game = current_scene
	var hand = game.hud.card_hand
	paused = false
	var CV = hand.CardViewScript
	game.cards.add("wool", 2)
	await frames(2)
	var uid: int = game.cards.hand()[0]["uid"]
	var v = hand.views[uid]
	check("카드 그림 노드가 메시 표면(card_surface)", v.art.get_script() == Surface)
	check("새 카드: 뽑힘 연출(draw) 시작·둥실 떠 있음", v.fl_kind == "draw" and v.t_float > 0.9, "kind=%s" % v.fl_kind)
	var y0: float = v.warp.get("yaw", 0.0)
	check("뽑힘 시작은 뒷면(회전 ≈ −3π 부근, cos<0)", y0 < -2.0 * PI and cos(y0) < 0.0, "yaw=%.2f" % y0)
	check("셰이더에 회전 값이 전달됨", absf(float(v.mat.get_shader_parameter("warp_yaw")) - y0) < 0.01)
	await create_timer(1.1).timeout
	check("뽑힘: 돌고 나면 앞면으로 멈춤", v.fl_kind != "draw" and cos(v.warp.get("yaw", 0.0)) > 0.9, "yaw=%.2f" % v.warp.get("yaw", 0.0))
	for i in 240:
		await process_frame
		if v.mode == CV.Mode.HAND:
			break
	await frames(30)
	check("공개 후 손패로: 떠 있음 해제", v.mode == CV.Mode.HAND and v.t_float == 0.0)

	# 마우스 올림: 카드 오른쪽 위를 가리키면 오른쪽이 들어가고(yaw>0) 위가 들어간다(pitch>0)
	hand._compute_rest()
	hand.set_hover(uid, true)
	await frames(3)
	var hr: Rect2 = hand._hover_rect(uid)
	var m := InputEventMouseMotion.new()
	m.position = hr.get_center() + Vector2(hr.size.x * 0.35, -hr.size.y * 0.35)
	root.push_input(m, true)
	await frames(30)
	check("마우스 올림: 연출(hover) 또는 3D 기울기 반응", v.t_yaw > 0.1 and v.t_pitch > 0.1, "t_yaw=%.2f t_pitch=%.2f hover=%d" % [v.t_yaw, v.t_pitch, hand.hover_uid])
	check("마우스 올림: 실제 회전이 목표를 따라감", v.yaw > 0.05, "yaw=%.2f" % v.yaw)

	# 집기 → 끌기 → 취소
	hand.begin_drag(uid)
	await process_frame
	check("집기: pickup 연출", v.fl_kind == "pickup")
	var start: Vector2 = v.pos
	var max_bend := 0.0
	var max_flut := 0.0
	for i in 20:
		hand.drag_pos = start + Vector2(-60.0 * i, -25.0 * i)
		await process_frame
		max_bend = maxf(max_bend, v.bend.x)
		max_flut = maxf(max_flut, v.flutter)
	check("끌기: 빠르게 움직이면 휘고 펄럭임", max_bend > 0.08 and max_flut > 0.1, "bend=%.2f flutter=%.2f" % [max_bend, max_flut])
	check("끌기: 왼쪽으로 움직이면 그쪽으로 돈다(yaw<0)", v.yaw < -0.05, "yaw=%.2f" % v.yaw)
	hand._cancel_by_player()
	await process_frame
	check("취소: 한 바퀴 돌며 돌아감(return)", v.fl_kind == "return" and v.mode == CV.Mode.HAND)
	await frames(60)

	# 주머니로: 두루마리
	hand._send_to_pocket(v)
	hand.views.erase(uid)
	# 2026-10-23: 휘어 도는 곡선으로 끌려가다 후반에 말려 든다(STASH_TIME 0.8초 중 0.45 이후 말림)
	await create_timer(0.6).timeout
	check("주머니로: 곡선으로 끌려가다 두루마리처럼 말림(stash, roll>0)", v.fl_kind == "stash" and v.path_lock and v.warp.get("roll", 0.0) > 0.2, "roll=%.2f" % v.warp.get("roll", 0.0))

	# 사용: 한 바퀴 돌며 타오름
	game.cards.add("moss_bandage")
	await frames(240)
	var e2: Dictionary = game.cards.hand().filter(func(e): return e["id"] == "moss_bandage")[0]
	var v2 = hand.views[e2["uid"]]
	hand.views.erase(e2["uid"])
	hand._consume_view(v2)
	await frames(8)
	check("사용: 핑그르 돌며(use) 보여 주기 단계로 날아감", v2.fl_kind == "use" and v2.mode == CV.Mode.DYING and v2.showing() and absf(v2.warp.get("twist", 0.0)) > 0.2, "twist=%.2f" % v2.warp.get("twist", 0.0))
	await create_timer(CV.SHOW_MOVE + CV.SHOW_HOLD + 0.1).timeout
	check("사용: 보여 준 뒤 타오름(burn)", v2.fl_kind == "burn" and not v2.showing() and v2.burn_glow.visible)
	await frames(2)
	check("사용: 소모 글로우 층에도 같은 휨이 전달됨", absf(float(v2.glow_mat.get_shader_parameter("warp_twist")) - float(v2.mat.get_shader_parameter("warp_twist"))) < 0.01)

	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)
