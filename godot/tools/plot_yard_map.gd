extends SceneTree
## 산장 주변 배치 평면도(헤드리스, 화면 방향 기준). 길·예약 공터·후면 띠·숲 군집·식생 구분선 시안을
## SVG로 그려 PNG로 저장한다. 실제 렌더 없이 배치 관계를 검토하기 위한 도구.
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/plot_yard_map.gd [-- --variant=<id>|all]
## 결과: output/yard-hedges-v01/map-<variant>.png (프로젝트 루트 기준)

const Layout := preload("res://scripts/world/layout.gd")
const Cfg := preload("res://scripts/config.gd")
const Forest := preload("res://scripts/world/forest_composition.gd")
const Hedges := preload("res://scripts/world/yard_hedges.gd")
const RearBlocker := preload("res://scripts/world/rear_blocker.gd")
const OUT := "res://../output/yard-hedges-v01/"
## 그릴 범위(화면 좌표, m). 화면 오른쪽 = 월드 (0.819,-0.574), 화면 아래 = (0.574,0.819).
const SX := Vector2(-30.0, 30.0)
const SY := Vector2(-22.0, 24.0)
const PPM := 22.0


func _initialize() -> void:
	var variants: Array = []
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--variant="):
			var v := arg.get_slice("=", 1)
			variants = Hedges.VARIANTS.keys() if v == "all" else [v]
	if variants.is_empty(): variants = ["none"]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	for v in variants:
		var svg: String = _svg(v)
		var img := Image.new()
		var err := img.load_svg_from_string(svg, 1.0)
		if err != OK:
			push_error("SVG rasterize failed: " + str(err))
			quit(1)
			return
		var path: String = OUT + "map-" + v + ".png"
		img.save_png(path)
		var f := FileAccess.open(OUT + "map-" + v + ".svg", FileAccess.WRITE)
		f.store_string(svg)
		f.close()
		print("PLOT ", ProjectSettings.globalize_path(path), " ", img.get_size())
		var counts := {}
		for part in Hedges.parts_for(v):
			var key: String = part.band + "/" + part.kind
			counts[key] = counts.get(key, 0) + 1
		print("COUNTS ", v, " total=", Hedges.parts_for(v).size(), " ", counts)
		var rej := {}
		for k in Hedges.reject_log:
			if not k.contains("decor"): rej[k] = Hedges.reject_log[k]
		print("REJECT ", v, " ", rej)
		Hedges.reject_log.clear()
	quit(0)


static func scr(p: Vector2) -> Vector2:
	return Vector2(0.819 * p.x - 0.574 * p.y, 0.574 * p.x + 0.819 * p.y)


func px(p: Vector2) -> Vector2:
	var s := scr(p)
	return Vector2((s.x - SX.x) * PPM, (s.y - SY.x) * PPM)


func poly(points: Array, stroke: String, width: float, fill := "none", dash := "") -> String:
	var pts := PackedStringArray()
	for p in points:
		var q := px(p)
		pts.append("%.1f,%.1f" % [q.x, q.y])
	var extra := (' stroke-dasharray="%s"' % dash) if dash != "" else ""
	return '<polyline points="%s" fill="%s" stroke="%s" stroke-width="%.1f" stroke-linejoin="round" stroke-linecap="round"%s/>\n' % [" ".join(pts), fill, stroke, width, extra]


func rect_poly(r: Rect2) -> Array:
	return [r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y), r.position]


func circle(p: Vector2, r_m: float, fill: String, stroke := "none", opacity := 1.0) -> String:
	var q := px(p)
	return '<circle cx="%.1f" cy="%.1f" r="%.1f" fill="%s" stroke="%s" stroke-width="1" opacity="%.2f"/>\n' % [q.x, q.y, r_m * PPM, fill, stroke, opacity]


func text(p: Vector2, s: String, size := 13, color := "#222") -> String:
	var q := px(p)
	return '<text x="%.1f" y="%.1f" font-size="%d" font-family="sans-serif" fill="%s" text-anchor="middle">%s</text>\n' % [q.x, q.y, size, color, s]


