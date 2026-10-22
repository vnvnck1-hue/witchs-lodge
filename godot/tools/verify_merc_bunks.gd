extends SceneTree
## 용병 숙소 침상 상한·고용 기회 검증(기획: docs/merc-count-balance-v01.md, 사용자 확정 2026-10-22).
## 침상 4→6→8, 침상을 넘겨 고용 불가, 증축 일차 제한(6·9일차), 2일차부터 하루 고용 기회 1번, 관리창 행을 확인한다.
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_merc_bunks.gd

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


func clear_cards() -> void:
	for e in game.cards.entries.duplicate():
		game.cards.remove_uid(e["uid"])


var _n := 0
func offer() -> Dictionary:
	_n += 1
	var o := {"person": "시험용병%d" % _n, "guest": null, "expires": 9999.0, "job": "warrior"}
	game.economy.offers.append(o)
	return o


func hire_n(n: int) -> int:
	var ok := 0
	for i in n:
		game.economy.gold = 999
		if game.economy.hire(offer()):
			ok += 1
	return ok


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
	var eco = game.economy
	clear_cards()

	# ── 수치 ──
	check("침상 4·6·8", Cfg.BUNK_LEVELS == [4, 6, 8])
	check("증축 6·9일차부터", Cfg.BUNK_UNLOCK_DAYS == [6, 9])
	check("숙소 증축 80G·목재 3 / 140G·목재 3", Cfg.BUILD_COSTS["bunks"] == [{"gold": 80, "timber": 3}, {"gold": 140, "timber": 3}])
	check("고용 기회: 1일차 2번, 이후 1번", Cfg.HIRE_BATCHES_FIRST_DAY == [0, 1] and Cfg.HIRE_BATCHES == [0])

	game.session.wave_index = 0
	check("1일차 hire_batches = [0,1]", eco.hire_batches() == [0, 1], str(eco.hire_batches()))
	game.session.wave_index = 1
	check("2일차 hire_batches = [0]", eco.hire_batches() == [0], str(eco.hire_batches()))

	# ── 침상 4개: 다섯 번째는 고용 불가 ──
	check("시작 침상 4개", eco.bunk_capacity() == 4)
	var r0: int = eco.roster_count()
	check("4명까지 고용", hire_n(4 - r0) == 4 - r0 and eco.roster_count() == 4, "roster=%d" % eco.roster_count())
	var o5 := offer()
	eco.gold = 999
	var reason: String = eco.hire_block_reason(o5)
	check("5번째 고용 막힘(침상 4개가 모두 찼음 · 6일차 안내)", reason.begins_with("침상 4개가 모두 찼음") and reason.contains("6일차"), reason)
	check("넘겨서 고용 불가", not eco.hire(o5) and eco.roster_count() == 4)
	check("골드가 남아도 막힘", eco.gold == 999)

	# ── 증축 일차 제한 ──
	game.cards.add("timber", 3, "", "hand")
	eco.gold = 999
	check("2일차엔 숙소 증축 불가", eco.block_reason("bunks") == "6일차부터 증축 가능", eco.block_reason("bunks"))
	check("가격 표기 '80G · 목재 3'", eco.price_text("bunks") == "80G · 목재 3", eco.price_text("bunks"))
	game.session.wave_index = 5
	check("6일차엔 증축 가능", eco.block_reason("bunks") == "", eco.block_reason("bunks"))
	check("증축 → 침상 6, 목재 0, 골드 919", eco.buy("bunks") and eco.bunk_capacity() == 6 and game.cards.hand_count_of("timber") == 0 and eco.gold == 919)
	check("침상 6 → 5·6번째 고용", hire_n(2) == 2 and eco.roster_count() == 6)
	var o7 := offer()
	check("7번째는 다시 막힘(9일차 안내)", eco.hire_block_reason(o7).contains("9일차"), eco.hire_block_reason(o7))
	game.cards.add("timber", 3, "", "hand")
	eco.gold = 999
	check("6일차엔 2단계 증축 불가", eco.block_reason("bunks") == "9일차부터 증축 가능", eco.block_reason("bunks"))
	game.session.wave_index = 8
	check("9일차 2단계 증축 → 침상 8", eco.buy("bunks") and eco.bunk_capacity() == 8)
	check("최대 단계", eco.block_reason("bunks") == "최대 단계" and eco.price_text("bunks") == "완료")
	check("8명까지 고용, 9번째 막힘(해지 안내)", hire_n(2) == 2 and eco.roster_count() == 8 and eco.hire_block_reason(offer()).contains("해지"))

	# ── 묘지는 더 이상 고용을 막지 않는다 ──
	check("묘지 크기와 무관(묘지 8 · 침상 8에서 막힌 이유는 침상)", eco.hire_block_reason(offer()).begins_with("침상"))

	# ── 관리창: 숙소 행 ──
	game.hud.open_lodge_panel()
	await frames(2)
	game.hud._refresh_shop()
	var row = game.hud.shop_rows.get("bunks")
	check("관리창에 '용병 숙소 증축' 행", row != null)
	if row != null:
		check("상태 '용병 8/8명'", row["state"].text == "용병 8/8명", row["state"].text)
		check("최대 단계 버튼 '완료'", row["button"].text == "완료" and row["button"].disabled)
	var grow = game.hud.shop_rows.get("graves")
	check("묘지 행 상태는 무덤 수", grow != null and grow["state"].text.begins_with("무덤 "), grow["state"].text if grow != null else "")

	print("RESULT %d/%d" % [total - failures, total])
	quit(1 if failures > 0 else 0)
