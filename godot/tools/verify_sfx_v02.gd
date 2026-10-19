extends SceneTree
## 빈 소리 v02(P1·P2 30종) 연결 검증: 실제 게임 장면에서 각 상황을 일으키고 SoundBank 재생 기록(history)에 전용 이벤트가 남는지 본다.
## 낮(침식·정화·모닥불·스튜·태우기·초대장·늑대의 피·반딧불이·제단·의식·시장) → 밤(보스·침식된 자·공성 괴물·덩굴·축복·보름달 늑대·활) → 반딧불 흩어짐.
## 실행: godot --headless --path . --script res://tools/verify_sfx_v02.gd
const Cfg := preload("res://scripts/config.gd")
const KEYS := ["prologue_page", "boss_roar", "boss_attack", "boss_die", "wolf_transform", "wolf_claw", "wolf_pounce", "wolf_bite",
	"wolf_revert", "wolf_blood_drink", "moon_cast", "vine_bind", "firefly_release", "firefly_disperse", "card_burn",
	"fire_stoke", "stew_cook", "corruption_gain", "altar_awaken", "ritual_done", "purify", "letter_send", "timber_stack",
	"bow_shot", "cultist_spawn", "cultist_hurt", "cultist_die", "brute_spawn", "brute_hurt", "brute_die"]
var game
var bank
var passed := 0
var total := 0
var notes: Array = []

func _initialize() -> void:
	call_deferred("run")

func frames(n: int) -> void:
	for i in n: await physics_frame

func wait(s: float) -> void:
	await create_timer(s).timeout

func sp(p: Vector3) -> Vector2:
	return game.world.camera.unproject_position(p)

func give(id: String) -> int:
	game.cards.add(id, 1, "검증", "hand")
	var uid := -1
	for e in game.cards.entries:
		if e["id"] == id: uid = e["uid"]
	return uid

## 헤드리스(더미 오디오)에서는 원샷 재생이 끝나지 않아 동시 재생 상한(MAX_VOICES)에 걸린다 → 검증 중 원샷 플레이어를 비운다.
func drain() -> void:
	if game.player != null and not game.player.dead: game.player.hp = game.player.max_hp
	for c in bank.get_children():
		if c is AudioStreamPlayer and c.finished.is_connected(c.queue_free): c.free()

func use(id: String, at: Vector3) -> void:
	drain()
	var r: Dictionary = game.resolver.commit(give(id), sp(at))
	if not r.get("ok", false):
		notes.append("%s: %s" % [id, r.get("reason", r.get("msg", str(r)))])
	await frames(3)

func player_at() -> Vector3:
	return game.player.global_position + Vector3(0, 1.0, 0)

func check(name: String, ok: bool, detail := "") -> void:
	total += 1
	if ok: passed += 1
	print("%s %s %s" % ["PASS" if ok else "FAIL", name, detail])

