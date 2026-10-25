extends Node
## 전설 카드 5장 + 광석 v1 자동 검증(docs/legend-cards-v01.md). 실제 게임 장면에서
## 카탈로그·영문·판 프로파일·시간대·얻는 길, 광석 판매·시설 보강·무기 벼리기, 왕관 하나 규칙·얼음창 관통·서리 룬·언데드 카드,
## 마법서 주문 세기·바닥선·폭주, 화로 설치·불덩이, 종(적·시설·손패), 새벽 보상 전설 섞기를 확인한다.
## 결과: res://art_sources/legend-cards-verify.json

const Cfg := preload("res://scripts/config.gd")
const Layout := preload("res://scripts/world/layout.gd")
const MonsterScript := preload("res://scripts/actors/monster.gd")
const SessionScript := preload("res://scripts/game/game_session.gd")
const IceLanceScript := preload("res://scripts/actors/ice_lance.gd")
const FireballScript := preload("res://scripts/actors/fireball.gd")
const RaceData := preload("res://scripts/game/race_card_data.gd")
const MerchantData := preload("res://scripts/game/merchant_data.gd")
const Catalog := preload("res://scripts/ui/card_catalog.gd")

const NEW_CARDS := ["ore", "frost_crown", "lich_crown", "wild_grimoire", "fire_brazier", "winter_bell"]
const LEGENDS := ["frost_crown", "lich_crown", "wild_grimoire", "fire_brazier", "winter_bell"]

var main
var lg
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
	var f := FileAccess.open("res://art_sources/legend-cards-verify.json", FileAccess.WRITE)
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


func seconds(t: float) -> void:
	await get_tree().create_timer(t, true, false, true).timeout


func sp(p: Vector3) -> Vector2:
	return main.world.camera.unproject_position(p)


func clear_hand() -> void:
	for e in main.cards.hand():
		main.cards.entries.erase(e)
	main.cards.changed.emit()


func give(id: String, n := 1, person := "") -> int:
	while main.cards.hand_full():
		main.cards.entries.erase(main.cards.hand()[0])
	main.cards.add(id, n, person, "hand")
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
	m.set_physics_process(false)
	return m


func kill_enemies() -> void:
	for e in get_tree().get_nodes_in_group("enemies"):
		if not e.dead and e.get("is_boss") != true:
			e.take_damage(999999.0)
	await frames(3)


func wsp() -> Vector2:
	return sp(main.player.global_position + Vector3(0, 1.0, 0))


func set_state(s: int) -> void:
	main.session.state = s


