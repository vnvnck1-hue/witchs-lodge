extends SceneTree
## 손패 고민 시간(scripts/ui/hand_focus_time.gd) 헤드리스 검증: 손패에 손을 올리면 세상이 1초에 걸쳐 천천히 멈추고,
## 손을 떼면 돌아오는지 · 거의 멈춤 프리셋은 1/40 속도인지 · 손패 UI 는 실제 시간으로 움직이는지 · 실제 게임 장면에서도 같은지.
## 실행(프로젝트 루트): .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_hand_focus_time.gd

const HandTime := preload("res://scripts/ui/hand_focus_time.gd")

var passed := 0
var total := 0


func _check(ok: bool, label: String, detail := "") -> void:
	total += 1
	if ok:
		passed += 1
	print("%s %s%s" % ["PASS" if ok else "FAIL", label, ("  — " + detail) if detail != "" else ""])


## 손패 흉내: 모듈이 보는 것은 hover_uid · drag_uid · modal_open() · game.session.is_over() 뿐이다.
class FakeSession:
	var over := false
	func is_over() -> bool: return over

class FakeGame:
	var session := FakeSession.new()

class FakeHand extends Node:
	var hover_uid := -1
	var drag_uid := -1
	var modal := false
	var game := FakeGame.new()
	func modal_open() -> bool: return modal


