extends SceneTree
## 에린 대화 창 초상 모션 실제 렌더 캡처(docs/erin-portrait-motion.md).
## 창을 띄우는 이유: 셰이더 컴파일 오류와 실제 변형 모양(가슴 모핑 진동·아이들링)은 헤드리스 더미 렌더러로 볼 수 없다.
## 등장 뒤 여러 시각의 초상 영역을 찍고, 프레임 사이 픽셀 차이가 있는지(움직였는지) PASS/FAIL 로 적는다.
## 실행(프로젝트 루트): .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_portrait_motion.gd
## 결과: res://screenshots/erin-portrait-motion/t<초>.png, full-*.png, RESULT n/m

const Profiles := preload("res://scripts/ui/guest_profiles.gd")
const OUT := "res://screenshots/erin-portrait-motion/"
const TIMES := [0.12, 0.28, 0.45, 0.62, 0.85, 1.4, 3.0, 6.0]

var game
var passed := 0
var total := 0


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	create_timer(90.0, true, false, true).timeout.connect(func(): print("TIMEOUT"); quit(2))
	_run.call_deferred()


func check(ok: bool, label: String, detail := "") -> void:
	total += 1
	if ok: passed += 1
	print(("PASS " if ok else "FAIL ") + label + ("  — " + detail if detail != "" else ""))


func frames(n := 2) -> void:
	for i in n: await process_frame


func diff(a: Image, b: Image) -> float:
	var n := 0
	var s := 0.0
	for y in range(0, a.get_height(), 3):
		for x in range(0, a.get_width(), 3):
			var ca := a.get_pixel(x, y)
			var cb := b.get_pixel(x, y)
			s += absf(ca.r - cb.r) + absf(ca.g - cb.g) + absf(ca.b - cb.b)
			n += 1
	return s / maxf(float(n), 1.0)


func _run() -> void:
	root.size = Vector2i(1774, 887)
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await frames(12)
	game.session.set_process(false)
	game.world.day_cycle.set_mode("day")
	var events = game.guest_events
	var profile: Dictionary = Profiles.guest_profile("erin")
	events._on_batch([profile])
	events.admit(profile)
	game.guest_arrival.finish()
	await frames(2)
	var pres = game.guest_ui.presenter
	game.guest_ui.open_conversation(int(profile["visit_uid"]))
	var t0 := Time.get_ticks_msec()
	var shots: Array[Image] = []
	var area := Rect2i()
	for i in TIMES.size():
		var target: float = float(TIMES[i])
		while (Time.get_ticks_msec() - t0) / 1000.0 < target:
			await process_frame
		await RenderingServer.frame_post_draw
		if i == 0:
			var r: Rect2 = pres.portrait.get_global_rect().grow(8)
			area = Rect2i(r)
		var full := root.get_texture().get_image()
		var img := full.get_region(area)
		img.save_png(ProjectSettings.globalize_path(OUT + "t%.2f.png" % target))
		if i == 0 or i == TIMES.size() - 1:
			full.save_png(ProjectSettings.globalize_path(OUT + "full-%.2f.png" % target))
		shots.append(img)
		print("CAPTURE t%.2f appear=%.2f" % [target, float(pres.portrait_material.get_shader_parameter("appear"))])
	check(shots.size() == TIMES.size(), "초상 영역 %d장 캡처" % shots.size())
	var opaque := 0
	var last: Image = shots.back()
	for y in range(0, last.get_height(), 4):
		for x in range(0, last.get_width(), 4):
			if last.get_pixel(x, y).a > 0.5: opaque += 1
	check(opaque > 200, "초상이 실제로 그려짐(셰이더 컴파일 실패면 분홍/빈 영역)", "opaque samples=%d" % opaque)
	# 등장 직후 연속 프레임은 가슴 진동으로 서로 달라야 하고, 가라앉은 뒤(3초·6초)의 아이들링 차이는 그보다 작아야 한다
	var early := diff(shots[1], shots[2])
	var late := diff(shots[6], shots[7])
	check(early > 0.0005, "등장 0.28→0.45초 사이 초상이 변형됨(가슴 모핑 진동)", "mean diff=%.5f" % early)
	check(late > 0.00005, "등장 뒤 3→6초 사이에도 조금 움직임(아이들링)", "mean diff=%.5f" % late)
	# 가슴 영역 3배 확대 컷(등장 0.28·0.45·0.62초)과 0.28↔0.62초 차이 이미지(8배 증폭): 어디가 움직였는지 눈으로 본다
	var cr := Rect2i(int(area.size.x * 0.22), int(area.size.y * 0.18), int(area.size.x * 0.42), int(area.size.y * 0.3))
	for i in [1, 2, 3]:
		var z := shots[i].get_region(cr)
		z.resize(z.get_width() * 3, z.get_height() * 3, Image.INTERPOLATE_LANCZOS)
		z.save_png(ProjectSettings.globalize_path(OUT + "chest-zoom-t%.2f.png" % float(TIMES[i])))
	var a: Image = shots[1]
	var b: Image = shots[3]
	var dimg := Image.create(a.get_width(), a.get_height(), false, Image.FORMAT_RGB8)
	for y in a.get_height():
		for x in a.get_width():
			var ca := a.get_pixel(x, y)
			var cb := b.get_pixel(x, y)
			var v := clampf((absf(ca.r - cb.r) + absf(ca.g - cb.g) + absf(ca.b - cb.b)) * 8.0 / 3.0, 0.0, 1.0)
			dimg.set_pixel(x, y, Color(v, v, v))
	dimg.save_png(ProjectSettings.globalize_path(OUT + "diff-0.28-0.62.png"))
	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)

