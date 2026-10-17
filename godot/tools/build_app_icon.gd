extends SceneTree
## 실행파일·창 아이콘 생성. 산장 모델 시트 정면도를 잘라 배경을 빼고 밤하늘 둥근 사각형 위에 올린다.
## 출력: res://icon.png(256), res://icon.ico(16~256 PNG 내장)
##   .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/build_app_icon.gd

const CROP := Rect2i(40, 0, 690, 690)  # 정면도(FRONT) 영역, 원본 2172x724 기준
const SIZES := [256, 128, 64, 48, 32, 24, 16]
const BG_TOLERANCE := 0.075

func _init() -> void:
	var src_path := ProjectSettings.globalize_path("res://").path_join("../art/model-sheets/witch-lodge-front-right-back.png")
	var src := Image.load_from_file(src_path)
	if src == null:
		push_error("source missing: " + src_path)
		quit(1)
		return
	src.convert(Image.FORMAT_RGBA8)
	var crop := src.get_region(CROP)
	crop.fill_rect(Rect2i(330, 10, 150, 50), crop.get_pixel(2, CROP.size.y / 2))  # "FRONT" 라벨 지우기
	_remove_background(crop)
	var master := _compose(crop, 1024)
	var png_256: Image = master.duplicate()
	png_256.resize(256, 256, Image.INTERPOLATE_LANCZOS)
	png_256.save_png("res://icon.png")
	_save_ico(master, "res://icon.ico")
	print("icon.png / icon.ico written")
	quit(0)

## 가장자리에서 이어진 회색 배경·안내선을 투명하게 만든다.
func _remove_background(img: Image) -> void:
	var w := img.get_width()
	var h := img.get_height()
	var bg := img.get_pixel(2, h / 2)
	var seen := PackedByteArray()
	seen.resize(w * h)
	var stack: Array[int] = []
	for x in w:
		stack.append(x)
		stack.append((h - 1) * w + x)
	for y in h:
		stack.append(y * w)
		stack.append(y * w + w - 1)
	while not stack.is_empty():
		var i: int = stack.pop_back()
		if seen[i]:
			continue
		seen[i] = 1
		var x := i % w
		var y := i / w
		var c := img.get_pixel(x, y)
		if not _is_background(c, bg):
			continue
		img.set_pixel(x, y, Color(0, 0, 0, 0))
		if x > 0: stack.append(i - 1)
		if x < w - 1: stack.append(i + 1)
		if y > 0: stack.append(i - w)
		if y < h - 1: stack.append(i + w)
	# 남은 경계 1px 회색 테두리를 반투명으로 부드럽게
	var copy: Image = img.duplicate()
	for y in range(1, h - 1):
		for x in range(1, w - 1):
			var c := copy.get_pixel(x, y)
			if c.a == 0.0:
				continue
			var empty := 0
			for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				if copy.get_pixelv(Vector2i(x, y) + d).a == 0.0:
					empty += 1
			if empty >= 2:
				c.a = 0.55
				img.set_pixel(x, y, c)

func _is_background(c: Color, bg: Color) -> bool:
	var diff := absf(c.r - bg.r) + absf(c.g - bg.g) + absf(c.b - bg.b)
	if diff < BG_TOLERANCE * 3.0:
		return true
	# 안내선(조금 어두운 무채색 가는 선)
	var sat := maxf(c.r, maxf(c.g, c.b)) - minf(c.r, minf(c.g, c.b))
	return sat < 0.035 and c.get_luminance() > bg.get_luminance() - 0.2 and c.get_luminance() < bg.get_luminance() + 0.05

## 밤하늘 둥근 사각형 + 달 + 산장.
func _compose(lodge: Image, size: int) -> Image:
	var out := Image.create(size, size, false, Image.FORMAT_RGBA8)
	var radius := size * 0.2
	var top := Color("2b2f5e")
	var bottom := Color("12142b")
	var moon_c := Vector2(size * 0.76, size * 0.22)
	var moon_r := size * 0.1
	for y in size:
		var t := float(y) / size
		var row := top.lerp(bottom, t)
		for x in size:
			var a := _rounded_alpha(x, y, size, radius)
			if a <= 0.0:
				continue
			var col := row
			var dm := Vector2(x, y).distance_to(moon_c)
			var glow := clampf(1.0 - (dm - moon_r) / (moon_r * 1.6), 0.0, 1.0)
			col = col.lerp(Color("b9b4ff"), glow * glow * 0.35)
			if dm < moon_r:
				col = Color("f4ecc8")
			col.a = a
			out.set_pixel(x, y, col)
	var used := lodge.get_used_rect()
	var part := lodge.get_region(used)
	var target_h := int(size * 0.84)
	var scale := float(target_h) / part.get_height()
	var target_w := int(part.get_width() * scale)
	if target_w > size * 0.9:
		target_w = int(size * 0.9)
		scale = float(target_w) / part.get_width()
		target_h = int(part.get_height() * scale)
	part.resize(target_w, target_h, Image.INTERPOLATE_LANCZOS)
	var pos := Vector2i((size - target_w) / 2, size - target_h - int(size * 0.06))
	out.blend_rect(part, Rect2i(Vector2i.ZERO, part.get_size()), pos)
	# 둥근 모서리 밖은 다시 투명하게
	for y in size:
		for x in size:
			var a := _rounded_alpha(x, y, size, radius)
			if a < 1.0:
				var c := out.get_pixel(x, y)
				c.a = minf(c.a, a)
				out.set_pixel(x, y, c)
	return out

func _rounded_alpha(x: int, y: int, size: int, r: float) -> float:
	var px := float(x) + 0.5
	var py := float(y) + 0.5
	var cx := clampf(px, r, size - r)
	var cy := clampf(py, r, size - r)
	var d := Vector2(px - cx, py - cy).length()
	return clampf(r - d + 0.5, 0.0, 1.0)

## PNG 내장 ICO(Windows Vista 이상) 작성.
func _save_ico(master: Image, path: String) -> void:
	var blobs: Array[PackedByteArray] = []
	for s in SIZES:
		var im: Image = master.duplicate()
		im.resize(s, s, Image.INTERPOLATE_LANCZOS)
		blobs.append(im.save_png_to_buffer())
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_16(0)
	f.store_16(1)
	f.store_16(SIZES.size())
	var offset := 6 + 16 * SIZES.size()
	for i in SIZES.size():
		var s: int = SIZES[i]
		f.store_8(0 if s >= 256 else s)
		f.store_8(0 if s >= 256 else s)
		f.store_8(0)
		f.store_8(0)
		f.store_16(1)
		f.store_16(32)
		f.store_32(blobs[i].size())
		f.store_32(offset)
		offset += blobs[i].size()
	for b in blobs:
		f.store_buffer(b)
	f.close()
