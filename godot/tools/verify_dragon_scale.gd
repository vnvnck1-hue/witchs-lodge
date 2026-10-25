extends SceneTree
## 용비늘 헤드리스 검증(docs/dragon-scale.md, 사용자 확정 2026-10-24).
##   .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_dragon_scale.gd
## 용 공물 버튼 삭제, 적 처치 0.1%·보스 확정 드랍(실제 처치 경로), 밤 전투 중 산장에 놓아야 소환·웨이브당 1번·카드 소비를 실제 장면에서 돌린다.

const Cfg := preload("res://scripts/config.gd")
const SessionScript := preload("res://scripts/game/game_session.gd")
const MerchantData := preload("res://scripts/game/merchant_data.gd")

var game
var passed := 0
var total := 0


func check(ok: bool, label: String) -> void:
	total += 1
	if ok:
		passed += 1
	print(("PASS " if ok else "FAIL ") + label)


func _initialize() -> void:
	create_timer(90.0, true, false, true).timeout.connect(func(): push_error("Dragon scale verification timeout"); quit(2))
	call_deferred("run")


func frames(n := 3) -> void:
	for i in n:
		await process_frame


func until(cond: Callable, timeout := 10.0) -> bool:
	var start := Time.get_ticks_msec()
	while not cond.call():
		await physics_frame
		if Time.get_ticks_msec() - start > timeout * 1000.0:
			return false
	return true


func sp(p: Vector3) -> Vector2:
	return game.world.camera.unproject_position(p)


func lodge_sp() -> Vector2:
	return sp(game.world.lodge.global_position + Vector3(0, 2, 0))


func uid_of(id: String) -> int:
	for e in game.cards.entries:
		if e["id"] == id:
			return e["uid"]
	return -1


func count_scales() -> int:
	var n := 0
	for e in game.cards.entries:
		if e["id"] == Cfg.DRAGON_SCALE:
			n += int(e.get("count", 1))
	return n


