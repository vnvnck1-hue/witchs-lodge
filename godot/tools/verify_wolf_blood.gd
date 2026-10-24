extends SceneTree
## 늑대의 피 이벤트·달 카드 헤드리스 검증(docs/wolf-blood-event-design.md).
##   .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_wolf_blood.gd
## 파르그의 특별 이야기(검은 양 조건·우선 발동·거절 뒤 재발동·수락 시 양 소멸+카드), 늑대의 피 사용(괴로움 → 달 카드 3장 주머니),
## 달 카드 3종(밤에만·한 밤에 한 장·1회용), 초승달/상현달 수치, 보름달 늑대(모델 교체·손패 잠김·물기·Q·E·새벽 복귀)를 실제 장면에서 돌린다.

const Cfg := preload("res://scripts/config.gd")
const Profiles := preload("res://scripts/ui/guest_profiles.gd")
const Dialogues := preload("res://scripts/game/guest_dialogues.gd")
const SessionScript := preload("res://scripts/game/game_session.gd")
const MoonLayout := preload("res://scripts/ui/moon/moon_layout.gd")

var game
var passed := 0
var total := 0


func check(ok: bool, label: String) -> void:
	total += 1
	if ok:
		passed += 1
	print(("PASS " if ok else "FAIL ") + label)


func _initialize() -> void:
	create_timer(120.0, true, false, true).timeout.connect(func(): push_error("Wolf blood verification timeout"); quit(2))
	call_deferred("run")


func frames(n := 3) -> void:
	for i in n:
		await process_frame


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


func sp(p: Vector3) -> Vector2:
	return game.world.camera.unproject_position(p)


## 마녀의 화면 위치(매번 새로 잰다 — 마녀가 걸어 다닌다)
func psp() -> Vector2:
	return sp(game.player.global_position + Vector3(0, 1.0, 0))


func uid_of(id: String, zone := "") -> int:
	for e in game.cards.entries:
		if e["id"] == id and (zone == "" or e["zone"] == zone):
			return e["uid"]
	return -1


## 파르그를 손님으로 들인다(실제 도착 묶음과 같은 경로: batch → admit → 말 걸기 준비).
func admit_fargh() -> int:
	var profile: Dictionary = Profiles.guest_profile("fargh")
	game.guest_events._on_batch([profile])
	game.guest_events.admit(profile)
	var uid: int = int(profile["visit_uid"])
	game.session.play_time += 3.0
	await until(func(): var e: Dictionary = game.guest_events.visit(uid); return e.get("ready", false) or e.get("read", false), 5.0)
	return uid


