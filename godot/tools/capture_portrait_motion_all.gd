extends SceneTree
## 전 손님 초상 모션 실제 렌더 캡처(docs/portrait-motion-all.md).
## 창을 띄우는 이유: 새 uniform 을 넣은 셰이더의 컴파일 결과와 날개·귀 보조 움직임의 실제 크기는 헤드리스 더미 렌더러로 볼 수 없다.
## 종족 대표 손님을 대화창 크기(480×600)로 같은 셰이더에 걸어, 쉬는 시각과 보조 움직임이 가장 큰 시각을 찍고 차이(8배 증폭)를 남긴다.
## 실행(프로젝트 루트): .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_portrait_motion_all.gd
## 결과: res://screenshots/portrait-motion-all/<id>-base.png(보조 움직임이 있는 종족은 같은 시각 accent 끈 렌더, 나머지는 쉬는 시각)·<id>-peak.png·<id>-diff.png, sheet.png, RESULT n/m

const Profiles := preload("res://scripts/ui/guest_profiles.gd")
const PortraitMotion := preload("res://scripts/ui/portrait_motion.gd")
const SHADER := preload("res://shaders/guest_portrait_motion.gdshader")
const OUT := "res://screenshots/portrait-motion-all/"
const IDS := ["bram", "harald", "fern", "graz", "fargh", "garok", "oswin", "pip"]
const SIZE := Vector2(480, 600)
## 귀 씰룩 문(burst gate)이 열리는 시각: sin(t·0.61+1.7)=1 → t ≈ 10.09초
const BURST_T := (PI * 0.5 - 1.7 + TAU) / 0.61

var passed := 0
var total := 0


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	create_timer(120.0, true, false, true).timeout.connect(func(): print("TIMEOUT"); quit(2))
	_run.call_deferred()


func check(ok: bool, label: String, detail := "") -> void:
	total += 1
	if ok: passed += 1
	print(("PASS " if ok else "FAIL ") + label + ("  — " + detail if detail != "" else ""))


func diff(a: Image, b: Image) -> float:
	var s := 0.0
	var n := 0
	for y in range(0, a.get_height(), 3):
		for x in range(0, a.get_width(), 3):
			var ca := a.get_pixel(x, y)
			var cb := b.get_pixel(x, y)
			s += absf(ca.r - cb.r) + absf(ca.g - cb.g) + absf(ca.b - cb.b)
			n += 1
	return s / maxf(float(n), 1.0)


## 배경과 다른(인물이 그려진) 픽셀 수
func coverage(img: Image) -> float:
	var n := 0.0
	for y in range(0, img.get_height(), 2):
		for x in range(0, img.get_width(), 2):
			var c := img.get_pixel(x, y)
			if absf(c.r - 0.13) + absf(c.g - 0.11) + absf(c.b - 0.15) > 0.04: n += 1.0
	return n


func shot(mat: ShaderMaterial, rect: TextureRect, t: float) -> Image:
	mat.set_shader_parameter("motion_time", t)
	await process_frame
	await RenderingServer.frame_post_draw
	return root.get_texture().get_image().get_region(Rect2i(Vector2i(rect.position), Vector2i(SIZE)))


