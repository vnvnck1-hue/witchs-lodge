extends SceneTree
## 첫 실행 플로우(FTUE) 실측: 실행 → 시작 손패 → 1일차 낮 → 첫 밤 끝까지, "아무것도 모르는 신규 유저가 조작 없이 지켜볼 때"를
## 그대로 재현해 타임라인을 기록하고, 초반 플로우 보강 목표(docs/first-session-flow-review.md §6)를 PASS/FAIL로 판정한다.
## 판정 항목 중 '목표' 항목은 현재 구현에서 FAIL이 정상이다 — 보강하면서 하나씩 PASS로 바꾸는 인수 기준이다.
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_first_session.gd
## 결과: art_sources/first-session-verify.json (타임라인·관측값·판정)

const Cfg := preload("res://scripts/config.gd")
const SessionScript := preload("res://scripts/game/game_session.gd")
const ChapterData := preload("res://scripts/game/chapter_data.gd")

const SPEED := 4.0
const NIGHT_CAP := 150.0   # 첫 밤이 이 시간(게임 초) 안에 끝나지 않으면 기록을 멈춘다

var main
var failures := 0
var total := 0
var results: Array = []
var timeline: Array = []          # [{t, phase, kind, text}]
var obs := {}
var _seen_toasts := {}
var _sound_cursor := 0
var _last_objective := ""
var _guest_intro_was := false
var _offer_count := 0
var _paused_was := false


func _initialize() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	_run.call_deferred()


func check(name: String, ok: bool, detail := "", goal := false) -> void:
	total += 1
	if not ok:
		failures += 1
	results.append({"check": name, "ok": ok, "detail": detail, "goal": goal})
	print(("PASS " if ok else "FAIL ") + ("[목표] " if goal else "") + name + ("  — " + detail if detail != "" else ""))


func _phase() -> String:
	var s = main.session
	match s.state:
		SessionScript.State.PREP: return "%d일 낮 %05.1fs" % [s.day(), s.prep_elapsed]
		SessionScript.State.COMBAT: return "%d일 밤" % s.wave_index
		SessionScript.State.CLEARING: return "%d일 정리" % s.wave_index
		SessionScript.State.VICTORY: return "승리"
		_: return "패배"


func log_event(kind: String, text: String) -> void:
	var e := {"t": snappedf(main.session.play_time, 0.1), "phase": _phase(), "kind": kind, "text": text}
	timeline.append(e)
	print("  [%6.1f | %-14s] %-8s %s" % [e.t, e.phase, kind, text])


## 매 프레임 상태 변화(토스트·효과음·목표 문구·손님 소개·고용 제안·일시정지)를 타임라인에 쌓는다.
func sample() -> void:
	for p in main.hud.toast_box.get_children():
		if _seen_toasts.has(p.get_instance_id()):
			continue
		_seen_toasts[p.get_instance_id()] = true
		var texts: Array = []
		for l in p.find_children("*", "Label", true, false):
			texts.append(l.text)
		log_event("toast", " ".join(texts))
	var hist: Array = main.sounds.history
	while _sound_cursor < hist.size():
		var ev: String = hist[_sound_cursor]
		_sound_cursor += 1
		if not ev.begins_with("step") and not ev.begins_with("foot") and ev not in ["toast_good", "toast_bad", "ui_hover", "card_hover"]:
			log_event("sound", ev)
	var o: String = main.hud.moon.objective() if main.hud.moon != null else ""
	if o != _last_objective:
		_last_objective = o
		log_event("목표", o)
	var ga: bool = main.guest_arrival.active
	if ga != _guest_intro_was:
		_guest_intro_was = ga
		log_event("손님소개", "시작" if ga else "끝")
	if main.economy.offers.size() != _offer_count:
		_offer_count = main.economy.offers.size()
		log_event("고용제안", "열린 제안 %d개" % _offer_count)
	if paused != _paused_was:
		_paused_was = paused
		log_event("정지", "게임 멈춤" if paused else "게임 재개")


## 스크립트 소스에서 도입 문구 후보가 등장하는 파일 수(승리 화면의 '봉인석을 지켜 냈습니다'는 결말이라 제외).
func _count_in_scripts(dir: String, needles: Array) -> int:
	var n := 0
	for f in DirAccess.get_files_at(dir):
		if f.ends_with(".gd"):
			var src := FileAccess.get_file_as_string(dir + "/" + f)
			for k in needles:
				if k in src:
					n += 1
					break
	for d in DirAccess.get_directories_at(dir):
		n += _count_in_scripts(dir + "/" + d, needles)
	return n


