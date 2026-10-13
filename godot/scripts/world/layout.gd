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
## 목장: x 2.45..5.65, z -1.6..2.4 (산장 +X 벽을 한 변으로 공유)
const PASTURE_RECT := Rect2(2.45, -1.6, 3.2, 4.0)
const GATE_Z := Vector2(0.1, 1.6)

const DOOR_FRONT := Vector3(0.5, 0.0, 3.9)
const PLAYER_START := Vector3(5.3, 0.0, 6.2)
const DRAGON_ANCHOR := Vector3(0.0, 5.0, -0.3)
const CHIMNEY_TOP := Vector3(1.55, 5.17, -1.55)

## 두 숲길. 각 배열의 앞쪽이 화면 아래(카메라 쪽) 끝, 뒤쪽이 숲 안쪽 끝.
const PATH_A := [Vector2(7.5, 12.5), Vector2(-1.7, 8.7), Vector2(-8.2, 6.4), Vector2(-13.5, 4.8),
	Vector2(-17.5, 3.7), Vector2(-26.0, 1.6)]
const PATH_B := [Vector2(13.0, 7.5), Vector2(9.9, -2.9), Vector2(8.1, -9.8), Vector2(6.9, -15.5),
	Vector2(6.6, -19.5), Vector2(6.0, -27.0)]
const SPAWN_A := Vector3(-21.5, 0.0, 2.7)
const SPAWN_B := Vector3(6.3, 0.0, -22.5)
const TRAVELER_ROUTE := [Vector3(-14.5, 0, 4.6), Vector3(-8.2, 0, 6.4), Vector3(-3.0, 0, 6.4), Vector3(0.5, 0, 3.9)]

const BOUNDARY_RADIUS := 16.0

## [x, z, 높이]
const TREES := [
	[-17.5, 8.1, 7.0], [-15.8, 10.6, 6.4], [-11.1, 10.1, 6.0], [-10.6, 15.4, 7.2],
	[-4.6, 16.0, 6.6], [-4.9, 20.5, 7.0], [-3.4, 11.8, 5.6], [3.0, 14.2, 6.2],
	[-12.5, 0.4, 6.6], [-7.9, -1.5, 6.0], [-1.9, -9.6, 6.6], [2.1, -14.6, 7.2],
	[4.0, -12.6, 5.8], [10.0, -15.0, 6.6], [13.5, -11.0, 7.0], [16.2, -5.8, 6.4],
	[17.2, -1.6, 6.8], [19.6, -4.3, 7.4],
]
## [x, z, 크기]
const ROCKS := [[-10.7, 2.4, 1.75], [3.5, -10.3, 1.6], [16.3, 3.7, 1.7]]
const SHRUBS := [[-8.9, 9.2], [11.9, -7.0]]
const LOGS := [[-2.4, 14.6, 25.0]]
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
