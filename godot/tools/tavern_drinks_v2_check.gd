extends Node
## 에린의 술 카드 v2 자동 검증(사용자 요청 2026-10-27): 용의 숨결(불바다 장판)·서리 거인의 독주(2초 완전 결빙)·건배!(5초 취기 → 2초 구토).
## 실제 게임 장면에서 판정·사용·피해·결빙·버프 배율·전투불능과 연출 노드를 확인한다. 결과: res://art_sources/tavern-drinks-v2-verify.json

const Layout := preload("res://scripts/world/layout.gd")
const MonsterScript := preload("res://scripts/actors/monster.gd")
const SessionScript := preload("res://scripts/game/game_session.gd")
const Catalog := preload("res://scripts/ui/card_catalog.gd")

const IDS := ["dragon_breath", "frost_giant_spirit", "cheers"]

var main
var results: Array = []
var failures := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	while get_tree().current_scene == null or get_tree().current_scene.get("session") == null:
		await get_tree().process_frame
	main = get_tree().current_scene
	await get_tree().process_frame
	await _run()
	var out := {"passed": failures == 0, "checks": results.size(), "failures": failures, "results": results}
	var f := FileAccess.open("res://art_sources/tavern-drinks-v2-verify.json", FileAccess.WRITE)
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


func give(id: String) -> int:
	while main.cards.hand_full():
		main.cards.entries.erase(main.cards.hand()[0])
	main.cards.add(id, 1, "", "hand")
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
	return m


func clear_enemies() -> void:
	for e in get_tree().get_nodes_in_group("enemies"):
		e.queue_free()
	await frames(2)


