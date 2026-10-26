extends SceneTree
## 용병 고유 키트 v04 — 드워프·요정·고블린·수인·오크 20명과 종족 시너지 헤드리스 검증(docs/mercenary-unique-kit-v04.md).
##   .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_merc_kit_all.gd
## 인간 4명·공통 틀(기세·마력·생성 카드·드로우 없음)은 verify_merc_kit.gd 가 본다.
## 종족마다 4명을 세워(그 종족 시너지 2·3단계가 켜진 상태) 패시브·고유 스킬·고유 카드·생성 카드가 화면에서 보일 효과를 내는지 확인한다.

const Layout := preload("res://scripts/world/layout.gd")
const MonsterScript := preload("res://scripts/actors/monster.gd")
const MercKit := preload("res://scripts/game/merc_kit.gd")
const LureScript := preload("res://scripts/actors/goblin_lure.gd")

var game
var kit
var passed := 0
var total := 0
var c: Vector3


func check(ok: bool, label: String, detail := "") -> void:
	total += 1
	if ok:
		passed += 1
	print(("PASS " if ok else "FAIL ") + label + ("  — " + detail if detail != "" else ""))


func _initialize() -> void:
	create_timer(300.0, true, false, true).timeout.connect(func(): push_error("merc kit all verification timeout"); quit(2))
	call_deferred("run")


func pframes(n := 3) -> void:
	for i in n:
		await physics_frame


func seconds(t: float) -> void:
	var start := Time.get_ticks_msec()
	while Time.get_ticks_msec() - start < t * 1000.0:
		await physics_frame


func enemy(pos: Vector3, hp := 400.0, kind := "spider"):
	var m := MonsterScript.new()
	m.setup(game, hp, false)
	m.configure(kind)
	m.position = pos
	game.actors.add_child(m)
	m.set_physics_process(false)
	m.set_process(false)
	return m


func clear_enemies() -> void:
	for e in get_nodes_in_group("enemies"):
		e.remove_from_group("enemies")
		e.queue_free()


func clear_walls() -> void:
	for f in get_nodes_in_group("allies"):
		if f.get("kind") in MercKit.WALL_KINDS:
			f.remove_from_group("allies")
			f.queue_free()


## 한 종족 4명을 세운다. 이전 무리는 치운다. 반환: 이름 → 용병.
func squad(people: Array) -> Dictionary:
	for a in game.contracts.allies.duplicate():
		game.contracts.allies.erase(a)
		a.queue_free()
	clear_enemies()
	clear_walls()
	game.cards.entries = game.cards.entries.filter(func(e): return not e.get("generated", false))
	await pframes(2)
	var out := {}
	var i := 0
	for p in people:
		var job: String = preload("res://scripts/ui/guest_profiles.gd").JOBS[p]
		var a = game.contracts.spawn_guard("merc", p, c + Vector3(cos(i * 1.6), 0, sin(i * 1.6)) * 1.5, null, job)
		a.set_physics_process(false)
		out[p] = a
		i += 1
	await pframes(2)
	while game.cards.hand().size() > 2:
		game.cards.entries.erase(game.cards.hand()[0])
	kit.start_battle()
	return out


func gen_count(id: String) -> int:
	return game.cards.hand().filter(func(e): return e["id"] == id and e.get("generated", false)).size() + kit._queue.filter(func(q): return q[0] == id).size()


func slowed(e, key: String) -> bool:
	return e._slows.has(key)


func cast(a) -> bool:
	var before: int = kit.stats["casts"]
	kit.momentum[a.get_instance_id()] = 100.0
	kit.tick(0.0)
	return kit.stats["casts"] == before + 1


