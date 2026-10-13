extends RefCounted
## 밸런스 초기값. 인수인계 문서 6~10절의 "초기 설계" 수치이며 플레이테스트로 조정한다.

# 준비·숙박
const PREP_TIME := 90.0
const GUEST_ARRIVALS := [5.0, 30.0, 60.0]
const GUEST_STAY := 20.0
const GUEST_FEE := 15
const BASE_CAPACITY := 2
const EXT_CAPACITY := 3
const GUEST_WALK_SPEED := 2.2

# 구매
const COST_EXTENSION := 60
const COST_DRAGON := 120
const COST_REPAIR := 10
const COST_HEAL := 10
const COST_SHEEP := 20
const REPAIR_AMOUNT := 50.0
const HEAL_AMOUNT := 50.0

# 플레이어
const PLAYER_HP := 100.0
const PLAYER_SPEED := 3.5
const BOLT_DAMAGE := 12.0
const BOLT_INTERVAL := 1.0
const BOLT_RANGE := 4.0
const BOLT_SPEED := 10.0

# 산장·양
const LODGE_HP := 300.0
const SHEEP_HP := 30.0
const SHEEP_MAX := 3

# 몬스터
const MONSTER_SPEED := 1.7
const MONSTER_MELEE := 1.2
const MONSTER_DAMAGE := 5.0
const MONSTER_INTERVAL := 2.0

# 웨이브: groups = [[출현 시각(초), 인원], ...]
const WAVES := [
	{"count": 5, "hp": 36.0, "sheep": 1, "groups": [[0.0, 3], [8.0, 2]]},
	{"count": 9, "hp": 48.0, "sheep": 3, "groups": [[0.0, 3], [5.0, 3], [10.0, 3]]},
	{"count": 18, "hp": 60.0, "sheep": 4,
		"groups": [[0.0, 3], [3.0, 3], [6.0, 3], [9.0, 3], [12.0, 3], [15.0, 3]]},
]

# 용
const DRAGON_SUMMON_TIME := 1.0
const DRAGON_FIRE_INTERVAL := 2.0
const DRAGON_LEAVE_TIME := 3.0
const FIREBALL_DAMAGE := 200.0
const FIREBALL_RADIUS := 5.0
const FIREBALL_RANGE := 30.0
const FIREBALL_SPEED := 12.0

# 물리 레이어 비트
const L_GROUND := 1
const L_OBSTACLE := 2   # 산장·나무 줄기·큰 바위: 이동 차단 + 시야 차단
const L_BOUNDARY := 4   # 울타리·숲 경계: 이동만 차단
const L_ACTOR := 8
