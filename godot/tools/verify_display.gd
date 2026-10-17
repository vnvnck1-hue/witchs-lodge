extends SceneTree
## 디스플레이 설정·화면 비율 정렬 검증: 여러 모니터 해상도(21:9 울트라와이드·16:9·16:10·4:3·32:9)에서
## - UI 화면 크기가 기준(1774×887)보다 작아지지 않는지(stretch canvas_items + expand)
## - 가운데 펼침 화면(시작 손패·보물상자·마법서적·새벽 보상·제단)이 화면 가운데에 놓이고, 열린 채 창 크기가 바뀌어도
##   (예: 1600×800 창에서 F11로 3440×1440 전체 화면) 새 가운데로 따라가는지
## - 모서리 HUD가 화면 밖으로 나가지 않는지
## - 일시 정지 → 디스플레이 설정 UI와 저장·불러오기
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_display.gd
## 사용자의 실제 user://settings.cfg 는 건드리지 않도록 검증 전용 파일을 쓴다. 헤드리스에서는 창을 실제로 바꾸지 않고
## 루트 뷰포트 크기만 바꿔 같은 stretch 계산을 재현한다.

const TEST_PATH := "user://verify_display.cfg"
const WindowModeScript := preload("res://scripts/visual/window_mode.gd")
const BASE := Vector2(1774, 887)
const SIZES := [
	Vector2i(3440, 1440), Vector2i(1920, 1080), Vector2i(2560, 1600), Vector2i(1024, 768),
	Vector2i(5120, 1440), Vector2i(1600, 800), Vector2i(1280, 720),
]
var failures := 0
var total := 0


func _initialize() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	_run.call_deferred()


func check(name: String, ok: bool, detail := "") -> void:
	total += 1
	if not ok:
		failures += 1
	print(("PASS " if ok else "FAIL ") + name + ("  — " + detail if detail != "" else ""))


func _wait(sec: float) -> void:
	await create_timer(sec, true, false, true).timeout


func _resize(sz: Vector2i) -> void:
	root.size = sz
	await process_frame
	await process_frame


func _vis() -> Vector2:
	return root.get_visible_rect().size


## 노드들의 전역 사각형을 합친 것.
func _union(nodes: Array) -> Rect2:
	var r := Rect2()
	var first := true
	for n in nodes:
		var c := n as Control
		if c == null or not is_instance_valid(c):
			continue
		var g := c.get_global_rect()
		r = g if first else r.merge(g)
		first = false
	return r


func _centered(label: String, rect: Rect2, tol := 3.0) -> void:
	var vis := _vis()
	var dx := rect.get_center().x - vis.x * 0.5
	check("%s 가로 가운데 (%dx%d)" % [label, int(vis.x), int(vis.y)], absf(dx) <= tol, "중심 x=%.1f, 화면 가운데=%.1f" % [rect.get_center().x, vis.x * 0.5])
	check("%s 화면 안 (%dx%d)" % [label, int(vis.x), int(vis.y)], Rect2(Vector2.ZERO, vis).grow(2).encloses(rect), str(rect))


func _card_nodes(screen) -> Array:
	return screen.cards.map(func(c): return c["node"])


