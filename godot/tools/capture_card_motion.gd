extends SceneTree
## 하스스톤식 손패 움직임 프레임 캡처(검토용). 실제 마우스 입력을 흘려 넣어
## 쓸어 만지기·확대·드래그 관성·놓기(소모)·취소·획득 공개·스택 합류·창고 이동을 연속 프레임으로 저장한다.
## 실행(프로젝트 루트): .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_card_motion.gd -- --out=<폴더>

var game
var out_dir := ""
var frame_no := 0
var every := 2
var _tick := 0
var marks: Array = []


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			out_dir = a.trim_prefix("--out=").trim_suffix("/") + "/"
	create_timer(180.0, true, false, true).timeout.connect(func(): quit(2))
	call_deferred("_run")


func shot() -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(out_dir + "f%04d.png" % frame_no)
	frame_no += 1


## n 프레임 진행하며 every 프레임마다 저장
func run_frames(n: int) -> void:
	for i in n:
		await process_frame
		_tick += 1
		if _tick % every == 0:
			await shot()


func mark(label: String) -> void:
	marks.append({"frame": frame_no, "label": label})
	print("MARK ", frame_no, " ", label)


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


func glide(from: Vector2, to: Vector2, frames: int, buttons := 0, curve := 0.0) -> void:
	for i in frames:
		var k := (i + 1) / float(frames)
		var e := k * k * (3.0 - 2.0 * k)
		var p := from.lerp(to, e) + Vector2(0, -sin(k * PI) * curve)
		move(p, buttons)
		await run_frames(1)


func _run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	for i in 40:
		await process_frame
	var hand = game.hud.card_hand
	var view: Vector2 = root.get_visible_rect().size
	game.cards.add("axe_mercenary", 1, game.economy._pick_name())
	game.cards.add("wool", 2)
	game.cards.add("timber", 10)
	game.cards.add("forest_monster")
	game.cards.add("axe_mercenary", 1, game.economy._pick_name())
	for c in game.hud.toast_box.get_children():
		c.queue_free()
	mark("reveal-5-cards")
	await run_frames(70)

	# 쓸어 만지기: 손패 위를 왼쪽 → 오른쪽 → 왼쪽
	var hy: float = view.y - 70.0
	mark("sweep")
	await glide(Vector2(view.x * 0.5 - 330, view.y - 20), Vector2(view.x * 0.5 - 260, hy), 8)
	await glide(Vector2(view.x * 0.5 - 260, hy), Vector2(view.x * 0.5 + 260, hy), 40)
	await glide(Vector2(view.x * 0.5 + 260, hy), Vector2(view.x * 0.5 - 120, hy), 30)
	await run_frames(16)

	# 드래그: 용병 카드를 나무로(빠르게 좌우로 흔들며 관성 확인) → 놓기(소모)
	var merc_uid: int = game.cards.hand()[0]["uid"]
	hand._compute_rest()
	var start: Vector2 = hand.rest[merc_uid]["pos"] - Vector2(0, hand.CH * 0.5)
	await glide(_last(), start, 6)
	await run_frames(6)
	mark("drag-merc")
	button(start, MOUSE_BUTTON_LEFT, true)
	await run_frames(2)
	var tree: Vector2 = game.world.camera.unproject_position(game.world.harvest_trees[0]["pos"] + Vector3(0, 1.6, 0))
	var mid := Vector2(view.x * 0.5 + 200, view.y * 0.45)
	await glide(start, mid, 18, MOUSE_BUTTON_MASK_LEFT, 60.0)
	await glide(mid, mid + Vector2(-260, 30), 9, MOUSE_BUTTON_MASK_LEFT)
	await glide(mid + Vector2(-260, 30), mid + Vector2(120, -20), 9, MOUSE_BUTTON_MASK_LEFT)
	await glide(mid + Vector2(120, -20), tree, 20, MOUSE_BUTTON_MASK_LEFT, 40.0)
	await run_frames(10)
	mark("drop-merc")
	button(tree, MOUSE_BUTTON_LEFT, false)
	await run_frames(40)

	# 드래그 후 취소(우클릭): 손패로 날아 돌아감
	var mon_uid := -1
	for e in game.cards.hand():
		if e["id"] == "forest_monster":
			mon_uid = e["uid"]
	hand._compute_rest()
	var s2: Vector2 = hand.rest[mon_uid]["pos"] - Vector2(0, hand.CH * 0.5)
	await glide(tree, s2, 10)
	await run_frames(6)
	mark("drag-cancel")
	button(s2, MOUSE_BUTTON_LEFT, true)
	await run_frames(2)
	await glide(s2, Vector2(view.x * 0.62, view.y * 0.38), 20, MOUSE_BUTTON_MASK_LEFT, 50.0)
	await run_frames(6)
	button(Vector2(view.x * 0.62, view.y * 0.38), MOUSE_BUTTON_RIGHT, true)
	button(Vector2(view.x * 0.62, view.y * 0.38), MOUSE_BUTTON_LEFT, false)
	await run_frames(36)

	# 목재 5개로 산장 수리(스택 일부 소모): 복제본이 타고 원본은 돌아감
	game.world.lodge.take_damage(120.0)
	var tim_uid := -1
	for e in game.cards.hand():
		if e["id"] == "timber":
			tim_uid = e["uid"]
	hand._compute_rest()
	var s3: Vector2 = hand.rest[tim_uid]["pos"] - Vector2(0, hand.CH * 0.5)
	await glide(_last(), s3, 10)
	await run_frames(4)
	mark("timber-repair")
	button(s3, MOUSE_BUTTON_LEFT, true)
	await run_frames(2)
	var lodge: Vector2 = game.world.camera.unproject_position(game.world.lodge.global_position + Vector3(0, 1.0, 0))
	await glide(s3, lodge, 24, MOUSE_BUTTON_MASK_LEFT, 80.0)
	await run_frames(6)
	button(lodge, MOUSE_BUTTON_LEFT, false)
	await run_frames(40)

	# 스택 합류: 양털 +3 (마녀에게서 날아와 배지 튐)
	move(Vector2(view.x * 0.5, view.y * 0.3))
	mark("wool-gain")
	game.cards.add("wool", 3)
	await run_frames(40)

	# 창고로 보내기 / 창고에서 꺼내기
	mark("to-storage")
	game.cards.move(game.cards.hand()[-1]["uid"], "storage")
	await run_frames(30)
	mark("from-storage")
	game.cards.move(game.cards.storage()[0]["uid"], "hand")
	await run_frames(36)

	var f := FileAccess.open(out_dir + "marks.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(marks, "\t"))
	print("CARD_MOTION frames=", frame_no)
	quit(0)


func _last() -> Vector2:
	return game.hud.card_hand._mouse
