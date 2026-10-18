extends SceneTree
## 재화 밸런스·묶음 검증(기획: docs/resource-single-card-balance-v01.md).
## 2026-10-18: 재화를 1장=1개로 바꿨다가 같은 날 묶음(한 장에 수량)으로 되돌렸다. 줄인 생산·소비 수치는 유지한다.
## 카탈로그 묶음, 수치, 묶음 획득·소비, 판매 수량 창, 건축 목재 소비, 목재 수리, 손패 가득 시 주머니행, 나무꾼 1개, 수량 배지 왼쪽 아래를 확인한다.
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_resource_balance.gd

const Cfg := preload("res://scripts/config.gd")
const SessionScript := preload("res://scripts/game/game_session.gd")

const RESOURCES := ["timber", "wool", "black_wool", "raw_meat", "rabbit_pelt"]

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


func clear_cards() -> void:
	for e in game.cards.entries.duplicate():
		game.cards.remove_uid(e["uid"])


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
	var hand = game.hud.card_hand

	# ── 카탈로그: 재화 5종은 묶음, 겨울 장작은 낱장 ──
	for id in RESOURCES:
		check("%s 는 묶음(stackable) 재화" % id, cards.stackable(id) and cards.is_resource(id))
	check("겨울 장작은 낱장 재화", not cards.stackable("winter_firewood") and cards.is_resource("winter_firewood"))

	# ── 수치(1장=1개 때 줄인 값 유지) ──
	check("나무꾼 보유 상한 1", Cfg.LUMBERJACK_CARRY == 1)
	check("벌목 15초 · 고목의 심장 10초", is_equal_approx(Cfg.CHOP_TIME, 15.0) and is_equal_approx(Cfg.RELIC_CHOP_TIME, 10.0))
	check("나무 한 그루 목재 2~6개", Cfg.TREE_YIELD_MIN == 2 and Cfg.TREE_YIELD_MAX == 6)
	check("목재 수리 1개 → +60", Cfg.TIMBER_REPAIR_COST == 1 and is_equal_approx(Cfg.TIMBER_REPAIR_AMOUNT, 60.0))
	var max_build := 0
	for k in Cfg.BUILD_COSTS:
		for step in Cfg.BUILD_COSTS[k]:
			max_build = maxi(max_build, int(step.get("timber", 0)))
	check("건축 목재 최고 3개", max_build == 3, str(Cfg.BUILD_COSTS))
	check("판매가 양털 6·고기 8·가죽 10", Cfg.WOOL_PRICE == 6 and Cfg.MEAT_PRICE == 8 and Cfg.PELT_PRICE == 10)

	# ── 묶음 획득: 목재 3개 = 손패 한 칸 ×3 ──
	clear_cards()
	cards.add("timber", 3)
	check("목재 3개 추가 → 손패 한 장에 ×3", hand_entries("timber").size() == 1 and int(hand_entries("timber")[0]["count"]) == 3)
	cards.add("timber", 2)
	check("같은 목재는 손패 묶음에 합산(×5)", hand_entries("timber").size() == 1 and cards.hand_count_of("timber") == 5)
	cards.add("wool", 2)
	check("양털 묶음 추가 → 손패 2장", cards.hand().size() == 2)

	# ── 종류 소비: 묶음에서 수량 차감, 버림패 없음 ──
	check("목재 2개 소비 → ×3", cards.consume_id("timber", 2) and cards.hand_count_of("timber") == 3)
	check("재화는 버림패로 가지 않음", not in_discard("timber"))
	check("손패보다 많이 소비하면 실패하고 그대로", not cards.consume_id("timber", 9) and cards.hand_count_of("timber") == 3)

	# ── 판매: 산장에 놓으면 수량 창이 열리고, 고른 수량만 판다 ──
	cards.add("wool", 3)  # 양털 ×5
	var wool_uid: int = hand_entries("wool")[0]["uid"]
	var lodge_sp: Vector2 = game.world.camera.unproject_position(game.world.lodge.global_position)
	var plan: Dictionary = game.resolver.commit(wool_uid, lodge_sp)
	check("양털을 산장에 놓으면 판매 판정(아직 소비 안 함)", plan.get("ok", false) and plan.get("action", "") == "sell" and cards.hand_count_of("wool") == 5, str(plan.get("reason", "")))
	hand.open_sale(wool_uid)
	check("판매 수량 창이 열리고 기본 수량은 보유 전부(5)", hand.sale_panel.visible and hand.sale_qty == 5)
	hand._set_qty(2)
	var g0: int = eco.gold
	hand._confirm_sale()
	check("2개 판매 +12G, 양털 ×3 남음, 창 닫힘", eco.gold == g0 + 2 * Cfg.WOOL_PRICE and cards.hand_count_of("wool") == 3 and not hand.sale_panel.visible)
	game.session.state = SessionScript.State.COMBAT
	check("전투 중에는 판매 불가", not eco.sell_resource(wool_uid, 1))
	game.session.state = SessionScript.State.PREP

	# ── 건축: 묘지 확장 1단계 = 30G + 목재 2 ──
	clear_cards()
	eco.gold = 100
	cards.add("timber", 1)
	check("묘지 확장 가격 표기 '30G · 목재 2'", eco.price_text("graves") == "30G · 목재 2", eco.price_text("graves"))
	check("목재 1개면 목재 부족", eco.block_reason("graves").begins_with("목재 부족"), eco.block_reason("graves"))
	cards.add("timber", 1)
	check("목재 2개면 확장 → 목재 0, 골드 70", eco.buy("graves") and cards.hand_count_of("timber") == 0 and eco.gold == 70)

	# ── 목재 수리: 묶음에서 1개 → +60 ──
	var lodge = game.world.lodge
	lodge.hp = lodge.max_hp - 100.0
	cards.add("timber", 3)
	var t_uid: int = hand_entries("timber")[0]["uid"]
	var rp: Dictionary = game.resolver.evaluate(t_uid, lodge_sp)
	check("목재를 산장에 놓으면 수리 판정", rp.get("ok", false) and rp.get("action", "") == "repair", str(rp.get("reason", rp.get("title", ""))))
	if rp.get("ok", false):
		var hp0: float = lodge.hp
		var res: Dictionary = game.resolver.commit(t_uid, lodge_sp)
		check("수리 후 산장 +60, 목재 ×2 남음", res.get("ok", false) and is_equal_approx(lodge.hp, hp0 + 60.0) and cards.hand_count_of("timber") == 2, "%.0f → %.0f" % [hp0, lodge.hp])

	# ── 손패 가득: 같은 묶음이 손패에 있으면 합산, 없으면 주머니로 ──
	clear_cards()
	for i in Cfg.HAND_VISIBLE - 1:
		cards.add("frost_rune")
	cards.add("timber", 1)
	check("손패 8장 가득", cards.hand_full())
	cards.add("timber", 4)
	check("가득 차도 손패의 목재 묶음에는 합산(×5)", cards.hand_count_of("timber") == 5 and cards.pocket_count_of("timber") == 0)
	var zone: String = cards.add("wool", 2)
	check("손패에 묶음이 없는 양털은 주머니로", zone == "pocket" and cards.pocket_count_of("wool") == 2 and cards.hand_count_of("wool") == 0)

	# ── 수량 배지: 카드 왼쪽 아래 모서리 ──
	clear_cards()
	cards.add("timber", 4)
	await frames(30)
	var tv = hand.views.get(hand_entries("timber")[0]["uid"])
	check("목재 카드 뷰가 있음", tv != null)
	if tv != null:
		var bp: Control = tv.badge.get_parent()
		check("배지에 ×4 표시", bp.visible and tv.badge.text == "×4", tv.badge.text)
		check("배지는 카드 왼쪽 아래(왼쪽 1/3·아래쪽 1/4 안)", bp.position.x < tv.size.x * 0.1 and bp.position.y > tv.size.y * 0.75 and bp.position.x + bp.size.x < tv.size.x * 0.45, "pos=%s size=%s card=%s" % [bp.position, bp.size, tv.size])

	# ── 나무꾼: 목재 1개를 들면 가득 차서 쉬고, 마녀가 받아 가면 다시 벌목 ──
	clear_cards()
	game.world.day_cycle.set_mode("day")
	var cd = game.contracts
	var tree: Variant = null
	for t in game.world.harvest_trees:
		if not t.get("removed", false) and t["remaining"] >= 2 and t["reserved"] == null and game.world.tree_access(t) == "":
			tree = t
			break
	check("벌목할 나무 있음(한 그루 2개 이상)", tree != null)
	if tree != null:
		var lj = cd.spawn_chop("검증나무꾼", tree, game.resolver.work_position(tree))
		await frames(2)
		lj.state = lj.State.WORKING
		cd.finish_chop(lj)
		check("벌목 1회 = 목재 1개를 들고 바로 가득 참", int(lj.carry.get("timber", 0)) == 1 and lj.state == lj.State.IDLE, str(lj.carry))
		lj.hand_over()
		check("마녀가 받으면 손패 목재 ×1, 다시 벌목하러 감", cards.hand_count_of("timber") == 1 and cd.assign_next_tree(lj) and lj.state == lj.State.GO_WORK)
		lj.dismiss()
		await frames(2)

	print("RESULT %d/%d" % [total - failures, total])
	quit(0 if failures == 0 else 1)
