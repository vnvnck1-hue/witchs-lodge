extends Node
## 마녀의 주머니(덱)·아침 드로우·버림패·드로우 카드 3종 자동 검증(기획: docs/region-season-pocket-design.md §6, 확정 규칙 1~10).
## 실제 게임 장면에서 인벤토리 호출·카드 판정·낮 전환을 재현한다. 실행: godot --headless --path . --script res://tools/verify_pocket.gd

const Cfg := preload("res://scripts/config.gd")
const Catalog := preload("res://scripts/ui/card_catalog.gd")
const SessionScript := preload("res://scripts/game/game_session.gd")

var main
var results: Array = []
var failures := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	while get_tree().current_scene == null or get_tree().current_scene.get("session") == null:
		await get_tree().process_frame
	main = get_tree().current_scene
	main.world.player_camera.toggle_overview()
	for i in 10:
		await get_tree().physics_frame
	main.session.set_process(false)   # 준비 시간이 흐르지 않게 고정하고 낮 전환은 직접 호출한다
	main.economy.set_process(false)
	if main.wildlife != null:
		main.wildlife.set_process(false)
	await _run()
	var out := {"passed": failures == 0, "checks": results.size(), "failures": failures, "results": results}
	var f := FileAccess.open("res://art_sources/pocket-verify.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(out, "\t") + "\n")
	print("POCKET_VERIFY passed=", failures == 0, " checks=", results.size(), " failures=", failures)
	print("RESULT %d/%d" % [results.size() - failures, results.size()])
	get_tree().quit(0 if failures == 0 else 1)


func check(name: String, ok: bool, detail := "") -> void:
	results.append({"check": name, "ok": ok, "detail": detail})
	if not ok:
		failures += 1
	print(("PASS " if ok else "FAIL ") + name + ("  — " + detail if detail != "" else ""))


func frames(n := 2) -> void:
	for i in n:
		await get_tree().physics_frame


func sp(p: Vector3) -> Vector2:
	return main.world.camera.unproject_position(p)


func uid_of(id: String, zone := "") -> int:
	for e in main.cards.entries:
		if e["id"] == id and (zone == "" or e["zone"] == zone):
			return e["uid"]
	return -1


func in_discard(id: String) -> bool:
	for e in main.cards.discard:
		if e["id"] == id:
			return true
	return false


func in_play(id: String) -> bool:
	for e in main.cards.in_play:
		if e["id"] == id:
			return true
	return false


func clear_cards() -> void:
	main.cards.entries.clear()
	main.cards.in_play.clear()
	main.cards.discard.clear()
	main.cards.last_drawn.clear()
	main.cards.changed.emit()


func _run() -> void:
	var cards = main.cards
	var res = main.resolver
	var sess = main.session
	var player = main.player

	# ── 0. 카탈로그·정의
	for id in ["poison_mushroom", "old_spellbook"]:
		var d: Dictionary = Catalog.find(id)
		check("카탈로그: %s 정의·문구 2줄" % id, not d.is_empty() and d.get("printed_rules", []).size() == 2 and cards.defs.has(id))
	check("자유 입출고 함수(move) 없음", not cards.has_method("move"))
	check("검증 시작 시 손패·주머니 비어 있음", cards.entries.is_empty())

	# ── 1. 시작 손패 고르기: 모두 주머니 → 3장 공개 → 1장 교체 → 손패(확정 규칙 2 + 사용자 결정)
	var total := 0
	for pair in Cfg.STARTER_CARDS:
		total += int(pair[1])
	var mul = main.mulligan_ui
	main.grant_starter_cards()
	await frames(2)
	check("시작: 고르기 화면 열림·시간 정지·아직 손패 없음", mul.active and get_tree().paused and cards.hand().is_empty() and cards.pocket().size() == total, _pause_cause())
	check("후보 %d장은 주머니의 서로 다른 카드" % Cfg.STARTER_DRAW, mul.offered.size() == Cfg.STARTER_DRAW and mul.offered.all(func(e): return cards.get_entry(e["uid"]).get("zone", "") == "pocket"))
	var t0 := 0.0
	while mul._phase != "pick" and t0 < 6.0:
		await get_tree().process_frame
		t0 += get_process_delta_time()
	check("세 장이 펼쳐진 뒤 고르기 단계", mul._phase == "pick" and mul.confirm_btn.visible, "phase=" + mul._phase)
	check("교체 표시는 1장만(두 번째 클릭이 앞 표시를 대체)", mul.toggle(0) and mul.toggle(2) and mul.marked == 2 and not mul.cards[0]["mark"].visible and mul.cards[2]["mark"].visible)
	var swap_uid: int = mul.cards[2]["uid"]
	var kept: Array = [mul.cards[0]["uid"], mul.cards[1]["uid"]]
	mul.confirm()
	t0 = 0.0
	while mul.active and t0 < 10.0:
		await get_tree().process_frame
		t0 += get_process_delta_time()
	await frames(3)
	check("확정 뒤 화면 닫힘·시간 재개", not mul.active and not get_tree().paused, _pause_cause())
	check("시작: 손패 %d장·주머니 %d장" % [Cfg.STARTER_DRAW, total - Cfg.STARTER_DRAW],
		cards.hand().size() == Cfg.STARTER_DRAW and cards.pocket().size() == total - Cfg.STARTER_DRAW,
		"hand=%d pocket=%d" % [cards.hand().size(), cards.pocket().size()])
	var hand_uids: Array = cards.hand().map(func(e): return e["uid"])
	check("교체한 카드는 주머니에 남고 손패에 없음", cards.get_entry(swap_uid).get("zone", "") == "pocket" and not swap_uid in hand_uids)
	check("남긴 두 장 + 새로 뽑은 다른 카드가 손패", kept[0] in hand_uids and kept[1] in hand_uids and mul.replacement.get("uid", -1) in hand_uids and mul.replacement["uid"] != swap_uid)
	check("손패는 받은 순서대로 오른쪽에 쌓임(마지막 카드 = 새로 뽑은 카드)", hand_uids.back() == mul.replacement["uid"], str(hand_uids))
	clear_cards()
	main.grant_starter_cards()
	await frames(2)
	t0 = 0.0
	while mul._phase != "pick" and t0 < 6.0:
		await get_tree().process_frame
		t0 += get_process_delta_time()
	mul.confirm()
	t0 = 0.0
	while mul.active and t0 < 10.0:
		await get_tree().process_frame
		t0 += get_process_delta_time()
	await frames(3)
	check("교체 없이 확정하면 펼친 세 장이 그대로 손패", cards.hand().size() == Cfg.STARTER_DRAW and mul.replacement.is_empty())
	await frames(3)

	# ── 2. 신규 획득: 손패 우선, 가득 차면 주머니(확정 규칙 1·3)
	clear_cards()
	for i in Cfg.HAND_VISIBLE:
		cards.add("frost_rune")
	check("손패 %d장 한도까지 손패에 들어감" % Cfg.HAND_VISIBLE, cards.hand().size() == Cfg.HAND_VISIBLE and cards.pocket().is_empty())
	var z: String = cards.add("ward_lantern")
	check("손패가 가득 차면 새 카드는 주머니로", z == "pocket" and cards.pocket().size() == 1 and cards.hand().size() == Cfg.HAND_VISIBLE)
	check("hand_full()", cards.hand_full())
	# 재화 1장=1개(2026-10-18): 목재 5개 = 낱장 5장. 손패가 가득 차면 모두 주머니로
	cards.add("timber", 5)
	check("손패가 가득 차면 재화 카드도 주머니로", uid_of("timber", "pocket") > 0 and uid_of("timber", "hand") == -1)
	cards.add("timber", 3)
	check("주머니의 목재는 낱장 8장(등불 1 + 목재 8)", cards.pocket().size() == 9 and cards.pocket_count_of("timber") == 8)

	# ── 3. 아침 드로우 건너뛰기·보존(확정 규칙 4)
	var pocket_before: int = cards.pocket_units()
	var got: Array = cards.morning_draw()
	check("손패가 가득 차면 아침 드로우를 건너뛰고 주머니 보존", got.is_empty() and cards.pocket_units() == pocket_before and cards.stats["skipped_draws"] == 1)

	# ── 4. 사용 카드 → 버림패, 자원은 수량 차감(확정 규칙 5)
	var fr := uid_of("frost_rune", "hand")
	check("서리 룬 소비 → 버림패로 이동(손패·주머니에서 사라짐)", cards.consume(fr) and cards.get_entry(fr).is_empty() and in_discard("frost_rune") and cards.discard.size() == 1)
	check("count_of 는 버림패를 세지 않음", cards.count_of("frost_rune") == Cfg.HAND_VISIBLE - 1)
	# 확정 규칙 9: 모든 자원 사용은 손패에 뽑힌 자원만
	check("주머니 속 목재(8)는 쓸 수 없음 — consume_id 거부·economy.timber() 0", not cards.consume_id("timber", 3) and cards.count_of("timber") == 8 and main.economy.timber() == 0 and cards.pocket_count_of("timber") == 8)
	# 재화 1장=1개: 목재 3장을 뽑으려면 손패 빈칸이 3개 필요하므로 서리 룬 2장을 더 쓴다
	cards.consume(uid_of("frost_rune", "hand"))
	cards.consume(uid_of("frost_rune", "hand"))
	cards.draw_uid(uid_of("timber", "pocket"))
	cards.draw_uid(uid_of("timber", "pocket"))
	cards.draw_uid(uid_of("timber", "pocket"))
	check("목재 3장을 손패로 뽑으면 economy.timber() 3", main.economy.timber() == 3 and cards.hand_count_of("timber") == 3)
	check("재화 소비는 손패의 낱장이 소멸(버림패 없음) · 주머니 목재는 그대로", cards.consume_id("timber", 3) and cards.count_of("timber") == 5 and cards.hand_count_of("timber") == 0 and cards.pocket_count_of("timber") == 5 and cards.discard.size() == 3)
	check("손패 목재가 모자라면 주머니 목재로 채우지 않음", not cards.consume_id("timber", 1))

	# ── 5. 무작위 드로우·재화 1장씩(확정 규칙 8)
	got = cards.draw(1)
	check("손패에 자리가 나면 draw(1) 성공", got.size() == 1 and cards.hand().size() == Cfg.HAND_VISIBLE - 2)
	clear_cards()
	cards.add("timber", 20, "", "pocket")
	var d1: Dictionary = cards.draw_uid(uid_of("timber", "pocket"))
	check("주머니 목재 20장에서 드로우 → 손패 목재 1·주머니 목재 19", d1.get("count", 0) == 1 and d1["zone"] == "hand" and cards.pocket_count_of("timber") == 19)
	cards.draw_uid(uid_of("timber", "pocket"))
	check("두 번째 드로우는 손패에 목재 카드 2장(낱장)", cards.hand_count_of("timber") == 2 and cards.pocket_count_of("timber") == 18 and cards.hand().size() == 2)
	cards.add("wool", 4)
	check("손패 우선: 손패에 자리가 있으면 재화도 손패로", uid_of("wool", "hand") > 0)
	cards.add("wool", 2)
	check("양털 6개 = 손패 양털 카드 6장(손패 8장 가득)", cards.hand_count_of("wool") == 6 and cards.hand().size() == Cfg.HAND_VISIBLE)

	# ── 6. 낮 전환 시 아침 드로우(GameSession)
	clear_cards()
	cards.add("lamb", 1, "", "pocket")
	cards.add("frost_rune", 1, "", "pocket")
	sess.wave_index = 1
	sess._enter_prep()
	await frames(2)
	check("새 낮 시작: 주머니에서 무작위 1장이 손패로", cards.hand().size() == 1 and cards.pocket().size() == 1 and cards.stats["morning_draws"] == 1, "hand=%s" % str(cards.hand().map(func(e): return e["id"])))
	sess.wave_index = 0
	sess._enter_prep()
	await frames(2)
	check("첫날(wave_index 0)은 아침 드로우 없음(시작 드로우가 대신)", cards.hand().size() == 1 and cards.pocket().size() == 1)

	# ── 7. 활동 카드: 활동 중 → 종료 시 버림패(확정 규칙 5)
	clear_cards()
	cards.add("ward_lantern")
	var ln := uid_of("ward_lantern")
	var ground: Vector3 = main.world.lodge.global_position + Vector3(0, 0, 5.0)
	var r: Dictionary = res.commit(ln, sp(ground))
	check("수호 등불 설치 → 활동 중 목록(버림패 아님)", r["ok"] and in_play("ward_lantern") and not in_discard("ward_lantern") and cards.get_entry(ln).is_empty(), r.get("reason", ""))
	var lanterns := get_tree().get_nodes_in_group("ward_lanterns")
	if not lanterns.is_empty():
		lanterns[0].extinguish()
	await frames(2)
	check("등불이 꺼지면 카드가 버림패로", in_discard("ward_lantern") and not in_play("ward_lantern"))

	cards.add("gatherer", 1, "미라")
	cards.add("frost_rune", 1, "", "pocket")
	sess.prep_elapsed = 0.0
	var gu := uid_of("gatherer")
	var hand_before: int = cards.hand().size()
	r = res.commit(gu, sp(ground + Vector3(1.5, 0, 0)))
	check("채집가 사용 → 활동 중 + 추가 효과로 1장 드로우(주머니 비워짐)", r["ok"] and in_play("gatherer") and cards.pocket().is_empty() and cards.hand().size() == hand_before and cards.stats["drawn"] >= 1, r.get("reason", ""))
	var g_ally = null
	for a in main.contracts.allies:
		if a.job == "gatherer":
			g_ally = a
	check("채집가 개체에 카드 uid 연결", g_ally != null and g_ally.card_uid == gu)
	if g_ally != null:
		g_ally.take_damage(99999.0)
	await frames(3)
	check("채집가가 쓰러지면 계약 카드가 버림패로", in_discard("gatherer") and not in_play("gatherer"))

	cards.add("gatherer", 1, "네리")
	var gu2 := uid_of("gatherer")
	r = res.commit(gu2, sp(ground + Vector3(-1.5, 0, 0)))
	check("주머니가 비어도 채집가는 사용 가능(드로우만 생략, 확정 규칙 7)", r["ok"] and in_play("gatherer") and uid_of("gatherer") == -1 and cards.pocket().is_empty(), r.get("reason", ""))
	for a in main.contracts.allies.duplicate():
		if is_instance_valid(a):
			a.take_damage(99999.0)
	await frames(3)

	# ── 8. 독버섯(확정 규칙 7, 체력 비용 시험값)
	clear_cards()
	player.hp = player.max_hp
	cards.add("poison_mushroom")
	var mu := uid_of("poison_mushroom")
	var psp := sp(player.global_position + Vector3(0, 1.0, 0))
	var ev: Dictionary = res.evaluate(mu, psp)
	check("독버섯: 주머니가 비면 사용 불가·비용 없음", not ev["ok"] and player.hp == player.max_hp and uid_of("poison_mushroom") == mu, ev.get("reason", ""))
	cards.add("frost_rune", 1, "", "pocket")
	check("독버섯: 마녀가 아닌 곳에는 사용 불가", not res.evaluate(mu, sp(ground))["ok"])
	player.hp = Cfg.MUSHROOM_HP_COST
	check("독버섯: 체력이 비용 이하이면 거부(치명적 비용 불허)", not res.evaluate(mu, psp)["ok"] and uid_of("poison_mushroom") == mu)
	player.hp = player.max_hp
	r = res.commit(mu, psp)
	check("독버섯 사용: 체력 -%d · 주머니에서 1장 드로우 · 독버섯은 버림패" % int(Cfg.MUSHROOM_HP_COST),
		r["ok"] and is_equal_approx(player.hp, player.max_hp - Cfg.MUSHROOM_HP_COST) and uid_of("frost_rune", "hand") > 0 and cards.pocket().is_empty() and in_discard("poison_mushroom"),
		"hp=%.1f reason=%s" % [player.hp, r.get("reason", "")])
	player.hp = player.max_hp

	# ── 9. 오래된 마법서적(확정 규칙 10)
	clear_cards()
	cards.add("old_spellbook")
	var bk := uid_of("old_spellbook")
	ev = res.evaluate(bk, sp(ground))
	check("마법서적: 주머니가 비면 사용 불가·비용 없음", not ev["ok"] and uid_of("old_spellbook") == bk, ev.get("reason", ""))
	for id in ["lamb", "ward_lantern", "guest_invitation", "black_sheep"]:
		cards.add(id, 1, "", "pocket")
	cards.add("timber", 5, "", "pocket")
	r = res.commit(bk, sp(ground))
	await frames(2)
	var ui = main.spellbook_ui
	check("마법서적 사용: 선택 화면 열림·시간 정지·서적은 버림패", r["ok"] and ui.active and get_tree().paused and in_discard("old_spellbook"), "paused=%s" % get_tree().paused)
	check("후보는 주머니의 서로 다른 카드 %d장" % Cfg.SPELLBOOK_CHOICES, ui.choices.size() == Cfg.SPELLBOOK_CHOICES and ui.choices.all(func(e): return cards.get_entry(e["uid"]).get("zone", "") == "pocket"))
	var pocket_units_before: int = cards.pocket_units()
	var chosen_id: String = ui.choices[1]["id"]
	check("검증 pick(1) 호출 성공", ui.pick(1))
	check("고른 카드가 손패로(묶음 자원이면 1개) · 나머지는 주머니에 유지", uid_of(chosen_id, "hand") > 0 and cards.hand().size() == 1 and cards.pocket_units() == pocket_units_before - 1,
		"chosen=%s hand=%d pocket_units=%d" % [chosen_id, cards.hand().size(), cards.pocket_units()])
	var t := 0.0
	while ui.active and t < 5.0:
		await get_tree().process_frame
		t += get_process_delta_time()
	await frames(2)
	check("선택 뒤 화면이 닫히고 시간이 다시 흐름", not ui.active and not get_tree().paused, _pause_cause())
	clear_cards()
	cards.add("old_spellbook")
	cards.add("wool", 1, "", "pocket")
	cards.add("lamb", 1, "", "pocket")
	bk = uid_of("old_spellbook")
	r = res.commit(bk, sp(ground))
	await frames(2)
	check("주머니에 2장뿐이면 후보 2장", r["ok"] and ui.choices.size() == 2)
	ui.pick(0)
	t = 0.0
	while ui.active and t < 5.0:
		await get_tree().process_frame
		t += get_process_delta_time()
	check("주머니 통계: 드로우 누적", cards.stats["drawn"] >= 5, str(cards.stats))

	# ── 9b. 채집가 줍기 표: 독버섯·마법서적 획득 경로(시험 확률)
	var total_p := 0.0
	var ids: Array = []
	for row in Cfg.GATHER_TABLE:
		total_p += float(row[1])
		ids.append(row[0])
	check("줍기 표 합 1.0 · 독버섯·마법서적 포함", is_equal_approx(total_p, 1.0) and "poison_mushroom" in ids and "old_spellbook" in ids, "sum=%.3f ids=%s" % [total_p, str(ids)])
	clear_cards()
	for a in main.contracts.allies.duplicate():
		if is_instance_valid(a):
			a.take_damage(99999.0)
	await frames(3)
	cards.add("gatherer", 1, "미라")
	sess.prep_elapsed = 0.0
	r = res.commit(uid_of("gatherer"), sp(ground + Vector3(1.5, 0, 0)))
	var ga = null
	for a in main.contracts.allies:
		if a.job == "gatherer":
			ga = a
	check("줍기 검사용 채집가 출발", r["ok"] and ga != null, r.get("reason", ""))
	if ga != null:
		# 같은 시드로 많이 굴려 두 카드가 실제로 나오는지, 서적은 하루 1권으로 묶이는지 본다
		main.contracts._rng.seed = 20261016
		for i in 400:
			main.contracts.gather_pick(ga)
		var mush: int = int(ga.carry.get("poison_mushroom", 0))
		var book: int = int(ga.carry.get("old_spellbook", 0))
		check("400회 굴림: 독버섯 다수 획득(들고 있음)", mush >= 10, "mushroom=%d carry=%s" % [mush, str(ga.carry)])
		check("400회 굴림: 마법서적은 하루 1권(초과분은 독버섯으로 대체)", book == Cfg.GATHER_BOOK_PER_DAY, "book=%d" % book)
		ga.carry.clear()
		ga.carry["old_spellbook"] = 1
		ga.carry["poison_mushroom"] = 2
		ga.global_position = player.global_position + Vector3(1.0, 0, 0)
		ga.hand_over()
		await frames(2)
		check("건네받은 독버섯·서적이 손패로", uid_of("old_spellbook") > 0 and cards.count_of("poison_mushroom") == 2, str(cards.hand().map(func(e): return e["id"])))
		main.contracts.on_prep_start()
		check("다음 낮에 서적 하루 한도 초기화", main.contracts._books_today == 0)
		ga.take_damage(99999.0)
		await frames(3)

	# ── 10. 주머니 목록 창: 보기 전용, 가격·이동 버튼 없음
	main.hud.card_hand.open_pocket()
	await frames(2)
	var buttons := 0
	for row in main.hud.card_hand.pocket_list.get_children():
		for c in row.get_children():
			if c is Button:
				buttons += 1
	check("주머니 창: 카드 목록만 있고 손패↔주머니 이동 버튼 없음", main.hud.card_hand.pocket_panel.visible and buttons == 0, "buttons=%d" % buttons)
	main.hud.card_hand.close_pocket()
	await frames(2)
	check("주머니 창 닫힘", not main.hud.card_hand.pocket_panel.visible and not get_tree().paused, _pause_cause())


func _pause_cause() -> String:
	var h = main.hud
	var on: Array = []
	for pair in [["Esc 메뉴", h.pause_panel], ["산장 관리 창", h.lodge_panel], ["판매 창", h.card_hand.sale_panel], ["주머니 창", h.card_hand.pocket_panel], ["종료 창", h.end_panel]]:
		if pair[1].visible:
			on.append(pair[0])
	if main.chest_ui != null and main.chest_ui.active:
		on.append("상자")
	if main.mulligan_ui != null and main.mulligan_ui.active:
		on.append("시작 손패")
	if main.spellbook_ui != null and main.spellbook_ui.active:
		on.append("마법서적")
	if main.session.is_over():
		on.append("게임 종료")
	return "열린 창: " + (", ".join(on) if not on.is_empty() else "없음")
