extends Node
## Real-scene checks: drag resolver, pasture capacity/production, harvesting, combat and ritual.
const Cfg := preload("res://scripts/config.gd")
const Catalog := preload("res://scripts/ui/card_catalog.gd")
const Session := preload("res://scripts/game/game_session.gd")
const Monster := preload("res://scripts/actors/monster.gd")
var game
var results: Array = []
var report_path := "res://../output/occult-cards-runtime/verification.json"

func check(label: String, ok: bool, detail := "") -> void:
	results.append({"check": label, "ok": ok, "detail": detail})
	print(("PASS " if ok else "FAIL ") + label + " " + detail)

func uid(id: String) -> int:
	for entry in game.cards.entries:
		if entry.id == id:
			return entry.uid
	return -1

func sp(p: Vector3) -> Vector2:
	return game.world.camera.unproject_position(p)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--occult-report="):
			report_path = arg.trim_prefix("--occult-report=")
	while get_tree().current_scene == null or get_tree().current_scene.get("cards") == null:
		await get_tree().process_frame
	game = get_tree().current_scene
	for i in 20:
		await get_tree().physics_frame
	game.session.set_process(false)
	game.economy.set_process(false)
	game.world.player_camera.toggle_overview()
	game.player.set_physics_process(false)
	if game.wildlife != null:
		game.wildlife.set_process(false)
	for i in 4:
		await get_tree().physics_frame
	await run()
	var failures: Array = results.filter(func(r): return not r.ok)
	var report := {"passed": failures.is_empty(), "checks": results.size(), "failures": failures, "results": results}
	var file := FileAccess.open(report_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t") + "\n")
	file.close()
	print("OCCULT_VERIFY passed=%s checks=%d failures=%d" % [report.passed, results.size(), failures.size()])
	get_tree().quit(0 if report.passed else 1)

func run() -> void:
	var cards = game.cards
	var resolver = game.resolver
	var pasture = game.world.pasture
	check("Verifier starts without automatic starter cards", cards.entries.is_empty())
	for pair in Cfg.STARTER_CARDS:
		cards.add(pair[0], pair[1])
	check("Both new cards are in the six-card starter hand", cards.hand().size() == 6 and uid("sleeping_thorn_seed") > 0 and uid("black_sheep") > 0)
	for id in ["sleeping_thorn_seed", "black_sheep", "black_wool"]:
		var definition: Dictionary = Catalog.find(id)
		check("Full and hand textures load: " + id, not definition.is_empty() and ResourceLoader.exists(definition.texture) and ResourceLoader.exists(definition.hand_texture) and Catalog.texture(id) != Catalog.back())
	var ground := Vector3(-1, 0, 6.5)
	var pasture_pos := Vector3(pasture.rect.get_center().x, 0, pasture.rect.get_center().y)
	var plant_uid := uid("sleeping_thorn_seed")
	check("Plant cannot be placed in pasture", not resolver.commit(plant_uid, sp(pasture_pos)).ok and uid("sleeping_thorn_seed") == plant_uid)
	get_tree().paused = true
	check("Paused use preserves card", not resolver.commit(plant_uid, sp(ground)).ok and uid("sleeping_thorn_seed") == plant_uid)
	get_tree().paused = false
	var plan: Dictionary = resolver.commit(plant_uid, sp(ground))
	check("Drag seed to valid visible ground consumes one card", plan.ok and uid("sleeping_thorn_seed") == -1, plan.get("reason", ""))
	var plants: Array = get_tree().get_nodes_in_group("thorn_plants")
	check("Living barricade is created with health and sight", plants.size() == 1 and plants[0].is_in_group("show_hp") and plants[0].is_in_group("sight_sources"))
	if plants.is_empty():
		return
	var plant = plants[0]
	plant.set_process(false)
	cards.add("sleeping_thorn_seed")
	check("Overlapping planting rejected without consumption", not resolver.commit(uid("sleeping_thorn_seed"), sp(ground)).ok and uid("sleeping_thorn_seed") > 0)
	plant._process(Cfg.THORN_GROW_TIME * 0.5)
	check("Daylight advances growth without instant maturity", plant.growth > 0 and not plant.is_grown())
	game.session.state = Session.State.COMBAT
	var young_growth: float = plant.growth
	var young_enemy := Monster.new()
	young_enemy.setup(game, 100, false)
	young_enemy.position = plant.global_position + Vector3(0.9, 0, 0)
	game.actors.add_child(young_enemy)
	young_enemy.set_physics_process(false)
	plant._process(1.0)
	check("Night stops growth and wakes young thorns at half damage", plant.growth == young_growth and young_enemy.hp == 100 - Cfg.THORN_DAMAGE * 0.5)
	young_enemy.free()
	game.session.state = Session.State.PREP
	plant._process(Cfg.THORN_GROW_TIME)
	check("Daylight alone can finish natural growth", plant.is_grown() and not plant.empowered)
	var black_uid := uid("black_sheep")
	check("Black sheep rejects ground outside pasture", not resolver.commit(black_uid, sp(ground)).ok and uid("black_sheep") == black_uid)
	var alive_before: int = pasture.alive_count()
	plan = resolver.commit(black_uid, sp(pasture_pos))
	check("Black sheep placement consumes card and one pasture slot", plan.ok and pasture.alive_count() == alive_before + 1 and uid("black_sheep") == -1)
	var sheep = pasture.slots.back()
	sheep.set_process(false)
	check("Black sheep has its own visual and harvest identity", sheep.is_black and not sheep.is_lamb and sheep.wool_card_id() == "black_wool")
	check("No wool produced on arrival day", pasture.produce_wool(game.session.day()) == 0 and not sheep.wool_ready)
	while pasture.has_empty_slot():
		pasture.spawn_sheep(game.session.day())
	cards.add("black_sheep")
	check("Full pasture rejects black sheep without consumption", not resolver.commit(uid("black_sheep"), sp(pasture_pos)).ok and uid("black_sheep") > 0)
	game.session.wave_index = 1
	pasture.produce_wool(game.session.day())
	check("Next morning readies black wool", sheep.wool_ready)
	check("Unharvested wool does not accumulate", pasture.produce_wool(game.session.day()) == 0)
	game.player.global_position = sheep.global_position + Vector3(0.1, 0, 0)
	game.player.harvest(sheep)
	game.player._update_harvest(Cfg.HARVEST_TIME + 0.1)
	check("Real shearing produces black wool card", cards.count_of("black_wool") == 1 and not sheep.wool_ready and not game.player.shearing)
	check("Other sheep still produce normal wool", pasture.slots[0].wool_card_id() == "wool")
	var black_wool_uid := uid("black_wool")
	check("Ritual rejects unrelated ground without consumption", not resolver.commit(black_wool_uid, sp(Vector3(10, 0, 10))).ok and cards.count_of("black_wool") == 1)
	plan = resolver.commit(black_wool_uid, sp(plant.global_position + Vector3(0, 0.4, 0)))
	check("Black wool ritual consumes one and matures/empowers/heals", plan.ok and plant.empowered and plant.is_grown() and plant.hp == Cfg.THORN_RITUAL_HP and cards.count_of("black_wool") == 0)
	cards.add("black_wool", 2)
	check("Black wool stacks as one inventory entry", cards.count_of("black_wool") == 2 and cards.entries.filter(func(e): return e.id == "black_wool").size() == 1)
	check("Full strengthened barricade rejects redundant offering", not resolver.commit(uid("black_wool"), sp(plant.global_position)).ok and cards.count_of("black_wool") == 2)
	plant.take_damage(25)
	plan = resolver.commit(uid("black_wool"), sp(plant.global_position))
	check("Later offering restores damaged barricade", plan.ok and plant.hp == plant.max_hp and cards.count_of("black_wool") == 1)
	game.session.state = Session.State.COMBAT
	check("Night planting rejected without consumption", not resolver.commit(uid("sleeping_thorn_seed"), sp(Vector3(3, 0, 6.5))).ok and uid("sleeping_thorn_seed") > 0)
	check("Night livestock placement rejected", not resolver.evaluate(uid("black_sheep"), sp(pasture_pos)).ok)
	var enemy := Monster.new()
	enemy.setup(game, 100, false)
	enemy.position = plant.global_position + Vector3(0.9, 0, 0)
	game.actors.add_child(enemy)
	enemy.set_physics_process(false)
	check("Enemy recognizes nearby barricade as a target", enemy._nearest_ally() == plant)
	plant._tick = 0
	plant._process(0.1)
	check("Mature ritual thorns damage and slow nearby enemy", enemy.hp == 100 - Cfg.THORN_RITUAL_DAMAGE and enemy.slow_factor() <= Cfg.THORN_SLOW)
	var hp_before: float = plant.hp
	game.player.global_position = Vector3(5.3, 0, 6.2)
	enemy.engaged = plant
	enemy.attack_cd = 0
	enemy._physics_process(0.05)
	check("Enemy can damage living barricade", plant.hp < hp_before)
	enemy.queue_free()
	game.session.state = Session.State.PREP
	check("Surviving barricade persists into next day", not plant.dead and plant.is_in_group("thorn_plants"))
	# A planting limit is separate from the mercenary limit.
	var Seed := load("res://scripts/actors/thorn_seed.gd")
	var extras: Array = []
	for i in Cfg.THORN_LIMIT - 1:
		var other = Seed.new()
		other.game = game
		other.position = Vector3(15 + i * 3, 0, 10)
		game.actors.add_child(other)
		extras.append(other)
	check("Plant limit preserves unused seed", not resolver.commit(uid("sleeping_thorn_seed"), sp(Vector3(2, 0, 6.5))).ok and uid("sleeping_thorn_seed") > 0)
	for other in extras:
		other.free()
	var merc_count: int = game.contracts.active_count()
	check("Plants do not consume mercenary activity slots", merc_count == 0)
	if "--capture-occult" in OS.get_cmdline_user_args() and DisplayServer.get_name() != "headless":
		game.world.player_camera.set_process(false)
		game.world.camera.position = Vector3(17, 20, 26)
		game.world.camera.look_at(Vector3(1, 0, 2))
		plant.set_process(true)
		cards.add("sleeping_thorn_seed")
		cards.add("black_sheep")
		sheep.position = Vector3(pasture.rect.end.x - 0.7, 0, pasture.rect.end.y - 0.8)
		game.hud.toast_box.visible = false
		await get_tree().create_timer(4.0).timeout
		for i in 25:
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://../output/occult-cards-runtime/game-applied.png")
	plant.take_damage(999)
	check("Destroyed barricade leaves targeting, sight and health groups", plant.dead and not plant.is_in_group("thorn_plants") and not plant.is_in_group("show_hp") and not plant.is_in_group("sight_sources"))