func run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await pframes(12)
	game.session.set_process(false)
	game.economy.set_process(false)
	kit = game.merc_kit
	kit.set_process(false)
	c = Layout.CAMPFIRE
	game.session.start_wave()
	game.waves.stop()
	game.waves.set_process(false)
	await pframes(3)

	var en: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/cards/catalog_en.json"))["cards"]
	var missing: Array = MercKit.CARD_IDS.filter(func(id): return not game.cards.defs.has(id) or not en.has(id) or game.cards.phase_of(id) != "night" or not ResourceLoader.exists(game.cards.def(id)["texture"]))
	check(missing.is_empty(), "카드 %d장 모두 한국어·영문·밤·원화 경로" % MercKit.CARD_IDS.size(), str(missing))
	var bad_kits: Array = MercKit.KITS.keys().filter(func(p): return MercKit.KITS[p]["cards"].values().reduce(func(s, n): return s + n, 0) > 2)
	check(MercKit.KITS.size() == 24 and bad_kits.is_empty(), "24명, 고유 카드는 인물마다 최대 2장")

	# ───── 인간 시너지 ─────
	var h := await squad(["브람", "올라프", "토르빈", "미라"])
	check(is_equal_approx(kit.mana, MercKit.MANA_START + MercKit.SYN_HUMAN_MANA), "인간 셋: 전투 시작 마력 +2", str(kit.mana))
	check(kit.cost_of("merc_war_horn") == 1, "인간 둘: 전투 첫 카드 마력 -1")

	# ───── 드워프 ─────
	var d := await squad(["하랄", "브륀힐드", "토르그림", "두르가"])
	var hp0: float = d["하랄"].hp
	d["하랄"].take_damage(10.0)
	check(is_equal_approx(hp0 - d["하랄"].hp, 7.0), "하랄 돌 피부: 받는 피해 -30%")
	var foe = enemy(d["하랄"].global_position + Vector3(2.0, 0, 0))
	await pframes(1)
	check(cast(d["하랄"]) and kit.taunt_of(foe) == d["하랄"], "하랄 철테 방패: 주변 적이 하랄만 노림")
	check(foe._pick_foe() == d["하랄"], "도발된 적의 대상 선택이 하랄")
	clear_enemies()
	var from: Vector3 = d["브륀힐드"].global_position
	var row: Array = []
	for i in 3:
		row.append(enemy(from + Vector3(3.0 + i * 1.5, 0, 0)))
	await pframes(1)
	var gb := gen_count("gen_bolt")
	check(cast(d["브륀힐드"]) and row.all(func(e): return is_equal_approx(e.hp, 400.0 - MercKit.BOLT_DAMAGE)), "브륀힐드 대못 석궁: 한 줄 관통 35")
	check(gen_count("gen_bolt") == gb + 1, "꿰뚫기: 3마리를 꿰뚫으면 [대못]")
	kit.mana = 6.0
	check(kit.cost_of("merc_all_in") == 6, "전부 걸어!: 가진 마력 전부")
	kit.apply_card("merc_all_in", {"pos": from + Vector3(8.0, 0, 0)}, 6)
	check(is_equal_approx(row[0].hp, 400.0 - MercKit.BOLT_DAMAGE - 60.0), "전부 걸어!: 쓴 마력 × 10 피해", str(row[0].hp))
	clear_enemies()
	var wall = game.race_cards._build("timber_wall", c + Vector3(-5, 0, 5))
	check(is_equal_approx(wall.max_hp, 200.0 * MercKit.WALL_HP_MULT * MercKit.SYN_DWARF_WALL), "갱목 방벽 200 × 토르그림 1.5 × 드워프 둘 1.5", str(wall.max_hp))
	wall.hp = 50.0
	check(cast(d["토르그림"]) and is_equal_approx(wall.hp, wall.max_hp), "토르그림 쐐기 박기: 가장 부서진 벽을 가득")
	check(is_equal_approx(kit.lodge_taken_mult(), MercKit.SYN_DWARF_LODGE), "드워프 셋: 산장 받는 피해 -15%")
	var olaf_like = d["하랄"]
	olaf_like.hp = olaf_like.max_hp * 0.6
	var gs := gen_count("gen_salve")
	olaf_like.take_damage(olaf_like.max_hp * 0.2 / 0.7)
	check(gen_count("gen_salve") == gs + 1, "두르가 잔소리 약: 절반 아래로 다치면 [고약]")
	check(cast(d["두르가"]) and is_equal_approx(kit.interval_mult(d["브륀힐드"]), 1.0 / MercKit.ROAR_SPEED), "두르가 호통: 모든 아군 공격 속도 +50%")
	var casts: int = kit.stats["casts"]
	var bh: float = d["하랄"].hp
	kit.apply_card("merc_bitter", {"ally": d["하랄"]})
	foe = enemy(d["하랄"].global_position + Vector3(1.5, 0, 0))
	kit.apply_card("merc_bitter", {"ally": d["하랄"]})
	check(kit.stats["casts"] == casts + 1 and d["하랄"].hp < bh, "쓴 약: 체력을 잃고 바로 고유 스킬(대상이 있을 때)")
	kit.apply_card("merc_hold_line", {"pos": foe.global_position})
	check(slowed(foe, "merc_root") and kit.taunt_of(foe) == d["하랄"], "하랄의 버팀목: 지점의 적이 묶이고 하랄을 노림")

	# ───── 요정 ─────
	var f := await squad(["티슬", "틸리아", "라르크", "페른"])
	check(gen_count("gen_root") == 2, "라르크 가시 가지: 전투 시작 [얽힌 뿌리] 2장")
	kit.momentum.clear()
	kit.add_momentum(f["틸리아"], 10.0)
	check(is_equal_approx(kit.momentum_of(f["틸리아"]), 10.0 * 2.0 * MercKit.SYN_FAIRY_MOMENTUM), "틸리아 나방 날개 ×2, 요정 셋 ×1.3", str(kit.momentum_of(f["틸리아"])))
	check(is_equal_approx(kit.speed_mult(f["티슬"]), MercKit.SYN_FAIRY_SPEED), "요정 둘: 이동 속도 +30%")
	var weak = enemy(c + Vector3(4, 0, 0), 100.0)
	var tough = enemy(c + Vector3(5, 0, 2), 600.0)
	await pframes(1)
	kit.tick(0.6)
	check(f["티슬"].priority == tough, "티슬 결투 예법: 가장 강한 적을 노림")
	check(cast(f["티슬"]) and kit.taunt_of(tough) == f["티슬"], "티슬 가시 창 결투: 강한 적이 티슬만 노림")
	kit.apply_card("gen_root", {"pos": weak.global_position})
	check(slowed(weak, "merc_root"), "얽힌 뿌리: 지점의 적이 묶임")
	kit.apply_card("merc_pruning", {"enemy": weak})
	check(is_equal_approx(weak.hp, 100.0 - MercKit.PRUNE_DAMAGE), "가지치기: 피해 40")
	kit.apply_card("merc_pollen", {"pos": tough.global_position})
	check(slowed(tough, "merc_sleep"), "꽃가루 잠: 적이 잠듦")
	tough.take_damage(1.0)
	check(not slowed(tough, "merc_sleep"), "잠든 적은 맞으면 깸")
	kit.apply_card("merc_thistle_hedge", {"pos": weak.global_position})
	var whp: float = weak.hp
	kit.tick(1.05)
	check(slowed(weak, "merc_hedge") and weak.hp < whp, "엉겅퀴 울타리: 안의 적이 느려지고 피해")
	kit.apply_card("merc_moth_dust", {"pos": tough.global_position})
	check(slowed(tough, "merc_dust"), "나방 가루: 앞쪽 적이 크게 느려짐")
	var flowers: int = kit.zones_of("flower").size()
	weak.take_damage(9999.0)
	check(kit.zones_of("flower").size() == flowers + 1, "페른 씨앗 주머니: 적이 쓰러진 자리에 회복 꽃")
	f["티슬"].hp = f["티슬"].max_hp * 0.5
	check(cast(f["페른"]) and kit.zones_of("garden").size() == 1, "페른 씨앗 심기: 다친 아군 자리에 꽃밭")
	var th: float = f["티슬"].hp
	kit.tick(1.05)
	check(f["티슬"].hp > th, "꽃밭 안 아군 회복")
	var thp: float = tough.hp
	check(cast(f["틸리아"]), "틸리아 화살세례 시전")
	await seconds(2.3)
	check(tough.hp < thp - 15.0, "화살세례: 3초에 걸쳐 피해", "%.1f" % (thp - tough.hp))

	# ───── 고블린 ─────
	var g := await squad(["그라즈", "피클", "러스크", "타크"])
	check(kit.start_hand() == MercKit.START_HAND + 1, "고블린 둘: 밤 시작 손패 +1")
	check(kit.cost_of("merc_junk_bomb") == 0, "고블린 셋: 고블린 고유 카드 마력 -1")
	for i in 3:
		enemy(g["그라즈"].global_position + Vector3(1.0 + i * 0.5, 0, 1.0))
	await pframes(1)
	check(is_equal_approx(kit.damage_mult(g["그라즈"]), MercKit.BLUFF_DAMAGE), "그라즈 허세: 둘러싸이면 공격력 +50%")
	check(cast(g["그라즈"]) and get_nodes_in_group("enemies").all(func(e): return kit.taunt_of(e) == g["그라즈"]), "그라즈 냄비 투구 함성: 주변 적이 그라즈만")
	clear_enemies()
	var big = enemy(c + Vector3(6, 0, 0), 600.0)
	await pframes(1)
	check(cast(g["피클"]) and slowed(big, "merc_root") and is_equal_approx(big.hp, 600.0 - MercKit.SNARE_ARROW_DAMAGE), "피클 올가미 화살: 가장 강한 적 묶고 30")
	for i in 3:
		game.cards.add("wild_grimoire", 1, "", "pocket")
	var td: int = kit.stats["tally_draws"]
	for i in 3:
		game.cards.card_used.emit("merc_snare")
	check(kit.stats["tally_draws"] == td + 1, "피클 셈 매듭: 카드 3장마다 덱에서 1장")
	kit.apply_card("merc_snare", {"pos": c + Vector3(8, 0, 0)})
	var walker = enemy(c + Vector3(8, 0, 0))
	await pframes(1)
	kit.tick(0.0)
	check(slowed(walker, "merc_root"), "올가미 덫: 밟은 적이 묶임")
	var gj := gen_count("gen_junk_wall")
	check(cast(g["러스크"]) and gen_count("gen_junk_wall") == gj + 2, "러스크: [급조 방책] 2장")
	var jw = game.race_cards._build("junk_wall", c + Vector3(-6, 0, -3))
	var leaner = enemy(jw.global_position + Vector3(1.0, 0, 0))
	await pframes(1)
	kit._saw_t = 0.0
	kit.tick(1.0)
	check(is_equal_approx(leaner.hp, 400.0 - MercKit.SAW_DPS * MercKit.JUNK_SAW_MULT), "톱날 셋: 급조 방책에 붙은 적 초당 10", str(leaner.hp))
	var gm := gen_count("gen_marble")
	check(cast(g["타크"]) and gen_count("gen_marble") == gm + 2, "타크: [반짝이 구슬] 2장")
	kit.apply_card("gen_marble", {"pos": leaner.global_position})
	check(slowed(leaner, "merc_stun") and leaner.attack_cd >= 1.9, "반짝이 구슬: 적이 넘어짐")
	var hitter = enemy(g["타크"].global_position + Vector3(1, 0, 0))
	await pframes(1)
	kit.enemy_out_mult(hitter, g["타크"])
	check(slowed(hitter, "merc_stun"), "타크를 때린 적이 미끄러짐")
	var bomb_hp: float = hitter.hp
	kit.apply_card("merc_junk_bomb", {"pos": hitter.global_position})
	check(is_equal_approx(bomb_hp - hitter.hp, MercKit.BOMB_DAMAGE), "고물 폭탄: 피해 25")
	var lures := get_nodes_in_group("allies").filter(func(n): return n.get_script() == LureScript).size()
	kit.apply_card("merc_lure", {"pos": c + Vector3(3, 0, 3)})
	await pframes(1)
	check(get_nodes_in_group("allies").filter(func(n): return n.get_script() == LureScript).size() == lures + 1 or game.actors.get_children().any(func(n): return n.get_script() == LureScript), "반짝이 미끼: 미끼가 놓임")
	var line_e = enemy(Vector3(6.0, 0, 0))
	await pframes(1)
	kit.apply_card("merc_saw_wheel", {"pos": Vector3(10.0, 0, 0)})
	await seconds(2.4)
	check(is_equal_approx(line_e.hp, 400.0 - MercKit.SAW_WHEEL_DPS * MercKit.SAW_WHEEL_TIME), "톱날 바퀴: 줄 위 적 초당 18 × 3초", str(line_e.hp))

	# ───── 수인 ─────
	var b := await squad(["파르그", "사야", "우르소", "모미"])
	check(gen_count("gen_honey") == 2, "우르소 꿀 단지: 전투 시작 [꿀단지] 2장")
	check(is_equal_approx(kit.damage_mult(b["파르그"]), 1.3), "파르그 무리: 곁의 아군 3명 → 공격력 +30%", str(kit.damage_mult(b["파르그"])))
	var scared = enemy(b["파르그"].global_position + Vector3(2.0, 0, 0))
	await pframes(1)
	var sp0: Vector3 = scared.global_position
	check(cast(b["파르그"]) and slowed(scared, "merc_stun") and scared.global_position.distance_to(sp0) > 2.0, "파르그 울부짖음: 겁먹고 밀려남")
	kit.apply_card("merc_blood_scent", {})
	check(is_equal_approx(kit.interval_mult(b["모미"]), 1.0 / MercKit.SCENT_SPEED), "피냄새: 주변 아군 공격 속도 +50%")
	clear_enemies()
	var near_e = enemy(b["사야"].global_position + Vector3(3, 0, 0))
	var far_e = enemy(b["사야"].global_position + Vector3(15, 0, 0))
	await pframes(1)
	check(cast(b["사야"]) and is_equal_approx(far_e.hp, 400.0 - MercKit.SNIPE_DAMAGE) and is_equal_approx(near_e.hp, 400.0), "사야 그림자 사격: 가장 먼 적 45")
	var gsa := gen_count("gen_shadow_arrow")
	far_e.hp = 1.0
	far_e.take_damage(5.0)
	kit.on_kill(b["사야"], far_e)
	check(gen_count("gen_shadow_arrow") == gsa + 1, "사야 밤눈: 가장 먼 적을 쓰러뜨리면 [그림자 화살]")
	kit.apply_card("merc_ambush", {})
	check(kit.stealthed(b["사야"]) and not near_e._foe_valid(b["사야"]), "매복: 적이 사야를 노리지 않음")
	check(is_equal_approx(kit.damage_mult(b["사야"]), MercKit.AMBUSH_MULT), "매복: 다음 공격 3배")
	kit.on_ally_hit(b["사야"], near_e)
	check(is_equal_approx(kit.damage_mult(b["사야"]), 1.0), "매복은 첫 공격 한 번")
	kit.apply_card("gen_honey", {"pos": near_e.global_position})
	check(slowed(near_e, "merc_honey"), "꿀단지: 크게 느려짐")
	var nh: float = near_e.hp
	near_e.global_position = b["우르소"].global_position + Vector3(3, 0, 0)
	check(cast(b["우르소"]) and is_equal_approx(nh - near_e.hp, MercKit.THROW_DAMAGE), "우르소 통나무 던지기: 피해 30")
	kit.apply_card("merc_bear_hug", {"enemy": near_e})
	check(slowed(near_e, "merc_stun"), "곰의 포옹: 큰 적을 붙잡음")
	clear_enemies()
	var gh := gen_count("gen_herb_handful")
	enemy(b["모미"].global_position + Vector3(2, 0, 0))
	await pframes(1)
	kit.tick(0.0)
	check(gen_count("gen_herb_handful") == gh + 1, "모미 깜짝 놀람: 적이 다가오면 [약초 한 줌]")
	kit.apply_card("merc_run", {})
	check(is_equal_approx(kit.speed_mult(b["파르그"]), MercKit.RUN_SPEED), "도망쳐!: 모든 아군이 빨라짐")
	b["모미"].hp = b["모미"].max_hp - 10.0
	var dying = enemy(b["모미"].global_position + Vector3(1, 0, 0), 5.0)
	await pframes(1)
	dying.take_damage(99.0)
	check(is_equal_approx(b["모미"].hp, b["모미"].max_hp - 10.0 + MercKit.SYN_BEAST_HEAL), "수인 둘: 적이 쓰러지면 근처 아군 회복")
	b["파르그"].hp = b["파르그"].max_hp * 0.4
	check(kit.damage_mult(b["파르그"]) > 1.3 * 1.39, "수인 셋: 체력 절반 이하 수인 공격력 +40%")

	# ───── 오크 ─────
	var o := await squad(["가로크", "크라냐", "모가", "샤가"])
	check(gen_count("gen_ash_charm") == 1, "샤가 재의 문양: 전투 시작 [재의 부적]")
	check(kit.oath != null and kit.oath != o["가로크"], "가로크 맹세: 지킬 동료가 정해짐")
	kit.oath = o["크라냐"]
	check(is_equal_approx(kit.damage_mult(o["가로크"]), 1.0 + MercKit.OATH_MULT), "맹세: 동료 곁에서 가로크 피해 +30%")
	kit.apply_card("merc_oath_shield", {"ally": o["모가"]})
	var gk: float = o["가로크"].hp
	var mg: float = o["모가"].hp
	o["모가"].take_damage(10.0)
	check(is_equal_approx(o["모가"].hp, mg) and o["가로크"].hp < gk, "맹세의 방패: 가로크가 대신 맞음")
	check(kit.oath == o["모가"], "맹세의 방패를 쓴 동료가 맹세 동료가 됨")
	var brute = enemy(c + Vector3(7, 0, 0), 800.0, "brute")
	var brute_hp: float = brute.hp
	var small = enemy(c + Vector3(4, 0, 2), 400.0)
	await pframes(1)
	check(cast(o["크라냐"]) and is_equal_approx(brute.hp, brute_hp - MercKit.SPEAR_SKILL_DAMAGE), "크라냐 투창: 가장 큰 적 70")
	kit.apply_card("merc_bone_spear", {"enemy": small})
	check(is_equal_approx(small.hp, 400.0 - MercKit.BONE_SPEAR_DAMAGE), "뼈 투창: 피해 45")
	var gt := gen_count("gen_trophy")
	brute.take_damage(9999.0)
	check(gen_count("gen_trophy") == gt + 1, "크라냐 전리품: 큰 적이 쓰러지면 [전리품 자랑]")
	kit.mana = 2.0
	kit.apply_card("gen_trophy", {})
	check(is_equal_approx(kit.mana, 5.0), "전리품 자랑: 마력 +3")
	var lw = game.race_cards._build("log_wall", c + Vector3(-4, 0, 4))
	var gf := gen_count("gen_forgive")
	lw.take_damage(9999.0)
	check(gen_count("gen_forgive") == gf + 1, "모가 사과의 의식: 벽이 부서지면 [나무의 용서]")
	check(cast(o["모가"]) and slowed(small, "merc_root"), "모가 덩굴 기도: 몰린 적이 묶임")
	var sh: float = small.hp
	kit.apply_card("merc_axe_whirl", {"pos": small.global_position})
	check(is_equal_approx(sh - small.hp, MercKit.WHIRL_DAMAGE), "양날 도끼 회오리: 피해 25")
	check(cast(o["샤가"]) and is_equal_approx(kit.enemy_out_mult(small, o["모가"]), MercKit.ASH_OUT), "샤가 재 구름: 안의 적 공격이 절반")
	kit.apply_card("gen_ash_charm", {"enemy": small})
	check(slowed(small, "merc_stun"), "재의 부적: 피해와 기절")
	kit.apply_card("merc_ash_blessing", {"ally": o["샤가"]})
	o["샤가"].take_damage(9999.0)
	check(not o["샤가"].dead and is_equal_approx(o["샤가"].hp, 1.0), "재의 축복: 한 번 쓰러지지 않음")
	o["크라냐"].hp = o["크라냐"].max_hp * 0.4
	check(kit.taken_mult(o["크라냐"]) <= MercKit.SYN_ORC_TAKEN + 0.001, "오크 셋: 체력 절반 이하 오크 받는 피해 -30%")
	kit._guard.clear()
	o["모가"].take_damage(9999.0)
	await pframes(2)
	check(is_equal_approx(kit.damage_mult(o["크라냐"]) / (1.0), MercKit.SYN_ORC_RAGE) and is_equal_approx(kit.momentum_of(o["크라냐"]), 100.0), "오크 둘: 오크가 쓰러지면 다른 오크 피해 +50%·기세 100", str(kit.damage_mult(o["크라냐"])))

	kit.end_battle()
	check(game.cards.entries.all(func(e): return not e.get("generated", false)) and kit._zones.is_empty(), "전투 끝: 생성 카드·지대가 사라짐")
	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)
