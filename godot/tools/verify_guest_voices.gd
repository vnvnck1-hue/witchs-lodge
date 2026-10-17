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
	var bank = game.sounds
	for profile in Profiles.all_profiles():
		var e: String = "voice_" + profile.id
		var ok: bool = bank.streams.has(e) and bank.streams[e].size() == 4
		if ok:
			for s in bank.streams[e]: ok = ok and s.get_length() > 0.3 and s.get_length() <= 1.7
		check("%s has 4 short voice clips (%s)" % [e, profile.person], ok)
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
