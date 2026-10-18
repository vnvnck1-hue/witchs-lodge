extends SceneTree
## 인원 상한 완화·숲의 괴물 제외·묘지 기준·나무꾼 목재(1개씩, 최대 10개, 가득 차면 휴식)·계약 해지(절반 환급)·
## 괴물의 주변 적 우선 공격을 검증한다.
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_roster_jobs.gd

const Cfg := preload("res://scripts/config.gd")
const Graveyard := preload("res://scripts/world/graveyard.gd")
const AllyScript := preload("res://scripts/actors/ally.gd")
const SessionScript := preload("res://scripts/game/game_session.gd")

var game
var failures := 0
var total := 0


func _initialize() -> void:
	create_timer(120.0, true, false, true).timeout.connect(func(): print("FAIL timeout"); quit(1))
	_run.call_deferred()


func check(name: String, ok: bool, detail := "") -> void:
	total += 1
	if not ok:
		failures += 1
	print(("PASS " if ok else "FAIL ") + name + ("  — " + detail if detail != "" else ""))


func frames(n := 2) -> void:
	for i in n:
		await process_frame


func seconds(s: float) -> void:
	await create_timer(s, true, false, true).timeout


func flat(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()


## 접근 가능한 미예약 벌목 나무 하나.
func free_tree() -> Variant:
	for t in game.world.harvest_trees:
		if not t.get("removed", false) and t["remaining"] >= 2 and t["reserved"] == null and game.world.tree_access(t) == "":
			return t
	return null


func _run() -> void:
	root.size = Vector2i(1600, 900)
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(8)
	game.world.day_cycle.set_mode("day")
	var eco = game.economy
	var cd = game.contracts
	var gy = game.world.graveyard

	# ── 상한 수치 ──
	check("활동 상한 16명(6에서 완화)", Cfg.ACTIVE_LIMIT == 16)
	check("묘지 단계 8·12·16", Cfg.GRAVE_LEVELS == [8, 12, 16])
	check("무덤 자리가 최대 단계만큼 있음", Graveyard.PLOTS.size() >= Cfg.GRAVE_LEVELS[-1])
	check("마당 대기 자리 16곳", cd.YARD.size() >= Cfg.ACTIVE_LIMIT)

	# ── 숲의 괴물 하수인은 상한에 들지 않음 ──
	var before: int = cd.active_count()
	var minion = cd.spawn_guard("minion", "", Vector3(1.0, 0, 6.0))
	await frames(2)
	check("하수인 소환 후에도 활동 수 그대로", cd.active_count() == before, "%d → %d" % [before, cd.active_count()])
	var merc = cd.spawn_guard("merc", "검증용병", Vector3(2.0, 0, 6.0), null, "warrior")
	await frames(2)
	check("용병은 활동 수에 듦", cd.active_count() == before + 1)
	game.cards.add("forest_monster")
	var fm_uid := -1
	for e in game.cards.entries:
		if e["id"] == "forest_monster":
			fm_uid = e["uid"]
	# 활동 상한을 가득 채운 것처럼 만들어도 하수인 카드는 쓸 수 있다
	var fakes: Array = []
	while cd.active_count() < Cfg.ACTIVE_LIMIT:
		fakes.append(cd.spawn_guard("merc", "가득%d" % fakes.size(), Vector3(3.0, 0, 7.0), null, "warrior"))
	await frames(2)
	var center: Vector3 = Vector3(-4.0, 0, 6.0)
	var sp: Vector2 = game.world.camera.unproject_position(center)
	var ev: Dictionary = game.resolver.evaluate(fm_uid, sp) if game.resolver.has_method("evaluate") else {}
	check("활동 상한이 차도 숲의 괴물 카드는 막히지 않음", ev.is_empty() or not str(ev.get("reason", "")).contains("활동 상한"), str(ev.get("reason", "")))
	for f in fakes:
		f.dismiss()
	minion.wither_out()
	await frames(4)

	# ── 묘지: 이미 묻힌 무덤은 고용을 막지 않음 ──
	for i in 8:
		gy.bury("옛 용병%d" % i, 1)
	eco.gold = 500
	var g0: Variant = null
	var offer := {"person": "검증손님", "guest": g0, "expires": eco.prep_time + 30.0, "job": "hunter"}
	eco.offers.append(offer)
	check("무덤 8기가 차 있어도 고용 가능", eco.hire_block_reason(offer) == "", eco.hire_block_reason(offer))
	while eco.roster_count() < gy.capacity():
		game.cards.add("hunter", 1, "카드%d" % eco.roster_count())
	check("데리고 있는 용병이 묘지 크기면 고용 불가", eco.hire_block_reason(offer).contains("묘지"), eco.hire_block_reason(offer))
	gy.upgrade()
	check("묘지 확장(12) 후 다시 고용 가능", gy.capacity() == 12 and eco.hire_block_reason(offer) == "", "%d %s" % [gy.capacity(), eco.hire_block_reason(offer)])
	eco.offers.erase(offer)

	# ── 계약 해지 ──
	var list: Array = eco.contract_list()
	var card_c: Dictionary = {}
	var ally_c: Dictionary = {}
	for c in list:
		if c["kind"] == "card" and card_c.is_empty():
			card_c = c
		if c["kind"] == "ally" and c["ally"] == merc:
			ally_c = c
	check("계약 목록에 활동 중 용병과 미사용 카드", not card_c.is_empty() and not ally_c.is_empty(), "%d건" % list.size())
	var gold0: int = eco.gold
	var roster0: int = eco.roster_count()
	check("미사용 계약 카드 해지", eco.dismiss_contract(card_c))
	check("카드 해지: 계약료 절반 환급", eco.gold == gold0 + Cfg.CONTRACT_COST / 2 and Cfg.CONTRACT_REFUND == Cfg.CONTRACT_COST / 2, "%d → %d" % [gold0, eco.gold])
	check("카드 해지: 카드가 없어짐", game.cards.get_entry(int(card_c["uid"])).is_empty() and eco.roster_count() == roster0 - 1)
	merc.add_carry("raw_meat", 2)
	var meat0: int = game.cards.count_of("raw_meat")
	var discard0: int = game.cards.discard.size()
	gold0 = eco.gold
	check("활동 중 용병 해지", eco.dismiss_contract(ally_c))
	await seconds(0.7)
	check("용병 해지: 절반 환급", eco.gold == gold0 + Cfg.CONTRACT_REFUND)
	check("용병 해지: 월드에서 떠남", not is_instance_valid(merc) or merc.dead)
	check("용병 해지: 들고 있던 자원은 마녀에게", game.cards.count_of("raw_meat") == meat0 + 2)
	check("용병 해지: 계약 카드가 버림패로 가지 않음", game.cards.discard.size() == discard0)
	check("같은 계약은 두 번 해지 안 됨", not eco.dismiss_contract(ally_c))

	# ── 산장 관리 '계약' 탭 ──
	var hud = game.hud
	hud.open_lodge_panel(3)
	await frames(3)
	check("산장 관리에 '계약' 탭", hud.lodge_tabs.get_tab_count() >= 4 and hud.lodge_tabs.get_tab_title(3) == "계약", hud.lodge_tabs.get_tab_title(3))
	check("계약 탭 줄 수 = 계약 수", hud.contract_rows.size() == eco.contract_list().size(), "%d / %d" % [hud.contract_rows.size(), eco.contract_list().size()])
	if not hud.contract_rows.is_empty():
		var row: Dictionary = hud.contract_rows[0]
		check("해지 버튼에 환급액", row["button"].text.contains("+%dG" % Cfg.CONTRACT_REFUND), row["button"].text)
		var n0: int = eco.contract_list().size()
		gold0 = eco.gold
		row["button"].pressed.emit()
		await frames(3)
		check("탭에서 해지 → 목록 줄어듦·환급", eco.contract_list().size() == n0 - 1 and eco.gold == gold0 + Cfg.CONTRACT_REFUND and hud.contract_rows.size() == n0 - 1)
	hud.close_lodge_panel()
	await frames(2)

	# ── 나무꾼 ──
	var tree: Variant = free_tree()
	check("벌목할 나무 있음", tree != null)
	if tree != null:
		var wp: Vector3 = game.resolver.work_position(tree)
		var lj = cd.spawn_chop("검증나무꾼", tree, wp)
		await frames(2)
		lj.state = AllyScript.State.WORKING
		var rem0: int = int(tree["remaining"])
		cd.finish_chop(lj)
		check("벌목 1회 = 목재 1개", int(lj.carry.get("timber", 0)) == 1 and int(tree["remaining"]) == rem0 - 1)
		for i in 20:
			if lj.state != AllyScript.State.WORKING:
				break
			cd.finish_chop(lj)
		check("최대 %d개까지만 든다" % Cfg.LUMBERJACK_CARRY, int(lj.carry.get("timber", 0)) == Cfg.LUMBERJACK_CARRY, str(lj.carry))
		check("가득 차면 벌목을 멈추고 쉰다", lj.state == AllyScript.State.IDLE and lj.tree == null)
		check("나무 예약이 풀림", tree["reserved"] == null)
		check("쉬는 자리는 산장 마당", flat(lj.guard_point, Vector3(2.4, 0, 6.0)) < 3.5, str(lj.guard_point))
		check("상태 표시: 목재 가득", lj.status_text().contains("목재 가득"), lj.status_text())
		check("가득 찬 동안은 다음 나무를 맡지 않음", not cd.assign_next_tree(lj) and lj.state == AllyScript.State.IDLE)
		lj.hand_over()
		check("마녀가 받아 가면 다시 벌목하러 감", cd.assign_next_tree(lj) and lj.state == AllyScript.State.GO_WORK)
		var t_chop: float = lj._chop_time()
		check("벌목 1회 시간 = CHOP_TIME(15초, 1장=1개 전환)", is_equal_approx(t_chop, Cfg.CHOP_TIME) and is_equal_approx(Cfg.CHOP_TIME, 15.0), "%.1f" % t_chop)
		lj.dismiss()
		await frames(2)

	# ── 괴물: 주변의 적을 먼저 공격 ──
	var player = game.player
	var lodge_c: Vector3 = game.world.lodge.global_position
	var mpos := Vector3(-16.0, 0, 6.0)
	var to_lodge: Vector3 = (lodge_c - mpos)
	to_lodge.y = 0
	to_lodge = to_lodge.normalized()
	game.waves.spawn_extra(mpos, "forest")
	await frames(2)
	var mon: Variant = null
	for e in get_nodes_in_group("enemies"):
		if not e.dead and flat(e.global_position, mpos) < 1.0:
			mon = e
	check("시험용 괴물 생성", mon != null)
	if mon != null:
		mon.hp = 1.0e6
		mon.max_hp = 1.0e6
		# 1) 적이 멀리(9m, 산장 반대편) 있으면 무시하고 산장으로
		var far_pos: Vector3 = mpos - to_lodge * 9.0
		player.global_position = far_pos
		player.set_destination(far_pos)
		var d0 := flat(mon.global_position, player.global_position)
		await seconds(1.5)
		check("반경 밖 적은 무시하고 산장으로 감", flat(mon.global_position, player.global_position) > d0 + 0.5 and mon.chase == null,
			"%.1f → %.1f" % [d0, flat(mon.global_position, player.global_position)])
		# 2) 반경 안(4m, 산장 반대편)에 오면 돌아서서 쫓아가 공격
		var near_pos: Vector3 = mon.global_position - to_lodge * 4.0
		player.global_position = near_pos
		player.set_destination(near_pos)
		var hp0: float = player.hp
		await seconds(3.5)
		check("반경 안 적을 먼저 쫓아감", mon.chase == player and flat(mon.global_position, player.global_position) <= mon.reach + 0.6,
			"거리 %.1f" % flat(mon.global_position, player.global_position))
		check("쫓아가 공격함", player.hp < hp0, "%.0f → %.0f" % [hp0, player.hp])
		# 3) 너무 멀어지면(LEASH) 포기
		player.global_position = mon.global_position - to_lodge * (Cfg.MONSTER_LEASH + 3.0)
		player.set_destination(player.global_position)
		await seconds(0.5)
		check("멀어지면 추적 포기", mon.chase != player)
		# 4) 공성 괴물은 여전히 적을 무시
		game.waves.spawn_extra(mpos + Vector3(0, 0, 3.0), "brute")
		await frames(2)
		var brute: Variant = null
		for e in get_nodes_in_group("enemies"):
			if not e.dead and e.get("ignore_units") == true:
				brute = e
		if brute != null:
			player.global_position = brute.global_position + Vector3(0, 0, 2.0)
			player.set_destination(player.global_position)
			await seconds(0.5)
			check("공성 괴물은 적을 쫓지 않음", brute.chase == null)
	player.hp = player.max_hp

	print("RESULT %d/%d" % [total - failures, total])
	quit(1 if failures > 0 else 0)
