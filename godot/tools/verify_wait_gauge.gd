extends SceneTree
## 기다림 게이지: 좌측 고용 제안 줄과 대화 알림 아래에 손님이 떠나기까지 남은 시간이 막대로 줄어드는지,
## 색이 금색 → 주황 → 붉은색(깜박임)으로 바뀌는지, 남은 시간 계산(guest_time_left)이 맞는지 검증한다.
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_wait_gauge.gd

const Cfg := preload("res://scripts/config.gd")
const WaitGauge := preload("res://scripts/ui/wait_gauge.gd")

var failures := 0
var total := 0


func _initialize() -> void:
	create_timer(90.0, true, false, true).timeout.connect(func(): print("FAIL timeout"); quit(1))
	_run.call_deferred()


func check(name: String, ok: bool, detail := "") -> void:
	total += 1
	if not ok:
		failures += 1
	print(("PASS " if ok else "FAIL ") + name + ("  — " + detail if detail != "" else ""))


func frames(n := 2) -> void:
	for i in n:
		await process_frame


## 게임 시간으로 seconds 만큼 흘려보낸다(배속).
func advance(seconds: float) -> void:
	Engine.time_scale = 10.0
	await create_timer(seconds / 10.0, true, false, true).timeout
	Engine.time_scale = 1.0
	await frames(2)


func _run() -> void:
	# ── 게이지 자체 ──
	var g := WaitGauge.new()
	g.size = Vector2(200, 6)
	root.add_child(g)
	g.ratio = 1.0
	check("가득: 금색", g.fill_color().is_equal_approx(WaitGauge.C_FULL) and not g.urgent())
	g.ratio = 0.4
	check("반 아래: 주황~붉은 사이", g.fill_color().r > g.fill_color().g and not g.urgent())
	g.ratio = 0.1
	check("1/4 아래: 붉게 깜박임", g.fill_color().is_equal_approx(WaitGauge.C_LOW) and g.urgent())
	g.ratio = 1.7
	check("비율은 0~1로 자름", is_equal_approx(g.ratio, 1.0))
	check("마우스 입력을 막지 않음", g.mouse_filter == Control.MOUSE_FILTER_IGNORE)
	g.queue_free()

	root.size = Vector2i(1600, 900)
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(8)
	game.world.day_cycle.set_mode("day")
	var eco = game.economy
	var events = game.guest_events
	var ui = game.guest_ui
	var hand = game.hud.card_hand

	# ── 손님 무리를 불러 남은 시간 계산 ──
	check("손님 초대 가능", eco.invite_block_reason() == "", eco.invite_block_reason())
	eco.invite_batch()
	await frames(4)
	var visits: Array = events.current_guests()
	check("손님 도착 기록", visits.size() >= 2, str(visits.size()))
	if visits.size() < 2:
		print("RESULT %d/%d" % [total - failures, total])
		quit(1)
		return
	var first: Dictionary = visits[visits.size() - 2]   # 초대한 무리의 첫 손님(고용 제안 몫)
	var second: Dictionary = visits[visits.size() - 1]
	var l1: float = eco.guest_time_left(first.uid)
	var l2: float = eco.guest_time_left(second.uid)
	check("보통 손님: 숙박 시간만큼 남음", absf(l2 - Cfg.GUEST_STAY) < 0.5, "%.1f초" % l2)
	check("고용 제안 손님: 숙박 + 고용 대기", absf(l1 - (Cfg.GUEST_STAY + Cfg.HIRE_WAIT)) < 0.5, "%.1f초" % l1)
	check("모르는 손님은 -1", eco.guest_time_left(99999) < 0.0)

	# ── 대화 알림 게이지 ──
	for e in [first, second]:
		events.admit(e.profile)
	first.read = true  # 알림이 두 번째 손님에 머물도록(첫 손님 이야기는 이미 들은 것으로)
	second.ready = true
	second.read = false
	await frames(3)
	check("대화 알림 표시", ui.notification.visible and ui.notification_uid == second.uid)
	check("대화 게이지 표시·가득", ui.notify_gauge.visible and ui.notify_gauge.ratio > 0.95, "%.2f" % ui.notify_gauge.ratio)
	var nr: Rect2 = ui.notify_gauge.get_global_rect()
	check("대화 게이지는 화면 좌측", nr.end.x < root.size.x * 0.3 and nr.size.x > 60, str(nr))
	check("툴팁에 남은 초", ui.notification.tooltip_text.contains("초 뒤 산장을 떠납니다"))
	var before: float = ui.notify_gauge.ratio
	await advance(Cfg.GUEST_STAY * 0.5)
	var want: float = eco.guest_time_left(second.uid) / l2
	check("시간이 흐르면 대화 게이지가 준다", ui.notify_gauge.ratio < before - 0.15, "%.2f → %.2f" % [before, ui.notify_gauge.ratio])
	check("대화 게이지 = 떠나기까지 남은 시간 비율", absf(ui.notify_gauge.ratio - want) < 0.05, "%.2f vs %.2f" % [ui.notify_gauge.ratio, want])

	# ── 고용 제안 게이지 ──
	await advance(Cfg.GUEST_STAY * 0.5 + 1.0)
	check("숙박이 끝나면 고용 제안", eco.offers.size() >= 1)
	await frames(3)
	var row: Dictionary = {}
	for r in hand.offer_rows:
		if r["offer"] in eco.offers:
			row = r
	check("고용 제안 줄에 게이지", not row.is_empty() and row.has("gauge") and row["gauge"].is_visible_in_tree())
	if not row.is_empty():
		var gr: Rect2 = row["gauge"].get_global_rect()
		check("고용 게이지는 화면 좌측·폭 있음", gr.end.x < root.size.x * 0.3 and gr.size.x > 60 and gr.size.y >= 4, str(gr))
		check("제안 직후 거의 가득", row["gauge"].ratio > 0.8, "%.2f" % row["gauge"].ratio)
		var offer: Dictionary = row["offer"]
		# 남은 시간이 1/4 아래가 될 때까지 흘려보낸다(배속은 프레임 길이 제한 때문에 정확하지 않다)
		for i in 10:
			if eco.offer_time_left(offer) < Cfg.HIRE_WAIT * 0.22:
				break
			await advance(1.0)
		await frames(2)
		for r in hand.offer_rows:  # 제안 목록이 바뀌면 줄을 다시 만든다
			if r["offer"] == offer:
				row = r
		var left: float = eco.offer_time_left(offer)
		check("게이지 = 남은 시간 비율", absf(row["gauge"].ratio - left / Cfg.HIRE_WAIT) < 0.05, "%.2f vs %.2f" % [row["gauge"].ratio, left / Cfg.HIRE_WAIT])
		check("끝무렵엔 붉게 깜박", row["gauge"].urgent(), "%.2f" % row["gauge"].ratio)

	print("RESULT %d/%d" % [total - failures, total])
	quit(1 if failures > 0 else 0)
