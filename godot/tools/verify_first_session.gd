extends SceneTree
## 첫 실행 플로우(FTUE) 검증: 타이틀 → 새 이야기 → 마녀 선택 → 프롤로그(건너뛰기) → 1일차 새벽 → '첫째 날' 카드·혼잣말 →
## 시작 손패(멀리건) → 첫 고용 튜토리얼(정지·시간 제한 없음) → 계약 카드 배치 → 단계형 목표를 따라 첫 밤 생존 → 2일차 새벽 →
## 패배 화면(원인별 힌트·다시 도전·타이틀로) → 다시 도전(프롤로그 없이 새벽부터) → 타이틀로 → main.tscn 직행(기존 검증 경로) 호환.
## 보강 전 실측과 인수 기준은 docs/first-session-flow-review.md §1~§6, 구현 결과는 §9.
## '[목표]' 줄은 보강 인수 기준(§6)이고, 나머지는 흐름이 이어지는지 보는 확인 항목이다.
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_first_session.gd
##   -- --scenario=idle : 튜토리얼을 이미 본 두 번째 판에서 아무 조작 없이 첫 밤을 맞는다(실제 패배 → 패배 힌트 확인)
## 결과: art_sources/first-session-verify.json (타임라인·관측값·판정). 사용자 튜토리얼 기록 대신 user://ftue-verify.cfg 를 쓴다.

const Cfg := preload("res://scripts/config.gd")
const SessionScript := preload("res://scripts/game/game_session.gd")
const Flow := preload("res://scripts/game/flow.gd")
const Layout := preload("res://scripts/world/layout.gd")

const SPEED := 4.0
const NIGHT_CAP := 150.0   # 첫 밤이 이 시간(게임 초) 안에 끝나지 않으면 기록을 멈춘다

var main
var title
var failures := 0
var total := 0
var results: Array = []
var timeline: Array = []          # [{t, phase, kind, text}]
var obs := {}
var scenario := "follow"
var _seen_toasts := {}
var _sound_cursor := 0
var _last_objective := ""
var _guest_intro_was := false
var _offer_count := 0
var _paused_was := false
var _banner_count := 0
var _stage_was := ""


func _initialize() -> void:
	if OS.get_cmdline_user_args().has("--scenario=idle"):
		scenario = "idle"
	Flow.ftue_path = "user://ftue-verify.cfg"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Flow.ftue_path))
	if scenario == "idle":
		Flow.set_tutorial_done(true)
	change_scene_to_file(ProjectSettings.get_setting("application/run/main_scene", ""))
	_run.call_deferred()


func check(name: String, ok: bool, detail := "", goal := false) -> void:
	total += 1
	if not ok:
		failures += 1
	results.append({"check": name, "ok": ok, "detail": detail, "goal": goal})
	print(("PASS " if ok else "FAIL ") + ("[목표] " if goal else "") + name + ("  — " + detail if detail != "" else ""))


func _phase() -> String:
	if main == null or not is_instance_valid(main):
		return "타이틀"
	var s = main.session
	if main.opening != null and main.opening.active:
		return "도입 " + main.opening.phase
	match s.state:
		SessionScript.State.PREP: return "%d일 낮 %05.1fs" % [s.day(), s.prep_elapsed]
		SessionScript.State.COMBAT: return "%d일 밤" % s.wave_index
		SessionScript.State.CLEARING: return "%d일 정리" % s.wave_index
		SessionScript.State.VICTORY: return "승리"
		_: return "패배"


func log_event(kind: String, text: String) -> void:
	var t := 0.0
	if main != null and is_instance_valid(main):
		t = snappedf(main.session.play_time, 0.1)
	var e := {"t": t, "phase": _phase(), "kind": kind, "text": text}
	timeline.append(e)
	print("  [%6.1f | %-14s] %-8s %s" % [e.t, e.phase, kind, text])


