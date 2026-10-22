extends SceneTree
## 시안(03-speech-only 발췌 2배)과 실제 캡처(2배)에서 색으로 틀·종이·글자·꺾쇠를 찾아 같은 방법으로 치수를 잰다.
## 두 줄의 숫자 차이가 곧 시안과의 차이다(단위: 화면 px, 1774 너비 기준 = 2배 크롭 / 2).
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/measure_speech_notification.gd
## 입력: docs/handoff/refs/speech-notification-concept-crop2x.png, godot/screenshots/speech-notification/2-graz-crop2x.png
## 마지막 줄 RESULT 는 항목별 |게임-시안| 최대값(화면 px).

func is_brass(c: Color) -> bool:
	return c.a > 0.5 and c.h > 0.06 and c.h < 0.12 and c.s > 0.5 and c.v > 0.4 and c.v < 0.95


func is_paper(c: Color) -> bool:
	return c.v > 0.7 and c.s > 0.1 and c.s < 0.55 and c.h > 0.07 and c.h < 0.17


func is_ink(c: Color) -> bool:
	return c.v < 0.4


## 고블린 피부(녹황색)와 금속(투구·칼날: 회색, 채도 낮음)
func is_skin(c: Color) -> bool:
	return c.a > 0.5 and c.h > 0.115 and c.h < 0.16 and c.s > 0.5 and c.s < 0.85 and c.v > 0.55 and c.v < 0.92  # 그라즈 피부(실측 h0.12~0.14 s0.6~0.8). 종이·놋쇠 제외
func is_metal(c: Color) -> bool:
	return c.a > 0.5 and c.s < 0.18 and c.v > 0.45 and c.v < 0.9


func count_rows(img: Image, pred: Callable, region: Rect2i) -> Array:
	var out := []
	for y in range(maxi(0, region.position.y), mini(img.get_height(), region.end.y)):
		var n := 0
		for x in range(maxi(0, region.position.x), mini(img.get_width(), region.end.x)):
			if pred.call(img.get_pixel(x, y)): n += 1
		out.append([y, n])
	return out


func count_cols(img: Image, pred: Callable, region: Rect2i) -> Array:
	var out := []
	for x in range(maxi(0, region.position.x), mini(img.get_width(), region.end.x)):
		var n := 0
		for y in range(maxi(0, region.position.y), mini(img.get_height(), region.end.y)):
			if pred.call(img.get_pixel(x, y)): n += 1
		out.append([x, n])
	return out


func span(counts: Array, min_n: int) -> Vector2:
	var a := -1
	var b := -1
	for c in counts:
		if c[1] >= min_n:
			if a < 0: a = c[0]
			b = c[0]
	return Vector2(a, b)


func bbox(img: Image, pred: Callable, region: Rect2i) -> Rect2:
	var l := 1e9
	var t := 1e9
	var r := -1e9
	var b := -1e9
	for y in range(maxi(0, region.position.y), mini(img.get_height(), region.end.y)):
		for x in range(maxi(0, region.position.x), mini(img.get_width(), region.end.x)):
			if pred.call(img.get_pixel(x, y)):
				l = minf(l, x); r = maxf(r, x); t = minf(t, y); b = maxf(b, y)
	return Rect2(l, t, r - l, b - t) if r >= l else Rect2()


