extends SceneTree
## 프롤로그 모션 코믹스 헤드리스 검증(docs/prologue-motion-comics-design.md §6).
##  1) 타임라인 데이터가 기획·코덱스 요청서의 레이어 id와 맞는지
##  2) 가짜 레이어로 CutView 를 만들어 특정 시각의 레이어 상태(등장 전 알파 0, 이동 완료, 전환)가 기획대로 계산되는지
##  3) 실제 재생: 컷 진행·클릭/Space 다음 컷·퇴장 컷 겹침·Esc 건너뛰기·자막 순서·폴백
##  4) 납품된 매니페스트가 있으면 모든 레이어 id·파일이 있는지, 내보내기 필터에 JSON 이 포함되는지
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_prologue_motion.gd

const PrologueScript := preload("res://scripts/ui/prologue.gd")

## 코덱스 요청서 v02(docs/handoff/codex-prologue-motion-comics-v02.md)의 컷별 레이어 id. 코드의 트랙이 여기 없는 id를 쓰면 실패.
const EXPECTED_IDS := [
	["sky", "village", "smoke", "cliff", "witch_1", "witch_2", "witch_3", "witch_fore", "fore"],
	["sky", "trees_left", "trees_right", "lodge", "window_glow", "smoke", "witch", "lantern_glow", "trunk_left", "trunk_right", "fore", "fog"],
	["wall", "beams", "shafts", "stone", "runes", "eyes_1", "eyes_2", "eyes_3", "fore"],
	["sky_dusk", "sky_night", "forest", "lodge", "window_glow", "traveler_1", "traveler_2", "traveler_fore", "spider_legs", "spider", "eyes_1", "eyes_2", "fore"],
]

var passed := 0
var total := 0


func check(label: String, ok: bool, detail := "") -> void:
	total += 1
	if ok:
		passed += 1
	print("%s %s%s" % ["PASS" if ok else "FAIL", label, "" if detail == "" else " — " + detail])


func _initialize() -> void:
	call_deferred("run")


func frames(n: int) -> void:
	for i in n:
		await process_frame


func fake_manifest(i: int) -> Dictionary:
	var layers := []
	var y := 0
	for id in EXPECTED_IDS[i]:
		var full: bool = id in ["sky", "wall", "sky_dusk", "sky_night", "fog"]
		layers.append({"id": id, "file": "cut%d_%s.png" % [i + 1, id], "pos": [0, 0] if full else [600 + y, 500], "size": [2304, 1296] if full else [200, 160], "depth": 0.5, "blend": "add" if id.ends_with("glow") or id == "runes" or id == "shafts" else "normal"})
		y += 10
	return {"cut": i + 1, "canvas": [2304, 1296], "layers": layers}


func fake_loader(_file: String) -> Texture2D:
	var img := Image.create(4, 4, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.5, 0.3, 0.6, 1.0))
	return ImageTexture.create_from_image(img)


func near(a: float, b: float, eps := 0.02) -> bool:
	return absf(a - b) <= eps