func run() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	await frames(40)
	game = current_scene
	bank = game.sounds
	paused = false
	var missing: Array = KEYS.filter(func(k): return not bank.streams.has(k) or bank.streams[k].is_empty())
	check("STREAMS 30종 로드", missing.is_empty(), str(missing))
	Engine.time_scale = 4.0
	var yard = game.world.yard
	var fire: Vector3 = yard.campfire.global_position + Vector3(0, 0.6, 0)
	var lodge: Vector3 = game.world.lodge.global_position + Vector3(0, 2.0, 0)

	# ── 프롤로그 컷 넘김
	var pro = game.opening.get("prologue") if game.get("opening") != null else null
	if pro == null:
		pro = load("res://scripts/ui/prologue.gd").new()
		game.add_child(pro)
		await frames(2)
	if pro.has_method("_start_cut"):
		pro._start_cut(1)
	await frames(2)

	# ── 낮
	game.session.prep_elapsed = 25.0
	game.chapter.corruption_tonight = 0
	game.chapter.add_corruption("cursed_whisper", "검증")
	game.player.hp = game.player.max_hp * 0.5
	await use("moss_bandage", player_at())
	await use("timber", fire)            # 장작 넣기
	await use("raw_meat", fire)          # 스튜
	await use("wool", fire)              # 태우기
	await use("guest_invitation", lodge)
	await use("wolf_blood", player_at())
	if not game.world.towers.is_empty():
		var tw = game.world.towers[0]
		await use("timber", tw.global_position + Vector3(0, 0.5, 0))
	else:
		notes.append("감시탑 공터 없음")
	await use("shroud_cloth", game.player.global_position + Vector3(-4.0, 0.0, 3.0))
	# 제단: 해금 → 복구 → 의식
	drain()
	var ch = game.chapter
	ch.altar_unlocked = false
	var unlock_day := -1
	for d in range(1, ch.total_days() + 1):
		if ch.day_cfg(d).get("unlock", "") == "altar": unlock_day = d
	if unlock_day > 0:
		ch.on_prep_start(unlock_day)
	game.cards.add("timber", 10, "", "hand")
	game.player.global_position = ch.altar_pos()
	await frames(2)
	if not ch.restore_altar(): notes.append("제단 복구: " + ch.restore_block_reason())
	game.cards.add("wool", 4, "", "hand")
	var rid: String = Cfg.RITUALS.keys()[0]
	for k in Cfg.RITUALS.keys():
		if ch.ritual_block_reason(k) == "": rid = k
	var why_r: String = ch.ritual_block_reason(rid)
	if why_r != "":
		notes.append("의식 %s: %s" % [rid, why_r])
		game.cards.add("forest_monster", 1, "검증", "hand")
		for c in Cfg.RITUALS[rid]["cost"].keys():
			if game.cards.defs.has(c): game.cards.add(c, 3, "검증", "hand")
		notes.append("의식 재시도: " + ch.ritual_block_reason(rid))
	ch.perform_ritual(rid)
	drain()
	game.economy.gold = 9999
	var offers: Array = ch.market_offers()
	var spend_before: int = bank.history.count("gold_spend")
	if not offers.is_empty():
		if not ch.buy(offers[0]): notes.append("시장: " + ch.buy_block_reason(offers[0]))
	var buy_spend: bool = bank.history.count("gold_spend") > spend_before
	await wait(1.0)

	# ── 산장 관리 메뉴: 손님 생활 앰비언스가 열려 있는 동안 반복, 닫으면 빠짐
	drain()
	game.hud.open_lodge_panel()
	await wait(0.4)
	var amb = bank._room_amb
	check("산장 메뉴 열림 → lodge_ambience 반복 재생", amb != null and amb.playing and bank.history.has("lodge_ambience") and get_root().get_tree().paused, "playing=%s paused=%s" % [amb != null and amb.playing, paused])
	await create_timer(1.6, true, false, true).timeout
	check("메뉴 안에서 음량이 올라옴(정지 중에도)", amb != null and amb.volume_db > -20.0, "%.1f dB" % (amb.volume_db if amb != null else -99.0))
	var life_from: int = bank.history.size()
	for i in 30:
		drain()
		await create_timer(1.0, true, false, true).timeout
	var life: Array = bank.history.slice(life_from).filter(func(e): return e in ["lodge_laugh", "lodge_toast", "lodge_laugh_small"])
	check("메뉴 안 손님 웃음·건배가 무작위로 섞임(정지 중에도)", life.size() >= 2, str(life))
	check("둘이 나누는 짧은 웃음도 섞임", life.has("lodge_laugh_small"), str(life.count("lodge_laugh_small")))
	game.hud.close_lodge_panel()
	await create_timer(1.0, true, false, true).timeout
	check("메뉴 닫힘 → 앰비언스 멈춤", amb != null and not amb.playing)
	var after: int = bank.history.size()
	await create_timer(9.0, true, false, true).timeout
	check("메뉴 닫힌 뒤 웃음·건배 멈춤", bank.history.slice(after).filter(func(e): return e in ["lodge_laugh", "lodge_toast", "lodge_laugh_small"]).is_empty())
	paused = false

	# ── 밤
	game.player.global_position = Vector3.ZERO
	game.session.start_wave()
	await frames(10)
	paused = false
	game.hud.set("paused_by_user", false)
	await use("firefly_swarm", game.player.global_position + Vector3(-5.0, 0.0, 4.0))
	var near: Vector3 = game.player.global_position
	var foes := {}
	for kind in ["boss", "cultist", "brute"]:
		game.waves.spawn_extra((game.world.lodge.global_position + Vector3(0, 0, 3.5)) if kind == "boss" else near + Vector3(2.5, 0, -1.5), kind)
		await frames(2)
		for e in get_nodes_in_group("enemies"):
			if e.get("kind") == kind: foes[kind] = e
	for i in 40:
		drain()
		await wait(0.5)  # 보스 공격이 나올 시간
	paused = false
	for kind in ["cultist", "brute"]:
		if foes.has(kind) and is_instance_valid(foes[kind]):
			foes[kind].take_damage(1.0)
	if foes.has("boss"):
		foes["boss"]._roar_t = 0.0
		foes["boss"]._tick_roar(0.1)
	await frames(3)
	var spider = null
	for e in get_nodes_in_group("enemies"):
		if not e.dead and e.get("kind") == "spider": spider = e
	if spider == null and foes.has("cultist"): spider = foes["cultist"]
	paused = false
	await use("vine_snare", spider.global_position + Vector3(0, 0.6, 0) if spider != null else near)
	var ally = game.contracts.spawn_guard("merc", "검증사냥꾼", near + Vector3(-1, 0, -1), null, "hunter")
	await frames(3)
	if ally != null and spider != null:
		ally._shoot(spider, 1.0)
	await use("full_moon", player_at())
	await wait(0.5)
	game.player.suffering = 0.0
	if not game.player.wolf: game.player.set_wolf(true)
	var tgt = foes.get("boss", spider)
	if tgt != null and is_instance_valid(tgt):
		game.player.global_position = tgt.global_position + Vector3(1.2, 0, 0)
		drain()
		notes.append("claw %s" % game.player.cast_claw(tgt.global_position))
		await wait(1.5)
		drain()
		if is_instance_valid(tgt) and not tgt.dead: game.player._bite(tgt)
		game.player.claw_cd = 0.0
		game.player.claw_t = 0.0
		var pt = tgt if is_instance_valid(tgt) and not tgt.dead else spider
		if pt != null and is_instance_valid(pt): notes.append("pounce %s" % game.player.cast_pounce(pt))
		await wait(2.0)
		if is_instance_valid(tgt) and not tgt.dead: game.player._bite(tgt)
		await wait(2.0)
	drain()
	notes.append("before revert: wolf=%s dead=%s hp=%d" % [game.player.wolf, game.player.dead, game.player.hp])
	game.player.set_wolf(false)
	for kind in ["boss", "cultist", "brute"]:
		if foes.has(kind) and is_instance_valid(foes[kind]) and not foes[kind].dead:
			foes[kind].die()
	for s in get_nodes_in_group("firefly_swarms"):
		s.disperse()
	await frames(5)

	var h: Array = bank.history
	for k in KEYS:
		if k == "boss_roar":
			check(k, h.count(k) >= 2, "등장+울부짖음 %d회" % h.count(k))
		else:
			check(k, h.has(k))
	check("시장 구매 = gold_spend", buy_spend)
	for n in notes: print("NOTE " + n)
	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)
