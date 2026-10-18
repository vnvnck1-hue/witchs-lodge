extends SceneTree
## 판마다 바뀌는 월드 설정 검증(docs/races-guests-v01.md §7): 주요 종족 둘 굴리기·가중치·무작위 손님 고르기·
## 실제 3일간 도착 묶음, 그리고 화면에 종족 설정을 드러내지 않는지(내부 설정).
##   .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_world_setting.gd
const Races := preload("res://scripts/game/races.gd")
const Profiles := preload("res://scripts/ui/guest_profiles.gd")
const WorldSetting := preload("res://scripts/game/world_setting.gd")
const OpeningScript := preload("res://scripts/game/opening_director.gd")
const Cfg := preload("res://scripts/config.gd")

var passed := 0
var total := 0
var game

func check(ok: bool, label: String) -> void:
	total += 1
	if ok: passed += 1
	print(("PASS " if ok else "FAIL ") + label)

func frames(n := 3) -> void:
	for i in n: await process_frame

func _initialize() -> void:
	create_timer(120.0, true, false, true).timeout.connect(func(): push_error("World setting verification timeout"); quit(2))
	call_deferred("run")

func run() -> void:
	# 1. 굴리기
	var counts := {}
	var ok_two := true
	for s in range(1, 301):
		var w := WorldSetting.new()
		w.roll(s)
		if w.majors.size() != 2 or w.majors[0] == w.majors[1] or not Races.has(w.majors[0]) or not Races.has(w.majors[1]): ok_two = false
		for r in w.majors: counts[r] = counts.get(r, 0) + 1
	check(ok_two, "roll: always two distinct registered major races (300 seeds)")
	check(counts.size() == 6, "roll: every race can be a major race (%s)" % str(counts))
	var a := WorldSetting.new()
	var b := WorldSetting.new()
	a.roll(777)
	b.roll(777)
	check(a.majors == b.majors, "roll: same seed gives the same world")
	var c := WorldSetting.new()
	c.roll(0)
	var d := WorldSetting.new()
	d.roll(0)
	check(c.seed_value != d.seed_value, "roll: seed 0 picks a fresh random seed each run")
	var e := WorldSetting.new()
	e.roll_from_args(PackedStringArray(["--world=orc,fairy"]))
	check(e.majors == ["orc", "fairy"], "args: --world=orc,fairy forces the major races")
	var f2 := WorldSetting.new()
	f2.roll_from_args(PackedStringArray(["--world-seed=42"]))
	var g2 := WorldSetting.new()
	g2.roll(42)
	check(f2.majors == g2.majors and f2.seed_value == 42, "args: --world-seed=N is reproducible")

	# 2. 가중치
	var w := WorldSetting.new()
	w.force(["orc", "fairy"], 5)
	check(absf(w.major_share() - 0.75) < 0.001, "weights: majors hold 75%% of guest weight (%.2f)" % w.major_share())
	var tally := {}
	for i in 6000:
		var r := w.pick_race()
		tally[r] = tally.get(r, 0) + 1
	var major_n: int = tally.get("orc", 0) + tally.get("fairy", 0)
	check(major_n > 6000 * 0.71 and major_n < 6000 * 0.79, "weights: ~75%% of 6000 picks are major (%d)" % major_n)
	var minors_ok := true
	for r in w.minors():
		if tally.get(r, 0) < 6000 * 0.035: minors_ok = false
	check(minors_ok, "weights: every minor race still appears occasionally (%s)" % str(tally))
	check(w.summary() == "major=orc,fairy seed=5", "summary: debug-only line (%s)" % w.summary())
	for r in Races.ALL:
		if w.village(r).get("place", "") == "": check(false, "village text for " + r)

	# 3. pick_guest
	var ok_flags := true
	var ok_excl := true
	for i in 200:
		var h := Profiles.pick_guest(w, true, ["가로크", "garok"])
		var t := Profiles.pick_guest(w, false, ["ulma"])
		if not h.hireable or t.hireable: ok_flags = false
		if h.person == "가로크" or t.id == "ulma": ok_excl = false
	check(ok_flags, "pick_guest: hire slot gives hireable guests, other slots give travelers")
	check(ok_excl, "pick_guest: excluded ids/names never come back")
	var orc_travelers := ["ulma", "bardu"]
	var avoid_ok := true
	for i in 100:
		var t := Profiles.pick_guest(w, false, [], orc_travelers)
		if t.id in orc_travelers: avoid_ok = false
	check(avoid_ok, "pick_guest: avoid list (already visited today) is respected while others remain")
	check(Profiles.pick_guest(w, true, Profiles.MERCENARIES).is_empty(), "pick_guest: empty when every hireable guest is taken")

	# 4. 실제 도착(3일)
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await frames(5)
	check(game.world_setting != null and game.world_setting.majors.size() == 2, "game: every run rolls a world setting")
	game.world_setting.force(["orc", "fairy"], 9)
	game.world.day_cycle.set_mode("day")
	var parties: Array = []
	game.economy.batch_arrived.connect(func(batch: Array): parties.append(batch.duplicate(true)))
	var all_guests: Array = []
	var ok_slots := true
	var ok_unique_batch := true
	var ok_unique_day := true
	var hired := 0
	for day in [1, 2, 3]:
		if day > 1:
			game.economy.end_prep()
			await frames(3)
			game.session.wave_index = day - 1
			game.session._enter_prep()
		var day_ids: Array = []
		for bi in 3:
			var arrive: float = Cfg.GUEST_ARRIVALS[bi] + 0.05
			game.session.prep_elapsed = arrive
			game.economy.update_prep(arrive)
			var party: Array = parties[-1]
			if day == 1 and bi == 0:
				check(party[0].character_id == "garok" and party[0].race == "orc", "day 1 first guest is the first major race's warrior (%s)" % party[0].person)
			if not party[0].hireable: ok_slots = false
			for k in range(1, party.size()):
				if party[k].hireable: ok_slots = false
			var ids: Array = party.map(func(p): return p.character_id)
			for id in ids:
				if ids.count(id) > 1: ok_unique_batch = false
				if id in day_ids: ok_unique_day = false
				day_ids.append(id)
			all_guests.append_array(party)
			game.guest_arrival.finish()
			game.economy.update_prep(arrive + Cfg.GUEST_STAY)
			if bi in Cfg.HIRE_BATCHES and not game.economy.offers.is_empty():
				var offer: Dictionary = game.economy.offers[-1]
				if offer.person == party[0].person and game.economy.hire(offer): hired += 1
	check(ok_slots, "arrivals: first of each batch is hireable, the rest are travelers")
	check(ok_unique_batch, "arrivals: no one appears twice in one batch")
	check(ok_unique_day, "arrivals: no one visits twice on the same day")
	check(hired >= 2, "arrivals: random guests still produce working hire offers (%d hired)" % hired)
	var major_guests := all_guests.filter(func(p): return p.race in ["orc", "fairy"]).size()
	print("INFO 3-day guests: %s" % str(all_guests.map(func(p): return "%s(%s)" % [p.person, p.race])))
	check(all_guests.size() >= 18 and major_guests >= all_guests.size() * 0.5, "arrivals: major races dominate the real guest stream (%d / %d)" % [major_guests, all_guests.size()])
	var hired_names: Array = game.cards.persons_in_use()
	var ok_no_dup := true
	for p in parties[-1]:
		if p.person in hired_names: ok_no_dup = false
	check(ok_no_dup, "arrivals: hired (contracted) guests do not show up again as new guests")

	# 5. 내부 설정: 화면 어디에도 종족 이름·확률을 드러내지 않는다(사용자 결정 2026-10-18)
	game.guest_ui._sync_hub()
	var leak := false
	for r in Races.ALL:
		if game.guest_ui.guest_summary.text.contains(Races.name_of(r)): leak = true
	check(not leak and not game.guest_ui.guest_summary.text.contains("산장 주변"), "hidden: lodge guest tab does not reveal the world setting")
	check(game.get("world_panel") == null and not ResourceLoader.exists("res://scripts/ui/world_setting_panel.gd"), "hidden: no world-setting panel exists")
	var opening = OpeningScript.new()
	opening.game = game
	game.add_child(opening)
	game.opening = opening
	opening.prepare(false)
	opening.phase = "dawn"
	opening._open_hand()
	await frames(2)
	check(opening.phase == "hand" and game.mulligan_ui.active, "hidden: opening goes straight from dawn to the starting hand")
	print("INFO world (debug only): " + game.world_setting.summary())
	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)
