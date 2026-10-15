extends SceneTree
## 카드 효과음 연결 검증: 실제 게임 장면에서 카드 동작마다 선택된 효과음 이벤트가 울리는지 확인한다.
## 실행: godot --headless --path . --script res://tools/verify_card_sfx.gd
var results: Array = []
var failed := false

func _initialize() -> void:
	call_deferred("run")

func check(label: String, passed: bool, detail := "") -> void:
	results.append({"check": label, "passed": passed, "detail": detail})
	failed = failed or not passed
	print(("PASS " if passed else "FAIL ") + label + ("  — " + detail if detail != "" else ""))

func wait_frames(n: int) -> void:
	for i in n: await physics_frame

## 직전 호출 뒤 새로 울린 이벤트를 돌려준다(100ms 중복 억제를 피하려고 잠깐 쉰다)
func fired(bank, before: int) -> String:
	return bank.last_event if bank.play_count > before else "(없음)"

func run() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	await wait_frames(40)
	var game = current_scene
	var bank = game.sounds
	var hand = game.hud.card_hand
	paused = false
	bank.reload_selection()
	var events := ["card_draw", "card_pickup", "card_target", "card_play", "card_cancel", "card_deny", "card_stash", "card_shuffle", "card_inspect"]
	var missing: Array = []
	for e in events:
		if not bank.streams.has(e) or bank.streams[e][0].get_length() <= 0.0 or bank.streams[e][0].get_length() > 0.6:
			missing.append(e)
	check("선택한 카드 효과음 9종이 0.6초 이하 WAV로 로드됨", missing.is_empty(), ",".join(missing))

	# 새 카드 획득 → 들어옴, 가운데 공개 도착 → 뒤집기·확대
	var n: int = bank.play_count
	game.cards.add("timber", 5)
	await wait_frames(3)
	check("새 카드 획득 → 카드 들어옴", bank.last_event == "card_draw" and bank.play_count > n, fired(bank, n))
	n = bank.play_count
	var ok := false
	for i in 120:
		await physics_frame
		if bank.last_event == "card_inspect":
			ok = true
			break
	check("공개 위치 도착 → 카드 뒤집기·확대", ok, fired(bank, n))
	for i in 60: await physics_frame  # 공개가 끝나고 손패로 들어갈 때까지
	await create_timer(0.15).timeout

	# 집어 들기
	var uid: int = game.cards.hand()[0]["uid"]
	n = bank.play_count
	hand.begin_drag(uid)
	check("드래그 시작 → 카드 집어 들기", bank.last_event == "card_pickup", fired(bank, n))
	await create_timer(0.15).timeout

	# 유효 대상(손상된 산장) 위 → 대상 위에 올림 한 번, 같은 대상에서는 반복하지 않음
	game.world.lodge.take_damage(150.0)
	var lodge_pt: Vector2 = game.world.camera.unproject_position(game.world.lodge.global_position + Vector3(0, 2, 0))
	hand.drag_pos = lodge_pt
	n = bank.play_count
	hand._update_drag()
	check("유효 대상에 닿음 → 대상 위에 올림", bank.last_event == "card_target", fired(bank, n) + " / " + str(hand.plan.get("title", hand.plan.get("reason", ""))))
	await create_timer(0.15).timeout
	n = bank.play_count
	hand._update_drag()
	check("같은 대상 위에서는 다시 울리지 않음", bank.play_count == n)

	# 손패 위로 되돌려 놓기 → 취소
	hand.drag_pos = Vector2(hand.size.x * 0.5, hand.size.y - 4.0)
	n = bank.play_count
	hand._end_drag()
	check("손패 위에 놓기 → 취소·복귀", bank.last_event == "card_cancel" and hand.drag_uid == -1, fired(bank, n))
	await create_timer(0.15).timeout

	# 산장에 놓아 사용 → 사용 확정
	hand.begin_drag(uid)
	await create_timer(0.15).timeout
	hand.drag_pos = lodge_pt
	n = bank.play_count
	hand._end_drag()
	check("유효 대상에 놓기 → 카드 사용 확정", bank.last_event == "card_play", fired(bank, n))
	await create_timer(0.15).timeout

	# 쓸 수 없는 곳(산장, 체력 최대) → 사용 불가
	game.world.lodge.hp = game.world.lodge.max_hp
	game.cards.add("timber", 5)
	await wait_frames(3)
	for i in 120: await physics_frame
	uid = game.cards.hand()[0]["uid"]
	hand.begin_drag(uid)
	await create_timer(0.15).timeout
	hand.drag_pos = lodge_pt
	n = bank.play_count
	hand._end_drag()
	check("쓸 수 없는 대상에 놓기 → 사용 불가", bank.last_event == "card_deny", fired(bank, n))
	await create_timer(0.15).timeout

	# 우클릭 취소 경로
	if paused:
		# 멈춘 채면 드래그 자체가 막힌다. 원인을 남기고 풀어서 소리 연결만 확인한다.
		var h = game.hud
		print("WARN 게임이 멈춰 있음 — Esc메뉴=", h.pause_panel.visible, " 산장창=", h.lodge_panel.visible, " 판매창=", hand.sale_panel.visible, " 창고창=", hand.storage_panel.visible, " 종료=", game.session.is_over())
		paused = false
	hand.begin_drag(uid)
	var started: bool = hand.drag_uid == uid
	await create_timer(0.15).timeout
	n = bank.play_count
	hand._cancel_by_player()
	check("우클릭/Esc 취소 → 취소·복귀", bank.last_event == "card_cancel", fired(bank, n) + " / drag_started=" + str(started) + " can_drag=" + str(hand.can_drag()) + " in_views=" + str(hand.views.has(uid)) + " modal=" + str(hand.modal_open()))
	await create_timer(0.15).timeout

	# 창고로 보내기 → 창고 보관, 창고에서 꺼내기 → 손패 정렬 (창고 창이 게임을 멈춘 상태에서도)
	paused = true
	n = bank.play_count
	game.cards.move(uid, "storage")
	await wait_frames(2)
	check("손패 → 창고 → 창고 보관 (정지 중에도)", bank.last_event == "card_stash", fired(bank, n))
	await create_timer(0.15).timeout
	n = bank.play_count
	game.cards.move(uid, "hand")
	await wait_frames(2)
	check("창고 → 손패 → 손패 정렬 (정지 중에도)", bank.last_event == "card_shuffle", fired(bank, n))
	check("정지 중에도 UI 효과음 재생(상점·판매 골드 등)", bank.play("gold_reward"))
	paused = false

	var report := FileAccess.open("res://../output/audio-card-sfx-elevenlabs-v01/game-verification.json", FileAccess.WRITE)
	report.store_string(JSON.stringify({"passed": not failed, "checks": results}, "\t"))
	report.close()
	print("CARD_SFX_VERIFY passed=", not failed)
	quit(1 if failed else 0)
