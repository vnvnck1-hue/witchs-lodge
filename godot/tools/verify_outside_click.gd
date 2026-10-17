extends SceneTree
## 창 밖(허공) 클릭으로 닫기 UX: 닫을 수 있는 창은 밖을 클릭하면 닫히고, 창 안·HUD 버튼 클릭은 닫지 않으며,
## 반드시 골라야 하는 창(보물상자·새벽 선물)은 밖을 클릭해도 그대로인지 실제 마우스 입력으로 검증한다.
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_outside_click.gd

const Profiles := preload("res://scripts/ui/guest_profiles.gd")

var game
var failures := 0
var total := 0
var empty_spot := Vector2(-1, -1)


func _initialize() -> void:
	create_timer(60.0, true, false, true).timeout.connect(func(): print("FAIL timeout"); quit(1))
	_run.call_deferred()


func check(name: String, ok: bool, detail := "") -> void:
	total += 1
	if not ok:
		failures += 1
	print(("PASS " if ok else "FAIL ") + name + ("  — " + detail if detail != "" else ""))


func frames(n := 2) -> void:
	for i in n:
		await process_frame


func move_to(at: Vector2) -> void:
	var m := InputEventMouseMotion.new()
	m.position = at
	m.global_position = at
	root.push_input(m, true)
	await frames(1)


func click_at(at: Vector2, button := MOUSE_BUTTON_LEFT) -> void:
	await move_to(at)
	for pressed in [true, false]:
		var e := InputEventMouseButton.new()
		e.position = at
		e.global_position = at
		e.button_index = button
		e.pressed = pressed
		root.push_input(e, true)
		await frames(2)


func center_of(c: Control) -> Vector2:
	return c.get_global_rect().get_center()


## 지금 열린 창·HUD 어느 것도 덮지 않은 월드 지점(hovered 가 null 인 곳)을 격자로 찾는다.
func find_empty_spot() -> Vector2:
	var view := root.get_visible_rect().size
	var y := 30.0
	while y < view.y - 30.0:
		var x := 30.0
		while x < view.x - 30.0:
			await move_to(Vector2(x, y))
			if root.gui_get_hovered_control() == null:
				return Vector2(x, y)
			x += 50.0
		y += 50.0
	check("창 밖 빈 지점 없음", false)
	return Vector2(-1, -1)


