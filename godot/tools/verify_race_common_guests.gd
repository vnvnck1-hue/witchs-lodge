extends SceneTree
## 종족 공용 3D 손님(인간·드워프·요정·수인·오크 + 고블린) 헤드리스 검증(docs/character-3d-pipeline.md 4단계).
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_race_common_guests.gd
## 실제 main.tscn 에서 손님 생성과 같은 방식으로 걸려 보내 공용 모델·묶음·키·걷기·바로 입실을 확인하고,
## 모든 손님·고용 용병·밤 소환수가 예전 임시 겨울 여행자 모델을 쓰지 않는지 확인한다(사용자 지시 2026-10-21).

const TravelerScript := preload("res://scripts/actors/traveler.gd")
const AllyScript := preload("res://scripts/actors/ally.gd")
const SummonScript := preload("res://scripts/actors/night_summon.gd")
const GuestProfiles := preload("res://scripts/ui/guest_profiles.gd")
const Layout := preload("res://scripts/world/layout.gd")
const CM := preload("res://scripts/visual/character_models.gd")

## 종족 → (공용 모델 id, 확인할 손님 id 들, 추가 묶음 수)
const CASES := {
	"human": ["human_common", ["bram", "neri", "sera"], 0],
	"dwarf": ["dwarf_common", ["harald", "ketil", "durga"], 0],
	"fairy": ["fairy_common", ["thistle", "pip", "willow"], 2],
	"beastfolk": ["beastfolk_common", ["fargh", "luka", "selen"], 1],
	"orc": ["orc_common", ["garok", "ulma", "eshka"], 0],
}

var passed := 0
var total := 0

func check(ok: bool, label: String) -> void:
	total += 1
	if ok: passed += 1
	print(("PASS " if ok else "FAIL ") + label)

func _initialize() -> void: call_deferred("_run")

func frames(n: int) -> void:
	for i in n: await process_frame

func spawn(game, id: String):
	var g := TravelerScript.new()
	g.profile = GuestProfiles.guest_profile(id)
	var pts: Array = Layout.TRAVELER_ROUTE.duplicate()
	pts[pts.size() - 1] = Layout.DOOR_FRONT
	g.setup(pts, 0.0)
	g.position = pts[0]
	game.actors.add_child(g)
	return g

func model_id(g) -> String:
	for n in g.find_children("*", "Node3D", true, false):
		var cid := str(n.get_meta("character_id", ""))
		if cid != "": return cid
	return ""

