extends SceneTree
## 니벨라 보스 BGM 검증: 둥지에 들어서 등장 연출(알아챔)이 시작되면 기존 곡에서 보스 곡(bgm_boss)으로 빠르게(1.2초) 넘어가고,
## 끊김 없는 반복으로 돌며, 둥지를 나가거나 보스를 쓰러뜨리면 원래 곡으로 돌아가는지 본다.
## 실행: godot --headless --path . --script res://tools/verify_boss_bgm.gd
var game
var bank
var room
var passed := 0
var total := 0

func _initialize() -> void:
	call_deferred("run")

func frames(n: int) -> void:
	for i in n: await physics_frame

func seconds(s: float) -> void:
	await create_timer(s).timeout

func check(name: String, ok: bool, detail := "") -> void:
	total += 1
	if ok: passed += 1
	print("%s %s %s" % ["PASS" if ok else "FAIL", name, detail])

func vol(event: String) -> float:
	# 덱의 두 플레이어 중 큰 쪽 음량(dB), 덱이 없으면 -99
	if not bank._decks.has(event): return -99.0
	var d: Dictionary = bank._decks[event]
	return maxf(d["a"].volume_db if d["a"].playing else -99.0, d["b"].volume_db if d["b"].playing else -99.0)

func run() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	await frames(40)
	game = current_scene
	bank = game.sounds
	room = game.world.boss_room
	paused = false
	check("bgm_boss 로드(1곡, 끊김 없는 반복 표시)", bank.streams.has("bgm_boss") and bank.streams["bgm_boss"].size() == 1 and bank.streams["bgm_boss"][0].get_meta("seamless", false))
	await seconds(1.0)
	var field_before: float = maxf(vol("bgm_field"), vol("bgm_evening"))
	check("둥지 밖: 보스 곡 안 들림", bank.boss_mix == 0.0 and not room.wants_music(), "field %.1f dB" % field_before)
	# 둥지 안쪽으로
	game.player.global_position = room.global_position + Vector3(-2.0, 0, -9.0)
	game.player.moving = false
	await frames(3)
	check("둥지에 들어섬 → 등장 연출 시작(알아챔)", room.inside and room.phase != room.Phase.DORMANT, "phase %d" % room.phase)
	check("등장 연출 중 wants_music()", room.wants_music())
	var t0 := Time.get_ticks_msec()
	var reached := -1.0
	for i in 60:
		await frames(1)
		game.player.global_position = room.global_position + Vector3(-2.0, 0, -9.0)
		if bank.boss_mix >= 0.999:
			reached = (Time.get_ticks_msec() - t0) / 1000.0
			break
	# 헤드리스 프레임 시간이 실시간보다 짧을 수 있어 game 시간 기준으로도 본다
	await seconds(1.4)
	check("보스 곡으로 빠르게 전환(1.2초 설정, 1.4초 안에 완료)", bank.boss_mix >= 0.999, "boss_mix %.2f" % bank.boss_mix)
	var d: Dictionary = bank._decks.get("bgm_boss", {})
	var cur: AudioStreamPlayer = d[d["cur"]] if not d.is_empty() else null
	check("보스 곡 재생 중", cur != null and cur.playing, "vol %.1f dB" % vol("bgm_boss"))
	var s = d.get("stream")
	check("WAV 엔진 반복(LOOP_FORWARD, 끝=길이)", s is AudioStreamWAV and s.loop_mode == AudioStreamWAV.LOOP_FORWARD and s.loop_end > 0)
	var field_in: float = maxf(vol("bgm_field"), vol("bgm_evening"))
	check("기존 곡은 거의 안 들림(-40dB 이하)", field_in < -40.0, "field %.1f dB" % field_in)
	check("보스 곡 음량 = -8dB + 파일 보정 -8.5dB 근처", absf(vol("bgm_boss") - (-16.5)) < 1.0, "%.1f dB" % vol("bgm_boss"))
	# 끝 근처에서 겹치기용 두 번째 플레이어를 켜지 않는다(이음매 반복)
	if cur != null:
		cur.seek(s.get_length() - 0.3)
		await seconds(0.8)
		var other: AudioStreamPlayer = d["b" if d["cur"] == "a" else "a"]
		check("끝→처음을 겹치지 않고 그대로 반복", not other.playing and cur.playing and cur.get_playback_position() < 1.0, "pos %.2f" % cur.get_playback_position())
	# 보스를 쓰러뜨리면 원래 곡으로
	room.combat.die()
	await frames(2)
	check("보스 쓰러짐 → wants_music() 꺼짐", not room.wants_music())
	await seconds(4.3)
	check("4초에 걸쳐 원래 곡으로 돌아감", bank.boss_mix <= 0.001 and maxf(vol("bgm_field"), maxf(vol("bgm_evening"), vol("bgm_combat"))) > -30.0, "boss_mix %.2f" % bank.boss_mix)
	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)
