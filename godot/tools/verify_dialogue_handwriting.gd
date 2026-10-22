extends SceneTree
## 대사 필기 연출(docs/dialogue-handwriting.md) 헤드리스 검증: 필기 타임라인 리듬, 대화창 줄 셰이더 공개,
## 마저 적기(스킵), 펜 긁는 소리(quill_scratch) 압력 추종과 정지.
##   .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_dialogue_handwriting.gd
const Handwriting := preload("res://scripts/ui/handwriting.gd")
const Presenter := preload("res://scripts/ui/guest_arrival.gd")
const SoundBank := preload("res://scripts/audio/sound_bank.gd")
const MoonSkin := preload("res://scripts/ui/moon/moon_skin.gd")
const LINE := "어서 오게, 마녀 양반. 눈길이 깊어 한참을 헤맸다네!"

class FakeGame:
	var sounds

var passed := 0
var total := 0

func check(ok: bool, message: String) -> void:
	total += 1
	if ok: passed += 1
	print(("PASS " if ok else "FAIL ") + message)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	_timeline()
	await _presenter()
	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)

func _timeline() -> void:
	var font := MoonSkin.font()
	var lines := ["어서 오게, 마녀 양반.", "눈길이 깊어 한참을 헤맸다네!", ""]
	var plan = Handwriting.build(lines, font, 28)
	check(plan.total > 1.0 and plan.total < 4.0, "timeline length readable (%.2fs for %d chars)" % [plan.total, (lines[0] + lines[1]).length()])
	check(Handwriting.build(lines, font, 28).total == plan.total, "same text gives same rhythm (seeded)")
	var ordered := true
	for i in range(1, plan.strokes.size()):
		ordered = ordered and plan.strokes[i].t0 >= plan.strokes[i - 1].t1 - 0.0001
	check(ordered, "strokes run one after another")
	var spaces: Array = plan.strokes.filter(func(s): return s.ink == 0.0)
	check(spaces.size() == 6, "pen lifts (no ink) on each space: %d" % spaces.size())
	var comma: Dictionary = plan.strokes[5]  # "어서 오게," 의 쉼표
	var after: Dictionary = plan.strokes[6]
	check(after.t0 - comma.t1 >= Handwriting.MARK_PAUSE - 0.001, "breath after comma")
	check(plan.strokes.filter(func(s): return s.line == 1)[0].t0 - plan.line_ends[0] >= Handwriting.LINE_PAUSE - 0.001, "pause moving to next line")
	check(plan.reveal_at(0, -0.01) < 0.0 and plan.reveal_at(1, 0.2) < 0.0, "nothing visible before the pen reaches it")
	var prev := -100.0
	var grows := true
	var t := 0.0
	while t < plan.line_ends[0]:
		var x: float = plan.reveal_at(0, t)
		grows = grows and x >= prev - 0.001
		prev = x
		t += 0.01
	check(grows, "pen tip only moves forward along a line")
	var mid: float = plan.reveal_at(0, plan.line_ends[0] * 0.5)
	check(mid > 20.0 and mid < plan.line_widths[0], "half-way the line is half written (%.0f / %.0f px)" % [mid, plan.line_widths[0]])
	check(plan.reveal_at(0, plan.line_ends[0]) >= plan.line_widths[0], "line end fully revealed")
	check(plan.reveal_at(0, plan.line_ends[0] + Handwriting.DRY_TIME + 0.01) > 10000.0 and plan.wetness(0, plan.line_ends[0] + Handwriting.DRY_TIME + 0.01) < 0.001, "line dries and stays fully shown")
	check(plan.wetness(1, plan.line_ends[0] + 0.1) > 0.99, "line being written stays wet")
	var pressure := 0.0
	for s in plan.strokes:
		if s.ink > 0.0: pressure = maxf(pressure, plan.pen_at((s.t0 + s.t1) * 0.5))
	check(pressure > 0.6, "pen pressure mid-stroke")
	check(plan.pen_at(spaces[0].t0 + 0.02) == 0.0 and plan.pen_at(plan.total + 0.1) == 0.0, "silent pen while lifted and after writing")
	check(not plan.is_writing(plan.total) and plan.is_writing(plan.total - 0.01), "is_writing ends with last stroke")

