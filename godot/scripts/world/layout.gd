extends RefCounted
## 장면 배치값. 산장 바닥 중심 = 원점, 1단위 = 1m, 건물 정면 = +Z.
## 화면 기준: 카메라가 +X+Z 쪽에서 내려다보므로 화면 아래 = (+X,+Z), 화면 왼쪽 위 = -X, 오른쪽 위 = -Z.
## 나무·바위 좌표는 승인 원화(04-prototype-reference-simplified)의 화면 위치를
## 같은 카메라로 역투영해 잡은 값이다(원화 측정치가 아닌 근사).

const CAMERA_TARGET := Vector3(1.0, 0.0, 1.3)
const CAMERA_YAW := 35.0
const CAMERA_PITCH := 50.0
const CAMERA_SIZE := 21.0
const CAMERA_DISTANCE := 45.0

const PLINTH_SIZE := Vector3(4.9, 0.4, 5.9)
const LODGE_RECT := Rect2(-2.45, -2.95, 4.9, 5.9)
const EXTENSION_RECT := Rect2(-5.45, -1.7, 3.2, 3.4)
## 목장 영역은 단계별로 config.gd의 PASTURE_LEVELS가 정한다(산장 +X 벽을 한 변으로 공유).

const DOOR_FRONT := Vector3(0.5, 0.0, 3.9)
const PLAYER_START := Vector3(5.3, 0.0, 6.2)
const DRAGON_ANCHOR := Vector3(0.0, 5.0, -0.3)
const CHIMNEY_TOP := Vector3(1.55, 5.17, -1.55)

## 두 숲길. 각 배열의 앞쪽이 화면 아래(카메라 쪽) 끝, 뒤쪽이 숲 안쪽 끝.
const PATH_A := [Vector2(7.5,12.5), Vector2(-1.7,8.7), Vector2(-8.2,6.4), Vector2(-13.5,4.8),
	Vector2(-18,4), Vector2(-24,5)]
const PATH_B := [Vector2(13,7.5), Vector2(10.2,1.3), Vector2(9,-6), Vector2(9,-12),
	Vector2(6.9,-15.5), Vector2(7,-20), Vector2(8,-26), Vector2(6,-27)]
const SPAWN_A := Vector3(-21.5, 0.0, 2.7)
const SPAWN_B := Vector3(6.3, 0.0, -22.5)
const TRAVELER_ROUTE := [Vector3(-14.5, 0, 4.6), Vector3(-8.2, 0, 6.4), Vector3(-3.0, 0, 6.4), Vector3(0.5, 0, 3.9)]

const BOUNDARY_RADIUS := 38.0
const GROUND_EXTENT := 104.0
const MAP_CENTER := Vector2(1.0, 1.3)
## Walkable clearings, connected by wide snow trails. Existing enemy spawns stay near the lodge.
const LANDMARKS := [
	{"id":"logging", "name":"서쪽 벌목터", "pos":Vector2(-24, 5)},
	{"id":"shrine", "name":"달빛 돌 제단", "pos":Vector2(8, -26)},
	{"id":"camp", "name":"숲속 야영지", "pos":Vector2(-20, 23)},
	{"id":"lookout", "name":"설원 전망터", "pos":Vector2(23, 18)},
]
const PATH_WEST := [Vector2(-13.5,4.8), Vector2(-24,5), Vector2(-29,1), Vector2(-30,-6),
	Vector2(-25,-13), Vector2(-19,-18), Vector2(-9,-23), Vector2(0,-27), Vector2(8,-26)]
const PATH_NORTH := [Vector2(8,-26), Vector2(15,-28), Vector2(23,-24), Vector2(29,-18),
	Vector2(30,-8), Vector2(27,1), Vector2(27,9), Vector2(23,18)]
const PATH_SOUTH := [Vector2(-24,5), Vector2(-29,12), Vector2(-26,19), Vector2(-20,23),
	Vector2(-12,27), Vector2(-2,30), Vector2(10,27), Vector2(18,24), Vector2(23,18)]
const PATH_HOME := [Vector2(-20,23), Vector2(-16,18), Vector2(-9,17), Vector2(-1,15),
	Vector2(7.5,12.5), Vector2(15,13), Vector2(21,16), Vector2(23,18)]
const EXPLORATION_PATHS := [PATH_A, PATH_B, PATH_WEST, PATH_NORTH, PATH_SOUTH, PATH_HOME]

## [x, z, 높이]
## Resource wrappers keep their original coordinates. Decorative forest lives in forest_layout.json.
const TREES := [[-7.9,-1.5,6.0],[-1.9,-9.6,6.6],[-3.4,11.8,5.6]]
## [x, z, 크기]
const ROCKS := []
const SHRUBS := []
const LOGS := []
const STEPPING_STONES := [[-0.4, 5.8], [1.7, 5.5], [3.8, 5.9], [6.6, 6.9], [8.2, 7.3]]


static func seg_dist(p: Vector2, a: Vector2, b: Vector2) -> float:
	var ab := b - a
	var t := clampf((p - a).dot(ab) / ab.length_squared(), 0.0, 1.0)
	return p.distance_to(a + ab * t)


static func dist_to_path(p: Vector2, path: Array, from_index := 0) -> float:
	var best := 1e9
	for i in range(from_index, path.size() - 1):
		best = minf(best, seg_dist(p, path[i], path[i + 1]))
	return best


static func dist_to_paths(p: Vector2, from_index := 0) -> float:
	return minf(dist_to_path(p, PATH_A, from_index), dist_to_path(p, PATH_B, from_index))


static func dist_to_trails(p: Vector2) -> float:
	var best := 1e9
	for path in EXPLORATION_PATHS:
		best = minf(best, dist_to_path(p, path))
	return best


static func clamp_to_map(p: Vector3, margin := 1.0) -> Vector3:
	var flat := Vector2(p.x, p.z) - MAP_CENTER
	flat = flat.limit_length(BOUNDARY_RADIUS - margin) + MAP_CENTER
	return Vector3(flat.x, 0.0, flat.y)
