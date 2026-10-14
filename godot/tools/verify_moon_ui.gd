extends SceneTree
## 달빛 마법 UI 원본 재현 검증(명세 §7-1).
## 게임과 같은 배치 코드(MoonLayout + MoonHud.Reference)로 승인 원본 8개 그룹을 1600×800 배경 위에 놓고
## 승인 mockup.png와 픽셀 단위로 비교한다. 추가로 1920×1080·1774×887 배치에서 그룹이 화면 안에 있고
## 중앙 플레이 영역(x350..1249, y225..619 디자인 px)을 침범하지 않는지 확인한다.
## 실행(프로젝트 루트): .tools/Godot-4.7.2.exe --path godot --script res://tools/verify_moon_ui.gd -- --out=<폴더>

const Layout := preload("res://scripts/ui/moon/moon_layout.gd")
const MoonHud := preload("res://scripts/ui/moon/moon_hud.gd")
const APPROVED := "../art/ui/moon-runes-v01/approved/"

var failures: Array = []


func _initialize() -> void:
	call_deferred("_run")


func check(ok: bool, msg: String) -> void:
	if not ok:
		failures.append(msg)
		push_error("MOON_UI FAIL: " + msg)


func _run() -> void:
	var out_dir := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			out_dir = a.trim_prefix("--out=").trim_suffix("/") + "/"
	var approved_dir := ProjectSettings.globalize_path("res://").path_join(APPROVED).simplify_path() + "/"
	var bg_img := Image.load_from_file(approved_dir + "game-background.png")
	var mock := Image.load_from_file(approved_dir + "mockup.png")
	check(bg_img != null and mock != null, "approved images missing in " + approved_dir)
	if not failures.is_empty():
		_finish({}, out_dir)
		return
	root.size = Vector2i(1600, 800)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	var canvas := Control.new()
	canvas.size = Vector2(1600, 800)
	root.add_child(canvas)
	var bg := TextureRect.new()
	bg.texture = ImageTexture.create_from_image(bg_img)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.size = Vector2(1600, 800)
	canvas.add_child(bg)
	var ref = MoonHud.Reference.new()
	canvas.add_child(ref)
	ref.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for f in 4:
		await process_frame
	await RenderingServer.frame_post_draw
	var shot := root.get_texture().get_image()
	shot.convert(Image.FORMAT_RGBA8)
	mock.convert(Image.FORMAT_RGBA8)
	var diff := 0
	var max_d := 0
	for y in 800:
		for x in 1600:
			var a := shot.get_pixel(x, y)
			var b := mock.get_pixel(x, y)
			var d := int(maxf(maxf(absf(a.r - b.r), absf(a.g - b.g)), absf(a.b - b.b)) * 255.0 + 0.5)
			if d > 0:
				diff += 1
				max_d = maxi(max_d, d)
	check(diff == 0, "reference differs from approved mockup: %d px (max channel diff %d)" % [diff, max_d])
	if out_dir != "":
		shot.save_png(out_dir + "moon-reference-1600x800.png")

	# 다른 해상도 배치 확인(디자인 → 화면 변환)
	var layouts := {}
	for view in [Vector2(1600, 800), Vector2(1774, 887), Vector2(1920, 1080), Vector2(1280, 800)]:
		var s := Layout.ui_scale(view)
		var center := Rect2(Layout.to_view(Layout.CENTER_CLEAR.position, Vector2(0.5, 0.5), view), Layout.CENTER_CLEAR.size * s)
		var rects := {}
		for id in Layout.ORDER:
			var r := Layout.slot_rect(id, view)
			rects[id] = [r.position.x, r.position.y, r.size.x, r.size.y]
			check(Rect2(Vector2.ZERO, view).encloses(r.grow(-0.01)), "%s outside view %s" % [id, view])
			if view.x / view.y <= 2.0 + 0.001:
				# 2:1 이하에서는 중앙 영역을 기준으로 겹침 확인(가로가 더 긴 화면은 좌우가 벌어짐)
				check(not r.intersects(center), "%s overlaps center play area at %s" % [id, view])
		layouts[str(view)] = {"scale": s, "slots": rects}
	_finish({"pixel_diff": diff, "max_channel_diff": max_d, "layouts": layouts}, out_dir)


func _finish(report: Dictionary, out_dir: String) -> void:
	report["passed"] = failures.is_empty()
	report["failures"] = failures
	if out_dir != "":
		var f := FileAccess.open(out_dir + "moon-ui-verification.json", FileAccess.WRITE)
		f.store_string(JSON.stringify(report, "\t"))
	print("MOON_UI ", JSON.stringify({"passed": report["passed"], "pixel_diff": report.get("pixel_diff", -1), "failures": failures}))
	quit(0 if failures.is_empty() else 1)