func _run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	get_root().add_child(game)
	await frames(20)
	game.session.set_process(false)
	game.economy.set_process(false)
	Engine.time_scale = 6.0

	var witch_h: float = float(CM.CATALOG["witch_north"].scale) * game.player.visual.scale.y
	for race in CASES:
		var mid: String = CASES[race][0]
		var groups: int = 6 + int(CASES[race][2])
		check(CM.has_model(mid) and CM.RACE_MODELS.get(race, "") == mid, "%s 종족 공용 모델 등록(%s)" % [race, mid])
		var h := float(CM.CATALOG[mid].scale)
		check(h < witch_h and h > witch_h * 0.7, "%s 키 %.2fm — 마녀 %.2fm 보다 작고 70%% 이상" % [mid, h, witch_h])
		for id in CASES[race][1]:
			var g = spawn(game, id)
			await frames(2)
			check(model_id(g) == mid and g.rig != null and g.rig.pivots.size() == groups,
				"%s(%s)는 %s 모델, 묶음 %d개" % [id, race, mid, groups])
			g.queue_free()
		await frames(2)

		# 대표 손님 한 명을 끝까지 걸려 본다: 다리가 번갈아 움직이고, 인사 없이 바로 입실.
		var who: String = CASES[race][1][0]
		var g = spawn(game, who)
		await frames(2)
		check(g.visual.find_child("Mouth", true, false) != null, "%s 입김 위치 표식(Mouth)" % mid)
		var arrived := [false]
		g.arrived.connect(func(): arrived[0] = true)
		var leg_min := 0.0
		var leg_max := 0.0
		var extra_moved: bool = not (race in ["fairy", "beastfolk"])
		var extra_group: String = "wing_l" if race == "fairy" else "tail"
		var greeted := false
		for i in 6000:
			await process_frame
			var lr: float = g.rig.pivots["leg_r"].rotation_degrees.x
			leg_min = minf(leg_min, lr)
			leg_max = maxf(leg_max, lr)
			if g.rig.pivots.has(extra_group) and absf(g.rig.pivots[extra_group].rotation_degrees.y) > 10.0: extra_moved = true
			if g.rig.state == "greet": greeted = true
			if arrived[0]: break
		check(leg_max - leg_min > 20.0, "%s 걷기 — 다리가 앞뒤로 흔들린다(%.0f°)" % [who, leg_max - leg_min])
		if race == "fairy": check(extra_moved, "요정 날개가 파닥인다(wing_l y 회전)")
		if race == "beastfolk": check(extra_moved, "수인 꼬리가 흔들린다(tail y 회전)")
		check(arrived[0] and not greeted and not g.visible, "%s 인사 없이 바로 입실(인물 고유 동작 없음)" % who)
		g.queue_free()
		await frames(2)

	# 모든 손님(명부 42명 + 특별 손님): 전용 또는 자기 종족 공용 모델 — 예전 겨울 여행자 모델 없음.
	var wrong: Array = []
	for p in GuestProfiles.CATALOG + GuestProfiles.SPECIALS:
		var key: String = p["id"] if CM.has_model(p["id"]) else str(CM.RACE_MODELS.get(p.get("race", "human"), ""))
		var want: String = str(CM.CATALOG[key].scene).get_file().get_basename()   # 장면의 character_id(니브는 goblin_nib)
		var g = spawn(game, p["id"])
		await frames(1)
		if model_id(g) != want or g.rig == null: wrong.append("%s(%s→%s)" % [p["id"], want, model_id(g)])
		g.queue_free()
	check(wrong.is_empty(), "손님 %d명 전원 전용/종족 공용 모델 %s" % [GuestProfiles.CATALOG.size() + GuestProfiles.SPECIALS.size(), str(wrong)])

	# 고용 용병: 손님 때와 같은 모델. 명부 밖 이름은 인간 공용.
	var merc_wrong: Array = []
	for pair in [["브람", "human_common"], ["하랄", "dwarf_common"], ["티슬", "fairy_common"], ["그라즈", "goblin_common"],
			["파르그", "beastfolk_common"], ["가로크", "orc_common"], ["용병 7", "human_common"]]:
		var a := AllyScript.new()
		a.setup(game, "merc", pair[0], GuestProfiles.job_of(pair[0]), Layout.DOOR_FRONT + Vector3(2, 0, 2))
		a.position = Layout.DOOR_FRONT + Vector3(2, 0, 2)
		game.actors.add_child(a)
		await frames(2)
		if model_id(a) != pair[1] or a.rig == null: merc_wrong.append("%s→%s" % [pair[0], model_id(a)])
		a.queue_free()
	check(merc_wrong.is_empty(), "고용 용병이 손님과 같은 3D 모델(6종족 + 명부 밖 이름) %s" % str(merc_wrong))

	# 밤 소환수: 민병·해골도 인간 공용 3D 모델(사냥개는 따로 뼈 짐승).
	for unit in ["militia", "skeleton"]:
		var s := SummonScript.new()
		s.setup(game, unit, Layout.DOOR_FRONT + Vector3(-2, 0, 2))
		s.position = Layout.DOOR_FRONT + Vector3(-2, 0, 2)
		game.actors.add_child(s)
		await frames(2)
		check(model_id(s) == "human_common" and s.rig != null, "밤 소환 %s 는 인간 공용 3D 모델" % unit)
		s.queue_free()

	Engine.time_scale = 1.0
	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)
