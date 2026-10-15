extends SceneTree
## 산장 메뉴를 열어도 배경음이 멈추지 않고 실내처럼 줄어드는지 검증(창 모드, 실제 오디오 드라이버).
## 실행: godot --path . --script res://tools/verify_lodge_menu_bgm.gd

var main
var failures := 0


func _initialize() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	_run.call_deferred()


func check(name: String, ok: bool, detail := "") -> void:
	if not ok:
		failures += 1
	print(("  PASS " if ok else "  FAIL ") + name + ("  — " + detail if detail != "" else ""))


func _wait(n: int) -> void:
	for i in n:
		await process_frame


func _state(sb) -> String:
	var bus := AudioServer.get_bus_index("Background")
	var lp := AudioServer.get_bus_effect(bus, 0) as AudioEffectLowPassFilter
	return "bus=%.1fdB cutoff=%dHz" % [AudioServer.get_bus_volume_db(bus), int(lp.cutoff_hz)]


func _bgm(sb) -> AudioStreamPlayer:
	for key in ["bgm_field", "bgm_evening"]:
		if sb.background_players.has(key):
			return sb.background_players[key]
	return null


func _run() -> void:
	while current_scene == null or current_scene.get("session") == null:
		await process_frame
	main = current_scene
	var sb = main.sounds
	await _wait(90)
	var bgm := _bgm(sb)
	check("BGM 재생 중", bgm != null and bgm.playing and bgm.bus == "Background")
	if bgm == null:
		quit(1)
		return
	main.hud.open_lodge_panel()
	await _wait(5)
	var p0 := bgm.get_playback_position()
	await _wait(60)
	var p1 := bgm.get_playback_position()
	check("산장 메뉴 열면 게임 정지", paused and main.hud.lodge_panel.visible)
	check("메뉴 안에서도 BGM 계속 재생", bgm.playing and not bgm.stream_paused and p1 > p0 + 0.3, "위치 %.2f→%.2f" % [p0, p1])
	var bus := AudioServer.get_bus_index("Background")
	check("메뉴 안에서 소리 줄이고 고음 차단", AudioServer.get_bus_volume_db(bus) < -5.5 and (AudioServer.get_bus_effect(bus, 0) as AudioEffectLowPassFilter).cutoff_hz < 2000.0, _state(sb))
	root.get_viewport().get_texture().get_image().save_png("res://screenshots/new-cards/08-lodge-menu-bgm.png")
	main.hud.close_lodge_panel()
	await _wait(60)
	var p2 := bgm.get_playback_position()
	await _wait(30)
	check("메뉴 닫으면 원래 음량·음색으로 복귀", AudioServer.get_bus_volume_db(bus) > -0.1 and (AudioServer.get_bus_effect(bus, 0) as AudioEffectLowPassFilter).cutoff_hz > 19000.0, _state(sb))
	check("닫은 뒤에도 BGM 이어서 재생", not paused and bgm.playing and bgm.get_playback_position() > p2, "위치 %.2f→%.2f" % [p2, bgm.get_playback_position()])
	main.hud._toggle_pause()
	await _wait(30)
	var q0 := bgm.get_playback_position()
	await _wait(30)
	check("Esc 일시정지에도 BGM은 끄지 않고 음량만 낮춤", paused and bgm.get_playback_position() > q0 + 0.3 and AudioServer.get_bus_volume_db(bus) < -8.5 and (AudioServer.get_bus_effect(bus, 0) as AudioEffectLowPassFilter).cutoff_hz > 19000.0, "위치 %.2f→%.2f %s" % [q0, bgm.get_playback_position(), _state(sb)])
	main.hud._toggle_pause()
	await _wait(60)
	check("Esc 해제 후 원래 음량", not paused and AudioServer.get_bus_volume_db(bus) > -0.1, _state(sb))
	var sale: Control = main.hud.card_hand.sale_panel
	sale.visible = true
	main.hud.refresh_pause()
	await _wait(30)
	var r0 := bgm.get_playback_position()
	await _wait(30)
	check("판매 창(정지 화면)에서도 BGM 계속·음량만 낮춤", paused and bgm.get_playback_position() > r0 + 0.3 and AudioServer.get_bus_volume_db(bus) < -8.5, "위치 %.2f→%.2f %s" % [r0, bgm.get_playback_position(), _state(sb)])
	sale.visible = false
	main.hud.refresh_pause()
	await _wait(60)
	check("판매 창 닫으면 원래 음량", not paused and AudioServer.get_bus_volume_db(bus) > -0.1, _state(sb))
	print("LODGE_MENU_BGM_VERIFY passed=", failures == 0, " failures=", failures)
	quit(0 if failures == 0 else 1)
