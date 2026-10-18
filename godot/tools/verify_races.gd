extends SceneTree
## 종족 시스템 1차 검증(docs/races-guests-v01.md §5): 종족 등록부, 손님 42명 구성, 대사·이야기, 등장 순서, 포트레이트 대체.
##   .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_races.gd
const Races := preload("res://scripts/game/races.gd")
const Profiles := preload("res://scripts/ui/guest_profiles.gd")
const Dialogues := preload("res://scripts/game/guest_dialogues.gd")
const Cfg := preload("res://scripts/config.gd")

const NEW_RACES := ["dwarf", "fairy", "goblin", "beastfolk", "orc"]
const JOB_LIST := ["warrior", "hunter", "lumberjack", "gatherer"]

var passed := 0
var total := 0
var game

func check(ok: bool, label: String) -> void:
	total += 1
	if ok: passed += 1
	print(("PASS " if ok else "FAIL ") + label)

func _initialize() -> void:
	create_timer(60.0, true, false, true).timeout.connect(func(): push_error("Races verification timeout"); quit(2))
	call_deferred("run")

func run() -> void:
	# 1. 종족 등록부
	check(Races.ALL.size() == 6 and Races.ALL[0] == "human", "races: 6 registered, human first")
	for id in NEW_RACES:
		check(Races.has(id) and Races.name_of(id) != "" and Races.emblem_of(id) != "", "races: %s has name/emblem" % id)
	check(Races.name_of("nope") == "" and Races.accent("nope") != Color(0, 0, 0, 0), "races: unknown id degrades gracefully")

	# 2. 손님 42명 구성
	var roster: Array = Profiles.all_profiles()
	check(roster.size() == 42, "roster: 42 profiles (7 human + 5 races x 7)")
	var ids := {}
	var names := {}
	var portraits := {}
	var ok_unique := true
	for p in roster:
		if ids.has(p.id) or names.has(p.person): ok_unique = false
		ids[p.id] = true
		names[p.person] = true
		# 포트레이트가 미납품이면 실루엣 경로를 공유하므로 원본 경로 기준으로 고유성을 본다.
		var raw: Dictionary = {}
		for c in Profiles.CATALOG:
			if c.id == p.id: raw = c
		if portraits.has(raw.portrait): ok_unique = false
		portraits[raw.portrait] = true
	check(ok_unique, "roster: id/name/portrait path unique")
	var ok_race_field := true
	for p in roster:
		if not Races.has(p.get("race", "")) or p.race_name == "": ok_race_field = false
	check(ok_race_field, "roster: every profile has a registered race and race_name")
	for race in Races.ALL:
		var members: Array = Profiles.profiles_of_race(race)
		var hire: Array = members.filter(func(p): return p.hireable)
		var jobs := {}
		for p in hire: jobs[Profiles.job_of(p.person)] = true
		check(members.size() == 7, "roster: %s has 7 guests" % race)
		check(hire.size() == 4 and jobs.size() == 4, "roster: %s has 4 hireable covering all 4 jobs" % race)
		check(members.size() - hire.size() == 3, "roster: %s has 3 travelers" % race)
	check(Profiles.race_of("브람") == "human" and Profiles.race_of("니브") == "goblin" and Profiles.race_of("용병 9") == "human", "roster: race_of by person name")
	check(Profiles.MERCENARIES.size() == 24 and Profiles.TRAVELERS.size() == 18, "roster: 24 hireable names, 18 traveler ids in pools")
	var ok_rot := true
	for n in Profiles.MERCENARIES:
		if not Profiles.JOBS.has(n) or Profiles.race_of(n) == "" : ok_rot = false
	for t in Profiles.TRAVELERS:
		var c: Dictionary = Profiles.character(t)
		if c.is_empty() or c.hireable: ok_rot = false
	check(ok_rot, "roster: pool lists reference catalog hireable names / traveler ids")

	# 3. 대사·이야기
	var ok_lines := true
	var ok_story := true
	for p in roster:
		if p.lines.size() != 3: ok_lines = false
		for line in p.lines:
			if line.strip_edges() == "" or line.split("\n").size() > 3: ok_lines = false
		var s: Dictionary = Dialogues.STORIES.get(p.id, {})
		if s.is_empty() or s.choices.size() != 2 or s.title == "" or s.opening == "" or s.closing == "": ok_story = false
		for ch in s.get("choices", []):
			if ch.text == "" or ch.reply == "": ok_story = false
	check(ok_lines, "dialogue: 3 greeting lines, each at most 3 rows, for all 42")
	check(ok_story, "dialogue: own story (title/opening/2 choices/closing) for all 42")

	# 4. 등장 방식은 판마다 바뀌는 월드 설정의 무작위 가중치다(tools/verify_world_setting.gd).
	check(not Profiles.pick_guest(null, true, []).is_empty() and not Profiles.pick_guest(null, false, []).is_empty(), "pick_guest returns hireable and traveler guests")

	# 5. 포트레이트 대체·UI 표시(씬 로드)
	var missing := 0
	var present := 0
	for p in roster:
		if p.portrait_missing: missing += 1
		else: present += 1
		var tex: Texture2D = load(p.portrait)
		if tex == null: check(false, "portrait: loadable texture for " + p.id)
	check(present >= 7, "portrait: at least the 7 human portraits are real (%d real, %d placeholder)" % [present, missing])
	print("INFO portraits delivered: %d / 42, placeholder: %d" % [present, missing])

	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	for i in 5: await process_frame
	var dwarf: Dictionary = Profiles.guest_profile("harald")
	game.guest_arrival.profiles = [dwarf]
	game.guest_arrival.guest_index = -1
	game.guest_arrival._show_guest()
	for i in 2: await process_frame
	check(game.guest_arrival.role_label.text == "드워프 · 전투용병", "ui: arrival role label shows race · role (%s)" % game.guest_arrival.role_label.text)
	var tint: Color = game.guest_arrival.role_label.modulate
	var want: Color = Races.accent("dwarf")
	check(absf(tint.r - want.r) < 0.01 and absf(tint.g - want.g) < 0.01 and absf(tint.b - want.b) < 0.01, "ui: arrival role label tinted with race accent (alpha is animated separately)")
	var font: Font = game.guest_arrival.dialogue_lines[0].get_theme_font("font")
	var ok_fit := true
	for p in roster:
		for line in p.lines:
			var wrapped: Array[String] = game.guest_arrival._wrap_dialogue(line)
			if wrapped.size() > 3: ok_fit = false
			for row in wrapped:
				if font.get_string_size(row, HORIZONTAL_ALIGNMENT_LEFT, -1, game.guest_arrival.dialogue_font_size).x > game.guest_arrival.text_width:
					ok_fit = false
					print("INFO too wide: %s: %s" % [p.id, row])
	check(ok_fit, "ui: all greeting rows fit the arrival speech box")
	game.guest_arrival.finish()
	game.queue_free()
	await process_frame
	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)