func _unit() -> void:
	_check(HandTime.IDS == ["freeze", "crawl", "off"] and HandTime.DEFAULT_ID == "freeze", "프리셋 3개(멈춤·거의 멈춤·끔), 기본은 멈춤")
	_check(float(HandTime.TARGETS["freeze"]) == 0.0, "멈춤은 속도 0(완전 정지)")
	var crawl := float(HandTime.TARGETS["crawl"])
	_check(crawl > 0.0 and crawl <= 0.05, "거의 멈춤은 0 보다 크고 1/20 이하(시간이 거의 흐르지 않는 듯)", str(crawl))
	_check(float(HandTime.TARGETS["off"]) == 1.0 and HandTime.SLOW_IN == 1.0, "끔은 평소 속도, 느려지는 데 1초")
	_check(HandTime.is_tool_run() and not HandTime.tool_allowed, "--script 도구 실행에서는 기본으로 늦추지 않음(다른 검증·캡처가 멈추지 않게)")
	var hand := FakeHand.new()
	root.add_child(hand)
	var node0 := HandTime.new()
	node0.hand = hand
	root.add_child(node0)
	Engine.time_scale = 1.0
	HandTime.apply("freeze")
	hand.hover_uid = 1
	node0.step(1.0)
	_check(Engine.time_scale == 1.0 and not HandTime.engaged, "도구 허용 전에는 호버해도 시간 그대로")
	hand.hover_uid = -1
	node0.queue_free()
	HandTime.tool_allowed = true
	var node := HandTime.new()
	node.settings_path = "user://verify_hand_focus_time.cfg"
	node.hand = hand
	root.add_child(node)
	Engine.time_scale = 1.0
	HandTime.apply("freeze")
	# 손을 올리면 1초에 걸쳐 단조롭게 느려져 0 에 닿는다
	hand.hover_uid = 7
	var scales: Array = []
	var monotonic := true
	for i in 20:
		node.step(0.05)
		scales.append(Engine.time_scale)
		if scales.size() > 1 and scales[-1] > scales[-2] + 1e-6:
			monotonic = false
	_check(scales[0] < 1.0 and scales[0] > 0.9, "올린 직후(0.05초)는 아직 거의 평소 속도 — 천천히 느려지기 시작", "%.3f" % scales[0])
	_check(absf(scales[9] - 0.5) < 0.02, "0.5초에는 절반 속도(smoothstep 가운데)", "%.3f" % scales[9])
	_check(monotonic, "느려지는 동안 속도가 되돌아가지 않음(단조 감소)")
	_check(Engine.time_scale == 0.0 and HandTime.engaged, "1초 뒤 완전히 멈춤(Engine.time_scale 0)")
	node.step(0.5)
	_check(Engine.time_scale == 0.0, "손을 계속 올려 두면 멈춘 채로 유지")
	# 세상이 멈춰도 UI 는 실제 시간을 받는다
	var ui := HandTime.ui_delta(0.0)
	_check(ui > 0.0 and ui <= 0.1, "멈춘 동안 ui_delta(0) 는 실제 경과 시간(> 0)을 돌려줌", "%.4f" % ui)
	# 손을 떼면 0.35초 안에 평소 속도로
	hand.hover_uid = -1
	node.step(0.1)
	var mid := Engine.time_scale
	_check(mid > 0.0 and mid < 1.0, "손을 뗀 0.1초 뒤에는 돌아오는 중", "%.3f" % mid)
	node.step(HandTime.SPEED_OUT)
	_check(Engine.time_scale == 1.0 and not HandTime.engaged, "손을 뗀 뒤 0.35초 안에 평소 속도로 돌아오고 놓아줌")
	_check(HandTime.ui_delta(0.0123) == 0.0123, "평소에는 ui_delta 가 받은 delta 그대로")
	# 끌고 있는 동안에도 늦춘다
	hand.drag_uid = 7
	node.step(1.0)
	_check(Engine.time_scale == 0.0, "카드를 끌고 있는 동안에도 멈춤")
	hand.drag_uid = -1
	node.step(1.0)
	# 거의 멈춤 프리셋
	HandTime.apply("crawl")
	hand.hover_uid = 3
	node.step(1.0)
	_check(is_equal_approx(Engine.time_scale, crawl), "거의 멈춤: 1초 뒤 속도 %.3f(1/40)" % crawl, "%.4f" % Engine.time_scale)
	hand.hover_uid = -1
	node.step(1.0)
	_check(Engine.time_scale == 1.0, "거의 멈춤에서 손을 떼면 평소 속도로")
	# 끔
	HandTime.apply("off")
	hand.hover_uid = 3
	node.step(1.0)
	_check(Engine.time_scale == 1.0 and not HandTime.engaged, "끔: 손을 올려도 시간을 건드리지 않음")
	hand.hover_uid = -1
	HandTime.apply("freeze")
	# 창(주머니·판매)·판 종료·일시정지면 늦추지 않는다
	hand.modal = true
	hand.hover_uid = 3
	node.step(1.0)
	_check(Engine.time_scale == 1.0, "주머니·판매 창이 열려 있으면 늦추지 않음")
	hand.modal = false
	hand.game.session.over = true
	node.step(1.0)
	_check(Engine.time_scale == 1.0, "판이 끝나면 늦추지 않음")
	hand.game.session.over = false
	node.step(1.0)
	_check(Engine.time_scale == 0.0, "다시 늦춤(상태 복구 확인)")
	paused = true
	node._process(0.0)
	_check(Engine.time_scale == 1.0 and not HandTime.engaged, "일시정지가 켜지면 즉시 평소 속도로 놓아줌")
	paused = false
	hand.hover_uid = -1
	node.step(1.0)
	# 다른 도구가 바꿔 둔 배율(촬영 3배) 위에 곱하고, 놓을 때 그 값으로 돌려준다
	Engine.time_scale = 3.0
	hand.hover_uid = 3
	node.step(0.5)
	_check(absf(Engine.time_scale - 1.5) < 0.06, "다른 도구의 3배 위에 곱함(0.5초 → 1.5배)", "%.3f" % Engine.time_scale)
	hand.hover_uid = -1
	node.step(1.0)
	_check(Engine.time_scale == 3.0, "놓을 때 원래 3배로 돌려줌")
	Engine.time_scale = 1.0
	# 저장·불러오기·순환
	HandTime.apply("freeze")
	_check(node.cycle() == "crawl" and node.cycle() == "off" and node.cycle() == "freeze", "F12 순환: 멈춤 → 거의 멈춤 → 끔 → 멈춤")
	node.set_preset("crawl")
	var cfg := ConfigFile.new()
	_check(cfg.load(node.settings_path) == OK and cfg.get_value("cards", "hand_time", "") == "crawl", "선택이 settings [cards] hand_time 에 저장됨")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(node.settings_path))
	HandTime.apply("freeze")
	node.queue_free()
	hand.queue_free()


