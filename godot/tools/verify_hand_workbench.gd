extends SceneTree
## 손패 후면 소품(props-v05) 헤드리스 검증.
## 실행(프로젝트 루트): .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_hand_workbench.gd

const Workbench := preload("res://scripts/ui/moon/hand_workbench.gd")

var passed := 0
var total := 0
var game


func check(ok: bool, msg: String) -> void:
	total += 1
	if ok:
		passed += 1
		print("PASS ", msg)
	else:
		print("FAIL ", msg)


func _initialize() -> void:
	create_timer(60.0, true, false, true).timeout.connect(func(): print("FAIL timeout"); quit(1))
	change_scene_to_file("res://scenes/main.tscn")
	run.call_deferred()


func frames(n: int) -> void:
	for i in n:
		await process_frame


func top_pixel_x(img: Image) -> float:
	for y in img.get_height():
		for x in img.get_width():
			if img.get_pixel(x, y).a > 0.5:
				return float(x) / img.get_width()
	return -1.0


func run() -> void:
	# 1) 구운 소품 PNG
	for spec in Workbench.SPECS:
		var path: String = Workbench.PROPS_DIR + spec[0] + ".png"
		var tex: Texture2D = load(path)
		check(tex != null, "소품 텍스처 로드 " + spec[0])
		if tex == null:
			continue
		var img := tex.get_image()
		if img.is_compressed():
			img.decompress()
		var corners := [img.get_pixel(0, 0).a, img.get_pixel(img.get_width() - 1, 0).a]
		check(corners[0] < 0.05 and corners[1] < 0.05, "투명 배경 유지 " + spec[0])
	var ink := (load(Workbench.PROPS_DIR + "InkAndQuill.png") as Texture2D).get_image()
	ink.decompress()
	check(top_pixel_x(ink) < 0.35, "깃펜 끝이 시안처럼 왼쪽 위")
	var potion := (load(Workbench.PROPS_DIR + "PotionsAndHerbs.png") as Texture2D).get_image()
	potion.decompress()
	check(top_pixel_x(potion) > 0.5, "큰 약병 마개가 시안처럼 오른쪽")

	# 2) 실제 게임 장면 배치
	while current_scene == null or current_scene.get("cards") == null:
		await process_frame
	game = current_scene
	root.size = Vector2i(1600, 800)
	game.session.set_process(false)
	await frames(10)
	var decor: Control = game.hud.moon.get_node_or_null("HandWorkbench")
	check(decor != null, "HandWorkbench 노드 존재")
	if decor == null:
		finish()
		return
	check(decor.pieces.size() == Workbench.SPECS.size(), "소품 7개")
	var names := []
	for pic in decor.pieces:
		names.append(String(pic.name))
	check(names == Workbench.SPECS.map(func(s): return s[0]), "소품 순서가 SPECS와 같음")
	var ignore: bool = decor.mouse_filter == Control.MOUSE_FILTER_IGNORE and decor.source_canvas.mouse_filter == Control.MOUSE_FILTER_IGNORE
	for pic in decor.pieces:
		ignore = ignore and pic.mouse_filter == Control.MOUSE_FILTER_IGNORE
	check(ignore, "소품이 입력을 받지 않음")
	var from_v05 := true
	var fitted := true
	for i in decor.pieces.size():
		var pic: TextureRect = decor.pieces[i]
		var slot: Rect2 = Workbench.SPECS[i][1]
		from_v05 = from_v05 and pic.texture.resource_path.begins_with(Workbench.PROPS_DIR)
		var r := Rect2(pic.position, pic.size)
		var in_slot := slot.grow(0.5).encloses(r)
		var bottom := absf(r.end.y - slot.end.y) < 0.5
		var centered := absf(r.get_center().x - slot.get_center().x) < 0.5
		var touches := absf(r.size.x - slot.size.x) < 0.5 or absf(r.size.y - slot.size.y) < 0.5
		fitted = fitted and in_slot and bottom and centered and touches
	check(from_v05, "모든 소품이 생성 에셋 props-v05 사용")
	check(fitted, "소품이 시안 칸 안에 비율 유지·바닥·가운데 정렬")
	check(game.hud.card_hand.get_index() > game.hud.moon.get_index(), "카드가 소품보다 나중에 그려짐")

	# 3) 손패 수와 무관한 고정 위치
	game.grant_starter_cards(false)
	await frames(30)
	var three := rects(decor)
	for id in ["timber", "wool", "raw_meat", "rabbit_pelt", "treasure_chest"]:
		game.cards.add(id)
	await frames(30)
	check(game.cards.hand().size() == 8, "손패 8장 구성")
	check(rects(decor) == three, "3장·8장에서 소품 위치 동일")
	var view := decor.get_global_rect()
	var inside := true
	for r in three:
		inside = inside and view.encloses(r)
	check(inside, "1600×800 창에서 소품이 HUD 화면 안")
	root.size = Vector2i(3440, 1440)
	await frames(5)
	inside = true
	for r in rects(decor):
		inside = inside and decor.get_global_rect().encloses(r)
	check(inside, "3440×1440 창에서 소품이 HUD 화면 안")
	finish()


func rects(decor: Control) -> Array:
	var out := []
	for pic in decor.pieces:
		var r: Rect2 = pic.get_global_rect()
		out.append(Rect2(r.position.round(), r.size.round()))
	return out


func finish() -> void:
	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)
