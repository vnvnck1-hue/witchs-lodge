extends SceneTree
## 대화 중 얻은 카드 보여 주기(card_spotlight.gd) 검증(헤드리스).
## 대화 중 카드를 얻으면 대화 패널 오른쪽 위(대답 열)에 대화의 막·패널보다 위 층으로 크게 떠 있고, 마우스를 올리면 툴팁이 뜨며,
## 시간이 지나도 대화가 끝날 때까지 손패로 가지 않다가, '이야기 이어 듣기' → '대화 마치기'로 대화가 끝나야 손패로 들어가는지 확인한다.
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_dialogue_card_spotlight.gd

const Profiles := preload("res://scripts/ui/guest_profiles.gd")
const CardViewScript := preload("res://scripts/ui/card_view.gd")

var game
var failures := 0
var total := 0


func _initialize() -> void:
	create_timer(60.0, true, false, true).timeout.connect(func(): print("FAIL timeout"); quit(1))
	_run.call_deferred()


func check(name: String, ok: bool, detail := "") -> void:
	total += 1
	if not ok: failures += 1
	print(("PASS " if ok else "FAIL ") + name + ("  — " + detail if detail != "" else ""))


func frames(n := 2) -> void:
	for i in n: await process_frame


func wait(sec: float) -> void:
	await create_timer(sec, true, false, true).timeout


func mouse(at: Vector2) -> void:
	var m := InputEventMouseMotion.new()
	m.position = at
	m.global_position = at
	root.push_input(m, true)
	await frames(1)


## 지금 손패 구역으로 들어오는 낱장 카드 하나를 고른다(시간대 규칙 때문에 주머니로 가는 카드는 건너뛴다)
func add_to_hand(ids: Array) -> String:
	for id in ids:
		if not game.cards.defs.has(id) or game.cards.stackable(id): continue
		var zone: String = game.cards.add(id, 1)
		if zone == "hand": return id
	return ""


