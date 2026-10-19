extends Node
## 종족·언데드·화합 카드 v1 자동 검증(docs/race-cards-v01.md). 실제 게임 장면에서 카드 43장의 판정·사용, 밤 버프·영구 강화,
## 시설·소환물, 장비 효과, 새벽 정리, 전 종족 용병 이벤트와 사건 효과, 언데드(제물·시체 부패·해골), 산장의 소문을 확인한다.
## 결과: res://art_sources/race-cards-verify.json

const Cfg := preload("res://scripts/config.gd")
const Layout := preload("res://scripts/world/layout.gd")
const Data := preload("res://scripts/game/race_card_data.gd")
const RaceEvents := preload("res://scripts/game/race_events_data.gd")
const MonsterScript := preload("res://scripts/actors/monster.gd")
const SessionScript := preload("res://scripts/game/game_session.gd")
const GuestProfiles := preload("res://scripts/ui/guest_profiles.gd")

const NEW_CARDS := ["fae_swap", "dream_journal", "thistle_oath", "forest_promise", "rune_hammer", "dark_ale", "stone_wall",
	"ancestor_shield", "mine_prop", "stone_song", "war_drum", "feast_table", "blood_oath", "bone_throw", "victory_roar",
	"ancestor_path", "ash_sigil", "spit_roast", "pack_scent", "porter_pack", "hibernation", "introduction_letter", "guild_writ",
	"village_militia", "old_records", "pilgrim_blessing", "merchant_wagon", "battle_ration", "sacrifice_dagger", "corpse",
	"rise_up", "bone_barricade", "soul_jar", "ghoul_feast", "death_march", "bone_hounds", "black_rumor", "ledger_of_dead",
	"crest_banner", "interpreter_pen", "lodge_festival", "stranger_gift", "lodge_cleanup"]