func frames(n: int) -> void:
	for i in n:
		await physics_frame
		sample()


func wait_until(cond: Callable, timeout_real := 30.0) -> bool:
	var start := Time.get_ticks_msec()
	while not cond.call():
		await physics_frame
		sample()
		if Time.get_ticks_msec() - start > timeout_real * 1000.0:
			return false
	return true


func _run() -> void:
	while current_scene == null or current_scene.get("session") == null or current_scene.get("hud") == null:
		await process_frame
	main = current_scene

	# ── 0. 실행 직후(로비·도입 없이 곧장 1일차 낮) ──
	print("── 0. 실행 직후")
	var main_scene: String = ProjectSettings.get_setting("application/run/main_scene", "")
	var scenes := DirAccess.get_files_at("res://scenes")
	obs["main_scene"] = main_scene
	obs["scenes"] = Array(scenes)
	obs["boot_state"] = SessionScript.State.keys()[main.session.state]
	obs["boot_day"] = main.session.day()
	obs["boot_day_progress"] = main.world.day_cycle.progress
	obs["boot_dawn_elapsed"] = main.world.day_cycle._dawn_elapsed
	obs["boot_sun_rotation"] = str(main.world.sun.rotation_degrees)
	obs["boot_gold"] = main.economy.gold
	# 실제 실행에서는 main._ready()가 session.start() 직후 시작 손패 화면을 연다(--script 실행에서는 생략되므로 같은 순서로 직접 연다)
	main.grant_starter_cards(true)
	sample()
	obs["boot_toasts"] = timeline.filter(func(e): return e.kind == "toast").map(func(e): return e.text)

	check("실행 즉시 게임 장면(main.tscn)으로 들어간다 — 현재 동작", main_scene == "res://scenes/main.tscn")
	check("타이틀/로비 장면이 있다", scenes.has("title.tscn") or scenes.has("lobby.tscn") or main_scene != "res://scenes/main.tscn",
		"scenes/=%s" % ", ".join(scenes), true)
	check("첫 프레임에 이미 1일차 낮(PREP)이 시작돼 있다 — 현재 동작", main.session.state == SessionScript.State.PREP and main.session.day() == 1)
	check("1일차 아침이 새벽빛에서 밝아진다(새벽 전환 진행 중)", main.world.day_cycle._dawn_elapsed < 12.0,
		"dawn_elapsed=%.1f progress=%.2f(0=한낮) — 첫 PREP 진입 신호가 day_cycle 연결보다 먼저 나서 새벽 전환을 건너뜀" % [main.world.day_cycle._dawn_elapsed, main.world.day_cycle.progress], true)
	check("1일차 시작에 새벽 효과음(dawn)이 울린다", main.sounds.history.has("dawn"), "game_session._enter_prep: wave_index>0 일 때만 재생", true)
	var intro_lines := _count_in_scripts("res://scripts", ["마을에도 도시에도", "봉인석을 지켜야", "봉인석을 지키"])
	check("시작 전에 '누구·어디·왜'(마녀·산장·봉인석)를 알려 주는 도입이 있다", intro_lines > 0, "도입 문구 초안(narrative.md §1)이 실행판 어디에도 없다", true)

	# ── 1. 시작 손패(멀리건) ──
	print("── 1. 시작 손패")
	check("시작 손패 화면이 바로 열리고 게임이 멈춘다 — 현재 동작", main.mulligan_ui.active and paused)
	var boot_toast_count: int = obs["boot_toasts"].size()
	check("멀리건 뒤에 가려진 채 사라지는 시작 알림이 없다", boot_toast_count == 0,
		"멀리건이 열리기 전에 뜬 알림 %d개(HUD는 정지 중에도 돌아 2.4초 뒤 사라짐): %s" % [boot_toast_count, " / ".join(obs["boot_toasts"])], true)
	var prep_before: float = main.session.prep_elapsed
	var deal_start := Time.get_ticks_msec()
	await wait_until(func(): return main.mulligan_ui._phase == "pick", 15.0)
	obs["mulligan_deal_sec"] = (Time.get_ticks_msec() - deal_start) / 1000.0
	obs["mulligan_offered"] = main.mulligan_ui.offered.map(func(e): return e["id"])
	obs["mulligan_title"] = main.mulligan_ui.title.text
	obs["mulligan_hint"] = main.mulligan_ui.hint.text
	await frames(30)
	check("멀리건 중에는 낮 타이머가 흐르지 않는다 — 현재 동작", is_equal_approx(main.session.prep_elapsed, prep_before))
	main.mulligan_ui.confirm()
	await wait_until(func(): return not main.mulligan_ui.active, 15.0)
	await frames(5)
	obs["hand_after_mulligan"] = main.cards.hand().map(func(e): return e["id"])
	obs["pocket_after_mulligan"] = main.cards.pocket().size()
	log_event("메모", "멀리건 확정 — 손패 %s, 주머니 %d장" % [str(obs["hand_after_mulligan"]), obs["pocket_after_mulligan"]])

	# ── 2. 1일차 낮(조작 없이 지켜봄) ──
	print("── 2. 1일차 낮")
	Engine.time_scale = SPEED
	var t_free: float = main.session.prep_elapsed
	var first_arrival := -1.0
	var first_offer := -1.0
	var intro_overlap_night := false
	var toasts_by_10s := {}
	while main.session.state == SessionScript.State.PREP:
		await physics_frame
		sample()
		var pe: float = main.session.prep_elapsed
		if first_arrival < 0.0 and main.guest_arrival.active:
			first_arrival = pe
		if first_offer < 0.0 and not main.economy.offers.is_empty():
			first_offer = pe
		# (-- --scenario=hire): 고용 제안이 뜨면 바로 고용하고, 받은 계약 카드는 산장 앞에 바로 쓴다(의도된 정답 플레이의 최소형)
		if OS.get_cmdline_user_args().has("--scenario=hire") and not main.economy.offers.is_empty():
			var o: Dictionary = main.economy.offers[0]
			if main.economy.hire(o):
				log_event("메모", "비교 시나리오: 고용 — %s" % str(o.get("job", o.get("name", "?"))))
				await frames(3)
				for e in main.cards.hand():
					if e["id"] in Cfg.JOB_CARDS:
						var spot: Vector3 = preload("res://scripts/world/layout.gd").DOOR_FRONT + Vector3(1.5, 0, 1.5)
						var r: Dictionary = main.resolver.commit(e["uid"], main.world.camera.unproject_position(spot))
						log_event("메모", "계약 카드 %s 사용 → %s" % [e["id"], str(r.get("ok", r))])
	obs["first_guest_intro_at"] = first_arrival
	obs["first_offer_at"] = first_offer
	obs["prep_time"] = Cfg.PREP_TIME
	var day_toasts := timeline.filter(func(e): return e.kind == "toast" and e.phase.begins_with("1일 낮"))
	obs["day1_toast_count"] = day_toasts.size()
	var idle_until := first_arrival if first_arrival >= 0.0 else Cfg.PREP_TIME
	check("낮이 시작되고 할 일이 생기기까지의 공백이 3초 이하", idle_until - t_free <= 3.0,
		"첫 손님 소개 %.1fs — 그 전 '손님을 맞이하세요'만 표시, 양털도 1일차엔 없음" % idle_until, true)
	check("첫 손님 소개가 낮 타이머를 멈추거나 별도 시간으로 보장된다", false,
		"손님 소개(guest_arrival)는 PAUSABLE·비정지 — 소개가 도는 동안 90초 타이머가 그대로 흐른다", true)

	# ── 3. 첫 밤 ──
	print("── 3. 첫 밤(조작 없음)")
	var night_toasts_start := timeline.size()
	var night_start: float = main.session.play_time
	# 비교 시나리오(-- --scenario=guard): 밤이 되자마자 마녀를 산장 문 앞으로 보낸다(H 키와 같은 동작)
	# (-- --scenario=chase): 카드·고용 없이 마녀가 가장 가까운 괴물에게 계속 걸어가 기본 공격만 한다(최소한의 능동 플레이)
	var guard := OS.get_cmdline_user_args().has("--scenario=guard")
	var chase := OS.get_cmdline_user_args().has("--scenario=chase")
	obs["scenario"] = "guard" if guard else ("chase" if chase else ("hire" if OS.get_cmdline_user_args().has("--scenario=hire") else "idle"))
	if guard:
		main.player.set_destination(preload("res://scripts/world/layout.gd").DOOR_FRONT)
		log_event("메모", "비교 시나리오: 마녀를 산장 문 앞으로 이동")
	if chase:
		log_event("메모", "비교 시나리오: 마녀가 가장 가까운 괴물을 쫓아 기본 공격")
	while main.session.state == SessionScript.State.COMBAT and main.session.play_time - night_start <= NIGHT_CAP:
		await physics_frame
		sample()
		if chase and Engine.get_physics_frames() % 15 == 0:
			var best = null
			var bd := INF
			for e in main.get_tree().get_nodes_in_group("enemies"):
				var d: float = e.global_position.distance_to(main.player.global_position)
				if d < bd:
					bd = d
					best = e
			if best != null and bd > 3.0:
				main.player.set_destination(best.global_position)
	var first_night := timeline.filter(func(e): return e.phase == "1일 밤")
	var night_t0: float = first_night[0].t if not first_night.is_empty() else night_start
	var simultaneous := first_night.filter(func(e): return e.kind == "toast" and e.t - night_t0 < 0.5)
	obs["night1_open_toasts"] = simultaneous.map(func(e): return e.text)
	obs["night1_result"] = SessionScript.State.keys()[main.session.state]
	obs["night1_lodge_hp"] = main.world.lodge.hp
	obs["night1_player_hp"] = main.player.hp
	obs["night1_sheep_lost"] = main.sheep_lost
	obs["night1_duration"] = main.session.play_time - night_start
	check("첫 밤 진입이 전용 연출(해 짐·경고 배너)로 구분된다", false,
		"밤 시작 0.5초 안에 토스트 %d개가 한꺼번에: %s" % [simultaneous.size(), " / ".join(obs["night1_open_toasts"])], true)
	check("아무 조작 없이도 첫 밤은 넘길 수 있다(튜토리얼 밤 난이도)", main.session.state in [SessionScript.State.CLEARING, SessionScript.State.PREP],
		"결과=%s %.0f초 산장 %.0f/%.0f 마녀 %.0f 잃은 양 %d" % [obs["night1_result"], obs["night1_duration"], obs["night1_lodge_hp"], main.world.lodge.max_hp, obs["night1_player_hp"], obs["night1_sheep_lost"]], true)
	if main.session.state == SessionScript.State.DEFEAT:
		await frames(5)
		obs["defeat_body"] = main.hud.end_body.text.get_slice("\n\n", 0)
		var first_seal: Array = timeline.filter(func(e): return "봉인석" in e.text)
		check("'봉인석'이 패배 화면보다 먼저 플레이어에게 소개된다", not first_seal.is_empty(),
			"패배 문구: %s" % obs["defeat_body"].replace("\n", " "), true)
		check("패배 화면이 원인과 다음 대처(산장 근처 방어 등)를 알려 준다", "지키" in obs["defeat_body"] or "방어" in obs["defeat_body"] or "팁" in obs["defeat_body"],
			"현재: 원인 한 줄 + 통계, 버튼은 '새 게임'(장면 재로드 → 다시 멀리건)뿐", true)

	# ── 4. 2일차 아침(비교: 둘째 날부터는 새벽 전환이 있다) ──
	if main.session.state == SessionScript.State.CLEARING:
		await wait_until(func(): return main.session.state != SessionScript.State.CLEARING, 30.0)
	if main.session.state == SessionScript.State.PREP:
		await frames(2)
		obs["day2_dawn_elapsed"] = main.world.day_cycle._dawn_elapsed
		obs["day2_progress"] = main.world.day_cycle.progress
		check("2일차 아침은 새벽 전환이 돈다 — 현재 동작(1일차와 비교)", main.world.day_cycle._dawn_elapsed < 12.0,
			"dawn_elapsed=%.2f progress=%.2f" % [main.world.day_cycle._dawn_elapsed, main.world.day_cycle.progress])
		await frames(10)
		obs["day2_toasts"] = timeline.filter(func(e): return e.kind == "toast" and e.phase.begins_with("2일 낮")).map(func(e): return e.text)
	Engine.time_scale = 1.0

	var out := {"passed": failures == 0, "checks": total, "failures": failures, "observations": obs, "results": results, "timeline": timeline}
	var f := FileAccess.open("res://art_sources/first-session-verify%s.json" % ("" if obs["scenario"] == "idle" else "-" + obs["scenario"]), FileAccess.WRITE)
	f.store_string(JSON.stringify(out, "\t") + "\n")
	print("FIRST_SESSION observations=", JSON.stringify(obs))
	print("RESULT %d/%d" % [total - failures, total])
	quit(0 if failures == 0 else 1)
