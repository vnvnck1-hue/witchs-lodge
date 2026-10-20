extends SceneTree
## HUD 이미지에 박힌 한글 글자(마녀·산장·산장 관리·창고·오늘의 할 일)를 지운 사본을 만든다.
## 영문판에서 moon_hud.gd 가 글자 자리만 이 사본으로 덮고 그 위에 영문 Label 을 올린다(scripts/ui/moon/moon_text_cover.gd).
## 글자 영역의 각 줄을 영역 왼쪽·오른쪽 바깥 픽셀 색으로 가로 보간해 채운다(무늬 없는 단색 판 위 글자라 자국이 남지 않는다).
## 실행(프로젝트 루트): .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/build_ui_notext.gd
const SkinUI := preload("res://scripts/ui/moon/moon_skin.gd")
const Cover := preload("res://scripts/ui/moon/moon_text_cover.gd")


func _initialize() -> void:
	var dir := ProjectSettings.globalize_path(Cover.NOTEXT_DIR)
	DirAccess.make_dir_recursive_absolute(dir)
	var ok := true
	for id in Cover.COVERS:
		var src: Texture2D = SkinUI.tex(id)
		if src == null:
			print("FAIL 원본 없음 ", id)
			ok = false
			continue
		var img := Image.load_from_file(ProjectSettings.globalize_path(src.resource_path))
		img.convert(Image.FORMAT_RGBA8)
		for c in Cover.COVERS[id]:
			var r: Rect2i = c["px"]
			for y in range(r.position.y, r.end.y):
				var a := img.get_pixel(r.position.x - 1, y)
				var b := img.get_pixel(r.end.x, y)
				for x in range(r.position.x, r.end.x):
					img.set_pixel(x, y, a.lerp(b, float(x - r.position.x + 1) / float(r.size.x + 1)))
		var out := dir.path_join(id + ".png")
		img.save_png(out)
		print("SAVED ", out)
	quit(0 if ok else 1)
