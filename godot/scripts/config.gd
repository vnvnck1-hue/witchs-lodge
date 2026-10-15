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
const ACTIVE_LIMIT := 6               # 용병+하수인 동시 활동 상한(미사용 카드는 제외). 직업 분화 v1에서 4→6
const HAND_VISIBLE := 8               # 손패 가시 장수. 넘치면 창고에 보관
const CHOP_TIME := 15.0
const CHOP_YIELD := 10
const TREE_TIMBER := 40               # (구) 자원 나무 기준 목재량. 직업 분화 v1부터 높이별 tree_yield()를 쓴다
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
const STARTER_CARDS := [["frost_rune", 1], ["ward_lantern", 1], ["guest_invitation", 1], ["lamb", 1], ["sleeping_thorn_seed", 1], ["black_sheep", 1]]
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

# 숲 확장 카드: 낮 성장 → 밤 방책, 검은 털을 공물로 강화(시험값).
const THORN_GROW_TIME := 18.0
const THORN_LIMIT := 4
const THORN_SPACING := 1.6
const THORN_HP := 90.0
const THORN_RADIUS := 2.1
const THORN_DAMAGE := 6.0
const THORN_INTERVAL := 1.2
const THORN_SLOW := 0.35
const THORN_RITUAL_HP := 130.0
const THORN_RITUAL_DAMAGE := 10.0

# 직업 분화 v1 — 네 직업·야생 동물·채집·유물(시험값). 기획: docs/mercenary-jobs-design.md
const JOB_CARDS := ["lumberjack", "hunter", "warrior", "gatherer"]
const JOB_NAMES := {"lumberjack": "나무꾼", "hunter": "사냥꾼", "warrior": "전투용병", "gatherer": "채집가"}
const JOB_HP := {"lumberjack": 40.0, "hunter": 36.0, "warrior": 56.0, "gatherer": 34.0}
const HUNTER_RANGE := 7.0             # 활 사거리
const HUNTER_KITE := 2.0              # 이보다 가까이 붙으면 물러나며 쏜다
const HUNTER_DAMAGE := 6.0
const HUNTER_INTERVAL := 1.2
const ARROW_SPEED := 16.0
const WARRIOR_DAMAGE := 10.0
const WARRIOR_INTERVAL := 1.3
const PATROL_RADIUS := [5.5, 8.0]     # 산장 중심에서 정찰 지점 반경
const PATROL_PAUSE := [1.0, 2.0]
const ENGAGE_RADIUS := 14.0           # 산장 중심 기준 적 발견 반경
const DISENGAGE_RADIUS := 18.0        # 대상이 이보다 멀어지면 놓아준다
const HANDOVER_RANGE := 2.2           # 마녀가 이 안에 오면 들고 있던 자원을 넘긴다
const TREE_YIELD_PER_M := 6.67        # 목재량 = clamp(round(높이 × 이 값), TREE_YIELD_MIN, TREE_YIELD_MAX)
const TREE_YIELD_MIN := 8
const TREE_YIELD_MAX := 56
const TREE_ACCESS_NAV := 1.2          # 밑동에서 이 거리 안에 이동 가능 지면이 있어야 벌목 가능
const TREE_CROWD_RADIUS := 2.4        # 이 반경 안에 다른 나무가 TREE_CROWD_MAX그루 이상이면 둘러싸임
const TREE_CROWD_MAX := 3
# 야생 동물
const RABBIT_HP := 8.0
const RABBIT_SPEED := 2.2
const DEER_HP := 20.0
const DEER_SPEED := 2.6
const ANIMAL_FLEE_RADIUS := 4.0
const ANIMAL_LIFETIME := 90.0
const ANIMAL_SPAWN_INTERVAL := [20.0, 40.0]
const ANIMAL_SPAWN_RING := [9.0, 26.0]
const RABBIT_MAX := 3
const DEER_MAX := 2
const HUNT_SEARCH_RADIUS := 25.0      # 사냥꾼이 사냥감을 찾는 반경(자기 위치 기준)
const DEER_MEAT := 2
# 채집가
const GATHER_MIN_PREP := 30.0         # 카드 사용에 필요한 남은 준비 시간
const GATHER_RETURN_MARGIN := 20.0    # 준비 시간 끝나기 이만큼 전에 산장 도착
const GATHER_STOPS := 3
const GATHER_PICK_TIME := 3.0
const GATHER_TABLE := [["timber", 0.40, 2, 4], ["raw_meat", 0.20, 1, 1], ["rabbit_pelt", 0.15, 1, 1], ["treasure_chest", 0.10, 1, 1], ["", 0.15, 0, 0]]
const GATHER_CHEST_PER_DAY := 1
# 새 자원
const MEAT_PRICE := 5
const PELT_PRICE := 7
const MEAT_HEAL := 25.0
const SALE_PRICES := {"wool": WOOL_PRICE, "raw_meat": MEAT_PRICE, "rabbit_pelt": PELT_PRICE}
# 유물(영구 패시브)
const RELICS := ["moonlit_charm", "hearth_ember", "old_tree_heart", "wolf_fang_pendant", "frost_queen_tear"]
const RELIC_NAMES := {"moonlit_charm": "달빛 부적", "hearth_ember": "화로의 온기석", "old_tree_heart": "고목의 심장",
	"wolf_fang_pendant": "늑대 송곳니 목걸이", "frost_queen_tear": "서리 여왕의 눈물"}
const RELIC_DESC := {
	"moonlit_charm": "마녀의 마법탄 피해 +50%, 사거리 +1m",
	"hearth_ember": "밤에도 산장 8m 안의 아군이 초당 1 회복. 매일 낮 시작에 산장 체력 +40",
	"old_tree_heart": "벌목 시간 15초 → 10초, 벌목 1회 목재 +50%",
	"wolf_fang_pendant": "사냥꾼·전투용병 피해 +40%, 사냥 드롭 +1",
	"frost_queen_tear": "모든 적 이동 속도 85%. 매일 낮 시작에 서리 룬 카드 1장"}
const CHEST_CHOICES := 3
const CHEST_FALLBACK_TIMBER := 10     # 유물을 다 모았을 때 상자가 주는 목재
const RELIC_BOLT_MULT := 1.5
const RELIC_BOLT_RANGE := 1.0
const RELIC_EMBER_RADIUS := 8.0
const RELIC_EMBER_REGEN := 1.0
const RELIC_EMBER_LODGE := 40.0
const RELIC_CHOP_TIME := 10.0
const RELIC_CHOP_MULT := 1.5
const RELIC_FANG_MULT := 1.4
const RELIC_FANG_DROP := 1
const RELIC_FROST_SLOW := 0.85

# 물리 레이어 비트
const L_GROUND := 1
const L_OBSTACLE := 2   # 산장·나무 줄기·큰 바위: 이동 차단 + 시야 차단
const L_BOUNDARY := 4   # 울타리·숲 경계: 이동만 차단
const L_ACTOR := 8
