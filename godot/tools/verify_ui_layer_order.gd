extends SceneTree
## 화면 겹침 순서 검증: 월드에 붙는 표시(모닥불 링·체력 바·이름표)가 자원·양 말풍선과 손님 도착 알림보다 아래 층에 있어
## 말풍선을 가리지 않는지 확인한다(사용자 지적 2026-10-20: 모닥불 '꺼짐' 링이 손님 말풍선을 가림).
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_ui_layer_order.gd

var failures := 0
var total := 0


func check(name: String, ok: bool, detail := "") -> void:
	total += 1
	if not ok:
		failures += 1
	print(("PASS " if ok else "FAIL ") + name + ("  — " + detail if detail != "" else ""))


func _initialize() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	_run.call_deferred()


func _layer_of(n: Node) -> int:
	while n != null:
		if n is CanvasLayer:
			return (n as CanvasLayer).layer
		n = n.get_parent()
	return 0


func _find(cls_name: String) -> Node:
	for n in root.find_children(cls_name, "", true, false):
		return n
	return null


func _run() -> void:
	while current_scene == null or current_scene.get("hud") == null:
		await process_frame
	await process_frame
	var main = current_scene
	var hud = main.hud
	var marks: Control = hud.world_marks
	check("월드 표시 오버레이가 있음", marks != null)
	if marks == null:
		print("RESULT %d/%d" % [total - failures, total])
		quit(1)
		return
	var marks_layer := _layer_of(marks)
	check("월드 표시는 world_marks 모드", marks.world_marks == true)
	check("화면 고정 오버레이는 world_marks 아님", hud.overlay.world_marks == false)
	check("모닥불 링 판정 함수 유지", hud.overlay.has_method("campfire_gauge_visible") and marks.has_method("campfire_gauge_visible"))
	for pair in [["CarryBubble", "자원 말풍선"], ["LambBubble", "양 말풍선"], ["GuestArrival", "손님 도착 알림"]]:
		var n := _find(pair[0])
		if n == null:
			check("%s 층 찾기" % pair[1], false, pair[0])
			continue
		check("월드 표시(%d) < %s(%d)" % [marks_layer, pair[1], _layer_of(n)], marks_layer < _layer_of(n))
	check("월드 표시(%d) < HUD(%d)" % [marks_layer, hud.layer], marks_layer < hud.layer)
	check("월드 표시(%d) > 화면 보정 PostGrade(1)" % marks_layer, marks_layer > 1)
	print("RESULT %d/%d" % [total - failures, total])
	quit(1 if failures > 0 else 0)
