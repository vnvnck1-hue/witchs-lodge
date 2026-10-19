extends Node
## 고블린 카드 v1 · 용병 이벤트 · 적 처치 골드 자동 검증(docs/goblin-cards-v01.md).
## 실제 게임 장면에서 카드 13장의 판정·사용, 졸개·미끼·덫·방책, 장비 4종 효과, 새벽 정리, 고블린 용병 이벤트와
## 말라의 특별 이야기, 처치 골드(기본·적 종류·동전 저울)를 확인한다. 결과: res://art_sources/goblin-cards-verify.json

const Cfg := preload("res://scripts/config.gd")
const Layout := preload("res://scripts/world/layout.gd")
const GoblinData := preload("res://scripts/game/goblin_data.gd")
const MonsterScript := preload("res://scripts/actors/monster.gd")
const SessionScript := preload("res://scripts/game/game_session.gd")
const GuestProfiles := preload("res://scripts/ui/guest_profiles.gd")

const NEW_CARDS := ["goblin_gang", "goblin_firecracker", "dud_bomb", "goblin_rush", "shiny_lure", "junk_barricade",
	"pikl_traps", "junk_sack", "scrap", "graz_whistle", "pot_helmet", "mala_coin_scale", "mala_monocle"]

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
	var f := FileAccess.open("res://art_sources/goblin-cards-verify.json", FileAccess.WRITE)
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


func physics(n := 2) -> void:
	for i in n:
		await get_tree().physics_frame


func sp(p: Vector3) -> Vector2:
	return main.world.camera.unproject_position(p)


func give(id: String, n := 1) -> int:
	while main.cards.hand_full():
		main.cards.entries.erase(main.cards.hand()[0])
	main.cards.add(id, n, "", "hand")
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


func set_state(s: int) -> void:
	main.session.state = s


