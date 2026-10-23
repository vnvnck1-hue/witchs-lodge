extends SceneTree
## 손님 초상 모션 좌표(머리·가슴 UV)를 눈으로 읽기 위한 격자 시트. docs/portrait-motion-all.md
## 초상마다 0.1 UV 간격 격자(0.5 는 굵게)를 얹어 한 장에 늘어놓는다. CPU Image 연산만 쓰므로 헤드리스로 돈다.
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/portrait_grid_sheet.gd
## 출력: screenshots/portrait-motion-all/grid-<n>.png 와 순서 목록(표준 출력)

const Profiles := preload("res://scripts/ui/guest_profiles.gd")
const OUT := "res://screenshots/portrait-motion-all/"
const CELL := Vector2i(300, 375)
const COLS := 6
const ROWS := 2


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var list: Array = []
	for p in Profiles.CATALOG + Profiles.SPECIALS: list.append([p["id"], p["portrait"]])
	var per := COLS * ROWS
	for sheet in ceili(list.size() / float(per)):
		var img := Image.create(CELL.x * COLS, CELL.y * ROWS, false, Image.FORMAT_RGBA8)
		img.fill(Color(0.12, 0.11, 0.14))
		for i in per:
			var n := sheet * per + i
			if n >= list.size(): break
			var src: Image = (load(list[n][1]) as Texture2D).get_image()
			src.convert(Image.FORMAT_RGBA8)
			src.resize(CELL.x, CELL.y, Image.INTERPOLATE_BILINEAR)
			var at := Vector2i((i % COLS) * CELL.x, (i / COLS) * CELL.y)
			img.blend_rect(src, Rect2i(Vector2i.ZERO, CELL), at)
			for g in range(1, 10):
				var c := Color(0.2, 1.0, 0.9, 0.9) if g == 5 else Color(0.9, 0.9, 0.2, 0.45)
				var x := at.x + int(CELL.x * g / 10.0)
				var y := at.y + int(CELL.y * g / 10.0)
				for k in CELL.y: _px(img, Vector2i(x, at.y + k), c)
				for k in CELL.x: _px(img, Vector2i(at.x + k, y), c)
			for k in CELL.y: _px(img, Vector2i(at.x, at.y + k), Color.RED)
			print("sheet %d  slot %d  %s" % [sheet, i, list[n][0]])
		img.save_png(ProjectSettings.globalize_path(OUT + "grid-%d.png" % sheet))
	quit(0)


func _px(img: Image, p: Vector2i, c: Color) -> void:
	img.set_pixelv(p, img.get_pixelv(p).blend(c))