func _presenter() -> void:
	var bank: Node = SoundBank.new()
	root.add_child(bank)
	await process_frame
	check(bank.streams.has("quill_scratch") and (bank.streams["quill_scratch"][0] as AudioStream).get_length() > 1.0, "quill_scratch sound registered in selected.json")
	var game := FakeGame.new()
	game.sounds = bank
	var p: CanvasLayer = Presenter.new()
	p.presentation_only = true
	p.game = game
	root.add_child(p)
	await process_frame
	p.set_process(false)  # 시간은 아래에서 직접 굴린다
	p.show_profile({"person": "브람", "role": "나무꾼", "detail": "", "portrait": "res://icon.png"}, LINE, "산장의 이야기")
	check(p.dialogue_lines.all(func(l): return l.material is ShaderMaterial and l.material.shader.resource_path.ends_with("handwriting_reveal.gdshader")), "dialogue lines use handwriting shader")
	check(p.write_start == Presenter.WRITE_DELAY, "writing starts after panel entrance")
	_advance(p, 0.5)
	check(float(p.dialogue_lines[0].material.get_shader_parameter("reveal_x")) < 0.0, "no ink before the panel settles")
	check(p.dialogue_lines[0].modulate.a > 0.99, "line label itself not faded (shader reveals)")
	var heard := 0.0
	var played := false
	var reveal_mid := 0.0
	var steps := int((p.write_start + p.writing.total * 0.5 - p.phase_time) / 0.02)
	for i in steps:
		_advance(p, 0.02)
		heard = maxf(heard, p.quill_level)
		played = played or (p.quill != null and p.quill.playing)
	reveal_mid = float(p.dialogue_lines[0].material.get_shader_parameter("reveal_x"))
	check(p.is_writing() and reveal_mid > 0.0, "writing in progress mid-way (pen at %.0f px)" % reveal_mid)
	check(heard > 0.3 and played, "quill scratch plays with pen pressure (peak %.2f)" % heard)
	check(p.quill != null and p.quill.bus == "Sfx", "quill on Sfx bus (follows sfx volume)")
	check(float(p.dialogue_lines[0].material.get_shader_parameter("wet_amount")) > 0.1 or float(p.dialogue_lines[1].material.get_shader_parameter("wet_amount")) > 0.1, "fresh ink shows wet colour")
	p.finish_writing()
	check(not p.is_writing(), "finish_writing completes the line at once")
	check(p.dialogue_lines.all(func(l): return float(l.material.get_shader_parameter("reveal_x")) > 10000.0 and float(l.material.get_shader_parameter("wet_amount")) < 0.001), "all lines shown and dry after finishing")
	for i in 20: _advance(p, 0.02)
	check(p.quill_level < 0.001 and not p.quill.playing, "quill falls silent once writing is done")
	p.update_dialogue("그럼 따뜻한 수프 한 그릇 부탁하네.")
	_advance(p, 0.02)
	check(p.is_writing() and float(p.dialogue_lines[0].material.get_shader_parameter("reveal_x")) < 0.0, "next line of the same guest starts a fresh writing")
	_advance(p, Presenter.WRITE_DELAY_UPDATE + p.writing.total + Handwriting.DRY_TIME + 0.1)
	check(not p.is_writing() and float(p.dialogue_lines[0].material.get_shader_parameter("reveal_x")) > 10000.0, "reply fully written in its own time")
	p.finish()
	for i in 10: _advance(p, 0.02, false)
	check(p.quill == null or not p.quill.playing, "closing the dialogue stops the pen")

func _advance(p, dt: float, running := true) -> void:
	if running:
		p.clock += dt
		p.phase_time += dt
		p._animate_guest()
	p._step_quill(dt)
