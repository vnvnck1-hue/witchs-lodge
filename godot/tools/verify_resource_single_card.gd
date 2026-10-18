extends SceneTree
## 재화 카드 1장=1개 전환 검증(기획: docs/resource-single-card-balance-v01.md, 2026-10-18).
## 카탈로그 비스택, 수치, 낱장 획득·소비·소멸, 손패 가득 시 주머니행, 판매 N장, 건축 목재 소비, 목재 수리를 확인한다.
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_resource_single_card.gd

const Cfg := preload("res://scripts/config.gd")
const SessionScript := preload("res://scripts/game/game_session.gd")

var game
var failures := 0
var total := 0


func _initialize() -> void:
	create_timer(120.0, true, false, true).timeout.connect(func(): print("FAIL timeout"); quit(1))
	_run.call_deferred()


func check(name: String, ok: bool, detail := "") -> void:
	total += 1
	if not ok:
		failures += 1
	print(("PASS " if ok else "FAIL ") + name + ("  — " + detail if detail != "" else ""))


func frames(n := 2) -> void:
	for i in n:
		await process_frame


func hand_entries(id: String) -> Array:
	return game.cards.hand().filter(func(e): return e["id"] == id)


func in_discard(id: String) -> bool:
	for e in game.cards.discard:
		if e["id"] == id:
			return true
	return false