## 매 프레임 상태 변화(토스트·효과음·목표 문구·배너·튜토리얼 단계·손님 소개·고용 제안·일시정지)를 타임라인에 쌓는다.
func sample() -> void:
	if main == null or not is_instance_valid(main) or main.hud == null or main.hud.toast_box == null:
		return
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
		if not ev.begins_with("step") and not ev.begins_with("foot") and ev not in ["toast_good", "toast_bad", "ui_hover", "card_hover", "btn_hover"]:
			log_event("sound", ev)
	var o: String = main.hud.moon.objective() if main.hud.moon != null else ""
	if o != _last_objective:
		_last_objective = o
		log_event("목표", o)
	var bh: Array = main.banner.history
	while _banner_count < bh.size():
		var b: Dictionary = bh[_banner_count]
		_banner_count += 1
		log_event("배너", "%s / %s / %s" % [b.head, b.sub, b.detail])
	if main.tutorial.stage != _stage_was:
		_stage_was = main.tutorial.stage
		log_event("튜토리얼", _stage_was)
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


func _scene_is(path: String) -> bool:
	return current_scene != null and current_scene.scene_file_path == path


func _wait_main() -> void:
	await wait_until(func(): return _scene_is(Flow.GAME_SCENE) and current_scene.get("session") != null and current_scene.get("hud") != null, 30.0)
	main = current_scene
	_seen_toasts.clear()
	_sound_cursor = 0
	_banner_count = 0
	_stage_was = ""


func _key(code: Key) -> void:
	for pressed in [true, false]:
		var ev := InputEventKey.new()
		ev.keycode = code
		ev.physical_keycode = code
		ev.pressed = pressed
		Input.parse_input_event(ev)
	await frames(2)


func _click(at: Vector2) -> void:
	for pressed in [true, false]:
		var ev := InputEventMouseButton.new()
		ev.button_index = MOUSE_BUTTON_LEFT
		ev.position = at
		ev.global_position = at
		ev.pressed = pressed
		root.push_input(ev, true)   # 화면(캔버스) 좌표 그대로. 헤드리스에서는 OS 마우스 입력 대신 뷰포트에 직접 넣는다(GUI → unhandled 경로 동일)
	await frames(2)


## 손패의 계약 카드를 산장 앞 자리에 쓴다(드래그 놓기와 같은 판정 경로).
func _place_job_card() -> bool:
	for e in main.cards.hand():
		if e["id"] in Cfg.JOB_CARDS:
			var r: Dictionary = main.resolver.commit(e["uid"], main.world.camera.unproject_position(main.tutorial.place_spot))
			log_event("메모", "계약 카드 %s 배치 → %s" % [e["id"], str(r.get("ok", r))])
			return bool(r.get("ok", false))
	return false


