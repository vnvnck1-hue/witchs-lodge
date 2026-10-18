extends SceneTree
## 생성 소품 시트(witch-props-v02.png)에서 손패 후면 소품 7개를 잘라 승인 v04 시안의 방향·구도에 맞춰 굽는다.
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/bake_hand_props.gd
## 이후 --import 로 가져오기를 갱신한다. 색은 시트 원본 그대로 쓴다.

const SHEET := "res://assets/ui/hand_workbench/witch-props-v02.png"
const OUT := "res://assets/ui/hand_workbench/props-v05/"

# 시트의 빈 열·행 구간으로 나눈 소품 영역, 좌우 반전, 회전(도, 화면 기준 시계 방향 +).
# 약병 묶음은 시안처럼 작은 보라 병이 왼쪽·수정이 오른쪽이 되도록 반전한다.
# 말린 약초는 라벤더 쪽이 내려가고, 두루마리는 오른쪽 끝이 살짝 올라간 시안 기울기를 따른다.
const PIECES := {
	"SpellbookAndCandle": {"rect": Rect2i(23, 92, 432, 348)},
	"PotionsAndHerbs": {"rect": Rect2i(485, 92, 398, 348), "flip": true},
	"InkAndQuill": {"rect": Rect2i(960, 92, 362, 348), "ink": true},
	"DriedHerbs": {"rect": Rect2i(1364, 92, 388, 348), "rotate": 10.0},
	"RolledParchment": {"rect": Rect2i(38, 526, 410, 301), "rotate": -6.0},
	"IngredientPouch": {"rect": Rect2i(551, 526, 281, 301)},
	"MoonCharm": {"rect": Rect2i(1024, 526, 169, 301)},
}

# 잉크병 분리(잘라낸 잉크·깃펜 조각의 로컬 좌표). 병 몸통과 앞쪽 입구 테두리를 병 레이어로 둔다.
const INKWELL_MASK := [Vector2(0, 40), Vector2(108, 40), Vector2(108, 85), Vector2(140, 85),
	Vector2(140, 190), Vector2(0, 190)]
# 시안의 깃펜은 병 입구에서 왼쪽 위로 약 45도 솟고, 병 폭 대비 길이가 시트보다 짧다.
const QUILL_PIVOT := Vector2(88, 66)
const QUILL_ROTATE := -38.0
const QUILL_SCALE := 0.82


func _init() -> void:
	var sheet := Image.load_from_file(ProjectSettings.globalize_path(SHEET))
	sheet.convert(Image.FORMAT_RGBA8)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	for id in PIECES:
		var spec: Dictionary = PIECES[id]
		var img := trim(sheet.get_region(spec["rect"]))
		if spec.get("ink", false):
			img = compose_ink(img)
		if spec.get("rotate", 0.0) != 0.0:
			img = transform(img, spec["rotate"], 1.0, Vector2(img.get_size()) * 0.5) as Image
		if spec.get("flip", false) or spec.get("ink", false):
			img.flip_x()
		img = trim(img)
		img.save_png(ProjectSettings.globalize_path(OUT + id + ".png"))
		print("BAKE ", id, " ", img.get_size())
	quit()


## 시트 전체에 깔린 거의 투명한 잡티를 지운 뒤 실제 소품 경계로 자른다.
func trim(img: Image) -> Image:
	for y in img.get_height():
		for x in img.get_width():
			if img.get_pixel(x, y).a < 0.06:
				img.set_pixel(x, y, Color(0, 0, 0, 0))
	var used := img.get_used_rect()
	return img.get_region(used)


func compose_ink(img: Image) -> Image:
	var mask := PackedVector2Array(INKWELL_MASK)
	var well := Image.create(img.get_width(), img.get_height(), false, Image.FORMAT_RGBA8)
	var quill := Image.create(img.get_width(), img.get_height(), false, Image.FORMAT_RGBA8)
	for y in img.get_height():
		for x in img.get_width():
			var c := img.get_pixel(x, y)
			if Geometry2D.is_point_in_polygon(Vector2(x + 0.5, y + 0.5), mask):
				well.set_pixel(x, y, c)
			else:
				quill.set_pixel(x, y, c)
	var turned: Dictionary = transform(quill, QUILL_ROTATE, QUILL_SCALE, QUILL_PIVOT, true)
	var canvas: Image = turned["image"]
	var offset: Vector2i = turned["origin"]
	# 깃펜 위에 병을 덮어 깃대가 입구 안으로 들어간 것처럼 보이게 한다.
	canvas.blend_rect(well, Rect2i(Vector2i.ZERO, well.get_size()), -offset)
	return canvas


## 회전·축소한 이미지를 새 캔버스에 그린다. keep_origin이면 원본 (0,0)의 새 위치도 돌려준다.
func transform(img: Image, degrees: float, scale: float, pivot: Vector2, keep_origin := false):
	var xf := Transform2D(deg_to_rad(degrees), Vector2.ONE * scale, 0.0, Vector2.ZERO)
	xf.origin = pivot - xf.basis_xform(pivot)
	var w := img.get_width()
	var h := img.get_height()
	var lo := Vector2(INF, INF)
	var hi := Vector2(-INF, -INF)
	for p in [Vector2(0, 0), Vector2(w, 0), Vector2(0, h), Vector2(w, h), Vector2.ZERO]:
		var q: Vector2 = xf * p
		lo = lo.min(q)
		hi = hi.max(q)
	# 원본 영역도 포함해 이후 합성 좌표를 맞춘다.
	lo = lo.min(Vector2.ZERO).floor()
	hi = hi.max(Vector2(w, h)).ceil()
	var out := Image.create(int(hi.x - lo.x), int(hi.y - lo.y), false, Image.FORMAT_RGBA8)
	var inv := xf.affine_inverse()
	for y in out.get_height():
		for x in out.get_width():
			var src := inv * (Vector2(x, y) + lo + Vector2(0.5, 0.5)) - Vector2(0.5, 0.5)
			out.set_pixel(x, y, sample(img, src))
	if keep_origin:
		return {"image": out, "origin": Vector2i(lo)}
	return out


## 투명 경계에 검은 테가 생기지 않게 알파 곱 보간.
func sample(img: Image, p: Vector2) -> Color:
	var x0 := floori(p.x)
	var y0 := floori(p.y)
	var fx := p.x - x0
	var fy := p.y - y0
	var acc := Color(0, 0, 0, 0)
	for k in 4:
		var dx := k % 2
		var dy := k / 2
		var wt := (fx if dx else 1.0 - fx) * (fy if dy else 1.0 - fy)
		var xx := x0 + dx
		var yy := y0 + dy
		if wt <= 0.0 or xx < 0 or yy < 0 or xx >= img.get_width() or yy >= img.get_height():
			continue
		var c := img.get_pixel(xx, yy)
		acc += Color(c.r * c.a, c.g * c.a, c.b * c.a, c.a) * wt
	if acc.a <= 0.001:
		return Color(0, 0, 0, 0)
	return Color(acc.r / acc.a, acc.g / acc.a, acc.b / acc.a, acc.a)
