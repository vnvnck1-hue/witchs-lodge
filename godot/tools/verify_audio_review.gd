extends SceneTree
var results: Array = []
var failed := false
var config := ""

func _initialize() -> void:
	call_deferred("run")

func check(label: String, passed: bool) -> void:
	results.append({"check": label, "passed": passed})
	failed = failed or not passed
	print(("PASS " if passed else "FAIL ") + label)

func write_config(sounds: Dictionary) -> void:
	var f := FileAccess.open(config, FileAccess.WRITE)
	f.store_string(JSON.stringify({"schema": 1, "sounds": sounds}))
	f.close()

func wait_frames(n: int) -> void:
	for i in n: await physics_frame

func run() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	await wait_frames(35)
	var game = current_scene
	var bank = game.sounds
	config = ProjectSettings.globalize_path("res://../output/audio-elevenlabs-v01/verification-selected.json")
	bank.config_path = config
	write_config({})
	bank.reload_selection()
	check("unapproved sounds stay silent", not bank.play("magic_bolt") and bank.play_count == 0)
	var approved := {
		"magic_bolt": {"files": ["magic-bolt-01.mp3", "magic-bolt-02.mp3"], "volume_db": -12},
		"card_play": {"files": ["card-play-01.mp3"], "volume_db": -10},
		"gold_reward": {"files": ["gold-reward-01.mp3"], "volume_db": -10},
		"dragon_arrival": {"files": ["dragon-arrival-01.mp3"], "volume_db": -8}}
	write_config(approved)
	bank.reload_selection()
	check("four approved event banks load actual MP3", bank.streams.size() == 4 and bank.streams["magic_bolt"].size() == 2 and bank.streams["dragon_arrival"][0].get_length() > 3.9)
	check("first approved variant plays", bank.play("magic_bolt") and bank.cursors["magic_bolt"] == 1)
	check("duplicate cast within 100ms is suppressed", not bank.play("magic_bolt"))
	await create_timer(0.15).timeout
	check("second approved variant rotates", bank.play("magic_bolt") and bank.cursors["magic_bolt"] == 2)
	game.economy._add_gold(1)
	check("actual gold receipt triggers reward", bank.last_event == "gold_reward")
	var count: int = bank.play_count
	game.resolver.commit(-999, Vector2.ZERO)
	check("invalid card use stays silent", bank.play_count == count)
	game.cards.add("timber", 5)
	game.world.lodge.take_damage(150.0)
	var uid: int = game.cards.entries[0]["uid"]
	var point: Vector2 = game.world.camera.unproject_position(game.world.lodge.global_position + Vector3(0, 2, 0))
	var repair: Dictionary = game.resolver.commit(uid, point)
	check("successful card use triggers card sound", repair["ok"] and bank.last_event == "card_play")
	await create_timer(0.15).timeout
	var enemy = load("res://scripts/actors/monster.gd").new()
	enemy.setup(game, 36.0, false)
	game.actors.add_child(enemy)
	enemy.global_position = game.player.global_position + Vector3(1, 0, 0)
	game.player._fire(enemy)
	check("witch firing triggers magic sound", bank.last_event == "magic_bolt")
	check("dragon summon triggers arrival sound", game.dragon.summon() and bank.last_event == "dragon_arrival")
	paused = true
	check("pause prevents new sounds", not bank.play("gold_reward"))
	paused = false
	var f := FileAccess.open(config, FileAccess.WRITE)
	f.store_string("{}")
	f.close()
	bank.reload_selection()
	check("malformed selection preserves valid bank", bank.streams.size() == 4)
	write_config({})
	bank.elapsed = 1.0
	bank._process(0.01)
	await wait_frames(2)
	check("live approval removal clears playback", bank.streams.is_empty() and bank.get_child_count() == 0 and not bank.play("dragon_arrival"))
	DirAccess.remove_absolute(config)
	var report := FileAccess.open("res://../output/audio-review/game-verification.json", FileAccess.WRITE)
	report.store_string(JSON.stringify({"passed": not failed, "checks": results}, "\t"))
	report.close()
	quit(1 if failed else 0)