func _run() -> void:
	root.size = Vector2i(1774, 887)
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await frames(12)
	game.session.set_process(false)
	var ui = game.guest_ui
	var hand = game.hud.card_hand
	var spot = hand.spotlight

	# 대화 전에 목재 한 장(스택)을 손패에 넣어 두고 공개 연출이 끝나길 기다린다
	game.cards.add("timber", 1)
	await wait(1.6)
	check("대화 전 획득은 기존 공개 연출(스포트라이트 없음)", not spot.holding())

	var profile: Dictionary = Profiles.all_profiles()[0]
	profile["character_id"] = profile["id"]
	game.guest_events._on_batch([profile])
	game.guest_events.admit(profile)
	ui.open_conversation(int(profile["visit_uid"]))
	await frames(30)
	ui.advance_dialogue()
	await frames(20)
	ui.choose(0)
	await frames(20)
	check("대답 단계", ui.dialogue_active and ui.dialogue_phase == "reply")

	var id := add_to_hand(["old_spellbook", "poison_mushroom", "wolf_blood", "hunter", "lumberjack", "moonlit_charm"])
	check("대화 중 손패로 오는 카드 획득", id != "", id)
	await frames(2)
	check("스포트라이트에 한 장", spot.items.size() == 1 and spot.items[0]["kind"] == "hand")
	var v = spot.items[0]["v"] if spot.holding() else null
	check("카드가 대화 막·패널·조작부보다 위 층", v != null and v.get_parent() == spot.root and spot.layer > ui.controls_layer.layer and spot.layer > ui.shade_layer.layer)
	check("손패 부채꼴 자리를 차지하지 않음", v != null and not hand.rest.has(v.uid))

	await wait(1.0)
	var rect: Rect2 = spot.items[0]["rect"]
	var stage = ui.presenter.stage
	var text_end: float = stage.position.x + (524.0 + 580.0) * stage.scale.x
	var next_rect: Rect2 = ui.next_button.get_global_rect()
	check("자리 잡음(등장 연출 완료)", spot.items[0]["landed"] and v.pos.distance_to(v.t_pos) < 4.0, str(v.pos))
	check("표시 위치: 대사 글 열 오른쪽", rect.position.x >= text_end, "%s vs %.1f" % [rect, text_end])
	check("표시 위치: '이야기 이어 듣기' 버튼 위", rect.end.y <= next_rect.position.y + 1.0, "%s vs %s" % [rect, next_rect])
	check("화면 안", rect.position.y >= 0.0 and rect.end.x <= root.size.x)
	check("크게 보임(손패 카드의 1.6배 이상)", v.scl >= 1.6, "scl %.2f" % v.scl)
	check("완전히 보임(투명·어둡게 하지 않음)", is_equal_approx(v.modulate.a, 1.0) and v.modulate.r >= 0.99)

	await mouse(rect.get_center())
	await wait(0.4)
	var tip: Control = hand.tooltip
	check("마우스 올림 → 툴팁", tip.visible and tip.get_parent() == spot.root, str(tip.get_parent()))
	check("툴팁 내용", hand.tip_title.text.begins_with(game.cards.def(id).get("name", id)) and hand.tip_use.text.contains("대화를 마치면"), hand.tip_title.text)
	check("툴팁이 카드와 겹치지 않음", not tip.get_global_rect().intersects(rect.grow(-2.0)))
	# 사용자 지적 2026-10-20: 크게 띄운 카드의 그림자가 툴팁·아래 대답 버튼을 덮지 않는다
	check("띄운 카드는 그림자 없음(툴팁·버튼이 깨끗함)", v.shadow_mul == 0.0 and v.shadow.modulate.a < 0.01, "a %.2f" % v.shadow.modulate.a)
	check("툴팁이 카드보다 위에 그려짐", tip.get_index() == spot.root.get_child_count() - 1 and tip.get_index() > v.get_index())
	await mouse(Vector2(40, 40))
	await wait(0.2)
	check("마우스를 떼면 툴팁 닫힘·제자리", not tip.visible and tip.get_parent() == hand)

	await wait(2.5)
	check("시간이 지나도 대화 중엔 손패로 가지 않음", spot.items.size() == 1 and v.get_parent() == spot.root and v.mode == CardViewScript.Mode.REVEAL)

	game.cards.add("timber", 1)
	await frames(2)
	check("스택 증가도 복제본으로 함께 보여 줌", spot.items.size() == 2 and spot.items[1]["kind"] == "stack")
	await wait(0.8)
	check("두 장이 겹치지 않게 나란히", not spot.items[0]["rect"].intersects(spot.items[1]["rect"].grow(-2.0)))

	ui.advance_dialogue()   # 이야기 이어 듣기 → 마무리 대사
	await frames(10)
	check("마무리 대사 단계에도 유지", ui.dialogue_active and spot.items.size() == 2)
	ui.advance_dialogue()   # 대화 마치기
	await frames(3)
	check("대화가 끝나면 놓아줌", not ui.dialogue_active and not spot.holding())
	check("날아가는 동안 맨 위 층에 남아 밝게", v.get_parent() == spot.root and v.modulate.r > 1.2 and v.mode == CardViewScript.Mode.HAND, "r %.2f" % v.modulate.r)
	# 손패 자리에 닿을 때까지 밝기가 그대로인지 매 프레임 본다
	var bright_until_arrival := true
	var arrived_at := -1.0
	var t0 := Time.get_ticks_msec()
	while arrived_at < 0.0 and Time.get_ticks_msec() - t0 < 3000:
		await process_frame
		if v.pos.distance_to(v.t_pos) > hand.CH * 0.08:
			if v.modulate.r < 1.2: bright_until_arrival = false
		else:
			arrived_at = Time.get_ticks_msec() / 1000.0
	check("손패 자리에 도착할 때까지 어두워지지 않음", bright_until_arrival and arrived_at > 0.0)
	await wait(0.45)
	var mid: float = v.modulate.r
	check("도착한 뒤에야 천천히 가라앉는 중", mid < 1.25 and mid > 1.02 and v.get_parent() == spot.root, "r %.2f" % mid)
	await wait(1.0)
	check("다 가라앉으면 손패 층·기본 밝기", v.get_parent() == hand.cards_root and is_equal_approx(v.modulate.r, 1.0) and spot.landing_count() == 0, "r %.2f" % v.modulate.r)
	await wait(0.2)
	var timber_view = null
	for e in game.cards.hand():
		if e["id"] == "timber": timber_view = hand.views.get(e["uid"])
	check("손패에 들어와 부채꼴에 자리", v.mode == CardViewScript.Mode.HAND and hand.rest.has(v.uid) and v.pos.distance_to(hand.rest[v.uid]["pos"]) < 6.0, str(v.pos))
	check("손패 크기로 돌아옴", absf(v.scl - 1.0) < 0.05, "scl %.2f" % v.scl)
	check("손패에 돌아오면 그림자도 되살아남", v.shadow_mul == 1.0 and v.shadow.modulate.a > 0.3, "a %.2f" % v.shadow.modulate.a)
	check("목재 스택 ×2", timber_view != null and timber_view.badge.text == "×2", timber_view.badge.text if timber_view else "")
	check("복제본 정리", spot.root.get_children().filter(func(c): return c is CardViewScript).is_empty())

	print("RESULT %d/%d" % [total - failures, total])
	quit(1 if failures > 0 else 0)
