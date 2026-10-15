extends RefCounted
## Single source for terrain, clearing exclusions, inhabitants and map markers.
const SITES := [
	{"id":"venom_hollow", "label":"맹독 균열지", "center":Vector2(-23,-13), "radii":Vector2(8.0,6.8), "seed":61015, "count":6},
	{"id":"wing_nest", "label":"독날개 군락", "center":Vector2(26,-10), "radii":Vector2(6.4,7.4), "seed":61016, "count":5},
	{"id":"blighted_roots", "label":"오염된 뿌리숲", "center":Vector2(-4,28), "radii":Vector2(6.2,5.4), "seed":61017, "count":4},
]

static func normalized_distance(point: Vector2, site: Dictionary) -> float:
	return ((point-site.center)/site.radii).length()

static func clearing_at(point: Vector2) -> bool:
	for site in SITES:
		if normalized_distance(point,site)<.94: return true
	return false

static func influence_at(point: Vector2) -> float:
	var value := 0.0
	for site in SITES:
		value = maxf(value,1.0-smoothstep(.55,1.55,normalized_distance(point,site)))
	return value

static func site_at(point: Vector2) -> Dictionary:
	for site in SITES:
		if normalized_distance(point,site)<1.15: return site
	return {}
