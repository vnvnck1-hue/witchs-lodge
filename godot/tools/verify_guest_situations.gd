extends SceneTree
## 상황을 아는 첫마디 헤드리스 검증(scripts/game/guest_situations.gd, 사용자 선택 2026-10-25).
## 데이터: 6종족 × 상황 9가지 × 3줄, 대화창 3줄 안, 쓰러진 이름 자리 %s 규칙, 영문 사전.
## 흐름: 밤 시작·새벽 신호로 어젯밤 기록(산장 손실·새 무덤·밤 종류) → 우선순위대로 한 상황 → 같은 날 반복 없음 → 실제 대화창 첫 박자.
## 실행(프로젝트 루트): .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_guest_situations.gd
const Situations := preload("res://scripts/game/guest_situations.gd")
const Profiles := preload("res://scripts/ui/guest_profiles.gd")
const SessionScript := preload("res://scripts/game/game_session.gd")
const RACES := ["human", "dwarf", "fairy", "goblin", "beastfolk", "orc"]
var game
var passed := 0
var total := 0

func _initialize() -> void:
	create_timer(120.0, true, false, true).timeout.connect(func(): print("FAIL timeout"); quit(2))
	call_deferred("run")

func check(ok: bool, label: String, detail := "") -> void:
	total += 1
	if ok: passed += 1
	print("%s %s%s" % ["PASS" if ok else "FAIL", label, ("  — " + detail) if detail != "" else ""])

func frames(count := 3) -> void:
	for i in count: await process_frame

func _fits(presenter, text: String) -> bool:
	var wrapped: Array = presenter._wrap_dialogue(text)
	if wrapped.size() > 3: return false
	for line in wrapped:
		if presenter.dialogue_lines[0].get_theme_font("font").get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, presenter.dialogue_font_size).x > presenter.text_width: return false
	return true

func run() -> void:
	root.size = Vector2i(1600, 872)
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.world_setting.force(["human", "dwarf"])
	await frames(6)
	var ui = game.guest_ui
	var events = game.guest_events

	# ── 데이터 ──
	var en_raw := FileAccess.get_file_as_string("res://assets/i18n/en.json")
	var en: Dictionary = JSON.parse_string(en_raw) if en_raw != "" else {}
	var particle := RegEx.new()
	particle.compile("%s[\\x{AC00}-\\x{D7A3}]")
	var hangul := RegEx.new()
	hangul.compile("[\\x{AC00}-\\x{D7A3}]")
	for race in RACES:
		var lines: Dictionary = Situations.lines(race)
		var short: Array = []
		var overflow: Array = []
		var bad_name: Array = []
		var no_en: Array = []
		for key in Situations.ORDER:
			var options: Array = lines.get(key, []) if Situations.RACE_FILES.has(race) and ResourceLoader.exists(Situations.RACE_FILES[race]) else []
			if options.size() < 3: short.append(key)
			for o in options:
				var text := str(o.get("text", ""))
				var needs_name: bool = key in ["fell", "fell_kin"]
				if text.count("%s") != (1 if needs_name else 0) or particle.search(text) != null: bad_name.append(key + ":" + text.substr(0, 12))
				if not _fits(ui.presenter, text.replace("%s", "토르그림")): overflow.append(text.substr(0, 14))
				var thought := str(o.get("thought", ""))
				if thought != "" and not _fits(ui.presenter, "(" + thought + ")"): overflow.append(thought.substr(0, 14))
				for t in [text, thought]:
					if t != "" and (not en.has(t) or hangul.search(str(en[t])) != null): no_en.append(t.substr(0, 12))
		check(short.is_empty(), "%s: 상황 9가지마다 3줄" % race, str(short))
		check(overflow.is_empty(), "%s: 모든 줄이 대화창 3줄 안" % race, str(overflow))
		check(bad_name.is_empty(), "%s: 쓰러진 이름 자리 %%s 는 애도 상황에만 하나, 바로 뒤 조사 없음" % race, str(bad_name))
		check(no_en.is_empty(), "%s: 영문 사전에 모두 있음" % race, str(no_en.slice(0, 4)))

	# ── 어젯밤 기록: 밤 시작·새벽 신호 ──
	var lodge = game.world.lodge
	var yard = game.world.graveyard
	events._on_session_state(SessionScript.State.COMBAT)
	lodge.hp -= lodge.max_hp * 0.3
	yard.graves.append({"person": "올라프", "day": game.session.day(), "node": null})
	events._on_session_state(SessionScript.State.PREP)
	check(is_equal_approx(float(events.night_log.lost), lodge.max_hp * 0.3) and events.night_log.fallen.size() == 1 and events.night_log.fallen[0].race == "human",
		"새벽에 어젯밤 기록: 산장 손실·새 무덤·종족", str(events.night_log))
	yard.graves.pop_back()

	# ── 우선순위·반복 없음 ──
	game.session.wave_index = maxi(game.session.wave_index, 1)
	events.night_log = {"night": game.session.wave_index, "lost": 120.0, "max_hp": 300.0, "fallen": [{"person": "올라프", "race": "human"}], "type": "big_raid"}
	var bram := Profiles.guest_profile("bram")
	var harald := Profiles.guest_profile("harald")
	events._on_batch([bram, harald])
	events.admit(bram)
	events.admit(harald)
	var e_bram: Dictionary = events.visit(bram["visit_uid"])
	var e_harald: Dictionary = events.visit(harald["visit_uid"])
	var first: Array = events.situation_beats(e_bram)
	check(first.size() >= 1 and first[0].situation == "fell_kin" and "올라프" in str(first[0].text), "같은 종족 용병이 쓰러졌으면 애도가 먼저(이름 들어감)", str(first))
	var second: Array = events.situation_beats(e_bram)
	check(second.size() >= 1 and second[0].situation == "night_hurt", "같은 날 두 번째 대화는 같은 죽음이 아니라 다음 상황", str(second))
	var dwarf: Array = events.situation_beats(e_harald)
	check(dwarf.size() >= 1 and dwarf[0].situation == "fell" and "올라프" in str(dwarf[0].text), "다른 종족 손님은 일반 애도", str(dwarf))
	events.night_log = {"night": game.session.wave_index, "lost": 0.0, "max_hp": 300.0, "fallen": [], "type": "normal"}
	var calm: Array = events.situation_beats(e_harald)
	check(calm.size() >= 1 and calm[0].situation == "night_calm", "아무도 안 다친 밤", str(calm))
	events.night_log = {"night": game.session.wave_index - 1, "lost": 200.0, "max_hp": 300.0, "fallen": [{"person": "올라프", "race": "human"}], "type": "fog"}
	var stale: Array = events.situation_beats(e_harald)
	check(stale.is_empty() or not stale[0].situation in ["fell", "fell_kin", "night_hurt", "fog_night", "big_night", "night_calm"], "지난 기록(그제 밤)은 꺼내지 않는다", str(stale))

	# ── 실제 대화창 첫 박자 ──
	events.night_log = {"night": game.session.wave_index, "lost": 0.0, "max_hp": 300.0, "fallen": [], "type": "fog"}
	await frames(3)
	ui.open_conversation(e_bram.uid)
	await frames(3)
	var expected := str(Situations.line("human", "fog_night", "bram").get("text", "?"))
	check(ui.dialogue_active and ui.presenter.dialogue_lines[0].text == ui.presenter._wrap_dialogue(expected)[0], "대화창 첫 박자가 상황 첫마디(안개 낀 밤)", ui.presenter.dialogue_lines[0].text)
	ui.close_conversation(false)
	await frames(2)

	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)
