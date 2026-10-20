extends Node
## 술 주정뱅이 에린·주점 카드 v1 자동 검증(docs/tavern-cards-v01.md). 실제 게임 장면에서 카드 6장의 판정·사용,
## 에린 카드 추첨 확률, 술 카드 수로 에린이 찾아오는 흐름과 대화 효과, 불꽃 에일 배율·불·숙취, 꿀술 대접과 다음 날 선물,
## 도깨비불 독주 성공·실패, 망각의 이슬주 제거와 아침 드로우 감소, 술주정 섞어 넣기를 확인한다.
## 결과: res://art_sources/tavern-cards-verify.json

const Cfg := preload("res://scripts/config.gd")
const Layout := preload("res://scripts/world/layout.gd")
const MonsterScript := preload("res://scripts/actors/monster.gd")
const SessionScript := preload("res://scripts/game/game_session.gd")
const GuestProfiles := preload("res://scripts/ui/guest_profiles.gd")
const Dialogues := preload("res://scripts/game/guest_dialogues.gd")
const ChapterData := preload("res://scripts/game/chapter_data.gd")
const Catalog := preload("res://scripts/ui/card_catalog.gd")

const NEW_CARDS := ["drunken_erin", "fire_ale", "golden_mead", "wisp_spirit", "dew_of_forgetting", "drunk_rant"]

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
	var f := FileAccess.open("res://art_sources/tavern-cards-verify.json", FileAccess.WRITE)
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


func clear_hand() -> void:
	for e in main.cards.hand():
		main.cards.entries.erase(e)
	main.cards.changed.emit()


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


func enemy(pos: Vector3, hp := 200.0):
	var m := MonsterScript.new()
	m.setup(main, hp, false)
	m.configure("spider")
	m.position = pos
	main.actors.add_child(m)
	m.set_physics_process(false)
	return m


func merc(person: String, job: String, at: Vector3):
	var a = main.contracts.spawn_guard("merc", person, at, null, job)
	await frames(2)
	a.set_physics_process(false)
	return a


func set_state(s: int) -> void:
	main.session.state = s


func close_ui() -> void:
	if main.offer_ui.active:
		main.offer_ui.close()
	main.race_cards._pending.clear()
	await frames(2)


