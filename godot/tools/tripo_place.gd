extends SceneTree
## Tripo 프랍을 숲 배치 데이터(assets/environment/forest_layout.json)에 넣는다(헤드리스).
##
##   .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/tripo_place.gd
##
## 입력: art_sources/tripo/placements.json
##   {"props": [{"asset": "tripo_x", "group": "lodge_west", "kind": "rock", "scale": 1.0,
##               "at": [x, z] (선택), "yaw": 도 (선택), "clearance": 2.0 (선택), "role": "tripo_prop"}]}
##   - kind "rock" 은 충돌체(장애물·내비 구멍)를 만들고, "decor" 는 장식만 둔다.
##   - at 이 없으면 군집(group) 중심 근처에서 게임과 같은 규칙으로 자리를 찾는다:
##     맹독 지역 밖, 마당 예약 공간 밖, 지도 안, 길에서 clearance+반경 이상, 기존 나무·바위 충돌체와 겹치지 않음.
##   - yaw 가 없으면 프랍 앞면(+Z)이 가장 가까운 길을 바라본다.
## 반복 실행해도 같다: 이전 tripo_* 부품을 모두 지우고 목록대로 다시 넣는다.
## build_forest_layout.py 로 숲을 새로 만들면 place_user_rocks.py 등과 함께 이것도 다시 돌린다.

const Layout := preload("res://scripts/world/layout.gd")
const Hazards := preload("res://scripts/world/hazard_sites.gd")
const LAYOUT := "res://assets/environment/forest_layout.json"
const PLACEMENTS := "res://art_sources/tripo/placements.json"
const FOOTPRINT := .45

func _initialize() -> void:
	quit(place())

func nearest_trail_point(p: Vector2) -> Vector2:
	var best := p
	var best_d := 1e9
	for path in Layout.EXPLORATION_PATHS:
		for i in path.size() - 1:
			var a: Vector2 = path[i]
			var ab: Vector2 = path[i + 1] - a
			var q := a + ab * clampf((p - a).dot(ab) / ab.length_squared(), 0.0, 1.0)
			if p.distance_to(q) < best_d: best_d = p.distance_to(q); best = q
	return best

func colliders(data: Dictionary) -> Array:
	var out := []
	for g in data.groups:
		for part in g.parts:
			if part.kind in ["rock", "tree"]:
				out.append([Vector2(part.position[0], part.position[1]), float(part.collider_radius)])
	return out

func spot_ok(p: Vector2, r: float, clearance: float, solid: Array) -> bool:
	if Hazards.clearing_at(p) or Layout.in_yard_reserve(p, r): return false
	if p.distance_to(Layout.MAP_CENTER) > Layout.BOUNDARY_RADIUS - 2.0 - r: return false
	if Layout.dist_to_trails(p) < clearance + r: return false
	for c in solid:
		if p.distance_to(c[0]) < r + c[1] + .15: return false
	return true

func find_spot(group: Dictionary, r: float, clearance: float, solid: Array) -> Variant:
	var c := Vector2(group.center[0], group.center[1])
	var radii := Vector2(group.radii[0], group.radii[1]) * 1.6 + Vector2.ONE * r
	var best: Variant = null
	var best_d := 1e9
	var step := 0.5
	for ix in range(-int(radii.x / step), int(radii.x / step) + 1):
		for iz in range(-int(radii.y / step), int(radii.y / step) + 1):
			var off := Vector2(ix * step, iz * step)
			if (off / radii).length() > 1.0: continue
			var p := c + off.rotated(deg_to_rad(float(group.get("yaw", 0.0))))
			var d := p.distance_to(c)
			if d < best_d and spot_ok(p, r, clearance, solid): best = p; best_d = d
	return best

func place() -> int:
	if not FileAccess.file_exists(PLACEMENTS):
		push_error("배치 목록이 없습니다: " + PLACEMENTS); return 1
	var plan: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(PLACEMENTS))
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(LAYOUT))
	var groups := {}
	for g in data.groups:
		g.parts = g.parts.filter(func(p): return not str(p.asset).begins_with("tripo_"))
		groups[g.id] = g
	var placed := []
	var removed := 0
	for item: Dictionary in plan.get("props", []):
		var asset: String = item.asset
		var report_path := "res://assets/tripo/%s/report.json" % asset
		if not FileAccess.file_exists(report_path) or not ResourceLoader.exists("res://scenes/props/nature/%s.tscn" % asset):
			push_error("먼저 임포트하세요: " + asset); return 1
		if not groups.has(item.group):
			push_error("없는 군집: %s (forest_layout.json groups[].id)" % item.group); return 1
		var g: Dictionary = groups[item.group]
		var report: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(report_path))
		var s := float(item.get("scale", 1.0))
		var size: Array = report.size_m
		var r := snappedf(maxf(size[0], size[2]) * s * FOOTPRINT, .001)
		var clearance := float(item.get("clearance", 2.0))
		var p: Variant
		if item.has("at"):
			p = Vector2(item.at[0], item.at[1])
			if not spot_ok(p, r, clearance, colliders(data)): push_warning("지정 위치가 배치 규칙에 맞지 않습니다: %s %s" % [asset, p])
		else:
			p = find_spot(g, r, clearance, colliders(data))
			if p == null:
				push_error("자리를 찾지 못했습니다: %s @ %s (scale·clearance 를 줄이거나 다른 군집)" % [asset, item.group]); return 1
		var at: Vector2 = p
		var yaw: float
		if item.has("yaw"): yaw = float(item.yaw)
		else:
			var q := nearest_trail_point(at)
			yaw = rad_to_deg(atan2(q.x - at.x, q.y - at.y))
		var before: int = g.parts.size()
		g.parts = g.parts.filter(func(part): return part.kind != "decor" \
			or Vector2(part.position[0], part.position[1]).distance_to(at) > r * 1.05)
		removed += before - g.parts.size()
		var part := {"kind": item.get("kind", "rock"), "asset": asset,
			"position": [snappedf(at.x, .001), snappedf(at.y, .001)], "scale": [s, s, s],
			"rotation": [0, snappedf(yaw, .01), 0], "role": item.get("role", "tripo_prop"),
			"collider_radius": r, "height": snappedf(float(size[1]) * s, .001),
			"canopy_radius": snappedf(maxf(size[0], size[2]) * s * .5, .001)}
		g.parts.append(part)
		placed.append({"asset": asset, "group": item.group, "position": part.position, "yaw": part.rotation[1]})
	var kinds := {}
	var assets := {}
	var total := 0
	for g in data.groups:
		for part in g.parts:
			total += 1
			kinds[part.kind] = kinds.get(part.kind, 0) + 1
			assets[part.asset] = true
	data.stats.parts = total
	data.stats.kinds = kinds
	data.stats.asset_types = assets.size()
	var f := FileAccess.open(LAYOUT, FileAccess.WRITE)
	f.store_string(JSON.stringify(data, "  ", false))
	f.close()
	print("TRIPO_PLACED ", placed.size(), " decor_removed ", removed, " ", JSON.stringify(placed))
	return 0
