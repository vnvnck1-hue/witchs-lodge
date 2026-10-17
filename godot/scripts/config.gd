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
const GUEST_STORY_EVERY := 2  # 대화 대상 손님 N명 중 1명만 말 걸기 이벤트를 띄운다

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
const GRAVE_LEVELS := [8, 12, 16]   # 살아 있는 용병 + 미사용 계약 카드가 이 수보다 적어야 고용할 수 있다(4·6·8에서 완화)

# 건축: 생성·증축·업그레이드는 골드와 함께 목재가 든다. 키 = 구매 종류, 배열 = 다음 단계별 비용
const BUILD_COSTS := {
	"extension": [{"gold": 60, "timber": 10}],
	"pasture": [{"gold": 40, "timber": 8}, {"gold": 60, "timber": 12}],
	"graves": [{"gold": 30, "timber": 6}, {"gold": 45, "timber": 10}],
}

# 몬스터
const MONSTER_SPEED := 1.7
const MONSTER_MELEE := 1.2
const MONSTER_AGGRO := 5.0            # 괴물이 가는 길 이 반경 안에 마녀·용병·하수인·가시덩굴이 있으면 먼저 쫓아가 공격한다
const MONSTER_LEASH := 8.0            # 쫓던 대상이 이보다 멀어지면 포기하고 원래 목표(산장·양)로 돌아간다
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
const CONTRACT_REFUND := 15           # 산장 관리에서 계약을 해지하면 돌려받는 골드(계약료의 절반)
const HIRE_WAIT := 10.0
const HIRE_BATCHES := [0, 1]          # 하루 2명: 첫·둘째 숙박 묶음에서 1명씩 고용 기회
const MERC_NAMES := ["브람", "올라프", "토르빈", "하겐", "에이릭", "군나르", "울프", "스벤", "레이프", "비요른"]
const ACTIVE_LIMIT := 16              # 월드에서 활동 중인 용병 상한(미사용 카드·숲의 괴물 하수인은 제외). 6에서 완화
const HAND_VISIBLE := 8               # 손패 한도(확정 규칙 3). 넘치면 주머니에 보관
const CHOP_TIME := 4.0               # 벌목 1회(목재 1개) 시간. 1회 수확량을 1개로 줄이며 15초에서 단축
const CHOP_YIELD := 1                # 벌목 1회에 얻는 목재(항상 1개)
const LUMBERJACK_CARRY := 10         # 나무꾼이 들고 있을 수 있는 목재 최대치. 가득 차면 산장 마당에서 쉬며 마녀를 기다린다
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
# 줍기 표(합 1.0, 시험값). 주머니 v1에서 독버섯·오래된 마법서적을 추가: 목재 40→36, 생고기 20→18, 가죽 15→13, 빈손 15→12
const GATHER_TABLE := [["timber", 0.36, 2, 4], ["raw_meat", 0.18, 1, 1], ["rabbit_pelt", 0.13, 1, 1], ["treasure_chest", 0.10, 1, 1], ["poison_mushroom", 0.08, 1, 1], ["old_spellbook", 0.03, 1, 1], ["", 0.12, 0, 0]]
const GATHER_CHEST_PER_DAY := 1
const GATHER_BOOK_PER_DAY := 1        # 오래된 마법서적은 하루 1권까지(넘치면 독버섯으로 대체)
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
	"old_tree_heart": "벌목 시간 4초 → 2.7초 (나무꾼이 목재를 더 빨리 모음)",
	"wolf_fang_pendant": "사냥꾼·전투용병 피해 +40%, 사냥 드롭 +1",
	"frost_queen_tear": "모든 적 이동 속도 85%. 매일 낮 시작에 서리 룬 카드 1장"}
const CHEST_CHOICES := 3
const CHEST_FALLBACK_TIMBER := 10     # 유물을 다 모았을 때 상자가 주는 목재
const RELIC_BOLT_MULT := 1.5
const RELIC_BOLT_RANGE := 1.0
const RELIC_EMBER_RADIUS := 8.0
const RELIC_EMBER_REGEN := 1.0
const RELIC_EMBER_LODGE := 40.0
const RELIC_CHOP_TIME := 2.7
const RELIC_FANG_MULT := 1.4
const RELIC_FANG_DROP := 1
const RELIC_FROST_SLOW := 0.85

# 물리 레이어 비트
const L_GROUND := 1
const L_OBSTACLE := 2   # 산장·나무 줄기·큰 바위: 이동 차단 + 시야 차단
const L_BOUNDARY := 4   # 울타리·숲 경계: 이동만 차단
const L_ACTOR := 8

# 마녀의 주머니 — 창고를 덱으로(기획: docs/region-season-pocket-design.md §6, 시험값). 우선순위·진행: docs/region-season-pocket-priorities.md
const STARTER_DRAW := 3               # 시작 손패: 주머니에서 무작위 3장을 펼쳐 보여 준다(사용자 결정 2026-10-16)
const MULLIGAN_SWAPS := 1             # 시작 손패에서 교체할 수 있는 장수. 교체한 카드는 주머니로 돌아가고 다른 카드를 뽑는다
const DRAW_REVEAL_SCALE := 1.25       # 아침·효과 드로우 카드를 화면 가운데에 잠깐 보여 줄 때의 크기(손패 카드 대비)
const MORNING_DRAW := 1               # 아침마다 주머니에서 뽑는 장수
const SPELLBOOK_CHOICES := 3          # 오래된 마법서적이 펼치는 후보 수(부족하면 있는 만큼)
const MUSHROOM_HP_COST := 10.0        # 독버섯의 체력 비용(미정 → 시험값). 체력이 이보다 많아야 사용할 수 있다(치명적 비용 불허)
const DRAW_ONLY_CARDS := ["poison_mushroom", "old_spellbook"]  # 본래 효과 없이 드로우만 하는 카드: 주머니가 비면 사용 불가·비용 없음

