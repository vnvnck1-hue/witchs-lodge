extends SceneTree
## 용병 고유 키트 v04 1차(인간 4명) 헤드리스 검증(docs/mercenary-unique-kit-v04.md, scripts/game/merc_kit.gd).
##   .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_merc_kit.gd
## 고용 → 고유 카드가 주머니로 · 밤 시작 손패 5장 + 패시브 생성 카드(넘치면 대기열) · 마력 3 → 초당 0.5 → 최대 10 ·
## 전투 중 스택 드로우 없음 · 기세(평타 +10, 피해 최대 +15, 비전투직 시간) → 고유 스킬 4종 · 고유 카드·생성 카드 효과 ·
## 생성 카드는 써도 버림패로 가지 않고 전투가 끝나면 사라짐 · 용병이 떠나면 고유 카드도 빠짐을 확인한다.

const Cfg := preload("res://scripts/config.gd")
const Layout := preload("res://scripts/world/layout.gd")
const MonsterScript := preload("res://scripts/actors/monster.gd")
const MercKit := preload("res://scripts/game/merc_kit.gd")
const Catalog := preload("res://scripts/ui/card_catalog.gd")

var game
var kit
var passed := 0
var total := 0


func check(ok: bool, label: String, detail := "") -> void:
	total += 1
	if ok:
		passed += 1
	print(("PASS " if ok else "FAIL ") + label + ("  — " + detail if detail != "" else ""))


func _initialize() -> void:
	create_timer(180.0, true, false, true).timeout.connect(func(): push_error("merc kit verification timeout"); quit(2))
	call_deferred("run")


func pframes(n := 3) -> void:
	for i in n:
		await physics_frame


func seconds(t: float) -> void:
	var start := Time.get_ticks_msec()
	while Time.get_ticks_msec() - start < t * 1000.0:
		await physics_frame


func enemy(pos: Vector3, hp := 400.0):
	var m := MonsterScript.new()
	m.setup(game, hp, false)
	m.configure("spider")
	m.position = pos
	game.actors.add_child(m)
	m.set_physics_process(false)
	m.set_process(false)
	return m


func count_id(list: Array, id: String) -> int:
	return list.filter(func(e): return e["id"] == id).size()


func generated_in_hand() -> int:
	return game.cards.hand().filter(func(e): return e.get("generated", false)).size()


