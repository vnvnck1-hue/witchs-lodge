extends SceneTree
## 2026-10-17 손님 인물 목소리: 대화가 열릴 때·인물 대사가 바뀔 때·도착 카드가 뜰 때
## 알림음 대신 그 인물의 voice_<id>(심즈풍 짧은 음성, 4개 번갈아)가 나는지 실제 장면으로 확인한다.
const Profiles := preload("res://scripts/ui/guest_profiles.gd")
var total := 0
var passed := 0

func _initialize() -> void:
	create_timer(90.0, true, false, true).timeout.connect(func(): print("FAIL timeout"); print("RESULT %d/%d" % [passed, total + 1]); quit(1))
	call_deferred("run")

func check(label: String, ok: bool) -> void:
	total += 1
	if ok: passed += 1
	print(("PASS " if ok else "FAIL ") + label)

func until(condition: Callable, timeout := 15.0) -> bool:
	var start := Time.get_ticks_msec()
	while not condition.call():
		await process_frame
		if Time.get_ticks_msec() - start > timeout * 1000: return false
	return true

func since(bank, mark: int) -> Array:
	return bank.history.slice(mark)

func run() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	for i in 35: await physics_frame
	var game = current_scene
	# 첫 손님이 브람이 되도록 이번 판의 주요 종족을 인간으로 고정한다(판마다 무작위, world_setting.gd).
	game.world_setting.force(["human", "dwarf"])
	var bank = game.sounds
	# 2026-10-18 종족 손님 35명 목소리(v02)까지 더해 42명 전원이 목소리 4개를 가진다.
	var voiced := 0
	for profile in Profiles.all_profiles():
		var e: String = "voice_" + profile.id
		var ok: bool = bank.streams.has(e) and bank.streams[e].size() == 4
		if ok:
			for s in bank.streams[e]: ok = ok and s.get_length() > 0.3 and s.get_length() <= 1.7
		if ok: voiced += 1
		check("%s has 4 short voice clips (%s · %s)" % [e, profile.person, profile.get("race", "human")], ok)
	check("all %d guests have a voice (%d)" % [Profiles.all_profiles().size(), voiced], voiced == Profiles.all_profiles().size())
	# 2026-10-20 술 주정뱅이 에린(특별 손님, 일반 손님 목록 밖): 사용자가 고른 목소리 8개(무작위) + 인물 id로 재생
	var erin_ok: bool = bank.streams.has("voice_erin") and bank.streams["voice_erin"].size() == 8
	if erin_ok:
		for s in bank.streams["voice_erin"]: erin_ok = erin_ok and s.get_length() > 0.3 and s.get_length() <= 1.7
	check("voice_erin has 8 short voice clips (에린 · 술 주정뱅이)", erin_ok)
	var seen := {}
	for i in 800: seen[bank._pick_variant("voice_erin", bank.streams.get("voice_erin", []))] = true
	check("에린 목소리 8개가 무작위로 고루 나옴 " + str(seen.size()), seen.size() == 8)
	# 에린 카드 사용 → 전용 "유~후~", 술주정 카드 사용 → 에린 목소리 무작위
	var tv = game.tavern
	var card_mark: int = bank.history.size()
	for id in ["drunken_erin", "drunk_rant"]:
		for n in 3: game.cards.add("timber", 1, "", "hand")
		game.cards.add(id, 1, "", "hand")
		var uid := -1
		for e in game.cards.entries:
			if e["id"] == id: uid = e["uid"]
		tv.commit(uid, {"tavern_card": id}, null)
		await create_timer(0.15).timeout
	var card_h: Array = bank.history.slice(card_mark)
	print("NOTE card sounds " + str(card_h))
	check("에린 카드 사용 → erin_card 전용음", card_h.has("erin_card") and bank.streams.has("erin_card"))
	var ec: Array = bank.streams.get("erin_card", [])
	var ec_seen := {}
	for i in 200: ec_seen[bank._pick_variant("erin_card", ec)] = true
	check("에린 카드 사용음 2개(아껴 마셔·비밀 주머니) 무작위", ec.size() == 2 and ec_seen.size() == 2)
	check("술주정 카드 사용 → voice_erin(전용음 아님)", card_h.has("voice_erin") and card_h.count("erin_card") == 1)
	check("에린 프로필로 voice() → voice_erin", bank.voice({"id": "erin"}, "talk_open") and bank.last_event == "voice_erin")
	await create_timer(0.15).timeout
	check("unknown character falls back", bank.voice({"id": "nobody"}, "talk_open") and bank.last_event == "talk_open")
	await create_timer(0.15).timeout
	check("no fallback means silence", not bank.voice({"id": "nobody"}))
	# 실제 도착 → 첫 손님(브람) 카드에서 목소리
	var intro = game.guest_arrival
	var ui = game.guest_ui
	var mark: int = bank.history.size()
	game.session.prep_elapsed = 4.8
	check("arrival card appears", await until(func(): return intro.phase == "guest"))
	check("arrival card plays first guest's voice (voice_bram)", since(bank, mark).has("voice_bram"))
	check("arrival card keeps card sound too", since(bank, mark).has("guest_card"))
	check("dialogue notification appears", await until(func(): return not intro.active and ui.notification.visible, 25.0))
	var uid: int = ui.notification_uid
	var entry: Dictionary = game.guest_events.visit(uid)
	var voice: String = "voice_" + entry.profile.character_id
	await create_timer(0.15).timeout
	mark = bank.history.size()
	ui.open_conversation(uid)
	check("conversation opens", ui.dialogue_active)
	check("opening plays %s instead of talk_open" % voice, since(bank, mark).has(voice) and not since(bank, mark).has("talk_open"))
	var cursor: int = bank.cursors.get(voice, 0)
	ui.advance_dialogue()
	await create_timer(0.15).timeout
	mark = bank.history.size()
	ui.choose(0)
	check("reply line plays character voice", since(bank, mark).has(voice))
	check("voice variants rotate", bank.cursors.get(voice, 0) == cursor + 1)
	await create_timer(0.15).timeout
	mark = bank.history.size()
	ui.advance_dialogue()
	check("closing line plays character voice", ui.dialogue_phase == "closing" and since(bank, mark).has(voice))
	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)