func _run() -> void:
	root.size = Vector2i(1600, 900)
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await frames(8)
	var hud = game.hud
	var hand = hud.card_hand
	game.world.day_cycle.set_mode("day")
	check("시작은 준비(PREP) 단계", game.session.state == 0)

	empty_spot = await find_empty_spot()
	check("월드 빈 지점 찾음", empty_spot.x >= 0, str(empty_spot))
	# 창 중앙에서 먼 모서리: 전체 화면 막(CanvasLayer)을 쓰는 창의 '밖' 지점
	var corner := Vector2(root.get_visible_rect().size.x * 0.5, 24)

	# ── 제단 ──
	game.altar_ui.open()
	await frames(3)
	check("제단 열림", game.altar_ui.active and paused)
	await click_at(center_of(game.altar_ui.panel))
	check("제단 창 안 클릭 → 그대로", game.altar_ui.active)
	await click_at(corner)
	check("제단 창 밖 클릭 → 닫힘", not game.altar_ui.active and not paused)

	# ── 장날 ──
	var ui = game.offer_ui
	ui.open_market([{"id": "vine_snare", "price": 9999, "sold": false}, {"id": "winter_firewood", "price": 9999, "sold": false}, {"id": "frost_rune", "price": 9999, "sold": false}])
	await frames(3)
	check("장날 열림", ui.active and ui.mode == "market")
	var b0: Control = ui.buttons[0]["btn"]
	var b1: Control = ui.buttons[1]["btn"]
	var gap := Vector2((b0.get_global_rect().end.x + b1.get_global_rect().position.x) * 0.5, center_of(b0).y)
	await click_at(gap)
	check("장날 카드 사이 틈 클릭 → 그대로", ui.active)
	await click_at(center_of(b0))
	check("장날 카드 클릭(골드 부족) → 그대로", ui.active)
	await click_at(corner)
	check("장날 밖 클릭 → 닫힘", not ui.active and not paused)

	# ── 새벽 선물: 밖 클릭으로 닫히지 않음 ──
	ui.open_reward(["moss_bandage", "resin_torch", "firefly_swarm"])
	await frames(3)
	await click_at(corner)
	check("새벽 선물 밖 클릭 → 닫히지 않음(보상 보호)", ui.active and ui.mode == "reward")
	ui.close()
	await frames(2)

	# ── 보물상자: 반드시 골라야 함 ──
	game.chest_ui.open(Vector3.ZERO)
	await frames(3)
	await click_at(corner)
	check("보물상자 밖 클릭 → 닫히지 않음", game.chest_ui.active)
	game.chest_ui.close()
	await create_timer(0.5, true, false, true).timeout  # 닫힘 연출(0.25초)이 끝나 막이 사라질 때까지

	# ── 일시 정지 ──
	hud._toggle_pause()
	await frames(3)
	check("일시 정지 열림", hud.pause_panel.visible and paused)
	await click_at(center_of(hud.pause_panel))
	check("일시 정지 창 안 클릭 → 그대로", hud.pause_panel.visible)
	await click_at(await find_empty_spot())
	check("일시 정지 밖 클릭 → 닫힘", not hud.pause_panel.visible and not paused)

	# ── 산장 관리 ──
	hud.open_lodge_panel()
	await frames(3)
	check("산장 관리 열림", hud.lodge_panel.visible)
	await click_at(center_of(hud.lodge_panel))
	check("산장 창 안 클릭 → 그대로", hud.lodge_panel.visible)
	await click_at(await find_empty_spot(), MOUSE_BUTTON_RIGHT)
	check("산장 창 밖 우클릭 → 닫힘", not hud.lodge_panel.visible and not paused)

	# ── 주머니: HUD 주머니 버튼을 다시 눌러도 깜빡 닫혔다 열리지 않음 ──
	hand.open_pocket()
	await frames(3)
	check("주머니 열림", hand.pocket_panel.visible)
	var dest_before: Vector3 = game.player.global_position
	await click_at(hud.moon.storage_btn.get_global_rect().get_center())
	check("주머니 버튼 클릭 → 열린 채 유지", hand.pocket_panel.visible)
	# 일시 정지를 주머니 위에 열면 밖 클릭은 맨 위(일시 정지)만 닫는다
	hud._toggle_pause()
	await frames(3)
	await click_at(await find_empty_spot())
	check("겹친 창: 밖 클릭은 맨 위 일시 정지만 닫음", not hud.pause_panel.visible and hand.pocket_panel.visible)
	await click_at(await find_empty_spot())
	check("주머니 밖 클릭 → 닫힘", not hand.pocket_panel.visible and not paused)
	await frames(10)
	check("창을 닫은 클릭은 월드 이동으로 새지 않음", game.player.global_position.distance_to(dest_before) < 0.05)

	# ── 손님 대화 ──
	var events = game.guest_events
	var profile: Dictionary = Profiles.all_profiles()[0]
	profile["character_id"] = profile["id"]
	events._on_batch([profile])
	events.admit(profile)
	var uid: int = int(profile["visit_uid"])
	game.guest_ui.open_conversation(uid)
	await frames(30)
	check("손님 대화 열림", game.guest_ui.dialogue_active and paused)
	var pres = game.guest_ui.presenter
	await click_at(pres.panel.get_global_transform() * (pres.panel.size * 0.5))
	check("대화 패널 위 클릭 → 그대로", game.guest_ui.dialogue_active)
	await click_at(corner)
	check("대화 밖 클릭 → 닫힘", not game.guest_ui.dialogue_active)

	print("RESULT %d/%d" % [total - failures, total])
	quit(1 if failures > 0 else 0)
