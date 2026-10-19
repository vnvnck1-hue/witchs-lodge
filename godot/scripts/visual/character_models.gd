extends RefCounted
## 손님 character_id → 전용 3D 모델(Tripo 파츠 묶음 캐릭터)과 애니메이션 성격 값.
## 없는 id 는 null 을 돌려주고, 호출한 쪽은 기존 공용 모델(겨울 여행자)을 쓴다.
## 절차: docs/character-3d-pipeline.md

const RigAnim := preload("res://scripts/visual/rig_anim.gd")
const Painted := preload("res://scripts/visual/painted_models.gd")

## scale: 장면(높이 1.0m)에 곱하는 배율. 기준: 마녀(플레이어) 모자 끝까지 약 1.84m, 공용 겨울 여행자 약 1.0m.
const CATALOG := {
	"nib": {
		"scene": "res://scenes/characters/goblin_nib.tscn",
		"scale": 1.3,   # 사용자 지시(2026-10-19): 마녀와 비슷하되 더 작게 — 1.3m(마녀 모자 끝 1.84m, 모자 빼면 더 작다)
		# 흥정꾼 행상: 짧은 다리로 잰걸음, 통통 튀고, 무거운 등짐이 뒤늦게 출렁인다.
		"style": {"walk_freq": 11.0, "leg_swing": 32.0, "arm_swing": 26.0, "walk_bounce": 0.05,
			"walk_lean": 7.0, "walk_roll": 5.0, "pack_sway": 8.0,
			"greet_time": 1.4, "wave_time": 1.0},
		# 입김 효과 위치: head 묶음 피벗(목) 기준, 장면 높이 1.0m 단위. 큰 얼굴에 입김이 덮이지 않게 입 앞으로 뺀다.
		"mouth": Vector3(0, 0.2, 0.34),
	},
	## 공용 고블린 손님: 니브 원본에서 등짐·귀걸이·멜빵을 뺀 평범한 고블린(니브 외 고블린 손님 모두).
	## 흥정 인사·손 흔들기는 니브만의 성격이라 없다(greet_time 없음 → 다른 손님처럼 바로 입실).
	"goblin_common": {
		"scene": "res://scenes/characters/goblin_common.tscn",
		"scale": 1.3,
		"style": {"walk_freq": 10.5, "leg_swing": 28.0, "arm_swing": 22.0, "walk_bounce": 0.04,
			"walk_lean": 5.0, "walk_roll": 4.0},
		"mouth": Vector3(0, 0.2, 0.34),
	},
	## 플레이어: 북쪽의 마녀. 플레이어는 visual 을 1.3배로 키우므로 최종 키 ≈ 1.0 × 1.12 × 1.3 ≈ 1.46m(니브 1.3m 보다 조금 크게).
	"witch_north": {
		"scene": "res://scenes/characters/witch_north.tscn",
		"scale": 1.12,
		# 침착한 원칙주의자·파수꾼: 흔들림 적은 단정한 걸음, 지팡이 팔은 거의 고정, 서 있을 땐 천천히 주변을 살핀다.
		# 몸 전체 위아래·좌우 흔들림은 player.gd 가 Body 에 주므로 여기서는 0.
		"style": {"walk_freq": 10.0, "leg_swing": 22.0, "arm_swing": 14.0, "staff_arm_swing": 5.0, "staff_arm_x": -12.0,
			"walk_bounce": 0.0, "walk_lean": 3.0, "walk_roll": 0.0, "head_bob": 2.0, "head_look": 3.0,
			"idle_look": 22.0, "idle_look_freq": 0.35, "lantern_sway": 16.0, "cape_flutter": 12.0},
		"mouth": Vector3(0, 0.08, 0.3),
	},
}


## 종족별 공용 모델: 전용 모델이 없는 손님은 종족 공용 모델을 쓴다.
const RACE_MODELS := {"goblin": "goblin_common"}


