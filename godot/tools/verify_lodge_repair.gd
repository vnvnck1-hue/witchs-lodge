extends SceneTree
## 산장 골드 수리 하루 한도·가격 계단 헤드리스 검증(사용자 결정 2026-10-27, 봉인석 균열 대신).
##   .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_lodge_repair.gd
## 그날 수리는 10 → 20 → 40G로 비싸지고 3번(+30)까지만 된다. 새 낮이 오면 다시 10G부터.

const Cfg := preload("res://scripts/config.gd")

var passed := 0
var total := 0


func check(ok: bool, label: String, detail := "") -> void:
	total += 1
	if ok:
		passed += 1
	print(("PASS " if ok else "FAIL ") + label + ("  — " + detail if detail != "" else ""))


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	for i in 12:
		await physics_frame
	game.session.set_process(false)
	var eco = game.economy
	var lodge = game.world.lodge
	lodge.hp = lodge.max_hp - 200.0
	eco.gold = 200
	var steps: Array = eco.REPAIR_COST_STEPS
	check(steps == [10, 20, 40], "가격 계단 10 → 20 → 40G", str(steps))
	var hp0: float = lodge.hp
	var paid: Array = []
	for i in steps.size():
		var cost: int = eco.cost_of("repair")
		var g0: int = eco.gold
		var ok: bool = eco.buy("repair")
		paid.append(g0 - eco.gold)
		check(ok and cost == steps[i] and g0 - eco.gold == steps[i], "%d번째 수리 %dG" % [i + 1, steps[i]], "cost=%d paid=%d" % [cost, g0 - eco.gold])
	check(is_equal_approx(lodge.hp - hp0, Cfg.REPAIR_AMOUNT * steps.size()), "하루 수리량 +%d" % int(Cfg.REPAIR_AMOUNT * steps.size()), str(lodge.hp - hp0))
	var reason: String = eco.block_reason("repair")
	check(reason.contains("한도") and not eco.buy("repair"), "4번째 수리는 막힘", reason)
	check(eco.gold == 200 - 70, "골드 70 차감", str(eco.gold))
	eco.begin_prep()
	check(eco.repairs_today == 0 and eco.cost_of("repair") == steps[0] and eco.block_reason("repair") == "", "새 낮에 10G부터 다시", "today=%d cost=%d" % [eco.repairs_today, eco.cost_of("repair")])
	lodge.hp = lodge.max_hp
	check(eco.block_reason("repair") == "체력 최대", "체력이 가득이면 여전히 막힘")
	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)