func measure(path: String, tag: String, ring_region: Rect2) -> Dictionary:
	var img := Image.load_from_file(path)
	img.convert(Image.FORMAT_RGBA8)
	var W := img.get_width()
	var H := img.get_height()
	var rr := Rect2i(int(ring_region.position.x * W), int(ring_region.position.y * H), int(ring_region.size.x * W), int(ring_region.size.y * H))
	var ring := bbox(img, is_brass, rr)
	var rc := ring.get_center()
	var band := Rect2i(int(ring.end.x) - 60, int(rc.y - 130), W - int(ring.end.x) + 60, 260)
	var ys := span(count_rows(img, is_paper, band), 300)   # 종이가 300px(2배) 넘게 이어진 줄 = 몸통
	var body_rows := Rect2i(band.position.x, int(ys.x), band.size.x, int(ys.y - ys.x) + 1)
	var cols := count_cols(img, is_paper, body_rows)
	var xs := span(cols, int((ys.y - ys.x) * 0.6))          # 몸통 높이의 60% 이상 종이인 열
	var body := Rect2(xs.x, ys.x, xs.y - xs.x, ys.y - ys.x)
	var inner := Rect2i(int(body.position.x) + 16, int(body.position.y + body.size.y * 0.18), int(body.size.x) - 32, int(body.size.y * 0.64))
	var text := bbox(img, is_ink, Rect2i(inner.position.x, inner.position.y, int(inner.size.x * 0.75), inner.size.y))
	var chev := bbox(img, is_ink, Rect2i(inner.position.x + int(inner.size.x * 0.8), inner.position.y, int(inner.size.x * 0.2), inner.size.y))
	# 꼬리: 몸통 왼쪽 밖, 몸통 세로 범위 안의 종이 픽셀(틀 안 피부색이 섞이지 않게 틀 오른끝 오른쪽만)
	var tl := 1e9
	var ty := 0.0
	var tn := 0.0
	for y in range(int(body.position.y), int(body.end.y) + 1):
		for x in range(int(ring.end.x) - 4, int(xs.x)):
			if is_paper(img.get_pixel(x, y)):
				tl = minf(tl, x); ty += y; tn += 1.0
	var tail_len := (xs.x - tl) if tn > 0 else 0.0
	var tail_cy := ty / tn if tn > 0 else body.get_center().y
	# 인물: 틀 안팎(위로 90px 더)의 피부 상자, 틀 위로 넘친 금속(칼끝·투구)의 꼭대기
	var fig_region := Rect2i(int(ring.position.x) + 34, int(ring.position.y) - 40, int(ring.size.x) - 68, int(ring.size.y) + 40 - 34)  # 틀 띠 안쪽 + 위로 넘친 부분
	# 피부 상자는 틀 안쪽 원(띠 제외) 안에서만 센다 — 놋쇠 하이라이트가 피부색과 겹치기 때문
	var inner_r: float = ring.size.x * 0.5 - 34.0
	var skin := Rect2()
	var sl := 1e9
	var st := 1e9
	var sr := -1e9
	var sb := -1e9
	for y in range(fig_region.position.y, fig_region.end.y):
		for x in range(fig_region.position.x, fig_region.end.x):
			if Vector2(x, y).distance_to(rc) < inner_r and is_skin(img.get_pixel(x, y)):
				sl = minf(sl, x); sr = maxf(sr, x); st = minf(st, y); sb = maxf(sb, y)
	if sr >= sl: skin = Rect2(sl, st, sr - sl, sb - st)
	var metal_top := bbox(img, is_metal, Rect2i(int(ring.position.x) + 10, int(ring.position.y) - 40, int(ring.size.x) - 20, 40 + int(ring.size.y * 0.25)))
	var rad := ring.size.x * 0.5
	var s := 0.5
	var d := {"틀 지름": ring.size.x * s,
		"피부 높이/반지름": skin.size.y / rad, "피부 폭/반지름": skin.size.x / rad,
		"피부중심x-틀중심/반지름": (skin.get_center().x - rc.x) / rad, "피부중심y-틀중심/반지름": (skin.get_center().y - rc.y) / rad,
		"피부아래-틀중심/반지름": (skin.end.y - rc.y) / rad, "금속꼭대기-틀위": (metal_top.position.y - ring.position.y) * s, "몸통 폭": body.size.x * s, "몸통 높이": body.size.y * s, "몸통왼끝-틀오른끝": (body.position.x - ring.end.x) * s,
		"몸통세로중심-틀중심": (body.get_center().y - rc.y) * s, "꼬리 길이": tail_len * s, "꼬리중심-몸통중심": (tail_cy - body.get_center().y) * s,
		"글자 높이": text.size.y * s, "글자 왼여백": (text.position.x - body.position.x) * s, "꺾쇠 높이": chev.size.y * s, "꺾쇠 오른여백": (body.end.x - chev.end.x) * s}
	var line := tag
	for k in d: line += " | %s %s" % [k, ("%.2f" % d[k]) if k.contains("/") else ("%.0f" % d[k])]
	print(line)
	return d


func _initialize() -> void:
	var base := "D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/"
	var a := measure(base + "docs/handoff/refs/speech-notification-concept-crop2x.png", "시안", Rect2(0, 0, 0.4, 1.0))
	var b := measure(base + "godot/screenshots/speech-notification/2-graz-crop2x.png", "게임", Rect2(0, 0.4, 0.35, 0.6))
	var worst := 0.0
	var line := "차이(게임-시안)"
	for k in a:
		var ratio: bool = str(k).contains("/")
		line += " | %s %s" % [k, ("%+.2f" % (b[k] - a[k])) if ratio else ("%+.0f" % (b[k] - a[k]))]
		worst = maxf(worst, absf(b[k] - a[k]) * (76.0 if ratio else 1.0))   # 비율 항목은 반지름 76 화면px 기준 px 로 환산
	print(line)
	print("RESULT 최대 차이 %.0f 화면px" % worst)
	quit()
