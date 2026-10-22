extends SceneTree
## 대사 필기 셰이더 실제 화면 캡처(셰이더 컴파일·글자 드러남·젖은 잉크 색은 헤드리스 더미 렌더러로 볼 수 없다).
##   .tools/Godot-4.7.2.exe --path godot --resolution 1600x872 --script res://tools/capture_dialogue_handwriting.gd
## 결과: godot/screenshots/dialogue-handwriting/
const Presenter := preload("res://scripts/ui/guest_arrival.gd")
const LINE := "어서 오게, 마녀 양반. 눈길이 깊어 한참을 헤맸다네! 따뜻한 수프 한 그릇이면 밤새 장작을 패 주겠네."

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var out := ProjectSettings.globalize_path("res://screenshots/dialogue-handwriting/")
	DirAccess.make_dir_recursive_absolute(out)
	var back := ColorRect.new()
	back.color = Color8(40, 34, 52)
	back.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(back)
	var p: CanvasLayer = Presenter.new()
	p.presentation_only = true
	root.add_child(p)
	await process_frame
	p.set_process(false)
	p.show_profile({"person": "브람", "role": "나무꾼", "detail": "눈길을 헤치고 온 나무꾼", "portrait": "res://icon.png"}, LINE, "산장의 이야기")
	var total: float = p.writing.total
	var shots := {"01-quarter": 0.25, "02-half": 0.5, "03-three-quarter": 0.8, "04-done": -1.0}
	for id in shots:
		var k: float = shots[id]
		p.phase_time = (p.write_start + total * k) if k >= 0.0 else (p.write_start + total + 2.0)
		p.clock = p.phase_time
		p._animate_guest()
		for i in 3: await process_frame
		await RenderingServer.frame_post_draw
		var ok := root.get_texture().get_image().save_png(out + id + ".png") == OK
		print("capture %s %s" % [id, "ok" if ok else "fail"])
	quit()
