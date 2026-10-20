extends SceneTree
## 에린 흐름 실제 플레이 확인(사용자 요청 2026-10-20): 실제 main.tscn · 실제 카드 사용 · 실제 입실 연출 시간 · 실제 마우스 클릭으로
## 술 3장 → 에린이 맨 먼저 찾아와 바로 말을 걺 → '술이 떨어졌다' 대답에도 카드 → 밤을 지나 다음 날에도 산장에 머묾 →
## 잡담 → 술 3장이면 대화·알림 없이 카드가 손패로 → 산장 관리 에린 칸의 술잔 카운터를 확인하고 장면마다 찍는다.
## 창을 띄우는 이유: 입실 연출·말풍선·대화창·술잔 그림을 실제 렌더 결과로 남기기 위해(로직은 tools/tavern_check.gd 가 헤드리스로 본다).
## 실행(프로젝트 루트): .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_erin_flow.gd
## 결과: res://screenshots/erin/flow/<장면>.png, PASS/FAIL 줄과 RESULT n/m

const OUT := "res://screenshots/erin/flow/"
const SessionScript := preload("res://scripts/game/game_session.gd")
const Cfg := preload("res://scripts/config.gd")

var game
var passed := 0
var total := 0


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	create_timer(120.0, true, false, true).timeout.connect(func(): print("TIMEOUT"); quit(1))
	_run.call_deferred()


func check(ok: bool, label: String, detail := "") -> void:
	total += 1
	if ok: passed += 1
	print(("PASS " if ok else "FAIL ") + label + ("  — " + detail if detail != "" else ""))


func frames(n: int) -> void:
	for i in n:
		await process_frame


func shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + name))


func click(c: Control) -> void:
	var at := c.get_global_rect().get_center()
	var move := InputEventMouseMotion.new()
	move.position = at
	move.global_position = at
	root.push_input(move, true)
	await frames(2)
	for pressed in [true, false]:
		var e := InputEventMouseButton.new()
		e.position = at
		e.global_position = at
		e.button_index = MOUSE_BUTTON_LEFT
		e.pressed = pressed
		root.push_input(e, true)
		await frames(2)


## 실제 카드 사용: 손패에 흑맥주 통을 넣고 판정기(resolver)로 쓴다(종족 카드지만 술로 센다).
func drink() -> bool:
	game.race_cards.night.clear()   # 흑맥주는 하루 한 번 규칙: 시험에서는 매번 새로 딴다
	while game.cards.hand_full():
		game.cards.entries.erase(game.cards.hand()[0])
	game.cards.add("dark_ale", 1, "", "hand")
	await frames(1)
	var uid := -1
	for e in game.cards.entries:
		if e["id"] == "dark_ale" and e["zone"] == "hand":
			uid = maxi(uid, e["uid"])
	var at: Vector2 = game.world.camera.unproject_position(game.player.global_position)
	var r: Dictionary = game.resolver.commit(uid, at)
	await frames(2)
	return r.get("ok", false)


func erin_visits() -> Array:
	return game.guest_events.visits.filter(func(v): return v.profile.character_id == "erin")