func _svg(variant: String) -> String:
	var w := int((SX.y - SX.x) * PPM)
	var h := int((SY.y - SY.x) * PPM)
	var s := '<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" viewBox="0 0 %d %d">\n' % [w, h, w, h]
	s += '<rect width="%d" height="%d" fill="#eef0f8"/>\n' % [w, h]
	# 5m 격자(월드 축)
	for gx in range(-40, 45, 5):
		s += poly([Vector2(gx, -45), Vector2(gx, 45)], "#dcdfea", 1)
	for gz in range(-40, 45, 5):
		s += poly([Vector2(-45, gz), Vector2(45, gz)], "#dcdfea", 1)
	# 오염 지역(숲 부품이 비워지는 타원)
	for site in load("res://scripts/world/hazard_sites.gd").SITES:
		var pts: Array = []
		for i in 33:
			var a := TAU * i / 32.0
			pts.append(site.center + Vector2(cos(a) * site.radii.x, sin(a) * site.radii.y))
		s += poly(pts, "#c9a7d8", 1.2, "#e9dcf0", "4,3")
	# 길(통행 여유 2.8m 띠 + 중심선)
	for path in Layout.EXPLORATION_PATHS:
		s += poly(path, "#d9c9b0", 2.8 * 2 * PPM, "none")
	for path in Layout.EXPLORATION_PATHS:
		s += poly(path, "#b89468", 1.8 * 2 * PPM, "none")
	for path in Layout.EXPLORATION_PATHS:
		s += poly(path, "#7a5a36", 1.2, "none")
	# 예약 영역·건물
	s += poly(rect_poly(Layout.EXTENSION_RESERVE), "#8a7fb5", 1.5, "#d9d3ee", "6,4")
	s += poly(rect_poly(Layout.LODGE_RECT), "#5a3b2a", 2, "#c58a63")
	s += poly(rect_poly(Cfg.PASTURE_LEVELS[-1].rect), "#7a5a36", 1.2, "none", "3,3")
	s += poly(rect_poly(Cfg.PASTURE_LEVELS[0].rect), "#7a5a36", 1.5, "#e8d8b8")
	for c in [Layout.TOWER_SITE_LEFT, Layout.TOWER_SITE_RIGHT]:
		s += poly(rect_poly(Layout.tower_site_rect(c)), "#6b5a4a", 1.5, "#cbb59a")
	s += circle(Layout.ALTAR_SITE, Layout.ALTAR_SITE_RADIUS, "#cbb59a", "#6b5a4a")
	s += circle(Vector2(Layout.CAMPFIRE.x, Layout.CAMPFIRE.z), Layout.REST_RING_OUTER + 0.6, "#f3dcc0", "#c07a3a")
	s += circle(Vector2(Layout.CAMPFIRE.x, Layout.CAMPFIRE.z), 0.5, "#e8702a")
	# 후면 차단 띠
	s += poly(Layout.REAR_BLOCKER, "#6d6a7a", Layout.REAR_BLOCKER_THICKNESS * PPM, "#cfcbd8")
	for p in RearBlocker.PINES:
		s += circle(Vector2(p[0], p[1]), 1.0, "#3f6b4f", "none", 0.8)
	# 스폰·손님 경로
	s += circle(Vector2(Layout.SPAWN_A.x, Layout.SPAWN_A.z), 0.8, "#d33")
	s += circle(Vector2(Layout.SPAWN_B.x, Layout.SPAWN_B.z), 0.8, "#d33")
	# 기존 숲 군집(나무 = 짙은 초록 수관, 바위 = 회색, 하층 = 작은 연두)
	for group in Forest.layout().groups:
		for part in group.parts:
			var p := Vector2(part.position[0], part.position[1])
			if part.kind == "tree":
				s += circle(p, maxf(part.canopy_radius, 0.6), "#3f6b4f", "none", 0.75)
			elif part.kind == "rock":
				s += circle(p, maxf(part.collider_radius, 0.4), "#8c8c96", "#55555f", 0.9)
			else:
				s += circle(p, 0.3, "#8fc07a", "none", 0.9)
	for t in Layout.TREES:
		s += circle(Vector2(t[0], t[1]), 1.6, "#2f8a4f", "#1e5a33", 0.85)
	# 시안 식생 구분선
	if variant != "none" and Hedges.VARIANTS.has(variant):
		for part in Hedges.parts_for(variant):
			var p: Vector2 = part.at
			match part.kind:
				"tree": s += circle(p, maxf(part.radius, 0.6), "#1d4d7a", "none", 0.75)
				"rock": s += circle(p, maxf(part.radius, 0.4), "#5b5f8c", "#2b2f55", 0.95)
				_: s += circle(p, 0.32, "#4aa0c8", "none", 0.95)
		for band in Hedges.BANDS:
			s += poly(band.points, "#1b3f6b", 1.0, "none", "2,3")
			s += text(band.points[0], band.id, 11, "#1b3f6b")
	# 라벨
	s += text(Vector2(0, 0.2), "산장", 14, "#fff")
	s += text(Layout.EXTENSION_RESERVE.get_center(), "증축 예약", 12, "#4a3f78")
	s += text(Cfg.PASTURE_LEVELS[0].rect.get_center(), "목장", 12)
	s += text(Vector2(Layout.CAMPFIRE.x, Layout.CAMPFIRE.z + 0.9), "모닥불", 11)
	s += text(Layout.TOWER_SITE_LEFT, "탑 L", 11)
	s += text(Layout.TOWER_SITE_RIGHT, "탑 R", 11)
	s += text(Layout.ALTAR_SITE, "제단 공터", 11)
	s += text(Vector2(Layout.SPAWN_A.x, Layout.SPAWN_A.z - 1.4), "스폰 A", 11, "#a22")
	s += text(Vector2(Layout.SPAWN_B.x, Layout.SPAWN_B.z - 1.4), "스폰 B", 11, "#a22")
	s += text(Vector2(-24, 5), "벌목터", 11)
	s += text(Vector2(-20, 23), "야영지", 11)
	s += text(Vector2(23, 18), "전망터", 11)
	s += text(Vector2(8, -26), "달빛 제단", 11)
	s += '<text x="12" y="20" font-size="15" font-family="sans-serif" fill="#222">yard map · variant=%s · 화면 방향(카메라 yaw 35°) · 격자 5m · 갈색 띠=길(1.8m), 연한 띠=통행 여유 2.8m</text>\n' % variant
	s += "</svg>\n"
	return s
