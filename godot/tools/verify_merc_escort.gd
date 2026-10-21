extends SceneTree
## 용병 동행 헤드리스 검증(docs/merc-escort-v01.md).
##   .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_merc_escort.gd
## 실제 장면에서 전투용병·사냥꾼·채집가를 고용하고 마녀를 산장 밖에 세워 출발 → 접근·달리기 → 마녀 곁 적 교전 → 처치 뒤 동행 복귀 →
## 마녀가 서 있을 때 길가 사냥 → 마녀가 움직이면 사냥 중단 → 마녀 복귀 시 정찰 → 일몰이면 동행 해제 → 비전투직은 따라오지 않음을 확인한다.

const Cfg := preload("res://scripts/config.gd")
const Layout := preload("res://scripts/world/layout.gd")
const Sites := preload("res://scripts/world/hazard_sites.gd")
const Insect := preload("res://scripts/actors/venom_insect.gd")
const AnimalScript := preload("res://scripts/actors/wild_animal.gd")
const AllyScript := preload("res://scripts/actors/ally.gd")
const ArrowScript := preload("res://scripts/actors/arrow.gd")

var game
var passed := 0
var total := 0


func check(ok: bool, label: String, detail := "") -> void:
	total += 1
	if ok:
		passed += 1
	print(("PASS " if ok else "FAIL ") + label + ("  — " + detail if detail != "" else ""))


func _initialize() -> void:
	create_timer(180.0, true, false, true).timeout.connect(func(): push_error("merc escort verification timeout"); quit(2))
	call_deferred("run")


func pframes(n := 3) -> void:
	for i in n:
		await physics_frame


func seconds(t: float) -> void:
	var start := Time.get_ticks_msec()
	while Time.get_ticks_msec() - start < t * 1000.0:
		await physics_frame


func until(cond: Callable, timeout := 10.0) -> bool:
	var start := Time.get_ticks_msec()
	while not cond.call():
		await physics_frame
		if Time.get_ticks_msec() - start > timeout * 1000.0:
			return false
	return true


func flat(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x, a.z).distance_to(Vector2(b.x, b.z))


func place(at: Vector3) -> void:
	game.player.position = at
	game.player.velocity = Vector3.ZERO
	game.player.moving = false
	game.player.agent.target_position = at
	game.world.player_camera.recenter()


func lodge_dist(p: Vector3) -> float:
	return flat(game.world.lodge.global_position, p)