func _run() -> void:
	var tv = main.tavern
	var res = main.resolver
	var cards = main.cards
	await frames(5)
	main.waves.set_process(false)
	spot = Layout.DOOR_FRONT + Vector3(6, 0, 4)
	main.player.global_position = Layout.DOOR_FRONT + Vector3(-6, 0, 2)
	set_state(SessionScript.State.PREP)

	# ── 1. 데이터
	check("모듈이 붙어 있음(TavernCards)", tv != null and main.get_node_or_null("TavernCards") == tv)
	var missing: Array = NEW_CARDS.filter(func(id): return cards.def(id).is_empty())
	check("카탈로그에 주점 카드 6장", missing.is_empty(), str(missing))
	check("시간대: 꿀술은 낮, 나머지는 공용", cards.phase_of("golden_mead") == "day" and cards.phase_of("fire_ale") == "both"
		and cards.phase_of("drunken_erin") == "both" and cards.phase_of("drunk_rant") == "both" and cards.phase_of("dew_of_forgetting") == "both")
	# 사용자 확정 2026-10-20: 술은 재화가 아닌 소모품(낱장), 묶음은 원재료만 — 술주정도 낱장
	var drinks := ["fire_ale", "golden_mead", "wisp_spirit", "dew_of_forgetting"]
	check("술 4종은 낱장 소모품(재화·묶음 아님), 에린·술주정은 주문(낱장)", drinks.all(func(id): return cards.def(id).get("kind", "") == "consumable" and not cards.is_resource(id) and not cards.stackable(id))
		and cards.def("drunken_erin").get("kind", "") == "spell" and not cards.stackable("drunk_rant"))
	var w: Dictionary = tv.ERIN_WEIGHTS
	var total := 0
	for k in w:
		total += int(w[k])
	check("에린 가중치: 합 100 · 술주정 40 최고 · 금빛 꿀술 10 최저", total == 100 and int(w["drunk_rant"]) == 40 and int(w["golden_mead"]) == 10
		and int(w["fire_ale"]) == 20 and int(w["wisp_spirit"]) == 15 and int(w["dew_of_forgetting"]) == 15)
	check("술주정·에린 카드는 술로 세지 않음, 흑맥주·전투 식량은 셈", not "drunk_rant" in tv.DRINK_IDS and not "drunken_erin" in tv.DRINK_IDS
		and "dark_ale" in tv.DRINK_IDS and "battle_ration" in tv.DRINK_IDS)
	var market_ok := true
	for id in ["fire_ale", "golden_mead", "wisp_spirit", "dew_of_forgetting"]:
		if not id in ChapterData.MARKET_POOL or not ChapterData.MARKET_PRICES.has(id):
			market_ok = false
	check("장날 행상이 술 4종을 판다(에린을 부를 다른 경로)", market_ok)
	var art_ok := true
	for id in NEW_CARDS:
		var t: Texture2D = Catalog.texture(id)
		var h: Texture2D = Catalog.texture(id, true)
		if t == null or h == null or t.resource_path == Catalog.back(false).resource_path or t.get_width() != 1024 or h.get_width() != 256:
			art_ok = false
	check("카드 원화 6장이 납품되어 뒷면 대신 로드(1024·손패 256)", art_ok)
	var erin := GuestProfiles.character("erin")
	check("에린 대화 초상이 납품됨(실루엣 아님)", not erin.get("portrait_missing", true) and erin["portrait"].ends_with("guest_erin_cutout.png"))
	check("에린은 특별 손님: 프로필이 있고 무작위 손님 명부(42명)에는 없음", not erin.is_empty() and erin["person"] == "에린"
		and GuestProfiles.CATALOG.filter(func(c): return c["id"] == "erin").is_empty())

	# ── 2. 에린 카드 추첨 확률(중복 가능 독립 추첨)
	var tally := {}
	var n := 20000
	for i in n:
		var id: String = tv.roll_erin()
		tally[id] = int(tally.get(id, 0)) + 1
	var off := 0.0
	for k in w:
		off = maxf(off, absf(float(tally.get(k, 0)) / n * 100.0 - float(w[k])))
	check("에린 추첨 2만 번: 다섯 카드 모두 가중치 ±1.5%p 안", tally.size() == 5 and off < 1.5, str(tally))
	clear_hand()
	cards.entries = cards.entries.filter(func(e): return not e["id"] in NEW_CARDS)
	var erin_uid: int = await give("drunken_erin")
	var r: Dictionary = res.commit(erin_uid, sp(spot))
	var got_n := 0
	for id in tv.ERIN_WEIGHTS:
		got_n += cards.count_of(id)
	check("술 주정뱅이 에린: 쓰면 사라지고 5종 가운데 3장", r.get("ok", false) and cards.count_of("drunken_erin") == 0 and got_n == 3, "받은 %d장" % got_n)
	check("에린 카드는 술로 세지 않음", tv.drinks == 0)

	# ── 3. 술 카드 수 → 에린 방문 → 대화
	tv.drinks = 0
	tv.erin_waiting = false
	var rant_uid: int = await give("drunk_rant")
	res.commit(rant_uid, sp(spot))
	check("술주정을 써도 에린 조건은 그대로", tv.drinks == 0)
	var ale: int = await give("dark_ale")
	r = res.commit(ale, sp(spot))
	check("흑맥주 통(종족 카드)도 술로 셈", r.get("ok", false) and tv.drinks == 1, str(tv.drinks))
	main.race_cards.night.clear()
	tv.on_card_used("wisp_spirit")
	check("술 2장째: 아직 에린은 오지 않음", tv.drinks == 2 and not tv.erin_waiting)
	tv.on_card_used("fire_ale")
	check("술 3장째: 에린이 찾아올 차례", tv.erin_waiting)
	var extra: Array = tv.extra_guests([])
	check("다음 손님 무리에 에린이 덤으로 붙음", extra.size() == 1 and extra[0]["character_id"] == "erin", str(extra.map(func(p): return p["character_id"])))
	check("같은 날 다음 무리에는 다시 붙지 않음(거절하면 내일)", tv.extra_guests([]).is_empty())
	main.guest_events._on_batch(extra)
	var visit: Dictionary = main.guest_events.visits.back()
	main.guest_events.admit(visit.profile)
	visit.ready_at = -1.0
	main.guest_events._process(0.0)
	check("에린은 표본 추출 없이 항상 말을 건다(에린 이야기)", visit.ready and visit.story.get("special", "") == "erin", str(visit.story.get("title", "")))
	var before: int = cards.count_of("drunken_erin")
	var ok: bool = main.guest_events.apply_effect(visit.uid, Dialogues.ERIN_STORY["choices"][0]["effect"])
	check("대화 '좋아, 한잔하고 가' → 에린 카드 1장, 조건은 0부터 다시", ok and cards.count_of("drunken_erin") == before + 1 and not tv.erin_waiting and tv.drinks == 0)
	check("에린 카드를 이미 받았으면 같은 효과는 실패(fail_reply)", not main.guest_events.apply_effect(visit.uid, "tavern:erin"))
	main.guest_events.complete(visit.uid, "좋아", [])
	check("에린 이야기는 손님 평소 이야기를 소모하지 않음", not main.guest_events.completed_stories.has("erin"))
	main.guest_events._on_departed(visit.profile, "퇴실")

	# ── 4. 불꽃 에일
	set_state(SessionScript.State.COMBAT)
	var bram = await merc("브람", "warrior", spot + Vector3(1, 0, 0))
	var base_mult: float = bram._damage_mult()
	var fa: int = await give("fire_ale")
	r = res.evaluate(fa, sp(spot + Vector3(8, 0, 8)))
	check("불꽃 에일: 용병이 아닌 곳은 거부", not r["ok"])
	r = res.commit(fa, sp(bram.global_position + Vector3(0, bram.hp_offset * 0.5, 0)))
	check("불꽃 에일: 용병에게 쓰면 공격력 ×1.4", r.get("ok", false) and absf(bram._damage_mult() - base_mult * 1.4) < 0.001, "%.2f → %.2f" % [base_mult, bram._damage_mult()])
	var fa2: int = await give("fire_ale")
	check("불꽃 에일: 같은 밤 같은 용병에게 두 번은 거부", not res.evaluate(fa2, sp(bram.global_position + Vector3(0, bram.hp_offset * 0.5, 0)))["ok"])
	var foe = enemy(spot + Vector3(1.6, 0, 0), 500.0)
	await frames(1)
	for i in 4:
		bram.on_hit(foe)
	check("불꽃 에일: 처음 3번만 불을 붙임", tv.stats["ignites"] == 3 and int(tv.fire["브람"]) == 0, str(tv.stats["ignites"]))
	var hp0: float = foe.hp
	for i in 10:
		tv._process(0.25)
	check("불붙은 적이 시간이 지나며 피해를 받음", foe.hp < hp0 - 10.0, "%.1f → %.1f" % [hp0, foe.hp])
	set_state(SessionScript.State.PREP)
	tv._on_state(SessionScript.State.PREP)
	check("새벽: 공격 배율이 풀리고 숙취가 걸림", absf(bram._damage_mult() - base_mult) < 0.001 and tv.hungover(bram))
	check("숙취 중 용병 상태 글이 '숙취'", bram.status_text().begins_with("숙취"), bram.status_text())
	tv._process(tv.HANGOVER_TIME + 0.1)
	check("숙취는 낮 30초 뒤 풀림", not tv.hungover(bram))
	foe.queue_free()

	# ── 5. 금빛 꿀술
	var gm: int = await give("golden_mead")
	check("금빛 꿀술: 묵는 손님이 없으면 거부", not res.evaluate(gm, sp(spot))["ok"])
	var guest := GuestProfiles.guest_profile("harald")
	main.guest_events._on_batch([guest])
	var gv: Dictionary = main.guest_events.visits.back()
	main.guest_events.admit(gv.profile)
	set_state(SessionScript.State.COMBAT)
	check("금빛 꿀술: 밤에는 거부", not res.evaluate(gm, sp(spot))["ok"])
	set_state(SessionScript.State.PREP)
	var gold0: int = main.economy.gold
	r = res.commit(gm, sp(spot))
	await frames(2)
	check("금빛 꿀술: 쓰면 손님을 고르는 창이 열림", r.get("ok", false) and main.offer_ui.active)
	await close_ui()
	check("대접: 숙박비 +50%(8G) · 호감 +1 · 내일 재방문 예약", tv.serve_mead(gv.uid) and main.economy.gold == gold0 + int(round(Cfg.GUEST_FEE * 0.5))
		and int(tv.favor.get("harald", 0)) == 1 and tv.mead_returns.size() == 1, "%d → %d" % [gold0, main.economy.gold])
	check("같은 날 같은 손님에게 또 대접할 수는 없음", tv.mead_guests().filter(func(v): return v.uid == gv.uid).is_empty())
	main.guest_events._on_departed(gv.profile, "퇴실")
	check("오늘은 아직 재방문하지 않음", tv.extra_guests([]).is_empty())
	main.session.wave_index += 1
	var today: int = main.session.day()
	tv.mead_returns[0]["day"] = today
	var back: Array = tv.extra_guests([])
	check("다음 날 그 손님이 덤 손님으로 다시 옴", back.size() == 1 and back[0]["character_id"] == "harald" and back[0].get("mead_gift", false))
	var hand_before: int = cards.entries.size()
	var gifts0: int = tv.stats["gifts"]
	tv._on_admitted(back[0])
	check("입실하면 그 종족(드워프) 카드를 선물로 줌", tv.stats["gifts"] == gifts0 + 1 and cards.entries.size() >= hand_before)
	tv._on_admitted(back[0])
	check("선물은 한 번만", tv.stats["gifts"] == gifts0 + 1)

	# ── 6. 도깨비불 독주
	clear_hand()
	var target: int = await give("moss_bandage")
	var ws: int = await give("wisp_spirit")
	check("도깨비불 독주: 부을 카드가 있으면 사용 가능", res.evaluate(ws, sp(spot))["ok"])
	var c0: int = cards.count_of("moss_bandage")
	tv.wisp(target, 1)
	check("성공: 같은 카드가 한 장 더", cards.count_of("moss_bandage") == c0 + 1)
	var in_hand0: int = cards.hand_count_of("moss_bandage")
	tv.wisp(target, 0)
	check("실패: 그 카드는 사라지지 않고 주머니로", cards.hand_count_of("moss_bandage") == in_hand0 - 1 and cards.count_of("moss_bandage") == c0 + 1)
	await frames(3)  # 앞 사용의 스택 드로우가 끝난 뒤에 손패를 비운다
	clear_hand()
	var ws_only: int = await give("wisp_spirit")
	for e in cards.hand():
		if e["uid"] != ws_only:
			cards.entries.erase(e)
	check("손패에 다른 카드가 없으면 거부", not res.evaluate(ws_only, sp(spot))["ok"])

	# ── 7. 망각의 이슬주
	cards.add("poison_mushroom", 1, "", "pocket")
	var pm: Dictionary = {}
	for e in cards.pocket():
		if e["id"] == "poison_mushroom":
			pm = e
	var dw: int = await give("dew_of_forgetting")
	var pocket0: int = cards.pocket_units()
	r = res.commit(dw, sp(spot))
	await frames(2)
	check("망각의 이슬주: 쓰면 주머니 카드 고르는 창(최대 3장)", r.get("ok", false) and main.offer_ui.active and main.offer_ui.choice_items.size() <= 3)
	await close_ui()
	await frames(3)  # 카드 사용 스택 드로우(3장마다 1장)가 끝난 뒤에 주머니를 센다
	cards.add("poison_mushroom", 1, "", "pocket")
	for e in cards.pocket():
		if e["id"] == "poison_mushroom":
			pm = e
	pocket0 = cards.pocket_units()
	var gone: String = tv.forget(pm["uid"])
	check("고른 카드는 이번 판에서 영구히 사라짐", gone == "poison_mushroom" and cards.pocket_units() == pocket0 - 1 and not cards.discard.any(func(d): return d["uid"] == pm["uid"]))
	cards.add("moss_bandage", 1, "", "pocket")
	clear_hand()
	var drawn: Array = cards.morning_draw()
	check("다음 날 아침 드로우 −1(1장 → 0장)", drawn.is_empty() and tv.draw_penalty == 0)
	drawn = cards.morning_draw()
	check("감소는 한 번만, 그다음 아침은 정상", drawn.size() == Cfg.MORNING_DRAW)

	# ── 8. 술주정
	clear_hand()
	for id in ["moss_bandage", "poison_mushroom", "lamb"]:
		await give(id)
	cards.add("winter_firewood", 1, "", "pocket")
	cards.add("resin_torch", 1, "", "pocket")
	var dr: int = await give("drunk_rant")
	var hand0: int = cards.hand().size()
	var p0: int = cards.pocket_units()
	r = res.commit(dr, sp(spot))
	check("술주정: 손패 2장을 주머니로 섞고 1장을 뽑음(손패 −2)", r.get("ok", false) and cards.hand().size() == hand0 - 1 - 2 + 1 and cards.pocket_units() == p0 + 2 - 1,
		"손패 %d → %d · 주머니 %d → %d" % [hand0, cards.hand().size(), p0, cards.pocket_units()])
	await close_ui()

	# ── 9. 술주정 일러스트 3종(사용자 확정 2026-10-20): 뽑을 때 무작위, 여러 장이면 서로 다른 그림
	cards.entries = cards.entries.filter(func(e): return e["id"] != "drunk_rant")
	check("술주정 일러스트 변형 3종이 카탈로그에 있고 파일이 모두 있음", Catalog.variant_count("drunk_rant") == 3
		and Catalog.variant_texture("drunk_rant", 1).get_width() == 1024 and Catalog.variant_texture("drunk_rant", 2, true).get_width() == 256
		and Catalog.variant_texture("drunk_rant", 1) != Catalog.variant_texture("drunk_rant", 2))   # 합성 텍스처라 resource_path 가 없어 객체로 비교
	check("술주정은 묶음이 아니라 한 장씩(그림이 따로 보이도록)", not cards.stackable("drunk_rant"))
	var ok3 := true
	for trial in 30:
		cards.entries = cards.entries.filter(func(e): return e["id"] != "drunk_rant")
		for i in 3:
			cards.add("drunk_rant", 1, "", "pocket" if i == 1 else "")
		var arts := {}
		for e in cards.entries:
			if e["id"] == "drunk_rant":
				arts[int(e.get("art", -1))] = true
		if arts.size() != 3 or arts.has(-1):
			ok3 = false
	check("술주정 3장을 가지면(손패·주머니 섞여도) 그림 3종이 모두 다름(30회)", ok3)
	cards.add("drunk_rant", 1, "", "pocket")
	var arts4: Array = cards.entries.filter(func(e): return e["id"] == "drunk_rant").map(func(e): return int(e.get("art", -1)))
	check("4장째는 세 그림 가운데 아무거나(그래도 그림 번호는 있음)", arts4.size() == 4 and arts4.all(func(a): return a >= 0 and a < 3))
	var seen := {}
	for trial in 60:
		cards.entries = cards.entries.filter(func(e): return e["id"] != "drunk_rant")
		cards.add("drunk_rant")
		seen[int(cards.entries.filter(func(e): return e["id"] == "drunk_rant")[0]["art"])] = true
	check("한 장만 뽑을 때도 세 그림이 무작위로 나옴(60회 중 3종 모두)", seen.size() == 3, str(seen.keys()))
	var hand_ui = main.hud.card_hand
	var t0: Texture2D = hand_ui._surface("drunk_rant", "", 0)
	var t2: Texture2D = hand_ui._surface("drunk_rant", "", 2)
	check("손패 화면이 카드마다 기록된 그림을 보여 줌", t0 != null and t2 != null and t0 != t2 and t2.get_width() == 256)
	cards.entries = cards.entries.filter(func(e): return e["id"] != "drunk_rant")
	tv.use_erin()
	var rant_arts: Array = cards.entries.filter(func(e): return e["id"] == "drunk_rant").map(func(e): return int(e["art"]))
	var uniq := {}
	for a in rant_arts:
		uniq[a] = true
	check("에린 카드에서 술주정이 여러 장 나오면 서로 다른 그림", uniq.size() == rant_arts.size(), str(rant_arts))

	# ── 10. 디버그 패널(F1) 프리셋 버튼: 에린·술 카드 지급, 에린 방문 부르기
	set_state(SessionScript.State.PREP)
	cards.entries = cards.entries.filter(func(e): return not e["id"] in NEW_CARDS and not cards.is_job(e["id"]))
	main.debug_tavern_cards()
	var got_ok: bool = cards.count_of("drunken_erin") == 1 and cards.count_of("fire_ale") == 1 and cards.count_of("golden_mead") == 1 \
		and cards.count_of("wisp_spirit") == 1 and cards.count_of("dew_of_forgetting") == 1 and cards.count_of("drunk_rant") == 2
	var rant2: Array = cards.entries.filter(func(e): return e["id"] == "drunk_rant").map(func(e): return int(e["art"]))
	check("프리셋 '에린·술 카드 지급': 에린+술 4종+술주정 2장(다른 그림)+전투 용병 계약", got_ok and rant2.size() == 2 and rant2[0] != rant2[1]
		and cards.entries.any(func(e): return e["id"] == "warrior"), str(rant2))
	var labels: Array = []
	for b in main.hud.debug_panel.find_children("*", "Button", true, false):
		labels.append(b.text)
	check("디버그 패널(F1)에 두 버튼이 있음", "에린·술 카드 지급" in labels and "에린 방문 부르기" in labels)
	tv.erin_waiting = false
	var batches0: int = main.economy.batches.size()
	main.session.prep_elapsed = 0.0
	main.debug_erin_visit()
	check("프리셋 '에린 방문 부르기': 에린 차례가 되고 낮이면 손님 무리를 바로 부름", tv.erin_waiting and main.economy.batches.size() == batches0 + 1)