func _run() -> void:
	lg = main.legend
	var res = main.resolver
	var cards = main.cards
	await frames(5)
	main.waves.set_process(false)
	await kill_enemies()
	spot = Layout.DOOR_FRONT + Vector3(5, 0, 3)
	main.player.global_position = Layout.DOOR_FRONT + Vector3(-5, 0, 2)
	main.player.set_physics_process(false)  # 검증 중 마녀가 걸어가 화면 좌표가 어긋나지 않게
	set_state(SessionScript.State.PREP)

	# ── 1. 데이터
	check("모듈이 붙어 있음(LegendCards)", lg != null and main.get_node_or_null("LegendCards") == lg)
	var missing: Array = NEW_CARDS.filter(func(id): return cards.def(id).is_empty())
	check("카탈로그에 6장", missing.is_empty(), str(missing))
	check("전설 5장은 전설 프레임·등급", LEGENDS.all(func(id): return cards.def(id).get("frame", "") == "legendary" and cards.def(id).get("rarity", "") == "legendary"))
	check("광석은 드워프 재화(묶음)", cards.is_resource("ore") and cards.stackable("ore") and cards.def("ore").get("race", "") == "dwarf")
	check("인쇄 문구 2줄씩", NEW_CARDS.all(func(id): return (cards.def(id).get("printed_rules", []) as Array).size() == 2))
	var en: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/cards/catalog_en.json"))["cards"]
	check("영문 문구 6장", NEW_CARDS.all(func(id): return en.has(id) and str(en[id].get("name", "")) != "" and (en[id].get("printed_rules", []) as Array).size() == 2))
	var tl: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/cards/text_layout.json"))
	check("판 프로파일: 전설=에린, 광석=목재", LEGENDS.all(func(id): return tl.has(id) and JSON.stringify(tl[id]) == JSON.stringify(tl["drunken_erin"]))
		and tl.has("ore") and JSON.stringify(tl["ore"]) == JSON.stringify(tl["timber"]))
	check("시간대: 광석 낮 · 마법서·종 밤 · 왕관·화로 공용", cards.phase_of("ore") == "day" and cards.phase_of("wild_grimoire") == "night"
		and cards.phase_of("winter_bell") == "night" and cards.phase_of("frost_crown") == "both" and cards.phase_of("lich_crown") == "both" and cards.phase_of("fire_brazier") == "both")
	var gsum := 0.0
	var has_ore := false
	for row in Cfg.GATHER_TABLE:
		gsum += float(row[1])
		has_ore = has_ore or row[0] == "ore"
	check("얻는 길: 채집표에 광석(합 1.0) · 드워프 묶음 · 판매가 12G(양털보다 비쌈)", has_ore and absf(gsum - 1.0) < 0.001 and "ore" in RaceData.POOLS["dwarf"]
		and int(Cfg.SALE_PRICES.get("ore", 0)) == 12 and int(Cfg.SALE_PRICES["ore"]) > Cfg.WOOL_PRICE, "합 %.2f" % gsum)
	var ok_shop := true
	for id in NEW_CARDS:
		if not MerchantData.sellable(id, cards.def(id)):
			ok_shop = false
	check("브로크 좌판에 오름 · 전설은 2배 값", ok_shop and MerchantData.price_of("frost_crown", cards.def("frost_crown")) == 90
		and MerchantData.price_of("ore", cards.def("ore")) == 28, "왕관 %dG · 광석 %dG" % [MerchantData.price_of("frost_crown", cards.def("frost_crown")), MerchantData.price_of("ore", cards.def("ore"))])

	# ── 2. 광석
	clear_hand()
	var ore_uid := await give("ore", 3)
	var lodge_sp := sp(main.world.lodge.global_position + Vector3(0, 1.6, 0))
	var p_sell: Dictionary = res.evaluate(ore_uid, lodge_sp)
	check("광석을 산장에 놓으면 판매(기존 판매 창)", p_sell.get("ok", false) and p_sell.get("action", "") == "sell", str(p_sell.get("reason", "")))
	var wall = main.race_cards._build("stone_wall", spot)
	await frames(3)
	var wall_sp := sp(wall.global_position + Vector3(0, wall.hp_offset * 0.5, 0))
	var p_wall: Dictionary = res.evaluate(ore_uid, wall_sp)
	check("광석을 돌 성벽에 놓으면 보강 판정", p_wall.get("ok", false) and p_wall.get("facility") == wall, str(p_wall.get("reason", "")))
	wall.take_damage(50.0)
	var base_hp: float = wall.max_hp
	res.commit(ore_uid, wall_sp)
	await frames(2)
	check("보강: 최대 체력 +40% · 완전 수리", absf(wall.max_hp - base_hp * 1.4) < 0.5 and absf(wall.hp - wall.max_hp) < 0.01, "%d/%d" % [int(wall.hp), int(wall.max_hp)])
	ore_uid = await give("ore", 1)
	res.commit(ore_uid, wall_sp)
	await frames(2)
	ore_uid = await give("ore", 1)
	check("시설마다 2번까지", not res.evaluate(ore_uid, wall_sp).get("ok", true))
	wall.collapse()
	await frames(2)
	var staff := await give("oak_staff")
	main.equipment.equip(main.player, staff)
	await frames(2)
	var m0: float = main.equipment.damage_mult(main.player)
	ore_uid = await give("ore", 3)
	var p_w: Dictionary = res.evaluate(ore_uid, wsp())
	check("무기를 낀 마녀에게 놓으면 벼리기 판정", p_w.get("ok", false) and p_w.has("weapon_uid"), str(p_w.get("reason", "")))
	for i in 3:
		ore_uid = await give("ore", 1)
		res.commit(ore_uid, wsp())
		await frames(1)
	var m3: float = main.equipment.damage_mult(main.player)
	check("벼리기 3번: 피해 배율 ×1.3", absf(m3 / m0 - 1.3) < 0.01, "%.3f → %.3f" % [m0, m3])
	ore_uid = await give("ore", 1)
	check("무기마다 3번까지", not res.evaluate(ore_uid, wsp()).get("ok", true))
	check("광석은 빈 땅에는 못 씀", not res.evaluate(ore_uid, sp(spot + Vector3(3, 0, 3))).get("ok", true))

	# ── 3. 서리 여왕의 왕관
	clear_hand()
	var fc := await give("frost_crown")
	check("왕관은 마녀에게만", not res.evaluate(fc, sp(spot)).get("ok", true) and res.evaluate(fc, wsp()).get("ok", false))
	res.commit(fc, wsp())
	await frames(2)
	check("서리 여왕이 됨 · 머리 위 왕관", lg.crown == "frost" and lg.frost_queen() and main.player.body.get_node_or_null("LegendCrown") != null)
	var lc := await give("lich_crown")
	check("왕관은 한 판에 하나", not res.evaluate(lc, wsp()).get("ok", true))
	var line: Array = []
	var origin: Vector3 = main.player.global_position
	for i in 4:
		line.append(enemy(origin + Vector3(2.0 + i * 1.3, 0, 0), 500.0))
	await frames(2)
	main.player._fire(line[0])
	var lance = null
	for c in main.actors.get_children():
		if c is IceLanceScript:
			lance = c
	check("마법탄 대신 얼음창을 쏨", lance != null)
	await seconds(1.2)
	var hit_n := 0
	var slowed := 0
	for e in line:
		if e.hp < 500.0:
			hit_n += 1
		if e.slow_factor() < 1.0:
			slowed += 1
	check("얼음창: 일직선 적 3마리 관통(4번째는 무사) · 둔화", hit_n == 3 and line[3].hp >= 500.0 and slowed >= 3, "맞음 %d · 둔화 %d" % [hit_n, slowed])
	await kill_enemies()
	var runes_before: int = cards.count_of("frost_rune")
	lg._on_state(SessionScript.State.COMBAT)
	check("밤이 오면 서리 룬 1장", cards.count_of("frost_rune") == runes_before + 1)

	# ── 4. 망자의 왕관
	lg.crown = ""
	main.undead.unlocked = false
	clear_hand()
	lc = await give("lich_crown")
	res.commit(lc, wsp())
	await frames(2)
	check("망자의 군주가 됨 · 언데드가 열림", lg.crown == "lich" and main.undead.unlocked)
	var before_cards: int = cards.entries.size()
	lg._on_state(SessionScript.State.PREP)
	await frames(1)
	var got_undead: bool = cards.entries.size() == before_cards + 1 and cards.entries.back()["id"] in RaceData.UNDEAD_POOL + RaceData.UNDEAD_INFAMY
	check("새벽마다 언데드 카드 1장", got_undead, str(cards.entries.back()["id"]) if not cards.entries.is_empty() else "")

	# ── 5. 폭주하는 마법서
	set_state(SessionScript.State.PREP)
	clear_hand()
	var gm := await give("wild_grimoire")
	check("마법서는 밤에만", not res.evaluate(gm, sp(spot)).get("ok", true))
	set_state(SessionScript.State.COMBAT)
	lg.spells_cast = 0
	check("바닥선: 주문 0장이어도 3번", lg.grimoire_count() == lg.GRIMOIRE_MIN)
	var fr := await give("frost_rune")
	var foe = enemy(spot, 400.0)
	await frames(2)
	res.commit(fr, sp(spot))
	await frames(2)
	check("주문 카드를 쓰면 센다", lg.spells_cast == 1)
	cards.add("raw_meat", 1, "", "hand")
	cards.consume(cards.hand().filter(func(e): return e["id"] == "raw_meat")[0]["uid"])
	check("주문이 아닌 카드는 안 센다", lg.spells_cast == 1)
	lg.spells_cast = 6
	var foes: Array = [foe, enemy(spot + Vector3(1.5, 0, 1), 400.0), enemy(spot + Vector3(-1, 0, 2), 400.0)]
	await frames(2)
	var lodge_hp: float = main.world.lodge.hp
	main.player.hp = main.player.max_hp - 30.0
	var witch_hp: float = main.player.hp
	var cast0: int = lg.stats["grimoire_spells"]
	res.commit(gm, sp(spot))
	check("마법서: 이번 판 주문 수만큼 폭주 대기", lg.grimoire_left == 6)
	await seconds(3.5)
	var hurt_foes := foes.filter(func(e): return e.dead or e.hp < 400.0).size()
	check("주문 6번이 터짐 · 적이 다침", lg.stats["grimoire_spells"] - cast0 == 6 and lg.grimoire_left == 0 and hurt_foes >= 1, "주문 %d · 다친 적 %d" % [lg.stats["grimoire_spells"] - cast0, hurt_foes])
	check("산장·마녀는 다치지 않음", main.world.lodge.hp >= lodge_hp and main.player.hp >= witch_hp)
	lg.spells_cast = 999
	check("상한 15번", lg.grimoire_count() == lg.GRIMOIRE_MAX)
	await kill_enemies()

	# ── 6. 불의 정령 화로
	clear_hand()
	var bz := await give("fire_brazier")
	var far: Vector3 = main.world.lodge.global_position + Vector3(14, 0, 0)
	check("화로는 산장 가까이에만", not res.evaluate(bz, sp(far)).get("ok", true))
	var near: Vector3 = Layout.DOOR_FRONT + Vector3(3, 0, 2)
	check("산장 가까이 땅에 세울 수 있음", res.evaluate(bz, sp(near)).get("ok", false), str(res.evaluate(bz, sp(near)).get("reason", "")))
	res.commit(bz, sp(near))
	await frames(3)
	var braziers: Array = main.race_cards.facilities("fire_brazier")
	check("화로 시설이 섬(체력 160)", braziers.size() == 1 and int(braziers[0].max_hp) == 160)
	var bz2 := await give("fire_brazier")
	check("화로는 하나만", not res.evaluate(bz2, sp(near + Vector3(1.5, 0, 0))).get("ok", true))
	var target = enemy(braziers[0].global_position + Vector3(6, 0, 0), 300.0)
	await frames(2)
	lg._brazier_t[braziers[0].get_instance_id()] = 0.0
	await frames(2)
	var fb_seen := false
	for c in main.actors.get_children():
		if c is FireballScript:
			fb_seen = true
	check("밤이면 화로가 불덩이를 던짐", fb_seen and lg.stats["brazier_fireballs"] >= 1)
	await seconds(1.2)
	check("불덩이가 적에게 큰 피해", target.dead or target.hp <= 300.0 - lg.BRAZIER_DAMAGE + 0.5, "체력 %d" % int(target.hp))
	await kill_enemies()

	# ── 7. 겨울의 끝 종
	clear_hand()
	set_state(SessionScript.State.PREP)
	var bell := await give("winter_bell")
	check("종은 밤에만", not res.evaluate(bell, sp(spot)).get("ok", true))
	set_state(SessionScript.State.COMBAT)
	main.race_cards._build("stone_wall", spot + Vector3(-2, 0, 0))
	var bell_foes: Array = [enemy(spot, 300.0), enemy(spot + Vector3(2, 0, 2), 300.0), enemy(Layout.DOOR_FRONT + Vector3(-12, 0, 8), 300.0)]
	cards.add("cursed_whisper", 1, "", "hand")
	await give("frost_rune")
	await frames(3)
	var hand_n: int = cards.hand().size()
	lodge_hp = main.world.lodge.hp
	var disc0: int = cards.discard.size()
	res.commit(bell, sp(spot))
	await frames(3)
	check("모든 적이 쓰러짐", bell_foes.all(func(e): return e.dead))
	check("우리 시설이 모두 무너짐(화로·돌 성벽)", main.race_cards.facilities().is_empty())
	check("손패를 전부 버림 · 침식도 버림패로", cards.hand().is_empty() and cards.discard.size() - disc0 == hand_n
		and cards.discard.any(func(e): return e["id"] == "cursed_whisper"), "버림 %d / 손패 %d" % [cards.discard.size() - disc0, hand_n])
	check("산장·마녀는 무사", main.world.lodge.hp >= lodge_hp and not main.player.dead)

	# ── 8. 새벽 보상에 전설 섞기
	lg.crown = ""
	lg.offered.clear()
	var base := ["timber", "wool", "raw_meat"]
	check("1일차엔 전설이 안 나옴", lg.mix_reward(base, 1) == base)
	main.relics.owned.append("frost_queen_tear")
	var with_tear: Array = lg.mix_reward(base, 1)
	check("서리 여왕의 눈물이 있으면 왕관이 반드시 나옴", with_tear[0] == "frost_crown" and with_tear.size() == 3)
	main.relics.owned.erase("frost_queen_tear")
	var replaced := 0
	for i in 2000:
		lg.offered.clear()
		if lg.mix_reward(base, 6)[0] != "timber":
			replaced += 1
	check("3일차부터 약 14% 확률", replaced > 200 and replaced < 380, "%d/2000" % replaced)
	lg.offered = ["frost_crown", "wild_grimoire", "fire_brazier", "winter_bell"]
	check("판마다 같은 전설은 한 번만(남은 것만 나옴)", lg._roll_legend() == "lich_crown")
	lg.crown = "frost"
	check("왕관을 썼으면 왕관은 더 안 나옴", lg._roll_legend() == "")

	# ── 9. 원화(Codex 납품)
	var art_ok := true
	var missing_art: Array = []
	for id in NEW_CARDS:
		var t: Texture2D = Catalog.texture(id)
		var h: Texture2D = Catalog.texture(id, true)
		if t == null or h == null or t.resource_path == Catalog.back(false).resource_path or t.get_width() != 1024 or h.get_width() != 256:
			art_ok = false
			missing_art.append(id)
	check("카드 원화 6장이 뒷면 대신 로드(1024·손패 256)", art_ok, str(missing_art))
