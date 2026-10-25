extends Node
## 자동 플레이 검증: 준비1 끝에 증축, 웨이브 2·3에 공물, 전투 중 마녀는 적에게 다가감.
## `-- --idle` 로 실행하면 아무것도 하지 않아 패배 경로(게임 오버)를 확인한다.
## 실행: godot --headless --path . --script res://tools/run_autoplay.gd [-- --idle]
var main
var last_state := -1
var last_gold := 0
var bought_ext := false
var idle := "--idle" in OS.get_cmdline_user_args()
func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	while get_tree().current_scene == null or get_tree().current_scene.get("session") == null:
		await get_tree().process_frame
	main = get_tree().current_scene
	Engine.time_scale = 6.0
	main.economy.gold_changed.connect(func(g): print("  [t=%.1f prep=%.1f] gold -> %d" % [main.session.play_time, main.session.prep_elapsed, g]))
func _physics_process(_d):
	if main == null: return
	var s = main.session
	if s.state != last_state:
		last_state = s.state
		print("STATE ", ["PREP","COMBAT","CLEARING","VICTORY","DEFEAT"][s.state], " wave=", s.wave_index, " gold=", main.economy.gold, " lodge=", main.world.lodge.hp, " player=", main.player.hp, " sheep=", main.world.pasture.alive_count(), " t=%.1f" % s.play_time)
		if s.is_over():
			print("RESULT ", s.defeat_reason, " earned=", main.economy.total_earned, " sheep_lost=", main.sheep_lost)
			get_tree().quit()
	if idle:
		return
	if s.state == 0:
		if s.prep_elapsed > 85.0 and not bought_ext and main.economy.block_reason("extension") == "":
			print("  buy extension: ", main.economy.buy("extension"), " capacity=", main.economy.capacity)
			bought_ext = true
		if s.prep_elapsed > 86.0:
			for k in ["repair", "heal", "sheep"]:
				if main.economy.gold >= 120 + 10 and main.economy.block_reason(k) == "":
					main.economy.buy(k)
	elif s.state == 1:
		if s.wave_index >= 2 and main.dragon.block_reason() == "" and main.waves.alive() >= 4:
			var ok1 = main.dragon.summon()
			var ok2 = main.dragon.summon()
			print("  dragon summon: ", ok1, " second: ", ok2)
		var best = null
		var bd := 1e9
		for e in get_tree().get_nodes_in_group("enemies"):
			var d = e.global_position.distance_to(main.world.lodge.global_position)
			if d < bd: bd = d; best = e
		if best != null and Engine.get_physics_frames() % 20 == 0:
			var tgt: Vector3 = best.global_position
			var dir: Vector3 = (main.player.global_position - tgt)
			dir.y = 0
			main.player.set_destination(tgt + dir.normalized() * 2.5)
