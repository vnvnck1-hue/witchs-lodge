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
const SHEEP_START := 3

# 목장 단계: 울타리 영역(x, z, 가로, 세로)과 최대 양 수. 산장 +X 벽을 한 변으로 공유한다.
const PASTURE_LEVELS := [
	{"rect": Rect2(2.45, -2.0, 3.7, 4.6), "cap": 4},
	{"rect": Rect2(2.45, -2.4, 4.5, 5.2), "cap": 6},
	{"rect": Rect2(2.45, -2.9, 5.3, 5.8), "cap": 8},
]
# 묘지 단계별 최대 무덤 수(산장 뒤편)
const GRAVE_LEVELS := [4, 6, 8]

# 건축: 생성·증축·업그레이드는 골드와 함께 목재가 든다. 키 = 구매 종류, 배열 = 다음 단계별 비용
const BUILD_COSTS := {
	"extension": [{"gold": 60, "timber": 10}],
	"pasture": [{"gold": 40, "timber": 8}, {"gold": 60, "timber": 12}],
	"graves": [{"gold": 30, "timber": 6}, {"gold": 45, "timber": 10}],
}

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

# 카드 코어 C0 — 기획서 v0.3 §5~9·11·12의 시험값
const START_GOLD := 40
const CONTRACT_COST := 30
const HIRE_WAIT := 10.0
const HIRE_BATCHES := [0, 1]          # 하루 2명: 첫·둘째 숙박 묶음에서 1명씩 고용 기회
const MERC_NAMES := ["브람", "올라프", "토르빈", "하겐", "에이릭", "군나르", "울프", "스벤", "레이프", "비요른"]
const ACTIVE_LIMIT := 4               # 용병+하수인 동시 활동 상한(미사용 카드는 제외)
const HAND_VISIBLE := 8               # 손패 가시 장수. 넘치면 창고에 보관
const CHOP_TIME := 15.0
const CHOP_YIELD := 10
const TREE_TIMBER := 20               # 자원 나무 한 그루의 목재량(벌목 2회)
const HARVEST_TREES := [[-7.9, -1.5], [-1.9, -9.6], [-3.4, 11.8]]
const WOOL_PRICE := 4
const HARVEST_RANGE := 0.8           # 목장 안에서 양 바로 옆까지 다가간다
const HARVEST_TIME := 2.2            # 털 깎기 모션 시간(진행 게이지 표시)
const TIMBER_REPAIR_COST := 5
const TIMBER_REPAIR_AMOUNT := 100.0
const MERC_HP := 40.0
const MERC_DAMAGE := 8.0
const MERC_INTERVAL := 1.5
const MERC_SPEED := 2.6
const MERC_REGEN := 1.0               # 낮 동안 초당 회복(용병은 죽기 전까지 산장에 남는다)
const MINION_HP := 48.0
const MINION_DAMAGE := 6.0
const MINION_INTERVAL := 1.6
const MINION_TIMBER := 1              # 숲의 괴물 하수인은 죽거나 낮이 되면 목재 1개가 된다
# 큰 숲의 괴물: 카드로 변환되는 표식 개체(기본 숲의 괴물보다 크고 등에 가지가 돋음)
const BIG_MONSTER_HP_MULT := 1.7
const BIG_MONSTER_SCALE := 1.32
const BIG_MONSTER_SPEED := 1.5
const BIG_MONSTER_DAMAGE := 7.0
const ALLY_MELEE := 1.3
const ALLY_AGGRO := 6.0               # 기준 지점에서 적을 찾는 반경(기획의 사거리6m 비교값)
const ALLY_LEASH := 8.0
const CARD_MONSTER_INDEX := [2, 4, 8] # 웨이브별 카드 획득 대상(출현 순서). 표식이 붙은 개체

# 신규 카드 v01 — 서리 룬·수호 등불·숙박 초대장·새끼양(시험값)
const STARTER_CARDS := [["frost_rune", 1], ["ward_lantern", 1], ["guest_invitation", 1], ["lamb", 1]]
const FROST_RADIUS := 2.6
const FROST_DAMAGE := 18.0
const FROST_SLOW := 0.45              # 이동 속도 배율
const FROST_SLOW_TIME := 5.0
const LANTERN_RADIUS := 3.5
const LANTERN_SLOW := 0.65            # 빛 안의 적 이동 속도 배율
const LANTERN_SIGHT := 5.0            # 안개를 걷어 내는 반경
const LANTERN_LIMIT := 2              # 동시에 켜 둘 수 있는 등불 수(밤 전투가 끝나면 꺼진다)
const INVITE_MIN_TIME := GUEST_STAY + 2.0  # 손님이 숙박비를 낼 수 있도록 남아 있어야 할 준비 시간
const LAMB_GROW_DAYS := 2             # 들인 날로부터 이틀 뒤 낮에 어른 양이 된다
const LAMB_HP := 15.0
const LAMB_SCALE := 0.6

# 물리 레이어 비트
const L_GROUND := 1
const L_OBSTACLE := 2   # 산장·나무 줄기·큰 바위: 이동 차단 + 시야 차단
const L_BOUNDARY := 4   # 울타리·숲 경계: 이동만 차단
const L_ACTOR := 8
