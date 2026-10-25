extends SceneTree
## 로비 인물 구역 지도(assets/ui/lobby/lobby_character_ids.png) → 셰이더 가중치 3장(lobby_weights_0~2.png). docs/lobby.md
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/build_lobby_weights.gd [-- --rough]
## --rough: 구역 지도 없이 원화 위 인물 위치를 타원으로 대강 칠해 굽는다(개발용, Codex 납품 전 셰이더 확인).

const LobbyRig := preload("res://scripts/ui/lobby_rig.gd")


func _init() -> void:
	var rough := "--rough" in OS.get_cmdline_user_args()
	var ids: Image
	var ids_file := ProjectSettings.globalize_path(LobbyRig.IDS_PATH)
	var wide_file := ProjectSettings.globalize_path(LobbyRig.IDS_WIDE_PATH)
	if FileAccess.file_exists(wide_file):
		ids_file = wide_file   # 넓은 화면용 확장 지도가 있으면 그것(화면도 넓은 레이어를 쓴다)
	if not rough and FileAccess.file_exists(ids_file):
		ids = Image.load_from_file(ids_file)
	elif rough:
		ids = LobbyRig.rough_ids()
	else:
		print("FAIL 구역 지도 없음: ", LobbyRig.IDS_PATH, " (개발용은 -- --rough)")
		quit(1)
		return
	if ids.get_height() != 1080 or not ids.get_width() in [1920, 2640]:
		print("FAIL 구역 지도 크기 %s (1920×1080 또는 2640×1080)" % ids.get_size())
		quit(1)
		return
	var t0 := Time.get_ticks_msec()
	var out := LobbyRig.build_weights(ids)
	for k in out.size():
		var path := ProjectSettings.globalize_path(LobbyRig.WEIGHT_DIR + "lobby_weights_%d.png" % k)
		out[k].save_png(path)
		print("saved ", path)
	print("weights built in %d ms (%s, %d×%d)" % [Time.get_ticks_msec() - t0, "rough" if rough else "ids", ids.get_width(), ids.get_height()])
	quit(0)
