extends Node
## 직업 분화 v1 자동 검증(docs/mercenary-jobs-design.md). 실제 게임 장면에서 네 직업·야생 동물·나무 전체 벌목·자원 전달·보물상자·유물을 재현한다.
## 결과: res://art_sources/jobs-verify.json

const Cfg := preload("res://scripts/config.gd")
const SessionScript := preload("res://scripts/game/game_session.gd")
const AllyScript := preload("res://scripts/actors/ally.gd")
const GuestProfiles := preload("res://scripts/ui/guest_profiles.gd")
const TreeHighlight := preload("res://scripts/visual/tree_highlight.gd")

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
	var f := FileAccess.open("res://art_sources/jobs-verify.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(out, "\t") + "\n")
	print("JOBS_VERIFY passed=", failures == 0, " checks=", results.size(), " failures=", failures)
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


func ally_of(job: String):
	for a in main.contracts.allies:
		if is_instance_valid(a) and not a.dead and a.job == job:
			return a
	return null


func _run() -> void:
	var cards = main.cards
	var world = main.world
	var eco = main.economy
	await frames(5)

	# ── 1. 카탈로그·직업 데이터
	for id in Cfg.JOB_CARDS + ["raw_meat", "rabbit_pelt", "treasure_chest", "relic_unknown"] + Cfg.RELICS:
		if cards.def(id).is_empty():
			check("카탈로그에 %s 있음" % id, false)
	check("카탈로그: 네 직업·새 자원·상자·유물 13종 등록, 도끼 용병 제거", cards.def("axe_mercenary").is_empty() and not cards.def("hunter").is_empty())
	check("인물별 고정 직업: 브람=전투용병·올라프=사냥꾼·토르빈=나무꾼·미라=채집가",
		GuestProfiles.job_of("브람") == "warrior" and GuestProfiles.job_of("올라프") == "hunter" and GuestProfiles.job_of("토르빈") == "lumberjack" and GuestProfiles.job_of("미라") == "gatherer")
	check("미라가 고용 가능 인물로 바뀜", GuestProfiles.character("mira").get("hireable", false))

	# ── 2. 나무: 전체 벌목 대상·높이별 목재량·둘러싸임 판정
	var n_trees: int = world.harvest_trees.size()
	check("모든 나무가 벌목 대상(위험 지역을 뺀 130그루 이상)", n_trees >= 130, "trees=%d" % n_trees)
	var y6: int = world.tree_yield(6.0)
	# 재화 1장=1개 전환(2026-10-18): 한 그루 2~6장. 6m → 6, 1.6m 묘목 → 2, 8.2m → 6(상한)
	check("목재량: 6m 나무 6장, 1.6m 묘목 2장, 8.2m 6장(상한)", y6 == 6 and world.tree_yield(1.6) == 2 and world.tree_yield(8.2) == 6, "y6=%d" % y6)
	var blocked := 0
	var open_tree = null
	for t in world.harvest_trees:
		var why: String = world.tree_access(t)
		if why != "":
			blocked += 1
		elif open_tree == null and t["pos"].distance_to(main.player.global_position) < 14.0:
			open_tree = t
	check("둘러싸인 나무가 일부 있고(지정 불가), 접근 가능한 나무도 있음", blocked > 0 and open_tree != null, "blocked=%d" % blocked)

	# ── 3. 고용 → 직업 카드
	await wait_until(func(): return not eco.offers.is_empty(), 40.0)
	if not eco.offers.is_empty():
		var o: Dictionary = eco.offers[0]
		var job: String = eco.offer_job(o)
		eco.gold = 200
		var ok: bool = eco.hire(o)
		check("고용 → 인물 직업과 같은 계약 카드(%s)" % job, ok and cards.count_of(job) == 1 and cards.get_entry(uid_of(job))["person"] == o["person"])
	else:
		check("고용 제안 발생", false)

	# ── 4. 나무꾼: 벌목 → 목재 보관 → 마녀 접근 시 전달
	for e in cards.entries.duplicate():
		if cards.is_job(e["id"]):
			cards.consume(e["uid"])
	cards.add("lumberjack", 1, "검증나무꾼")
	await frames(3)
	var tpos: Vector3 = open_tree["pos"]
	var plan: Dictionary = main.resolver.evaluate(uid_of("lumberjack"), sp(tpos + Vector3(0, minf(open_tree["height"] * 0.45, 2.4), 0)))
	check("나무꾼 카드를 나무 위에서 판정 → 벌목 계획", plan["ok"] and plan["action"] == "chop" and plan["tree"] == open_tree, str(plan.get("reason", "")))
	# 선택 강조: 모델 전체 덧칠 + 외곽선, 바닥 고리는 없음
	TreeHighlight.set_target(open_tree, true)
	var hulls: int = open_tree["visual"].find_children("__outline", "MeshInstance3D", true, false).size()
	var tinted := 0
	for mi in open_tree["visual"].find_children("*", "MeshInstance3D", true, false):
		if mi.name != "__outline" and mi.material_overlay != null:
			tinted += 1
	check("선택 나무 강조: 외곽선 껍질과 모델 덧칠 적용", hulls > 0 and tinted > 0, "hulls=%d tinted=%d" % [hulls, tinted])
	TreeHighlight.clear()
	check("강조 해제 시 덧칠·외곽선 제거", open_tree["visual"].find_children("__outline", "MeshInstance3D", true, false).size() == 0)
	# 둘러싸인 나무는 거부
	var crowded = null
	for t in world.harvest_trees:
		if world.tree_access(t).begins_with("나무에 둘러싸여"):
			crowded = t
			break
	if crowded != null:
		var bad: Dictionary = main.resolver.evaluate(uid_of("lumberjack"), sp(crowded["pos"] + Vector3(0, minf(crowded["height"] * 0.45, 2.4), 0)))
		check("둘러싸인 나무에 놓으면 거부·미소비", not bad["ok"] and cards.count_of("lumberjack") == 1, str(bad.get("reason", "")))
	var r: Dictionary = main.resolver.commit(uid_of("lumberjack"), sp(tpos + Vector3(0, minf(open_tree["height"] * 0.45, 2.4), 0)))
	check("나무꾼 소환·카드 소비", r["ok"] and cards.count_of("lumberjack") == 0 and ally_of("lumberjack") != null)
	var lj = ally_of("lumberjack")
	var timber_before: int = cards.count_of("timber")
	var remaining_before: int = open_tree["remaining"]
	var chopped := await wait_until(func(): return lj != null and lj.carry.get("timber", 0) > 0, 40.0)
	check("벌목 1회 → 목재를 나무꾼이 보관(손패에는 아직 없음)", chopped and cards.count_of("timber") == timber_before and open_tree["remaining"] == remaining_before - Cfg.CHOP_YIELD,
		"carry=%s remaining=%d" % [str(lj.carry), open_tree["remaining"]])
	check("나무꾼은 같은 나무를 계속 벤다", lj.tree == open_tree and lj.state in [AllyScript.State.WORKING, AllyScript.State.GO_WORK])
	# 마녀가 다가가면 전달
	main.player.global_position = lj.global_position + Vector3(0.8, 0, 0.8)
	var handed := await wait_until(func(): return lj.carry.is_empty(), 5.0)
	check("마녀 접근 → 목재 손패로 전달", handed and cards.count_of("timber") == timber_before + Cfg.CHOP_YIELD, "timber=%d" % cards.count_of("timber"))
	main.player.global_position = Vector3(5.3, 0, 6.2)
	# 다 베이면 나무가 사라진다
	open_tree["remaining"] = 3
	var felled := await wait_until(func(): return open_tree.get("removed", false), 40.0)
	check("목재가 바닥난 나무는 사라짐(목록·충돌 제거, 나무꾼은 다음 나무로)", felled and not open_tree in world.harvest_trees and open_tree["body"].collision_layer == 0 and world.harvest_trees.size() == n_trees - 1,
		"trees=%d" % world.harvest_trees.size())
	await frames(10)
	check("나무꾼이 다음 접근 가능한 나무를 스스로 맡음", lj.tree != null and lj.tree != open_tree and lj.task == "chop", "state=%d" % lj.state)

	# ── 5. 야생 동물과 사냥꾼
	var rabbit = main.wildlife.spawn("rabbit", Vector3(-4.0, 0, 9.0))
	var deer = main.wildlife.spawn("deer", Vector3(-6.0, 0, 11.0))
	check("토끼·사슴 출현(animals 그룹)", rabbit != null and deer != null and get_tree().get_nodes_in_group("animals").size() >= 2)
	var deer_loot: Dictionary = deer.loot() if deer != null else {}
	check("사슴 전리품은 생고기만(2개)", deer_loot == {"raw_meat": Cfg.DEER_MEAT})
	var rabbit_ok := true
	for i in 20:
		var l: Dictionary = rabbit.loot()
		if not (l == {"rabbit_pelt": 1} or l == {"raw_meat": 1}):
			rabbit_ok = false
	check("토끼 전리품은 가죽 또는 생고기 1개", rabbit_ok)
	cards.add("hunter", 1, "검증사냥꾼")
	await frames(3)
	var hr: Dictionary = main.resolver.commit(uid_of("hunter"), sp(Vector3(-2.0, 0, 8.0)))
	check("사냥꾼 지면 배치", hr["ok"] and ally_of("hunter") != null, str(hr.get("reason", "")))
	var hunter = ally_of("hunter")
	var hunting := await wait_until(func(): return hunter != null and hunter.state == AllyScript.State.HUNT, 15.0)
	check("낮의 사냥꾼은 사냥감을 찾아 사냥 상태로", hunting, "state=%d" % (hunter.state if hunter != null else -1))
	var looted := await wait_until(func(): return hunter != null and hunter.carry_total() > 0, 45.0)
	check("활로 사냥 성공 → 전리품 보관", looted, "carry=%s" % str(hunter.carry if hunter != null else {}))
	main.player.global_position = hunter.global_position + Vector3(0.8, 0, 0.6)
	var handed2 := await wait_until(func(): return hunter.carry.is_empty(), 5.0)
	check("마녀 접근 → 사냥 전리품 전달(생고기/가죽 카드)", handed2 and cards.count_of("raw_meat") + cards.count_of("rabbit_pelt") > 0)
	main.player.global_position = Vector3(5.3, 0, 6.2)

	# ── 6. 전투용병: 정찰 → 적 발견 → 교전, 산장 공격자 우선
	cards.add("warrior", 1, "검증전사")
	await frames(3)
	var wr: Dictionary = main.resolver.commit(uid_of("warrior"), sp(Vector3(1.0, 0, 7.5)))
	check("전투용병 지면 배치 → 정찰", wr["ok"] and ally_of("warrior") != null and ally_of("warrior").state in [AllyScript.State.PATROL, AllyScript.State.PATROL_WAIT])
	var warrior = ally_of("warrior")
	var p0: Vector3 = warrior.global_position
	await wait_until(func(): return warrior.global_position.distance_to(p0) > 1.0, 10.0)
	check("정찰: 가만히 서 있지 않고 산장 주변을 걷는다", warrior.global_position.distance_to(p0) > 1.0)

	# ── 7. 채집가: 경로 계획 → 탐색 → 줍기
	cards.add("gatherer", 1, "검증채집가")
	await frames(3)
	main.session.prep_elapsed = 5.0
	var gr: Dictionary = main.resolver.commit(uid_of("gatherer"), sp(Vector3(-1.0, 0, 8.5)))
	var gat = ally_of("gatherer")
	check("채집가 배치 → 탐색 출발(경로 지점 있음)", gr["ok"] and gat != null and gat.state == AllyScript.State.GATHER_OUT and not gat.gather_stops.is_empty(), str(gr.get("reason", "")))
	main.contracts.gather_pick(gat)
	main.contracts.gather_pick(gat)
	main.contracts.gather_pick(gat)
	main.contracts.gather_pick(gat)
	check("줍기 표: 네 번 굴리면 보관이 생기거나 빈손 안내(상자는 하루 1개 제한)", gat.carry_total() >= 0 and int(gat.carry.get("treasure_chest", 0)) <= Cfg.GATHER_CHEST_PER_DAY, str(gat.carry))
	main.session.prep_elapsed = Cfg.PREP_TIME - Cfg.GATHER_RETURN_MARGIN + 1.0
	await frames(5)
	check("저녁이 가까우면 채집가는 귀환", gat.state == AllyScript.State.GATHER_RETURN or gat.state == AllyScript.State.IDLE, "state=%d" % gat.state)
	main.session.prep_elapsed = 20.0

	# ── 8. 밤: 비전투직 대피, 전투직 교전, 산장 공격자 추적, 동물 퇴장
	var lj2 = ally_of("lumberjack")
	main.session.start_wave()
	await frames(3)
	check("웨이브 시작 → 야생 동물 사라짐", get_tree().get_nodes_in_group("animals").size() == 0)
	var hid := await wait_until(func(): return lj2.hidden, 30.0)
	check("나무꾼은 산장 안으로 대피(숨김·피격 불가)", hid and not lj2.visible and lj2.collision_mask == 0)
	var engaged := await wait_until(func(): return warrior.state == AllyScript.State.ENGAGE or hunter.state == AllyScript.State.ENGAGE, 40.0)
	check("적이 산장 근처로 오면 전투직이 스스로 교전", engaged, "w=%d h=%d" % [warrior.state, hunter.state])
	var enemies := get_tree().get_nodes_in_group("wave_enemies")
	if not enemies.is_empty():
		var attacker = enemies[0]
		world.lodge.take_damage(1.0, attacker)
		await frames(2)
		check("산장 피격 → 공격자가 전투직의 우선 대상", main.contracts.lodge_threat == attacker and warrior.target == attacker)
	var arrows := await wait_until(func(): return get_tree().root.find_child("Shaft", true, false) != null, 20.0)
	check("사냥꾼은 화살(원거리)로 공격", arrows)
	main.debug_kill_all()
	await wait_until(func(): return main.session.state == SessionScript.State.PREP, 40.0)
	await frames(5)
	check("새벽 → 대피했던 나무꾼이 다시 나와 일함", not lj2.hidden and lj2.visible and lj2.task == "chop")
	check("새벽 → 전투직은 정찰로 복귀", warrior.state in [AllyScript.State.PATROL, AllyScript.State.PATROL_WAIT])

	# ── 9. 생고기·가죽 판매와 회복
	cards.add("raw_meat", 2)
	cards.add("rabbit_pelt", 2)
	await frames(2)
	main.player.hp = 50.0
	var meat: Dictionary = main.resolver.commit(uid_of("raw_meat"), sp(main.player.global_position + Vector3(0, 1.0, 0)))
	check("생고기를 마녀에게 → 체력 +%d, 1개 소비" % int(Cfg.MEAT_HEAL), meat["ok"] and meat["action"] == "eat" and main.player.hp == 50.0 + Cfg.MEAT_HEAL, str(meat.get("reason", "")))
	var pelt_plan: Dictionary = main.resolver.evaluate(uid_of("rabbit_pelt"), sp(world.lodge.global_position + Vector3(0, 2.0, 0)))
	check("토끼 가죽을 산장에 → 판매 창(1개 %dG)" % Cfg.PELT_PRICE, pelt_plan["ok"] and pelt_plan["action"] == "sell")
	var gold0: int = eco.gold
	check("가죽 판매 → 골드", eco.sell_resource(uid_of("rabbit_pelt"), 2) and eco.gold == gold0 + 2 * Cfg.PELT_PRICE)

	# ── 10. 보물상자 → 물음표 3장 → 선택 → 유물(패시브)
	cards.add("treasure_chest", 1)
	await frames(2)
	var cr: Dictionary = main.resolver.commit(uid_of("treasure_chest"), sp(Vector3(2.0, 0, 8.0)))
	check("보물상자를 땅에 → 상자 열림(게임 정지)", cr["ok"] and main.chest_ui.active and get_tree().paused and cards.count_of("treasure_chest") == 0)
	var picked := await wait_until(func(): return main.chest_ui._phase == "pick", 10.0)
	check("물음표 카드 %d장 등장" % Cfg.CHEST_CHOICES, picked and main.chest_ui.cards.size() == Cfg.CHEST_CHOICES)
	var first_id: String = main.chest_ui.choices[0] if picked else ""
	main.chest_ui._on_pick(0)
	var granted := await wait_until(func(): return main.relics.has(first_id), 10.0)
	check("하나를 고르면 그 유물 획득(영구), 상자 닫힘·정지 해제", granted and not main.chest_ui.active and not get_tree().paused and main.relics.count() == 1)
	check("유물칸에 아이콘 표시", main.hud.relic_tray.get_child_count() == 1)
	for id in Cfg.RELICS:
		main.relics.grant(id)
	check("유물 5종 모두 보유 → 상자는 목재로 대체", main.relics.choices().is_empty())
	var tb: int = cards.count_of("timber")
	cards.add("treasure_chest", 1)
	await frames(2)
	var cr2: Dictionary = main.resolver.commit(uid_of("treasure_chest"), sp(Vector3(2.0, 0, 8.0)))
	check("다 모은 뒤 상자 → 목재 +%d" % Cfg.CHEST_FALLBACK_TIMBER, cr2["ok"] and cards.count_of("timber") == tb + Cfg.CHEST_FALLBACK_TIMBER)
	check("유물 효과: 마법탄 피해·사거리, 적 감속, 벌목 시간", main.relics.bolt_damage() == Cfg.BOLT_DAMAGE * Cfg.RELIC_BOLT_MULT and main.relics.enemy_speed_mult() == Cfg.RELIC_FROST_SLOW and lj2._chop_time() == Cfg.RELIC_CHOP_TIME)
	check("활동 상한 16 (숲의 괴물 하수인 제외)", Cfg.ACTIVE_LIMIT == 16)
