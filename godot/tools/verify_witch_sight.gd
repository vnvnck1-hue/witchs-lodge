extends SceneTree
## 마녀 안개 시야 확대(2026-10-22, 낮 12→20m·밤 9→15m) 헤드리스 검증.
const Cfg := preload("res://scripts/config.gd")
var game
var passed := 0
var total := 0

func _initialize() -> void:
	create_timer(90.0, true, false, true).timeout.connect(func(): print("FAIL timeout"); quit(2))
	call_deferred("_run")

func check(label: String, ok: bool, detail := "") -> void:
	total += 1
	if ok: passed += 1
	print("%s %s%s" % ["PASS" if ok else "FAIL", label, "" if detail == "" else "  — " + detail])

func frames(n := 4) -> void:
	for i in n: await process_frame

func _run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await frames(15)
	game.session.set_process(false)
	game.player.set_physics_process(false)
	var fog = game.world.fog_of_war
	check("낮 시야 20m · 밤 15m · 아군 6m", is_equal_approx(Cfg.WITCH_SIGHT_DAY, 20.0) and is_equal_approx(Cfg.WITCH_SIGHT_NIGHT, 15.0) and is_equal_approx(Cfg.ALLY_SIGHT, 6.0))
	# 장애물 없는 칸만 세도록 네 방향 중 하나라도 보이면 통과(나무가 가리는 방향이 있을 수 있다).
	var origin := Vector3(25, 0, -20)
	game.player.position = origin
	await physics_frame
	await physics_frame
	fog.refresh()
	var near_seen := false
	var far_seen := false
	for d in [Vector3(1, 0, 0), Vector3(-1, 0, 0), Vector3(0, 0, 1), Vector3(0, 0, -1)]:
		if fog.is_visible_at(origin + d * 13.0): near_seen = true
		if fog.is_visible_at(origin + d * 24.0): far_seen = true
	var night: float = game.world.day_cycle.night_amount
	check("밤에도 13m 떨어진 곳이 보인다(예전 낮 12m·밤 9m 밖)", near_seen, "night_amount=%.2f" % night)
	check("24m 밖은 여전히 안개", not far_seen)
	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)