## 손님 프로필 → 쓸 모델 id(전용 → 종족 공용 → "" = 기존 공용 여행자).
static func model_for(profile: Dictionary) -> String:
	var id := str(profile.get("character_id", ""))
	if has_model(id): return id
	var by_race := str(RACE_MODELS.get(str(profile.get("race", "")), ""))
	return by_race if has_model(by_race) else ""


static func has_model(id: String) -> bool:
	return CATALOG.has(id) and ResourceLoader.exists(CATALOG[id].scene)


## 반환: {"root": 루트(자식 Body), "body": Body, "anim": RigAnim} 또는 {}.
static func make(id: String) -> Dictionary:
	if not has_model(id): return {}
	var entry: Dictionary = CATALOG[id]
	var root := Node3D.new()
	root.name = "Visual"
	var body := Node3D.new()
	body.name = "Body"
	root.add_child(body)
	var model: Node3D = load(entry.scene).instantiate()
	model.scale = Vector3.ONE * float(entry.get("scale", 1.0))
	body.add_child(model)
	if entry.has("mouth"):
		for n in model.find_children("*", "Node3D", true, false):
			if str(n.get_meta("part_group", "")) == "head":
				var mouth := Node3D.new()
				mouth.name = "Mouth"
				mouth.position = entry.mouth
				n.add_child(mouth)
	var anim: Node = RigAnim.new()
	anim.name = "RigAnim"
	anim.setup(model, entry.get("style", {}))
	root.add_child(anim)
	return {"root": root, "body": body, "anim": anim, "style": entry.get("style", {})}


## 묶음 피벗 아래 손끝 자리(장면 단위). 팔 메시 경계에서 몸 바깥쪽 아래 끝.
static func _hand(model: Node3D, group: String) -> Node3D:
	for n in model.find_children("*", "Node3D", true, false):
		if str(n.get_meta("part_group", "")) != group: continue
		var box: AABB = (n.get_node("Mesh") as MeshInstance3D).mesh.get_aabb()
		var outer := box.end.x if box.get_center().x > 0.0 else box.position.x
		var hand := Node3D.new()
		hand.name = "Hand_" + group
		hand.position = Vector3(outer - signf(box.get_center().x) * 0.04, box.position.y + 0.04, box.get_center().z)
		n.add_child(hand)
		return hand
	return null


## 플레이어 마녀: 기존 Models.make_witch() 와 같은 모양의 사전({root, body, head, staff, tip})에 anim·hand_r 를 더한다.
## 지팡이는 기존 witch_staff 모델을 왼손(arm_l)에 쥐여 같은 세계 크기(길이 약 1.48m)로 붙인다. 없으면 {}.
static func make_player_witch() -> Dictionary:
	var made := make("witch_north")
	if made.is_empty(): return {}
	var s := float(CATALOG["witch_north"].scale)
	var model: Node3D = made.body.get_child(0)
	var hand_l := _hand(model, "arm_l")
	var hand_r := _hand(model, "arm_r")
	if hand_l == null: return {}
	# 손 높이(장면 단위) — 지팡이 밑동이 땅에 닿도록 그만큼 아래로 내린다.
	var hand_h: float = (hand_l.get_parent() as Node3D).position.y + (hand_l.get_parent().get_parent() as Node3D).position.y + hand_l.position.y
	var staff := Node3D.new()
	staff.name = "Staff"
	staff.rotation_degrees.x = 8.0
	hand_l.add_child(staff)
	var asset := Painted.asset("witch_staff")
	asset.scale = Vector3.ONE / s
	asset.position = Vector3(0, -(hand_h - 0.02), 0)
	staff.add_child(asset)
	var tip := Node3D.new()
	tip.name = "Tip"
	tip.position = Vector3(0, 1.14 / s - (hand_h - 0.02), 0)
	staff.add_child(tip)
	var head: Node3D = null
	for n in model.find_children("*", "Node3D", true, false):
		if str(n.get_meta("part_group", "")) == "head": head = n
	made["staff"] = staff
	made["tip"] = tip
	made["head"] = head
	made["hand_r"] = hand_r
	return made
