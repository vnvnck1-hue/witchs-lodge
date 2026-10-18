extends Node
## 모닥불 연료·스튜 자동 검증(docs/resource-uses-expansion-v01.md v0.3, 사용자 확정 2026-10-18).
## 실제 게임 장면에서 연소·꺼짐 → 목재 넣기(링 게이지) → 켜진 불에서만 스튜 → 스튜로 용병 회복 →
## 낮에 모닥불 곁에서만 느린 회복(다친 전투직은 불가로 가서 쉼)을 재현한다.
## 결과: res://art_sources/campfire-verify.json

const Cfg := preload("res://scripts/config.gd")
const Layout := preload("res://scripts/world/layout.gd")
const SessionScript := preload("res://scripts/game/game_session.gd")
const AllyScript := preload("res://scripts/actors/ally.gd")

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
	await _run()
	var out := {"passed": failures == 0, "checks": results.size(), "failures": failures, "results": results}
	var f := FileAccess.open("res://art_sources/campfire-verify.json", FileAccess.WRITE)
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
		await get_tree().physics_frame


func sp(p: Vector3) -> Vector2:
	return main.world.camera.unproject_position(p)


func hand_uid(id: String) -> int:
	for e in main.cards.entries:
		if e["id"] == id and e["zone"] == "hand":
			return e["uid"]
	return -1


func give(id: String) -> int:
	main.cards.add(id, 1, "", "hand")
	await frames(2)
	return hand_uid(id)


func fire_sp() -> Vector2:
	return sp(Layout.CAMPFIRE + Vector3(0, 0.6, 0))