func _run() -> void:
	var tv = main.tavern
	var res = main.resolver
	var cards = main.cards
	await frames(5)
	main.waves.set_process(false)
	var spot: Vector3 = Layout.DOOR_FRONT + Vector3(6, 0, 4)
	main.player.global_position = Layout.DOOR_FRONT + Vector3(-6, 0, 2)
	main.session.state = SessionScript.State.PREP

	# ── 1. 데이터
	var ok_cat := true
	for id in IDS:
		var d: Dictionary = cards.def(id)
		if d.is_empty() or d.get("race", "") != "tavern" or (d.get("printed_rules", []) as Array).size() != 2 or str(d.get("description", "")).length() < 20:
			ok_cat = false
	check("카탈로그에 새 술 3장(주점·설명 2줄·소개문)", ok_cat)
	check("이름: 용의 숨결 · 서리 거인의 독주 · 건배!", cards.def("dragon_breath").get("name", "") == "용의 숨결"
		and cards.def("frost_giant_spirit").get("name", "") == "서리 거인의 독주" and cards.def("cheers").get("name", "") == "건배!")
	var en: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/cards/catalog_en.json"))
	var en_cards: Dictionary = en.get("cards", en)
	check("영문 카드 문구(F8)", IDS.all(func(id): return en_cards.has(id)))
	check("용의 숨결·서리 거인은 다른 술처럼 낱장 소모품", ["dragon_breath", "frost_giant_spirit"].all(func(id): return cards.def(id).get("kind", "") == "consumable" and not cards.stackable(id)))
	check("시간대: 세 장 모두 밤 전투", IDS.all(func(id): return cards.phase_of(id) == "night"))
	check("세 장 모두 술로 세고(에린 조건) 에린 카드에서 나옴", IDS.all(func(id): return id in tv.DRINK_IDS and tv.ERIN_WEIGHTS.has(id) and tv.handles(id)))
	var art_ok := true
	for id in IDS:
		var t: Texture2D = Catalog.texture(id)
		var h: Texture2D = Catalog.texture(id, true)
		if t == null or h == null or t.get_width() != 1024 or h.get_width() != 256:
			art_ok = false
	check("카드 그림 3장 로드(1024·손패 256)", art_ok)
	var tex_ok := true
	for p in ["res://assets/vfx/tavern/fire_pool.png", "res://assets/vfx/tavern/ice_block.png", "res://assets/vfx/tavern/vomit_puddle.png"]:
		if not ResourceLoader.exists(p) or load(p) == null:
			tex_ok = false
	check("연출 텍스처 3장(불바다·얼음·토사물) 로드", tex_ok)

	# ── 2. 낮에는 못 씀
	var uid: int = await give("dragon_breath")
	check("낮에는 용의 숨결을 못 던짐", not res.evaluate(uid, sp(spot)).get("ok", true))
	uid = await give("cheers")
	check("낮에는 건배 불가", not res.evaluate(uid, sp(spot)).get("ok", true))
	main.session.state = SessionScript.State.COMBAT

	# ── 3. 용의 숨결
	await clear_enemies()
	var inside = enemy(spot + Vector3(1.0, 0, 0.5))
	var outside = enemy(spot + Vector3(tv.BREATH_RADIUS + 3.0, 0, 0))
	inside.set_physics_process(false)
	outside.set_physics_process(false)
	uid = await give("dragon_breath")
	var plan: Dictionary = res.evaluate(uid, sp(spot))
	check("밤: 땅에 용의 숨결 판정 ok · 반경 표시", plan.get("ok", false) and is_equal_approx(float(plan.get("radius", 0.0)), tv.BREATH_RADIUS), str(plan.get("reason", "")))
	var hp0: float = inside.hp
	var r: Dictionary = res.commit(uid, sp(spot))
	await frames(2)
	var fires := get_tree().get_nodes_in_group("dragon_breath_fires")
	check("사용: 카드 소비 · 불바다 노드 생성", r.get("ok", false) and cards.get_entry(uid).is_empty() and fires.size() == 1)
	var fire = fires[0] if not fires.is_empty() else null
	check("불바다에 텍스처 데칼이 깔림", fire != null and fire.find_children("*", "MeshInstance3D", true, false).size() >= 2)
	for i in 3:
		fire._process(0.5)
	check("불바다 위의 적은 계속 피해(1.5초 ≈ 12)", hp0 - inside.hp >= tv.BREATH_DPS * 1.4, "%.1f" % (hp0 - inside.hp))
	check("반경 밖의 적은 무사", is_equal_approx(outside.hp, 200.0))
	fire._process(tv.BREATH_TIME)
	await frames(2)
	check("시간이 다하면 불이 꺼짐", get_tree().get_nodes_in_group("dragon_breath_fires").is_empty())

	# ── 4. 서리 거인의 독주
	await clear_enemies()
	var a1 = enemy(spot + Vector3(0.8, 0, 0))
	var a2 = enemy(spot + Vector3(-1.2, 0, 1.0))
	var far = enemy(spot + Vector3(tv.FREEZE_RADIUS + 3.0, 0, 0))
	await frames(2)
	uid = await give("frost_giant_spirit")
	r = res.commit(uid, sp(spot))
	await frames(1)
	check("사용: 반경 안 적 2마리 결빙", r.get("ok", false) and tv.is_frozen(a1) and tv.is_frozen(a2) and not tv.is_frozen(far))
	check("언 적은 물리 처리 정지(이동·공격·동작 멈춤), 밖은 그대로", not a1.is_physics_processing() and not a2.is_physics_processing() and far.is_physics_processing())
	check("언 적 몸에 얼음 덩어리가 씌워짐", a1.get_node_or_null("TavernIce") != null and a2.get_node_or_null("TavernIce") != null)
	var pos0: Vector3 = a1.global_position
	for i in 10:
		await get_tree().physics_frame
	check("얼어 있는 동안 제자리", a1.global_position.distance_to(pos0) < 0.01)
	tv._tick_drinks(1.0)
	check("1초 뒤에도 아직 얼음", tv.is_frozen(a1))
	tv._tick_drinks(1.05)
	await frames(2)
	check("2초가 지나면 녹아 다시 움직임 · 얼음 사라짐", not tv.is_frozen(a1) and a1.is_physics_processing() and a1.get_node_or_null("TavernIce") == null)
	# 얼어 있는 적도 맞으면 피해를 받는다
	tv.freeze(a2)
	var hp2: float = a2.hp
	a2.take_damage(10.0)
	check("얼음 속 적도 피해를 받음", a2.hp < hp2)
	tv._tick_drinks(5.0)

	# ── 5. 건배!
	await clear_enemies()
	var m1 = main.contracts.spawn_guard("merc", "브람", spot + Vector3(2, 0, 0), null, "warrior")
	var m2 = main.contracts.spawn_guard("merc", "하랄", spot + Vector3(-2, 0, 0), null, "hunter")
	await frames(2)
	var mercs: Array = tv.cheer_targets()
	var dmg0: float = m1._damage_mult()
	var int0: float = m1._interval_mult()
	uid = await give("cheers")
	plan = res.evaluate(uid, sp(spot))
	check("밤: 건배 판정 ok · 용병 %d명" % mercs.size(), plan.get("ok", false) and mercs.size() >= 2)
	r = res.commit(uid, sp(spot))
	check("사용: 카드 소비 · 모든 용병 취기", r.get("ok", false) and mercs.all(func(a): return tv.tipsy(a)))
	check("취기: 공격력 +50%", is_equal_approx(m1._damage_mult(), dmg0 * (1.0 + tv.CHEERS_DAMAGE)), "%.2f → %.2f" % [dmg0, m1._damage_mult()])
	check("취기: 공격 간격 ×0.6(공격 속도 ↑)", is_equal_approx(m1._interval_mult(), int0 * tv.CHEERS_INTERVAL))
	uid = await give("cheers")
	check("취해 있는 동안 또 건배는 불가", not res.evaluate(uid, sp(spot)).get("ok", true))
	tv._tick_drinks(4.0)
	check("4초: 아직 취기", tv.tipsy(m1) and not tv.dazed(m1))
	tv._tick_drinks(1.05)
	check("5초 뒤: 취기 끝 · 전투불능(구토)", not tv.tipsy(m1) and tv.dazed(m1) and tv.dazed(m2) and is_equal_approx(m1._damage_mult(), dmg0))
	check("전투불능 상태 문구", m1.status_text().begins_with("건배 뒤 게우는 중"))
	var puddles := 0
	for n in main.actors.get_children():
		if n.name.begins_with("VomitPuddle"):
			puddles += 1
	check("각자 자리 발 앞에 토사물 웅덩이", puddles >= mercs.size(), str(puddles))
	var foe = enemy(m1.global_position + Vector3(1.2, 0, 0))
	foe.set_physics_process(false)
	await frames(1)
	var p1: Vector3 = m1.global_position
	var foe_hp: float = foe.hp
	for i in 20:
		await get_tree().physics_frame
	check("전투불능 동안 이동·공격 없음(옆의 적도 무사)", m1.global_position.distance_to(p1) < 0.05 and is_equal_approx(foe.hp, foe_hp))
	tv._tick_drinks(2.05)
	check("2초 뒤 회복: 취기·전투불능 모두 끝", not tv.dazed(m1) and not tv.tipsy(m1) and tv._cheered.is_empty())
	for i in 40:
		await get_tree().physics_frame
	check("회복 뒤 다시 싸움(옆의 적이 맞음)", foe.hp < foe_hp, "%.1f → %.1f" % [foe_hp, foe.hp])

	# ── 6. 밤이 끝나면 정리
	var e3 = enemy(spot)
	await frames(1)
	tv.freeze(e3)
	tv.cheers()
	main.session.state = SessionScript.State.PREP
	tv._on_state(SessionScript.State.PREP)
	check("새벽: 얼음·취기가 모두 풀림", tv._frozen.is_empty() and tv._cheered.is_empty() and e3.is_physics_processing())
