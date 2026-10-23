extends SceneTree
## 에린 대화 창 초상 모션(아이들링·등장 가슴 모핑) 헤드리스 검증. docs/erin-portrait-motion.md
## 셰이더 재질이 초상에 걸리고, 에린 프로필의 모션 값이 실리며, 시계·등장 시간이 흐르고, 모션 정보가 없는 손님은 정지(0)인지 본다.
## 실제 화면 모양(셰이더 컴파일·변형 결과)은 tools/capture_portrait_motion.gd 로 따로 본다.
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_portrait_motion.gd

const Profiles := preload("res://scripts/ui/guest_profiles.gd")
const PortraitMotion := preload("res://scripts/ui/portrait_motion.gd")
const SHADER := "res://shaders/guest_portrait_motion.gdshader"

var game
var failures := 0
var total := 0


func _initialize() -> void:
	create_timer(60.0, true, false, true).timeout.connect(func(): print("FAIL timeout"); quit(1))
	_run.call_deferred()


func check(name: String, ok: bool, detail := "") -> void:
	total += 1
	if not ok: failures += 1
	print(("PASS " if ok else "FAIL ") + name + ("  — " + detail if detail != "" else ""))


func frames(n := 2) -> void:
	for i in n: await process_frame


func open(id: String) -> Dictionary:
	var events = game.guest_events
	var profile: Dictionary = Profiles.guest_profile(id)
	events._on_batch([profile])
	events.admit(profile)
	game.guest_ui.open_conversation(int(profile["visit_uid"]))
	await frames(6)
	return profile


## 초상 등장 모션(0.06+0.63초)이 끝날 때까지 기다린다.
func until_settled(pres) -> void:
	while pres.phase_time < 0.8:
		await process_frame
	await process_frame


func wait_clock(pres, sec: float) -> void:
	var until: float = pres.clock + sec
	while pres.clock < until:
		await process_frame
	await process_frame


func param(name: String):
	return game.guest_ui.presenter.portrait_material.get_shader_parameter(name)


