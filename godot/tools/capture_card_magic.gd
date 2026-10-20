extends SceneTree
## 마법 카드 연출(card_warp.gdshaderinc) 실제 렌더 캡처. 셰이더 정점 변형·뒷면·명암은 헤드리스 더미 렌더러로 볼 수 없어 창을 띄운다.
## (1) 자세 표: 평평 · 좌우 회전 · 휨(볼록/오목) · 두루마리 · 비틀림 · 뒷면 · 물결 · 마법 광택을 한 장에.
## (2) 연출 동작 프레임: draw·pickup·return·use·stash 를 카드 한 장씩 연속 프레임으로 저장.
## 실행(프로젝트 루트): .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_card_magic.gd -- --out=<폴더>

const CardView := preload("res://scripts/ui/card_view.gd")
const Catalog := preload("res://scripts/ui/card_catalog.gd")
const MoonSkin := preload("res://scripts/ui/moon/moon_skin.gd")

var out_dir := "res://screenshots/card-magic/"
var frame_no := 0
var layer: Control


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			out_dir = a.trim_prefix("--out=").trim_suffix("/") + "/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_dir))
	create_timer(90.0, true, false, true).timeout.connect(func() -> void: quit(2))
	call_deferred("_run")


func shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(out_dir) + name + ".png")


func _card(id: String, at: Vector2, sz: Vector2) -> CardView:
	var v := CardView.new()
	v.setup(id, MoonSkin.card_surface(id, Catalog.texture(id, true)))
	layer.add_child(v)
	v.resize(sz)
	v.snap(at, 0.0, 1.0)
	v.t_lift = 1.0
	v.lift = 1.0
	v._apply()
	return v


func _pose(v: CardView, w: Dictionary) -> void:
	for k in w:
		v.mat.set_shader_parameter("warp_" + k, w[k])


func _label(text: String, at: Vector2) -> void:
	var l := Label.new()
	l.text = text
	l.position = at
	l.add_theme_font_size_override("font_size", 18)
	l.add_theme_color_override("font_color", Color(1, 0.95, 0.85))
	layer.add_child(l)


func _run() -> void:
	root.size = Vector2i(1600, 900)
	var bg := ColorRect.new()
	bg.color = Color(0.12, 0.09, 0.18)
	bg.size = Vector2(1600, 900)
	root.add_child(bg)
	layer = Control.new()
	layer.size = Vector2(1600, 900)
	root.add_child(layer)
	var sz := Vector2(170, 255)
	# (1) 자세 표
	var poses := [
		["평평", {}],
		["좌우 회전 0.7", {"yaw": 0.7}],
		["볼록 휨 0.5", {"bend": Vector2(0.5, 0.0)}],
		["오목 휨 -0.5", {"bend": Vector2(-0.5, 0.0)}],
		["두루마리 0.55", {"roll": 0.55}],
		["비틀림 1.4", {"twist": 1.4}],
		["뒷면(π)+휨", {"yaw": PI + 0.35, "bend": Vector2(0.3, 0.0)}],
		["물결+광택", {"flutter": 0.9, "magic": 1.0, "pitch": 0.3}],
	]
	var ids := ["wool", "timber", "hunter", "frost_rune", "lumberjack", "moss_bandage", "warrior", "resin_torch"]
	for i in poses.size():
		var col := i % 4
		var row := i / 4
		var at := Vector2(230 + col * 380, 400 + row * 420)
		var v := _card(ids[i], at, sz)
		_pose(v, poses[i][1])
		_label(poses[i][0], at + Vector2(-80, 20))
	for i in 6:
		await process_frame
	await shot("poses")
	for c in layer.get_children():
		c.queue_free()
	await process_frame
	# (2) 연출 동작: 카드마다 같은 자리에서 동작을 재생하며 프레임 저장(30fps 간격)
	var kinds := ["draw", "pickup", "return", "use", "stash"]
	for k in kinds.size():
		var kind: String = kinds[k]
		var v := _card("hunter", Vector2(800, 640), Vector2(220, 330))
		v.mode = CardView.Mode.REVEAL
		if kind == "use":
			v.start_dissolve(Callable())
		else:
			v.flourish(kind)
		if kind == "stash":
			v.t_scl = 0.6
		var n := 0
		var t := 0.0
		var dur: float = CardView.FLOURISH_TIME[kind] + (0.6 if kind == "use" else 0.1)
		while t < dur:
			await process_frame
			var d := 1.0 / 30.0
			t += d
			v.step(d)
			if kind == "use":
				v.tick_dissolve(d)
			await shot("%s_%02d" % [kind, n])
			n += 1
		v.queue_free()
		await process_frame
	print("CAPTURED ", out_dir)
	quit(0)
