extends Node
## 감시탑 자동 검증(docs/watchtower-v01.md). 실제 게임 장면에서 목재 적립 → 골드 건설 → 밤 사냥꾼 배치·사격·시야 →
## 괴물의 탑 공격 → 붕괴 → 목재 수리 → 2단계(사냥꾼 3명) → 새벽 하차를 재현한다.
## 결과: res://art_sources/watchtower-verify.json

const Cfg := preload("res://scripts/config.gd")
const Layout := preload("res://scripts/world/layout.gd")
const SessionScript := preload("res://scripts/game/game_session.gd")
const AllyScript := preload("res://scripts/actors/ally.gd")
const Model := preload("res://scripts/visual/watchtower_model.gd")

var main
var results: Array = []
var failures := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	while get_tree().current_scene == null or get_tree().current_scene.get("session") == null:
		await get_tree().process_frame
	main = get_tree().current_scene
	main.world.player_camera.toggle_overview()
	await get_tree().process_frame
	Engine.time_scale = 4.0
	await _run()
	var out := {"passed": failures == 0, "checks": results.size(), "failures": failures, "results": results}
	var f := FileAccess.open("res://art_sources/watchtower-verify.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(out, "\t") + "\n")
	print("RESULT %d/%d" % [results.size() - failures, results.size()])
	get_tree().quit(0 if failures == 0 else 1)


func check(name: String, ok: bool, detail := "") -> void:
	results.append({"check": name, "ok": ok, "detail": detail})
	if not ok:
		failures += 1
	print(("PASS " if ok else "FAIL ") + name + ("  — " + detail if detail != "" else ""))


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


func last_uid(id: String) -> int:
	var u := -1
	for e in main.cards.entries:
		if e["id"] == id and main.cards.hand_count_of(id) > 0:
			u = e["uid"]
	return u


func hand_uid(id: String) -> int:
	for e in main.cards.entries:
		if e["id"] == id and e.get("zone", "hand") == "hand":
			return e["uid"]
	return last_uid(id)


## 목재 1장을 탑 공터에 끌어 놓는다.
func drop_timber(tower) -> Dictionary:
	main.cards.add("timber", 1, "", "hand")
	await frames(2)
	return main.resolver.commit(hand_uid("timber"), sp(tower.global_position))


func hunters() -> Array:
	var out: Array = []
	for a in main.contracts.allies:
		if is_instance_valid(a) and not a.dead and a.job == "hunter":
			out.append(a)
	return out


func perched_on(tower) -> int:
	var n := 0
	for h in hunters():
		if h.on_tower and h.tower == tower:
			n += 1
	return n


func kill_wave() -> void:
	main.waves.spawn_index = main.waves.total
	main.debug_kill_all()


func _run() -> void:
	var world = main.world
	var eco = main.economy
	var cards = main.cards
	await frames(5)

	# ── 1. 모델·공터 초기 상태
	var s1 := Model.size_of(1)
	var s2 := Model.size_of(2)
	check("GLB 분리: 1단계 약 2.7m 폭·3m 높이, 2단계 더 높은 지붕 탑", s1.y > 2.4 and s1.y < 3.6 and s2.y > s1.y + 1.2 and maxf(s2.x, s2.z) <= Layout.TOWER_SITE_SIZE + 0.6,
		"L1=%s L2=%s" % [str(s1), str(s2)])
	check("감시탑 공터 2곳(왼쪽·오른쪽)", world.towers.size() == 2 and world.towers[0].site_id == "left" and world.towers[1].site_id == "right")
	var tl = world.towers[0]
	var tr = world.towers[1]
	check("처음엔 빈 공터: 단계 0·충돌 없음·적 표적 아님", tl.level == 0 and tl.collision_layer == 0 and not tl.is_in_group("watchtowers") and not tl.is_in_group("sight_sources"))
	check("수치: 탑 사거리 > 지상 사냥꾼, 피해 배율 > 1", Cfg.TOWER_RANGE > Cfg.HUNTER_RANGE and Cfg.TOWER_DAMAGE_MULT > 1.0)
	check("2단계는 더 많은 목재·골드, 사냥꾼 3명", Cfg.TOWER_LEVELS[1]["timber"] > Cfg.TOWER_LEVELS[0]["timber"] and Cfg.TOWER_LEVELS[1]["gold"] > Cfg.TOWER_LEVELS[0]["gold"]
		and Cfg.TOWER_LEVELS[0]["slots"] == 1 and Cfg.TOWER_LEVELS[1]["slots"] == 3)

	# ── 2. 목재 적립 → 골드 건설
	eco.debug_add_gold(1000)
	check("목재 적립 전에는 건설 불가", eco.block_reason("tower_left").begins_with("공터에 목재 적립 필요"), eco.block_reason("tower_left"))
	var need: int = tl.stock_needed()
	var plan: Dictionary = main.resolver.evaluate(-1, sp(tl.global_position))
	cards.add("timber", 1, "", "hand")
	await frames(2)
	plan = main.resolver.evaluate(hand_uid("timber"), sp(tl.global_position))
	check("목재를 공터에 끌면 적립 판정", plan.get("ok", false) and plan.get("action", "") == "tower_deposit", str(plan.get("reason", plan.get("title", ""))))
	var before: int = cards.count_of("timber")
	var r: Dictionary = main.resolver.commit(hand_uid("timber"), sp(tl.global_position))
	check("적립: 목재 카드 1장 소비, 적립 1", r.get("ok", false) and tl.stock == 1 and cards.count_of("timber") == before - 1, "stock=%d" % tl.stock)
	for i in need - 1:
		await drop_timber(tl)
	check("목재 %d장 적립 → 준비 완료" % need, tl.stock_full() and tl.stock == need)
	var extra: Dictionary = await drop_timber(tl)
	check("다 모인 뒤에는 더 적립되지 않음(카드 유지)", not extra.get("ok", true) and tl.stock == need, str(extra.get("reason", "")))
	main.session.wave_index = 0   # 검증은 밤을 여러 번 쓰므로 일차를 1일로 고정(승리로 끝나지 않게)
	main.session.start_wave()
	await frames(2)
	check("밤에는 건설 불가", eco.block_reason("tower_left") != "", eco.block_reason("tower_left"))
	main.waves.stop()
	kill_wave()
	main.session._on_wave_cleared()
	await wait_until(func(): return main.session.state == SessionScript.State.PREP, 30.0)
	var gold0: int = eco.gold
	var cost: int = eco.cost_of("tower_left")
	var bought: bool = eco.buy("tower_left")
	await frames(3)
	check("준비 시간에 골드 지불 → 1단계 건설", bought and tl.level == 1 and eco.gold == gold0 - cost and cost == int(Cfg.TOWER_LEVELS[0]["gold"]), "gold %d→%d cost=%d" % [gold0, eco.gold, cost])
	check("건설 후: 충돌·적 표적·시야 소스·체력", tl.collision_layer == Cfg.L_OBSTACLE and tl.is_in_group("watchtowers") and tl.is_in_group("sight_sources")
		and tl.sight_radius == float(Cfg.TOWER_LEVELS[0]["sight"]) and tl.hp == tl.max_hp and tl.max_hp == float(Cfg.TOWER_LEVELS[0]["hp"]))
	check("관리창 문구: 2단계 다음 비용", eco.price_text("tower_left") == "%dG" % int(Cfg.TOWER_LEVELS[1]["gold"]), eco.price_text("tower_left"))

	# ── 3. 밤: 사냥꾼 1명이 올라가 긴 사거리로 사격
	for i in 2:
		cards.add("hunter", 1, "탑사냥꾼%d" % i, "hand")
		await frames(2)
		var hr: Dictionary = main.resolver.commit(hand_uid("hunter"), sp(Vector3(1.0 + i, 0, 9.0)))
		check("사냥꾼 %d 배치" % (i + 1), hr.get("ok", false), str(hr.get("reason", "")))
	main.session.wave_index = 0   # 검증은 밤을 여러 번 쓰므로 일차를 1일로 고정(승리로 끝나지 않게)
	main.session.start_wave()
	main.waves.stop()
	for e in get_tree().get_nodes_in_group("enemies"):
		e.take_damage(99999.0)
	var up := await wait_until(func(): return perched_on(tl) == 1, 30.0)
	check("밤 → 사냥꾼 1명이 1단계 탑에 올라감", up, "perched=%d states=%s" % [perched_on(tl), str(hunters().map(func(h): return h.state))])
	var top_h = null
	for h in hunters():
		if h.on_tower:
			top_h = h
	check("1단계 자리는 1명뿐(다른 사냥꾼은 지상)", perched_on(tl) == 1 and hunters().size() == 2)
	if top_h != null:
		check("발판 높이에 서 있음", absf(top_h.global_position.y - Model.floor_height()) < 0.05, "y=%.2f floor=%.2f" % [top_h.global_position.y, Model.floor_height()])
		# 지상 사거리(7m) 밖, 탑 사거리(10.5m) 안에 묶어 둔 괴물을 쏘는지
		var dir: Vector3 = (Vector3(Layout.CAMPFIRE.x, 0, Layout.CAMPFIRE.z) - tl.global_position).normalized()
		main.waves.spawn_extra(tl.global_position - dir * 9.0, "forest")
		await frames(2)
		var dummy = get_tree().get_nodes_in_group("enemies").back()
		dummy.hp = 400.0
		dummy.max_hp = 400.0
		dummy.set_physics_process(false)
		dummy.global_position = Vector3(top_h.global_position.x, 0, top_h.global_position.z) - dir * 9.0
		var hp0: float = dummy.hp
		var shot := await wait_until(func(): return dummy.hp < hp0, 12.0)
		var flat: float = Vector2(dummy.global_position.x - top_h.global_position.x, dummy.global_position.z - top_h.global_position.z).length()
		check("탑 위 사냥꾼: 지상 사거리 밖(%.1fm) 적도 맞힘" % flat, shot and flat > Cfg.HUNTER_RANGE)
		var dmg: float = hp0 - dummy.hp
		check("탑 화살 피해 = 사냥꾼 피해 × %.1f" % Cfg.TOWER_DAMAGE_MULT, absf(dmg - Cfg.HUNTER_DAMAGE * Cfg.TOWER_DAMAGE_MULT) < 0.6 or dmg >= Cfg.HUNTER_DAMAGE * Cfg.TOWER_DAMAGE_MULT - 0.01, "dmg=%.1f" % dmg)
		dummy.take_damage(99999.0)
		# ── 4. 괴물의 탑 공격: 탑 위 사냥꾼은 직접 표적이 아니고 탑을 친다
		check("괴물 표적 판정: 탑 위 사냥꾼 제외", not dummy._foe_valid(top_h))
	main.waves.spawn_extra(tl.global_position + Vector3(-3.0, 0, 0.5), "forest")
	await frames(2)
	var brute = get_tree().get_nodes_in_group("enemies").back()
	brute.hp = 5000.0
	brute.max_hp = 5000.0
	var hit := await wait_until(func(): return tl.hp < tl.max_hp, 25.0)
	check("괴물이 지나가다 감시탑을 공격", hit, "hp=%.0f/%.0f foe=%s" % [tl.hp, tl.max_hp, str(brute.chase)])
	check("탑 공격자를 탑 위 사냥꾼이 우선 겨눔", top_h != null and (top_h.target == brute or tl.last_attacker == brute))
	# ── 5. 붕괴 → 사냥꾼 하차 → 표적·시야에서 빠짐
	tl.take_damage(99999.0, brute)
	await frames(3)
	check("체력 0 → 무너짐, 표적·시야·체력바에서 빠짐", tl.collapsed and not tl.is_in_group("watchtowers") and not tl.is_in_group("sight_sources") and not tl.is_in_group("show_hp"))
	check("무너지면 사냥꾼이 땅으로 내려옴", top_h == null or (not top_h.on_tower and top_h.tower == null and top_h.global_position.y < 0.05))
	check("무너진 탑은 업그레이드 불가", eco.block_reason("tower_left") != "")
	brute.take_damage(99999.0)
	kill_wave()
	main.session._on_wave_cleared()
	await wait_until(func(): return main.session.state == SessionScript.State.PREP, 30.0)
	await frames(3)

	# ── 6. 목재 수리(산장처럼): 무너진 탑도 다시 선다
	var rp: Dictionary = await drop_timber(tl)
	check("목재를 무너진 탑에 → 수리·다시 세움", rp.get("ok", false) and not tl.collapsed and tl.hp == minf(Cfg.TOWER_REPAIR_AMOUNT, tl.max_hp) and tl.is_in_group("watchtowers"), "hp=%.0f %s" % [tl.hp, str(rp.get("reason", ""))])
	while tl.needs_repair():
		await drop_timber(tl)
	check("체력이 찰 때까지 목재 1장당 +%d" % int(Cfg.TOWER_REPAIR_AMOUNT), tl.hp == tl.max_hp)
	tl.take_damage(20.0)
	main.session.wave_index = 0   # 검증은 밤을 여러 번 쓰므로 일차를 1일로 고정(승리로 끝나지 않게)
	main.session.start_wave()
	await frames(2)
	cards.add("timber", 1, "", "hand")
	await frames(2)
	var night_rp: Dictionary = main.resolver.evaluate(hand_uid("timber"), sp(tl.global_position))
	check("수리·적립은 준비 시간에만", not night_rp.get("ok", true), str(night_rp.get("reason", "")))
	main.waves.stop()
	kill_wave()
	main.session._on_wave_cleared()
	await wait_until(func(): return main.session.state == SessionScript.State.PREP, 30.0)
	await frames(3)
	check("새벽 → 탑 위 사냥꾼 모두 하차", perched_on(tl) == 0 and hunters().all(func(h): return not h.on_tower and h.tower == null))
	await drop_timber(tl)   # 남은 피해 수리

	# ── 7. 2단계: 더 많은 목재 적립 + 더 많은 골드 → 사냥꾼 3명
	var need2: int = tl.stock_needed()
	var why := ""
	for i in need2:
		var dr: Dictionary = await drop_timber(tl)
		if not dr.get("ok", false):
			why = str(dr.get("reason", ""))
	check("2단계 목재 %d장 적립" % need2, tl.stock_full() and need2 == int(Cfg.TOWER_LEVELS[1]["timber"]), "stock=%d/%d %s" % [tl.stock, need2, why])
	var g1: int = eco.gold
	check("2단계 업그레이드 골드 지불", eco.buy("tower_left") and tl.level == 2 and eco.gold == g1 - int(Cfg.TOWER_LEVELS[1]["gold"]) and tl.slots() == 3 and tl.max_hp == float(Cfg.TOWER_LEVELS[1]["hp"]))
	check("최대 단계: 더 이상 업그레이드 없음", eco.price_text("tower_left") == "완료" and eco.block_reason("tower_left") == "최대 단계")
	cards.add("hunter", 1, "탑사냥꾼2", "hand")
	await frames(2)
	main.resolver.commit(hand_uid("hunter"), sp(Vector3(2.0, 0, 9.5)))
	await frames(2)
	main.session.wave_index = 0   # 검증은 밤을 여러 번 쓰므로 일차를 1일로 고정(승리로 끝나지 않게)
	main.session.start_wave()
	main.waves.stop()
	for e in get_tree().get_nodes_in_group("enemies"):
		e.take_damage(99999.0)
	var three := await wait_until(func(): return perched_on(tl) == 3, 40.0)
	check("2단계 탑에 사냥꾼 3명이 올라감", three, "perched=%d hunters=%d" % [perched_on(tl), hunters().size()])
	var spots := {}
	for h in hunters():
		if h.on_tower:
			spots[str(Vector2(snappedf(h.global_position.x, 0.1), snappedf(h.global_position.z, 0.1)))] = true
	check("세 명은 서로 다른 발판 자리", spots.size() == 3)
	check("오른쪽 공터는 여전히 빈 공터(독립)", tr.level == 0 and tr.stock == 0)
	kill_wave()
	main.session._on_wave_cleared()
	await wait_until(func(): return main.session.state == SessionScript.State.PREP, 30.0)
	await frames(3)
	check("새벽 → 2단계 탑 사냥꾼도 모두 하차", perched_on(tl) == 0)
