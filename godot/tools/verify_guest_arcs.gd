extends SceneTree
## 손님 이야기 연작·기억 장부·끼어들기 헤드리스 검증(docs/pentiment-dialogue-research-v01.md §3, 2026-10-25 인간 7명 시범).
## 데이터: 인간 7명 × 2·3편, 모든 박자가 대화창 3줄 안, 끼어드는 화자 id·조건 문법·기억 표시가 실제로 정의돼 있는지.
## 흐름: 실제 대화창에서 장면 묘사(괄호·색) → 다른 손님 끼어들기(초상·이름 교체) → 조건 선택지 → 기억 → 다음 편·재방문 인사.
## 용병 이벤트: 이야기 속에 3인칭으로 나오는 인물은 그 이야기의 화자가 되지 않는다.
## 실행(프로젝트 루트): .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_guest_arcs.gd
const Arcs := preload("res://scripts/game/guest_story_arcs.gd")
const Stories := preload("res://scripts/game/guest_dialogues.gd")
const Profiles := preload("res://scripts/ui/guest_profiles.gd")
const MercEvents := preload("res://scripts/game/merc_events.gd")
const HUMANS := ["bram", "mira", "olaf", "torbin", "neri", "oswin", "sera"]
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

## 박자 목록을 펼쳐 [text, who, if] 로.
func _flat(raw) -> Array:
	var out: Array = []
	for b in (raw if raw is Array else [raw]):
		if b is String: out.append({"text": b, "who": "", "if": null})
		else: out.append({"text": b.get("text", ""), "who": str(b.get("who", "")), "if": b.get("if")})
	return out

func _conds(c) -> Array:
	if c == null: return []
	return c if c is Array else [c]

## 대화창을 끝까지(또는 선택지까지) 넘기며 본 이름·글색을 모은다.
func _drive(ui, seen: Array, until_phase := "") -> void:
	for i in 60:
		if not ui.dialogue_active or ui.dialogue_phase == until_phase: return
		if ui.dialogue_phase == "choices": return
		seen.append({"name": ui.presenter.name_label.text, "tint": ui.presenter.dialogue_lines[0].modulate, "text": ui.presenter.dialogue_lines[0].text})
		if ui.presenter.is_writing(): ui.presenter.finish_writing()
		ui.advance_dialogue()
		await frames(2)