func _run() -> void:
	root.size = Vector2i(1000, 640)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED  # 프로젝트 화면 배율을 끄고 1:1 픽셀로 찍는다
	var bg := ColorRect.new()
	bg.color = Color(0.13, 0.11, 0.15)
	bg.size = Vector2(root.size)
	root.add_child(bg)
	var sheet := Image.create(240 * IDS.size(), 300 * 2, false, Image.FORMAT_RGBA8)
	for n in IDS.size():
		var id: String = IDS[n]
		var profile: Dictionary = Profiles.character(id)
		var rect := TextureRect.new()
		rect.texture = load(profile["portrait"])
		rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		rect.position = Vector2(20, 20)
		rect.size = SIZE
		var mat := ShaderMaterial.new()
		mat.shader = SHADER
		var m: Dictionary = PortraitMotion.DEFAULTS.duplicate()
		m.merge(PortraitMotion.for_profile(profile), true)
		m["motion_phase"] = 0.0
		for k in m: mat.set_shader_parameter({"idle": "idle_amount", "chest": "chest_amount"}.get(k, k), m[k])
		rect.material = mat
		root.add_child(rect)
		await process_frame
		# 쉬는 시각(귀 문 닫힘, 숨 중간)과 그 근처 최대 변형 시각을 찾는다
		var rest: Image = await shot(mat, rect, BURST_T - 2.6)
		var best := 0.0
		var peak: Image = rest
		var peak_t := BURST_T
		var rate: float = float(m["accent_rate"])
		for k in 10:
			var t: float = BURST_T + (float(k) - 4.5) * (PI / rate) * 0.5
			var img: Image = await shot(mat, rect, t)
			var d := diff(rest, img)
			if d > best:
				best = d
				peak = img
				peak_t = t
		# 보조 움직임(날개·귀)만 떼어 보기: 같은 시각에 accent 를 끈 렌더와 비교
		var accent_only := 0.0
		if float(m["accent_amount"]) > 0.0:
			mat.set_shader_parameter("accent_amount", 0.0)
			var plain: Image = await shot(mat, rect, peak_t)
			mat.set_shader_parameter("accent_amount", m["accent_amount"])
			accent_only = diff(plain, peak)
			rest = plain
			check(accent_only > 0.002, "%s: 날개/귀 보조 움직임이 실제로 보임" % id, "accent diff=%.5f" % accent_only)
		rest.save_png(ProjectSettings.globalize_path(OUT + "%s-base.png" % id))
		peak.save_png(ProjectSettings.globalize_path(OUT + "%s-peak.png" % id))
		var dimg := Image.create(rest.get_width(), rest.get_height(), false, Image.FORMAT_RGB8)
		for y in rest.get_height():
			for x in rest.get_width():
				var ca := rest.get_pixel(x, y)
				var cb := peak.get_pixel(x, y)
				var v := clampf((absf(ca.r - cb.r) + absf(ca.g - cb.g) + absf(ca.b - cb.b)) * 8.0 / 3.0, 0.0, 1.0)
				dimg.set_pixel(x, y, Color(v, v, v))
		dimg.save_png(ProjectSettings.globalize_path(OUT + "%s-diff.png" % id))
		var opaque := 0
		for y in range(0, rest.get_height(), 6):
			for x in range(0, rest.get_width(), 6):
				if rest.get_pixel(x, y).a > 0.5 and rest.get_pixel(x, y).r + rest.get_pixel(x, y).g > 0.5: opaque += 1
		check(opaque > 300, "%s: 초상이 실제로 그려짐(셰이더 컴파일)" % id, "samples=%d" % opaque)
		check(best > 0.0005, "%s: 시각에 따라 초상이 움직임" % id, "mean diff=%.5f" % best)
		# 찢어짐·구멍 검사: UV 비틀기는 실루엣을 몇 px 옮길 뿐이라 불투명 면적이 거의 같아야 한다
		var cover_a := coverage(rest)
		var cover_b := coverage(peak)
		check(absf(cover_a - cover_b) / cover_a < 0.03, "%s: 실루엣 면적 변화 3%% 미만(찢어짐 없음)" % id, "%.0f → %.0f" % [cover_a, cover_b])
		var r2 := rest.duplicate() as Image
		r2.resize(240, 300)
		var d2 := dimg.duplicate() as Image
		d2.convert(Image.FORMAT_RGBA8)
		d2.resize(240, 300)
		r2.convert(Image.FORMAT_RGBA8)
		sheet.blit_rect(r2, Rect2i(0, 0, 240, 300), Vector2i(n * 240, 0))
		sheet.blit_rect(d2, Rect2i(0, 0, 240, 300), Vector2i(n * 240, 300))
		print("CAPTURE %s best=%.5f accent=%.5f" % [id, best, accent_only])
		rect.queue_free()
		await process_frame
	sheet.save_png(ProjectSettings.globalize_path(OUT + "sheet.png"))
	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)