func _run() -> void:
	root.size = Vector2i(1600, 900)
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(8)
	game.session.set_process(false)
	game.economy.set_process(false)
	if game.wildlife != null:
		game.wildlife.set_process(false)
	game.session.state = SessionScript.State.PREP
	var cards = game.cards
	var eco = game.economy

	# ── 카탈로그: 모든 카드가 낱장, 재화 5종이 kind=resource ──
	var any_stack := false
	for id in cards.defs:
		if cards.stackable(id):
			any_stack = true
	check("카탈로그에 stackable 카드가 없음", not any_stack)
	for id in ["timber", "wool", "black_wool", "raw_meat", "rabbit_pelt", "winter_firewood"]:
		check("%s 는 재화(kind=resource)" % id, cards.is_resource(id))

	# ── 수치 ──
	check("나무꾼 보유 상한 1", Cfg.LUMBERJACK_CARRY == 1)
	check("벌목 15초 · 고목의 심장 10초", is_equal_approx(Cfg.CHOP_TIME, 15.0) and is_equal_approx(Cfg.RELIC_CHOP_TIME, 10.0))
	check("나무 한 그루 목재 2~6장", Cfg.TREE_YIELD_MIN == 2 and Cfg.TREE_YIELD_MAX == 6)
	check("목재 수리 1장 → +60", Cfg.TIMBER_REPAIR_COST == 1 and is_equal_approx(Cfg.TIMBER_REPAIR_AMOUNT, 60.0))
	var max_build := 0
	for k in Cfg.BUILD_COSTS:
		for step in Cfg.BUILD_COSTS[k]:
			max_build = maxi(max_build, int(step.get("timber", 0)))
	check("건축 목재 최고 3장", max_build == 3, str(Cfg.BUILD_COSTS))
	check("제단 복구 목재 3장", Cfg.ALTAR_RESTORE_TIMBER == 3)
	check("판매가 양털 6·고기 8·가죽 10", Cfg.WOOL_PRICE == 6 and Cfg.MEAT_PRICE == 8 and Cfg.PELT_PRICE == 10)
	check("생고기 회복 30", is_equal_approx(Cfg.MEAT_HEAL, 30.0))
	check("사슴 생고기 1장", Cfg.DEER_MEAT == 1)
	var timber_row: Array = Cfg.GATHER_TABLE[0]
	check("채집 목재 1장", timber_row[0] == "timber" and int(timber_row[2]) == 1 and int(timber_row[3]) == 1)
	check("상자 대체 목재 2장", Cfg.CHEST_FALLBACK_TIMBER == 2)
	check("수의의 의식 양털 2", int(Cfg.RITUALS["shroud"]["cost"]["wool"]) == 2)
	check("손패 한도 8 유지", Cfg.HAND_VISIBLE == 8)

	# ── 낱장 획득: 목재 3개 = 손패 3칸 ──
	# 시작 손패를 비워 깨끗하게 시작한다
	for e in cards.entries.duplicate():
		cards.remove_uid(e["uid"])
	cards.add("timber", 3)
	check("목재 3개 추가 → 손패에 목재 카드 3장", hand_entries("timber").size() == 3 and cards.hand_count_of("timber") == 3)
	var all_one := true
	for e in hand_entries("timber"):
		if int(e["count"]) != 1:
			all_one = false
	check("각 목재 카드 수량 1", all_one)
	cards.add("wool", 2)
	check("양털 2개 → 손패 2장, 손패 총 5장", hand_entries("wool").size() == 2 and cards.hand().size() == 5)

	# ── 종류 소비: 2장 소멸, 버림패에 가지 않음 ──
	check("목재 2장 소비", cards.consume_id("timber", 2) and cards.hand_count_of("timber") == 1)
	check("재화는 버림패로 가지 않음", not in_discard("timber"))
	check("손패보다 많이 소비하면 실패하고 그대로", not cards.consume_id("timber", 5) and cards.hand_count_of("timber") == 1)

	# ── 판매: 손패의 같은 종류 N장 ──
	var g0: int = eco.gold
	var wool_uid: int = hand_entries("wool")[0]["uid"]
	check("끌어 놓은 양털 1장 판매 +6G", eco.sell_resource(wool_uid, 1) and eco.gold == g0 + Cfg.WOOL_PRICE and cards.hand_count_of("wool") == 1)
	check("손패보다 많이 팔 수 없음", not eco.sell_id("wool", 2) and cards.hand_count_of("wool") == 1)
	cards.add("raw_meat", 3)
	g0 = eco.gold
	check("생고기 3장 한 번에 판매 +24G", eco.sell_id("raw_meat", 3) and eco.gold == g0 + 3 * Cfg.MEAT_PRICE and cards.hand_count_of("raw_meat") == 0)
	game.session.state = SessionScript.State.COMBAT
	check("전투 중에는 판매 불가", not eco.sell_id("wool", 1))
	game.session.state = SessionScript.State.PREP

	# ── 건축: 묘지 확장 1단계 = 30G + 목재 2장 ──
	for e in cards.entries.duplicate():
		cards.remove_uid(e["uid"])
	eco.gold = 100
	cards.add("timber", 2)
	check("묘지 확장 가격 표기 '30G · 목재 2'", eco.price_text("graves") == "30G · 목재 2", eco.price_text("graves"))
	check("목재 1장이면 목재 부족", (func(): cards.consume_id("timber", 1); return eco.block_reason("graves").begins_with("목재 부족")).call())
	cards.add("timber", 1)
	check("목재 2장이면 확장 가능 → 목재 0, 골드 70", eco.buy("graves") and cards.hand_count_of("timber") == 0 and eco.gold == 70)

	# ── 목재 수리: 카드 1장 → +60 ──
	var lodge = game.world.lodge
	lodge.hp = lodge.max_hp - 100.0
	cards.add("timber", 1)
	var t_uid: int = hand_entries("timber")[0]["uid"]
	var sp: Vector2 = game.world.camera.unproject_position(lodge.global_position)
	var plan: Dictionary = game.resolver.evaluate(t_uid, sp)
	check("목재를 산장에 놓으면 수리 판정", plan.get("ok", false) and plan.get("action", "") == "repair", str(plan.get("reason", plan.get("title", ""))))
	if plan.get("ok", false):
		var hp0: float = lodge.hp
		var res: Dictionary = game.resolver.commit(t_uid, sp)
		check("수리 후 산장 +60, 목재 0장", res.get("ok", false) and is_equal_approx(lodge.hp, hp0 + 60.0) and cards.hand_count_of("timber") == 0, "%.0f → %.0f" % [hp0, lodge.hp])

	# ── 손패 가득: 넘친 재화는 주머니로(현행 규칙 유지, 사용자 결정 2026-10-18) ──
	for e in cards.entries.duplicate():
		cards.remove_uid(e["uid"])
	cards.add("timber", Cfg.HAND_VISIBLE)
	check("손패 8장 가득", cards.hand_full() and cards.hand().size() == Cfg.HAND_VISIBLE)
	var zone: String = cards.add("wool", 1)
	check("가득 찬 상태의 양털은 주머니로", zone == "pocket" and cards.pocket_count_of("wool") == 1 and cards.hand_count_of("wool") == 0)
	check("주머니 재화는 판매 불가(손패만)", not eco.sell_id("wool", 1))
	cards.consume_id("timber", 1)
	var got: Array = cards.draw(1)
	check("빈칸이 생기면 드로우로 양털 1장이 손패로", got.size() == 1 and got[0]["id"] == "wool" and cards.hand_count_of("wool") == 1)

	# ── 나무꾼: 목재 1개를 들면 가득 차서 쉬고, 마녀가 받아 가면 다시 벌목 ──
	for e in cards.entries.duplicate():
		cards.remove_uid(e["uid"])
	game.world.day_cycle.set_mode("day")
	var cd = game.contracts
	var tree: Variant = null
	for t in game.world.harvest_trees:
		if not t.get("removed", false) and t["remaining"] >= 2 and t["reserved"] == null and game.world.tree_access(t) == "":
			tree = t
			break
	check("벌목할 나무 있음(한 그루 2장 이상)", tree != null)
	if tree != null:
		var lj = cd.spawn_chop("검증나무꾼", tree, game.resolver.work_position(tree))
		await frames(2)
		lj.state = lj.State.WORKING
		cd.finish_chop(lj)
		check("벌목 1회 = 목재 1개를 들고 바로 가득 참", int(lj.carry.get("timber", 0)) == 1 and lj.state == lj.State.IDLE, str(lj.carry))
		check("가득 찬 동안은 다음 나무를 맡지 않음", not cd.assign_next_tree(lj))
		lj.hand_over()
		check("마녀가 받으면 손패에 목재 1장, 다시 벌목하러 감", cards.hand_count_of("timber") == 1 and cd.assign_next_tree(lj) and lj.state == lj.State.GO_WORK)
		lj.dismiss()
		await frames(2)

	print("RESULT %d/%d" % [total - failures, total])
	quit(0 if failures == 0 else 1)