func run() -> void:
	print("── 1. 타임라인 데이터")
	var cuts: Array = PrologueScript.CUTS
	check("컷 수 4 = 자막 4장", cuts.size() == 4 and PrologueScript.SLIDES.size() == 4)
	for i in cuts.size():
		var ids: Array = EXPECTED_IDS[i]
		var bad := []
		var caption_lines := 0
		var has_exit := false
		for tr in cuts[i]["tracks"]:
			if tr.has("layer") and not (tr["layer"] in ids):
				bad.append(tr["layer"])
			if tr["k"] == "caption":
				caption_lines += 1
			if float(tr.get("t0", -1.0)) >= float(cuts[i]["dur"]) - 0.001:
				has_exit = true
		check("컷 %d 트랙의 레이어 id가 요청서와 일치" % (i + 1), bad.is_empty(), ", ".join(bad))
		check("컷 %d 자막 1·2행 등장 시각이 있고 dur 안" % (i + 1), caption_lines == 2)
		check("컷 %d 퇴장 전환 트랙이 dur 이후에 있다" % (i + 1), has_exit)
		var two_lines: bool = (PrologueScript.SLIDES[i][1] as String).split("\n").size() == 2
		check("컷 %d 자막이 2행" % (i + 1), two_lines)

	print("── 2. 가짜 레이어로 특정 시각 상태")
	var views := []
	for i in 4:
		var v = PrologueScript.CutView.new(i, cuts[i])
		root.add_child(v)
		check("컷 %d 레이어 생성(%d장)" % [i + 1, EXPECTED_IDS[i].size()], v.use_layers(fake_manifest(i), fake_loader) and v.layers.size() == EXPECTED_IDS[i].size())
		views.append(v)
	# 컷 1(v02): 전경 마녀는 처음부터, 비탈의 세 마녀는 2.0s 전에는 안 보이고 2.6s에 서 있다가 6.2s에 각자의 길로 멀어진다(작아지고 흐려짐);
	# 카메라가 어깨를 스쳐 마을로 밀고 들어갈 때 전경 마녀가 오른쪽으로 밀린다; 연기가 9.2s에 2.4배로 화면을 덮는다
	var s1 = views[0].evaluate(1.9)["layers"]
	check("컷1 1.9s 비탈의 마녀 셋 알파 0, 전경 마녀는 보임", s1["witch_1"]["alpha"] == 0.0 and s1["witch_3"]["alpha"] == 0.0 and s1["witch_fore"]["alpha"] == 1.0)
	check("컷1 1.9s 절벽 아직 올라오는 중(오프셋 y>0)", s1["cliff"]["off"].y > 0.0 and s1["cliff"]["alpha"] < 1.0)
	s1 = views[0].evaluate(2.6)["layers"]
	check("컷1 2.6s 마녀 셋 서 있음(알파 1, 오프셋 0)", near(s1["witch_1"]["alpha"], 1.0) and s1["witch_2"]["off"] == Vector2.ZERO and s1["witch_fore"]["off"] == Vector2.ZERO)
	s1 = views[0].evaluate(6.3)["layers"]
	check("컷1 6.3s 마녀 셋이 각자의 길로 멀어짐(이동·축소·흐려짐)", s1["witch_1"]["off"].x < -170 and s1["witch_2"]["off"].y < -35 and s1["witch_3"]["off"].x > 60 and near(s1["witch_1"]["scale"], 0.8, 0.03) and near(s1["witch_3"]["alpha"], 0.3, 0.03))
	var e1 = views[0].evaluate(9.2)
	check("컷1 9.2s 연기가 2.4배로 커져 화면을 덮음(T1)", near(e1["layers"]["smoke"]["scale"], 2.4, 0.15) and views[0].finished_exit())
	var e1m = views[0].evaluate(8.9)
	check("컷1 8.9s 연기 빛이 화면 전체를 덮고(≥0.9) 9.2s에 컷이 걷힘", e1m["flash"] >= 0.9 and near(e1m["cut_alpha"], 1.0) and near(e1["cut_alpha"], 0.0))
	check("컷1 8.4s 전환 전에는 연기 빛 0", views[0].evaluate(8.4)["flash"] == 0.0)
	check("컷1 7.5s 카메라가 마을 쪽으로 줌하며 전경 마녀가 오른쪽으로 밀림", views[0].evaluate(7.5)["zoom"] > 1.03 and views[0].evaluate(7.5)["layers"]["witch_fore"]["off"].x > 20.0)
	check("컷1 불티 입자가 있다", views[0].embers != null)
	# 컷 2: 안개가 1초에 걷히고, 숲이 갈라지고, 마녀가 걸어오고, 4.2s에 창문이 켜진다
	var s2 = views[1].evaluate(0.0)["layers"]
	check("컷2 0.0s 안개 알파 1, 창문 글로우 0, 전경 둥치·중경 나무 안쪽", s2["fog"]["alpha"] == 1.0 and s2["window_glow"]["alpha"] == 0.0 and s2["trunk_left"]["off"].x == 140.0 and s2["trunk_right"]["off"].x == -140.0 and s2["trees_left"]["off"].x == 60.0)
	s2 = views[1].evaluate(1.0)["layers"]
	check("컷2 1.0s 마녀 왼쪽 아래(-150,+70)에서 출발, 스케일 1", near(s2["witch"]["off"].x, -150.0, 1.0) and near(s2["witch"]["off"].y, 70.0, 3.0) and near(s2["lantern_glow"]["off"].x, -150.0, 1.0) and near(s2["witch"]["scale"], 1.0))
	s2 = views[1].evaluate(4.1)["layers"]
	check("컷2 4.1s 마녀 길 위쪽 도착(작아짐 0.86), 창문 아직 꺼짐, 둥치 갈라짐", near(s2["witch"]["off"].x, 0.0, 1.0) and near(s2["witch"]["scale"], 0.86, 0.01) and s2["window_glow"]["alpha"] == 0.0 and s2["fog"]["alpha"] == 0.0 and s2["trunk_left"]["off"] == Vector2.ZERO)
	s2 = views[1].evaluate(5.4)["layers"]
	check("컷2 5.4s 창문 켜짐(깜빡임 포함 ≥0.85)·굴뚝 연기 등장", s2["window_glow"]["alpha"] >= 0.85 and s2["smoke"]["alpha"] > 0.5)
	var e2 = views[1].evaluate(9.0)
	check("컷2 9.0s 컷 전체가 위로 밀려 사라짐(T2)", e2["cut_off"].y < -150 and near(e2["cut_alpha"], 0.0))
	# 컷 3: 위에서 내려오고, 룬이 1.8s에 켜지고, 눈빛이 4.0s부터 하나씩, 8.0s 섬광
	var e3 = views[2].evaluate(0.0)
	check("컷3 0.0s 위(-200)에서 시작, 알파 0", e3["cut_off"].y == -200.0 and e3["cut_alpha"] == 0.0)
	var s3 = views[2].evaluate(1.7)["layers"]
	check("컷3 1.7s 돌은 보이고 룬·눈빛은 꺼짐", s3["stone"]["alpha"] > 0.9 and s3["runes"]["alpha"] == 0.0 and s3["eyes_1"]["alpha"] == 0.0)
	s3 = views[2].evaluate(2.7)["layers"]
	check("컷3 2.7s 룬 점등(0.65~0.9)", s3["runes"]["alpha"] >= 0.6 and s3["runes"]["alpha"] <= 0.91)
	s3 = views[2].evaluate(4.45)["layers"]
	check("컷3 4.45s 눈빛 1만 켜지고 2·3은 아직", s3["eyes_1"]["alpha"] > 0.5 and s3["eyes_2"]["alpha"] == 0.0 and s3["eyes_3"]["alpha"] == 0.0)
	e3 = views[2].evaluate(8.35)
	check("컷3 8.35s 룬 섬광 알파 1(T3)", near(e3["flash"], 1.0) and views[2].finished_exit())
	check("컷3 7.0s 줌 + 손떨림 팬", e3["zoom"] > 1.0 and views[2].evaluate(7.0)["pan"].length() > 0.0)
	# 컷 4: 섬광에서 걷히고, 나그네가 왼쪽에서, 밤하늘 크로스페이드, 거미가 오른쪽에서, 끝에 검은 막
	var e4 = views[3].evaluate(0.0)
	check("컷4 0.0s 섬광 1에서 시작", near(e4["flash"], 1.0))
	var s4 = views[3].evaluate(0.9)["layers"]
	check("컷4 0.9s 나그네1·전경 나그네 왼쪽에서 등장 중, 2 아직, 밤하늘 0, 거미 다리 0", s4["traveler_1"]["off"].x < -150 and s4["traveler_1"]["alpha"] > 0.2 and s4["traveler_fore"]["off"].x < -100 and s4["traveler_2"]["alpha"] == 0.0 and s4["sky_night"]["alpha"] == 0.0 and s4["spider_legs"]["alpha"] == 0.0)
	s4 = views[3].evaluate(3.9)["layers"]
	check("컷4 3.9s 나그네 둘·전경 나그네 문 앞 도착(중경은 1.0으로 축소)", near(s4["traveler_1"]["off"].x, 0.0, 1.0) and near(s4["traveler_2"]["off"].x, 0.0, 1.0) and near(s4["traveler_fore"]["off"].x, 0.0, 1.0) and near(s4["traveler_1"]["scale"], 1.0, 0.01))
	var e4n = views[3].evaluate(6.2)
	s4 = e4n["layers"]
	check("컷4 6.2s 밤하늘 완전히 덮임, 나그네 어두워짐(0.6/0.5), 카메라 -2° 틸트, 거미 다리 내려오는 중", near(s4["sky_night"]["alpha"], 1.0) and near(s4["traveler_2"]["bright"], 0.6) and near(s4["traveler_fore"]["bright"], 0.5) and near(e4n["tilt"], -2.0, 0.05) and s4["spider_legs"]["alpha"] > 0.9 and s4["spider_legs"]["off"].y < 0.0 and s4["spider_legs"]["off"].y > -260.0)
	s4 = views[3].evaluate(7.2)["layers"]
	check("컷4 7.2s 거미 다리가 산장 위에 도착, 괴물 눈·숲 눈빛 켜짐", near(s4["spider_legs"]["off"].x, 0.0, 2.0) and near(s4["spider_legs"]["off"].y, 0.0, 2.0) and s4["spider"]["alpha"] > 0.5 and s4["eyes_1"]["alpha"] > 0.5 and s4["eyes_2"]["alpha"] > 0.5)
	check("컷4 3.5s 밤 전환 전에는 틸트 0", views[3].evaluate(3.5)["tilt"] == 0.0)
	e4 = views[3].evaluate(9.6)
	check("컷4 9.6s 검은 막(컷 알파 0)", near(e4["cut_alpha"], 0.0) and views[3].finished_exit())
	for v in views:
		v.queue_free()

	print("── 3. 실제 재생(폴백 또는 납품 레이어)")
	var p = PrologueScript.new()
	root.add_child(p)
	await frames(2)
	var ended := [false, false]
	p.finished.connect(func(skipped: bool): ended[0] = true; ended[1] = skipped)
	p.play()
	await frames(2)
	check("재생 시작: 컷 1, 자막은 전체 문장이 설정되고 글자는 아직 안 보임", p.index == 0 and p.caption.text == PrologueScript.SLIDES[0][1] and p.active)
	check("정지 그림 폴백 또는 레이어 모드 중 하나로 재생", p.current != null and (p.current.static_mode or p.motion_used.has(0)))
	# 자막 타이핑
	p.current.evaluate(p.current.line_at[0] + 0.6)
	p._update_caption(p.current.t)
	check("1행 자막이 한 글자씩 나타난다", p.caption.visible_characters > 3 and p.caption.visible_characters <= (PrologueScript.SLIDES[0][1] as String).split("\n")[0].length())
	p.next()
	await frames(2)
	check("next(): 컷 2로 넘어가고 컷 1은 퇴장 컷으로 겹쳐 남는다", p.index == 1 and p.outgoing != null and p.current != p.outgoing)
	# 퇴장 컷이 제 시간에 정리된다
	var waited := 0
	while p.outgoing != null and waited < 240:
		await process_frame
		waited += 1
	check("퇴장 컷이 전환 시간 뒤 제거된다", p.outgoing == null, "%d 프레임" % waited)
	# 클릭으로 다음
	var mb := InputEventMouseButton.new()
	mb.button_index = MOUSE_BUTTON_LEFT
	mb.pressed = true
	mb.position = Vector2(400, 300)
	mb.global_position = mb.position
	p._on_click(mb)
	await frames(2)
	check("클릭: 컷 3", p.index == 2)
	var captions_so_far: Array = p.shown_captions.duplicate()
	check("자막은 순서대로 기록된다", captions_so_far.size() == 3 and captions_so_far[2] == PrologueScript.SLIDES[2][1])
	# 자동 진행: 컷 3의 dur 뒤 컷 4로
	p.current.t = p.current.dur - 0.001
	await frames(12)
	check("자동 진행: 컷 3이 끝나면 컷 4", p.index == 3, "index=%d" % p.index)
	# Esc 건너뛰기
	var k := InputEventKey.new()
	k.keycode = KEY_ESCAPE
	k.pressed = true
	p._unhandled_input(k)
	waited = 0
	while not ended[0] and waited < 120:
		await process_frame
		waited += 1
	check("Esc: finished(skipped=true)", ended[0] and ended[1] and not p.active)
	check("4장 모두 자막이 기록됐다", p.shown_captions.size() == 4)
	check("정지 그림 4장이 있으니 그라데이션 플레이스홀더는 쓰지 않는다", not p.placeholder_used)
	p.queue_free()

	print("── 4. 납품 매니페스트·내보내기 필터")
	var delivered := 0
	for i in 4:
		var m: Dictionary = PrologueScript.manifest_of(i)
		if m.is_empty() or (m["layers"] as Array).is_empty():
			print("INFO 컷 %d 매니페스트 없음 → 정지 그림 폴백(코덱스 납품 전)" % (i + 1))
			continue
		delivered += 1
		var ids := []
		var missing := []
		for entry in m["layers"]:
			ids.append(str(entry.get("id", "")))
			var path: String = PrologueScript.MOTION_DIR + str(entry.get("file", ""))
			if not FileAccess.file_exists(path) and not ResourceLoader.exists(path):
				missing.append(str(entry.get("file", "")))
		var lacking := []
		for id in EXPECTED_IDS[i]:
			if not (id in ids):
				lacking.append(id)
		check("컷 %d 매니페스트에 요청서의 레이어 id가 모두 있다" % (i + 1), lacking.is_empty(), ", ".join(lacking))
		check("컷 %d 매니페스트의 파일이 모두 존재" % (i + 1), missing.is_empty(), ", ".join(missing))
		check("컷 %d has_motion()" % (i + 1), PrologueScript.has_motion(i))
	print("INFO 납품된 컷: %d / 4" % delivered)
	var preset := FileAccess.get_file_as_string("res://export_presets.cfg")
	check("내보내기 필터에 motion/*.json 포함", "assets/ui/ftue/motion/*.json" in preset)

	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)
