extends SceneTree
## 게임 효과음 연결 검증: 실제 게임 장면에서 압축한 플레이로 선택된 84개 소리가 실제로 울리는지 기록한다.
## 낮(고용·벌목·상점·창·정지·양털·손님 이야기·위험 지역·모닥불) → 밤(웨이브·등불·서리·하수인·용·처치) → 새벽 → 패배·승리.
## 실행: godot --headless --path . --script res://tools/verify_game_sfx.gd
const Sites := preload("res://scripts/world/hazard_sites.gd")
const CAMP := Vector3(-20.0, 0.0, 23.0)
var game
var bank
var combat_mix_max := 0.0

func _initialize() -> void:
	call_deferred("run")

func frames(n: int) -> void:
	for i in n: await physics_frame

func wait(s: float) -> void:
	await create_timer(s).timeout

func sp(p: Vector3) -> Vector2:
	return game.world.camera.unproject_position(p)

func uid_of(id: String) -> int:
	for e in game.cards.entries:
		if e["id"] == id: return e["uid"]
	return -1

func teleport(p: Vector3) -> void:
	game.player.global_position = p
	game.player.moving = false

func enemies() -> Array:
	return get_nodes_in_group("wave_enemies").filter(func(e): return is_instance_valid(e) and not e.dead)

