extends SceneTree
## 일시 정지 → 소리 설정: 버스 구성(Music·Sfx), 슬라이더·음소거가 버스 음량에 반영되는지, 저장·불러오기를 검증한다.
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_sound_settings.gd
## 사용자의 실제 user://settings.cfg 는 건드리지 않도록 검증 전용 파일로 경로를 바꿔 쓴다.

const TEST_PATH := "user://verify_sound_settings.cfg"
const SoundBankScript := preload("res://scripts/audio/sound_bank.gd")
var failures := 0
var total := 0


func _initialize() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	_run.call_deferred()


func check(name: String, ok: bool, detail := "") -> void:
	total += 1
	if not ok:
		failures += 1
	print(("PASS " if ok else "FAIL ") + name + ("  — " + detail if detail != "" else ""))


func _db(bus: String) -> float:
	return AudioServer.get_bus_volume_db(AudioServer.get_bus_index(bus))


func _muted(bus: String) -> bool:
	return AudioServer.is_bus_mute(AudioServer.get_bus_index(bus))


func _run() -> void:
	while current_scene == null or current_scene.get("session") == null or current_scene.get("hud") == null:
		await process_frame
	for i in 5:
		await process_frame
	var main = current_scene
	var sb = main.sounds
	var hud = main.hud
	var before: Dictionary = sb.volumes.duplicate()
	var before_muted: bool = sb.muted
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PATH))
	sb.settings_path = TEST_PATH

	# 버스 구성
	for bus in ["Music", "Sfx", "Background"]:
		check("버스 " + bus + " 있음", AudioServer.get_bus_index(bus) != -1)
	check("Background → Music 으로 보냄", AudioServer.get_bus_send(AudioServer.get_bus_index("Background")) == "Music")
	check("Music → Master", AudioServer.get_bus_send(AudioServer.get_bus_index("Music")) == "Master")
	check("Sfx → Master", AudioServer.get_bus_send(AudioServer.get_bus_index("Sfx")) == "Master")

	# UI 구성
	check("소리 설정 버튼", hud.sound_btn != null and hud.sound_btn.text.begins_with("소리 설정"))
	check("소리 설정 구역은 처음엔 접힘", hud.pause_sound != null and not hud.pause_sound.visible)
	check("슬라이더 3개(전체·배경음·효과음)", hud.volume_sliders.size() == 3 and hud.volume_sliders.has("master") and hud.volume_sliders.has("music") and hud.volume_sliders.has("sfx"))
	check("음소거 토글", hud.mute_toggle != null)
	hud.sound_btn.pressed.emit()
	check("버튼으로 구역 펼침", hud.pause_sound.visible and hud.sound_btn.text.ends_with("▴"))
	hud.sound_btn.pressed.emit()

	# 슬라이더 → 버스
	hud.volume_sliders["sfx"].value = 50.0
	check("효과음 50% → Sfx 버스 약 -6dB", absf(_db("Sfx") - linear_to_db(0.5)) < 0.05, "%.2fdB" % _db("Sfx"))
	check("퍼센트 표시 갱신", hud.volume_values["sfx"].text == "50%", hud.volume_values["sfx"].text)
	hud.volume_sliders["music"].value = 0.0
	check("배경음 0% → Music 버스 꺼짐", _muted("Music"))
	hud.volume_sliders["master"].value = 80.0
	check("전체 80% → Master 버스", absf(_db("Master") - linear_to_db(0.8)) < 0.05 and not _muted("Master"), "%.2fdB" % _db("Master"))
	hud.mute_toggle.button_pressed = true
	check("음소거 → Master 꺼짐", _muted("Master") and sb.muted)

	# 저장
	var cfg := ConfigFile.new()
	check("설정 파일 저장됨", cfg.load(TEST_PATH) == OK)
	check("저장값 일치", is_equal_approx(float(cfg.get_value("audio", "sfx", -1.0)), 0.5) and is_equal_approx(float(cfg.get_value("audio", "music", -1.0)), 0.0) and is_equal_approx(float(cfg.get_value("audio", "master", -1.0)), 0.8) and bool(cfg.get_value("audio", "muted", false)))

	# 효과음은 Sfx 버스로
	var played := false
	for ev in ["btn_click", "card_play", "gold_reward"]:
		if sb.play(ev):
			played = true
			break
	if played:
		var last: Node = sb.get_child(sb.get_child_count() - 1)
		check("효과음 플레이어는 Sfx 버스", last is AudioStreamPlayer and last.bus == "Sfx", str(last.get("bus")))
	else:
		check("효과음 재생 가능(선택된 소리 있음)", false)
	var bg_ok := true
	for key in sb.background_players:
		if sb.background_players[key].bus != "Background": bg_ok = false
	check("배경 플레이어는 Background 버스 유지", bg_ok)

	# 불러오기: 새 SoundBank 가 같은 파일을 읽는다
	hud.mute_toggle.button_pressed = false
	var fresh = SoundBankScript.new()
	fresh.settings_path = TEST_PATH
	fresh.load_settings()
	check("다시 불러오면 값 복원", is_equal_approx(fresh.volumes["sfx"], 0.5) and is_equal_approx(fresh.volumes["master"], 0.8) and not fresh.muted)
	fresh.free()

	# 원상 복구(실제 설정 파일은 손대지 않음)
	for kind in before:
		sb.set_volume(kind, before[kind], false)
	sb.set_muted(before_muted, false)
	sb.settings_path = SoundBankScript.SETTINGS_PATH
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PATH))

	print("RESULT %d/%d" % [total - failures, total])
	quit(1 if failures > 0 else 0)
