extends SceneTree
## 2026-10-17 일레븐랩스로 새로 만든 효과음 12종(가시 방책·상자·유물·마법서·야생동물·화살·고기)이
## 실제로 불러와지고, 해당 게임 동작에서 재생되며, 파일이 빠지면 예전 소리로 대신하는지 확인한다.
const NEW := ["thorn_plant", "thorn_lash", "thorn_empower", "thorn_hit", "thorn_die", "chest_open",
	"relic_get", "book_open", "animal_flee", "animal_hurt", "eat_meat", "arrow_hit"]
var total := 0
var passed := 0

func _initialize() -> void:
	call_deferred("run")

func check(label: String, ok: bool) -> void:
	total += 1
	if ok: passed += 1
	print(("PASS " if ok else "FAIL ") + label)

func wait_frames(n: int) -> void:
	for i in n: await physics_frame

func run() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	await wait_frames(35)
	var game = current_scene
	var bank = game.sounds
	for e in NEW:
		check("%s loads a real stream" % e, bank.streams.has(e) and not bank.streams[e].is_empty() and bank.streams[e][0].get_length() > 0.3)
	# 2026-10-17 사용자 검토: 토끼·사슴 쓰러짐은 양 소리 유지, 생고기 먹기는 다시 만든 후보로
	var sel: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(bank.config_path))["sounds"]
	check("animal_hurt uses sheep_hurt file (user pick)", sel["animal_hurt"]["files"] == ["sfx-sheep_hurt.wav"])
	check("eat_meat uses regenerated file", sel["eat_meat"]["files"] == ["sfx-eat-meat-el-03.mp3"])
	# 가시 방책: 심기 → 봉헌 → 피격 → 소멸
	var thorn = load("res://scripts/actors/thorn_seed.gd").new()
	thorn.game = game
	thorn.position = Vector3(3, 0, 3)
	game.actors.add_child(thorn)
	await wait_frames(2)
	check("planting thorn plays thorn_plant", bank.history.has("thorn_plant"))
	thorn.offer_black_wool()
	check("black wool offering plays thorn_empower", bank.last_event == "thorn_empower")
	thorn.take_damage(1.0)
	check("thorn damage plays thorn_hit", bank.last_event == "thorn_hit")
	thorn.take_damage(99999.0)
	check("thorn death plays thorn_die", bank.last_event == "thorn_die")
	# 야생 동물이 쓰러질 때는 양 소리 대신 전용 소리
	var animal = load("res://scripts/actors/wild_animal.gd").new()
	animal.setup(game, "rabbit")
	animal.position = Vector3(-4, 0, 4)
	game.actors.add_child(animal)
	await wait_frames(2)
	animal.take_damage(99999.0)
	check("wild animal death plays animal_hurt", bank.history.has("animal_hurt"))
	# 새 파일이 빠지면 예전 소리로 대신
	await create_timer(0.15).timeout
	var saved = bank.streams["chest_open"]
	bank.streams.erase("chest_open")
	check("missing chest_open falls back to mon_drop", bank.play_or("chest_open", "mon_drop") and bank.last_event == "mon_drop")
	bank.streams["chest_open"] = saved
	await create_timer(0.15).timeout
	check("present chest_open plays itself", bank.play_or("chest_open", "mon_drop") and bank.last_event == "chest_open")
	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)