func run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await pframes(12)
	game.session.set_process(false)
	game.economy.set_process(false)
	kit = game.merc_kit
	kit.set_process(false)   # 시간은 tick()/_process(dt)로 직접 흘린다
	check(kit != null and MercKit.enabled, "용병 키트 모듈이 붙고 켜져 있음")

	# ── 카드 정의 ──
	var en: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/cards/catalog_en.json"))["cards"]
	var missing: Array = MercKit.CARD_IDS.filter(func(id): return not game.cards.defs.has(id) or not en.has(id) or not ResourceLoader.exists(game.cards.def(id)["texture"]))
	check(missing.is_empty(), "새 카드 7장: 한국어·영문 문구와 원화 경로가 있음", str(missing))
	check(MercKit.CARD_IDS.all(func(id): return game.cards.phase_of(id) == "night"), "새 카드는 모두 밤 카드")
	check(game.cards.def("merc_war_horn")["printed_rules"].size() == 2, "인쇄 문구 두 줄")

	# ── 고용: 고유 카드가 주머니로 ──
	for p in ["브람", "올라프", "토르빈", "미라"]:
		kit.on_hired(p)
	var pocket: Array = game.cards.pocket()
	check(count_id(pocket, "merc_war_horn") == 2 and count_id(pocket, "merc_hunt_mark") == 1 and count_id(pocket, "merc_rolling_log") == 1 and count_id(pocket, "merc_big_cauldron") == 1,
		"고용하면 고유 카드가 주머니로 (진격 나팔 2 · 사냥 표식 · 굴러가는 통나무 · 큰 약솥)")

	var c := Layout.CAMPFIRE
	var bram = game.contracts.spawn_guard("merc", "브람", c + Vector3(2.0, 0, 0), null, "warrior")
	var olaf = game.contracts.spawn_guard("merc", "올라프", c + Vector3(-2.0, 0, 0), null, "hunter")
	var torbin = game.contracts.spawn_guard("merc", "토르빈", c + Vector3(0, 0, -2.0), null, "lumberjack")
	var mira = game.contracts.spawn_gatherer("미라", c + Vector3(0, 0, 2.2))
	for a in [bram, olaf, torbin, mira]:
		a.set_physics_process(false)
	await pframes(3)
	check(kit.kit_mercs().size() == 4, "키트 용병 4명 인식")

	# ── 밤 시작 ──
	game.cards.add("timber", 2)   # 낮 카드: 밤이 되면 주머니로 가야 한다
	game.session.start_wave()
	game.waves.stop()
	await pframes(3)
	var normal_hand: Array = game.cards.hand().filter(func(e): return not e.get("generated", false))
	check(normal_hand.size() <= MercKit.START_HAND, "밤 시작 손패(생성 카드 제외)는 5장 이하", "%d장" % normal_hand.size())
	check(generated_in_hand() + kit.queue_size() == 5, "패시브 생성 카드 5장(호령 1 · 통나무 벽 2 · 약초 물 2) — 손패 + 대기열", "손패 %d · 대기 %d" % [generated_in_hand(), kit.queue_size()])
	check(game.cards.hand().size() <= Cfg.HAND_VISIBLE, "손패 한도를 넘지 않음", "%d장" % game.cards.hand().size())
	check(is_equal_approx(kit.mana, MercKit.MANA_START), "마력 시작 3")
	kit._process(2.0)
	check(is_equal_approx(kit.mana, 4.0), "마력 초당 0.5 (2초 뒤 4)", str(kit.mana))
	kit._process(60.0)
	check(is_equal_approx(kit.mana, MercKit.MANA_MAX), "마력 최대 10", str(kit.mana))

	# ── 전투 중 드로우 없음 ──
	var stack_before: int = game.cards.draw_stack
	var drawn_before: int = game.cards.stats["stack_draws"]
	for i in 4:
		game.cards._count_use()
	check(game.cards.draw_stack == stack_before and game.cards.stats["stack_draws"] == drawn_before, "밤에는 카드를 써도 스택 드로우가 쌓이지 않음")

	# ── 기세 ──
	kit.momentum.clear()
	kit.on_ally_hit(bram, null)
	check(is_equal_approx(kit.momentum_of(bram), 10.0), "평타가 맞으면 기세 +10")
	kit.on_ally_hurt(bram, 40.0)
	check(is_equal_approx(kit.momentum_of(bram), 25.0), "피해를 받으면 받은 만큼, 1회 최대 +15")
	kit.momentum.clear()
	kit.tick(4.0)
	check(is_equal_approx(kit.momentum_of(torbin), 20.0) and is_equal_approx(kit.momentum_of(bram), 0.0), "비전투직만 시간으로 기세 (초당 5)", "토르빈 %.1f · 브람 %.1f" % [kit.momentum_of(torbin), kit.momentum_of(bram)])

	# ── 브람: 방패벽 ──
	kit.momentum.clear()
	kit.momentum[bram.get_instance_id()] = 100.0
	var casts: int = kit.stats["casts"]
	kit.tick(0.0)
	check(kit.stats["casts"] == casts + 1 and kit.momentum_of(bram) == 0.0, "기세 100 → 브람 방패벽 시전, 기세 0")
	check(kit.shielded(bram), "방패벽: 브람 주변 아군 보호")
	var hp0: float = bram.hp
	bram.take_damage(10.0)
	check(is_equal_approx(hp0 - bram.hp, 5.0), "방패벽 동안 받는 피해 절반", "%.1f" % (hp0 - bram.hp))
	kit._clock += MercKit.SHIELD_TIME + 0.1
	check(not kit.shielded(bram), "방패벽은 4초 뒤 끝남")

	# ── 올라프: 불화살 ──
	var foes: Array = []
	for i in 3:
		foes.append(enemy(olaf.global_position + Vector3(4.0 + i * 0.6, 0, 1.0)))
	var lone = enemy(olaf.global_position + Vector3(-14.0, 0, -6.0))
	await pframes(2)
	var hp_before: Array = foes.map(func(e): return e.hp)
	kit.momentum[olaf.get_instance_id()] = 100.0
	kit.tick(0.0)
	var dealt := 0.0
	for i in foes.size():
		dealt += hp_before[i] - foes[i].hp
	check(is_equal_approx(dealt, MercKit.FIRE_DAMAGE * MercKit.FIRE_ARROWS), "불화살: 몰린 적에게 12 × 3", "%.1f" % dealt)
	check(is_equal_approx(lone.hp, 400.0), "떨어진 적은 맞지 않음")

	# ── 토르빈: 말뚝 깎기 ──
	kit._queue.clear()
	var gen0: int = kit.stats["generated"] + kit.stats["queued"]
	kit.momentum[torbin.get_instance_id()] = 100.0
	kit.tick(0.0)
	check(kit.stats["generated"] + kit.stats["queued"] == gen0 + 1, "말뚝 깎기: [통나무 벽] 1장 생성")

	# ── 미라: 약초 달이기 ──
	olaf.hp = olaf.max_hp - 25.0
	kit.momentum[mira.get_instance_id()] = 100.0
	kit.tick(0.0)
	check(is_equal_approx(olaf.hp, olaf.max_hp), "약초 달이기: 가장 다친 용병 회복", "%.1f/%.1f" % [olaf.hp, olaf.max_hp])
	for a in [bram, olaf, torbin, mira]:
		a.hp = a.max_hp
	kit.momentum[mira.get_instance_id()] = 100.0
	kit.tick(0.0)
	check(kit.momentum_of(mira) == 100.0, "다친 사람이 없으면 기세 100인 채 기다림")

	# ── 사냥 표식(고유 카드)과 숲지기의 눈(패시브) ──
	var target = foes[0]
	kit.mark(target)
	check(bram.priority == target, "사냥 표식: 용병이 그 적을 먼저 노림")
	var t_hp: float = target.hp
	target.take_damage(10.0)
	check(is_equal_approx(t_hp - target.hp, 15.0), "사냥 표식: 받는 피해 1.5배")
	for e in game.cards.hand().filter(func(x): return x.get("generated", false)):
		game.cards.entries.erase(e)   # 손패 자리를 비워 돌아오는 카드를 손패에서 확인
	target.take_damage(9999.0)
	kit.tick(0.0)
	var back: Array = game.cards.hand().filter(func(e): return e["id"] == "merc_hunt_mark" and e.get("generated", false))
	check(back.size() == 1, "숲지기의 눈: 표식한 적이 쓰러지면 [사냥 표식]이 손으로 돌아옴")

	# ── 굴러가는 통나무 ──
	var dir := Vector3(1, 0, 0.3).normalized()
	var on_line = enemy(dir * 9.0)
	var off_line = enemy(dir * 9.0 + dir.cross(Vector3.UP) * 4.0)
	await pframes(2)
	var p0: Vector3 = on_line.global_position
	var rolled: Array = kit.rolling_log(dir * 12.0)
	check(on_line in rolled and not off_line in rolled, "굴러가는 통나무: 길 위의 적만 맞음")
	check(is_equal_approx(on_line.hp, 400.0 - MercKit.LOG_DAMAGE) and on_line.global_position.distance_to(p0) > 2.5, "통나무: 피해 15, 진행 방향으로 밀림")

	# ── 진격 나팔 ──
	var spot := c + Vector3(6.0, 0, 6.0)
	var near_spot = enemy(spot + Vector3(1.0, 0, 0))
	await pframes(2)
	kit.war_horn(spot)
	await seconds(MercKit.HORN_DASH + 0.3)
	check(flat(bram.global_position, spot) < 0.6, "진격 나팔: 브람이 지점으로 돌격", "%.2fm" % flat(bram.global_position, spot))
	check(flat(olaf.global_position, spot) < 2.0, "진격 나팔: 다른 전투 용병도 따라옴")
	check(is_equal_approx(near_spot.hp, 400.0 - MercKit.HORN_DAMAGE), "진격 나팔: 도착하면 주변 적 피해 15")

	# ── 카드 판정·사용(해석기 경로) ──
	var r = game.resolver
	var caul: Dictionary = game.cards.entries.filter(func(e): return e["id"] == "merc_big_cauldron")[0]
	if caul["zone"] == "pocket":
		if game.cards.hand_full():
			game.cards.entries.erase(game.cards.hand()[0])
		game.cards.draw_uid(caul["uid"])
	bram.hp = bram.max_hp - 30.0
	kit.mana = 1.0
	var plan: Dictionary = r.evaluate(caul["uid"], Vector2.ZERO)
	check(not plan["ok"] and "마력" in str(plan["reason"]), "마력이 모자라면 쓸 수 없음", str(plan.get("reason", "")))
	kit.mana = 5.0
	plan = r.evaluate(caul["uid"], Vector2.ZERO)
	check(plan["ok"] and plan["action"] == "merc", "큰 약솥: 판정 통과")
	var done: Dictionary = r.commit(caul["uid"], Vector2.ZERO)
	check(done.get("ok", false) and is_equal_approx(kit.mana, 3.0), "큰 약솥: 마력 2 소모")
	check(is_equal_approx(bram.hp, bram.max_hp - 10.0), "큰 약솥: 모든 용병 체력 20 회복")
	check(count_id(game.cards.discard, "merc_big_cauldron") == 1, "고유 카드는 쓰면 버림패로")

	var herb: int = kit.generate("gen_herb_water", "미라")
	check(herb > 0 and game.cards.get_entry(herb).get("generated", false), "생성 카드에 생성 표시")
	olaf.hp = olaf.max_hp - 40.0
	plan = {"ok": true, "action": "merc", "merc_card": "gen_herb_water", "ally": olaf}
	kit.commit(herb, plan, r)
	check(is_equal_approx(olaf.hp, olaf.max_hp - 10.0), "약초 물: 체력 30 회복")
	check(count_id(game.cards.discard, "gen_herb_water") == 0 and game.cards.get_entry(herb).is_empty(), "생성 카드는 쓰면 사라짐(버림패로 가지 않음)")

	var wall_uid: int = kit.generate("gen_log_wall", "토르빈")
	kit.commit(wall_uid, {"ok": true, "action": "merc", "merc_card": "gen_log_wall", "pos": c + Vector3(-5.0, 0, 5.0)}, r)
	await pframes(2)
	var walls: Array = get_nodes_in_group("allies").filter(func(n): return n.get("kind") == "log_wall")
	check(walls.size() == 1 and is_equal_approx(walls[0].max_hp, 60.0), "통나무 벽: 체력 60 벽이 세워짐")

	var rally: int = kit.generate("gen_rally", "브람")
	var casts1: int = kit.stats["casts"]
	kit.commit(rally, {"ok": true, "action": "merc", "merc_card": "gen_rally", "ally": bram}, r)
	check(kit.stats["casts"] == casts1 + 1 and kit.shielded(bram), "호령: 고른 용병이 바로 고유 스킬(방패벽)")

	# ── 대기열 ──
	while not game.cards.hand_full():
		game.cards.add("gen_herb_water", 1, "미라", "hand")
	kit._queue.clear()
	kit.generate("gen_rally", "브람")
	check(kit.queue_size() == 1, "손패가 가득하면 생성 카드는 대기열로")
	var h = game.cards.hand()[0]
	game.cards.entries.erase(h)
	kit.tick(0.0)
	check(kit.queue_size() == 0 and game.cards.hand().any(func(e): return e["id"] == "gen_rally"), "자리가 나면 대기열 카드가 손패로")

	# ── 전투 끝 ──
	kit.end_battle()
	check(game.cards.entries.all(func(e): return not e.get("generated", false)) and kit.queue_size() == 0, "전투가 끝나면 생성 카드·대기열이 사라짐")

	# ── 용병이 떠나면 ──
	kit.on_merc_gone("브람")
	var horn_left := count_id(game.cards.entries, "merc_war_horn") + count_id(game.cards.discard, "merc_war_horn")
	check(horn_left == 0, "브람이 떠나면 진격 나팔도 덱에서 빠짐")
	check(count_id(game.cards.discard, "merc_big_cauldron") == 1, "다른 용병의 고유 카드는 남음(미라의 큰 약솥)")

	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)


func flat(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x, a.z).distance_to(Vector2(b.x, b.z))
