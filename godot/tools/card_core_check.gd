extends Node
## 카드 코어 C0 자동 검증(기획서 v0.3 §16). 실제 게임 장면에서 시스템 호출과 마우스 입력으로 세 획득 경로·사용·소비·귀가를 재현한다.
## 실행: godot --headless --path . --script res://tools/verify_card_core.gd

const SessionScript := preload("res://scripts/game/game_session.gd")

var main
var results: Array = []
var failures := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	while get_tree().current_scene == null or get_tree().current_scene.get("session") == null:
		await get_tree().process_frame
	main = get_tree().current_scene
	# Keep this legacy card scenario framed on the lodge; follow interactions have their own suite.
	main.world.player_camera.toggle_overview()
	await get_tree().process_frame
	Engine.time_scale = 4.0
	await _run()
	var out := {"passed": failures == 0, "checks": results.size(), "failures": failures, "results": results}
	var f := FileAccess.open("res://art_sources/card-core-verify.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(out, "\t") + "\n")
	print("CARD_CORE_VERIFY passed=", failures == 0, " checks=", results.size(), " failures=", failures)
	get_tree().quit(0 if failures == 0 else 1)


func check(name: String, ok: bool, detail := "") -> void:
	results.append({"check": name, "ok": ok, "detail": detail})
	if not ok:
		failures += 1
	print(("  PASS " if ok else "  FAIL ") + name + ("  — " + detail if detail != "" else ""))


func wait_until(cond: Callable, timeout := 60.0) -> bool:
	var t := 0.0
	while not cond.call():
		await get_tree().physics_frame
		t += get_physics_process_delta_time()
		if t > timeout:
			return false
	return true


func frames(n := 2) -> void:
	for i in n:
		await get_tree().physics_frame


func sp(p: Vector3) -> Vector2:
	return main.world.camera.unproject_position(p)


func uid_of(id: String) -> int:
	for e in main.cards.entries:
		if e["id"] == id:
			return e["uid"]
	return -1


func set_prep(t: float) -> void:
	main.session.prep_elapsed = t


func _run() -> void:
	var cards = main.cards
	var eco = main.economy
	var res = main.resolver
	var lodge = main.world.lodge
	check("시작 골드 40G·손패 비어 있음", eco.gold == 40 and cards.entries.is_empty(), "gold=%d" % eco.gold)

	# ── 1. 손님 정산 → 고용 기회 → 용병 계약 카드
	set_prep(25.2)
	await frames(3)
	check("첫 묶음 정산 +30G 후 고용 기회 1명", eco.offers.size() == 1 and eco.gold == 70, "offers=%d gold=%d" % [eco.offers.size(), eco.gold])
	var offer: Dictionary = eco.offers[0]
	var person: String = offer["person"]
	check("고용 30G → 계약 카드(같은 인물)", eco.hire(offer) and eco.gold == 40 and cards.count_of("axe_mercenary") == 1 and cards.get_entry(uid_of("axe_mercenary"))["person"] == person, person)
	check("같은 고용 기회 중복 고용 불가", not eco.hire(offer) and eco.gold == 40)

	# ── 2. 무효 대상은 소비하지 않음
	var merc := uid_of("axe_mercenary")
	var bad: Dictionary = res.commit(merc, sp(lodge.global_position + Vector3(0, 2.0, 0)))
	check("산장에 용병 카드 → 거부·미소비", not bad["ok"] and cards.count_of("axe_mercenary") == 1, bad.get("reason", ""))
	var far: Dictionary = res.commit(merc, sp(Vector3(-44, 0, -20)))
	check("확장 맵 경계 밖 소환 거부·미소비", not far["ok"] and cards.count_of("axe_mercenary") == 1, far.get("reason", ""))

	# ── 3. 실제 마우스 드래그로 나무에 사용 → 벌목 → 목재 → 귀가
	var tree: Dictionary = main.world.harvest_trees[0]
	var hand = main.hud.card_hand
	var mover_before: Vector3 = main.player.agent.target_position
	await frames(40)
	var view = hand.views[merc]
	var start: Vector2 = view.get_global_rect().get_center()
	await _mouse_drag(start, sp(tree["pos"] + Vector3(0, 1.6, 0)))
	check("드래그 놓기로 계약 1장 소비·용병 1명 등장", cards.count_of("axe_mercenary") == 0 and main.contracts.active_count() == 1)
	check("카드 드래그가 마녀 이동으로 전달되지 않음", main.player.agent.target_position == mover_before and not main.player.moving)
	check("작업 중인 나무 예약", tree["reserved"] != null)
	var got := await wait_until(func(): return cards.count_of("timber") == 10, 40.0)
	check("15초 벌목 완료 → 목재 ×10 지급(1회)", got and cards.count_of("timber") == 10, "timber=%d" % cards.count_of("timber"))
	var stay: bool = main.contracts.active_count() == 1 and main.contracts.allies[0].task == "idle" and not main.contracts.allies[0].dead
	check("벌목 후에도 용병이 남아 산장 마당에서 대기(쓰러지기 전까지 유지)", stay and cards.count_of("axe_mercenary") == 0)
	var next_tree := await wait_until(func(): return main.contracts.allies[0].task == "chop" and main.contracts.allies[0].tree["remaining"] > 0, 10.0)
	check("낮에 쉬는 용병은 다음 자원 나무를 스스로 맡음", next_tree)
	check("나무 목재 20→10", tree["remaining"] == 10)

	# ── 4. 목재로 산장 재료 수리
	lodge.take_damage(150.0)
	var hp0: float = lodge.hp
	var rep: Dictionary = res.commit(uid_of("timber"), sp(lodge.global_position + Vector3(0, 2.0, 0)))
	check("목재 5개 → 산장 +100", rep["ok"] and is_equal_approx(lodge.hp, hp0 + 100.0) and cards.count_of("timber") == 5, "hp %d→%d" % [hp0, lodge.hp])
	lodge.repair(999.0)
	var full: Dictionary = res.evaluate(uid_of("timber"), sp(lodge.global_position + Vector3(0, 2.0, 0)))
	check("체력 최대에서는 목재 수리 불가", not full["ok"], full.get("reason", ""))

	# ── 5. 첫날 양털 없음
	check("1일차 양털 생산 없음", main.world.pasture.ready_count() == 0)

	# ── 6. 둘째 손님 고용 → 낮에 지면 배치(오늘 밤 방어)
	set_prep(50.2)
	await frames(3)
	check("둘째 묶음 고용 기회", eco.offers.size() == 1)
	eco.hire(eco.offers[0])
	var guard_spot := Vector3(-3.0, 0, 6.0)
	var g: Dictionary = res.commit(uid_of("axe_mercenary"), sp(guard_spot))
	check("낮 지면 배치 → 방어 대기 용병", g["ok"] and g["action"] == "guard" and main.contracts.active_count() == 2, g.get("reason", ""))

	# ── 7. 활동 상한·창고(손패 넘침)
	for i in 4:
		cards.add("axe_mercenary", 1, "테스트%d" % i)
	var placed := 0
	for i in 4:
		var r: Dictionary = res.commit(uid_of("axe_mercenary"), sp(Vector3(-1.0 + i * 1.3, 0, 7.5)))
		if r["ok"]:
			placed += 1
	check("활동 상한 4명: 남아 있는 용병 포함, 2명 추가 후 거부·미소비", placed == 2 and main.contracts.active_count() == 4 and cards.count_of("axe_mercenary") == 2, "placed=%d" % placed)
	for i in 8:
		cards.add("forest_monster")
	check("손패 8장 초과분은 창고 보관(손실 없음)", cards.hand().size() == 8 and cards.storage().size() == cards.entries.size() - 8 and cards.count_of("forest_monster") == 8)
	for e in cards.entries.duplicate():
		if e["id"] == "forest_monster" or e["id"] == "axe_mercenary":
			cards.consume(e["uid"])
	# 테스트로 소환한 용병은 밤 전투 뒤에도 남는다

	# ── 8. 밤 1: 표식 괴물 처치 → 카드, 아군은 밤 종료를 막지 않음
	var monster_before: int = cards.count_of("forest_monster")
	main.session.start_wave()
	await frames(2)
	var chopping := 0
	for a in main.contracts.allies:
		if a.state == 0 or a.state == 1:
			chopping += 1
	check("밤에는 벌목을 멈추고 산장 앞을 지킴", chopping == 0)
	var marked := 0
	for e in get_tree().get_nodes_in_group("enemies"):
		if e.card_drop != "":
			marked += 1
	check("웨이브 1 표식 괴물 1마리", marked == 1)
	var big_ok := false
	for e in get_tree().get_nodes_in_group("enemies"):
		if e.card_drop != "":
			big_ok = e.big and is_equal_approx(e.max_hp, 36.0 * 1.7) and e.visual.has_meta("big") and e.visual.get_node_or_null("Body/BackBranches") != null
		elif e.big:
			big_ok = false
			break
	check("카드 대상은 큰 숲의 괴물(체력 ×1.7·등 가지), 나머지는 기본 숲의 괴물", big_ok)
	var cleared := await _kill_wave()
	check("적 정리 → 밤 종료(아군 생존 중에도)", cleared)
	check("표식 괴물 처치 → 숲의 괴물 카드 1장", cards.count_of("forest_monster") == monster_before + 1)
	await frames(20)
	var idle_all: bool = main.contracts.active_count() == 4
	for a in main.contracts.allies:
		if a.kind == "merc" and a.task == "guard":
			idle_all = false
	check("밤 종료 후 전투 용병 전원 남아 마당 대기로 전환", idle_all, "active=%d" % main.contracts.active_count())

	# ── 8b. 용병 사망 → 산장 뒤편 무덤, 무덤이 차면 고용 불가
	var gy = main.world.graveyard
	var victims: Array = main.contracts.allies.filter(func(a): return a.kind == "merc").slice(0, 2)
	for a in victims:
		a.take_damage(9999.0)
	await frames(3)
	check("용병 사망 → 무덤 2기(이름 비석, 산장 뒤편)", gy.count() == 2 and main.contracts.active_count() == 2 and gy.graves[0]["node"].global_position.z < -3.0, "graves=%d" % gy.count())
	check("초기 무덤 최대 4기", gy.capacity() == 4)

	# ── 9. 2일차 양털: 접근 수확 → 판매
	await wait_until(func(): return main.session.state == SessionScript.State.PREP, 20.0)
	await frames(2)
	var ready: int = main.world.pasture.ready_count()
	check("2일차 생존 양마다 털 1회분", ready == main.world.pasture.alive_count() and ready > 0, "ready=%d" % ready)
	var gold0: int = eco.gold - _fees_paid()
	var sheep = main.world.pasture.nearest_alive_sheep(main.player.global_position)
	main.player.harvest(sheep)
	var sheared_in_pen := [false, 0.0]
	var h1 := await wait_until(func():
		if main.player.shearing and main.world.pasture.inside(main.player.global_position):
			sheared_in_pen[0] = true
			sheared_in_pen[1] = maxf(sheared_in_pen[1], main.player.harvest_t)
		return cards.count_of("wool") == 1, 30.0)
	check("목장 안으로 들어가 양 옆에서 털 깎기 모션·게이지 진행", sheared_in_pen[0] and sheared_in_pen[1] > 1.5, "max_t=%.2f" % sheared_in_pen[1])
	check("양에게 다가가 수확 → 양털 ×1, 골드 변화 없음(숙박비 제외)", h1 and eco.gold - _fees_paid() == gold0, "wool=%d gold %d→%d prep=%.1f p=%s s=%s" % [cards.count_of("wool"), gold0, eco.gold, main.session.prep_elapsed, main.player.global_position, sheep.global_position])
	main.player.harvest(sheep)
	await frames(30)
	check("같은 생산분 중복 수확 불가", cards.count_of("wool") == 1)
	for s in main.world.pasture.slots:
		if s != null and not s.dead and s.wool_ready:
			main.player.harvest(s)
			await wait_until(func(): return not s.wool_ready, 30.0)
	var wool_n: int = cards.count_of("wool")
	check("양털 수량 묶음(한 장)", wool_n == ready and cards.entries.filter(func(e): return e["id"] == "wool").size() == 1, "wool=%d" % wool_n)
	var sell: Dictionary = res.commit(uid_of("wool"), sp(lodge.global_position + Vector3(0, 2.0, 0)))
	check("양털을 산장에 놓으면 판매 창(아직 미소비)", sell["ok"] and sell["action"] == "sell" and cards.count_of("wool") == wool_n)
	var g1: int = eco.gold
	check("선택 수량 판매 4G/개", eco.sell_wool(uid_of("wool"), 2) and eco.gold == g1 + 8 and cards.count_of("wool") == wool_n - 2)

	# ── 10. 밤 2: 하수인 소환, 적 수에서 제외, 밤 종료 시 퇴장·재드롭 없음
	main.session.start_wave()
	await frames(2)
	var monster_uid := uid_of("forest_monster")
	var m: Dictionary = res.commit(monster_uid, sp(Vector3(-2.5, 0, 6.5)))
	check("밤에 하수인 카드 소환", m["ok"] and main.contracts.active_count() == 3 and cards.count_of("forest_monster") == 0, m.get("reason", ""))
	await frames(2)
	var minion = main.contracts.allies.filter(func(a): return a.kind == "minion")[0]
	check("하수인은 적 수에 포함되지 않음", main.waves.alive() == get_tree().get_nodes_in_group("enemies").size() and not minion.is_in_group("enemies"))
	check("하수인은 큰 숲의 괴물 모델", minion.visual.has_meta("big"))
	var timber_before_day: int = cards.count_of("timber")
	var sell_night: Dictionary = res.evaluate(uid_of("wool"), sp(lodge.global_position + Vector3(0, 2.0, 0)))
	check("밤에는 판매 불가", not sell_night["ok"], sell_night.get("reason", ""))
	var c2 := await _kill_wave()
	await frames(10)
	check("밤 2 정리 → 하수인 시듦(체력 남아도), 카드 재드롭 없음(표식 카드만 +1)", c2 and main.contracts.active_count() == 2 and cards.count_of("forest_monster") == 1)
	check("시든 하수인 → 목재 +1 손패", cards.count_of("timber") >= timber_before_day + 1 and main.contracts.stats["withered"] == 1, "timber %d→%d" % [timber_before_day, cards.count_of("timber")])

	# ── 11. 드래그 취소(우클릭)는 미소비
	await wait_until(func(): return main.session.state == SessionScript.State.PREP, 20.0)
	var uid2 := uid_of("forest_monster")
	var v2 = hand.views.get(uid2)
	if v2 != null:
		await frames(20)
		await _mouse_drag(v2.get_global_rect().get_center(), sp(Vector3(-2.5, 0, 6.5)), true)
		check("우클릭 취소 → 카드 손패로 복귀", cards.count_of("forest_monster") == 1 and main.contracts.active_count() == 2)
	else:
		check("우클릭 취소 → 카드 손패로 복귀", false, "카드 뷰 없음")

	# ── 12. 건물은 목재가 필요, 목장·묘지 증축
	var pa = main.world.pasture
	eco.debug_add_gold(1000)
	cards.consume_id("timber", cards.count_of("timber"))
	check("목재 없으면 객실 증축 불가", eco.block_reason("extension").begins_with("목재 부족") and not eco.buy("extension"), eco.block_reason("extension"))
	cards.add("timber", 60)
	var t0: int = cards.count_of("timber")
	check("객실 증축 → 골드 + 목재 10 소비", eco.buy("extension") and cards.count_of("timber") == t0 - 10 and main.world.lodge.extension_built)
	while pa.has_empty_slot():
		eco.buy("sheep")
	check("목장 1단계 최대 4마리 → 추가 구입 불가", pa.alive_count() == 4 and eco.block_reason("sheep") != "", eco.block_reason("sheep"))
	var area0: float = pa.rect.get_area()
	t0 = cards.count_of("timber")
	check("목장 증축 → 목재 8 소비·영역 확대·최대 6마리", eco.buy("pasture") and cards.count_of("timber") == t0 - 8 and pa.capacity() == 6 and pa.rect.get_area() > area0)
	var bought := 0
	while pa.has_empty_slot():
		if not eco.buy("sheep"):
			break
		bought += 1
	check("증축 뒤 양 계속 구입(6마리까지)", bought == 2 and pa.alive_count() == 6)
	check("목장 3단계 → 최대 8마리, 이후 최대 단계", eco.buy("pasture") and pa.capacity() == 8 and eco.block_reason("pasture") == "최대 단계")
	var hire_reason := ""
	cards.add("axe_mercenary", 1, "예비")
	main.economy.offers.append({"person": "시험", "guest": null, "expires": 999.0})
	hire_reason = eco.hire_block_reason(main.economy.offers[-1])
	check("무덤 남은 자리 ≤ 용병 수 → 고용 불가", hire_reason.begins_with("묘지가 가득"), hire_reason)
	t0 = cards.count_of("timber")
	check("묘지 확장 → 목재 6 소비·무덤 최대 6기", eco.buy("graves") and cards.count_of("timber") == t0 - 6 and gy.capacity() == 6)
	check("묘지 확장 뒤 다시 고용 가능", eco.hire_block_reason(main.economy.offers[-1]) == "")
	main.economy.offers.pop_back()


func _fees_paid() -> int:
	var n := 0
	for b in main.economy.batches:
		if b["paid"]:
			n += b["count"] * 15
	return n


func _kill_wave() -> bool:
	return await wait_until(func():
		for e in get_tree().get_nodes_in_group("enemies"):
			e.take_damage(99999.0)
		return main.session.state != SessionScript.State.COMBAT, 60.0)


func _mouse_drag(from: Vector2, to: Vector2, cancel := false) -> void:
	var mv := InputEventMouseMotion.new()
	mv.position = from
	mv.global_position = from
	get_viewport().push_input(mv, true)
	await frames(2)
	var down := InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.pressed = true
	down.position = from
	down.global_position = from
	get_viewport().push_input(down, true)
	await frames(2)
	for i in 6:
		var m := InputEventMouseMotion.new()
		m.position = from.lerp(to, (i + 1) / 6.0)
		m.global_position = m.position
		m.button_mask = MOUSE_BUTTON_MASK_LEFT
		get_viewport().push_input(m, true)
		await frames(1)
	if cancel:
		var r := InputEventMouseButton.new()
		r.button_index = MOUSE_BUTTON_RIGHT
		r.pressed = true
		r.position = to
		r.global_position = to
		get_viewport().push_input(r, true)
		await frames(2)
	var up := InputEventMouseButton.new()
	up.button_index = MOUSE_BUTTON_LEFT
	up.pressed = false
	up.position = to
	up.global_position = to
	get_viewport().push_input(up, true)
	await frames(3)
