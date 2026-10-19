extends SceneTree
## 종족·언데드·화합 카드 v1 실제 화면 캡처(docs/race-cards-v01.md).
## 헤드리스 더미 렌더러로는 소문 막대가 다른 HUD와 겹치는지, 선택 창 배치, 해골·사냥개·민병·돌 성벽·버팀목·뼈 방책 블록아웃의 모양을 볼 수 없어 창으로 짧게 찍는다.
## 실행(창 모드): .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_race_cards.gd
## 결과: godot/screenshots/race-cards/*.png

const OUT := "res://screenshots/race-cards/"
const Layout := preload("res://scripts/world/layout.gd")
const SessionScript := preload("res://scripts/game/game_session.gd")
var game


func _initialize() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	_run.call_deferred()


func _wait(n: int) -> void:
	for i in n:
		await process_frame


func _shot(file: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_viewport().get_texture().get_image().save_png(OUT + file + ".png")
	print("SHOT ", file)


func _run() -> void:
	while current_scene == null or current_scene.get("session") == null:
		await process_frame
	game = current_scene
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	root.size = Vector2i(1774, 887)
	await _wait(40)
	game.economy.set_process(false)
	game.waves.set_process(false)
	game.world.day_cycle.set_mode("day")
	var c: Vector3 = Layout.DOOR_FRONT + Vector3(3.0, 0, 4.0)
	game.player.position = c + Vector3(-2.5, 0, 1.5)
	game.world.player_camera.recenter()
	game.reputation.value = -42
	game.reputation.changed.emit(-42)
	await _wait(20)
	# 1) 블록아웃: 돌 성벽·갱도 버팀목·뼈 방책 + 해골 병사·뼈 사냥개·마을 민병
	game.race_cards._build("stone_wall", c + Vector3(-2.2, 0, -0.5))
	game.race_cards._build("mine_prop", c + Vector3(0.2, 0, -1.2))
	game.race_cards._build("bone_barricade", c + Vector3(2.4, 0, -0.5))
	for i in 2:
		game.race_cards.spawn_summon("skeleton", c + Vector3(-1.5 + i * 0.9, 0, 1.4), "undead")
	for i in 2:
		game.race_cards.spawn_summon("hound", c + Vector3(0.6 + i * 0.7, 0, 1.6), "undead")
	for i in 2:
		game.race_cards.spawn_summon("militia", c + Vector3(2.2 + i * 0.8, 0, 1.3), "militia")
	for s in game.race_cards.summons():
		s.set_physics_process(false)
	await _wait(40)
	await _shot("01-blockouts-and-rumor-bar")
	# 2) 선택 창: 언데드 보상 3장 / 대청소(여러 줄)
	game.offer_ui.open_choice("제물의 대가", "망자가 내미는 카드 세 장 — 한 장을 고르세요", [{"id": "rise_up"}, {"id": "bone_hounds"}, {"id": "soul_jar"}], func(_i): return true)
	await _wait(20)
	await _shot("02-choice-three")
	game.offer_ui.close()
	var many: Array = []
	for id in ["timber", "wool", "meat_stew", "vine_snare", "resin_torch", "frost_rune", "moss_bandage", "dark_ale", "war_drum", "stone_wall", "corpse", "soul_jar"]:
		many.append({"id": id})
	game.offer_ui.open_choice("산장 대청소", "주머니에서 영구히 없앨 카드 한 장을 고르세요", many, func(_i): return true)
	await _wait(20)
	await _shot("03-choice-many")
	game.offer_ui.close()
	# 3) 상인 마차(가격) · 소개장(종족 그림)
	game.race_cards._open_wagon()
	await _wait(20)
	await _shot("04-wagon")
	game.offer_ui.close()
	game.race_cards._open_letter()
	await _wait(20)
	await _shot("05-letter")
	game.offer_ui.close()
	quit(0)