func _run() -> void:
	var yard = main.world.yard
	var cards = main.cards
	var res = main.resolver
	await frames(5)
	# 마녀는 모닥불에서 멀리(놓기 판정이 마녀 먹기로 새지 않게)
	main.player.global_position = Layout.DOOR_FRONT + Vector3(-6, 0, 0)
	await frames(2)

	# ── 1. 시작 상태·수치
	check("앞마당 모닥불이 있고 새 판은 목재 1개분으로 켜져 있음", yard != null and yard.is_lit() and absf(yard.fuel - Cfg.CAMPFIRE_START_FUEL) < 2.0, "fuel=%.1f" % yard.fuel)
	check("수치: 목재 1개 60초 · 최대 3개(180초) · 낮 회복 초당 0.3 · 스튜 80%",
		Cfg.CAMPFIRE_FUEL_PER_TIMBER == 60.0 and Cfg.CAMPFIRE_MAX_TIMBER == 3 and yard.max_fuel() == 180.0
		and Cfg.CAMPFIRE_HEAL_PER_SEC == 0.3 and Cfg.STEW_HEAL_RATIO == 0.8)
	check("켜진 불: 불꽃·불빛이 보임", yard.fire_light.visible and yard._flames[0].visible)

	# ── 2. 연소 → 꺼짐(불빛도 꺼짐)
	var f0: float = yard.fuel
	await get_tree().create_timer(1.0).timeout
	check("낮에도 시간이 지나면 연료가 줄어듦", yard.fuel < f0 - 0.5, "%.2f → %.2f" % [f0, yard.fuel])
	yard.fuel = 0.4
	await get_tree().create_timer(0.8).timeout
	await get_tree().process_frame
	check("다 타면 꺼짐", not yard.is_lit() and yard.fuel == 0.0)
	check("꺼지면 앞마당 불빛·불꽃이 사라지고 숯이 식음", not yard.fire_light.visible and not yard._flames[0].visible and yard._ember.material_override == yard._ember_out)

	# ── 3. 꺼진 불에는 스튜를 끓일 수 없음
	var meat: int = await give("raw_meat")
	var p: Dictionary = res.evaluate(meat, fire_sp())
	check("꺼진 모닥불에 생고기 → 거부(목재를 넣으라는 안내)", not p.get("ok", true) and str(p.get("reason", "")).contains("꺼져"), str(p.get("reason", "")))

	# ── 4. 목재 넣기 → 다시 켜짐, 게이지 차오름
	var timber: int = await give("timber")
	var t_before: int = cards.count_of("timber")
	p = res.evaluate(timber, fire_sp())
	check("목재를 모닥불에 끌면 '불 피우기' 판정", p.get("ok", false) and p.get("action", "") == "campfire_fuel", str(p.get("title", p.get("reason", ""))))
	var shown0: float = yard.gauge_shown
	var r: Dictionary = res.commit(timber, fire_sp())
	check("목재 1개 소비 → 연료 60초, 다시 켜짐", r.get("ok", false) and cards.count_of("timber") == t_before - 1 and yard.is_lit() and absf(yard.fuel - 60.0) < 0.5, "fuel=%.1f" % yard.fuel)
	await get_tree().create_timer(0.3).timeout
	check("링 게이지가 부드럽게 차오름(즉시 점프 아님)", yard.gauge_shown > shown0 and yard.gauge_shown < yard.fuel_ratio() + 0.001, "%.3f → %.3f (목표 %.3f)" % [shown0, yard.gauge_shown, yard.fuel_ratio()])
	await get_tree().create_timer(0.6).timeout
	check("게이지가 남은 연료 비율에 도달", absf(yard.gauge_shown - yard.fuel_ratio()) < 0.02, "%.3f / %.3f" % [yard.gauge_shown, yard.fuel_ratio()])
	await get_tree().process_frame
	check("다시 켜지면 불빛도 돌아옴", yard.fire_light.visible)

	# ── 5. 최대치
	yard.fuel = 140.0
	timber = await give("timber")
	res.commit(timber, fire_sp())
	check("넘치는 연료는 최대 180초로 자름", absf(yard.fuel - 180.0) < 0.5, "fuel=%.1f" % yard.fuel)
	timber = await give("timber")
	p = res.evaluate(timber, fire_sp())
	check("가득 차면 목재를 넣을 수 없음(카드 유지)", not p.get("ok", true) and str(p.get("reason", "")).contains("가득"), str(p.get("reason", "")))
	yard.fuel = 100.0
	p = res.evaluate(timber, fire_sp())
	check("한 개분 이상 자리가 있으면 다시 넣을 수 있음", p.get("ok", false))
	check("목재를 산장에 놓으면 여전히 수리 판정(기존 쓰임 유지)", res.evaluate(timber, sp(main.world.lodge.global_position + Vector3(0, 1.5, 0))).get("action", "") in ["repair", ""])

	# ── 6. 링 게이지 표시 조건
	var overlay = main.hud.overlay
	check("마녀가 멀면 링이 보이지 않음", not overlay.campfire_gauge_visible())
	main.player.global_position = Layout.CAMPFIRE + Vector3(3.0, 0, 1.5)
	await frames(2)
	check("마녀가 모닥불 가까이 오면 링이 보임", overlay.campfire_gauge_visible())
	main.player.global_position = Layout.DOOR_FRONT + Vector3(-6, 0, 0)
	main.hud.card_hand.drag_uid = timber
	check("목재 카드를 들고 있으면 멀어도 링이 보임", overlay.campfire_gauge_visible())
	main.hud.card_hand.drag_uid = -1
	await frames(2)

	# ── 7. 스튜: 켜진 불에서 생고기 → 스튜 카드
	var m_before: int = cards.count_of("raw_meat")
	p = res.evaluate(meat, fire_sp())
	check("켜진 모닥불에 생고기 → 스튜 끓이기 판정", p.get("ok", false) and p.get("action", "") == "cook_stew", str(p.get("title", p.get("reason", ""))))
	r = res.commit(meat, fire_sp())
	check("생고기 1개 소비 → 고기 스튜 카드 1장", r.get("ok", false) and cards.count_of("raw_meat") == m_before - 1 and cards.count_of("meat_stew") == 1)
	check("스튜 카드는 카탈로그에 등록된 자원(사용하면 소멸)", cards.def("meat_stew").get("name", "") == "고기 스튜" and cards.is_resource("meat_stew"))
	var meat2: int = await give("raw_meat")
	check("생고기는 마녀에게 놓으면 여전히 먹기(기존 쓰임 유지)", res.evaluate(meat2, sp(main.player.global_position + Vector3(0, 1.0, 0))).get("action", "") in ["eat", ""])

	# ── 8. 스튜로 용병 회복(끌어 놓은 한 명)
	var spot: Vector3 = Layout.DOOR_FRONT + Vector3(4.0, 0, 3.0)
	var w = main.contracts.spawn_guard("merc", "검증 전사", spot, null, "warrior")
	var w2 = main.contracts.spawn_guard("merc", "검증 전사2", spot + Vector3(1.2, 0, 0), null, "warrior")
	await frames(3)
	yard.fuel = 0.0   # 낮 회복이 섞이지 않게 불을 끈다
	await frames(2)
	w.hp = 10.0
	w2.hp = 10.0
	var stew: int = hand_uid("meat_stew")
	var at_w: Vector2 = sp(w.global_position + Vector3(0, w.hp_offset * 0.5, 0))
	p = res.evaluate(stew, at_w)
	check("스튜를 다친 용병에게 끌면 회복 판정", p.get("ok", false) and p.get("action", "") == "stew", str(p.get("title", p.get("reason", ""))))
	var target = p.get("ally")
	var other = w2 if target == w else w
	r = res.commit(stew, at_w)
	check("대상 용병만 최대 체력의 80% 회복, 옆 용병은 그대로", r.get("ok", false) and absf(target.hp - minf(10.0 + target.max_hp * 0.8, target.max_hp)) < 0.6 and absf(other.hp - 10.0) < 0.6,
		"대상 %.1f/%.1f · 옆 %.1f" % [target.hp, target.max_hp, other.hp])
	check("스튜 카드 1장 소비", cards.count_of("meat_stew") == 0)
	cards.add("meat_stew", 1, "", "hand")
	await frames(2)
	stew = hand_uid("meat_stew")
	target.hp = target.max_hp
	p = res.evaluate(stew, sp(target.global_position + Vector3(0, target.hp_offset * 0.5, 0)))
	check("체력이 가득한 용병에게는 쓸 수 없음", not p.get("ok", true) and str(p.get("reason", "")).contains("가득"), str(p.get("reason", "")))
	p = res.evaluate(stew, sp(Layout.CAMPFIRE + Vector3(-6, 0, 4)))
	check("빈 땅에 놓으면 거부", not p.get("ok", true))

	# ── 9. 낮 회복: 꺼진 불·불가에서 먼 곳은 회복 없음, 켜진 불 곁은 초당 0.3
	var far_hp: float = other.hp
	await get_tree().create_timer(1.0).timeout
	check("낮이라도 모닥불이 꺼져 있으면 회복하지 않음", absf(other.hp - far_hp) < 0.05, "%.2f → %.2f" % [far_hp, other.hp])
	check("불이 꺼져 있으면 다친 전투직이 불가로 가지 않음", not other.wants_campfire_rest())
	yard.fuel = 180.0
	await frames(3)
	check("불이 켜지면 다친 전투직은 모닥불 곁으로 쉬러 감(IDLE)", other.state == AllyScript.State.IDLE and Vector2(other.guard_point.x - Layout.CAMPFIRE.x, other.guard_point.z - Layout.CAMPFIRE.z).length() <= Cfg.CAMPFIRE_HEAL_RADIUS,
		"state=%d" % other.state)
	other.global_position = other.guard_point
	await frames(2)
	check("모닥불 곁 회복 속도 = 초당 0.3", absf(other.campfire_heal_rate() - 0.3) < 0.001, "%.3f" % other.campfire_heal_rate())
	var h0: float = other.hp
	await get_tree().create_timer(2.0).timeout
	var gained: float = other.hp - h0
	check("2초에 약 0.6 회복(매우 느림)", gained > 0.3 and gained < 1.0, "+%.2f" % gained)
	check("모닥불 곁 상태 문구", other.status_text() == "모닥불 곁에서 회복 중", other.status_text())
	other.hp = other.max_hp
	await frames(3)
	check("다 나으면 정찰로 돌아감", other.state == AllyScript.State.PATROL or other.state == AllyScript.State.PATROL_WAIT, "state=%d" % other.state)
	check("불가에서 먼 곳은 회복 0", yard.heal_rate_at(Layout.CAMPFIRE + Vector3(Cfg.CAMPFIRE_HEAL_RADIUS + 1.0, 0, 0)) == 0.0)

	# ── 10. 밤: 연료는 계속 타고, 모닥불 낮 회복은 없음
	main.session.wave_index = 0
	main.session.start_wave()
	await frames(3)
	var night_fuel: float = yard.fuel
	check("밤에는 모닥불 낮 회복이 없음", yard.heal_rate_at(Layout.CAMPFIRE + Vector3(1.7, 0, 0)) == 0.0)
	await get_tree().create_timer(0.6).timeout
	check("밤에도 연료가 탐", yard.fuel < night_fuel - 0.2, "%.2f → %.2f" % [night_fuel, yard.fuel])
	# 손패 흐름 v1: 목재는 낮 카드라 밤에는 주머니로 간다(손패에 없음). 밤의 산장 보강은 겨울 장작이 맡는다
	check("밤에는 목재가 손패에 없음(낮 카드 → 주머니)", hand_uid("timber") == -1 and main.cards.pocket_count_of("timber") > 0, "pocket timber=%d" % main.cards.pocket_count_of("timber"))
	main.waves.stop()