func run() -> void:
	root.size = Vector2i(1600, 872)
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await frames(6)
	game.world.player_camera.toggle_overview()
	game.economy.set_process(false)
	var cards = game.cards
	var dragon = game.dragon
	var res = game.resolver

	# ── 1. 카드 데이터
	var d: Dictionary = cards.def(Cfg.DRAGON_SCALE)
	check(d.get("name", "") == "용비늘" and d.get("printed_rules", []).size() == 2, "catalog: 용비늘 with 2 printed rule lines")
	check(ResourceLoader.exists(d.get("texture", "")) and ResourceLoader.exists(d.get("hand_texture", "")), "catalog: card + hand textures exist")
	var en = JSON.parse_string(FileAccess.get_file_as_string("res://assets/cards/catalog_en.json"))
	check(en["cards"].has(Cfg.DRAGON_SCALE) and en["cards"][Cfg.DRAGON_SCALE]["name"] == "Dragon Scale", "catalog_en: Dragon Scale")
	var layout = JSON.parse_string(FileAccess.get_file_as_string("res://assets/cards/text_layout.json"))
	check(layout.has(Cfg.DRAGON_SCALE), "text_layout: plate profile present")
	check(cards.phase_of(Cfg.DRAGON_SCALE) == "night", "config: night card")
	check(Cfg.DRAGON_SCALE_DROP == 0.001, "config: drop chance 0.1%")
	check(Cfg.DRAGON_SCALE in MerchantData.EXCLUDED_IDS and not Cfg.DRAGON_SCALE in MerchantData.pool(cards.defs), "merchant: never sold")
	var starter := false
	for pair in Cfg.STARTER_CARDS:
		starter = starter or pair[0] == Cfg.DRAGON_SCALE
	check(not starter, "not a starter card")

	# ── 2. 용 공물 버튼 삭제
	var m = game.hud.moon
	check(m.get("dragon_btn") == null and m.find_child("dragon_*", true, false) == null, "moon HUD: no dragon summon button")
	check(game.economy.cost_of("dragon") == 0, "economy: no dragon tribute price")
	var debug_ok := false
	for b in game.hud.debug_panel.find_children("*", "Button", true, false):
		if b.text == "용 강제 소환":
			debug_ok = false
			break
		if b.text == "용비늘 얻기":
			debug_ok = true
	check(debug_ok, "debug menu: '용비늘 얻기' replaces force summon")

	# ── 3. 낮에는 못 쓴다(밤 카드라 주머니로 들어감)
	game.debug_dragon_scale()
	check(count_scales() == 1, "debug grant adds one 용비늘")
	var u0: int = uid_of(Cfg.DRAGON_SCALE)
	var day_plan: Dictionary = res.evaluate(u0, lodge_sp())
	check(not day_plan["ok"], "day: cannot use (%s)" % day_plan.get("reason", ""))
	cards.consume(u0)
	check(count_scales() == 0, "cleanup")

	# ── 4. 밤 전투 시작 → 실제 처치 경로로 드랍
	game.session.start_wave()
	await until(func(): return game.waves.alive() >= 2, 20.0)
	check(game.session.state == SessionScript.State.COMBAT and game.waves.alive() >= 2, "combat with enemies (%d alive)" % game.waves.alive())
	var enemies: Array = []
	for e in game.get_tree().get_nodes_in_group("wave_enemies"):
		if not e.dead:
			enemies.append(e)
	var normal = enemies[0]
	check(is_equal_approx(dragon.scale_drop_chance(normal), 0.001), "normal enemy: chance 0.1%% (%.4f)" % dragon.scale_drop_chance(normal))
	check(dragon.on_enemy_killed(normal, 0.5) == false and count_scales() == 0, "roll 0.5 → no drop")
	check(dragon.on_enemy_killed(normal, 0.0009) == true and count_scales() == 1, "roll 0.0009 → drop")
	cards.consume(uid_of(Cfg.DRAGON_SCALE))
	# 1만 번 굴려 확률이 0.1% 근처인지(카드 추가 없이 판정만): 기대 10, 허용 1~30
	var hits := 0
	for i in 10000:
		if randf() < dragon.scale_drop_chance(normal):
			hits += 1
	check(hits >= 1 and hits <= 30, "10000 rolls → %d drops (≈10)" % hits)
	# 보스는 확정: 실제 처치(take_damage → die → kill_gold → dragon)로 확인
	var boss = enemies[1]
	boss.is_boss = true
	check(dragon.scale_drop_chance(boss) == 1.0, "boss: chance 100%")
	var before: int = dragon.scales_dropped
	boss.take_damage(99999.0)
	await frames(3)
	check(dragon.scales_dropped == before + 1 and count_scales() == 1, "boss kill via real death path drops 용비늘")
	var u1: int = uid_of(Cfg.DRAGON_SCALE)
	check(cards.get_entry(u1).get("zone", "") == "hand", "night drop goes to hand")

	# ── 5. 사용: 산장에 놓아야 한다
	var ground: Dictionary = res.evaluate(u1, sp(Vector3(-3.0, 0, 7.0)))
	check(not ground["ok"] and ground["reason"] == "산장에 놓아야 합니다", "ground: rejected (%s)" % ground.get("reason", ""))
	var plan: Dictionary = res.evaluate(u1, lodge_sp())
	check(plan["ok"] and plan["action"] == "dragon", "lodge: ok → dragon (%s)" % plan.get("reason", ""))
	var gold0: int = game.economy.gold
	var done: Dictionary = res.commit(u1, lodge_sp())
	check(done["ok"] and dragon.is_present() and dragon.used_this_wave, "commit: dragon summoned")
	check(count_scales() == 0 and game.economy.gold == gold0, "card consumed, no gold spent")
	# 같은 웨이브에 두 번째 비늘은 거부(소비하지 않음)
	game.debug_dragon_scale()
	var u2: int = uid_of(Cfg.DRAGON_SCALE)
	var again: Dictionary = res.commit(u2, lodge_sp())
	check(not again["ok"] and count_scales() == 1, "second scale same wave rejected, kept (%s)" % again.get("reason", ""))
	check(game.hud.card_hand._usage_text(cards.get_entry(u2)) == dragon.block_reason(), "hand hint shows block reason")
	# 용이 실제로 불덩이를 쏜다
	var fired: bool = await until(func(): return dragon._fire_cd > 0.5, 6.0)
	check(fired, "dragon attacks")

	# ── 6. 다음 웨이브엔 다시 쓸 수 있다
	dragon.on_wave_start()
	dragon.dismiss()
	await until(func(): return not dragon.is_present(), 6.0)
	check(dragon.block_reason() == "" or game.waves.alive() + game.waves.pending() == 0, "next wave: usable again (%s)" % dragon.block_reason())

	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)
