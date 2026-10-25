extends SceneTree
## 로비 실제 화면 캡처(사용자 요청 2026-10-24: 컨셉 원화 그대로 재현 + 인물 셰이더 아이들링). docs/lobby.md
## 헤드리스 더미 렌더러로는 셰이더 컴파일·실제 픽셀(원화와의 일치, 인물이 찢어지지 않고 움직이는지)을 볼 수 없어서 짧게 캡처한다.
## 실행(창 모드): .tools/Godot-4.7.2.exe --path godot --resolution 1920x1080 --script res://tools/capture_lobby.gd [-- --concept-test]
##   기본: 타이틀 장면을 띄워 정지 상태를 원화와 픽셀 비교하고, 아이들링 몇 장면·메뉴 강조 이동·안내·1774×887 창·2560×1080 울트라와이드를 찍는다.
##   --concept-test: 레이어 납품 전, 원화 한 장에 셰이더만 걸어 움직임을 확인한다(개발용).
## 결과: res://screenshots/lobby/*.png, 비교 수치는 출력 줄 LOBBY_DIFF.

const OUT := "res://screenshots/lobby/"
const CONCEPT := "res://../art/concepts/lobby/races-closeup-distant-v02/03-races-closeup-distant.png"
const LobbyRig := preload("res://scripts/ui/lobby_rig.gd")
var vp: SubViewport   # 창 크기(작업 표시줄에 막혀 줄어듦)와 상관없이 1920×1080 으로 그린다
const MOTION_TIMES := [0.0, 1.6, 3.2, 4.8, 6.4, 8.0]


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	create_timer(420.0, true, false, true).timeout.connect(func(): print("LOBBY timeout"); quit(1))
	vp = SubViewport.new()
	vp.size = Vector2i(1920, 1080)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	vp.transparent_bg = false
	root.add_child.call_deferred(vp)
	if "--concept-test" in OS.get_cmdline_user_args():
		_concept_test.call_deferred()
	else:
		_run.call_deferred()


func frames(n: int) -> void:
	for i in n:
		await process_frame


func _grab() -> Image:
	await RenderingServer.frame_post_draw
	return vp.get_texture().get_image()


func _save(img: Image, name: String) -> void:
	img.save_png(ProjectSettings.globalize_path(OUT + name))
	print("LOBBY saved ", name)


func _concept_image() -> Image:
	var img := Image.load_from_file(ProjectSettings.globalize_path(CONCEPT))
	img.convert(Image.FORMAT_RGBA8)
	return img


## 두 장의 차이: 평균 채널 차이, 채널 차이 > 8 인 픽셀 비율, 차이를 8배 키운 그림.
func _diff(a: Image, b: Image) -> Dictionary:
	a.convert(Image.FORMAT_RGBA8)
	b.convert(Image.FORMAT_RGBA8)
	if a.get_size() != b.get_size():
		b = b.duplicate()
		b.resize(a.get_width(), a.get_height(), Image.INTERPOLATE_BILINEAR)
	var da := a.get_data()
	var db := b.get_data()
	var vis := PackedByteArray()
	vis.resize(da.size())
	var total := 0.0
	var big := 0
	var n := a.get_width() * a.get_height()
	for k in n:
		var m := 0
		for c in 3:
			var d := absi(int(da[k * 4 + c]) - int(db[k * 4 + c]))
			total += d
			m = maxi(m, d)
			vis[k * 4 + c] = mini(255, d * 8)
		vis[k * 4 + 3] = 255
		if m > 8:
			big += 1
	return {"mean": total / (n * 3.0), "over8": float(big) / n,
		"vis": Image.create_from_data(a.get_width(), a.get_height(), false, Image.FORMAT_RGBA8, vis)}


