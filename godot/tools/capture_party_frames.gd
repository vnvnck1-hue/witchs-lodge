extends SceneTree
## 용병 초상 메달(오른쪽 세로 줄) 실제 화면 캡처(docs/equipment-and-party-frames-v01.md).
## 헤드리스 더미 렌더러로는 프레임·초상 오림·체력 고리의 실제 모양과 색을 볼 수 없어 창으로 짧게 찍는다.
## 실행(창 모드): .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_party_frames.gd
## 결과: godot/screenshots/party-frames/*.png

const OUT := "res://screenshots/party-frames/"
const Layout := preload("res://scripts/world/layout.gd")
var game


func _initialize() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	_run.call_deferred()


func _wait(n: int) -> void:
	for i in n:
		await process_frame


func _shot(file: String) -> void:
	await _wait(4)
	await RenderingServer.frame_post_draw
	root.get_viewport().get_texture().get_image().save_png(OUT + file + ".png")
	print("SHOT ", file)


func _hand_uid(id: String) -> int:
	var best := -1
	for e in game.cards.entries:
		if e["id"] == id and e["zone"] == "hand":
			best = maxi(best, e["uid"])
	return best


func _equip(holder, id: String) -> void:
	game.cards.add(id, 1, "", "hand")
	game.equipment.equip(holder, _hand_uid(id))


func _center_of(pf, holder, slot: String) -> Vector2:
	for h in pf._hits:
		if h["holder"] == holder and h["slot"] == slot:
			return (h["rect"] as Rect2).get_center()
	return Vector2(-1, -1)


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
	game.player.position = Vector3(-1.5, 0, 5.0)
	game.world.player_camera.recenter()
	# 용병 넷(종족·직업 섞어서), 체력 제각각
	var base: Vector3 = Layout.DOOR_FRONT + Vector3(2.5, 0, 2.0)
	var roster := [["브람", "warrior", 1.0], ["올라프", "hunter", 0.62], ["티슬", "gatherer", 0.22], ["파르그", "warrior", 0.85], ["토르그림", "lumberjack", 1.0]]
	var allies: Array = []
	for i in roster.size():
		var r: Array = roster[i]
		var a
		if r[1] == "gatherer":
			a = game.contracts.spawn_gatherer(r[0], base + Vector3(i * 1.3, 0, 0))
		else:
			a = game.contracts.spawn_guard("merc", r[0], base + Vector3(i * 1.3, 0, 0), null, r[1])
		allies.append(a)
	await _wait(10)
	for i in allies.size():
		allies[i].set_physics_process(false)
		allies[i].hp = allies[i].max_hp * roster[i][2]
	_equip(game.player, "oak_staff")
	_equip(game.player, "quilted_gambeson")
	_equip(allies[0], "rusty_longsword")
	_equip(allies[0], "rowan_charm")
	_equip(allies[1], "traveler_boots")
	_equip(allies[3], "quilted_gambeson")
	allies[2].hp = allies[2].max_hp * 0.22
	await _wait(90)   # 장착 카드가 타 사라지는 연출이 끝날 때까지
	var pf = game.hud.party_frame
	await _shot("medallion-right")
	pf.hover_override = _center_of(pf, allies[2], "")
	await _shot("medallion-right-hover")
	pf.hover_override = Vector2(-1, -1)
	# 장비 카드를 끄는 중(메달이 드롭 대상으로 빛남)
	var hand = game.hud.card_hand
	game.cards.add("traveler_boots", 1, "", "hand")
	await _wait(20)
	var uid := _hand_uid("traveler_boots")
	hand.begin_drag(uid)
	hand.drag_pos = _center_of(pf, allies[3], "") + Vector2(-20, 0)
	await _wait(30)
	await _shot("medallion-right-drag-equip")
	# 지도 창은 왼쪽에 열림(메달 줄은 그대로)
	hand._cancel_drag()
	game.hud.set_map_visible(true)
	await _wait(20)
	await _shot("medallion-right-map-open")
	game.hud.set_map_visible(false)
	quit(0)