func run() -> void:
	root.size = Vector2i(1600, 872)
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.world_setting.force(["human", "dwarf"])
	await frames(6)
	game.world.day_cycle.set_mode("day")
	var ui = game.guest_ui
	var events = game.guest_events

	# ── 데이터 ──
	var ids := {}
	for p in Profiles.CATALOG + Profiles.SPECIALS: ids[p["id"]] = true
	var defined := {}
	for id in Arcs.all_part1():
		for f in Arcs.all_part1()[id]: defined[f] = true
	for id in ids: defined["heard:" + id] = true
	for id in Arcs.all_arcs():
		for part in Arcs.all_arcs()[id]:
			for c in part["choices"]:
				if c.has("remember"): defined[c["remember"]] = true
	var overflow: Array = []
	var bad_who: Array = []
	var bad_cond: Array = []
	var bad_shape: Array = []
	for p in Profiles.CATALOG:
		var id: String = p["id"]
		check(Arcs.part_count(id) == 3, "연작 3편: " + id)
		var first := Arcs.part(id, 0, Stories.story(id))
		check(first["choices"][0].get("remember", "") != "" and first["choices"][1].get("remember", "") != "", "1편 두 대답이 기억을 남긴다: " + id)
		for n in [1, 2]:
			var s := Arcs.part(id, n, {})
			var plain: int = s.get("choices", []).filter(func(c): return not c.has("if")).size()
			if not (s.has("prompt") and s.has("title") and s.has("opening") and s.has("closing") and plain >= 2): bad_shape.append("%s#%d" % [id, n])
			var beats: Array = _flat(s.get("opening", [])) + _flat(s.get("closing", []))
			for c in s.get("choices", []):
				beats += _flat(c["reply"])
				beats.append({"text": c["text"], "who": "", "if": c.get("if")})
			for b in beats:
				var shown: String = ("(" + b.text + ")") if b.who in ["witch", "scene"] else b.text
				if not _fits(ui.presenter, shown): overflow.append("%s#%d %s" % [id, n, b.text.substr(0, 14)])
				if b.who not in ["", "witch", "scene"] and not ids.has(b.who): bad_who.append(b.who)
				for c in _conds(b["if"]):
					var t := str(c).trim_prefix("!")
					var known: bool = t in ["merchant_day", "black_sheep"] or t.begins_with("day>=") or t.begins_with("day<=") \
						or (t.begins_with("present:") and ids.has(t.substr(8))) or (t.begins_with("mem:") and defined.has(t.substr(4)))
					if not known: bad_cond.append(str(c))
	for id in Arcs.all_greetings():
		for g in Arcs.all_greetings()[id]:
			if not _fits(game.guest_arrival, g["text"]): overflow.append("인사 " + id)
			for c in _conds(g["if"]):
				if not defined.has(str(c).trim_prefix("!").trim_prefix("mem:")): bad_cond.append(str(c))
	check(bad_shape.is_empty(), "2·3편 구조(prompt·title·opening·선택지 2+·closing)", str(bad_shape))
	check(overflow.is_empty(), "모든 박자·인사가 3줄 안", str(overflow))
	check(bad_who.is_empty(), "끼어드는 화자 id 가 명부에 있다", str(bad_who))
	check(bad_cond.is_empty(), "조건 문법과 기억 표시가 정의돼 있다", str(bad_cond))

	# ── 조건 ──
	check(events.cond_ok(null) and events.cond_ok("day>=1") and not events.cond_ok("mem:nope") and events.cond_ok("!mem:nope"), "조건: 없음·day·mem·부정")
	check(not events.cond_ok(["day>=1", "mem:nope"]), "조건 목록은 모두 참이어야 한다")

	# ── 흐름: 미라 2편 + 두르가 끼어들기 ──
	events.story_parts["mira"] = 1
	events.memory["mira_book"] = true
	var mira := Profiles.guest_profile("mira")
	var durga := Profiles.guest_profile("durga")
	events._on_batch([mira, durga])
	events.admit(mira)
	events.admit(durga)
	var uid: int = mira["visit_uid"]
	check(events.visit(uid).story.title == "찢긴 첫 장", "1편을 마친 손님은 2편을 가져온다", events.visit(uid).story.title)
	await frames(3)
	ui.open_conversation(uid)
	await frames(3)
	check(ui.dialogue_active, "2편 대화가 열린다")
	var seen: Array = []
	await _drive(ui, seen)
	var names: Array = seen.map(func(x): return x.name)
	check(seen.size() > 0 and seen[0].tint.is_equal_approx(Color(ui.SCENE_TINT.r, ui.SCENE_TINT.g, ui.SCENE_TINT.b, seen[0].tint.a)) and seen[0].text.begins_with("("), "장면 묘사는 괄호 글·청록색")
	check("두르가" in names and names.count("미라") >= 2, "묵고 있는 두르가가 끼어들고 다시 미라로 돌아온다", str(names))
	check(seen.any(func(x): return x.text.begins_with("그 책이요")), "기억(mira_book)에 맞는 줄이 나온다")
	check(not seen.any(func(x): return x.text.begins_with("그냥 잡초라고")), "기억에 없는 대답(mira_weed) 줄은 빠진다")
	check(seen.any(func(x): return x.tint.is_equal_approx(Color(ui.THOUGHT_TINT.r, ui.THOUGHT_TINT.g, ui.THOUGHT_TINT.b, x.tint.a))), "마녀의 생각은 연보라 괄호 글")
	check(ui.dialogue_phase == "choices" and ui.active_choices.size() == 2, "선택지 2개")
	check(ui.next_button.text != "", "다음 버튼 문구")
	ui.choose(0)
	await frames(3)
	check(events.memory.has("mira_shows"), "고른 대답이 기억 장부에 남는다")
	await _drive(ui, seen)
	check(not ui.dialogue_active and events.story_parts.get("mira", 0) == 2 and events.memory.has("heard:mira"), "대화를 마치면 2편 완료")
	var log: Array = events.history.back().transcript
	check(log.any(func(l): return str(l).begins_with("두르가:")) and log.any(func(l): return str(l).begins_with("마녀의 생각:")), "기록 탭에 끼어들기·생각이 함께 남는다")
	check(events.next_story("mira").title == "겨울에 피는 까닭" and not events.completed_stories.has("mira"), "다음 방문은 3편")
	check(events.memory_greeting("mira") == Arcs.all_greetings()["mira"][1]["text"], "재방문 인사가 지난 대답을 꺼낸다")
	check(events.memory_greeting("ketil") == "", "기억 인사가 없는 손님은 평소 인사")

	# ── 끼어들 손님이 없으면 그 줄은 빠진다 ──
	var none: Array = ui._beats(events.visit(uid), Arcs.all_arcs()["bram"][0]["opening"])
	check(not none.any(func(b): return str(b.get("who", "")) == "thistle"), "티슬이 없으면 티슬 끼어들기는 빠진다")

	# ── 3편까지 마치면 연작 완료 ──
	events.story_parts["mira"] = 2
	var st: Dictionary = events.next_story("mira")
	check(st.title == "겨울에 피는 까닭", "3편 선택")
	events.story_parts["mira"] = 3
	check(events.next_story("mira").title == Stories.story("mira").title, "연작을 다 마치면 1편이 자리만 채운다")

	# ── 특수 손님(에린·브로크)은 연작이 없다, 1편은 기존 이야기 그대로 ──
	check(Arcs.part_count("erin") == 1 and Arcs.part_count("brock") == 1, "특수 손님은 연작 없음")
	check(Arcs.part("durga", 0, Stories.story("durga")).title == Stories.story("durga").title, "1편은 기존 이야기 그대로")

	# ── 용병 이벤트 화자 ──
	var me = game.merc_events
	var evs: Dictionary = me.all_events()
	var named := 0
	var leaks: Array = []
	for p in Profiles.CATALOG:
		var s := {"person": p["person"], "id": p["id"], "race": p["race"]}
		for k in me._options_for(s, [s], evs, false) + me._options_for(s, [s], evs, true):
			if MercEvents._mentions(evs[k], p["person"]): leaks.append(p["person"] + "→" + k)
		for k in evs:
			if MercEvents._mentions(evs[k], p["person"]): named += 1
	check(named > 0, "3인칭 이름이 나오는 이벤트가 있다(검사 대상)", str(named))
	check(leaks.is_empty(), "자기 이름이 3인칭으로 나오는 이벤트를 그 인물이 말하지 않는다", str(leaks))

	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)