func run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await pframes(12)
	for i in 150:
		if game.world.hazard_regions.inhabitants.size() == 15:
			break
		await physics_frame
	game.session.set_process(false)
	game.economy.set_process(false)
	game.world.day_cycle.set_mode("day")
	# 서식지 곤충·야생 동물은 멈춰 두고(결정적 검증), 동물은 치운다
	for r in game.world.hazard_regions.inhabitants:
		r.set_physics_process(false)
	if game.wildlife != null:
		game.wildlife.set_process(false)
		for a in get_nodes_in_group("animals"):
			a.queue_free()
	await pframes(2)
	check(game.session.state == 0, "낮(준비 시간)에서 시작")

	# ── 1. 수치(사용자 확정 2026-10-22)
	check(Cfg.ESCORT_LEAVE_RADIUS == 14.0 and Cfg.ESCORT_RETURN_RADIUS == 11.0, "출발 14m · 복귀 11m")
	check(Cfg.MERC_SPEED * Cfg.ESCORT_SPEED_MAX_MULT > Cfg.PLAYER_SPEED * 1.5, "최대 달리기(%.2f) > 마녀(%.1f)의 1.5배" % [Cfg.MERC_SPEED * Cfg.ESCORT_SPEED_MAX_MULT, Cfg.PLAYER_SPEED])

	# ── 2. 고용: 전투용병·사냥꾼·채집가
	place(Layout.PLAYER_START)
	var warrior = game.contracts.spawn_guard("merc", "브람", Layout.CAMPFIRE + Vector3(2.0, 0, 0), null, "warrior")
	var hunter = game.contracts.spawn_guard("merc", "올라프", Layout.CAMPFIRE + Vector3(-2.0, 0, 0), null, "hunter")
	var gatherer = game.contracts.spawn_gatherer("미라", Layout.CAMPFIRE + Vector3(0, 0, 2.2))
	await pframes(5)
	check(warrior.state in [AllyScript.State.PATROL, AllyScript.State.PATROL_WAIT] and hunter.state in [AllyScript.State.PATROL, AllyScript.State.PATROL_WAIT], "전투직은 정찰로 시작", "w=%d h=%d" % [warrior.state, hunter.state])

	# ── 3. 마녀가 산장 근처(12m)에 있으면 따라나서지 않는다
	place(Layout.DOOR_FRONT + Vector3(0, 0, 5.0))
	await seconds(1.0)
	check(not warrior.escort and not hunter.escort, "산장 9m 안: 동행 없음", "d=%.1f" % lodge_dist(game.player.global_position))

	# ── 4. 마녀가 18m 밖으로 나가면 후다닥 따라나선다
	var camp := Vector3(-20, 0, 23)
	place(camp)
	var started: bool = await until(func(): return warrior.escort and hunter.escort, 2.0)
	check(started, "마녀가 %.0fm 밖으로 나가자 전투용병·사냥꾼이 동행 시작" % lodge_dist(camp))
	check(warrior.state == AllyScript.State.ESCORT and hunter.state == AllyScript.State.ESCORT, "상태 ESCORT")
	check(warrior.status_text().begins_with("마녀와 동행 중") and hunter.short_status().begins_with("동행"), "명부 '마녀와 동행 중' · 머리 위 '동행'")
	check(not gatherer.escort and gatherer.state != AllyScript.State.ESCORT, "채집가는 따라오지 않음", "state=%d" % gatherer.state)
	await pframes(2)
	var far_mult: float = warrior._sprint
	check(far_mult > 2.0, "멀리 있을 때 거리 비례 달리기(배율 %.2f)" % far_mult)
	var speed_ok: bool = warrior.velocity.length() > Cfg.PLAYER_SPEED * 1.4
	check(speed_ok, "달리기 속도 적용(마녀 1.4배 이상)", "v=%.2f" % warrior.velocity.length())
	var slowed: bool = await until(func(): return flat(warrior.global_position, game.player.global_position) < 10.0, 12.0)
	check(slowed and warrior._sprint < far_mult - 0.3 and warrior._sprint > 1.0, "가까워질수록 배율이 줄어듦(%.2f → %.2f)" % [far_mult, warrior._sprint])
	await seconds(0.6)
	check(game.contracts.escort_departures == 1, "출발 토스트 한 번으로 묶임", "n=%d" % game.contracts.escort_departures)
	var arrived: bool = await until(func(): return flat(warrior.global_position, game.player.global_position) <= 4.0 and flat(hunter.global_position, game.player.global_position) <= 4.5, 20.0)
	check(arrived, "두 용병이 마녀 곁(4m 안)까지 달려옴", "w=%.1f h=%.1f" % [flat(warrior.global_position, game.player.global_position), flat(hunter.global_position, game.player.global_position)])
	await seconds(1.0)
	check(warrior._sprint == 1.0 and hunter._sprint == 1.0 and warrior.state == AllyScript.State.ESCORT, "곁에 오면 걷기 배율(1)로 돌아와 선다(분리 밀림만 남음)", "v=%.2f" % warrior.velocity.length())
	check(flat(warrior.global_position, game.player.global_position) <= Cfg.ESCORT_FOLLOW_DIST["warrior"] + 1.2, "전투용병은 가까이, 사냥꾼은 조금 뒤", "w=%.1f h=%.1f" % [flat(warrior.global_position, game.player.global_position), flat(hunter.global_position, game.player.global_position)])

	# ── 5. 마녀 곁의 적(맹독 곤충)과 교전
	var insect := Insect.new()
	insect.setup(game, Sites.SITES[2], camp + Vector3(4.0, 0, 0), false, 0)
	game.actors.add_child(insect)
	insect.set_physics_process(false)
	var engaged: bool = await until(func(): return warrior.state == AllyScript.State.ENGAGE and hunter.state == AllyScript.State.ENGAGE and warrior.target == insect and hunter.target == insect, 3.0)
	check(engaged, "마녀 10m 안의 곤충을 둘 다 교전 대상으로 잡음")
	var hp0: float = insect.hp
	var hurt: bool = await until(func(): return insect.hp < hp0 - 1.0, 8.0)
	check(hurt, "교전으로 곤충 체력이 줄어듦", "%.0f → %.0f" % [hp0, insect.hp])
	var shot := false
	for n in game.actors.get_children():
		if n is ArrowScript:
			shot = true
	await seconds(1.5)
	for n in game.actors.get_children():
		if n is ArrowScript:
			shot = true
	check(shot or insect.hp < hp0 - Cfg.WARRIOR_DAMAGE, "사냥꾼이 활을 쏨(화살 노드)", "arrow=%s" % shot)
	insect.take_damage(999.0)
	var back: bool = await until(func(): return warrior.state == AllyScript.State.ESCORT and hunter.state == AllyScript.State.ESCORT and warrior.escort, 3.0)
	check(back, "곤충을 처치하면 다시 동행")

	# ── 6. 길가 사냥: 마녀가 서 있으면 사냥꾼이 주변 사냥감을 쏘고, 마녀가 움직이면 바로 따라간다
	await seconds(1.0)
	var rabbit := AnimalScript.new()
	rabbit.setup(game, "rabbit")
	rabbit.position = game.player.global_position + Vector3(0, 0, 5.0)
	game.actors.add_child(rabbit)
	rabbit.set_physics_process(false)
	var hunting: bool = await until(func(): return hunter.state == AllyScript.State.HUNT and hunter.prey == rabbit, 3.0)
	check(hunting, "마녀가 서 있을 때 사냥꾼이 길가 토끼를 사냥")
	check(warrior.state == AllyScript.State.ESCORT, "전투용병은 사냥하지 않고 곁에 있음")
	game.player.set_destination(game.player.global_position + Vector3(0, 0, -7.0))
	var stopped: bool = await until(func(): return hunter.state == AllyScript.State.ESCORT and hunter.prey == null, 2.0)
	check(stopped, "마녀가 움직이자 사냥을 끊고 바로 따라감")
	check(hunter.escort and warrior.escort, "이동 중에도 동행 유지")
	await seconds(2.5)
	rabbit.queue_free()
	# 필드에서 벌어져도 거리 비례 달리기: 마녀를 12m 앞으로 옮기면 배율이 1보다 크고 곧 다시 붙는다
	place(game.player.global_position + Vector3(0, 0, -12.0))
	await pframes(3)
	var field_mult: float = warrior._sprint
	check(warrior.state == AllyScript.State.ESCORT and field_mult > 1.4, "필드에서 12m 벌어지면 비례 달리기(배율 %.2f)" % field_mult)
	var rejoined: bool = await until(func(): return flat(warrior.global_position, game.player.global_position) <= 4.0, 8.0)
	check(rejoined, "필드에서 다시 합류")

	# ── 7. 마녀가 산장 14m 안으로 돌아오면 정찰로 복귀
	place(Layout.DOOR_FRONT + Vector3(0, 0, 5.0))
	var home: bool = await until(func(): return not warrior.escort and not hunter.escort and warrior.state == AllyScript.State.PATROL and hunter.state == AllyScript.State.PATROL, 2.0)
	check(home, "마녀가 11m 안으로 돌아오자 동행 해제 → 정찰")

	# ── 8. 밤에는 동행하지 않는다(일몰이면 해제, 밤에는 출발 없음)
	place(camp)
	var again: bool = await until(func(): return warrior.escort and hunter.escort, 2.0)
	check(again, "낮에 다시 나가면 다시 동행")
	game.session.start_wave()
	await seconds(0.5)
	check(not warrior.escort and not hunter.escort and warrior.state != AllyScript.State.ESCORT and hunter.state != AllyScript.State.ESCORT, "일몰(웨이브 시작)이면 동행을 끝내고 산장 수비로", "w=%d h=%d" % [warrior.state, hunter.state])
	place(Vector3(23, 0, 18))
	await seconds(1.5)
	check(not warrior.escort and not hunter.escort, "밤에 마녀가 멀리 나가도 따라나서지 않음")

	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)
