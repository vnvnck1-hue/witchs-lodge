extends SceneTree
## 로비(타이틀) 헤드리스 검증 — 컨셉 원화 레이어 재현 + 인물 셰이더 아이들링(사용자 요청 2026-10-24). docs/lobby.md
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_lobby.gd
## 셰이더 변위를 CPU에서 같은 식으로 계산해 "천천히 자연스럽게"(작은 변위·느린 속도·인물마다 다른 박자)를 수치로 확인한다.
## 실제 픽셀(원화 일치·찢어짐)은 tools/capture_lobby.gd 로 본다.

const LobbyRig := preload("res://scripts/ui/lobby_rig.gd")
const LOBBY_DIR := "res://assets/ui/lobby/"
const MAX_SHIFT_BODY := 6.0     # 인물 몸·머리 최대 변위(px, 원화 1080 기준)
const MAX_SPEED_BODY := 6.0     # 인물 몸·머리 최대 속도(px/s)
const MAX_SHIFT_PART := 9.0     # 귀·날개·더듬이(가벼운 부위)
const PARTS := ["goblin_ear", "wings", "antennae", "wolf_ear", "hat"]

var passed := 0
var total := 0


func check(name: String, ok: bool, detail := "") -> void:
	total += 1
	if ok:
		passed += 1
	print("%s %s%s" % ["PASS" if ok else "FAIL", name, ("  — " + detail) if detail != "" else ""])


func _initialize() -> void:
	_run.call_deferred()


func frames(n: int) -> void:
	for i in n:
		await process_frame


## lobby_idle.gdshader 의 motion() 과 같은 식(부모 포함). 반환: 변위(px)
func motion(i: int, p: Vector2, t: float) -> Vector2:
	var r: Array = LobbyRig.REGIONS[i]
	var d := _own(r, p, t)
	if r[9] >= 0:
		d += _own(LobbyRig.REGIONS[r[9]], p, t)
	return d


func _own(r: Array, p: Vector2, time: float) -> Vector2:
	var c: Vector2 = r[1]
	var t: float = time + r[4]
	var gate := 1.0
	if r[8] > 0:
		gate = pow(maxf(sin(t * TAU / r[10] + 1.3), 0.0), 18.0)
	var w: float = TAU / r[3]
	var a: float = deg_to_rad(r[2]) * (0.72 * sin(t * w) + 0.28 * sin(t * w * 1.61 + 1.1)) * gate
	var q := p - c
	var src := c + Vector2(cos(a) * q.x + sin(a) * q.y, -sin(a) * q.x + cos(a) * q.y)
	var b: float = sin(t * TAU / r[6])
	var above := smoothstep(0.0, 120.0, c.y - src.y)
	src.y = lerpf(src.y, c.y + (src.y - c.y) / (1.0 + r[7] * b), above)
	src.y += r[5] * (0.5 + 0.5 * b) * smoothstep(-80.0, 160.0, c.y - p.y)
	return p - src


## 구역이 차지하는 대표 점들(피벗 주변 반경 안 격자)에서 0~30초 동안 최대 변위·속도
func region_stats(i: int, radius: float) -> Dictionary:
	var c: Vector2 = LobbyRig.REGIONS[i][1]
	var max_shift := 0.0
	var max_speed := 0.0
	var dt := 0.05
	for gx in range(-2, 3):
		for gy in range(-2, 3):
			var p := c + Vector2(gx, gy) * radius * 0.5
			p = p.clamp(Vector2.ZERO, LobbyRig.CANVAS)
			var prev := motion(i, p, 0.0)
			var t := dt
			while t < 30.0:
				var d := motion(i, p, t)
				max_shift = maxf(max_shift, d.length())
				max_speed = maxf(max_speed, (d - prev).length() / dt)
				prev = d
				t += dt
	return {"shift": max_shift, "speed": max_speed}


