extends SceneTree
## 에린 밑단 표시 마감 비교. 원본 PNG를 바꾸지 않고 실제 셰이더와 대화창을 렌더한다.
const Profiles := preload("res://scripts/ui/guest_profiles.gd")
const OUT := "res://../output/erin-portrait-hem/"

func _initialize() -> void:
	create_timer(90.0, true, false, true).timeout.connect(func(): quit(2))
	_run.call_deferred()

func frames(n := 3) -> void:
	for i in n: await process_frame

func shot(filename: String) -> void:
	await frames()
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + filename))

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	# 같은 원본 크기로 렌더해 마감 대상 밖의 픽셀이 모두 동일한지 확인한다.
	var tex: Texture2D = load("res://assets/portraits/guest_erin_cutout.png")
	var viewport := SubViewport.new()
	viewport.size = Vector2i(tex.get_size())
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var sprite := Sprite2D.new()
	sprite.texture = tex
	sprite.centered = false
	var mat := ShaderMaterial.new()
	mat.shader = load("res://shaders/guest_portrait_motion.gdshader")
	sprite.material = mat
	viewport.add_child(sprite)
	await frames()
	await RenderingServer.frame_post_draw
	var before := viewport.get_texture().get_image()
	mat.set_shader_parameter("rounded_hem", true)
	await frames()
	await RenderingServer.frame_post_draw
	var after := viewport.get_texture().get_image()
	var changed_above := 0
	var opaque_bottom := 0
	for y in int(tex.get_height() * 0.85):
		for x in tex.get_width():
			if before.get_pixel(x, y) != after.get_pixel(x, y): changed_above += 1
	for x in after.get_width():
		if after.get_pixel(x, after.get_height() - 1).a > 0.0: opaque_bottom += 1
	print("MASK: changed pixels above bottom 15%%=%d, opaque last-row pixels=%d" % [changed_above, opaque_bottom])
	after.save_png(ProjectSettings.globalize_path(OUT + "native-hem.png"))
	viewport.queue_free()
	await frames()
	root.size = Vector2i(1774, 887)
	# 게임에서 사용하는 대화 표시 부품을 동일한 좌표·배율로 직접 렌더한다.
	var pres = load("res://scripts/ui/guest_arrival.gd").new()
	pres.presentation_only = true
	root.add_child(pres)
	var profile: Dictionary = Profiles.guest_profile("erin")
	pres.show_profile(profile, str(profile["line"]))
	pres.set_process(false)
	pres.phase_time = 3.0
	pres.clock = 3.0
	pres._animate_guest()
	pres.portrait_material.set_shader_parameter("rounded_hem", false)
	pres.portrait.scale = Vector2.ONE
	await shot("01-before.png")
	pres.portrait_material.set_shader_parameter("rounded_hem", true)
	pres.portrait.scale = Vector2.ONE * float(profile["dialogue_portrait_scale"])
	await shot("02-after.png")
	root.size = Vector2i(960, 540)
	await shot("03-after-960.png")
	# 다른 인물로 바뀌었을 때 에린의 마감·확대가 남지 않아야 한다.
	pres.show_profile(Profiles.guest_profile("bram"), "다른 손님의 초상은 기존 마감을 유지합니다.")
	# 등장 스케일 트윈(0.92배에서 시작) 중이라 현재 배율 대신 기준 배율을 본다.
	var reset_ok: bool = is_equal_approx(pres.portrait_base_scale, 1.0) and not bool(pres.portrait_material.get_shader_parameter("rounded_hem"))
	print("PROFILE RESET: ", reset_ok)
	print("RESULT ", "PASS" if changed_above == 0 and opaque_bottom == 0 and reset_ok else "FAIL")
	quit(0 if changed_above == 0 and opaque_bottom == 0 and reset_ok else 1)
