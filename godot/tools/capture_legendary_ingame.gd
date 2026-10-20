extends SceneTree
## 전설 카드(에린) 실제 게임 장면 캡처. 실제 main.tscn 을 띄우고 실제 마우스 입력을 흘려 넣어
## 손패에 놓임 → 마우스 올림(확대) → 드래그하며 좌우로 흔들기(실제 회전·빛 반응) → 우클릭 취소 → 주머니 목록 확대를 찍는다.
## 빛·반짝임·회전 외형은 헤드리스 더미 렌더러로 볼 수 없어 창을 띄운다.
## 실행(프로젝트 루트): .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_legendary_ingame.gd
## 결과: res://screenshots/legendary/ingame/<장면>.png 와 drag/f###.png, 숫자 기록 ingame.json

const OUT := "res://screenshots/legendary/ingame/"

var game
var hand
var log := {}
var n := 0


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT + "drag"))
	create_timer(180.0, true, false, true).timeout.connect(func(): quit(2))
	call_deferred("_run")


func shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + name + ".png"))


func frames(k: int) -> void:
	for i in k:
		await process_frame


func move(p: Vector2, buttons := 0) -> void:
	var m := InputEventMouseMotion.new()
	m.position = p
	m.global_position = p
	m.button_mask = buttons
	root.push_input(m, true)


func button(p: Vector2, idx: int, pressed: bool) -> void:
	var b := InputEventMouseButton.new()
	b.position = p
	b.global_position = p
	b.button_index = idx
	b.pressed = pressed
	root.push_input(b, true)


func glide(from: Vector2, to: Vector2, k: int, buttons := 0, record := false) -> void:
	for i in k:
		var e := (i + 1) / float(k)
		e = e * e * (3.0 - 2.0 * e)
		move(from.lerp(to, e), buttons)
		await process_frame
		if record:
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + "drag/f%03d.png" % n))
			var v = hand.views.get(_erin_uid())
			if v != null:
				log["drag_%03d" % n] = {"rot": snappedf(v.rot, 0.01), "motion": snappedf(v.legend_motion, 0.001)}
			n += 1


func _erin_uid() -> int:
	for e in game.cards.entries:
		if e["id"] == "drunken_erin":
			return e["uid"]
	return -1


func _run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await frames(40)
	hand = game.hud.card_hand
	var view: Vector2 = root.get_visible_rect().size
	game.cards.add("timber", 3)
	game.cards.add("drunken_erin")
	game.cards.add("wool", 2)
	for c in game.hud.toast_box.get_children():
		c.queue_free()
	await frames(90)
	var uid := _erin_uid()
	var v = hand.views[uid]
	log["view_legendary"] = v.legendary
	log["pivot_is_center"] = v.pivot_offset.is_equal_approx(v.size * 0.5)
	log["pivot"] = str(v.pivot_offset)
	log["size"] = str(v.size)
	await shot("1_hand_rest")
	# 마우스 올림(확대)
	hand._compute_rest()
	var at: Vector2 = hand.rest[uid]["pos"] - Vector2(0, hand.CH * 0.5)
	await glide(Vector2(view.x * 0.5, view.y - 10), at, 10)
	await frames(30)
	await shot("2_hover")
	log["hover_rot"] = v.rot
	# 드래그하며 좌우로 흔들기
	button(at, MOUSE_BUTTON_LEFT, true)
	await frames(3)
	var mid := Vector2(view.x * 0.5, view.y * 0.42)
	await glide(at, mid, 14, MOUSE_BUTTON_MASK_LEFT, true)
	for i in 3:
		await glide(mid, mid + Vector2(-240, 20), 7, MOUSE_BUTTON_MASK_LEFT, true)
		await glide(mid + Vector2(-240, 20), mid + Vector2(240, -20), 12, MOUSE_BUTTON_MASK_LEFT, true)
		await glide(mid + Vector2(240, -20), mid, 7, MOUSE_BUTTON_MASK_LEFT, true)
	var peak_rot := 0.0
	var peak_motion := 0.0
	for k in log:
		if String(k).begins_with("drag_"):
			peak_rot = maxf(peak_rot, absf(log[k]["rot"]))
			peak_motion = maxf(peak_motion, log[k]["motion"])
	log["drag_peak_rot_deg"] = peak_rot
	log["drag_peak_motion"] = peak_motion
	log["drag_shader_tilt"] = v.mat.get_shader_parameter("tilt")
	await shot("3_drag_swing")
	# 멈춘 채 들고 있기 → 빛이 가라앉음
	await frames(120)
	log["drag_still_motion"] = v.legend_motion
	await shot("4_drag_still")
	# 우클릭 취소 → 손패로 돌아감
	button(mid, MOUSE_BUTTON_RIGHT, true)
	button(mid, MOUSE_BUTTON_LEFT, false)
	await frames(60)
	# 주머니 목록: 에린을 주머니로 보내고 목록을 열어 확대
	game.cards.stash_uid(uid)
	await frames(10)
	hand.open_pocket()
	await frames(30)
	var g = hand.pocket_gallery
	for i in g.tiles.size():
		if g.tiles[i]["entry"]["id"] == "drunken_erin":
			g.hover_index(i)   # 마우스가 움직이기 전까지 확대 유지(캡처·검증용)
			break
	await frames(40)
	log["pocket_lifted_legendary"] = g.lifted.legendary
	await shot("5_pocket_lifted")
	var f := FileAccess.open(ProjectSettings.globalize_path(OUT + "ingame.json"), FileAccess.WRITE)
	f.store_string(JSON.stringify(log, "\t"))
	print("LOG ", JSON.stringify({"legendary": log.get("view_legendary"), "center": log.get("pivot_is_center"),
		"peak_rot": log.get("drag_peak_rot_deg"), "peak_motion": log.get("drag_peak_motion"), "still": log.get("drag_still_motion"),
		"tilt": log.get("drag_shader_tilt"), "pocket": log.get("pocket_lifted_legendary"), "pivot": log.get("pivot"), "size": log.get("size")}))
	print("DONE")
	quit(0)