func _run() -> void:
	while current_scene == null or current_scene.get("session") == null or current_scene.get("hud") == null:
		await process_frame
	for i in 5:
		await process_frame
	var main = current_scene
	var ds = main.display
	var hud = main.hud

	# ── 디스플레이 설정 노드 ──
	check("디스플레이 설정 노드", ds != null and ds.get_script() == WindowModeScript)
	check("--script 실행에서는 창을 건드리지 않음", ds != null and not ds.apply_window)
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PATH))
	ds.settings_path = TEST_PATH
	check("기본 화면 모드 = 전체 화면(테두리 없음)", WindowModeScript.DEFAULT_MODE == "borderless")
	check("stretch = canvas_items", ProjectSettings.get_setting("display/window/stretch/mode") == "canvas_items")
	check("stretch aspect = expand", ProjectSettings.get_setting("display/window/stretch/aspect") == "expand")

	# fit_size: 작업 영역에 비율 유지로 맞춤
	check("창 크기 맞춤: 들어가면 그대로", WindowModeScript.fit_size(Vector2i(1600, 800), Vector2i(3440, 1400)) == Vector2i(1600, 800))
	var fitted: Vector2i = WindowModeScript.fit_size(Vector2i(3840, 2160), Vector2i(1920, 1040))
	check("창 크기 맞춤: 넘치면 비율 유지 축소", fitted.x <= 1920 and fitted.y <= 1040 and absf(float(fitted.x) / fitted.y - 16.0 / 9.0) < 0.01, str(fitted))

	# ── 해상도별 UI 화면 크기와 HUD ──
	for sz in SIZES:
		await _resize(sz)
		var vis := _vis()
		check("UI 화면이 기준 이상 %dx%d → %dx%d" % [sz.x, sz.y, int(vis.x), int(vis.y)], vis.x >= BASE.x - 1 and vis.y >= BASE.y - 1)
		check("UI 화면 비율 = 모니터 비율 %dx%d" % [sz.x, sz.y], absf(vis.x / vis.y - float(sz.x) / sz.y) < 0.01)
		var out: Array = []
		for c in hud.moon.get_children():
			var ctl := c as Control
			if ctl == null or not ctl.visible or ctl.get_global_rect().size == Vector2.ZERO:
				continue
			if not Rect2(Vector2.ZERO, vis).grow(4).encloses(ctl.get_global_rect()):
				out.append("%s %s" % [ctl.name, ctl.get_global_rect()])
		check("달빛 HUD 요소가 화면 안 %dx%d" % [sz.x, sz.y], out.is_empty(), ", ".join(out))

	# ── 시작 손패: 1600×800 창에서 연 뒤 3440×1440 전체 화면으로 바뀌는 사용자 상황 ──
	await _resize(Vector2i(1600, 800))
	main.grant_starter_cards(true)
	var mull = main.mulligan_ui
	check("시작 손패 열림", mull.active)
	await _wait(1.6)
	check("시작 손패 카드 3장", mull.cards.size() == 3)
	_centered("시작 손패 카드", _union(_card_nodes(mull)))
	await _resize(Vector2i(3440, 1440))
	_centered("F11 뒤 시작 손패 카드", _union(_card_nodes(mull)))
	_centered("F11 뒤 시작 손패 확정 버튼", mull.confirm_btn.get_global_rect())
	check("F11 뒤 제목 가운데 정렬", absf(mull.title.get_global_rect().get_center().x - _vis().x * 0.5) <= 3.0)
	await _resize(Vector2i(1024, 768))
	_centered("4:3 시작 손패 카드", _union(_card_nodes(mull)))
	var vis43 := _vis()
	var cards_rect := _union(_card_nodes(mull))
	check("4:3 시작 손패 세로 가운데", absf(cards_rect.get_center().y - vis43.y * 0.5) <= 20.0, "중심 y=%.1f / %.1f" % [cards_rect.get_center().y, vis43.y * 0.5])
	mull.confirm()
	await _wait(1.4)
	check("시작 손패 닫힘", not mull.active)

	# ── 보물상자 ──
	await _resize(Vector2i(1920, 1080))
	var chest = main.chest_ui
	chest.open(Vector3.ZERO)
	if chest.active:
		await _wait(2.8)  # 흔들림·뚜껑·카드 튀어나옴까지 약 2초
		_centered("보물상자 카드", _union(_card_nodes(chest)))
		await _resize(Vector2i(3440, 1440))
		_centered("창 변경 뒤 보물상자 카드", _union(_card_nodes(chest)))
		chest.close()
		await _wait(0.4)
	else:
		check("보물상자 열림", false, "유물 후보 없음")

	# ── 마법서적 ──
	await _resize(Vector2i(1600, 800))
	var book = main.spellbook_ui
	book.open()
	if book.active:
		await _wait(1.2)
		_centered("마법서적 카드", _union(_card_nodes(book)))
		await _resize(Vector2i(5120, 1440))
		_centered("32:9 마법서적 카드", _union(_card_nodes(book)))
		book.close()
		await _wait(0.4)
	else:
		print("SKIP 마법서적 — 주머니가 비어 후보 없음")

	# ── 새벽 보상 ──
	await _resize(Vector2i(1600, 800))
	var offer = main.offer_ui
	offer.open_reward(["timber", "raw_meat", "timber"])
	check("새벽 보상 열림", offer.active)
	var offer_nodes: Array = offer.buttons.map(func(b): return b["btn"])
	_centered("새벽 보상 카드", _union(offer_nodes))
	await _resize(Vector2i(3440, 1440))
	_centered("창 변경 뒤 새벽 보상 카드", _union(offer_nodes))
	_centered("창 변경 뒤 새벽 보상 닫기 버튼", offer.close_btn.get_global_rect())
	offer.close()

	# ── 제단 ──
	await _resize(Vector2i(1600, 800))
	var altar = main.altar_ui
	altar.open()
	await process_frame
	await process_frame
	_centered("제단 창", altar.panel.get_global_rect())
	await _resize(Vector2i(3440, 1440))
	await process_frame
	_centered("창 변경 뒤 제단 창", altar.panel.get_global_rect())
	altar.close()
	await process_frame

	# ── 일시 정지 모달 ──
	hud.pause_panel.visible = true
	await _resize(Vector2i(1024, 768))
	await process_frame
	_centered("4:3 일시 정지 창", hud.pause_panel.get_global_rect(), 4.0)
	await _resize(Vector2i(3440, 1440))
	await process_frame
	_centered("21:9 일시 정지 창", hud.pause_panel.get_global_rect(), 4.0)

	# ── 디스플레이 설정 UI ──
	check("디스플레이 버튼", hud.display_btn != null and hud.display_btn.text.begins_with("디스플레이"))
	check("디스플레이 구역은 처음엔 접힘", hud.pause_display != null and not hud.pause_display.visible)
	hud.display_btn.pressed.emit()
	check("버튼으로 구역 펼침", hud.pause_display.visible and hud.display_btn.text.ends_with("▴"))
	check("화면 모드 선택지 3개", hud.display_mode_select.item_count == 3)
	check("안내 문구에 현재 화면 크기", hud.display_info.text.contains("3440×1440") and hud.display_info.text.contains("2118×887"), hud.display_info.text)
	hud.display_mode_select.select(0)
	hud.display_mode_select.item_selected.emit(0)
	check("창 모드 선택 → 설정 반영", ds.mode == "windowed")
	check("창 모드에서 창 크기 선택 가능", not hud.display_size_select.disabled and hud.display_size_select.item_count >= 1)
	var idx := -1
	for i in hud.display_size_select.item_count:
		if hud.display_size_select.get_item_metadata(i) == Vector2i(1920, 1080):
			idx = i
	if idx == -1:
		idx = 0
	var want: Vector2i = hud.display_size_select.get_item_metadata(idx)
	hud.display_size_select.select(idx)
	hud.display_size_select.item_selected.emit(idx)
	check("창 크기 선택 → 설정 반영", ds.window_size == want, str(ds.window_size))
	hud.display_fps_select.item_selected.emit(WindowModeScript.FPS_LIMITS.find(144))
	check("프레임 제한 선택 → 설정 반영", ds.max_fps == 144)
	hud.display_scale_select.item_selected.emit(WindowModeScript.RENDER_SCALES.find(0.75))
	check("3D 해상도 선택 → 뷰포트 배율", is_equal_approx(ds.render_scale, 0.75) and is_equal_approx(root.scaling_3d_scale, 0.75))
	hud.display_vsync.toggled.emit(false)
	check("수직 동기화 끔 → 설정 반영", not ds.vsync)
	ds.toggle_fullscreen()
	check("F11: 창 모드 → 전체 화면(테두리 없음)", ds.mode == "borderless")
	check("F11 변경이 UI에 반영", hud.display_mode_select.selected == 1 and hud.display_size_select.disabled)
	ds.set_mode("fullscreen")
	ds.toggle_fullscreen()
	ds.toggle_fullscreen()
	check("F11: 마지막 전체 화면 모드(전용)로 복귀", ds.mode == "fullscreen")

	# 저장·불러오기
	var fresh = WindowModeScript.new()
	fresh.settings_path = TEST_PATH
	fresh.load_settings()
	check("저장·불러오기: 모드", fresh.mode == "fullscreen")
	check("저장·불러오기: 창 크기", fresh.window_size == want)
	check("저장·불러오기: 프레임 제한", fresh.max_fps == 144)
	check("저장·불러오기: 3D 해상도", is_equal_approx(fresh.render_scale, 0.75))
	check("저장·불러오기: 수직 동기화", not fresh.vsync)
	var cfg := ConfigFile.new()
	cfg.load(TEST_PATH)
	cfg.set_value("audio", "master", 0.4)
	cfg.save(TEST_PATH)
	ds.set_vsync(true)
	cfg = ConfigFile.new()
	cfg.load(TEST_PATH)
	check("디스플레이 저장이 소리 설정 구역을 지우지 않음", is_equal_approx(float(cfg.get_value("audio", "master", -1.0)), 0.4))
	fresh.free()
	ds.set_render_scale(1.0, false)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PATH))

	print("RESULT %d/%d" % [total - failures, total])
	quit(1 if failures > 0 else 0)
