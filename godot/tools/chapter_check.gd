extends Node
## 볼륨 확장 E0~E3 자동 검증(기획: docs/game-volume-expansion-plan.md).
## 12일 챕터 데이터·세션 흐름, 적 종류·보스, 밤 규칙, 축복, 제단·의식, 신규 카드, 침식, 새벽 보상·장날을
## 실제 게임 장면에서 재현한다. 실행: godot --headless --path . --script res://tools/verify_chapter.gd

const Cfg := preload("res://scripts/config.gd")
const ChapterData := preload("res://scripts/game/chapter_data.gd")
const Catalog := preload("res://scripts/ui/card_catalog.gd")
const SessionScript := preload("res://scripts/game/game_session.gd")
const MonsterScript := preload("res://scripts/actors/monster.gd")
const BoltScript := preload("res://scripts/actors/magic_bolt.gd")

const NEW_CARDS := ["moss_bandage", "resin_torch", "firefly_swarm", "vine_snare", "winter_firewood",
	"shroud_cloth", "thorn_bind", "red_chalice", "hibernation_pelt", "corrupt_prayer", "poison_spore", "cursed_whisper"]

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
	main.session.set_process(false)   # 준비 시간이 흐르지 않게 고정하고 낮·밤 전환은 직접 호출한다
	main.economy.set_process(false)
	if main.wildlife != null:
		main.wildlife.set_process(false)
	Engine.time_scale = 4.0
	await _run()
	Engine.time_scale = 1.0
	var out := {"passed": failures == 0, "checks": results.size(), "failures": failures, "results": results}
	var f := FileAccess.open("res://art_sources/chapter-verify.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(out, "\t") + "\n")
	print("CHAPTER_VERIFY passed=", failures == 0, " checks=", results.size(), " failures=", failures)
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


func wait_until(cond: Callable, timeout := 20.0) -> bool:
	var t := 0.0
	while not cond.call():
		await get_tree().physics_frame
		t += get_physics_process_delta_time() * Engine.time_scale
		if t > timeout:
			return false
	return true


func sp(p: Vector3) -> Vector2:
	return main.world.camera.unproject_position(p)


func uid_of(id: String) -> int:
	for e in main.cards.entries:
		if e["id"] == id and e["zone"] == "hand":
			return e["uid"]
	return -1


func clear_cards() -> void:
	main.cards.entries.clear()
	main.cards.in_play.clear()
	main.cards.discard.clear()
	main.cards.changed.emit()


func kill_enemies() -> void:
	for e in get_tree().get_nodes_in_group("enemies"):
		for i in 40:
			if e.dead:
				break
			e.take_damage(99999.0)
	await frames(3)


func spawn(kind: String, pos: Vector3, hp := 60.0):
	var m := MonsterScript.new()
	m.setup(main, hp, false)
	m.configure(kind)
	m.position = pos
	main.actors.add_child(m)
	return m


func set_state(s: int) -> void:
	main.session.state = s


func _run() -> void:
	var ch = main.chapter
	var cards = main.cards
	var res = main.resolver
	var sess = main.session
	var lodge = main.world.lodge
	var player = main.player
	var pasture = main.world.pasture
	var lodge_sp := sp(lodge.global_position + Vector3(0, 2.0, 0))

	# ── 0. 카탈로그
	var cat_ok := true
	for id in NEW_CARDS:
		var d: Dictionary = Catalog.find(id)
		cat_ok = cat_ok and not d.is_empty() and d.get("printed_rules", []).size() == 2 and cards.defs.has(id) and Catalog.texture(id, true) != Catalog.back(true)
	check("카탈로그: 신규 12종 정의·문구 2줄·임시 원화 로딩", cat_ok)

	# ── 1. 챕터 데이터(E0)
	check("챕터: 12일", ChapterData.total_days() == 12 and sess.total_days() == 12)
	var same := true
	for i in 3:
		var d: Dictionary = ChapterData.day_cfg(i + 1)
		same = same and d["hp"] == Cfg.WAVES[i]["hp"] and d["sheep"] == Cfg.WAVES[i]["sheep"] and d["groups"] == Cfg.WAVES[i]["groups"] \
			and ChapterData.night_count(i + 1) == Cfg.WAVES[i]["count"] and int(d["marked"]) == Cfg.CARD_MONSTER_INDEX[i]
	check("1~3일은 기존 3웨이브와 같음", same)
	var kinds_ok := true
	var rules_ok := true
	var marked_ok := true
	for n in range(1, 13):
		var d: Dictionary = ChapterData.day_cfg(n)
		rules_ok = rules_ok and ChapterData.NIGHT_RULES.has(d["night"])
		var order: Array = []
		for g in d["groups"]:
			kinds_ok = kinds_ok and Cfg.ENEMY_KINDS.has(ChapterData.group_kind(g))
			for k in int(g[1]):
				order.append(ChapterData.group_kind(g))
		var m: int = int(d.get("marked", -1))
		marked_ok = marked_ok and (m == -1 or (m < order.size() and order[m] in ["spider", "forest"]))   # 기본 적 자리 → 큰 숲의 괴물로 바뀌어 나온다
	check("모든 밤 규칙·적 종류가 정의됨", kinds_ok and rules_ok)
	check("표식 개체는 기본 적(서리 거미·숲의 괴물) 순번에 걸림(카드 획득 보장)", marked_ok)
	var boss_day := false
	for g in ChapterData.day_cfg(12)["groups"]:
		boss_day = boss_day or ChapterData.group_kind(g) == "boss"
	check("12일 보스·4일 제단 해금·장날 6/11일·새벽 보상 4/6/8/10일",
		boss_day and ChapterData.day_cfg(4).get("unlock", "") == "altar"
		and ChapterData.day_cfg(6).get("market", false) and ChapterData.day_cfg(11).get("market", false)
		and [4, 6, 8, 10].all(func(x): return ChapterData.day_cfg(x).get("reward", false)))

	# ── 2. 세션 흐름: 3번째 밤 뒤 승리가 아니라 4일차, 12번째 밤 뒤 승리
	sess.wave_index = 3
	set_state(SessionScript.State.CLEARING)
	sess._after_clear()
	check("4일차: 제단 해금 + 새벽 보상 예약", ch.altar_unlocked and ch.screen_queue.size() >= 1 and ch.screen_queue[0]["type"] == "reward")
	await frames(2)
	check("3번째 밤 뒤에는 4일차 낮으로(승리 아님)", sess.state == SessionScript.State.PREP and sess.day() == 4, "state=%d day=%d" % [sess.state, sess.day()])
	check("낮이 되면 새벽 보상 창이 저절로 열림", main.offer_ui.active and main.offer_ui.mode == "reward")
	main.offer_ui.close()
	ch.screen_queue.clear()
	await frames(2)
	sess.wave_index = 12
	set_state(SessionScript.State.CLEARING)
	sess._after_clear()
	check("12번째 밤 뒤 챕터 완료(승리)", sess.state == SessionScript.State.VICTORY)
	get_tree().paused = false
	sess.wave_index = 3
	set_state(SessionScript.State.PREP)
	await frames(2)

	# ── 3. 적 종류(E1)
	player.global_position = Vector3(-24, 0, 5)
	player.set_destination(player.global_position)
	var probe = spawn("cultist", Vector3(20, 0, 20))
	var brute = spawn("brute", Vector3(22, 0, 20))
	var boss = spawn("boss", Vector3(24, 0, 22))
	await frames(2)
	check("침식된 자: 원거리 4.5m·체력 0.8배", probe.reach == 4.5 and is_equal_approx(probe.max_hp, 48.0))
	check("공성 괴물: 체력 3배·산장 피해 3배·아군 무시", is_equal_approx(brute.max_hp, 180.0) and brute.lodge_mult == 3.0 and brute.ignore_units and brute.big)
	check("보스: 체력 1400·보스 그룹·전리품 카드", boss.max_hp == 1400.0 and boss.is_in_group("bosses") and boss.card_drop == Cfg.BOSS_TROPHY)
	boss.take_damage(200.0)
	check("보스: 한 번에 받는 피해 상한 %d" % int(Cfg.BOSS_HIT_CAP), is_equal_approx(boss.hp, 1400.0 - Cfg.BOSS_HIT_CAP), "hp=%.0f" % boss.hp)
	ch.corruption_tonight = 0
	var before_enemies := get_tree().get_nodes_in_group("enemies").size()
	boss._roar_t = 0.01
	await frames(3)
	check("보스의 부름: 숲의 괴물 %d마리 + 저주의 속삭임(주머니)" % Cfg.BOSS_ROAR_SPAWN,
		get_tree().get_nodes_in_group("enemies").size() == before_enemies + Cfg.BOSS_ROAR_SPAWN and cards.pocket_count_of("cursed_whisper") == 1)
	await kill_enemies()
	check("보스 처치: 겨울잠 털가죽 카드 획득", cards.count_of(Cfg.BOSS_TROPHY) == 1)
	clear_cards()

	# 공성 괴물은 곁의 마녀를 무시한다
	set_state(SessionScript.State.COMBAT)
	var hp0: float = player.hp
	var b2 = spawn("brute", player.global_position + Vector3(0.6, 0, 0))
	await wait_until(func(): return false, 4.0)
	check("공성 괴물: 바로 옆의 마녀를 공격하지 않음", player.hp == hp0 and not b2.dead, "hp %.0f→%.0f" % [hp0, player.hp])
	await kill_enemies()
	# 공성 괴물이 산장 벽을 치면 피해 = 6 × 3
	var wall: Vector3 = lodge.closest_point(Vector3(0, 0, 9))
	var b3 = spawn("brute", wall + Vector3(0, 0, 1.2))
	var lhp: float = lodge.hp
	await wait_until(func(): return lodge.hp < lhp, 10.0)
	check("공성 괴물: 산장 피해 %d" % int(6.0 * 3.0), is_equal_approx(lhp - lodge.hp, 18.0), "Δ=%.1f" % (lhp - lodge.hp))
	await kill_enemies()
	lodge.repair(1000.0)

	# 침식된 자: 사거리에서 산장을 저주 → 주머니에 침식 카드, 한 밤 상한 2
	ch.corruption_tonight = 0
	var c_pos: Vector3 = lodge.closest_point(Vector3(9, 0, 0)) + Vector3(3.6, 0, 0)
	for i in 3:
		spawn("cultist", c_pos + Vector3(0, 0, -1.5 + i * 1.5))
	lhp = lodge.hp
	await wait_until(func(): return cards.pocket_count_of("corrupt_prayer") >= 2, 12.0)
	await wait_until(func(): return false, 3.0)
	check("침식된 자: 원거리에서 산장 피해", lodge.hp < lhp, "Δ=%.1f" % (lhp - lodge.hp))
	check("침식된 자: 주머니에 침식된 기도문(한 밤 상한 %d)" % Cfg.CORRUPTION_PER_NIGHT, cards.pocket_count_of("corrupt_prayer") == Cfg.CORRUPTION_PER_NIGHT, "n=%d" % cards.pocket_count_of("corrupt_prayer"))
	await kill_enemies()
	lodge.repair(1000.0)
	clear_cards()

	# 웨이브 감독: 5일차 밤의 종류 구성
	set_state(SessionScript.State.COMBAT)
	main.waves.start_wave(5)
	main.waves.time = 100.0
	main.waves._spawn_due()
	await frames(2)
	var n_cult := 0
	var n_forest := 0
	for e in get_tree().get_nodes_in_group("wave_enemies"):
		if e.kind == "cultist":
			n_cult += 1
		elif e.kind == "spider" or e.kind == "forest":
			n_forest += 1   # 기본 적 서리 거미 5 + 표식 개체(큰 숲의 괴물) 1
	check("5일차 밤: 기본 적 6(서리 거미+표식 큰 숲의 괴물) + 침식된 자 4", n_cult == 4 and n_forest == 6 and main.waves.total == 10, "base=%d cult=%d" % [n_forest, n_cult])
	await kill_enemies()
	main.waves.stop()
	clear_cards()   # 표식 개체가 떨어뜨린 숲의 괴물 카드를 치운다

	# ── 4. 밤 규칙: 안개의 밤
	ch.on_wave_start(6)
	check("안개의 밤: 시야 배율 %.1f" % Cfg.FOG_NIGHT_SIGHT, main.world.fog_of_war.sight_mult == Cfg.FOG_NIGHT_SIGHT)
	ch.on_combat_end()
	check("밤 정리 후 시야 복구", main.world.fog_of_war.sight_mult == 1.0)

	# ── 5. 축복
	ch.bless("shroud")
	player.heal(1000.0)
	player.take_damage(9999.0)
	check("수의: 마녀가 치명타를 한 번 버팀(체력 1)", not player.dead and player.hp == 1.0 and sess.state != SessionScript.State.DEFEAT)
	player.heal(1000.0)
	ch.bless("pelt")
	lhp = lodge.hp
	lodge.take_damage(20.0)
	check("겨울잠 털가죽: 산장 피해 절반", is_equal_approx(lhp - lodge.hp, 10.0))
	lodge.repair(1000.0)
	ch.bless("thorn")
	check("가시의 봉헌 축복: 방책 공격력 ×1.5", ch.thorn_mult() == Cfg.BLESS_THORN_MULT)
	ch.bless("red_feast")
	player.hp = 50.0
	var target = spawn("forest", player.global_position + Vector3(0.3, 0, 0), 500.0)
	await frames(1)
	var bolt := BoltScript.new()
	bolt.target = target
	bolt.caster = player
	bolt.lifesteal = ch.lifesteal()
	main.actors.add_child(bolt)
	bolt.global_position = target.global_position + Vector3(0, 0.65, 0)
	# 마법탄은 _process 로 움직인다. physics_frame 만 기다리면 느린 프레임에선 한 번도 처리되지 않을 수 있다
	for i in 10:
		if not is_instance_valid(bolt):
			break
		await get_tree().process_frame
	check("붉은 만찬 축복: 마법탄 피해의 30% 회복", is_equal_approx(player.hp, 50.0 + Cfg.BOLT_DAMAGE * Cfg.BLESS_LIFESTEAL), "hp=%.1f dead=%s target_hp=%.0f" % [player.hp, player.dead, target.hp if is_instance_valid(target) else -1.0])
	await kill_enemies()
	ch.on_combat_end()
	check("밤 정리 후 축복 소멸", ch.blessings.is_empty() and ch.thorn_mult() == 1.0 and ch.lodge_damage_mult() == 1.0)
	player.heal(1000.0)

	# ── 6. 제단(E2)
	set_state(SessionScript.State.PREP)
	ch.altar_unlocked = false
	ch.altar_restored = false
	ch.rituals_done.clear()
	check("해금 전: 복구 불가(4일차 안내)", ch.restore_block_reason().find("4일차") >= 0)
	ch.on_prep_start(4)
	ch.screen_queue.clear()
	check("4일차 낮: 제단 해금·문양 표시", ch.altar_unlocked and main.altar._glyph.visible and not main.altar._table.visible)
	cards.add("timber", 5)
	check("복구: 손패 목재 부족이면 거부", ch.restore_block_reason().find("목재") >= 0 and not ch.restore_altar())
	cards.add("timber", 5)
	check("복구: 목재 10 소비·나무 제단 등장", ch.restore_altar() and cards.count_of("timber") == 0 and main.altar._table.visible)
	cards.add("wool", 3)
	var r: String = main.altar_ui.perform("shroud")
	check("수의의 의식 첫 완성: 양털 3 소비 → 권능 '수의' 카드", r == "power" and cards.count_of("wool") == 0 and cards.count_of("shroud_cloth") == 1)
	cards.add("wool", 3)
	check("하루 한 번: 같은 날 두 번째 의식 거부", main.altar_ui.perform("shroud") == "" and ch.ritual_block_reason("shroud").find("오늘") >= 0)
	ch.on_prep_start(5)
	r = main.altar_ui.perform("shroud")
	check("다음 날 다시 치르면 축복(카드 없음)", r == "blessing" and ch.blessed("shroud") and cards.count_of("shroud_cloth") == 1)
	ch.on_combat_end()
	ch.on_prep_start(6)
	ch.screen_queue.clear()
	cards.add("forest_monster")
	var why_thorn: String = ch.ritual_block_reason("thorn")
	r = main.altar_ui.perform("thorn")
	check("가시의 봉헌: 숲의 괴물 카드 소비 → 권능 '가시 속박'", r == "power" and cards.count_of("forest_monster") == 0 and cards.count_of("thorn_bind") == 1, "%s r=%s fm=%d tb=%d" % [why_thorn, r, cards.count_of("forest_monster"), cards.count_of("thorn_bind")])
	ch.on_prep_start(7)
	while pasture.adult_count() < 1:
		pasture.add_sheep()
	var adults: int = pasture.adult_count()
	var lost: int = main.sheep_lost
	r = main.altar_ui.perform("red_feast")
	await frames(2)
	check("붉은 만찬: 어른 양 1마리 공물(잃은 양으로 세지 않음) → 권능 '붉은 잔'", r == "power" and pasture.adult_count() == adults - 1 and main.sheep_lost == lost and cards.count_of("red_chalice") == 1)
	main.altar_ui.open()
	check("제단 창: 열면 게임 정지", main.altar_ui.active and get_tree().paused)
	main.altar_ui.close()
	check("제단 창: 닫으면 재개", not main.altar_ui.active and not get_tree().paused)
	clear_cards()

	# ── 7. 신규 카드(E3) — 판정·사용
	var ground := Vector3(-3.5, 0, 6.5)
	cards.add("resin_torch")
	check("송진 횃불: 낮에는 거부", not res.evaluate(uid_of("resin_torch"), sp(ground))["ok"])
	set_state(SessionScript.State.COMBAT)
	var e1 = spawn("forest", ground, 100.0)
	await frames(2)
	var plan: Dictionary = res.commit(uid_of("resin_torch"), sp(ground))
	await wait_until(func(): return false, 3.2)
	check("송진 횃불: 불길이 적을 태움", plan["ok"] and e1.hp < 100.0 and cards.count_of("resin_torch") == 0, "hp=%.0f %s" % [e1.hp, plan.get("reason", "")])
	cards.add("vine_snare")
	plan = res.commit(uid_of("vine_snare"), sp(e1.global_position))
	check("덩굴 덫: 피해 + 강한 감속", plan["ok"] and e1.slow_factor() <= Cfg.VINE_SLOW + 0.001, plan.get("reason", ""))
	cards.add("thorn_bind")
	var hp1: float = e1.hp
	plan = res.commit(uid_of("thorn_bind"), sp(e1.global_position))
	check("가시 속박: 피해 %d + 속박" % int(Cfg.THORN_BIND_DAMAGE), plan["ok"] and is_equal_approx(hp1 - e1.hp, Cfg.THORN_BIND_DAMAGE) and e1.slow_factor() <= Cfg.THORN_BIND_SLOW + 0.001)
	await kill_enemies()
	cards.add("firefly_swarm")
	plan = res.commit(uid_of("firefly_swarm"), sp(ground))
	await frames(2)
	check("반딧불이 떼: 시야 발생원(반경 %d)" % int(Cfg.FIREFLY_SIGHT), plan["ok"] and get_tree().get_nodes_in_group("firefly_swarms").size() == 1 and cards.in_play.size() == 1, plan.get("reason", ""))
	lodge.take_damage(100.0)
	lhp = lodge.hp
	cards.add("winter_firewood")
	plan = res.commit(uid_of("winter_firewood"), lodge_sp)
	check("겨울 장작: 밤에도 산장 +%d" % int(Cfg.FIREWOOD_REPAIR), plan["ok"] and is_equal_approx(lodge.hp - lhp, Cfg.FIREWOOD_REPAIR), plan.get("reason", ""))
	lodge.repair(1000.0)
	cards.add("shroud_cloth")
	plan = res.commit(uid_of("shroud_cloth"), sp(ground))
	check("수의 카드: 오늘 밤 수의 축복", plan["ok"] and ch.blessed("shroud"))
	cards.add("shroud_cloth")
	check("같은 축복이 있으면 거부", not res.evaluate(uid_of("shroud_cloth"), sp(ground))["ok"])
	cards.add("red_chalice")
	plan = res.commit(uid_of("red_chalice"), sp(player.global_position + Vector3(0, 1.0, 0)))
	check("붉은 잔: 마녀에게 → 흡혈 축복", plan["ok"] and ch.lifesteal() == Cfg.BLESS_LIFESTEAL, plan.get("reason", ""))
	cards.add("hibernation_pelt")
	plan = res.commit(uid_of("hibernation_pelt"), lodge_sp)
	check("겨울잠 털가죽: 산장에 → 피해 절반 축복", plan["ok"] and ch.lodge_damage_mult() == Cfg.PELT_LODGE_MULT, plan.get("reason", ""))
	main.session.state_changed.emit(SessionScript.State.CLEARING)
	ch.on_combat_end()
	await frames(2)
	check("밤 정리: 반딧불이 흩어지고 카드는 버림패", get_tree().get_nodes_in_group("firefly_swarms").is_empty() and cards.in_play.is_empty())
	set_state(SessionScript.State.PREP)
	clear_cards()

	# ── 8. 침식 카드
	cards.add("corrupt_prayer", 1, "", "hand")
	check("침식 카드: 사용 거부", not res.evaluate(uid_of("corrupt_prayer"), sp(ground))["ok"] and res.evaluate(uid_of("corrupt_prayer"), sp(ground))["reason"].find("침식") >= 0)
	cards.add("poison_spore", 1, "", "hand")
	player.heal(1000.0)
	hp0 = player.hp
	ch.on_prep_start(8)
	ch.screen_queue.clear()
	check("독 포자(손패): 새벽에 마녀 체력 -%d" % int(Cfg.SPORE_DAWN_HP), is_equal_approx(hp0 - player.hp, Cfg.SPORE_DAWN_HP))
	cards.add("cursed_whisper", 1, "", "hand")
	cards.add("frost_rune", 1, "", "pocket")
	var hand_n: int = cards.hand().size()
	sess.wave_index = 8
	sess._enter_prep()
	ch.screen_queue.clear()
	await frames(2)
	check("저주의 속삭임(손패): 아침 드로우 막힘", cards.hand().size() == hand_n and cards.pocket_count_of("frost_rune") == 1)
	cards.add("moss_bandage")
	player.hp = 60.0
	var before_bad: int = ch.corruption_count()
	plan = res.commit(uid_of("moss_bandage"), sp(player.global_position + Vector3(0, 1.0, 0)))
	check("이끼 붕대: 체력 +%d·침식 1장 정화" % int(Cfg.MOSS_HEAL), plan["ok"] and player.hp == 60.0 + Cfg.MOSS_HEAL and ch.corruption_count() == before_bad - 1, plan.get("reason", ""))
	clear_cards()

	# ── 9. 새벽 보상·장날 화면
	ch.screen_queue.append({"type": "reward"})
	ch._process(0.0)
	await frames(2)
	var ui = main.offer_ui
	check("새벽 보상: 대기열에서 열림·게임 정지·3장", ui.active and ui.mode == "reward" and get_tree().paused and ui.ids.size() == ChapterData.REWARD_CHOICES)
	var pick_id: String = ui.ids[0]
	ui.pick(0)
	await frames(2)
	check("새벽 보상: 고른 카드가 손패로·창 닫힘·재개", cards.count_of(pick_id) == 1 and not ui.active and not get_tree().paused)
	main.economy.gold = 100
	ui.open_market([{"id": "frost_rune", "price": 25, "sold": false}, {"id": "treasure_chest", "price": 45, "sold": false}, {"id": "old_spellbook", "price": 35, "sold": false}])
	check("장날: 창 열림·게임 정지", ui.active and ui.mode == "market" and get_tree().paused)
	check("장날: 구매 → 골드 차감·카드 획득", ui.buy(0) and main.economy.gold == 75 and cards.count_of("frost_rune") == 1)
	check("장날: 이미 산 카드는 다시 못 삼", not ui.buy(0) and main.economy.gold == 75)
	ui.buy(1)
	check("장날: 골드 부족이면 거부", not ui.buy(2) and main.economy.gold == 30 and cards.count_of("old_spellbook") == 0)
	cards.add("corrupt_prayer", 1, "", "pocket")
	var gone: String = ui.purify()
	check("장날: 침식 정화 %dG" % ChapterData.PURIFY_PRICE, gone != "" and main.economy.gold == 15 and ch.corruption_count() == 0)
	ui.close()
	await frames(2)
	check("장날: 닫으면 재개", not ui.active and not get_tree().paused)
	check("장날 후보: 4장·가격표 있음", ch.market_offers().size() == ChapterData.MARKET_OFFERS and ch.market_offers().all(func(o): return o["price"] > 0))