func _run() -> void:
	root.size = Vector2i(1600, 900)
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(20)
	game.waves.set_process(false)
	var tv = game.tavern
	check(game.session.state == SessionScript.State.PREP, "1일차 낮에서 시작")

	# ── 1. 술 3장 → 에린이 지금 바로, 맨 먼저 찾아옴
	var ok := true
	for i in 3:
		ok = ok and await drink()
	var visits := erin_visits()
	check(ok and tv.erin_waiting and visits.size() == 1, "흑맥주 통 3장을 실제로 쓰면 에린이 바로 찾아옴", "drinks=%d" % tv.drinks)
	var arrive_t: float = game.session.play_time
	var erin: Dictionary = visits[0] if not visits.is_empty() else {}
	check(not erin.is_empty() and game.guest_arrival.active and game.guest_arrival.profiles[0].character_id == "erin", "입실 연출의 첫 손님이 에린")
	await frames(12)
	await shot("01-arrival-intro.png")
	# 실제 연출 시간 그대로 기다린다(클릭으로 넘기지 않음)
	var waited := 0
	while not erin.is_empty() and not erin.admitted and waited < 900:
		await frames(1)
		waited += 1
	var admit_t: float = game.session.play_time
	check(erin.get("admitted", false), "소개 연출이 끝나 에린이 입실", "%.1f초" % (admit_t - arrive_t))
	await frames(3)
	var talk_t: float = game.session.play_time
	check(game.guest_events.pending_events().has(erin) and game.guest_ui.notification.visible and game.guest_ui.notification_uid == erin.uid,
		"입실하자마자 말풍선(대기 없음)", "입실 후 %.2f초" % (talk_t - admit_t))
	await shot("02-erin-speaks.png")

	# ── 2. 실제 클릭: 말풍선 → 대답하기 → '술이 떨어졌다' → 카드
	var before: int = game.cards.count_of("drunken_erin")
	await click(game.guest_ui.notification)
	await frames(20)
	check(game.guest_ui.dialogue_active and game.guest_ui.active_uid == erin.uid, "말풍선을 누르면 에린과 대화가 열림")
	await click(game.guest_ui.next_button)
	await frames(40)
	var decline_text: String = game.guest_ui.choice_buttons[1].text if game.guest_ui.choice_buttons[1].get("text") != null else ""
	await shot("03-choices.png")
	await click(game.guest_ui.choice_buttons[1])
	await frames(40)
	await shot("04-decline-reply.png")
	check(game.cards.count_of("drunken_erin") == before + 1 and tv.erin_met, "'술이 떨어졌다'를 골라도 에린 카드 1장", "대답 줄: " + decline_text)
	check("챙겨 왔" in str(game.guest_ui.presenter.get("dialogue_text") if game.guest_ui.presenter.get("dialogue_text") != null else game.guest_ui.transcript.back()),
		"에린이 제 술을 챙겨 왔다고 능청스럽게 받아침", str(game.guest_ui.transcript.back()))
	await click(game.guest_ui.next_button)
	await frames(20)
	await click(game.guest_ui.next_button)
	await frames(20)
	check(not game.guest_ui.dialogue_active and game.guest_events.history.size() >= 1, "대화를 끝까지 마침")

	# ── 3. 손님 무리 정산·낮 끝·밤·다음 날에도 에린은 머묾
	game.session.start_wave()
	await frames(5)
	check(game.session.state == SessionScript.State.COMBAT and erin.present, "밤이 되어도 에린은 산장에 있음")
	game.session._on_wave_cleared()
	game.session._after_clear()
	await frames(10)
	check(game.session.state == SessionScript.State.PREP and game.session.day() == 2 and erin.present and game.guest_events.current_guests().has(erin),
		"다음 날(2일차) 낮에도 에린이 산장에 있음", erin.status)

	# ── 4. 직접 말 걸기: 산장 관리 손님 탭의 '안부 묻기' → 잡담
	game.guest_arrival.finish()
	game.hud.open_lodge_panel(1)
	await frames(10)
	var talk_btn: Button = game.guest_ui.guest_buttons.get(erin.uid)
	check(talk_btn != null and not talk_btn.disabled, "산장 관리 · 에린 칸의 대화 버튼이 눌림", talk_btn.text if talk_btn else "")
	var titles := {}
	for i in 2:
		talk_btn = game.guest_ui.guest_buttons.get(erin.uid)
		if talk_btn == null:
			game.hud.open_lodge_panel(1)
			await frames(6)
			talk_btn = game.guest_ui.guest_buttons.get(erin.uid)
		await click(talk_btn)
		await frames(20)
		titles[erin.story.title] = erin.story.get("special", "")
		if i == 0: await shot("05-chat.png")
		game.guest_ui.close_conversation(true)
		await frames(8)
	check(titles.size() == 2 and titles.values().all(func(s): return s == "erin_chat"), "말을 걸 때마다 서로 다른 잡담", str(titles.keys()))

	# ── 5. 술잔 카운터와 카드 바로 지급
	game.hud.open_lodge_panel(1)
	await frames(6)
	var vis0: int = game.guest_events.visits.size()
	before = game.cards.count_of("drunken_erin")
	game.hud.close_lodge_panel()
	await drink()
	await drink()
	game.hud.open_lodge_panel(1)
	await frames(8)
	var row: Node = game.guest_ui.guest_list.find_child("ErinDrinkMeter", true, false)
	check(row != null and row.get_child(0).filled == 2, "산장 관리 에린 칸 술잔 2/3")
	await frames(30)
	await shot("06-drink-meter.png")
	game.hud.close_lodge_panel()
	await frames(4)
	await drink()
	await frames(30)
	check(game.cards.count_of("drunken_erin") == before + 1 and tv.drinks == 0 and game.guest_events.visits.size() == vis0
		and game.guest_events.pending_events().is_empty() and not game.guest_ui.notification.visible and not game.guest_arrival.active,
		"술 3장째: 방문·말풍선·입실 연출 없이 에린 카드가 바로 손패로")
	await shot("07-card-in-hand.png")
	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)