func _concept_test() -> void:
	await frames(2)
	var tr := TextureRect.new()
	tr.texture = ImageTexture.create_from_image(_concept_image())
	tr.size = Vector2(1920, 1080)
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	var mat := ShaderMaterial.new()
	mat.shader = load("res://shaders/lobby_idle.gdshader")
	LobbyRig.apply(mat)
	tr.material = mat
	vp.add_child(tr)
	await frames(10)
	var base: Image
	for t in MOTION_TIMES:
		mat.set_shader_parameter("motion_time", t)
		await frames(2)
		var img := await _grab()
		if base == null:
			base = img
		_save(img, "concept-test-t%04.1f.png" % t)
		if t > 0.0:
			var d := _diff(base, img)
			_save(d["vis"], "concept-test-diff-t%04.1f.png" % t)
			print("LOBBY_MOTION t=%.1f mean=%.3f over8=%.4f" % [t, d["mean"], d["over8"]])
	quit(0)


func _run() -> void:
	await frames(2)
	var lobby = load("res://scenes/title.tscn").instantiate()
	vp.add_child(lobby)
	await frames(20)
	lobby.set_process(false)   # 시계를 직접 돌린다
	var mat: ShaderMaterial = lobby.character_mat
	print("LOBBY layered=%s shader=%s" % [lobby.layered, mat != null])
	# 1) 정지(idle 0) + 원화 그대로의 강조(이어하기) → 원화와 비교
	if mat != null:
		mat.set_shader_parameter("idle_amount", 0.0)
	lobby.highlight(0, true)
	await frames(4)
	var still := await _grab()
	_save(still, "00-still.png")
	var concept := _concept_image()
	var d := _diff(concept, still)
	_save(d["vis"], "00-still-diff-x8.png")
	print("LOBBY_DIFF mean=%.3f over8=%.4f size=%s" % [d["mean"], d["over8"], still.get_size()])
	# 2) 아이들링
	if mat != null:
		mat.set_shader_parameter("idle_amount", 1.0)
		var i := 1
		for t in MOTION_TIMES:
			if t == 0.0:
				continue
			mat.set_shader_parameter("motion_time", t)
			await frames(2)
			var img := await _grab()
			_save(img, "%02d-idle-t%04.1f.png" % [i, t])
			var dm := _diff(still, img)
			_save(dm["vis"], "%02d-idle-diff-t%04.1f-x8.png" % [i, t])
			print("LOBBY_MOTION t=%.1f mean=%.3f over8=%.4f" % [t, dm["mean"], dm["over8"]])
			i += 1
	# 3) 메뉴 강조를 '새로운 이야기'로 옮긴 모습
	lobby.highlight(1, true)
	await frames(4)
	_save(await _grab(), "10-highlight-new.png")
	lobby.highlight(3, true)
	await frames(4)
	_save(await _grab(), "11-highlight-settings.png")
	lobby.highlight(0, true)
	# 4) 안내(이어하기 저장 없음)
	lobby._on_continue()
	lobby.notice.modulate.a = 1.0
	await frames(4)
	_save(await _grab(), "12-notice.png")
	# 5) 작은 창(기본 1774×887 비율)에서 무대 맞춤
	vp.size = Vector2i(1774, 887)
	await frames(6)
	_save(await _grab(), "13-window-1774x887.png")
	# 6) 울트라와이드(2026-10-24 사용자 화면): 위아래가 잘리지 않고 왼쪽 확장 그림이 보인다. 확장 부분도 함께 움직이는지
	vp.size = Vector2i(2560, 1080)
	if mat != null:
		mat.set_shader_parameter("motion_time", 0.0)
	await frames(6)
	var wide := await _grab()
	_save(wide, "14-ultrawide-2560x1080.png")
	if mat != null:
		mat.set_shader_parameter("motion_time", 3.2)
		await frames(3)
		var wm := _diff(wide, await _grab())
		_save(wm["vis"], "15-ultrawide-idle-diff-t03.2-x8.png")
		print("LOBBY_WIDE_MOTION mean=%.3f over8=%.4f" % [wm["mean"], wm["over8"]])
	quit(0)
