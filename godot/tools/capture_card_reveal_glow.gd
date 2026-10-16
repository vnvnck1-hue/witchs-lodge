extends SceneTree
## 카드 공개 글로우(card_reveal_glow) 렌더 캡처(검토용). 헤드리스로는 셰이더 컴파일·블렌딩·색을 볼 수 없어 실제 창에서 저장한다.
## (A) 화면 가운데 공개 크기의 카드 복제본 위에 글로우를 터뜨려 3프레임마다 저장
## (B) 아침 드로우(주머니 → 가운데 공개 → 손패)를 3프레임마다 저장
## 실행(프로젝트 루트): .tools/Godot-4.7.2.exe --fixed-fps 60 --position -6000,-6000 --path godot --script res://tools/capture_card_reveal_glow.gd -- --out=<폴더>/

const Cfg := preload("res://scripts/config.gd")

var game
var out_dir := ""
var frame_no := 0


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			out_dir = a.trim_prefix("--out=").trim_suffix("/") + "/"
	create_timer(120.0, true, false, true).timeout.connect(func(): quit(2))
	change_scene_to_file("res://scenes/main.tscn")
	call_deferred("_run")


func shot(label: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(out_dir + "%s-%02d.png" % [label, frame_no])
	frame_no += 1


func run_frames(label: String, n: int, every := 3) -> void:
	for i in n:
		await process_frame
		if i % every == 0:
			await shot(label)


func _run() -> void:
	while current_scene == null or current_scene.get("cards") == null:
		await process_frame
	game = current_scene
	await _wait(20)
	var hand = game.hud.card_hand
	var fx = hand.fx
	# (A) 단독 글로우: 공개 크기 카드 복제본 + 글로우
	var scl: float = hand.REVEAL_SCALE
	var card_size: Vector2 = Vector2(hand.CW, hand.CH) * scl
	var center: Vector2 = hand.size * 0.5
	var ids: Array = [Cfg.STARTER_CARDS[0][0]]
	var tex: Texture2D = hand._surface(ids[0]) if ids.size() > 0 else null
	if tex != null:
		var g = fx._ghost(tex, Vector2(hand.CW, hand.CH))
		g.snap(center + Vector2(0, card_size.y * 0.5), 0.0, scl)
	await _wait(2)
	await shot("solo-before")
	fx.card_glow(center, card_size, 0.0)
	fx.burst(center, hand._s(), 34)
	await run_frames("solo", 54, 3)
	# (B) 아침 드로우 실제 흐름
	game.grant_starter_cards(false)
	await _wait(30)
	game.session.wave_index = 1
	game.session._enter_prep()
	await run_frames("draw", 90, 3)
	print("REVEAL_GLOW_CAPTURE done frames=", frame_no)
	quit(0)


func _wait(n: int) -> void:
	for i in n:
		await process_frame