var main
var results: Array = []
var failures := 0
var spot := Vector3.ZERO


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	while get_tree().current_scene == null or get_tree().current_scene.get("session") == null:
		await get_tree().process_frame
	main = get_tree().current_scene
	await get_tree().process_frame
	await _run()
	var out := {"passed": failures == 0, "checks": results.size(), "failures": failures, "results": results}
	var f := FileAccess.open("res://art_sources/race-cards-verify.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(out, "\t") + "\n")
	print("RESULT %d/%d" % [results.size() - failures, results.size()])
	get_tree().quit(0 if failures == 0 else 1)


func check(name: String, ok: bool, detail := "") -> void:
	results.append({"check": name, "ok": ok, "detail": detail})
	if not ok:
		failures += 1
	print(("PASS " if ok else "FAIL ") + name + ("  — " + detail if detail != "" else ""))


func frames(n := 2) -> void:
	for i in n:
		await get_tree().process_frame


func sp(p: Vector3) -> Vector2:
	return main.world.camera.unproject_position(p)


func give(id: String, n := 1, person := "") -> int:
	while main.cards.hand_full():
		main.cards.entries.erase(main.cards.hand()[0])
	main.cards.add(id, n, person, "hand")
	await frames(1)
	var best := -1
	for e in main.cards.entries:
		if e["id"] == id and e["zone"] == "hand":
			best = maxi(best, e["uid"])
	return best


func enemy(pos: Vector3, kind := "spider", hp := 60.0):
	var m := MonsterScript.new()
	m.setup(main, hp, false)
	m.configure(kind)
	m.position = pos
	main.actors.add_child(m)
	m.set_physics_process(false)
	return m


func clear_enemies() -> void:
	for e in get_tree().get_nodes_in_group("enemies"):
		e.remove_from_group("enemies")
		e.queue_free()
	await frames(2)


func merc(person: String, job: String, at: Vector3):
	var a = main.contracts.spawn_guard("merc", person, at, null, job)
	await frames(2)
	a.set_physics_process(false)
	return a


func clear_mercs() -> void:
	for a in main.contracts.allies.duplicate():
		if is_instance_valid(a) and not a.dead and a.kind == "merc":
			a.dismiss()
	for e in main.cards.entries.duplicate():
		if main.cards.is_job(e["id"]):
			main.cards.remove_uid(e["uid"])
	await frames(3)


func set_state(s: int) -> void:
	main.session.state = s


func merc_sp(a) -> Vector2:
	return sp(a.global_position + Vector3(0, a.hp_offset * 0.5, 0))


func close_ui() -> void:
	if main.offer_ui.active:
		main.offer_ui.close()
	main.race_cards._pending.clear()
	await frames(2)


func count_of(id: String) -> int:
	return main.cards.count_of(id)


func _run() -> void:
	var rc = main.race_cards
	var ud = main.undead
	var rep = main.reputation
	var res = main.resolver
	var cards = main.cards
	await frames(5)
	main.waves.set_process(false)
	spot = Layout.DOOR_FRONT + Vector3(6, 0, 4)
	main.player.global_position = Layout.DOOR_FRONT + Vector3(-6, 0, 2)
	main.economy.gold = 500

	# ── 1. 데이터·모듈
	check("모듈이 붙어 있음(종족 카드·언데드·소문·소문 막대)", rc != null and ud != null and rep != null and main.get_node_or_null("ReputationBar") != null)
	var missing: Array = NEW_CARDS.filter(func(id): return cards.def(id).is_empty())
	check("카탈로그에 새 카드 43장", missing.is_empty() and NEW_CARDS.size() == 43, str(missing))
	check("시간대: 노래·함성·민병·일어나라·행진·사냥개는 밤, 길드 증서는 낮, 검은 소문은 없음, 나머지 공용",
		cards.phase_of("stone_song") == "night" and cards.phase_of("bone_hounds") == "night" and cards.phase_of("guild_writ") == "day"
		and cards.phase_of("black_rumor") == "none" and cards.phase_of("dark_ale") == "both" and cards.is_corruption("black_rumor"))
	var eq_ok := true
	for id in rc.EQUIP_IDS:
		if not Cfg.EQUIPMENT.has(id) or main.equipment.effect_text(id) == "":
			eq_ok = false
	check("장비 9종이 장비 표에 칸·설명과 함께 등록(마녀 장비 3종은 마녀 전용)", eq_ok and Cfg.EQUIPMENT["dream_journal"]["who"] == "witch" and Cfg.EQUIPMENT["ledger_of_dead"]["who"] == "witch")
	var bad_fx: Array = []
	var n_events := 0
	for k in RaceEvents.EVENTS:
		n_events += 1
		for c in RaceEvents.EVENTS[k]["choices"]:
			var fx: String = c.get("effect", "")
			if fx.begins_with("merc:card:") and cards.def(fx.split(":")[2]).is_empty():
				bad_fx.append(fx)
	check("종족 이벤트 33건 · 카드 효과가 모두 카탈로그 카드", n_events == 33 and bad_fx.is_empty(), str(bad_fx))

	# ── 2. 드워프
	set_state(SessionScript.State.PREP)
	var harald = await merc("하랄", "warrior", spot + Vector3(-1, 0, 0))
	var bram = await merc("브람", "warrior", spot + Vector3(1, 0, 0))
	var hp_h: float = harald.max_hp
	var hp_b: float = bram.max_hp
	var ale: int = await give("dark_ale")
	var r: Dictionary = res.commit(ale, sp(spot))
	check("흑맥주 통: 용병 전원 최대 체력 +30%", r.get("ok", false) and absf(harald.max_hp - hp_h * 1.3) < 0.01 and absf(bram.max_hp - hp_b * 1.3) < 0.01, "%.1f/%.1f" % [harald.max_hp, bram.max_hp])
	check("흑맥주 통: 인간 이동 −15%, 드워프는 감속 없음", absf(main.equipment.speed_mult(bram) - 0.85) < 0.001 and absf(main.equipment.speed_mult(harald) - 1.0) < 0.001,
		"%.2f/%.2f" % [main.equipment.speed_mult(bram), main.equipment.speed_mult(harald)])
	rc.on_dawn(main.session.day())
	check("흑맥주 통: 새벽에 최대 체력이 원래대로", absf(harald.max_hp - hp_h) < 0.01 and absf(main.equipment.speed_mult(bram) - 1.0) < 0.001)
	var wall: int = await give("stone_wall")
	r = res.commit(wall, sp(spot + Vector3(0, 0, 3)))
	await frames(2)
	var walls: Array = rc.facilities("stone_wall")
	check("돌 성벽 기초: 체력 220 돌벽이 서고 적의 표적(allies)", r.get("ok", false) and walls.size() == 1 and walls[0].max_hp == 220.0 and walls[0].is_in_group("allies"))
	walls[0].hp = 100.0
	rc.on_dawn(main.session.day())
	check("돌 성벽: 드워프 1명이면 새벽 자동 수리 없음(3명 이상 조건)", walls[0].hp == 100.0)
	cards.add("warrior", 1, "브륀힐드", "pocket")
	cards.add("hunter", 1, "토르그림", "pocket")
	check("드워프 수 = 3(활동 1 + 계약 카드 2)", rc.race_count("dwarf") == 3, str(rc.race_count("dwarf")))
	rc.on_dawn(main.session.day())
	check("돌 성벽: 드워프 3명이면 새벽마다 +30", walls[0].hp == 130.0, str(walls[0].hp))
	var lodge = main.world.lodge
	var lmax: float = lodge.max_hp
	var prop: int = await give("mine_prop")
	r = res.evaluate(prop, sp(Layout.DOOR_FRONT + Vector3(14, 0, 10)))
	check("갱도 버팀목: 산장에서 먼 땅은 거부", not r["ok"], str(r.get("reason", "")))
	var prop_at: Vector3 = lodge.global_position + Vector3(3.0, 0, 4.5)
	r = res.commit(prop, sp(prop_at))
	await frames(2)
	var props: Array = rc.facilities("mine_prop")
	check("갱도 버팀목: 산장 최대 체력 +60", r.get("ok", false) and props.size() == 1 and lodge.max_hp == lmax + 60.0, "%s · %.0f" % [str(r.get("reason", "")), lodge.max_hp])
	if props.size() == 1:
		var e_near = enemy(props[0].global_position + Vector3(1.0, 0, 0), "spider", 100.0)
		await frames(1)
		props[0].take_damage(999.0)
		await frames(2)
		check("갱도 버팀목: 부서지면 근처 적에게 피해 45 · 산장 최대 체력 원래대로", e_near.hp <= 55.0 and lodge.max_hp == lmax, "적 %.0f · 산장 %.0f" % [e_near.hp, lodge.max_hp])
	await clear_enemies()
	var song: int = await give("stone_song")
	check("돌 속의 노래: 낮에는 거부", not res.evaluate(song, sp(spot))["ok"])
	set_state(SessionScript.State.COMBAT)
	r = res.commit(song, sp(spot))
	var lhp: float = lodge.hp
	lodge.take_damage(30.0)
	walls[0].take_damage(30.0)
	check("돌 속의 노래: 산장·성벽이 피해를 받지 않음", r.get("ok", false) and lodge.hp == lhp and walls[0].hp == 130.0)
	check("돌 속의 노래: 드워프 3명이면 5초", absf((rc._song_until - rc._clock) - 5.0) < 0.2, "%.2f" % (rc._song_until - rc._clock))
	cards.add("gatherer", 1, "두르가", "pocket")
	check("돌 속의 노래: 드워프 4명이면 10초(판정 안내)", rc._song_time() == 10.0)
	rc._song_until = -1.0
	lodge.take_damage(10.0)
	check("노래가 끝나면 다시 피해를 받음", lodge.hp == lhp - 10.0)
	lodge.hp = lodge.max_hp
	# 조상의 방패
	set_state(SessionScript.State.PREP)
	var shield: int = await give("ancestor_shield")
	r = res.commit(shield, merc_sp(harald))
	check("조상의 방패 장착(드워프): 받는 피해 −30%", r.get("ok", false) and absf(main.equipment.taken_mult(harald) - 0.7) < 0.001, "%.2f" % main.equipment.taken_mult(harald))
	check("조상의 방패: 드워프가 끼면 4m 안 아군 −15%", absf(main.equipment.taken_mult(bram) - 0.85) < 0.001, "%.2f" % main.equipment.taken_mult(bram))
	bram.global_position = spot + Vector3(9, 0, 0)
	check("조상의 방패: 멀리 있는 아군은 그대로", absf(main.equipment.taken_mult(bram) - 1.0) < 0.001)
	bram.global_position = spot + Vector3(1, 0, 0)
	main.equipment.unequip(harald, "armor", false)
	# 룬 새긴 망치
	var hammer: int = await give("rune_hammer")
	res.commit(hammer, merc_sp(harald))
	cards.add("timber", 2, "", "hand")
	var timber0: int = cards.hand_count_of("timber")
	lodge.hp = lodge.max_hp - 150.0
	rc.on_dawn(main.session.day())
	check("룬 새긴 망치(드워프): 새벽에 목재 1로 산장 +80", lodge.hp == lodge.max_hp - 70.0 and cards.hand_count_of("timber") == timber0 - 1, "산장 %.0f/%.0f · 목재 %d" % [lodge.hp, lodge.max_hp, cards.hand_count_of("timber")])
	main.equipment.unequip(harald, "weapon", false)
	lodge.hp = lodge.max_hp

	# ── 3. 오크
	var garok = await merc("가로크", "warrior", spot + Vector3(0, 0, -1))
	var drum: int = await give("war_drum")
	res.commit(drum, sp(spot))
	check("전쟁 북: 인간 공격 +30%, 오크 +60%", absf(main.equipment.damage_mult(bram) - 1.3) < 0.001 and absf(main.equipment.damage_mult(garok) - 1.6) < 0.001,
		"%.2f/%.2f" % [main.equipment.damage_mult(bram), main.equipment.damage_mult(garok)])
	var ek = enemy(garok.global_position + Vector3(1.0, 0, 0))
	await frames(1)
	var ek0: Vector3 = ek.global_position
	garok.on_hit(ek)
	check("전쟁 북: 오크의 타격은 넉백", ek.global_position.distance_to(ek0) > 0.5)
	await clear_enemies()
	rc.on_dawn(main.session.day())
	var feast: int = await give("feast_table")
	var stew0: int = count_of("meat_stew")
	res.commit(feast, sp(spot))
	check("잔칫상: 고기 스튜 2개(오크 1명)", count_of("meat_stew") == stew0 + 2, "%d → %d" % [stew0, count_of("meat_stew")])
	cards.add("hunter", 1, "크라냐", "pocket")
	cards.add("lumberjack", 1, "모가", "pocket")
	var feast2: int = await give("feast_table")
	stew0 = count_of("meat_stew")
	res.commit(feast2, sp(spot))
	check("잔칫상: 오크 3명이면 스튜 3개", count_of("meat_stew") == stew0 + 3, "%d → %d" % [stew0, count_of("meat_stew")])
	var oath: int = await give("blood_oath")
	check("피의 맹세: 오크가 아니면 거부", not res.evaluate(oath, merc_sp(bram))["ok"])
	var g_hp: float = garok.max_hp
	r = res.commit(oath, merc_sp(garok))
	check("피의 맹세: 최대 체력 +50% · 공격 +30%", r.get("ok", false) and absf(garok.max_hp - g_hp * 1.5) < 0.5 and absf(main.equipment.damage_mult(garok) - 1.3) < 0.001,
		"%.0f → %.0f · %.2f" % [g_hp, garok.max_hp, main.equipment.damage_mult(garok)])
	check("피의 맹세: 계약 해지 불가", main.economy.dismiss_block_reason({"kind": "ally", "ally": garok, "person": garok.person}) != "")
	var dagger_try: int = await give("sacrifice_dagger")
	check("피의 맹세: 제물로 바칠 수 없음", not res.evaluate(dagger_try, merc_sp(garok))["ok"])
	cards.remove_uid(dagger_try)
	set_state(SessionScript.State.COMBAT)
	var roar: int = await give("victory_roar")
	res.commit(roar, sp(spot))
	var iv0: float = rc.interval_mult(garok)
	for i in 3:
		var ex = enemy(spot + Vector3(5 + i, 0, 5))
		await frames(1)
		ex.take_damage(9999.0)
	check("승리의 함성: 처치 3번 → 오크 공격 속도 +24%", absf(1.0 / rc.interval_mult(garok) - 1.24) < 0.01 and absf(rc.interval_mult(bram) - 1.0) < 0.001,
		"%.3f → %.3f" % [iv0, rc.interval_mult(garok)])
	await clear_enemies()
	# 재로 그린 문양
	var moga = await merc("모가", "warrior", spot + Vector3(-3, 0, 3))
	var sigil: int = await give("ash_sigil")
	var rs: Dictionary = main.equipment.equip(moga, sigil)
	var foe = enemy(moga.global_position + Vector3(1.5, 0, 0), "spider", 500.0)
	await frames(1)
	var f0: Vector3 = foe.global_position
	moga.take_damage(9999.0)
	await frames(2)
	check("재로 그린 문양: 쓰러질 때 근처 적이 겁먹어 달아남", rc.is_fleeing(foe) and foe.global_position.distance_to(f0) > 2.0 and foe.attack_cd >= 3.9)
	check("재로 그린 문양: 장비 카드는 손패로 돌아옴", count_of("ash_sigil") == 1, "%d · dead=%s · fleeing=%s · moved=%.2f" % [count_of("ash_sigil"), str(moga.dead), str(rc.is_fleeing(foe)), foe.global_position.distance_to(f0)])
	await clear_enemies()
	set_state(SessionScript.State.PREP)
	rc.on_dawn(main.session.day())
	var roast: int = await give("spit_roast")
	check("통구이: 생고기 3이 없으면 거부", not res.evaluate(roast, sp(spot))["ok"])
	cards.add("raw_meat", 3, "", "hand")
	bram.hp = 10.0
	r = res.commit(roast, sp(spot))
	check("통구이: 생고기 3 소비 · 전원 완전 회복 · 공격 +20%", r.get("ok", false) and bram.hp == bram.max_hp and absf(main.equipment.damage_mult(bram) - 1.2) < 0.001)
	rc.on_dawn(main.session.day())

	# ── 4. 수인·요정
	var fargh = await merc("파르그", "warrior", spot + Vector3(4, 0, 0))
	var saya = await merc("사야", "hunter", spot + Vector3(5, 0, 0))
	var scent: int = await give("pack_scent")
	res.commit(scent, merc_sp(fargh))
	check("무리의 냄새: 곁의 수인 1명 → 이동·공격 속도 +10%", absf(main.equipment.speed_mult(fargh) - 1.1) < 0.001 and absf(1.0 / rc.interval_mult(fargh) - 1.1) < 0.001)
	var momi = await merc("모미", "gatherer", spot + Vector3(6, 0, 1))
	var porter: int = await give("porter_pack")
	res.commit(porter, merc_sp(momi))
	momi.carry.clear()
	momi.add_carry("raw_meat", 1)
	momi.add_carry("timber", 1)
	check("짐꾼의 등짐: 채집가가 줍는 양 2배(목재 제외) · 짐을 들면 이동 +25%", int(momi.carry.get("raw_meat", 0)) == 2 and int(momi.carry.get("timber", 0)) == 1 and absf(main.equipment.speed_mult(momi) - 1.25) < 0.001)
	momi.carry.clear()
	var thistle_m = await merc("티슬", "warrior", spot + Vector3(2, 0, -3))
	var thistle: int = await give("thistle_oath")
	res.commit(thistle, merc_sp(thistle_m))
	var es = enemy(thistle_m.global_position + Vector3(1, 0, 0))
	await frames(1)
	thistle_m.on_hit(es)
	check("엉겅퀴 맹세: 맞은 적이 느려짐(−40%)", absf(es.slow_factor() - 0.6) < 0.001, "%.2f" % es.slow_factor())
	await clear_enemies()
	# 요정의 맞바꿈
	var swap: int = await give("fae_swap")
	var bait: int = await give("feast_table")
	r = res.commit(swap, sp(spot))
	await frames(2)
	check("요정의 맞바꿈: 손패 카드 고르는 창이 열림", r.get("ok", false) and main.offer_ui.active and main.offer_ui.mode == "choice")
	var bait_i := -1
	for i in main.offer_ui.choice_items.size():
		if int(main.offer_ui.choice_items[i].get("uid", -1)) == bait:
			bait_i = i
	main.offer_ui.choose(bait_i)
	await frames(2)
	check("요정의 맞바꿈: 고른 카드를 내고 다른 계열 카드(또는 침식)를 받음", cards.get_entry(bait).is_empty() and rc.stats["swaps"] == 1 and not main.offer_ui.active)
	await close_ui()
	# 꿈 기록장
	var journal: int = await give("dream_journal")
	r = res.commit(journal, sp(main.player.global_position + Vector3(0, 1.0, 0)))
	check("꿈 기록장: 마녀에게만 장착", r.get("ok", false) and rc.witch_wears("dream_journal"), str(r.get("reason", "")))
	for id in ["timber", "wool", "meat_stew"]:
		cards.add(id, 1, "", "pocket")
	while cards.hand().size() > 4:
		cards.entries.erase(cards.hand()[0])
	var hand0: int = cards.hand().size()
	cards.morning_draw()
	await frames(2)
	check("꿈 기록장: 아침 드로우가 2장 중 1장 고르기 창으로", main.offer_ui.active and main.offer_ui.choice_items.size() == 2)
	main.offer_ui.choose(0)
	await frames(2)
	check("꿈 기록장: 고른 카드가 손패로", cards.hand().size() >= hand0 and not main.offer_ui.active)
	main.equipment.unequip(main.player, "trinket", false)

	# ── 5. 인간·브리지·화합
	var writ: int = await give("guild_writ")
	cards.add("lumberjack", 1, "올라프", "hand")
	r = res.commit(writ, sp(spot))
	await frames(2)
	var olaf_i := -1
	for i in main.offer_ui.choice_items.size():
		if main.offer_ui.choice_items[i].get("person", "") == "올라프":
			olaf_i = i
	main.offer_ui.choose(olaf_i)
	await frames(3)
	check("길드 증서: 계약 카드 고른 뒤 직업 고르는 창", main.offer_ui.active and main.offer_ui.choice_items.size() == 3)
	var pick_job: String = main.offer_ui.choice_items[0]["id"]
	main.offer_ui.choose(0)
	await frames(2)
	var olaf_job := ""
	for e in cards.entries:
		if e.get("person", "") == "올라프":
			olaf_job = e["id"]
	check("길드 증서: 올라프의 계약이 새 직업으로", olaf_job == pick_job and pick_job != "lumberjack", olaf_job)
	set_state(SessionScript.State.COMBAT)
	var mil: int = await give("village_militia")
	r = res.commit(mil, sp(harald.global_position + Vector3(1.5, 0, 0)))
	await frames(3)
	var militia: Array = rc.summons().filter(func(s): return s.kind == "militia")
	check("마을 민병: 밤에 민병 2명", r.get("ok", false) and militia.size() == 2)
	if militia.size() == 2:
		militia[0].global_position = harald.global_position + Vector3(1, 0, 0)
		check("마을 민병: 드워프 곁이면 받는 피해 −15%(드워프 패시브 절반)", absf(rc.summon_taken_mult(militia[0]) - 0.85) < 0.001)
		militia[0].global_position = garok.global_position + Vector3(0.5, 0, 0)
		check("마을 민병: 오크 곁이면 피해 +15%", rc.summon_damage_mult(militia[0]) >= 1.149)
	main.session.state = SessionScript.State.CLEARING
	rc._on_state(SessionScript.State.CLEARING)
	await frames(3)
	check("새벽(전투 정리)이 되면 민병이 돌아감", rc.summons().is_empty())
	set_state(SessionScript.State.PREP)
	rc.on_dawn(main.session.day())
	cards.add("corrupt_prayer", 1, "", "hand")
	var bless: int = await give("pilgrim_blessing")
	var rep0: int = rep.value
	res.commit(bless, sp(spot))
	check("순례자의 축복: 손패 침식 정화 · 소문 +12", cards.hand().filter(func(e): return cards.is_corruption(e["id"])).is_empty() and rep.value == rep0 + 12)
	var ration: int = await give("battle_ration")
	var bh: float = bram.max_hp
	bram.hp = 10.0
	res.commit(ration, sp(spot))
	check("전투 식량: 최대 체력 +40% · 감속 없음 · 체력 50% 회복", absf(bram.max_hp - bh * 1.4) < 0.5 and main.equipment.speed_mult(bram) == 1.0 and bram.hp > bram.max_hp * 0.45)
	rc.on_dawn(main.session.day())
	var banner: int = await give("crest_banner")
	res.commit(banner, sp(spot))
	check("여러 문장이 박힌 깃발: 서로 다른 종족 용병 3명+ → 전원 피해 +20%", rc.banner_up and rc.distinct_races(true) >= 3 and absf(main.equipment.damage_mult(bram) - 1.2) < 0.001,
		"%d종족 · %.2f" % [rc.distinct_races(true), main.equipment.damage_mult(bram)])

	# ── 6. 용병 이벤트
	var me = main.merc_events
	var ge = main.guest_events
	var roster: Array = me.full_roster()
	check("이벤트 명단에 모든 종족 용병(활동+계약 카드)", roster.any(func(s): return s["race"] == "dwarf") and roster.any(func(s): return s["race"] == "orc") and roster.any(func(s): return s["race"] == "fairy"))
	me.done.clear()
	check("브리지(드워프+오크)·화합(3종족) 조건 충족 시 이벤트를 꺼낼 수 있음", me.trigger(roster, "x_ration") and me.trigger(roster, "m_banner"))
	var day: int = main.session.day()
	check("숲의 약속 이벤트를 요정 용병이 꺼냄", me.trigger(roster, "f_promise"))
	var v: Dictionary = ge.visits[ge.visits.size() - 1]
	var fairy0: int = cards.entries.filter(func(e): return cards.def(e["id"]).get("race", "") == "fairy").size()
	var ok_p: bool = me.apply_effect(v, "merc:race:promise")
	var fairy1: int = cards.entries.filter(func(e): return cards.def(e["id"]).get("race", "") == "fairy").size()
	check("숲의 약속: 요정 카드 2장 · 다음날 하루 벌목 금지", ok_p and fairy1 == fairy0 + 2 and rc.lumber_ban_day == day + 1 and rc.lumber_block_reason() == "")
	rc.lumber_ban_day = day
	check("약속한 날에는 벌목 거부 사유", rc.lumber_block_reason() != "")
	rc.lumber_ban_day = -1
	me.trigger(roster, "o_bones")
	v = ge.visits[ge.visits.size() - 1]
	check("뼈 던지기: 대사에 오늘 밤 적 구성이 채워짐", not str(v.story["opening"]).contains("%s") and (str(v.story["opening"]).contains("거미") or str(v.story["opening"]).contains("괴물") or str(v.story["opening"]).contains("고요")), str(v.story["opening"]).replace("\n", " / "))
	me.apply_effect(v, "merc:race:bone_fate")
	set_state(SessionScript.State.COMBAT)
	var gold0: int = main.economy.gold
	var ef = enemy(spot + Vector3(3, 0, 6))
	await frames(1)
	ef.take_damage(9999.0)
	check("뼈 던지기 '운명': 오늘 밤 처치 골드 ×2", main.economy.gold == gold0 + 2, "%d → %d" % [gold0, main.economy.gold])
	set_state(SessionScript.State.PREP)
	rc.on_dawn(main.session.day())
	var bones_card: String = rc.prepare_card(day)
	check("뼈 던지기 '대비': 그 밤 적에 맞는 카드", cards.defs.has(bones_card), bones_card)
	# 조상의 길
	var kranya_entry := {"merc_event": "o_path", "merc_speaker": {"person": "크라냐"}}
	check("조상의 길: 말을 건 오크(계약 카드)가 떠남", me.apply_effect(kranya_entry, "merc:race:path_help") and rc.is_away("크라냐") and not cards.entries.any(func(e): return e.get("person", "") == "크라냐"))
	rc.on_dawn(day + 1)
	check("조상의 길: 다음 새벽에 계약 카드로 돌아오고 영구 강화", cards.entries.any(func(e): return e.get("person", "") == "크라냐") and float(rc.person_buffs.get("크라냐", {}).get("dmg", 0.0)) > 0.19)
	check("조상의 길: 피의 맹세 용병은 떠날 수 없음(이벤트 후보 제외)", me._options_for({"person": "가로크", "id": "garok", "race": "orc"}, roster, me.all_events(), false, "o_path").is_empty())
	# 소개장
	me.apply_effect({"merc_event": "h_letter"}, "merc:race:letter")
	await frames(2)
	check("소개장: 종족 고르는 창(6종족)", main.offer_ui.active and main.offer_ui.choice_items.size() == 6)
	var dwarf_i := -1
	for i in main.offer_ui.choice_items.size():
		if main.offer_ui.choice_items[i].get("race", "") == "dwarf":
			dwarf_i = i
	main.offer_ui.choose(dwarf_i)
	check("소개장: 다음 고용 손님을 드워프로 보장", main.economy.forced_hire_race == "dwarf")
	main.economy.forced_hire_race = ""
	await close_ui()
	# 오래된 기록 · 상인 마차
	me.apply_effect({"merc_event": "h_records"}, "merc:race:records_read")
	await frames(2)
	check("오래된 기록 '읽는다': 종족 카드 3장 중 1장 창", main.offer_ui.active and main.offer_ui.choice_items.size() == 3)
	await close_ui()
	cards.add("cursed_whisper", 1, "", "pocket")
	var cor0: int = main.chapter.corruption_count()
	me.apply_effect({"merc_event": "h_records"}, "merc:race:records_cover")
	check("오래된 기록 '덮는다': 침식 1장 정화", main.chapter.corruption_count() == cor0 - 1)
	main.economy.gold = 100
	me.apply_effect({"merc_event": "h_wagon"}, "merc:race:wagon")
	await frames(2)
	var wag_id: String = main.offer_ui.choice_items[0]["id"] if main.offer_ui.active else ""
	var wag0: int = count_of(wag_id)
	main.offer_ui.choose(0)
	check("상인 마차: 18G에 카드 1장 · 창은 열린 채(여러 장 구매 가능)", main.economy.gold == 82 and count_of(wag_id) == wag0 + 1 and main.offer_ui.active)
	check("상인 마차: 같은 칸은 다시 살 수 없음", not main.offer_ui.choose(0) or main.economy.gold == 82)
	await close_ui()
	# 축제·선물·대청소
	main.economy.gold = 10
	check("산장의 축제: 20G가 없으면 실패(fail_reply)", not me.apply_effect({"merc_event": "m_festival"}, "merc:race:festival"))
	main.economy.gold = 100
	var bram_hp: float = bram.max_hp
	check("산장의 축제: 용병 전원 영구 강화(최대 체력 +20 · 공격 +10%)", me.apply_effect({"merc_event": "m_festival"}, "merc:race:festival") and bram.max_hp == bram_hp + 20.0 and main.economy.gold == 80)
	var before_n: int = cards.entries.size()
	me.apply_effect({"merc_event": "n_gift"}, "merc:race:gift")
	check("낯선 손님의 선물: 카드 1장", cards.entries.size() >= before_n)
	cards.add("vine_snare", 1, "", "pocket")
	me.apply_effect({"merc_event": "n_cleanup"}, "merc:race:cleanup")
	await frames(2)
	var pocket0: int = cards.pocket().size()
	main.offer_ui.choose(0)
	check("산장 대청소: 주머니 카드 1장이 영구히 사라짐", cards.pocket().size() == pocket0 - 1 and rc.stats["cleaned"] == 1)
	await close_ui()
	# 이벤트 확률(통역사의 펜)
	check("공용 이벤트 확률 30%", absf(me.shared_chance() - 0.3) < 0.001)
	var pen: int = await give("interpreter_pen")
	res.commit(pen, sp(main.player.global_position + Vector3(0, 1.0, 0)))
	check("통역사의 펜: 공용 이벤트 확률 55%", absf(me.shared_chance() - 0.55) < 0.001)
	main.equipment.unequip(main.player, "trinket", false)
	# 고블린 이벤트도 같은 체계에서
	check("고블린 용병이 있으면 고블린 이벤트도 그대로(그라즈 '근처에 온 친척들')", me.trigger([{"person": "그라즈", "id": "graz"}], "gang"))
	# 겨울잠
	cards.add("warrior", 1, "우르소", "pocket")
	check("겨울잠: 수인이 다음 새벽까지 잠듦", me.apply_effect({"merc_event": "b_sleep", "merc_speaker": {"person": "우르소"}}, "merc:race:sleep") and rc.is_away("우르소"))
	rc.on_dawn(main.session.day() + 1)
	check("겨울잠: 돌아오면 최대 체력 +40 영구", float(rc.person_buffs.get("우르소", {}).get("hp_flat", 0.0)) == 40.0)
	ge.visits.clear()
	me.done.clear()

	# ── 7. 언데드
	check("언데드: 처음엔 잠겨 있고 단검도 없음", not ud.unlocked and not ud.dagger_given)
	main.economy.gold = 500
	cards.add("timber", 9, "", "hand")
	var bought: bool = main.economy.buy("graves")
	check("묘지를 처음 넓히면 제물의 단검 1장", bought and ud.dagger_given and count_of("sacrifice_dagger") == 1)
	main.chapter.altar_unlocked = true
	cards.add("timber", 5, "", "hand")
	main.chapter.restore_altar()
	check("제단 복구는 두 번째 단검을 주지 않음(한 판 한 번)", count_of("sacrifice_dagger") == 1)
	var victim = await merc("올라프", "hunter", spot + Vector3(-2, 0, -2))
	var dagger := -1
	for e in cards.entries:
		if e["id"] == "sacrifice_dagger":
			dagger = e["uid"]
	if cards.get_entry(dagger)["zone"] != "hand":
		cards.entries.erase(cards.get_entry(dagger))
		dagger = await give("sacrifice_dagger")
	rep0 = rep.value
	r = res.commit(dagger, merc_sp(victim))
	await frames(3)
	check("제물의 단검: 용병이 떠나고 시체 1 · 소문 −15 · 언데드가 열림", r.get("ok", false) and victim.dead and ud.corpse_count() == 1 and rep.value == rep0 - 15 and ud.unlocked)
	check("제물의 단검: 언데드 카드 3장 중 1장 창", main.offer_ui.active and main.offer_ui.choice_items.size() == 3 and main.offer_ui.choice_items.all(func(it): return it["id"] in Data.UNDEAD_POOL))
	main.offer_ui.choose(0)
	await close_ui()
	var mixed: Array = main.chapter.reward_choices()
	check("언데드가 열리면 새벽 보상 후보에 언데드 카드", mixed.any(func(id): return id in Data.UNDEAD_POOL or id in Data.UNDEAD_INFAMY), str(mixed))
	# 시체 부패
	var c_day: int = main.session.day()
	var cu: int = ud.give_corpse("시험")
	check("낮에 얻은 시체는 다음 새벽에 썩음(하루만 유지)", int(ud.corpse_expire.get(cu, -1)) == c_day + 1)
	set_state(SessionScript.State.COMBAT)
	var cu2: int = ud.give_corpse("시험2")
	check("밤에 얻은 시체는 그다음 새벽까지 남음", int(ud.corpse_expire.get(cu2, -1)) == c_day + 2)
	# 시체 → 해골
	var corpse_hand := -1
	for e in cards.entries:
		if e["id"] == "corpse":
			e["zone"] = "hand"
			corpse_hand = e["uid"]
	var n_c: int = ud.corpse_count()
	r = res.commit(corpse_hand, sp(spot + Vector3(2, 0, 2)))
	await frames(3)
	check("시체: 밤에 땅에 놓으면 해골 병사 1 · 시체 1구 소비", r.get("ok", false) and ud.undead_allies().size() == 1 and ud.corpse_count() == n_c - 1)
	var es2 = enemy(ud.undead_allies()[0].global_position + Vector3(0.8, 0, 0), "spider", 100.0)
	await get_tree().create_timer(1.5).timeout
	check("해골 병사가 가까운 적을 친다", es2.hp < 100.0, "%.0f" % es2.hp)
	await clear_enemies()
	# 영혼 병 · 뼈 사냥개 · 구울의 만찬
	ud.give_corpse("a")
	ud.give_corpse("b")
	ud.give_corpse("c")
	for id in ["timber", "wool"]:
		cards.add(id, 1, "", "pocket")
	var jar: int = await give("soul_jar")
	var nc0: int = ud.corpse_count()
	var draws0: int = cards.stats["drawn"]
	r = res.commit(jar, sp(spot))
	check("영혼 병: 시체 1 소비 · 주머니에서 2장(밤 카드가 모자라면 있는 만큼)", r.get("ok", false) and ud.corpse_count() == nc0 - 1 and cards.stats["drawn"] > draws0)
	var hounds: int = await give("bone_hounds")
	r = res.commit(hounds, sp(spot + Vector3(3, 0, 1)))
	await frames(3)
	check("뼈 사냥개: 시체 1로 사냥개 2마리", str(r.get("reason", "")) == "" and r.get("ok", false) and ud.undead_allies().filter(func(s): return s.kind == "hound").size() == 2)
	var hd = ud.undead_allies().filter(func(s): return s.kind == "hound")[0]
	var near_e = enemy(hd.global_position + Vector3(2, 0, 0), "spider", 100.0)
	var fleeing_e = enemy(hd.global_position + Vector3(6, 0, 0), "spider", 100.0)
	await frames(1)
	rc.scare(fleeing_e, hd.global_position, 4.0, 0.0)
	check("뼈 사냥개: 겁먹어 달아나는 적을 먼저 쫓음", hd._find_enemy() == fleeing_e)
	await clear_enemies()
	for e in cards.entries:
		if e["id"] == "corpse":
			e["zone"] = "hand"
	var feast_c: int = await give("ghoul_feast")
	var hc: int = ud.corpse_count(true)
	var sd0: float = rc.summon_damage_mult(hd)
	r = res.commit(feast_c, sp(spot))
	check("구울의 만찬: 손패 시체를 모두 써서 언데드 공격 +15%/구", r.get("ok", false) and ud.corpse_count(true) == 0 and absf(rc.summon_damage_mult(hd) - (sd0 + 0.15 * hc)) < 0.001, "%d구 · %.2f" % [hc, rc.summon_damage_mult(hd)])
	# 뼈 방책
	ud.give_corpse("d")
	var bb: int = await give("bone_barricade")
	check("뼈 방책: 시체 2구가 없으면 거부", not res.evaluate(bb, sp(spot + Vector3(0, 0, 5)))["ok"])
	ud.give_corpse("e")
	r = res.commit(bb, sp(spot + Vector3(0, 0, 5)))
	await frames(2)
	var bones: Array = rc.facilities("bone_barricade")
	check("뼈 방책: 시체 2구로 체력 120 방책", r.get("ok", false) and bones.size() == 1 and bones[0].max_hp == 120.0)
	if bones.size() == 1:
		bones[0].hp = 50.0
		var eb = enemy(bones[0].global_position + Vector3(2, 0, 0))
		await frames(1)
		eb.take_damage(9999.0)
		check("뼈 방책: 근처에서 적이 죽으면 +12", bones[0].hp == 62.0, str(bones[0].hp))
	# 일어나라 · 자동 시체
	var rise: int = await give("rise_up")
	res.commit(rise, sp(spot))
	var fallen = await merc("미라", "gatherer", spot + Vector3(3, 0, -3))
	var sk0: int = ud.undead_allies().size()
	var cc0: int = ud.corpse_count()
	fallen.take_damage(9999.0)
	await frames(3)
	check("일어나라: 쓰러진 용병이 해골로 일어남", ud.undead_allies().size() == sk0 + 1)
	check("언데드가 열린 뒤 쓰러진 용병은 자동으로 시체 카드(묻을까 묻지 않음)", ud.corpse_count() == cc0 + 1)
	# 죽음의 행진
	var march: int = await give("death_march")
	check("죽음의 행진: 시체 5구 미만이면 거부", ud.corpse_count() >= 5 or not res.evaluate(march, sp(spot))["ok"])
	while ud.corpse_count() < 6:
		ud.give_corpse("x")
	var sk1: int = ud.undead_allies().size()
	r = res.commit(march, sp(spot + Vector3(4, 0, 4)))
	await frames(3)
	check("죽음의 행진: 가진 시체 수만큼 해골", r.get("ok", false) and ud.corpse_count() == 0 and ud.undead_allies().size() >= sk1 + 6)
	main.session.state = SessionScript.State.CLEARING
	rc._on_state(SessionScript.State.CLEARING)
	await frames(3)
	check("새벽(전투 정리)이 되면 해골·사냥개가 무너짐", ud.undead_allies().is_empty())
	set_state(SessionScript.State.PREP)
	ud.give_corpse("rot")
	ud.on_dawn(main.session.day() + 1)
	check("시체: 하루 뒤 새벽에 썩어 사라짐", ud.corpse_count() == 0 and ud.stats["rotted"] >= 1)
	# 망자의 장부
	var ledger: int = await give("ledger_of_dead")
	res.commit(ledger, sp(main.player.global_position + Vector3(0, 1.0, 0)))
	ud.ledger_count = 4
	var v2 = await merc("토르빈", "lumberjack", spot + Vector3(-3, 0, 1))
	ud.sacrifice(v2)
	await frames(2)
	check("망자의 장부: 5번째 제물에 언데드 카드 한 장 더(창 2개 대기)", ud.stats["ledger_rewards"] == 1 and main.offer_ui.active and rc.has_pending())
	await close_ui()
	main.equipment.unequip(main.player, "trinket", false)

	# ── 8. 산장의 소문
	rep.value = 0
	rep.shift(-35, "시험")
	check("소문 −35 → '음산'", rep.tier() == "gloom")
	rep.shift(-40, "시험")
	check("소문 −75 → '악명' · 죽음의 행진이 언데드 후보에", rep.tier() == "infamy" and ud.undead_pool().has("death_march"))
	var rumors0: int = count_of("black_rumor")
	rep.on_dawn(5)
	check("악명: 새벽에 검은 소문이 주머니로", count_of("black_rumor") == rumors0 + 1)
	for e in cards.entries:
		if e["id"] == "black_rumor":
			e["zone"] = "hand"
	var cost: int = main.economy.contract_cost()
	check("검은 소문: 손패에 있으면 고용비 +8G", cost == Cfg.CONTRACT_COST + 8 * cards.hand().filter(func(e): return e["id"] == "black_rumor").size(), str(cost))
	var rv: int = rep.value
	var rum := -1
	for e in cards.entries:
		if e["id"] == "black_rumor":
			rum = e["uid"]
	main.chapter.purify_one()
	check("검은 소문 정화 → 소문 +5", rep.value == rv + 5 and count_of("black_rumor") == rumors0)
	rep.value = 40
	check("환대: 고용비 −5G", main.economy.contract_cost() == Cfg.CONTRACT_COST - 5)
	var bar = main.get_node_or_null("ReputationBar")
	if bar != null:
		bar.refresh()
	check("소문 막대가 구간 이름을 표시", bar != null and str(bar.label.text).contains("환대"))
	rep.value = 0