func _sources() -> void:
	var want := {
		"res://scripts/ui/card_hand.gd": ["HandTime.ui_delta(delta)", "set_ignore_time_scale(true)", "false, false, true).timeout"],
		"res://scripts/ui/card_lift.gd": ["ui_delta(delta)"],
		"res://scripts/ui/card_fx.gd": ["HandTime.ui_delta(delta)", "set_ignore_time_scale(true)"],
		"res://scripts/ui/card_spotlight.gd": ["ui_delta(delta)", "set_ignore_time_scale(true)"],
		"res://scripts/audio/sound_bank.gd": ["ui_delta(delta)"],
		"res://scripts/visual/player_camera.gd": ["ui_delta(delta)"],
		"res://scripts/visual/spider_visual.gd": ["if delta <= 0.0:"],
		"res://scripts/ui/hud.gd": ["HandFocusTimeSelect", "손패 고민 시간 · F12"],
		"res://scripts/main.gd": ["HandFocusTime", "hand_time.hand = hud.card_hand"],
	}
	for path in want:
		var text := FileAccess.get_file_as_string(path)
		var missing: Array = []
		for needle in want[path]:
			if not needle in text:
				missing.append(needle)
		_check(missing.is_empty(), "%s 보정 코드" % path.get_file(), ", ".join(missing))
	var en: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/i18n/en.json"))
	var keys := ["손패 고민 시간 · F12", "손패 고민 시간: ", "멈춤", "거의 멈춤", "끔"]
	var lacking: Array = []
	for k in keys:
		if not en.has(k):
			lacking.append(k)
	_check(lacking.is_empty(), "영문 사전에 손패 고민 시간 문구 5개", ", ".join(lacking))


## 실제 게임 장면: 손패 카드에 호버를 강제하고 프레임을 돌려 세상이 멈추는지 본다(물리 프레임은 멈추므로 process_frame 으로 센다).
func _scene() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	for i in 40:
		await process_frame
	var game = current_scene
	paused = false
	var node = game.get_node_or_null("HandFocusTime")
	_check(node != null and node.hand == game.hud.card_hand, "게임 장면에 HandFocusTime 모듈이 손패와 연결됨")
	var select = game.hud.find_child("HandFocusTimeSelect", true, false)
	_check(select != null and select.get_item_count() == 3, "일시정지 메뉴에 '손패 고민 시간' 선택 3개")
	HandTime.apply("freeze")
	Engine.time_scale = 1.0
	game.cards.add("timber", 2)
	for i in 150:
		await process_frame   # 공개 연출이 끝나 손패에 자리 잡을 때까지
	var hand = game.hud.card_hand
	var uid: int = game.cards.hand()[0]["uid"]
	hand.set_hover(uid, true)
	await process_frame
	await process_frame
	_check(hand.hover_uid == uid, "손패 카드 호버 강제")
	var t0 := Time.get_ticks_msec()
	var early := -1.0
	while Time.get_ticks_msec() - t0 < 1500 and Engine.time_scale > 0.0:
		await process_frame
		if early < 0.0 and Time.get_ticks_msec() - t0 >= 300:
			early = Engine.time_scale
	_check(early > 0.0 and early < 1.0, "0.3초쯤에는 느려지는 중(0 < 속도 < 1)", "%.3f" % early)
	_check(Engine.time_scale == 0.0, "실제 장면: 호버 1초 뒤 세상이 멈춤", "%.3f" % Engine.time_scale)
	var pos0: Vector2 = hand.views[uid].pos
	for i in 10:
		await process_frame
	_check(hand.views[uid].pos.distance_to(pos0) < 50.0 and hand.views[uid].lift > 0.0, "멈춘 동안에도 손패 카드는 들려 있고 제자리", "lift %.2f" % hand.views[uid].lift)
	hand.set_hover(uid, false)
	hand.hover_uid = -1
	hand._forced_hover = -1
	hand._mouse = Vector2(-9999, -9999)
	t0 = Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 1500 and Engine.time_scale < 1.0:
		await process_frame
	_check(Engine.time_scale == 1.0, "실제 장면: 손을 떼면 평소 속도로", "%.3f" % Engine.time_scale)
	# 일시정지 메뉴를 열면 즉시 놓아준다
	hand.set_hover(uid, true)
	t0 = Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 1500 and Engine.time_scale > 0.0:
		await process_frame
	game.hud._toggle_pause()
	await process_frame
	await process_frame
	_check(paused and Engine.time_scale == 1.0, "일시정지 메뉴를 열면 즉시 평소 속도(일시정지가 대신 멈춤)")
	game.hud._toggle_pause()
	hand.set_hover(uid, false)
	hand.hover_uid = -1
	Engine.time_scale = 1.0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_unit()
	_sources()
	await _scene()
	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)
