extends SceneTree
## 전설 카드 셰이더(금테 숨쉬기·별빛·회전 광택) 렌더 캡처. 빛·반짝임 외형은 헤드리스 더미 렌더러로 볼 수 없어 창을 띄운다.
## 실행(프로젝트 루트): .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_legendary_card.gd
## 결과: res://screenshots/legendary/frames/f###.png — 0~1.5초 가만히, 1.5~4.5초 좌우로 흔들림, 4.5~6초 다시 정지.

const Catalog := preload("res://scripts/ui/card_catalog.gd")
const CardView := preload("res://scripts/ui/card_view.gd")
const OUT := "res://screenshots/legendary/frames/"
const FPS := 20.0
const DURATION := 6.0

var v
var plain
var t := 0.0
var n := 0


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	DisplayServer.window_set_size(Vector2i(760, 620))
	root.size = Vector2i(760, 620)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	var bg := ColorRect.new()
	bg.color = Color(0.11, 0.08, 0.16)
	bg.size = Vector2(760, 620)
	root.add_child(bg)
	v = _card("drunken_erin", Vector2(555, 570))
	plain = _card("timber", Vector2(195, 570))
	call_deferred("_run")


func _card(id: String, at: Vector2):
	var c = CardView.new()
	root.add_child(c)
	c.setup(id, Catalog.texture(id))
	c.resize(Vector2(300, 450))
	c.pos = at
	c.t_pos = at
	return c


func _run() -> void:
	# 카드 앞면 글자를 굽는 동안 기다린다
	for i in 20:
		await process_frame
	while t < DURATION:
		var dt := 1.0 / FPS
		var target := 0.0
		if t > 1.5 and t < 4.5:
			target = sin((t - 1.5) * 4.2) * 16.0
		v.t_rot = target
		plain.t_rot = target
		for s in 3:
			v.step(dt / 3.0)
			plain.step(dt / 3.0)
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + "f%03d.png" % n))
		n += 1
		t += dt
		await create_timer(dt).timeout
	print("DONE %d frames" % n)
	quit(0)
