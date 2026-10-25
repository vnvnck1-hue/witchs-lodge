extends SceneTree
## 손패 평소 숨김(설명판만 가림)·마우스 접근 시 등장, 손패 뒤 소품 반투명 헤드리스 검증.
## 실행(프로젝트 루트): .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_hand_peek.gd

const CardHand := preload("res://scripts/ui/card_hand.gd")
const Workbench := preload("res://scripts/ui/moon/hand_workbench.gd")
const MoonLayout := preload("res://scripts/ui/moon/moon_layout.gd")

var passed := 0
var total := 0
var game


func check(ok: bool, msg: String) -> void:
	total += 1
	if ok:
		passed += 1
		print("PASS ", msg)
	else:
		print("FAIL ", msg)


func _initialize() -> void:
	create_timer(120.0, true, false, true).timeout.connect(func(): print("FAIL timeout"); quit(1))
	change_scene_to_file("res://scenes/main.tscn")
	run.call_deferred()


func frames(n: int) -> void:
	for i in n:
		await process_frame


func seconds(t: float) -> void:
	await create_timer(t, true, false, true).timeout


func move(at: Vector2) -> void:
	var m := InputEventMouseMotion.new()
	m.position = at
	m.global_position = at
	root.push_input(m, true)
	await frames(1)


## 가운데(부채꼴 맨 아래 중앙) 카드의 실제 바닥선 y
func mid_bottom(hand) -> float:
	var best := INF
	var y := 0.0
	for uid in hand.rest:
		var v = hand.views[uid]
		var dx: float = absf(v.pos.x - hand.size.x * 0.5)
		if dx < best:
			best = dx
			y = v.pos.y
	return y


func run() -> void:
	while current_scene == null or current_scene.get("cards") == null:
		await process_frame
	game = current_scene
	root.size = Vector2i(1600, 900)
	game.session.set_process(false)
	await frames(10)
	var hand = game.hud.card_hand
	var decor: Control = game.hud.moon.get_node_or_null("HandWorkbench")
	check(decor != null, "HandWorkbench 노드 존재")
	game.grant_starter_cards(false)
	for id in ["timber", "wool", "raw_meat"]:
		game.cards.add(id)
	await seconds(2.5)   # 새 카드 공개 연출이 끝나 손패에 내려앉을 때까지

	# 1) 평소: 마우스가 손패 밖이면 설명판 아래만 가리고 제목·일러스트는 보인다
	await move(Vector2(800, 120))
	await seconds(1.2)
	check(hand.rest.size() >= 5, "손패 %d장 구성" % hand.rest.size())
	check(hand.peek < 0.01, "마우스가 멀면 손패가 숨은 상태(peek=%.3f)" % hand.peek)
	var s: float = MoonLayout.ui_scale(hand.size)
	var hidden_bottom := mid_bottom(hand)
	var visible_frac: float = (hand.size.y - (hidden_bottom - hand.CH)) / hand.CH
	check(absf(visible_frac - CardHand.PEEK_VISIBLE) < 0.06, "숨김 상태에서 가운데 카드가 PEEK_VISIBLE 만큼 보임(%.2f)" % visible_frac)
	check(visible_frac >= 0.76, "숨김 상태에서도 일러스트(설명판 위 카드 위 75%%)가 다 보임(%.2f)" % visible_frac)
	check(decor != null and absf(decor.modulate.a - Workbench.IDLE_ALPHA) < 0.02, "평소 소품이 반투명(a=%.2f)" % (decor.modulate.a if decor else -1.0))

	# 2) 숨어 있어도 보이는 윗부분은 집을 수 있다
	var any_uid: int = hand.rest.keys()[hand.rest.size() / 2]
	var r: Dictionary = hand.rest[any_uid]
	var top_half: Vector2 = r["pos"] + Vector2(0, -hand.CH * 0.8).rotated(deg_to_rad(r["rot"]))
	check(top_half.y < hand.size.y, "가운데 카드 윗부분이 화면 안")

	# 3) 손패 쪽으로 마우스를 옮기면 자연스럽게(여러 프레임에 걸쳐) 올라온다
	var shown_bottom: float = MoonLayout.to_view(Vector2(800, CardHand.CARD_BOTTOM), Vector2(0.5, 1), hand.size).y
	await move(Vector2(hand.size.x * 0.5 + hand.CW * 2.5, hand.size.y - 20.0 * s))
	await frames(2)
	var mid_peek: float = hand.peek
	check(mid_peek > 0.0, "손패 쪽에 오면 올라오기 시작(peek=%.3f)" % mid_peek)
	await seconds(1.0)
	check(hand.peek > 0.99, "곧 다 올라옴(peek=%.3f)" % hand.peek)
	check(absf(mid_bottom(hand) - shown_bottom) < 30.0 * s, "다 올라오면 기존 손패 위치(바닥 %.0f ≈ %.0f)" % [mid_bottom(hand), shown_bottom])
	check(decor != null and decor.modulate.a > 0.98, "손패가 올라오면 소품도 또렷(a=%.2f)" % (decor.modulate.a if decor else -1.0))

	# 4) 올라온 손패 위(카드 윗부분)를 훑는 동안에는 내려가지 않는다
	var up_r: Dictionary = hand.rest[any_uid]
	await move(up_r["pos"] + Vector2(0, -hand.CH * 0.9))
	await seconds(0.8)
	check(hand.peek > 0.99, "올라온 카드 윗부분 위에서는 유지(peek=%.3f)" % hand.peek)

	# 5) 손패를 확인하고 떠나도 1초 동안은 숨지 않고, 그 뒤에 다시 숨는다
	await move(Vector2(800, 120))
	await frames(2)
	check(hand.peek > 0.95, "떠난 직후에는 머묾(peek=%.3f)" % hand.peek)
	await seconds(0.8)
	check(hand.peek > 0.99, "떠난 뒤 0.8초에도 손패가 그대로(peek=%.3f)" % hand.peek)
	check(is_equal_approx(CardHand.PEEK_LINGER, 1.0), "확인 뒤 유지 시간 1초")
	await seconds(2.0)
	check(hand.peek < 0.01, "잠시 뒤 다시 숨음(peek=%.3f)" % hand.peek)
	check(absf(mid_bottom(hand) - hidden_bottom) < 4.0, "숨김 위치로 돌아옴")
	check(decor != null and absf(decor.modulate.a - Workbench.IDLE_ALPHA) < 0.02, "소품도 다시 반투명")

	# 6) 확대(개발용 강제 확대 포함) 중에는 손패가 올라와 있다
	hand.set_hover(any_uid, true)
	await seconds(0.8)
	check(hand.peek > 0.99, "카드 확대 중에는 손패가 올라옴(peek=%.3f)" % hand.peek)
	hand.set_hover(any_uid, false)
	await move(Vector2(800, 110))
	await seconds(2.5)

	# 7) 손패 좌우 바깥(창고·산장 관리 버튼 쪽) 아래에서는 올라오지 않는다
	await move(Vector2(30.0, hand.size.y - 10.0))
	await seconds(0.6)
	check(hand.peek < 0.01, "손패 폭 밖 화면 아래에서는 숨은 채(peek=%.3f)" % hand.peek)
	finish()


func finish() -> void:
	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)