# 볼륨 확장 E1 — 적 종류·보스·밤 규칙(시험값). 기획: docs/game-volume-expansion-plan.md §2.3~2.5
# hp_mult는 그 밤의 기본 체력에 곱한다. reach = 공격 거리. lodge_mult = 산장에 주는 피해 배율.
# ignore_units = 마녀·용병·방책을 무시하고 산장으로 간다. scale = 모형 크기. tint = 표시용 빛 색.
const ENEMY_KINDS := {
	# 기본 적(2026-10-17): 서리 거미. 수치는 숲의 괴물과 같고 이동은 '달리다 멈칫'(평균 속도 동일, monster.gd _scuttle)
	"spider": {"name": "서리 거미", "hp_mult": 1.0, "speed": 1.7, "damage": 5.0, "interval": 2.0, "reach": 1.2, "lodge_mult": 1.0, "scale": 1.0},
	"forest": {"name": "숲의 괴물", "hp_mult": 1.0, "speed": 1.7, "damage": 5.0, "interval": 2.0, "reach": 1.2, "lodge_mult": 1.0, "scale": 1.0},
	"cultist": {"name": "침식된 자", "hp_mult": 0.8, "speed": 1.5, "damage": 4.0, "interval": 2.2, "reach": 4.5, "lodge_mult": 1.0, "scale": 0.92, "tint": Color(0.75, 0.35, 1.0)},
	"insect": {"name": "맹독 곤충", "hp_mult": 0.5, "speed": 3.0, "damage": 3.0, "interval": 1.0, "reach": 1.1, "lodge_mult": 1.0, "scale": 0.7, "tint": Color(0.7, 1.0, 0.25)},
	"brute": {"name": "공성 괴물", "hp_mult": 3.0, "speed": 1.0, "damage": 6.0, "interval": 2.6, "reach": 1.5, "lodge_mult": 3.0, "scale": 1.5, "ignore_units": true, "big": true, "tint": Color(1.0, 0.55, 0.3)},
	"boss": {"name": "빈 굴의 주인", "hp": 1400.0, "speed": 1.1, "damage": 16.0, "interval": 2.4, "reach": 1.9, "lodge_mult": 1.5, "scale": 2.3, "big": true, "tint": Color(0.6, 0.85, 1.0)},
}
const BOSS_HIT_CAP := 150.0           # 보스가 한 번에 받는 피해 상한(용 불덩이 200이 보스를 녹이지 않도록)
const BOSS_ROAR_INTERVAL := 14.0      # 보스의 부름: 이 간격마다 숲의 괴물을 불러낸다
const BOSS_ROAR_SPAWN := 2
const BOSS_TROPHY := "hibernation_pelt"
const FOG_NIGHT_SIGHT := 0.6          # 안개의 밤 시야 배율

# 볼륨 확장 E2 — 마녀의 제단과 의식(시험값). 제단은 달빛 돌 제단 랜드마크에 있다.
const ALTAR_UNLOCK_DAY := 4
const ALTAR_RESTORE_TIMBER := 10
const ALTAR_USE_RANGE := 3.2          # 마녀가 이 안에 있어야 제단을 쓸 수 있다
# id -> 공물(손패 자원 id·수량 또는 양), 첫 완성 권능 카드, 반복 시 그날 밤 축복
const RITUALS := {
	"shroud": {"name": "수의의 의식", "cost": {"wool": 3}, "power": "shroud_cloth", "blessing": "shroud",
		"desc": "양털 3 · 권능: 수의 카드 · 축복: 오늘 밤 마녀·아군이 치명타를 한 번 버팀"},
	"thorn": {"name": "가시의 봉헌", "cost": {"forest_monster": 1}, "power": "thorn_bind", "blessing": "thorn",
		"desc": "숲의 괴물 카드 1 · 권능: 가시 속박 카드 · 축복: 오늘 밤 가시 방책 공격력 +50%"},
	"red_feast": {"name": "붉은 만찬", "cost": {"sheep": 1}, "power": "red_chalice", "blessing": "red_feast",
		"desc": "어른 양 1마리 · 권능: 붉은 잔 카드 · 축복: 오늘 밤 마녀의 마법탄이 피해의 30% 회복"},
}
const BLESS_THORN_MULT := 1.5
const BLESS_LIFESTEAL := 0.3
const PELT_LODGE_MULT := 0.5          # 겨울잠 털가죽: 그날 밤 산장이 받는 피해 배율

# 볼륨 확장 E3 — 숲 카드·침식 카드(시험값)
const MOSS_HEAL := 20.0
const RESIN_RADIUS := 2.4
const RESIN_DPS := 6.0
const RESIN_TIME := 5.0
const FIREFLY_SIGHT := 8.0
const VINE_RADIUS := 2.0
const VINE_DAMAGE := 6.0
const VINE_SLOW := 0.15
const VINE_TIME := 4.0
const THORN_BIND_RADIUS := 3.0
const THORN_BIND_DAMAGE := 12.0
const THORN_BIND_SLOW := 0.1
const THORN_BIND_TIME := 4.0
const FIREWOOD_REPAIR := 60.0
const CORRUPTION_CARDS := ["corrupt_prayer", "poison_spore", "cursed_whisper"]
const CORRUPTION_PER_NIGHT := 2       # 한 밤에 주머니로 들어오는 침식 카드 상한
const SPORE_DAWN_HP := 8.0            # 독 포자: 손패에 있으면 새벽마다 마녀 체력 -8(치명적이지 않음)