func _run() -> void:
	root.size = Vector2i(1774, 887)
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await frames(12)
	game.session.set_process(false)
	var ui = game.guest_ui
	var pres = ui.presenter

	var shader = load(SHADER)
	check("셰이더 파일이 있고 코드가 비어 있지 않음", shader is Shader and not shader.get_code().is_empty())
	var code: String = shader.get_code() if shader is Shader else ""
	for u in ["motion_time", "appear", "idle_amount", "chest_amount", "chest_center", "chest_radius", "head_center"]:
		check("셰이더 uniform %s" % u, code.contains("uniform") and code.contains(" %s" % u))
	check("대화 창 초상에 모션 셰이더 재질이 걸림", pres.portrait.material is ShaderMaterial and pres.portrait.material.shader == shader)
	check("도착 소개 초상(compact)에도 같은 셰이더", game.guest_arrival.portrait.material is ShaderMaterial and game.guest_arrival.portrait.material.shader == shader)

	# ── 에린: 프로필 모션 값이 실리고 등장 시간이 흐른다
	var erin_profile: Dictionary = Profiles.guest_profile("erin")
	check("에린 프로필에 portrait_motion", erin_profile.has("portrait_motion") and float(erin_profile["portrait_motion"].get("chest", 0.0)) > 0.0)
	await open("erin")
	check("에린과 대화가 열림", ui.dialogue_active and pres.active and pres.portrait.visible)
	# 등장 스케일 트윈: 발끝(하단 중앙) 피벗, 작게 시작해 대화창 배율로(사용자 요청 2026-10-22)
	var P = pres.portrait
	var appear_start: float = float(param("appear"))
	var base: float = pres.portrait_base_scale
	check("등장 피벗이 하단 중앙", P.pivot_offset.is_equal_approx(Vector2(P.size.x * 0.5, P.size.y)), str(P.pivot_offset))
	check("등장 초반 배율이 최종보다 작음", P.scale.x < base - 0.01, "%.3f < %.3f (phase %.2f)" % [P.scale.x, base, pres.phase_time])
	var feet0: Vector2 = P.get_transform() * Vector2(P.size.x * 0.5, P.size.y)
	var peak := 0.0
	var feet_drift := 0.0
	while pres.phase_time < 0.8:
		await process_frame
		peak = maxf(peak, P.scale.x)
		var f: Vector2 = P.get_transform() * Vector2(P.size.x * 0.5, P.size.y)
		feet_drift = maxf(feet_drift, absf(f.y - feet0.y))
	check("등장 내내 발끝 높이 고정(하단 축으로 커짐)", feet_drift < 0.01, "drift %.4f px" % feet_drift)
	check("살짝 넘었다 돌아옴(최대 +3% 이내)", peak > base and peak < base * 1.03, "peak %.4f / base %.3f" % [peak, base])
	await process_frame
	check("등장 뒤 배율이 대화창 배율로 돌아옴", is_equal_approx(P.scale.x, base), "%.4f / %.3f" % [P.scale.x, base])
	var top: Vector2 = P.get_transform() * Vector2(P.size.x * 0.5, 0.0)
	var want_top: Vector2 = pres.portrait_home + Vector2(P.size.x * 0.5, 0.0)
	check("최종 모습이 위쪽 기준 배율 배치와 같음(머리 위치 불변)", top.distance_to(want_top) < 0.05, "%s vs %s" % [top, want_top])
	check("에린: 아이들링 켜짐(idle_amount 1)", is_equal_approx(float(param("idle_amount")), 1.0), str(param("idle_amount")))
	check("에린: 가슴 모핑 켜짐(chest_amount 1)", is_equal_approx(float(param("chest_amount")), 1.0), str(param("chest_amount")))
	check("에린: 가슴 영역 중심이 프로필 값", param("chest_center") == Vector2(0.40, 0.36), str(param("chest_center")))
	var appear0: float = appear_start
	var clock0: float = float(param("motion_time"))
	check("등장 시간이 초상 등장 직후(0~0.4초)", appear0 >= -0.06 and appear0 < 0.4, "appear=%.3f" % appear0)
	await frames(20)
	var appear1: float = float(param("appear"))
	var clock1: float = float(param("motion_time"))
	check("등장 시간이 매 프레임 늘어남(가슴 진동 위상 진행)", appear1 > appear0 + 0.1, "%.3f → %.3f" % [appear0, appear1])
	check("아이들링 시계가 흐름", clock1 > clock0 + 0.1, "%.3f → %.3f" % [clock0, clock1])
	# 같은 대화를 이어가도 등장 시간은 초기화되지 않는다(흔들림은 처음 등장할 때 한 번)
	ui.advance_dialogue()
	await frames(5)
	var appear2: float = float(param("appear"))
	check("대사를 넘겨도 등장 시간이 이어짐(다시 흔들리지 않음)", appear2 > appear1, "%.3f → %.3f" % [appear1, appear2])
	check("초상 재질은 그대로", pres.portrait.material == pres.portrait_material)
	# 아이들링 초상은 등장이 끝난 뒤 통째로 위아래로 떠다니지 않는다(사용자 요청 2026-10-22)
	await until_settled(pres)
	var ey0: float = pres.portrait.position.y
	var c0: float = pres.clock
	await wait_clock(pres, 1.2)
	var ey1: float = pres.portrait.position.y
	check("에린: 등장 뒤 초상 위치 고정(상하 부유 없음)", is_equal_approx(ey0, pres.portrait_home.y + pres.portrait_pivot_shift.y) and is_equal_approx(ey1, ey0), "y %.3f → %.3f, home+shift %.3f, clock %.2f→%.2f" % [ey0, ey1, pres.portrait_home.y + pres.portrait_pivot_shift.y, c0, pres.clock])
	ui.close_conversation(false)
	await frames(3)

	# ── 다른 손님도 모두 아이들링(사용자 요청 2026-10-23, docs/portrait-motion-all.md). 가슴 모핑은 에린만.
	var plain_id: String = Profiles.all_profiles()[0]["id"]
	var p2: Dictionary = Profiles.guest_profile(plain_id)
	game.guest_events._on_batch([p2])
	game.guest_events.admit(p2)
	ui.open_conversation(int(p2["visit_uid"]))
	await frames(6)
	check("일반 손님(%s)과 대화가 열림" % plain_id, ui.dialogue_active and ui.active_uid == int(p2["visit_uid"]))
	check("일반 손님: 아이들링 켜짐(1)", is_equal_approx(float(param("idle_amount")), 1.0), str(param("idle_amount")))
	check("일반 손님: 에린 뒤에도 가슴 모핑은 꺼짐(0)", is_zero_approx(float(param("chest_amount"))), str(param("chest_amount")))
	check("일반 손님: 머리 중심이 인물표 값", param("head_center") == PortraitMotion.HEADS[plain_id], str(param("head_center")))
	await until_settled(pres)
	var gy0: float = pres.portrait.position.y
	await wait_clock(pres, 1.2)
	check("일반 손님: 상하 부유 없음(위치 고정)", is_equal_approx(gy0, pres.portrait_home.y + pres.portrait_pivot_shift.y) and is_equal_approx(pres.portrait.position.y, gy0), "y %.3f → %.3f" % [gy0, pres.portrait.position.y])
	ui.close_conversation(false)
	await frames(3)
	check("guest_arrival 에 상하 부유(bob) 코드가 남지 않음", not FileAccess.get_file_as_string("res://scripts/ui/guest_arrival.gd").contains("sin(clock * 0.7)"))

	# ── 인물표: 모든 손님이 초상·머리 좌표·종족 성격을 가진다
	var heads_ok := 0
	var alpha_ok := 0
	var phases := {}
	var people: Array = Profiles.all_profiles()
	for p in people:
		var m: Dictionary = PortraitMotion.for_profile(p)
		if float(m.get("idle", 0.0)) == 1.0 and is_zero_approx(float(m.get("chest", 0.0))) and PortraitMotion.HEADS.has(p["id"]): heads_ok += 1
		var img: Image = (load(p["portrait"]) as Texture2D).get_image()
		var hc: Vector2 = m.get("head_center", Vector2(-1, -1))
		var px := Vector2i(int(hc.x * img.get_width()), int(hc.y * img.get_height()))
		if px.x >= 0 and px.y >= 0 and px.x < img.get_width() and px.y < img.get_height() and img.get_pixelv(px).a > 0.5: alpha_ok += 1
		phases[snappedf(float(m.get("motion_phase", 0.0)), 0.01)] = true
	check("손님 %d명 모두 아이들링 켜짐·가슴 꺼짐·머리 좌표 있음" % people.size(), heads_ok == people.size(), "%d/%d" % [heads_ok, people.size()])
	check("머리 중심이 모두 초상의 불투명 부분(인물 위)", alpha_ok == people.size(), "%d/%d" % [alpha_ok, people.size()])
	check("숨 박자 위상이 인물마다 흩어짐(30가지 이상)", phases.size() >= 30, str(phases.size()))
	var fairy: Dictionary = PortraitMotion.for_profile(Profiles.character("fern"))
	var goblin: Dictionary = PortraitMotion.for_profile(Profiles.character("graz"))
	var beast: Dictionary = PortraitMotion.for_profile(Profiles.character("fargh"))
	var dwarf: Dictionary = PortraitMotion.for_profile(Profiles.character("harald"))
	var orc: Dictionary = PortraitMotion.for_profile(Profiles.character("garok"))
	check("요정: 날개가 계속 파닥임(accent, burst 0)", float(fairy.get("accent_amount", 0)) > 0.0 and is_zero_approx(float(fairy.get("accent_burst", 1))))
	check("고블린: 귀가 가끔 씰룩(가로, burst 1)", float(goblin.get("accent_amount", 0)) > 0.0 and is_equal_approx(float(goblin.get("accent_burst", 0)), 1.0) and goblin["accent_axis"].x > goblin["accent_axis"].y)
	check("수인: 귀가 가끔 쫑긋(세로, burst 1)", float(beast.get("accent_amount", 0)) > 0.0 and beast["accent_axis"].y > beast["accent_axis"].x)
	check("드워프: 사람보다 덜 흔들림", float(dwarf.get("sway_amount", 1)) < 1.0)
	check("오크: 크고 느린 숨", float(orc.get("breath_amount", 1)) > 1.0 and float(orc.get("breath_rate", 1.8)) < 1.8)
	check("에린 값은 프로필 그대로(성격표가 덮지 않음)", PortraitMotion.for_profile(Profiles.character("erin")) == Profiles.character("erin")["portrait_motion"])

	# 요정 → 사람으로 바뀌면 날개 보조 움직임이 꺼진다(재질 공유 시 값 잔류 없음)
	for id in ["fern", "bram"]:
		var pp: Dictionary = Profiles.guest_profile(id)
		game.guest_events._on_batch([pp])
		game.guest_events.admit(pp)
		ui.open_conversation(int(pp["visit_uid"]))
		await frames(6)
		if id == "fern": check("요정 대화: 날개 uniform 실림", float(param("accent_amount")) > 0.0, str(param("accent_amount")))
		else: check("요정 다음 사람: 날개 uniform 0 으로 복구", is_zero_approx(float(param("accent_amount"))), str(param("accent_amount")))
		ui.close_conversation(false)
		await frames(3)
	for u in ["motion_phase", "breath_amount", "sway_amount", "sway_rate", "head_amount", "accent_amount", "accent_burst"]:
		check("셰이더 uniform %s" % u, code.contains(" %s" % u))

	print("RESULT %d/%d" % [total - failures, total])
	quit(1 if failures > 0 else 0)
