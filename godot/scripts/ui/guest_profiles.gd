extends RefCounted
## 일곱 손님의 이름·초상·소개 문구. 고용/정산 규칙은 LodgeEconomy가 소유한다.
const MERC_PORTRAIT := "res://assets/portraits/guest_bram_cutout.png"
const HERBALIST_PORTRAIT := "res://assets/portraits/guest_mira_cutout.png"
const MERCENARIES := ["브람", "올라프", "토르빈", "미라"]
## 인물별 고정 직업(기획 §1). 고용하면 이 직업의 계약 카드를 준다.
const JOBS := {"브람": "warrior", "올라프": "hunter", "토르빈": "lumberjack", "미라": "gatherer"}
const TRAVELERS := ["neri", "oswin", "sera"]
const CATALOG := [
	{"id": "bram", "person": "브람", "role": "전투용병", "detail": "북쪽 숲길을 건너온 여행자",
		"tag": "경계 어린 첫인사", "portrait": MERC_PORTRAIT, "hireable": true,
		"lines": ["마녀의 산장에 묵게 되다니…\n기묘한 일이군.",
			"숲에서 이상한 소리가 들리더군.\n오늘 밤은 지붕 아래서 쉬고 싶소.",
			"소문은 소문일 뿐이지.\n따뜻한 침대 하나면 충분하오."]},
	{"id": "mira", "person": "미라", "role": "채집가", "detail": "숲에서 약초와 쓸 만한 것을 찾는 여행자",
		"tag": "따뜻한 잠자리를 찾아", "portrait": HERBALIST_PORTRAIT, "hireable": true,
		"lines": ["창문 불빛이 보여서\n얼마나 반가웠는지 몰라요.\n오늘 밤, 잘 부탁합니다.",
			"숲에서는 이름을 불러도\n돌아보지 말라던데…\n여기서는 쉬어도 되겠죠?",
			"또 신세를 지게 됐네요.\n이곳의 따뜻한 차가 생각났어요."]},
	{"id": "olaf", "person": "올라프", "role": "사냥꾼", "detail": "교역 마차를 호위해 온 용병",
		"tag": "무뚝뚝한 안도", "portrait": "res://assets/portraits/guest_olaf_cutout.png", "hireable": true,
		"lines": ["마녀든 누구든 상관없소.\n불이 켜진 집이면 됐지.\n따뜻한 수프도 있겠지?",
			"길목에 발자국이 있었소.\n들어간 자국만 있더군.",
			"그 수프가 생각나서 왔소.\n방 하나 비어 있겠지?"]},
	{"id": "torbin", "person": "토르빈", "role": "나무꾼", "detail": "오래된 산길을 아는 호위꾼",
		"tag": "말수 적은 경계", "portrait": "res://assets/portraits/guest_torbin_cutout.png", "hireable": true,
		"lines": ["문이 튼튼하군.\n오늘 밤은 푹 잘 수 있겠어.",
			"숲에서 종소리를 들었소.\n이 근처에 성당은 없을 텐데.",
			"오늘도 같은 방을 부탁하오.\n창문에서 먼 쪽이면 좋겠군."]},
	{"id": "neri", "person": "네리", "role": "숲길 전령", "detail": "눈 덮인 고개를 넘는 편지 배달부",
		"tag": "겁을 감춘 호기심", "portrait": "res://assets/portraits/guest_neri_cutout.png", "hireable": false,
		"lines": ["여기가 그 마녀의 산장이에요?\n생각보다 아늑하네요!\n하룻밤 잘 부탁해요.",
			"숲에서 누가 제 이름을 불렀어요.\n편지 받을 사람은 아니었는데…",
			"오늘은 길을 안 잃었어요!\n굴뚝 연기를 따라왔거든요."]},
	{"id": "oswin", "person": "오스윈", "role": "유적 기록가", "detail": "숲의 옛 문양을 찾아다니는 학자",
		"tag": "조용한 탐구심", "portrait": "res://assets/portraits/guest_oswin_cutout.png", "hireable": false,
		"lines": ["마녀가 내어 주는 잠자리라…\n기록할 이야기가 늘겠군요.",
			"폐허에서 같은 문양을 봤지요.\n그런데 올 때와 갈 때가 달랐소.",
			"이번에는 잉크를 넉넉히 챙겼소.\n숲이 자꾸 이야기를 늘려서요."]},
	{"id": "sera", "person": "세라", "role": "떠돌이 교역상", "detail": "마을과 산길 사이를 오가는 상인",
		"tag": "실속 있는 친절", "portrait": "res://assets/portraits/guest_sera_cutout.png", "hireable": false,
		"lines": ["소문보다 창문 불빛을 믿어요.\n방 하나 부탁할게요.\n값은 제대로 치를게요.",
			"이상하죠? 숲을 나서면\n가져온 물건이 하나씩 늘어요.",
			"오늘도 불이 켜져 있네요.\n장사 끝에 이보다 반가운 게 없죠."]},
]

static func character(id: String) -> Dictionary:
	for profile in CATALOG:
		if profile["id"] == id: return profile.duplicate(true)
	return {}

static func all_profiles() -> Array:
	return CATALOG.duplicate(true)

static func preferred_mercenary(batch: int, day: int) -> String:
	return MERCENARIES[(maxi(day, 1) - 1 + maxi(batch, 0)) % MERCENARIES.size()]

## 인물 이름 → 직업 카드 id. 이름 풀 밖의 인물(용병 n)은 이름 순서로 네 직업을 돌아가며 받는다.
static func job_of(person: String) -> String:
	if JOBS.has(person):
		return JOBS[person]
	return ["warrior", "hunter", "lumberjack", "gatherer"][absi(person.hash()) % 4]

static func greeting(profile: Dictionary, visit: int) -> String:
	var lines: Array = profile["lines"]
	return lines[maxi(visit, 0) % lines.size()]

static func make_guest(slot: int, batch: int, day: int, merc_name: String) -> Dictionary:
	var profile: Dictionary
	if slot == 0:
		var id := "bram"
		for candidate in CATALOG:
			if candidate["hireable"] and candidate["person"] == merc_name:
				id = candidate["id"]
				break
		profile = character(id)
		# 기존 이름 풀이 필요한 경우 같은 용병 초상 원형을 사용하되 계약 인물명은 보존한다.
		profile["person"] = merc_name
	else:
		var index := ((maxi(day, 1) - 1) * 3 + maxi(batch, 0) + slot - 1) % TRAVELERS.size()
		profile = character(TRAVELERS[index])
	profile["line"] = greeting(profile, 0)
	profile["character_id"] = profile["id"]
	return profile

