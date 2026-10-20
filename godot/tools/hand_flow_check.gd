extends Node
## 손패 흐름 v1 자동 검증(기획: docs/hand-draw-flow-design-v01.md §7, 사용자 확정 2026-10-18).
## 실제 게임 장면에서 인벤토리·판정·낮밤 전환을 재현한다. 실행: godot --headless --path . --script res://tools/verify_hand_flow.gd

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
	main.session.set_process(false)
	main.economy.set_process(false)
	if main.wildlife != null:
		main.wildlife.set_process(false)
	await _run()
	var out := {"passed": failures == 0, "checks": results.size(), "failures": failures, "results": results}
	var f := FileAccess.open("res://art_sources/hand-flow-verify.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(out, "\t") + "\n")
	print("HAND_FLOW_VERIFY passed=", failures == 0, " checks=", results.size(), " failures=", failures)
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


func ids(zone: String) -> Array:
	return main.cards.entries.filter(func(e): return e["zone"] == zone).map(func(e): return e["id"])


func in_discard(id: String) -> bool:
	for e in main.cards.discard:
		if e["id"] == id:
			return true
	return false


func clear_cards() -> void:
	main.cards.entries.clear()
	main.cards.in_play.clear()
	main.cards.discard.clear()
	main.cards.last_drawn.clear()
	main.cards.draw_stack = 0
	main.cards.burns_today = 0
	main.cards.resource_uses_today.clear()
	main.cards._returned_uids.clear()
	main.cards.changed.emit()


func set_phase(night: bool) -> void:
	main.session.state = SessionScript.State.COMBAT if night else SessionScript.State.PREP


func _run() -> void:
	var cards = main.cards
	var res = main.resolver
	var sess = main.session
	var player = main.player
	var yard = main.world.yard

	# ── 0. 시간대 표: 손패에 들어올 수 있는 모든 카드가 표에 있다(유물은 손패를 거치지 않는다)
	var missing: Array = []
	for d in Catalog.read().get("cards", []):
		if str(d.get("kind", "")) in ["relic", "event"]:  # 사건 카드(종족 카드 v1)는 대화 이벤트라 손패에 들어오지 않는다
			continue
		if not Cfg.CARD_PHASE.has(d["id"]):
			missing.append(d["id"])
	check("CARD_PHASE: 유물·사건 외 모든 카드에 시간대가 있음", missing.is_empty(), str(missing))
	# 묶음은 원재료 6종뿐, 술·요리 같은 소모품은 낱장(사용자 확정 2026-10-20)
	var raw_ids: Array = []
	var stack_ids: Array = []
	var bad_consumables: Array = []
	for d in Catalog.read().get("cards", []):
		if str(d.get("kind", "")) == "resource":
			raw_ids.append(d["id"])
		if bool(d.get("stackable", false)):
			stack_ids.append(d["id"])
		if str(d.get("kind", "")) == "consumable" and bool(d.get("stackable", false)):
			bad_consumables.append(d["id"])
	raw_ids.sort()
	stack_ids.sort()
	var raw_expected := ["black_wool", "rabbit_pelt", "raw_meat", "scrap", "timber", "wool"]
	check("재화(묶음)는 원재료 6종뿐: 양털·검은 털·목재·생고기·토끼 가죽·쇠붙이", raw_ids == raw_expected and stack_ids == raw_expected, "resource=%s stackable=%s" % [str(raw_ids), str(stack_ids)])
	var cons_expected := ["fire_ale", "golden_mead", "spit_roast", "feast_table", "winter_firewood", "battle_ration", "meat_stew", "dark_ale", "wisp_spirit", "dew_of_forgetting", "soul_jar", "junk_sack", "corpse"]
	check("술·요리·꾸러미 13종은 소모품(consumable) 낱장", bad_consumables.is_empty() and cons_expected.all(func(id): return str(cards.def(id).get("kind", "")) == "consumable" and not cards.stackable(id)))
	clear_cards()
	cards.add("fire_ale", 3, "", "hand")
	check("소모품은 여러 개 받아도 한 장씩 따로 들어옴", cards.hand().size() == 3 and cards.hand().all(func(e): return int(e["count"]) == 1))
	cards.draw_stack = 0
	cards.consume(cards.hand()[0]["uid"])
	cards.consume(cards.hand()[0]["uid"])
	check("소모품은 쓸 때마다 스택 +1이고 버림패로 감", cards.draw_stack == 2 and in_discard("fire_ale"), "stack=%d" % cards.draw_stack)
	cards.draw_stack = 0
	check("시간대 값은 day/night/both/none 뿐", Cfg.CARD_PHASE.values().all(func(v): return v in ["day", "night", "both", "none"]))
	check("시작 손패 후보(시작 카드)에 낮 카드가 STARTER_DRAW장 이상", Cfg.STARTER_CARDS.filter(func(p): return cards.fits_phase(p[0], "day")).size() >= Cfg.STARTER_DRAW)
	set_phase(false)
	check("준비 시간 = 낮, 전투 = 밤", cards.current_phase() == "day" and cards.phase_of("frost_rune") == "night" and cards.phase_of("lamb") == "day" and cards.phase_of("raw_meat") == "both" and cards.phase_of("corrupt_prayer") == "none")

	# ── 1. 손패 진입: 지금 시간대 카드만 손패로, 아니면 주머니로
	clear_cards()
	check("낮에 서리 룬(밤)을 얻으면 주머니로", cards.add("frost_rune") == "pocket" and uid_of("frost_rune", "pocket") > 0)
	check("낮에 수호 등불(낮)은 손패로", cards.add("ward_lantern") == "hand")
	check("양쪽 카드(생고기)는 낮에도 손패로", cards.add("raw_meat", 2) == "hand")
	check("침식 카드는 시간대와 무관하게 손패를 막음", cards.add("corrupt_prayer") == "hand")
	check("낮에 목재(낮) 묶음은 손패로", cards.add("timber", 3) == "hand" and cards.hand_count_of("timber") == 3)
	set_phase(true)
	check("밤에 목재를 더 얻으면 주머니 묶음으로(손패 묶음이 있어도)", cards.add("timber", 2) == "pocket" and cards.pocket_count_of("timber") == 2 and cards.hand_count_of("timber") == 3)
	check("밤에 덩굴 덫(밤)은 손패로", cards.add("vine_snare") == "hand")
	set_phase(false)

	# ── 2. 드로우는 지금 시간대 카드에서만
	clear_cards()
	cards.add("frost_rune", 1, "", "pocket")
	cards.add("resin_torch", 1, "", "pocket")
	cards.add("lamb", 1, "", "pocket")
	check("낮 드로우 후보 = 낮·양쪽 카드만(1장)", cards.eligible_pocket().size() == 1 and cards.eligible_pocket()[0]["id"] == "lamb")
	var got: Array = cards.draw(1)
	check("draw(1)은 새끼양을 뽑고 밤 카드는 남김", got.size() == 1 and got[0]["id"] == "lamb" and ids("pocket") == ["frost_rune", "resin_torch"])
	check("draw_uid로 밤 카드를 낮에 뽑을 수 없음", cards.draw_uid(uid_of("frost_rune")).is_empty() and uid_of("frost_rune", "pocket") > 0)
	check("낮에 뽑을 카드가 없으면 아침 드로우 없음(주머니 보존)", cards.morning_draw().is_empty() and cards.pocket().size() == 2)
	check("마법서적 후보도 시간대 필터", cards.draw_choices(3).is_empty())
	check("시작 손패 교체 후보도 시간대 필터", cards.peek_random_pocket().is_empty())

	# ── 3. 낮 → 밤 전환: 낮 카드는 주머니로, 넣은 만큼 밤 카드를 뽑는다(양쪽·침식은 남음)
	clear_cards()
	for id in ["ward_lantern", "lamb"]:
		cards.add(id)
	cards.add("timber", 5)
	cards.add("raw_meat", 2)
	cards.add("corrupt_prayer")
	for id in ["frost_rune", "vine_snare", "resin_torch", "firefly_swarm"]:
		cards.add(id, 1, "", "pocket")
	cards.add("timber", 3, "", "pocket")
	set_phase(true)
	var sw: Dictionary = cards.phase_swap("night")
	var hand_ids: Array = ids("hand")
	check("낮 카드 3장(등불·새끼양·목재 묶음)이 주머니로", sw["out"] == 3 and uid_of("ward_lantern", "pocket") > 0 and uid_of("lamb", "pocket") > 0 and uid_of("timber", "hand") == -1, str(hand_ids))
	check("목재 묶음은 주머니 묶음에 합쳐짐(5+3=8, 묶음 1개)", cards.pocket_count_of("timber") == 8 and cards.pocket().filter(func(e): return e["id"] == "timber").size() == 1)
	check("넣은 만큼(3장) 밤 카드를 무작위로 뽑음", sw["in"].size() == 3 and sw["in"].all(func(e): return cards.phase_of(e["id"]) == "night"))
	check("양쪽 카드(생고기)와 침식 카드는 손패에 남음", "raw_meat" in hand_ids and "corrupt_prayer" in hand_ids and cards.hand().size() == 5, str(hand_ids))
	check("밤 카드 1장은 주머니에 남음", cards.eligible_pocket("night").size() == 1)
	check("통계: swapped_out 3 · swapped_in 3", cards.stats["swapped_out"] == 3 and cards.stats["swapped_in"] == 3)
	# 순차 연출(사용자 요청 2026-10-18): 나가는 카드는 제자리에서 차례를 기다리고, 들어오는 카드는 주머니 안에 숨어 있다가 한 장씩 공개된다
	var ch = main.hud.card_hand   # changed 신호를 동기로 받아 대기열이 이미 채워져 있다(첫 카드는 첫 프레임에 바로 출발)
	check("전환 연출: 나가는 3장 대기열 · 들어오는 3장 숨김 대기열", ch._pending_out.size() == 3 and ch._pending_in.size() == 3 and ch.swap_animating(), "out=%d in=%d" % [ch._pending_out.size(), ch._pending_in.size()])
	check("들어오는 카드는 공개 전까지 투명(fade 0)·REVEAL 대기", ch._pending_in.all(func(it): return it["v"].fade == 0.0 and it["v"].mode == 2))
	check("지연은 순차(나가는 0 < 0.14 < 0.28, 들어오는 카드는 그 뒤)", ch._pending_out[0]["delay"] < ch._pending_out[1]["delay"] and ch._pending_out[1]["delay"] < ch._pending_out[2]["delay"] and ch._pending_in[0]["delay"] > ch._pending_out[2]["delay"] and ch._pending_in[0]["delay"] < ch._pending_in[1]["delay"])
	await get_tree().create_timer(0.5, true).timeout
	check("0.5초 뒤: 나가는 카드는 모두 출발, 들어오는 카드는 아직 대기", ch._pending_out.is_empty() and ch._pending_in.size() == 3, "out=%d in=%d" % [ch._pending_out.size(), ch._pending_in.size()])
	await get_tree().create_timer(3.0, true).timeout
	check("3.5초 뒤: 연출 끝 · 손패 5장 모두 보임", not ch.swap_animating() and ch.views.size() == 5 and ch.views.values().all(func(v): return v.fade > 0.9), "views=%d" % ch.views.size())

	# ── 4. 밤 → 낮 전환(GameSession._enter_prep): 밤 카드는 주머니로, 낮 카드는 묶음째 돌아오고 그 뒤 아침 드로우
	var night_cards: Array = ids("hand").filter(func(id): return cards.phase_of(id) == "night")
	var morning_before: int = cards.stats["morning_draws"]
	sess.wave_index = 1
	sess._enter_prep()
	await frames(2)
	hand_ids = ids("hand")
	check("새 낮: 밤 카드 %d장이 모두 주머니로" % night_cards.size(), night_cards.all(func(id): return not id in hand_ids), str(hand_ids))
	check("넣은 만큼(3장) 낮 카드가 모두 돌아옴(낮 후보 3장 → 손패) · 남은 낮 카드가 없어 아침 드로우는 없음",
		"ward_lantern" in hand_ids and "lamb" in hand_ids and "timber" in hand_ids and cards.stats["morning_draws"] == morning_before and cards.eligible_pocket("day").is_empty(),
		"hand=%s pocket=%s" % [str(hand_ids), str(ids("pocket"))])
	check("재화 묶음은 묶음째 돌아옴(손패 목재 8)", cards.hand_count_of("timber") == 8 and cards.pocket_count_of("timber") == 0)
	check("생고기·침식 카드는 그대로 손패", "raw_meat" in hand_ids and "corrupt_prayer" in hand_ids)
	check("새벽에 태우기 횟수 초기화", cards.burns_today == 0)

	# ── 5. 부족하면 있는 만큼: 낮 카드 3장 넣었는데 주머니 밤 카드 1장
	clear_cards()
	set_phase(false)
	for id in ["ward_lantern", "lamb", "black_sheep"]:
		cards.add(id)
	cards.add("frost_rune", 1, "", "pocket")
	set_phase(true)
	sw = cards.phase_swap("night")
	check("밤 카드가 1장뿐이면 1장만 뽑고 나머지 칸은 빔", sw["out"] == 3 and sw["in"].size() == 1 and cards.hand().size() == 1 and cards.pocket().size() == 3)
	check("손패에 반대 카드가 없으면 전환은 아무것도 하지 않음", cards.phase_swap("night")["out"] == 0 and cards.hand().size() == 1)
	set_phase(false)

	# ── 5-1. 여러 장 드로우 연출(사용자 요청 2026-10-20): 주머니에서 한 장씩 나와 가운데 줄에 왼쪽부터 놓이고,
	#         잠깐(DRAW_REVEAL_HOLD) 보인 뒤 나온 순서대로 손패 오른쪽 끝에 들어간다
	await get_tree().create_timer(2.5, true).timeout
	clear_cards()
	for id in ["lamb", "black_sheep", "ward_lantern"]:
		cards.add(id, 1, "", "pocket")
	await frames(2)
	var hc = main.hud.card_hand
	var drawn: Array = cards.draw(3).map(func(e): return e["uid"])
	check("3장 드로우: 3장 모두 주머니 안 대기열", drawn.size() == 3 and hc._pending_in.size() == 3 and hc._pending_in.map(func(it): return it["v"].uid) == drawn, str(drawn))
	check("나오는 지연은 DRAW_REVEAL_STEP 간격으로 순차(0 → 0.3 → 0.6)",
		hc._pending_in.size() == 3 and is_equal_approx(hc._pending_in[1]["delay"] - hc._pending_in[0]["delay"], Cfg.DRAW_REVEAL_STEP) and is_equal_approx(hc._pending_in[2]["delay"] - hc._pending_in[1]["delay"], Cfg.DRAW_REVEAL_STEP),
		str(hc._pending_in.map(func(it): return snappedf(it["delay"], 0.01))))
	check("가운데 줄 순서 = 뽑은 순서", hc._reveal_row.map(func(v): return v.uid) == drawn)
	var draw_t0 := Time.get_ticks_msec()
	var started: Array = []
	var landed: Array = []
	var start_x := {}
	var start_ms := {}
	var land_ms := {}
	while landed.size() < 3 and Time.get_ticks_msec() - draw_t0 < 6000:
		await get_tree().process_frame
		for u in drawn:
			var v = hc.views.get(u)
			if v == null:
				continue
			if not u in started and not v.get_meta("queued", true):
				started.append(u)
				start_x[u] = v.t_pos.x
				start_ms[u] = Time.get_ticks_msec()
			if not u in landed and v.mode == 0:
				landed.append(u)
				land_ms[u] = Time.get_ticks_msec()
	check("주머니에서 나오는 순서 = 뽑은 순서", started == drawn, str(started))
	check("가운데 줄은 왼쪽 → 오른쪽 차례", started.size() == 3 and start_x[drawn[0]] < start_x[drawn[1]] and start_x[drawn[1]] < start_x[drawn[2]],
		str(drawn.map(func(u): return snappedf(start_x.get(u, 0.0), 1.0))))
	check("손패에 들어가는 순서 = 뽑은 순서", landed == drawn, str(landed))
	var holds: Array = drawn.map(func(u): return (land_ms.get(u, 0) - start_ms.get(u, 0)) / 1000.0)
	check("가운데 표시 시간 ≈ DRAW_REVEAL_HOLD(%.2fs, 이전 0.55s)" % Cfg.DRAW_REVEAL_HOLD, holds.all(func(h): return h >= Cfg.DRAW_REVEAL_HOLD - 0.05 and h < Cfg.DRAW_REVEAL_HOLD + 0.3), str(holds))
	var hand_uids: Array = cards.hand().map(func(e): return e["uid"])
	check("손패 순서 맨 뒤 3장 = 뽑은 순서", hand_uids.slice(-3) == drawn, str(hand_uids))

	# ── 6. 달빛 스택: 카드 DRAW_STACK_SIZE장 쓰면 1장 드로우
	clear_cards()
	for id in ["lamb", "black_sheep", "guest_invitation"]:
		cards.add(id, 1, "", "pocket")
	for i in 4:
		cards.add("moss_bandage")
	var stack_seen: Array = []
	var cb := func(n: int): stack_seen.append(n)
	cards.stack_changed.connect(cb)
	cards.consume(uid_of("moss_bandage"))
	cards.consume(uid_of("moss_bandage"))
	check("두 장 쓰면 스택 2 (드로우 없음)", cards.draw_stack == 2 and cards.hand().size() == 2 and cards.stats["stack_draws"] == 0)
	cards.consume(uid_of("moss_bandage"))
	check("세 장째에 주머니에서 1장 뽑고 스택 0", cards.draw_stack == 0 and cards.stats["stack_draws"] == 1 and cards.hand().size() == 2 and cards.pocket().size() == 2, str(ids("hand")))
	check("스택 신호: 1 → 2 → 3 → 0", stack_seen == [1, 2, 3, 0], str(stack_seen))
	cards.stack_changed.disconnect(cb)
	cards.add("timber", 5)
	cards.draw_stack = 0
	cards.resource_uses_today.clear()
	cards.consume_id("timber", 3)
	check("consume_id(목재 3)는 한 번의 사용으로 셈(스택 1)", cards.draw_stack == 1)
	cards.draw_stack = 0
	var lantern_uid: int = -1
	cards.add("ward_lantern")
	lantern_uid = uid_of("ward_lantern")
	cards.activate(lantern_uid)
	check("활동 카드 사용(activate)도 스택에 셈", cards.draw_stack == 1)

	# ── 6-1. 스택 악용 방지(docs/draw-stack-exploit-review-v01.md, A+B'+C 사용자 확정 2026-10-20)
	clear_cards()
	var draws0: int = cards.stats["stack_draws"]  # 앞 검사의 누적값. 이 구간 끝에 되돌려 뒤 검사의 기대값을 지킨다
	for i in 10:
		cards.add("ward_lantern", 1, "", "pocket")
	cards.add("wool", 6, "", "hand")
	cards.add("raw_meat", 2, "", "hand")
	for i in 6:
		main.economy.sell_id("wool", 1)
	check("B': 양털 6개를 1개씩 팔아도 스택 1 (종류별 하루 첫 사용만)", cards.draw_stack == 1 and cards.hand_count_of("wool") == 0, "stack=%d" % cards.draw_stack)
	main.economy.sell_id("raw_meat", 1)
	check("B': 다른 재화(생고기) 첫 판매는 +1", cards.draw_stack == 2, "stack=%d" % cards.draw_stack)
	cards.add("timber", 4, "", "hand")
	cards.draw_stack = 0
	cards.consume_id("timber", 1)
	cards.consume_id("timber", 1)
	check("B': 목재를 하나씩 두 번 써도 오늘 첫 사용 1회", cards.draw_stack == 1, "stack=%d" % cards.draw_stack)
	cards.on_prep_start()
	cards.consume_id("timber", 1)
	check("B': 새벽이 지나면 같은 재화도 다시 셈", cards.draw_stack == 2, "stack=%d" % cards.draw_stack)
	cards.draw_stack = 0
	cards.add("oak_staff", 1, "", "hand")
	main.equipment.equip(player, uid_of("oak_staff", "hand"))
	check("A: 장비 첫 착용은 스택 +1", cards.draw_stack == 1, "stack=%d" % cards.draw_stack)
	for i in 6:
		main.equipment.unequip(player, "weapon", false)
		main.equipment.equip(player, uid_of("oak_staff", "hand"))
	check("A: 벗겼다 다시 끼우기 6회 반복해도 스택 그대로 1", cards.draw_stack == 1 and cards.stats["stack_draws"] == draws0, "stack=%d draws+%d" % [cards.draw_stack, cards.stats["stack_draws"] - draws0])
	main.equipment.unequip(player, "weapon", false)
	cards.draw_stack = 0
	cards.add("traveler_boots", 1, "", "hand")
	cards.add("rowan_charm", 1, "", "hand")
	for i in 8:
		var want := "traveler_boots" if i % 2 == 0 else "rowan_charm"
		main.equipment.equip(player, uid_of(want, "hand"))
	check("A: 같은 칸 장비 2개 8회 맞바꾸기 = 처음 두 장만 셈(스택 2)", cards.draw_stack == 2, "stack=%d" % cards.draw_stack)
	main.equipment.unequip(player, "trinket", false)
	cards.draw_stack = 0
	cards.add("moss_bandage")
	cards.add("timber", 2, "", "hand")
	cards.resource_uses_today.clear()
	cards.begin_use()
	cards.consume(uid_of("moss_bandage"))
	cards.consume_id("timber", 1)
	cards.end_use()
	check("C: 카드 + 재화를 함께 낸 한 번의 사용 = 스택 1", cards.draw_stack == 1, "stack=%d" % cards.draw_stack)
	cards.begin_use()
	cards.consume_id("timber", 1)
	cards.end_use()
	check("C: 재화만 묶인 사용은 B' 규칙(오늘 처음이면 1) — 목재는 아직 안 셌으므로 +1", cards.draw_stack == 2, "stack=%d" % cards.draw_stack)
	cards.add("moss_bandage")
	cards.consume(uid_of("moss_bandage"), 1, false)
	check("count=false 소비(요정 교환 재료)는 세지 않음", cards.draw_stack == 2, "stack=%d" % cards.draw_stack)
	cards.add("moss_bandage")
	cards.consume(uid_of("moss_bandage"))
	check("재화가 아닌 카드는 매번 셈(이끼 붕대 → 스택 3에서 드로우)", cards.stats["stack_draws"] == draws0 + 1 and cards.draw_stack == 0, "stack=%d draws+%d" % [cards.draw_stack, cards.stats["stack_draws"] - draws0])
	cards.stats["stack_draws"] = draws0
	# 가득 찬 스택은 뽑을 카드가 생길 때까지 기다린다
	clear_cards()
	cards.add("frost_rune", 1, "", "pocket")
	for i in 3:
		cards.add("moss_bandage")
	for i in 3:
		cards.consume(uid_of("moss_bandage"))
	check("뽑을 낮 카드가 없으면 스택 3인 채로 대기", cards.draw_stack == Cfg.DRAW_STACK_SIZE and cards.stats["stack_draws"] == 1 and cards.hand().is_empty())
	cards.add("lamb", 1, "", "pocket")
	for i in 3:
		await get_tree().process_frame
	check("낮 카드가 주머니에 들어오면 다음 프레임에 뽑음", cards.draw_stack == 0 and uid_of("lamb", "hand") > 0 and cards.stats["stack_draws"] == 2, "stack=%d hand=%s" % [cards.draw_stack, str(ids("hand"))])
	# 손패가 가득 차면 자리가 날 때까지 기다린다
	clear_cards()
	for i in Cfg.HAND_VISIBLE:
		cards.add("moss_bandage")
	cards.add("lamb", 1, "", "pocket")
	cards.draw_stack = Cfg.DRAW_STACK_SIZE
	await frames(2)
	check("손패가 가득 차면 스택 3인 채로 대기", cards.draw_stack == Cfg.DRAW_STACK_SIZE and uid_of("lamb", "pocket") > 0)
	cards.consume(uid_of("moss_bandage"))
	await frames(2)
	check("자리가 나면 뽑음(그 사용은 다음 스택 1로)", uid_of("lamb", "hand") > 0 and cards.draw_stack == 1, "stack=%d" % cards.draw_stack)

	# ── 7. 모닥불에 태우기
	clear_cards()
	player.hp = player.max_hp
	yard.fuel = Cfg.CAMPFIRE_START_FUEL
	var fire_sp := sp(yard.campfire.global_position + Vector3(0, 0.6, 0))
	cards.add("rabbit_pelt", 2)
	cards.add("corrupt_prayer")
	cards.add("ward_lantern")
	cards.add("timber", 2)
	cards.add("lamb", 1, "", "pocket")
	cards.add("black_sheep", 1, "", "pocket")
	cards.add("frost_rune", 1, "", "pocket")
	var pelt := uid_of("rabbit_pelt")
	var ev: Dictionary = res.evaluate(pelt, fire_sp)
	check("토끼 가죽을 모닥불에: 태우기 판정", ev["ok"] and ev["action"] == "burn", ev.get("reason", ""))
	check("목재를 모닥불에: 여전히 장작 넣기", res.evaluate(uid_of("timber"), fire_sp).get("action", "") == "campfire_fuel")
	var r: Dictionary = res.commit(pelt, fire_sp)
	check("태우기: 가죽 1개 소멸 · 낮 카드 1장 드로우 · 오늘 1회", r["ok"] and cards.hand_count_of("rabbit_pelt") == 1 and cards.burns_today == 1 and cards.stats["burns"] == 1
		and (uid_of("lamb", "hand") > 0 or uid_of("black_sheep", "hand") > 0) and uid_of("frost_rune", "pocket") > 0, r.get("reason", ""))
	check("태우기는 스택에 세지 않음", cards.draw_stack == 0)
	var cp := uid_of("corrupt_prayer")
	var pocket_n: int = cards.pocket().size()
	var hp0: float = player.hp
	r = res.commit(cp, fire_sp)
	check("침식 카드 태우기: 정화(버림패 없음) · 드로우 없음 · 체력 -%d" % int(Cfg.BURN_CORRUPTION_HP),
		r["ok"] and uid_of("corrupt_prayer") == -1 and not in_discard("corrupt_prayer") and cards.pocket().size() == pocket_n and is_equal_approx(player.hp, hp0 - Cfg.BURN_CORRUPTION_HP), r.get("reason", ""))
	ev = res.evaluate(uid_of("ward_lantern"), fire_sp)
	check("하루 %d회를 넘기면 거부" % Cfg.BURN_DRAW_PER_DAY, not ev["ok"] and cards.burns_today == 2, ev.get("reason", ""))
	cards.burns_today = 0
	yard.fuel = 0.0
	ev = res.evaluate(uid_of("ward_lantern"), fire_sp)
	check("꺼진 모닥불에는 태울 수 없음", not ev["ok"] and "꺼져" in str(ev.get("reason", "")), ev.get("reason", ""))
	yard.fuel = Cfg.CAMPFIRE_START_FUEL
	r = res.commit(uid_of("ward_lantern"), fire_sp)
	check("일반 카드 태우기 → 버림패 · 주머니에 뽑을 낮 카드가 없으면 드로우 없이 태움", r["ok"] and in_discard("ward_lantern") and cards.eligible_pocket().is_empty(), r.get("reason", ""))
	player.hp = Cfg.BURN_CORRUPTION_HP
	cards.add("poison_spore")
	cards.burns_today = 0
	ev = res.evaluate(uid_of("poison_spore"), fire_sp)
	check("체력이 비용 이하이면 침식 카드를 태울 수 없음", not ev["ok"], ev.get("reason", ""))
	player.hp = player.max_hp

	# ── 8. 판정 안전장치: 시간대가 맞지 않는 카드는 쓸 수 없다
	clear_cards()
	cards.add("frost_rune", 1, "", "pocket")
	cards.get_entry(uid_of("frost_rune"))["zone"] = "hand"   # 손패에 억지로 둔 밤 카드
	cards.changed.emit()
	ev = res.evaluate(uid_of("frost_rune"), sp(main.world.lodge.global_position + Vector3(0, 0, 5.0)))
	check("낮에 밤 카드 판정 → '밤에만' 거부", not ev["ok"] and "밤" in str(ev.get("reason", "")), ev.get("reason", ""))

	# ── 9. 시작 손패 고르기: 낮 카드만 펼친다
	clear_cards()
	set_phase(false)
	var mul = main.mulligan_ui
	main.grant_starter_cards()
	await frames(2)
	check("시작 손패 후보는 모두 낮 카드(서리 룬 제외)", mul.active and mul.offered.size() == Cfg.STARTER_DRAW and mul.offered.all(func(e): return cards.fits_phase(e["id"], "day")), str(mul.offered.map(func(e): return e["id"])))
	var t0 := 0.0
	while mul._phase != "pick" and t0 < 6.0:
		await get_tree().process_frame
		t0 += get_process_delta_time()
	mul.confirm()
	t0 = 0.0
	while mul.active and t0 < 10.0:
		await get_tree().process_frame
		t0 += get_process_delta_time()
	await frames(3)
	check("확정 뒤 손패는 낮 카드뿐·서리 룬은 주머니", cards.hand().all(func(e): return cards.fits_phase(e["id"], "day")) and uid_of("frost_rune", "pocket") > 0, str(ids("hand")))

	# ── 10. HUD: 주머니 옆 달빛 스택 표시와 툴팁
	var moon = main.hud.moon
	check("달빛 스택 위젯이 주머니 그룹에 있음", moon != null and moon.draw_stack != null and moon.draw_stack.get_parent() == moon.groups["storage"])
	cards.draw_stack = 0
	cards.add("moss_bandage")
	cards.consume(uid_of("moss_bandage"))
	await frames(2)
	check("카드를 쓰면 스택 표시가 1", moon.draw_stack.count == 1, "count=%d" % moon.draw_stack.count)
	moon.refresh(true)
	check("스택 툴팁·주머니 툴팁 문구", "달빛 스택 1/%d" % Cfg.DRAW_STACK_SIZE in moon.stack_hover.tooltip_text and "태우면" in moon.storage_btn.tooltip_text)
	clear_cards()