func run() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	await frames(40)
	game = current_scene
	bank = game.sounds
	paused = false
	var picks = JSON.parse_string(FileAccess.get_file_as_string("res://../output/audio-game-sfx-v01/picks.json"))
	var expected: Array = []
	for p in picks:
		expected.append("magic_bolt" if p["key"] == "bolt_cast" else p["key"])
	var missing_streams: Array = expected.filter(func(e): return not bank.streams.has(e))
	print("STREAMS loaded %d/%d missing=%s" % [expected.size() - missing_streams.size(), expected.size(), missing_streams])
	Engine.time_scale = 4.0
	var eco = game.economy
	var lodge = game.world.lodge
	var hand = game.hud.card_hand
	var home: Vector3 = game.player.global_position

	# ── 낮 1: 손님·고용·벌목
	game.session.prep_elapsed = 25.2
	await frames(30)
	if not eco.offers.is_empty():
		eco.gold = 999
		eco.hire(eco.offers[0])
	await frames(10)
	var merc := uid_of("lumberjack")
	if merc != -1:
		game.resolver.commit(merc, sp(game.world.harvest_trees[0]["pos"] + Vector3(0, 1.6, 0)))
	await wait(18.0)  # 벌목 15초(타이머도 배속을 따름) → 목재 소리
	game.world.deplete_tree(game.world.harvest_trees[1])  # 나무 쓰러짐
	game.session.prep_elapsed = 30.0  # 낮 단계가 밤으로 넘어가지 않게 시계를 되돌린다

	# ── 상점·창·정지·알림
	eco.gold = 3000
	game.cards.add("timber", 40)
	await frames(5)
	game.cards.add("timber", 5)  # 같은 자원 더미 +N
	await wait(1.0)
	game.hud.open_lodge_panel()
	await frames(3)
	for k in ["extension", "pasture", "graves", "sheep", "repair", "heal"]:
		if k == "repair": lodge.take_damage(120.0)
		if k == "heal": game.player.take_damage(10.0)
		eco.buy(k)
		await frames(6)
	game.hud.close_lodge_panel()
	paused = false
	game.hud._toggle_pause(); await frames(3); game.hud._toggle_pause(); await frames(3)
	game.hud.set_map_visible(true); await frames(3); game.hud.set_map_visible(false)
	# 버튼: 클릭·오버·불가(달빛 버튼과 기본 버튼 공통 훅)
	var btn: Control = game.hud.moon.storage_btn
	btn.mouse_entered.emit()
	await wait(0.15)
	btn.pressed.emit()  # 창고 열림 → 창 열기
	await wait(0.15)
	hand.close_storage()
	btn.disabled = true
	var press := InputEventMouseButton.new(); press.button_index = MOUSE_BUTTON_LEFT; press.pressed = true
	btn.gui_input.emit(press)
	btn.disabled = false
	# 카드 오버: 손패 첫 카드에 강제로 올림
	hand._compute_rest()
	if not game.cards.hand().is_empty():
		hand._forced_hover = game.cards.hand()[0]["uid"]
		hand._update_hover(0.016)
		hand._forced_hover = -1
	# 판매 수량 조절
	game.cards.add("wool", 3); await frames(5)
	hand.open_sale(uid_of("wool")); await frames(3); hand._set_qty(1); await frames(2); hand.close_sale()
	paused = false
	# 알림: 다른 소리가 잦아든 뒤
	for i in 120:
		if bank.quiet_for(300): break
		await wait(0.1)
	game.hud.toast("검증: 좋은 소식", Color(0.8, 1.0, 0.8))
	for i in 20:
		if bank.quiet_for(300): break
		await wait(0.1)
	game.hud.toast("검증: 나쁜 소식", Color(1.0, 0.5, 0.5))
	# 새끼양 카드
	game.cards.add("lamb"); await frames(5)
	var center: Vector3 = Vector3(game.world.pasture.rect.get_center().x, 0, game.world.pasture.rect.get_center().y)
	if uid_of("lamb") != -1: game.resolver.commit(uid_of("lamb"), sp(center))
	# 양털 깎기: 털 난 양 하나를 만들어 깎는다
	var sheep = null
	for s in game.world.pasture.slots:
		if is_instance_valid(s) and not s.dead and not s.is_lamb: sheep = s; break
	if sheep != null:
		sheep.wool_ready = true
		teleport(sheep.global_position + Vector3(0.6, 0, 0))
		game.player.harvest(sheep)
		await wait(8.0)  # 타이머도 배속(4)을 따른다: 걸어가서 2.2초 깎기
		sheep.take_damage(1.0)
	# 걷기(발소리)·이동 표시
	teleport(home)
	game.player.set_destination(home + Vector3(4, 0, 0))
	game.world.show_click_marker(home + Vector3(4, 0, 0))
	await wait(1.5)
	# 손님 이야기: 입장한 손님 중 대화 가능한 사람
	await wait(1.0)
	for entry in game.guest_events.visits:
		if game.guest_events.can_talk(entry.uid):
			game.guest_ui.open_conversation(entry.uid)
			await frames(5)
			game.guest_ui.advance_dialogue()
			await frames(5)
			game.guest_ui.close_conversation(false)
			break
	paused = false
	# 위험 지역(맹독 균열지)과 모닥불 근처
	var site: Vector2 = Sites.SITES[0]["center"]
	teleport(Vector3(site.x, 0, site.y))
	await wait(3.0)
	for ins in get_nodes_in_group("hazard_insects"):
		if is_instance_valid(ins) and not ins.dead:
			ins.take_damage(1.0)
			break
	teleport(CAMP + Vector3(1.5, 0, 0))
	await wait(1.5)
	teleport(home)
	await wait(0.5)

	# ── 밤: 웨이브
	game.session.prep_elapsed = 90.0 - 10.5
	await wait(1.0)
	if game.session.state == 0: game.session.start_wave()
	await wait(4.0)
	var ground := sp(Vector3(-3.0, 0, 6.0))
	for id in ["ward_lantern", "frost_rune", "forest_monster", "warrior"]:
		game.cards.add(id, 1, "검증용병" if id == "warrior" else "")
	await frames(5)
	game.resolver.commit(uid_of("ward_lantern"), ground)
	game.resolver.commit(uid_of("forest_monster"), sp(Vector3(-1.5, 0, 7.0)))
	game.resolver.commit(uid_of("warrior"), sp(Vector3(1.0, 0, 7.5)))
	eco.gold = 3000
	eco.buy("dragon")
	await wait(3.0)
	# 방어 배치한 용병 옆으로 적 하나를 데려와 아군 공격을 확인
	for a in game.contracts.allies:
		if a.kind == "merc" and not a.dead and not enemies().is_empty():
			enemies()[-1].global_position = a.global_position + Vector3(0.8, 0, 0)
			break
	await wait(3.0)
	# 마녀가 적을 쏘고, 적은 서리로 느려지고, 양을 위협한다
	var es := enemies()
	if not es.is_empty():
		var e0 = es[0]
		teleport(e0.global_position + Vector3(2.0, 0, 0))
		game.player._fire(e0)
		e0.apply_slow("frost", 0.5, 2.0)
		game.resolver.commit(uid_of("frost_rune"), sp(e0.global_position))
		if sheep != null and is_instance_valid(sheep) and not sheep.dead:
			e0.global_position = sheep.global_position + Vector3(1.0, 0, 0)
	await wait(4.0)
	combat_mix_max = maxf(combat_mix_max, bank.combat_mix)
	# 아군 피격·사망 → 무덤
	for a in game.contracts.allies.duplicate():
		if a.kind == "merc" and not a.dead:
			a.take_damage(5.0)
			await wait(0.2)
			a.take_damage(9999.0)
			break
	# 표식 괴물부터 처치, 날아가는 중 대상이 사라지는 마법탄
	for e in enemies():
		if e.get("card_drop") != "":
			e.take_damage(9999.0)
	es = enemies()
	if not es.is_empty():
		game.player._fire(es[0])
		es[0].take_damage(9999.0)
	for i in 80:
		combat_mix_max = maxf(combat_mix_max, bank.combat_mix)
		for e in enemies(): e.take_damage(999.0)
		await wait(0.5)
		if game.session.state != 1: break
	await wait(8.0)  # 정리 → 새벽

	# ── 끝: 마녀 쓰러짐(패배) → 승리 경로
	game.player.take_damage(99999.0)
	await wait(0.3)
	game.session.state = 0
	game.session.wave_index = 99
	game.session._after_clear()
	await wait(0.3)
	paused = false
	lodge.dead = false
	lodge.take_damage(99999.0)  # 산장 붕괴 소리(이미 끝난 판이라 패배 처리는 무시됨)
	await wait(0.3)
	var fired: Dictionary = {}
	for e in bank.history: fired[e] = int(fired.get(e, 0)) + 1
	var hit: Array = expected.filter(func(e): return fired.has(e))
	var miss: Array = expected.filter(func(e): return not fired.has(e))
	print("FIRED %d/%d  combat_bgm_mix_max=%.2f" % [hit.size(), expected.size(), combat_mix_max])
	print("NOT_FIRED ", miss)
	print("COUNTS ", fired)
	var f := FileAccess.open("res://../output/audio-game-sfx-v01/game-verification.json", FileAccess.WRITE)
	f.store_string(JSON.stringify({"streams_missing": missing_streams, "fired": hit, "not_fired": miss, "combat_bgm_mix_max": combat_mix_max, "counts": fired}, "\t"))
	f.close()
	quit(0)
