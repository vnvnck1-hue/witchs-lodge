extends SceneTree
## 손님 소개 클릭 넘김 + 새끼양 근접 말풍선 검증(창 모드, 실제 마우스 이벤트 주입).
## 실행: godot --path . --script res://tools/verify_guest_click_lamb.gd -- --no-starter-cards
## 결과: res://art_sources/guest-click-lamb-verify.json, res://screenshots/new-cards/05~07*.png

const OUT := "res://screenshots/new-cards/"

var main
var results: Array = []
var failures := 0


func _initialize() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	_run.call_deferred()


func check(name: String, ok: bool, detail := "") -> void:
	results.append({"check": name, "ok": ok, "detail": detail})
	if not ok:
		failures += 1
	print(("  PASS " if ok else "  FAIL ") + name + ("  — " + detail if detail != "" else ""))


func _wait(n: int) -> void:
	for i in n:
		await process_frame


func _shot(name: String) -> void:
	await _wait(3)
	root.get_viewport().get_texture().get_image().save_png(OUT + name + ".png")


func _click(p: Vector2) -> void:
	for pressed in [true, false]:
		var ev := InputEventMouseButton.new()
		ev.button_index = MOUSE_BUTTON_LEFT
		ev.pressed = pressed
		ev.position = p
		ev.global_position = p
		Input.parse_input_event(ev)
	Input.flush_buffered_events()
	await _wait(1)


func _run() -> void:
	while current_scene == null or current_scene.get("session") == null:
		await process_frame
	main = current_scene
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var ga = main.guest_arrival

	# ── 손님 소개: 첫 손님 묶음은 5초에 도착
	var t := 0
	while not (ga.active and ga.phase == "guest") and t < 1200:
		await process_frame
		t += 1
	check("손님 소개 패널 등장", ga.phase == "guest")
	var center: Vector2 = ga.panel.get_global_transform() * (ga.panel.size * 0.5)
	var player_target: Vector3 = main.player.global_position
	await _click(center)
	check("글 출력 전 클릭은 넘기지 않음", ga.phase == "guest" and ga.guest_index == 0, "phase_time=%.2f ready=%.2f" % [ga.phase_time, ga.ready_time])
	while ga.phase == "guest" and ga.phase_time < ga.ready_time + 0.3:
		await process_frame
	await _shot("05-guest-ready-hint")
	check("안내 문구 표시", ga.hint.modulate.a > 0.5, "alpha=%.2f" % ga.hint.modulate.a)
	var shown_for: float = ga.phase_time
	await _click(center)
	check("글 출력 후 클릭하면 바로 다음 동작", ga.phase == "flight", "phase=%s 표시 %.2f초 (자동 %.2f초)" % [ga.phase, shown_for, ga.guest_duration])
	await _wait(5)
	check("패널 클릭이 월드 이동으로 새지 않음", main.player.global_position.distance_to(player_target) < 0.3)

	# ── 새끼양 말풍선
	main.cards.add("lamb")
	var uid := -1
	for e in main.cards.entries:
		if e["id"] == "lamb":
			uid = e["uid"]
	var pasture = main.world.pasture
	var cam: Camera3D = main.world.camera
	main.resolver.commit(uid, cam.unproject_position(Vector3(pasture.rect.get_center().x, 0, pasture.rect.get_center().y)))
	var lamb = pasture.slots.back()
	var bubble = main.get_node("LambBubble")
	await _wait(20)
	check("멀리 있으면 말풍선 없음", not bubble.bubble.visible)
	main.player.global_position = lamb.global_position + Vector3(-1.2, 0, 0.6)
	await _wait(30)
	check("가까이 가면 말풍선 표시", bubble.bubble.visible and bubble.bubble.modulate.a > 0.9, bubble.text.text)
	check("남은 날 안내", bubble.text.text.contains("2일"), bubble.text.text)
	await _shot("06-lamb-bubble-near")
	main.player.global_position = Vector3(-4, 0, 6)
	await _wait(30)
	check("멀어지면 말풍선 사라짐", not bubble.bubble.visible)
	await _shot("07-lamb-bubble-far")

	var out := {"passed": failures == 0, "checks": results.size(), "failures": failures, "results": results}
	var f := FileAccess.open("res://art_sources/guest-click-lamb-verify.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(out, "\t") + "\n")
	print("GUEST_CLICK_LAMB_VERIFY passed=", failures == 0, " checks=", results.size(), " failures=", failures)
	quit(0 if failures == 0 else 1)
