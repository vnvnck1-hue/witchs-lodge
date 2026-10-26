extends SceneTree
## 용병 고유 키트 v04 실전 흐름 헤드리스 검증: 종족마다 4명을 세우고 실제 밤 웨이브를 그대로 흘려
## (용병 AI·몬스터 AI·웨이브 생성·기세 충전이 모두 스스로 돈다) 고유 스킬이 저절로 터지고 생성 카드가 손패에 들어오는지 본다.
##   .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_merc_kit_live.gd
## 결과 표는 art_sources/merc-kit-live.json 에도 남긴다.

const Layout := preload("res://scripts/world/layout.gd")
const GuestProfiles := preload("res://scripts/ui/guest_profiles.gd")

const RACES := [["인간", ["브람", "올라프", "토르빈", "미라"]], ["드워프", ["하랄", "브륀힐드", "토르그림", "두르가"]],
	["요정", ["티슬", "틸리아", "라르크", "페른"]], ["고블린", ["그라즈", "피클", "러스크", "타크"]],
	["수인", ["파르그", "사야", "우르소", "모미"]], ["오크", ["가로크", "크라냐", "모가", "샤가"]]]
const BATTLE_SECONDS := 40.0
const TIME_SCALE := 4.0

var passed := 0
var total := 0
var report: Array = []


func check(ok: bool, label: String, detail := "") -> void:
	total += 1
	if ok:
		passed += 1
	print(("PASS " if ok else "FAIL ") + label + ("  — " + detail if detail != "" else ""))


func _initialize() -> void:
	create_timer(900.0, true, false, true).timeout.connect(func(): push_error("live timeout"); quit(2))
	call_deferred("run")


func run() -> void:
	for race in RACES:
		await battle(race[0], race[1])
	FileAccess.open("res://art_sources/merc-kit-live.json", FileAccess.WRITE).store_string(JSON.stringify(report, "  "))
	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)


func battle(race: String, people: Array) -> void:
	Engine.time_scale = 1.0
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	for i in 12:
		await physics_frame
	game.session.set_process(false)
	game.economy.set_process(false)
	var kit = game.merc_kit
	var c: Vector3 = Layout.CAMPFIRE
	var i := 0
	for p in people:
		var job: String = GuestProfiles.JOBS[p]
		if job == "gatherer":
			game.contracts.spawn_gatherer(p, c + Vector3(cos(i * 1.6), 0, sin(i * 1.6)) * 2.0)
		else:
			game.contracts.spawn_guard("merc", p, c + Vector3(cos(i * 1.6), 0, sin(i * 1.6)) * 2.0, null, job)
		i += 1
	for j in 10:
		await physics_frame
	game.session.start_wave()
	Engine.time_scale = TIME_SCALE
	var casts_by: Dictionary = {}
	var last_m: Dictionary = {}
	var gen_ids: Dictionary = {}
	var start := Time.get_ticks_msec()
	var lodge_hp0: float = game.world.lodge.hp
	var hp_lost_enemies := 0.0
	while (Time.get_ticks_msec() - start) * TIME_SCALE < BATTLE_SECONDS * 1000.0:
		await physics_frame
		for a in kit.kit_mercs():
			var m: float = kit.momentum_of(a)
			if last_m.get(a.person, 0.0) >= 99.0 and m < 50.0:
				casts_by[a.person] = int(casts_by.get(a.person, 0)) + 1
			last_m[a.person] = m
		for e in game.cards.hand():
			if e.get("generated", false):
				gen_ids[e["id"]] = true
		# 쓸 수 있는 생성 카드는 바로 써서 손패를 비운다(손패가 막혀 생성이 멈추지 않게)
		for e in game.cards.hand():
			if e.get("generated", false) and kit.cost_of(e["id"]) == 0:
				_use(game, kit, e)
				break
	Engine.time_scale = 1.0
	var casts: int = kit.stats["casts"]
	var row := {"race": race, "casts": casts, "casts_by": casts_by, "generated": kit.stats["generated"] + kit.stats["queued"],
		"generated_ids": gen_ids.keys(), "wave_alive": game.waves.alive(), "lodge_hp_lost": lodge_hp0 - game.world.lodge.hp}
	report.append(row)
	print("  %s: 스킬 %d번 %s · 생성 %d장 %s" % [race, casts, str(casts_by), row["generated"], str(gen_ids.keys())])
	check(casts >= 3, "%s: 실제 웨이브 %d초 동안 고유 스킬이 저절로 3번 이상" % [race, int(BATTLE_SECONDS)], str(casts))
	check(casts_by.size() >= 2, "%s: 두 명 이상이 스킬을 씀" % race, str(casts_by.keys()))
	check(int(row["generated"]) >= 1, "%s: 생성 카드가 손패로 들어옴" % race, str(gen_ids.keys()))
	game.queue_free()
	for j in 5:
		await process_frame


## 생성 카드를 대상에 맞춰 바로 쓴다(플레이어 손 흉내).
func _use(game, kit, e: Dictionary) -> void:
	var id: String = e["id"]
	var foes: Array = game.get_tree().get_nodes_in_group("enemies").filter(func(x): return not x.dead)
	var mercs: Array = kit.all_mercs()
	var plan := {}
	match id:
		"gen_rally", "gen_herb_water", "gen_salve", "gen_herb_handful":
			if mercs.is_empty():
				return
			var a = kit.most_hurt() if id != "gen_rally" else mercs[0]
			plan = {"ally": a if a != null else mercs[0]}
		"gen_shadow_arrow", "gen_ash_charm", "merc_hunt_mark":
			if foes.is_empty():
				return
			plan = {"enemy": foes[0]}
		"gen_trophy":
			plan = {}
		_:
			plan = {"pos": foes[0].global_position if not foes.is_empty() else Layout.CAMPFIRE + Vector3(4, 0, 4)}
	if id == "merc_hunt_mark":
		kit.mark(plan["enemy"])
	else:
		kit.apply_card(id, plan)
	game.cards.consume(e["uid"])