func _run() -> void:
	var g = main.goblin
	var res = main.resolver
	var cards = main.cards
	await frames(5)
	main.waves.set_process(false)
	spot = Layout.DOOR_FRONT + Vector3(6, 0, 4)
	main.player.global_position = Layout.DOOR_FRONT + Vector3(-6, 0, 2)

	# ── 1. 데이터·모듈
	check("모듈 3개가 붙어 있음(고블린 카드·용병 이벤트·처치 골드)", g != null and main.merc_events != null and main.kill_gold != null)
	var missing: Array = []
	for id in NEW_CARDS:
		if cards.def(id).is_empty():
			missing.append(id)
	check("카탈로그에 고블린 카드 13장", missing.is_empty(), str(missing))
	check("시간대: 졸개·폭죽·미끼는 밤, 자루·쇠붙이는 낮, 방책·덫·장비는 공용",
		cards.phase_of("goblin_gang") == "night" and cards.phase_of("shiny_lure") == "night" and cards.phase_of("junk_sack") == "day"
		and cards.phase_of("junk_barricade") == "both" and cards.phase_of("pot_helmet") == "both")
	check("장비 4종이 장비 표에 칸과 함께 등록", Cfg.EQUIPMENT.get("graz_whistle", {}).get("slot", "") == "trinket" and Cfg.EQUIPMENT.get("pot_helmet", {}).get("slot", "") == "armor"
		and main.equipment.effect_text("pot_helmet") != "")
	check("고블린 인물(그라즈·타크·피클·러스크)이 고블린 종족", ["그라즈", "타크", "피클", "러스크"].all(func(p): return GuestProfiles.race_of(p) == "goblin"))

	# ── 2. 적 처치 골드
	var kg = main.kill_gold
	var gold0: int = main.economy.gold
	var e1 = enemy(spot)
	await frames(1)
	e1.take_damage(9999.0)
	await frames(2)
	check("기본 적 처치: 골드 +1", main.economy.gold == gold0 + 1, "%d → %d" % [gold0, main.economy.gold])
	var coins := 0
	for n in main.actors.get_children():
		if n is MeshInstance3D and n.mesh is CylinderMesh and n.material_override != null and n.material_override.albedo_color == Color(1.0, 0.8, 0.28):
			coins += 1
	check("동전이 흩뿌려짐(동전 메시 3개 이상)", coins >= 3, "%d개" % coins)
	await get_tree().create_timer(1.5).timeout
	var left := 0
	for n in main.actors.get_children():
		if n is MeshInstance3D and n.mesh is CylinderMesh and n.material_override != null and n.material_override.albedo_color == Color(1.0, 0.8, 0.28):
			left += 1
	check("동전은 마녀에게 빨려 들어가 사라짐(1.5초 뒤)", left == 0, "%d개 남음" % left)
	var gold1: int = main.economy.gold
	var b1 = enemy(spot, "brute")
	await frames(1)
	b1.take_damage(99999.0)
	check("공성 괴물 처치: 골드 +3", main.economy.gold == gold1 + 3, "%d → %d" % [gold1, main.economy.gold])
	# 동전 저울을 낀 용병이 노리던 적
	var bram = await merc("브람", "warrior", spot + Vector3(1.0, 0, 0))
	var scale_uid: int = await give("mala_coin_scale")
	var r: Dictionary = res.commit(scale_uid, sp(bram.global_position + Vector3(0, bram.hp_offset * 0.5, 0)))
	check("말라의 동전 저울을 용병에게 장착", r.get("ok", false) and main.equipment.equipped(bram, "trinket").get("id", "") == "mala_coin_scale", str(r.get("reason", "")))
	var e2 = enemy(spot + Vector3(4, 0, 0))
	await frames(1)
	bram.target = e2
	var gold2: int = main.economy.gold
	e2.take_damage(9999.0)
	check("동전 저울: 장착 용병이 노린 적 처치 → +1 +1", main.economy.gold == gold2 + 2, "%d → %d" % [gold2, main.economy.gold])
	var e3 = enemy(spot + Vector3(-4, 0, 0))
	await frames(1)
	var gold3: int = main.economy.gold
	e3.take_damage(9999.0)
	check("동전 저울: 다른 적 처치는 보너스 없음", main.economy.gold == gold3 + 1)
	main.equipment.unequip(bram, "trinket", false)
	var mono_uid: int = await give("mala_monocle")
	res.commit(mono_uid, sp(bram.global_position + Vector3(0, bram.hp_offset * 0.5, 0)))
	var e4 = enemy(spot + Vector3(4, 0, 2))
	await frames(1)
	bram.target = e4
	check("외알 안경: 장착 용병이 노린 적의 재화 드랍 배율 ×1.5(재화 드랍 시스템 연결 지점)", absf(kg.loot_chance_mult(e4) - 1.5) < 0.001 and absf(kg.loot_chance_mult(e3) - 1.0) < 0.001)
	e4.take_damage(9999.0)
	main.equipment.unequip(bram, "trinket", false)
	await clear_enemies()

	# ── 3. 고블린 용병 수와 낮 제한
	var graz = await merc("그라즈", "warrior", spot + Vector3(-2, 0, -2))
	check("고블린 용병 수 = 1(그라즈)", g.goblin_count() == 1, str(g.goblin_count()))
	set_state(SessionScript.State.PREP)
	var gang: int = await give("goblin_gang")
	r = res.evaluate(gang, sp(spot))
	check("사촌 패거리: 낮에는 거부(밤 전투 전용)", not r["ok"] and str(r["reason"]).contains("밤"), str(r.get("reason", "")))

	# ── 4. 밤: 사촌 패거리 → 졸개
	set_state(SessionScript.State.COMBAT)
	r = res.evaluate(gang, sp(spot))
	check("사촌 패거리: 밤 판정 ok(졸개 3마리 안내)", r["ok"] and str(r["lines"]).contains("3마리"), str(r.get("lines", r.get("reason", ""))))
	r = res.commit(gang, sp(spot))
	await frames(3)
	check("사촌 패거리: 졸개 3마리 소환 · 카드 소비", r["ok"] and g.minions().size() == 3 and cards.get_entry(gang).is_empty(), "%d" % g.minions().size())
	var m0 = g.minions()[0]
	check("졸개는 아군 그룹(적의 표적) · 고블린 니브 모델 축소", m0.is_in_group("allies") and m0.visual != null and m0.visual.scale.x < 0.7)
	# 졸개가 적을 공격한다
	var e5 = enemy(m0.global_position + Vector3(0.6, 0, 0), "spider", 100.0)
	await physics(6)
	await get_tree().create_timer(1.3).timeout
	check("졸개가 가까운 적을 찌른다", e5.hp < 100.0, "적 체력 %.0f" % e5.hp)
	await clear_enemies()
	# 고블린 2명이면 4마리
	main.cards.add("hunter", 1, "피클", "pocket")
	check("고블린 계약 카드도 고블린 수에 셈(2명)", g.goblin_count() == 2)
	var gang2: int = await give("goblin_gang")
	var before_m: int = g.minions().size()
	res.commit(gang2, sp(spot + Vector3(2, 0, 2)))
	await frames(3)
	check("고블린 용병 2명: 사촌 패거리 4마리", g.minions().size() == before_m + 4, "%d → %d" % [before_m, g.minions().size()])

	# ── 5. 떼거리 돌격
	var target_p: Vector3 = spot + Vector3(5, 0, -3)  # 앞마당 모닥불(태우기 판정)에서 먼 곳
	var e6 = enemy(target_p, "spider", 200.0)
	await frames(1)
	var rush: int = await give("goblin_rush")
	var n_min: int = g.minions().size()
	r = res.commit(rush, sp(target_p))
	check("떼거리 돌격: 졸개 수 × %d 피해" % int(GoblinData.RUSH_DAMAGE_PER), r["ok"] and absf((200.0 - e6.hp) - GoblinData.RUSH_DAMAGE_PER * n_min) < 0.01, "졸개 %d · 피해 %.0f · %s" % [n_min, 200.0 - e6.hp, str(r.get("reason", r.get("pos", "")))])
	check("떼거리 돌격: 졸개들이 목적지로 돌진 중", g.minions().all(func(m): return m.rush_to != null))
	await clear_enemies()

	# ── 6. 고블린 폭죽 · 불발탄
	var fp: Vector3 = spot + Vector3(-6, 0, -1)
	var ea = enemy(fp + Vector3(0.5, 0, 0), "spider", 100.0)
	var eb = enemy(fp + Vector3(-1.0, 0, 0.5), "spider", 100.0)
	await frames(1)
	var pos_a: Vector3 = ea.global_position
	var fire: int = await give("goblin_firecracker")
	r = res.commit(fire, sp(fp))
	check("고블린 폭죽: 범위 적 둘에게 피해 %d" % int(GoblinData.FIRECRACKER_DAMAGE), r["ok"] and absf(ea.hp - 86.0) < 0.01 and absf(eb.hp - 86.0) < 0.01, "%.0f / %.0f" % [ea.hp, eb.hp])
	check("고블린 폭죽: 맞은 적이 밀려나고(겁먹음) 공격을 멈춤", ea.global_position.distance_to(pos_a) > 1.0 and ea.attack_cd >= GoblinData.FIRECRACKER_FEAR - 0.01 and ea.slow_factor() < 0.5)
	var duds0: int = cards.count_of("dud_bomb")
	check("고블린 2명: 불발탄 없음", duds0 == 0)
	for p2 in ["러스크", "타크"]:
		main.cards.add("lumberjack" if p2 == "러스크" else "gatherer", 1, p2, "pocket")
	check("고블린 4명(활동 1 + 계약 카드 3)", g.goblin_count() == 4, str(g.goblin_count()))
	var fire2: int = await give("goblin_firecracker")
	res.commit(fire2, sp(fp))
	check("고블린 4명: 폭죽 뒤 불발탄 2장", cards.count_of("dud_bomb") == duds0 + 2, str(cards.count_of("dud_bomb")))
	await clear_enemies()
	var ec = enemy(fp, "spider", 100.0)
	await frames(1)
	var dud: int = -1
	for e in cards.entries:
		if e["id"] == "dud_bomb":
			dud = e["uid"]
	if cards.get_entry(dud).get("zone", "") != "hand":
		dud = await give("dud_bomb")
	r = res.commit(dud, sp(fp))
	check("불발탄: 피해 %d · %d초 기절(이동 0 · 공격 대기)" % [int(GoblinData.DUD_DAMAGE), int(GoblinData.DUD_STUN)], r["ok"] and absf(ec.hp - 96.0) < 0.01 and ec.slow_factor() == 0.0 and ec.attack_cd >= GoblinData.DUD_STUN - 0.01, "hp %.0f" % ec.hp)
	await clear_enemies()

	# ── 7. 반짝이 미끼
	var lp: Vector3 = spot + Vector3(0, 0, 6)
	var ed = enemy(lp + Vector3(4, 0, 0))
	var ee = enemy(lp + Vector3(12, 0, 0))
	await frames(1)
	var far_ap: Vector3 = ee.attack_point
	var orig_ap: Vector3 = ed.attack_point
	var lure: int = await give("shiny_lure")
	r = res.commit(lure, sp(lp))
	await frames(3)
	var lure_node = null
	for n in get_tree().get_nodes_in_group("allies"):
		if n.get("kind") == "goblin_lure":
			lure_node = n
	check("반짝이 미끼: 설치(아군 그룹 표적)", r["ok"] and lure_node != null)
	check("미끼 반경 %dm 안 적의 공격 지점이 미끼로, 밖은 그대로" % int(GoblinData.LURE_PULL), lure_node != null and ed.attack_point.distance_to(lure_node.global_position) < 0.01 and ee.attack_point == far_ap)
	var ef = enemy(lp + Vector3(1.0, 0, 0))
	await frames(1)
	check("미끼 반경 3m 안 적: 졸개 피해 배율 1.5", absf(g.minion_damage_mult(ef) - 1.5) < 0.01)
	lure_node.time_left = 0.0
	await frames(3)
	check("미끼가 터짐: 3m 안 적 눈부심(기절) · 끌린 적 공격 지점 복구", ef.slow_factor() == 0.0 and ed.attack_point == orig_ap and lure_node.dead)
	await clear_enemies()

	# ── 8. 고물 방책
	set_state(SessionScript.State.PREP)
	var bar: int = await give("junk_barricade")
	for e in cards.entries.duplicate():
		if e["id"] == "timber":
			cards.entries.erase(e)
	r = res.evaluate(bar, sp(spot + Vector3(0, 0, -4)))
	check("고물 방책: 손패에 목재가 없으면 거부", not r["ok"] and str(r["reason"]).contains("목재"), str(r.get("reason", "")))
	await give("timber", 2)
	r = res.commit(bar, sp(spot + Vector3(0, 0, -4)))
	await frames(2)
	var bars: Array = get_tree().get_nodes_in_group("junk_barricades")
	check("고물 방책: 목재 1 소비 · 체력 %d" % int(GoblinData.BARRICADE_HP), r["ok"] and bars.size() == 1 and cards.hand_count_of("timber") == 1 and absf(bars[0].hp - GoblinData.BARRICADE_HP) < 0.01)
	check("고물 방책은 적의 표적(아군 그룹)", bars[0].is_in_group("allies"))
	var built: int = bars[0].built_day
	g.on_dawn(built + 1)
	await frames(1)
	check("1일 뒤 새벽: 아직 서 있음", not bars[0].dead)
	g.on_dawn(built + GoblinData.BARRICADE_DAYS)
	await frames(1)
	check("%d일 뒤 새벽: 무너짐" % GoblinData.BARRICADE_DAYS, bars[0].dead)

	# ── 9. 피클의 덫
	var tp: Vector3 = spot + Vector3(-4, 0, -5)
	var traps_uid: int = await give("pikl_traps")
	r = res.commit(traps_uid, sp(tp))
	await frames(2)
	var traps: Array = get_tree().get_nodes_in_group("goblin_traps")
	check("피클의 덫: 덫 %d개" % GoblinData.TRAP_COUNT, r["ok"] and traps.size() == GoblinData.TRAP_COUNT, str(traps.size()))
	var eg = enemy(traps[0].global_position, "spider", 50.0)
	await physics(3)
	check("덫을 밟은 적: 피해 %d · 멈춤 · 덫 닫힘" % int(GoblinData.TRAP_DAMAGE), absf(eg.hp - 46.0) < 0.01 and eg.slow_factor() == 0.0 and not traps[0].armed, "hp %.0f" % eg.hp)
	await clear_enemies()
	g.on_dawn(main.session.day())
	check("새벽: 고블린 용병이 있어 터진 덫을 다시 깖", traps[0].armed)

	# ── 10. 잡동사니 자루 · 쇠붙이 판매
	var units0 := 0
	for e in cards.entries:
		units0 += int(e["count"])
	var sack: int = await give("junk_sack")
	units0 += 1
	r = res.commit(sack, sp(main.player.global_position))
	await frames(2)
	var units1 := 0
	for e in cards.entries:
		units1 += int(e["count"])
	var got: int = units1 - (units0 - 1)
	check("잡동사니 자루: 자원 %d~%d개가 나옴" % [GoblinData.SACK_MIN, GoblinData.SACK_MAX], r["ok"] and got >= GoblinData.SACK_MIN and got <= GoblinData.SACK_MAX, "%d개" % got)
	await give("scrap", 2)
	var g0: int = main.economy.gold
	check("쇠붙이 2개 판매 → +8G", main.economy.sell_id("scrap", 2) and main.economy.gold == g0 + 8)

	# ── 11. 냄비 투구
	set_state(SessionScript.State.COMBAT)
	var helm: int = await give("pot_helmet")
	r = res.commit(helm, sp(bram.global_position + Vector3(0, bram.hp_offset * 0.5, 0)))
	check("냄비 투구: 인간 용병 방어구 칸", r.get("ok", false) and main.equipment.equipped(bram, "armor").get("id", "") == "pot_helmet")
	var taken: Array = []
	for i in 5:
		bram.hp = bram.max_hp
		bram.take_damage(10.0)
		taken.append(snappedf(bram.max_hp - bram.hp, 0.01))
	check("냄비 투구: 피해 5회를 100·80·60·40·20%% 막음 → 0·2·4·6·8", taken == [0.0, 2.0, 4.0, 6.0, 8.0], str(taken))
	bram.hp = bram.max_hp
	bram.take_damage(10.0)
	check("냄비 투구: 인간이 쓰면 6번째 피해에 부서짐(칸 비고 카드 사라짐)", main.equipment.equipped(bram, "armor").is_empty() and not cards.in_play.any(func(e): return e["uid"] == helm) and cards.get_entry(helm).is_empty())
	var helm2: int = await give("pot_helmet")
	graz.hp = graz.max_hp
	res.commit(helm2, sp(graz.global_position + Vector3(0, graz.hp_offset * 0.5, 0)))
	for i in 5:
		graz.hp = graz.max_hp
		graz.take_damage(10.0)
	graz.hp = graz.max_hp
	graz.take_damage(10.0)
	check("냄비 투구: 고블린은 6번째에도 안 부서지고 10% 막음(피해 9)", main.equipment.equipped(graz, "armor").get("id", "") == "pot_helmet" and absf((graz.max_hp - graz.hp) - 9.0) < 0.01, "%.1f" % (graz.max_hp - graz.hp))
	g.on_dawn(main.session.day())
	graz.hp = graz.max_hp
	graz.take_damage(10.0)
	check("새벽: 고블린이 투구를 고쳐 다시 100%부터", absf(graz.max_hp - graz.hp) < 0.01)

	# ── 12. 그라즈의 호루라기
	for m in g.minions():
		m.leave()
	await frames(2)
	var wh: int = await give("graz_whistle")
	r = res.commit(wh, sp(graz.global_position + Vector3(0, graz.hp_offset * 0.5, 0)))
	check("호루라기: 고블린 용병 장신구 칸", r.get("ok", false) and main.equipment.equipped(graz, "trinket").get("id", "") == "graz_whistle")
	for i in 5:
		g._whistle_t.clear()
		await frames(2)
	var wm: int = g.minions().filter(func(m): return m.source == "whistle").size()
	check("호루라기: 밤에 졸개를 부르고 최대 %d마리" % GoblinData.WHISTLE_MAX, wm == GoblinData.WHISTLE_MAX, str(wm))
	var wh2: int = await give("graz_whistle")
	res.commit(wh2, sp(bram.global_position + Vector3(0, bram.hp_offset * 0.5, 0)))
	for i in 3:
		g._whistle_t.clear()
		await frames(2)
	check("호루라기: 인간 용병이 끼면 졸개가 오지 않음", g.minions().filter(func(m): return m.owner_ally == bram).is_empty())
	# 새벽: 졸개 귀가
	main.session.state_changed.emit(SessionScript.State.CLEARING)
	await frames(2)
	check("밤이 끝나면 졸개가 모두 돌아감", g.minions().is_empty())
	set_state(SessionScript.State.PREP)

	# ── 13. 고블린 용병 이벤트
	var me = main.merc_events
	var ge = main.guest_events
	var before_v: int = ge.visits.size()
	check("고블린 용병 명부(활동 + 계약 카드)", me.goblin_roster().size() == 4, str(me.goblin_roster()))
	var ok_t: bool = me.trigger([], "sack")
	var v: Dictionary = ge.visits.back()
	check("용병 이벤트: 대화 기록에 '용병 방문'이 생기고 말을 건다", ok_t and ge.visits.size() == before_v + 1 and v.get("merc_event", "") == "sack" and v in ge.pending_events())
	check("용병 이벤트: 말하는 인물은 타크(고블린)", v.profile.person == "타크" and v.story.special == "merc")
	var sacks0: int = cards.count_of("junk_sack")
	check("선택지 효과 → 잡동사니 자루 카드", ge.apply_effect(v.uid, v.story.choices[0].effect) and cards.count_of("junk_sack") == sacks0 + 1)
	check("마친 이벤트는 다시 나오지 않음", me.done.has("sack") and not me.trigger([], "sack"))
	ge.complete(v.uid, "다 줘 봐.", [])
	check("용병 이벤트는 그 인물의 손님 이야기를 소모하지 않음", not ge.completed_stories.has("tak"))
	# 모든 고블린 이벤트 대사·효과 형식
	var bad: Array = []
	for k in me.EVENTS:
		var st: Dictionary = me.EVENTS[k]
		if st.choices.size() != 2 or st.opening.split("\n").size() > 3 or st.closing.split("\n").size() > 3:
			bad.append(k)
		for c in st.choices:
			if c.reply.split("\n").size() > 3:
				bad.append(k + ":reply")
	check("고블린 이벤트 %d건: 선택지 2개 · 대사 3줄 이하" % me.EVENTS.size(), bad.is_empty(), str(bad))
	# 빚 문서: 고블린 고용 손님 4명이 모두 명부에 있으면 데려올 고블린이 없다(실패 대사) → 피클 계약 카드를 치워 한 자리 비운다
	me.trigger([], "debt")
	check("빚 문서: 데려올 고블린이 없으면 실패(대사만)", not ge.apply_effect(ge.visits.back().uid, "merc:debt") and g.debts.is_empty())
	for e in cards.entries.duplicate():
		if cards.is_job(e["id"]) and e["person"] == "피클":
			cards.remove_uid(e["uid"])
	var dv: Dictionary = ge.visits.back()
	var jobs0: int = 0
	for e in cards.entries:
		if cards.is_job(e["id"]):
			jobs0 += 1
	check("빚 문서 서명: 고블린 계약 카드 무료 + 빚 기록", ge.apply_effect(dv.uid, "merc:debt") and g.debts.size() == 1)
	var debtor: String = g.debts[0]["person"]
	check("빚 문서 계약 카드는 고블린", GuestProfiles.race_of(debtor) == "goblin" and cards.entries.any(func(e): return cards.is_job(e["id"]) and e["person"] == debtor))
	main.economy.gold = 0
	g.on_dawn(int(g.debts[0]["due_day"]))
	check("3일 뒤 새벽에 못 갚으면 그 용병이 떠남", g.debts.is_empty() and not cards.entries.any(func(e): return cards.is_job(e["id"]) and e["person"] == debtor))
	main.economy.gold = 200
	# 사촌의 사촌
	me.trigger([], "cousin")
	var cv: Dictionary = ge.visits.back()
	ge.apply_effect(cv.uid, "merc:cousin")
	check("사촌의 사촌: 내일로 예약", me.cousin_day == main.session.day() + 1)
	me.on_dawn(me.cousin_day)
	var prof: Dictionary = main.economy._roll_guest(true, 1, [])
	check("다음 날 첫 고용 손님이 고블린", prof.get("race", "") == "goblin" and prof.get("hireable", false), str(prof.get("person", "")))
	# 말라의 특별 이야기
	var mala: Dictionary = GuestProfiles.guest_profile("mala")
	mala["visit_uid"] = ge._next_uid
	ge.visits.append({"uid": ge._next_uid, "profile": mala, "day": 1, "present": true, "admitted": true, "ready": false, "read": false,
		"ready_at": 99999.0, "status": "투숙 중", "story": {}})
	ge._next_uid += 1
	await frames(3)
	var mv: Dictionary = ge.visits.back()
	check("말라 입실(고블린 용병 있음) → '값을 매기는 눈' 바로 말 걸기", mv.ready and mv.story.get("title", "") == "값을 매기는 눈")
	var scales0: int = cards.count_of("mala_monocle")
	check("말라: [물건을 본다] → 외알 안경", ge.apply_effect(mv.uid, mv.story.choices[1].effect) and cards.count_of("mala_monocle") == scales0 + 1 and me.mala_given)
	# 밤이 오면 듣지 않은 용병 이야기는 접힌다
	me.trigger([], "lure")
	main.session.state_changed.emit(SessionScript.State.COMBAT)
	await frames(1)
	check("밤이 오면 듣지 않은 용병 이야기는 접힘", not ge.visits.back().present)
