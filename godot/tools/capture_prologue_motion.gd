extends SceneTree
## 프롤로그 모션 코믹스 실제 화면 캡처. 헤드리스 더미 렌더러로는 확인할 수 없는 것 — 레이어의 실제 합성(알파 가장자리),
## 글로우 레이어의 가산 혼합 색, 카메라 줌·전경 시차가 만든 깊이, 자막 종이 패널의 실제 겹침 — 만 컷별 핵심 시각에 짧게 확인한다.
## 타이밍·상태 계산은 verify_prologue_motion.gd 가 헤드리스로 검증한다.
## 실행(창 모드): .tools/Godot-4.7.2.exe --path godot --resolution 1920x1080 --script res://tools/capture_prologue_motion.gd
## 결과: res://screenshots/ftue/motion/cap-cutN-<시각>.png

const OUT := "res://screenshots/ftue/motion/"
const PrologueScript := preload("res://scripts/ui/prologue.gd")

## [컷 인덱스, 시각들] — 기획 §3의 연출 전환점
const SHOTS := [
	[0, [0.3, 2.6, 6.3, 8.4, 9.0]],
	[1, [0.5, 4.0, 5.6, 8.4]],
	[2, [1.2, 2.8, 5.2, 7.9, 8.2]],
	[3, [0.9, 3.4, 6.4, 8.6]],
]

var p


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	_run.call_deferred()


func _wait(n: int) -> void:
	for i in n:
		await process_frame


func _shot(name: String) -> void:
	await _wait(2)
	var img := root.get_viewport().get_texture().get_image()
	img.save_png(OUT + name + ".png")
	print("SHOT ", name, " motion=", p.motion_used)


func _run() -> void:
	p = PrologueScript.new()
	root.add_child(p)
	await _wait(3)
	p.play()
	await _wait(3)
	p.set_process(false)   # 시각은 직접 지정한다
	for entry in SHOTS:
		var i: int = entry[0]
		if p.index != i:
			p._start_cut(i)
			if p.outgoing != null:
				p.outgoing.queue_free()
				p.outgoing = null
			await _wait(2)
		for at in entry[1]:
			p.current.evaluate(float(at))
			p.caption_panel.modulate.a = 1.0 if at >= p.current.line_at[0] and at < p.current.dur else 0.0
			p._update_caption(float(at))
			if p.current.embers != null:
				p.current.embers.restart()
				p.current.embers.preprocess = 2.0
			await _shot("cap-cut%d-%04.1f" % [i + 1, at])
	print("CAPTURE DONE")
	quit(0)