func _run() -> void:
	# 1) 리그 값: 인물 일곱 + 부위 다섯, 몸통은 느린 주기, 박자가 서로 다르다
	var regions: Array = LobbyRig.REGIONS
	check("리그 구역 12개(인물 7 + 모자·고블린 귀·날개·더듬이·늑대 귀)", regions.size() == 12, str(regions.map(func(r): return r[0])))
	var bodies := regions.filter(func(r): return not r[0] in PARTS)
	check("몸통 기울기 주기 6초 이상·숨 주기 3초 이상(천천히)", bodies.all(func(r): return r[3] >= 6.0 and r[6] >= 3.0),
		str(bodies.map(func(r): return "%s %.1f/%.1f" % [r[0], r[3], r[6]])))
	check("몸통 기울기 1도 미만", bodies.all(func(r): return r[2] < 1.0))
	var periods := {}
	for r in bodies:
		periods["%.1f/%.1f" % [r[3], r[6]]] = true
	check("인물마다 박자가 다르다(기울기/숨 주기 조합이 모두 다름)", periods.size() == bodies.size())
	var phases := {}
	for r in bodies:
		phases[r[4]] = true
	check("인물마다 위상이 다르다", phases.size() == bodies.size())
	check("부위는 부모 인물을 이어받는다(모자→마녀, 귀→고블린·늑대, 날개·더듬이→요정)",
		regions[5][9] == 4 and regions[8][9] == 7 and regions[9][9] == 3 and regions[10][9] == 3 and regions[11][9] == 1)

	# 2) 변위·속도: 몸통 6px/6px·s 이하, 가벼운 부위 9px 이하
	var worst_body := ""
	var body_ok := true
	for i in regions.size():
		var r: Array = regions[i]
		var part: bool = r[0] in PARTS
		var st := region_stats(i, 160.0 if not part else 90.0)
		var lim_shift := MAX_SHIFT_PART if part else MAX_SHIFT_BODY
		var ok: bool = st["shift"] <= lim_shift and (part or st["speed"] <= MAX_SPEED_BODY)
		print("  %-10s 최대 변위 %.2fpx  최대 속도 %.2fpx/s" % [r[0], st["shift"], st["speed"]])
		if not ok:
			body_ok = false
			worst_body += "%s(%.1fpx, %.1fpx/s) " % [r[0], st["shift"], st["speed"]]
	check("움직임이 작고 느리다(몸 ≤%.0fpx·≤%.0fpx/s, 부위 ≤%.0fpx)" % [MAX_SHIFT_BODY, MAX_SPEED_BODY, MAX_SHIFT_PART], body_ok, worst_body)
	var still := true
	for i in regions.size():
		if motion(i, regions[i][1] + Vector2(40, -60), 0.0).length() > 6.0:
			still = false
	check("시작 순간에도 원화에서 크게 벗어나지 않는다", still)

	# 3) 레이어·가중치 파일
	var files := ["lobby_bg", "lobby_characters", "lobby_title", "lobby_menu_continue", "lobby_menu_new", "lobby_menu_archive",
		"lobby_menu_settings", "lobby_menu_exit", "lobby_menu_moon", "lobby_menu_underline"]
	var missing := files.filter(func(f): return not ResourceLoader.exists(LOBBY_DIR + f + ".png"))
	check("원화 레이어 10장이 있다", missing.is_empty(), "없음: " + str(missing))
	check("셰이더 가중치 3장이 있다", LobbyRig.weights_ready())
	for f in ["lobby_bg", "lobby_characters", "lobby_title"]:
		if ResourceLoader.exists(LOBBY_DIR + f + ".png"):
			var tex: Texture2D = load(LOBBY_DIR + f + ".png")
			check("%s 1920×1080" % f, tex.get_size() == Vector2(1920, 1080), str(tex.get_size()))
	if ResourceLoader.exists(LOBBY_DIR + "lobby_characters.png"):
		var img: Image = load(LOBBY_DIR + "lobby_characters.png").get_image()
		var corner := img.get_pixel(1900, 40).a
		var face := img.get_pixel(300, 200).a
		check("인물 레이어: 오른쪽 하늘은 투명, 인간 얼굴은 불투명", corner < 0.05 and face > 0.95, "하늘 %.2f 얼굴 %.2f" % [corner, face])
	var shader: Shader = load("res://shaders/lobby_idle.gdshader")
	check("셰이더 리소스", shader != null and shader.code.contains("rig_pivot"))

	# 4) 타이틀 장면: 메뉴·강조·안내·언어
	var lobby = load("res://scenes/title.tscn").instantiate()
	root.add_child(lobby)
	await frames(6)
	var labels: Array = lobby.menu_buttons.map(func(b): return b.text)
	check("메뉴: 이어하기·새로운 이야기·기록 보관소·설정 + 나가기", labels == ["이어하기", "새로운 이야기", "기록 보관소", "설정"] and lobby.quit_btn.text == "나가기", str(labels))
	check("원화 레이어 모드", lobby.layered)
	check("인물 레이어에 아이들링 셰이더", lobby.characters != null and lobby.character_mat != null)
	if lobby.character_mat != null:
		check("셰이더 리그 배열이 12칸", (lobby.character_mat.get_shader_parameter("rig_pivot") as PackedVector4Array).size() == 12)
		var t0: float = lobby.character_mat.get_shader_parameter("motion_time")
		await frames(10)
		check("시계가 흐른다", float(lobby.character_mat.get_shader_parameter("motion_time")) > t0)
	var order: Array = lobby.stage.get_children().map(func(n): return String(n.name))
	check("겹침 순서: 배경 → 인물 → 타이틀 → 메뉴", order.find("Background") < order.find("Characters") and order.find("Characters") < order.find("TitleBox") and order.find("TitleBox") < order.find("Menu"), str(order))
	check("처음 강조는 원화처럼 이어하기", lobby.highlighted == 0)
	var moon_home: Rect2 = lobby.moon_mark.get_meta("home")
	check("이어하기 강조 때 초승달이 원화 자리", lobby.moon_mark.position.distance_to(moon_home.position) < 0.5, str(lobby.moon_mark.position))
	lobby.highlight(2, true)
	var dy: float = lobby.menu_rects[2].get_center().y - lobby.menu_rects[0].get_center().y
	check("기록 보관소로 옮기면 초승달·밑줄이 그 줄로", absf(lobby.moon_mark.position.y - (moon_home.position.y + dy)) < 0.5
		and absf(lobby.underline.position.y - (lobby.underline.get_meta("home").position.y + dy)) < 0.5)
	var art0: Control = lobby.menu_art[0] if lobby.menu_art[0] != null else lobby.menu_buttons[0]
	var art2: Control = lobby.menu_art[2] if lobby.menu_art[2] != null else lobby.menu_buttons[2]
	check("고른 줄은 커지고 이어하기는 보통 크기로", art2.scale.x > 1.05 and art0.scale.x < 0.95, "%.2f / %.2f" % [art2.scale.x, art0.scale.x])
	lobby.highlight(0, true)
	check("되돌리면 원화 크기(1.0)", is_equal_approx(art0.scale.x, 1.0) and is_equal_approx(art2.scale.x, 1.0))
	check("이어하기는 비활성(저장 기능 없음)", lobby.continue_btn.disabled)
	lobby._on_continue()
	await frames(20)
	check("이어하기를 누르면 안내가 뜬다", lobby.notice.text != "" and lobby.notice.modulate.a > 0.1, lobby.notice.text)
	lobby._open_settings()
	check("설정을 열면 타이틀·메뉴가 숨는다", lobby.settings_panel.visible and not lobby.title_box.visible and not lobby.menu.visible)
	lobby.close_settings()
	lobby._open_select()
	check("새로운 이야기 → 네 마녀 선택", lobby.select_panel.visible and lobby.slot_buttons.size() == 4)
	lobby.close_select()
	if lobby.layered:
		var ink: Color = lobby.continue_btn.get_theme_color("font_color")
		check("한국어: 원화 글자 그림을 보이고 버튼 글자는 투명", lobby.menu_art[0].visible and ink.a == 0.0)
		TranslationServer.set_locale("en")
		await frames(3)
		ink = lobby.continue_btn.get_theme_color("font_color")
		check("영어: 원화 글자 그림을 숨기고 게임이 글자를 그린다", not lobby.menu_art[0].visible and ink.a > 0.9)
		TranslationServer.set_locale("ko")
		await frames(3)
	# 무대 맞춤(2026-10-24 사용자 요청: 넓은 화면에서 위가 잘리지 않게): 여러 화면비에서 빈틈없이 덮고, 나가기가 화면 안,
	# 넓은 레이어가 있으면 21:9·3440×1440 에서도 위아래를 자르지 않는다
	check("넓은 화면용 왼쪽 확장 레이어(2640×1080)를 쓴다", lobby.art_x == lobby.WIDE_EXT and lobby.stage.size.x == 2640.0, "art_x %.0f" % lobby.art_x)
	for res in [Vector2(1920, 1080), Vector2(1774, 887), Vector2(2560, 1080), Vector2(3440, 1440), Vector2(1440, 1080)]:
		lobby.size = res
		lobby._fit_stage()
		var s: float = lobby.stage.scale.x
		var p: Vector2 = lobby.stage.position
		var covered: bool = p.x <= 0.5 and p.y <= 0.5 and lobby.stage.size.x * s + p.x >= res.x - 0.5 and 1080.0 * s + p.y >= res.y - 0.5
		var exit_in: bool = (lobby.art_x + lobby.EXIT_RECT.end.x) * s + p.x <= res.x and lobby.EXIT_RECT.end.y * s + p.y <= res.y
		var no_vcrop: bool = absf(p.y) < 0.5 and absf(1080.0 * s - res.y) < 0.5
		check("%d×%d: 빈틈없이 덮고 나가기가 화면 안, 위아래가 잘리지 않음" % [res.x, res.y], covered and exit_in and no_vcrop, "scale %.3f pos %s" % [s, p])
	lobby.size = Vector2(1920, 1080)
	lobby._fit_stage()
	check("16:9 에서는 원화 그대로(확장 부분은 화면 밖)", is_equal_approx(lobby.stage.scale.x, 1.0) and absf(lobby.stage.position.x + lobby.art_x) < 0.5, str(lobby.stage.position))
	# 음악: 계속 되풀이
	await frames(3)
	if lobby.music != null:
		var st: AudioStream = lobby.music.stream
		var loops: bool = ("loop" in st and st.loop) or lobby.music.finished.get_connections().size() > 0
		check("로비 음악이 계속 되풀이된다", loops, st.get_class())
	else:
		check("로비 음악이 있다", false)
	lobby.queue_free()
	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)