func _run() -> void:
	# ── 0. 타이틀 ──
	print("── 0. 타이틀 (시나리오: %s)" % scenario)
	await wait_until(func(): return _scene_is(Flow.TITLE_SCENE) and current_scene.get("menu") != null, 20.0)
	title = current_scene
	var main_scene: String = ProjectSettings.get_setting("application/run/main_scene", "")
	obs["main_scene"] = main_scene
	check("[1] 실행하면 타이틀 장면으로 시작한다", main_scene == Flow.TITLE_SCENE and _scene_is(Flow.TITLE_SCENE), main_scene, true)
	var labels: Array = title.menu.get_children().map(func(b): return b.text)
	obs["title_menu"] = labels
	check("[1] 타이틀 메뉴: 새 이야기·이어하기·설정·끝내기", labels == ["새 이야기", "이어하기", "설정", "끝내기"], str(labels), true)
	check("[1] 이어하기는 비활성(저장 기능 제외)", title.continue_btn.disabled)
	check("[1] 타이틀 배경이 있다(그림 또는 밤 산장 플레이스홀더)", title.bg != null and title.bg.visible, title.bg.get_class() if title.bg != null else "없음")
	title._open_settings()
	await frames(2)
	var sliders: Array = title.settings_panel.find_children("Volume_*", "HSlider", true, false)
	check("[1] 타이틀 설정이 기존 소리 설정(전체·배경음·효과음·음소거)을 재사용한다", sliders.size() == 3 and title.settings_parts.mute_toggle != null, "슬라이더 %d개" % sliders.size(), true)
	check("[1] 타이틀 설정에 화면(전체 화면/디스플레이)·튜토리얼 다시 보기가 있다", title.settings_panel.find_child("DisplaySettings", true, false).get_child_count() > 0 and title.tutorial_toggle != null)
	check("[4] 첫 실행에서는 '튜토리얼 다시 보기'가 켜진 상태(아직 보지 않음)", title.tutorial_toggle.button_pressed == (scenario != "idle"))
	title.close_settings()
	title._open_select()
	await frames(2)
	check("[1] 새 이야기 → 네 마녀 선택(4칸)", title.select_panel.visible and title.slot_buttons.size() == 4)
	var locked_ok: bool = not title.select_witch(1) and not title.select_witch(2) and not title.select_witch(3)
	check("[1] 잠긴 세 칸은 고를 수 없고 '?'로 표시된다", locked_ok and title.WITCHES.slice(1).all(func(w): return w[1] == "?"), title.select_note.text)
	check("[1] 이름 없는 '마녀' 한 칸만 고를 수 있다", title.select_witch(0) and not title.start_btn.disabled and title.WITCHES[0][1] == "마녀")
	title.start_story()

	# ── 1. 프롤로그 ──
	print("── 1. 프롤로그")
	await _wait_main()
	await frames(3)
	var op = main.opening
	check("[2] 새 이야기로 들어오면 도입 연출이 열린다", op != null and op.with_prologue, "opening=%s" % str(op != null))
	if op == null:
		_finish()
		return
	check("[2] 프롤로그가 재생되는 동안 게임이 멈춰 있다", op.phase == "prologue" and op.prologue.active and paused)
	var prep0: float = main.session.prep_elapsed
	obs["boot_dawn_elapsed"] = main.world.day_cycle._dawn_elapsed
	check("[3] 프롤로그 뒤 1일차는 밤빛에서 시작한다(새벽 전환 대기)", main.world.day_cycle._dawn_elapsed == 0.0, "dawn_elapsed=%.1f progress=%.2f" % [main.world.day_cycle._dawn_elapsed, main.world.day_cycle.progress], true)
	check("[3] 프롤로그 중에는 새벽음이 아직 울리지 않는다", not main.sounds.history.has("dawn"))
	obs["prologue_first"] = op.prologue.caption.text
	await frames(20)
	await _key(KEY_SPACE)   # 다음 장
	check("[2] Space/클릭으로 다음 장으로 넘어간다", op.prologue.index == 1, "index=%d" % op.prologue.index)
	await _click(Vector2(400, 300))
	check("[2] 클릭으로도 다음 장으로 넘어간다", op.prologue.index == 2, "index=%d" % op.prologue.index)
	var captions: String = "\n".join(op.prologue.shown_captions)
	await _key(KEY_ESCAPE)   # 건너뛰기
	await wait_until(func(): return op.phase != "prologue", 5.0)
	obs["prologue_captions"] = op.prologue.shown_captions
	obs["prologue_placeholder"] = op.prologue.placeholder_used
	check("[2] Esc로 프롤로그를 건너뛴다", op.phase == "dawn", "phase=%s" % op.phase, true)
	var all_text: String = "\n".join(op.prologue.SLIDES.map(func(s): return s[1]))
	check("[2] 프롤로그가 마녀사냥·숲속 산장·봉인석·낮 손님/밤 괴물을 알린다", "마녀사냥" in all_text and "산장" in all_text and "봉인석" in all_text and "낮에는" in all_text and "밤이면" in all_text, "", true)
	check("[2] 프롤로그는 일러스트 3~4장", op.prologue.SLIDES.size() >= 3 and op.prologue.SLIDES.size() <= 4, "%d장 · 플레이스홀더 사용=%s" % [op.prologue.SLIDES.size(), str(op.prologue.placeholder_used)])
	check("[2] 프롤로그 중 낮 타이머가 흐르지 않는다", is_equal_approx(main.session.prep_elapsed, prep0))

	# ── 2. 1일차 새벽 → 첫째 날 카드 → 혼잣말 → 시작 손패 ──
	print("── 2. 1일차 새벽")
	await frames(5)
	check("[3] 1일차에도 새벽음(dawn)이 울린다", main.sounds.history.has("dawn"), "", true)
	var dawn_a: float = main.world.day_cycle._dawn_elapsed
	var prog_a: float = main.world.day_cycle.progress
	await frames(30)
	check("[3] 1일차 아침이 새벽빛(밤)에서 밝아진다", main.world.day_cycle._dawn_elapsed > dawn_a and main.world.day_cycle.progress < prog_a and prog_a > 0.6,
		"dawn %.2f→%.2f progress %.2f→%.2f" % [dawn_a, main.world.day_cycle._dawn_elapsed, prog_a, main.world.day_cycle.progress], true)
	var opened_mulligan := await wait_until(func(): return main.mulligan_ui.active, 15.0)
	var before_mull := timeline.filter(func(e): return e.phase.begins_with("도입"))
	var day_banner := before_mull.filter(func(e): return e.kind == "배너")
	var dawn_idx := before_mull.map(func(e): return e.kind == "sound" and e.text == "dawn").find(true)
	obs["day1_card"] = day_banner.map(func(e): return e.text)
	obs["monologue"] = op.monologue_shown
	check("[3] '첫째 날' 타이틀 카드에 오늘 밤 예고가 들어 있다", not day_banner.is_empty() and "첫째 날" in day_banner[0].text and "오늘 밤" in day_banner[0].text, str(obs["day1_card"]), true)
	check("[3] 마녀의 첫 혼잣말 한 줄이 나온다", op.monologue_shown != "", op.monologue_shown, true)
	check("[3] 순서: 새벽음 → 타이틀 카드 → 시작 손패", opened_mulligan and dawn_idx >= 0 and before_mull.find(day_banner[0] if not day_banner.is_empty() else {}) > dawn_idx)
	var boot_toasts := timeline.filter(func(e): return e.kind == "toast")
	obs["boot_toasts"] = boot_toasts.map(func(e): return e.text)
	check("[3] 멀리건 뒤에 가려지는 시작 알림이 없다('오늘 밤' 토스트는 타이틀 카드로)", boot_toasts.is_empty(), " / ".join(obs["boot_toasts"]), true)
	check("시작 손패 화면이 열리고 게임이 멈춘다", main.mulligan_ui.active and paused)
	await wait_until(func(): return main.mulligan_ui._phase == "pick", 15.0)
	check("[3] 멀리건은 지금처럼 교체를 허용한다", main.mulligan_ui.confirm_btn.visible and main.mulligan_ui.offered.size() == Cfg.STARTER_DRAW)
	main.mulligan_ui.toggle(0)   # 한 장 교체
	main.mulligan_ui.confirm()
	await wait_until(func(): return not main.mulligan_ui.active, 15.0)
	await frames(5)
	check("도입이 끝나고 게임이 재개된다", not op.active and not paused, "phase=%s paused=%s" % [op.phase, str(paused)])
	obs["hand_after_mulligan"] = main.cards.hand().map(func(e): return e["id"])

	# ── 3. 1일차 낮: 고용 튜토리얼 ──
	print("── 3. 1일차 낮")
	Engine.time_scale = SPEED
	var tut = main.tutorial
	if scenario == "follow":
		check("[4] 첫 판이면 튜토리얼이 손님을 기다린다", tut.stage == "wait_offer", tut.stage)
		check("[5] 목표 문구가 단계형으로 시작한다(① 손님 맞이)", main.hud.moon.objective().begins_with("①"), main.hud.moon.objective(), true)
		await wait_until(func(): return tut.stage != "wait_offer" or main.session.state != SessionScript.State.PREP, 40.0)
		Engine.time_scale = 1.0
		await frames(3)
		obs["hire_offer_person"] = tut.offer.get("person", "")
		obs["hire_offer_at"] = main.session.prep_elapsed
		check("[4] 첫 고용 제안에서 게임이 멈추고 안내가 뜬다", tut.stage == "hire" and paused and tut.panel.visible, "%s · %s · %.1fs" % [tut.stage, obs["hire_offer_person"], main.session.prep_elapsed], true)
		check("[4] 첫 고용 손님은 브람", obs["hire_offer_person"] == "브람", obs["hire_offer_person"])
		var o: Dictionary = tut.offer
		var prep_h: float = main.session.prep_elapsed
		await frames(int(Cfg.HIRE_WAIT * 60.0) + 60)   # 실제 시간으로 HIRE_WAIT보다 오래 기다린다
		check("[4] 첫 고용 제안은 시간 제한 없이 남아 있다", o in main.economy.offers and tut.stage == "hire" and is_equal_approx(main.session.prep_elapsed, prep_h),
			"%.0f초 대기 후 제안 %s, 낮 시간 %.1f→%.1f" % [Cfg.HIRE_WAIT + 1.0, str(o in main.economy.offers), prep_h, main.session.prep_elapsed], true)
		check("[5] 목표 ②(고용)", main.hud.moon.objective().begins_with("②"), main.hud.moon.objective())
		var g = o.get("guest")
		var at: Vector2 = tut.guest_screen_pos(g) if is_instance_valid(g) else Vector2.ZERO
		obs["hire_click_at"] = str(at)
		await _click(at)   # 손님 머리 위 클릭(정지 중에도 튜토리얼이 받는다)
		var clicked: bool = tut.stage == "place"
		if not clicked:
			log_event("메모", "클릭이 다른 UI에 가로막혀 버튼으로 고용")
			tut.hire_now()
			await frames(3)
		check("[4] 정지 중에도 손님 클릭으로 고용된다", clicked, "클릭 위치 %s" % obs["hire_click_at"])
		check("[4] 고용 후 '계약 카드를 산장 앞에' 강제 단계 — 게임은 움직이되 낮 시계는 멈춤", tut.stage == "place" and not paused and tut.panel.visible, "", true)
		var prep_p: float = main.session.prep_elapsed
		await frames(90)
		check("[4] 배치 전까지 낮 시계가 멈춘다", is_equal_approx(main.session.prep_elapsed, prep_p), "%.2f→%.2f" % [prep_p, main.session.prep_elapsed])
		check("[5] 목표 ③(계약 카드 배치)", main.hud.moon.objective().begins_with("③"), main.hud.moon.objective())
		var placed := _place_job_card()
		await frames(5)
		check("[4] 계약 카드를 배치하면 튜토리얼이 풀리고 기록된다", placed and tut.stage == "done" and Flow.tutorial_done() and not tut.panel.visible, "stage=%s flag=%s" % [tut.stage, str(Flow.tutorial_done())], true)
		check("[5] 목표 ④(밤 대비)", main.hud.moon.objective().begins_with("④"), main.hud.moon.objective())
		check("[4] 1일차 밤 난이도는 그대로(챕터 1일차 = 습격의 밤)", main.chapter.day_cfg(1).get("night", "normal") == "normal")
		Engine.time_scale = SPEED
	else:
		check("[4] 튜토리얼을 본 판에서는 강제 단계가 없다", tut.stage == "off", tut.stage)
	# 나머지 낮: 단계형 목표를 따른다(follow) — ②가 뜨면 고용, ③이면 계약 카드 배치. idle은 아무것도 하지 않는다.
	while main.session.state == SessionScript.State.PREP:
		await physics_frame
		sample()
		if scenario == "follow" and not main.economy.offers.is_empty() and main.hud.moon.objective().begins_with("②"):
			var o2: Dictionary = main.economy.offers[0]
			if main.economy.hire(o2):
				log_event("메모", "목표 ②를 따라 고용 — %s" % o2.get("person", "?"))
				await frames(3)
				_place_job_card()
	if scenario == "idle":
		check("[4] 튜토리얼을 본 판의 고용 제안은 원래대로 10초", main.economy.offers.is_empty())

	# ── 4. 첫 밤 ──
	print("── 4. 첫 밤")
	var night_start: float = main.session.play_time
	await frames(3)
	var night_banner := timeline.filter(func(e): return e.kind == "배너" and e.phase == "1일 밤")
	var first_night := timeline.filter(func(e): return e.phase == "1일 밤")
	var night_t0: float = first_night[0].t if not first_night.is_empty() else night_start
	var night_toasts := first_night.filter(func(e): return e.kind == "toast" and e.t - night_t0 < 0.5)
	obs["night1_banner"] = night_banner.map(func(e): return e.text)
	obs["night1_open_toasts"] = night_toasts.map(func(e): return e.text)
	check("[5] 밤 진입이 가운데 배너 하나로 알려진다(중복 토스트 없음)", night_banner.size() == 1 and "첫째 밤" in night_banner[0].text and night_toasts.is_empty(),
		"배너 %s · 토스트 %s" % [str(obs["night1_banner"]), str(obs["night1_open_toasts"])], true)
	while main.session.state == SessionScript.State.COMBAT and main.session.play_time - night_start <= NIGHT_CAP:
		await physics_frame
		sample()
	obs["night1_result"] = SessionScript.State.keys()[main.session.state]
	obs["night1_lodge_hp"] = main.world.lodge.hp
	obs["night1_player_hp"] = main.player.hp
	obs["night1_duration"] = main.session.play_time - night_start
	obs["mercs_hired"] = main.cards.stats["hired"]
	var survived: bool = main.session.state in [SessionScript.State.CLEARING, SessionScript.State.PREP]
	var detail := "결과=%s %.0f초 산장 %.0f/%.0f 마녀 %.0f 고용 %d명" % [obs["night1_result"], obs["night1_duration"], obs["night1_lodge_hp"], main.world.lodge.max_hp, obs["night1_player_hp"], obs["mercs_hired"]]
	if scenario == "follow":
		check("[4] 튜토리얼·단계형 목표를 따르면 첫 밤을 넘긴다(난이도 하향 없음)", survived, detail, true)
	else:
		check("아무 조작 없는 두 번째 판은 첫 밤에 진다(난이도 그대로)", not survived, detail)

	# ── 5. 2일차 아침 ──
	if main.session.state == SessionScript.State.CLEARING:
		await wait_until(func(): return main.session.state != SessionScript.State.CLEARING, 30.0)
	if main.session.state == SessionScript.State.PREP:
		await frames(2)
		obs["day2_dawn_elapsed"] = main.world.day_cycle._dawn_elapsed
		check("2일차 아침도 새벽 전환이 돈다", main.world.day_cycle._dawn_elapsed < 12.0, "dawn_elapsed=%.2f" % main.world.day_cycle._dawn_elapsed)
		await frames(10)
		obs["day2_toasts"] = timeline.filter(func(e): return e.kind == "toast" and e.phase.begins_with("2일 낮")).map(func(e): return e.text)
		check("2일차는 '오늘 밤' 토스트가 그대로 뜬다", obs["day2_toasts"].any(func(t): return "오늘 밤" in t), str(obs["day2_toasts"]))
	Engine.time_scale = 1.0

	# ── 6. 패배 화면 ──
	print("── 6. 패배 화면")
	if main.session.state != SessionScript.State.DEFEAT:
		main.world.lodge.take_damage(99999.0)   # 원인별 힌트 확인용 강제 패배(산장 붕괴)
		await frames(5)
	var hud = main.hud
	obs["defeat_body"] = hud.end_body.text.get_slice("\n\n", 0)
	obs["defeat_hint"] = hud.end_hint.text
	# 프롤로그를 건너뛰어도 첫째 날 카드·첫 고용 안내가 봉인석을 말한다
	var seal_first := timeline.filter(func(e): return "봉인석" in e.text and e.phase != "패배")
	var seal_where: String = (seal_first[0].phase + " " + seal_first[0].kind) if not seal_first.is_empty() else "없음"
	check("[2] '봉인석'이 패배 화면보다 먼저 소개된다(프롤로그를 건너뛰어도)", not seal_first.is_empty() and op.prologue.SLIDES.any(func(s): return "봉인석" in s[1]), "처음 등장: " + seal_where, true)
	check("[5] 패배 화면이 원인별 다음 행동을 알려 준다(산장 붕괴 → 용병을 산장 앞에)", hud.end_panel.visible and "고용" in hud.end_hint.text and "산장 앞" in hud.end_hint.text, hud.end_hint.text, true)
	check("[5] 마녀가 쓰러진 경우의 힌트도 따로 있다", "산장 곁" in hud.defeat_hint("마녀가 쓰러졌습니다"), hud.defeat_hint("마녀가 쓰러졌습니다"))
	check("[1] 패배/승리 화면에 '다시 도전'·'타이틀로'", hud.retry_btn.text == "다시 도전" and hud.title_btn.text == "타이틀로" and hud.retry_btn.is_visible_in_tree(), "", true)
	var pause_labels: Array = hud.pause_panel.find_children("*", "Button", true, false).map(func(b): return b.text)
	check("[1] 일시정지 메뉴에 '타이틀로'", "타이틀로" in pause_labels, str(pause_labels.filter(func(t): return t in ["새 게임", "타이틀로", "종료"])), true)

	# ── 7. 다시 도전(프롤로그 없이 새벽부터, 튜토리얼은 이미 봄) ──
	print("── 7. 다시 도전")
	hud.retry_btn.pressed.emit()
	await frames(2)
	await _wait_main()
	await frames(5)
	check("다시 도전은 프롤로그 없이 새벽부터 다시 연다", main.opening != null and not main.opening.with_prologue and main.opening.phase == "dawn", "phase=%s" % (main.opening.phase if main.opening != null else "없음"))
	await wait_until(func(): return main.mulligan_ui.active and main.mulligan_ui._phase == "pick", 20.0)
	main.mulligan_ui.confirm()
	await wait_until(func(): return not main.mulligan_ui.active and not main.opening.active, 15.0)
	await frames(3)
	check("[4] 튜토리얼을 마친 뒤의 판에서는 강제 단계가 없다(단계형 목표만)", main.tutorial.stage == "off" and main.tutorial.guide, main.tutorial.stage)

	# ── 8. 타이틀로 ──
	print("── 8. 타이틀로")
	main.hud._to_title()
	main = null
	await wait_until(func(): return _scene_is(Flow.TITLE_SCENE) and current_scene.get("menu") != null, 20.0)
	check("[1] '타이틀로'로 타이틀 화면에 돌아온다", _scene_is(Flow.TITLE_SCENE) and not paused)
	current_scene._open_settings()
	await frames(2)
	check("[4] 설정 '튜토리얼 다시 보기'는 튜토리얼을 본 뒤 꺼져 있고, 켜면 기록이 지워진다", not current_scene.tutorial_toggle.button_pressed)
	current_scene.tutorial_toggle.button_pressed = true
	check("[4] '튜토리얼 다시 보기'를 켜면 다음 판에 다시 안내한다", not Flow.tutorial_done())

	# ── 9. 기존 검증 경로 호환: main.tscn 직행(--script) ──
	print("── 9. main.tscn 직행 호환")
	change_scene_to_file(Flow.GAME_SCENE)
	await _wait_main()
	await frames(10)
	check("main.tscn 직행(--script)은 도입·프롤로그·튜토리얼 없이 곧장 1일차 낮", main.opening == null and main.session.state == SessionScript.State.PREP and not main.mulligan_ui.active and not paused and main.tutorial.stage == "off")
	check("[3] main.tscn 직행에서도 1일차가 새벽 전환·새벽음으로 시작한다", main.world.day_cycle._dawn_elapsed < 12.0 and main.sounds.history.has("dawn"), "dawn_elapsed=%.2f" % main.world.day_cycle._dawn_elapsed, true)
	_finish()


func _finish() -> void:
	Engine.time_scale = 1.0
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Flow.ftue_path))
	var out := {"passed": failures == 0, "scenario": scenario, "checks": total, "failures": failures, "observations": obs, "results": results, "timeline": timeline}
	var f := FileAccess.open("res://art_sources/first-session-verify%s.json" % ("" if scenario == "follow" else "-" + scenario), FileAccess.WRITE)
	f.store_string(JSON.stringify(out, "\t") + "\n")
	print("FIRST_SESSION observations=", JSON.stringify(obs))
	print("RESULT %d/%d" % [total - failures, total])
	quit(0 if failures == 0 else 1)