func run() -> void:
	root.size = Vector2i(1600, 872)
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	game.world_setting.force(["human", "dwarf"])
	await frames(6)
	game.world.day_cycle.set_mode("day")
	game.world.player_camera.toggle_overview()
	game.economy.set_process(false)   # 실제 손님 묶음이 끼어들지 않게
	game.session.prep_elapsed = 1.0
	var cards = game.cards
	var moon = game.moon_powers
	var player = game.player
	var pasture = game.world.pasture
	var ui = game.guest_ui
	var events = game.guest_events

	# ── 1. 카탈로그·설정
	for id in ["wolf_blood"] + Cfg.MOON_CARDS:
		check(cards.defs.has(id) and cards.def(id).get("name", "") != "", "catalog: %s registered" % id)
	check(cards.phase_of("wolf_blood") == "both" and cards.phase_of("full_moon") == "night", "config: wolf_blood both / moon cards night")
	check(moon != null and not moon.blood_given and moon.tonight == "", "moon_powers: fresh state")
	var story: Dictionary = Dialogues.wolf_story()
	check(story.get("special", "") == "wolf" and story.choices.size() == 2 and story.choices[0].get("effect", "") == "wolf_blood", "wolf story: special, two choices, accept effect")
	var wrapped_ok := true
	for text in [story.opening, story.choices[0].reply, story.choices[0].fail_reply, story.choices[1].reply, story.closing]:
		wrapped_ok = wrapped_ok and ui.presenter._wrap_dialogue(text).size() <= 3
	check(wrapped_ok, "wolf story: every line fits the dialogue panel (3 lines)")

	# ── 2. 검은 양이 없으면 평소 이야기
	check(pasture.black_sheep_count() == 0, "pasture: no black sheep at start")
	var uid0: int = await admit_fargh()
	var e0: Dictionary = events.visit(uid0)
	check(e0.get("ready", false) and e0.story.get("special", "") != "wolf" and e0.story.title == Dialogues.story("fargh").title, "fargh without black sheep: ordinary story")
	game.economy.guest_departed.emit(e0.profile, "떠남")
	await pframes(2)

	# ── 3. 검은 양이 있으면 특별 이야기(표본 추출 무시) — 거절
	check(pasture.add_black_sheep() and pasture.black_sheep_count() == 1, "pasture: black sheep added")
	events._story_candidates = 1   # 평소라면 이번 손님은 이벤트에서 빠지는 차례
	var uid1: int = await admit_fargh()
	var e1: Dictionary = events.visit(uid1)
	check(e1.get("ready", false) and e1.story.get("special", "") == "wolf", "fargh with black sheep: wolf story offered even on a skipped turn")
	ui.open_conversation(uid1)
	check(ui.dialogue_active and ui.dialogue_phase == "opening", "dialogue opens")
	_advance(ui)
	ui.choose(1)
	check(ui.dialogue_phase == "reply" and pasture.black_sheep_count() == 1 and uid_of("wolf_blood") == -1 and not moon.blood_given, "refuse: sheep kept, no card")
	_advance(ui)
	_advance(ui)
	check(not ui.dialogue_active and not events.completed_stories.has("fargh") and events.history.size() >= 1, "refuse: conversation closes, fargh's stories not consumed")
	game.economy.guest_departed.emit(e1.profile, "떠남")
	await pframes(2)

	# ── 4. 다음 방문: 다시 묻고 수락 → 검은 양 소멸 + 늑대의 피 카드
	var uid2: int = await admit_fargh()
	var e2: Dictionary = events.visit(uid2)
	check(e2.get("ready", false) and e2.story.get("special", "") == "wolf", "next visit: wolf story asked again")
	var hand_before: int = cards.hand().size()
	ui.open_conversation(uid2)
	_advance(ui)
	ui.choose(0)
	await pframes(2)
	check(pasture.black_sheep_count() == 0 and pasture.alive_count() == Cfg.SHEEP_START, "accept: one black sheep taken, white sheep untouched")
	check(uid_of("wolf_blood", "hand") != -1 and cards.hand().size() == hand_before + 1 and moon.blood_given, "accept: wolf_blood card in hand, blood_given")
	_advance(ui)
	_advance(ui)
	check(not ui.dialogue_active and not events.completed_stories.has("fargh"), "accept: closes, ordinary story still available")
	game.economy.guest_departed.emit(e2.profile, "떠남")
	await pframes(2)
	# 다시 검은 양을 들여도 늑대의 피는 한 판에 한 번
	pasture.add_black_sheep()
	var uid3: int = await admit_fargh()
	check(events.visit(uid3).story.get("special", "") != "wolf", "after the gift: fargh goes back to his ordinary story")
	game.economy.guest_departed.emit(events.visit(uid3).profile, "떠남")
	await pframes(2)

	# ── 5. 늑대의 피 사용: 마녀에게만, 괴로움 → 달 카드 3장 주머니
	var blood: int = uid_of("wolf_blood")
	var res = game.resolver
	var ground_sp := sp(player.global_position + Vector3(3.0, 0, 3.0))
	check(not res.evaluate(blood, ground_sp)["ok"], "wolf_blood: refused on the ground")
	var r: Dictionary = res.commit(blood, psp())
	check(r["ok"] and uid_of("wolf_blood") == -1 and player.suffering > 0.0 and moon.blood_used, "wolf_blood: used on the witch, witch suffers")
	player.set_destination(player.global_position + Vector3(2, 0, 0))
	await pframes(2)
	check(player.suffering > 0.0 and player.velocity.length() < 0.01, "suffering: movement ignored")
	check(not res.evaluate(uid_of("timber"), psp())["ok"] or uid_of("timber") == -1, "suffering: nothing else to break")
	var got := await until(func(): return cards.pocket_count_of("crescent_moon") == 1 and cards.pocket_count_of("half_moon") == 1 and cards.pocket_count_of("full_moon") == 1, 6.0)
	check(got, "moon cards: three in the pocket after the suffering")
	await until(func(): return player.suffering <= 0.0, 6.0)
	check(player.suffering <= 0.0 and player.body.rotation.x == 0.0, "suffering ends and the pose resets")

	# ── 6. 달 카드는 밤에만. 낮 손패에는 못 올라온다
	check(cards.draw_uid(uid_of("crescent_moon")).is_empty(), "moon cards: cannot be drawn into the day hand")
	game.session.start_wave()
	await pframes(2)
	check(game.session.state == SessionScript.State.COMBAT, "night started")
	game.waves.stop()
	for e in get_nodes_in_group("enemies"):
		e.queue_free()
	await pframes(2)
	var crescent: int = uid_of("crescent_moon")
	if cards.get_entry(crescent)["zone"] != "hand":
		cards.draw_uid(crescent)
	await pframes(1)
	check(cards.get_entry(crescent)["zone"] == "hand", "crescent moon drawn into the night hand")
	check(not res.evaluate(crescent, ground_sp)["ok"], "moon card: refused on the ground")
	var base_interval: float = player.attack_interval()
	r = res.commit(crescent, psp())
	check(r["ok"] and moon.tonight == "crescent" and uid_of("crescent_moon") == -1, "crescent: used, tonight = crescent, card gone")
	check(is_equal_approx(player.attack_interval(), base_interval * Cfg.MOON_CRESCENT_ATTACK) and is_equal_approx(player.move_speed(), Cfg.PLAYER_SPEED), "crescent: attack interval shortened, move speed unchanged")
	check(player.moon_ring.visible, "crescent: moon ring shown")
	var half: int = uid_of("half_moon")
	cards.draw_uid(half)
	await pframes(1)
	var second: Dictionary = res.evaluate(half, psp())
	check(not second["ok"] and second["reason"].contains("이미"), "second moon card the same night is refused")
	check(cards.discard.filter(func(d): return d["id"] == "crescent_moon").size() == 1, "crescent moon is one-shot (discard pile)")
	# 밤이 끝나면 효과 종료
	game.session._on_wave_cleared()
	await pframes(2)
	check(moon.tonight == "" and is_equal_approx(player.attack_interval(), Cfg.BOLT_INTERVAL) and not player.moon_ring.visible, "night over: crescent effect ends")
	game.session.clear_timer = 0.0
	await pframes(3)
	check(game.session.state == SessionScript.State.PREP, "back to day")

	# ── 7. 상현달
	game.session.start_wave()
	await pframes(2)
	game.waves.stop()
	for e in get_nodes_in_group("enemies"):
		e.queue_free()
	await pframes(2)
	half = uid_of("half_moon")
	if cards.get_entry(half)["zone"] != "hand":
		cards.draw_uid(half)
	await pframes(1)
	r = res.commit(half, psp())
	check(r["ok"] and moon.tonight == "half" and is_equal_approx(player.move_speed(), Cfg.PLAYER_SPEED * Cfg.MOON_HALF_MOVE) and is_equal_approx(player.attack_interval(), Cfg.BOLT_INTERVAL * Cfg.MOON_HALF_ATTACK), "half moon: attack and move faster")
	game.session._on_wave_cleared()
	game.session.clear_timer = 0.0
	await pframes(4)
	check(moon.tonight == "" and game.session.state == SessionScript.State.PREP, "half moon ends at dawn")

	# ── 8. 보름달 — 늑대
	game.session.start_wave()
	await pframes(2)
	game.waves.stop()
	for e in get_nodes_in_group("enemies"):
		e.queue_free()
	await pframes(2)
	var full: int = uid_of("full_moon")
	if cards.get_entry(full)["zone"] != "hand":
		cards.draw_uid(full)
	await pframes(1)
	r = res.commit(full, psp())
	check(r["ok"] and moon.tonight == "full" and player.wolf, "full moon: witch becomes a wolf")
	check(not player.body.visible and player.wolf_visual.visible and player.wolf_visual.get_node_or_null("Body") != null and player.wolf_visual.get("head") != null, "wolf: witch body hidden, wolf model shown")
	check(is_equal_approx(player.move_speed(), Cfg.PLAYER_SPEED * Cfg.WOLF_MOVE_MULT) and is_equal_approx(player.attack_range(), Cfg.WOLF_BITE_RANGE) and is_equal_approx(player.attack_interval(), Cfg.WOLF_BITE_INTERVAL), "wolf: fast, melee range, bite interval")
	check(not game.hud.card_hand.can_drag(), "wolf: hand locked")
	cards.add("timber", 1)
	await pframes(1)
	var locked: Dictionary = res.evaluate(uid_of("timber"), sp(game.world.lodge.global_position + Vector3(0, 2, 0)))
	check(not locked["ok"] and locked["reason"].contains("늑대"), "wolf: cards refused")
	check(game.hud.moon.objective().contains("늑대"), "wolf: objective line explains Q/E")
	# 스킬 바 자리(2026-10-22): 산장 관리 버튼 왼쪽, 화면 오른쪽 아래 빈자리. 늑대 두 스킬 모두 버튼과 겹치지 않는다.
	var view: Vector2 = game.hud.overlay.size
	var sb: Vector2 = game.hud.overlay.skill_bar_center(view)
	var lodge_rect: Rect2 = game.hud.moon.lodge_btn.get_global_rect()
	var ui_k: float = MoonLayout.ui_scale(view)
	var sb_right: float = sb.x + (0.5 * game.hud.overlay.SKILL_GAP + 31.0) * ui_k
	check(sb_right < lodge_rect.position.x and sb.x > view.x * 0.5, "skill bar: right-bottom, left of lodge button (x=%.0f lodge=%.0f)" % [sb.x, lodge_rect.position.x])
	check(sb.y > view.y * 0.75 and sb.y + 31.0 * ui_k < view.y, "skill bar: near the bottom edge, inside the screen (y=%.0f/%.0f)" % [sb.y, view.y])
	# 물기: 적 하나를 가까이 두고 우클릭 공격
	var near_pos: Vector3 = player.global_position + Vector3(1.0, 0, 0)
	game.waves.spawn_extra(near_pos, "forest")
	await pframes(2)
	var foe = get_nodes_in_group("enemies")[0]
	foe.global_position = near_pos
	foe.set_physics_process(false)
	var hp0: float = foe.hp
	player.command_attack(foe)
	var bit := await until(func(): return player.bites >= 1, 4.0)
	check(bit and foe.hp <= hp0 - Cfg.WOLF_BITE_DAMAGE + 0.01, "wolf bite: melee damage %d" % int(Cfg.WOLF_BITE_DAMAGE))
	player.command_stop()
	# Q 할퀴기: 적 방향 부채꼴, 4번
	foe.hp = 400.0
	hp0 = foe.hp
	var far_pos: Vector3 = player.global_position + Vector3(0, 0, 5.0)
	game.waves.spawn_extra(far_pos, "forest")
	await pframes(2)
	var far = get_nodes_in_group("enemies")[1]
	far.global_position = far_pos
	far.set_physics_process(false)
	far.hp = 400.0
	check(player.cast_claw(foe.global_position) and player.claw_t > 0.0 and player.claw_cd > 0.0, "Q: claw starts with cooldown")
	check(not player.cast_claw(foe.global_position), "Q: refused during cooldown")
	await seconds(Cfg.WOLF_CLAW_TIME + 0.3)
	check(player.claw_hits == Cfg.WOLF_CLAW_HITS and is_equal_approx(foe.hp, hp0 - Cfg.WOLF_CLAW_DAMAGE * Cfg.WOLF_CLAW_HITS), "Q: four claw hits on the enemy in the fan (%d each)" % int(Cfg.WOLF_CLAW_DAMAGE))
	check(is_equal_approx(far.hp, 400.0), "Q: enemy outside the fan radius untouched")
	# E 덮치기: 떨어진 적에게 뛰어들어 물어뜯는다
	player.claw_cd = 0.0
	hp0 = far.hp
	var from: Vector3 = player.global_position
	check(player.cast_pounce(far) and player.pounce_t > 0.0, "E: pounce starts")
	await seconds(Cfg.WOLF_POUNCE_TIME + 0.2)
	check(player.pounce_t <= 0.0 and player.global_position.distance_to(far.global_position) < 1.6 and player.global_position.distance_to(from) > 2.0, "E: wolf leapt next to the target")
	check(far.hp <= hp0 - Cfg.WOLF_POUNCE_DAMAGE + 0.01 and far.slow_factor() < 1.0, "E: bite damage %d and slow (extra bites may follow)" % int(Cfg.WOLF_POUNCE_DAMAGE))
	check(player.target_enemy == far and player.attack_forced, "E: keeps biting the pounced enemy")
	check(player.pounce_cd > 0.0 and not player.cast_pounce(far), "E: cooldown")
	# 새벽: 마녀로 복귀, 손패 풀림
	for e in get_nodes_in_group("enemies"):
		e.queue_free()
	await pframes(2)
	game.session._on_wave_cleared()
	game.session.clear_timer = 0.0
	await pframes(4)
	check(not player.wolf and player.body.visible and not player.wolf_visual.visible and moon.tonight == "", "dawn: wolf turns back into the witch")
	check(not game.hud.card_hand.wolf_locked() and game.session.state == SessionScript.State.PREP, "dawn: hand unlocked")
	check(cards.count_of("full_moon") == 0 and cards.count_of("half_moon") == 0 and cards.count_of("crescent_moon") == 0, "all three moon cards are gone (one-shot)")
	check(moon.stats["moons_used"] == 3 and moon.stats["wolf_nights"] == 1, "stats: 3 moons used, 1 wolf night")

	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)


## 대사를 펜으로 적는 중이면 먼저 마저 적고 넘긴다(실제 조작과 같다, docs/dialogue-handwriting.md).
func _advance(ui) -> void:
	if ui.presenter.is_writing(): ui.presenter.finish_writing()
	ui.advance_dialogue()
