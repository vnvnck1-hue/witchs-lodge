extends SceneTree
var failures: Array[String] = []
var checks: Array = []
const OUT := "C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/output/fullscreen/"

func _initialize() -> void:
	create_timer(25.0,true,false,true).timeout.connect(func(): quit(2))
	call_deferred("_run")

func wait_frames(count:=12) -> void:
	for i in count: await process_frame

func check(ok: bool, label: String) -> void:
	checks.append({"check":label,"passed":ok})
	if not ok: failures.append(label)

func press_f11(echo:=false, pressed:=true) -> void:
	var key:=InputEventKey.new()
	key.keycode=KEY_F11
	key.physical_keycode=KEY_F11
	key.pressed=pressed
	key.echo=echo
	root.push_input(key,true)
	await wait_frames()

func _run() -> void:
	var game=load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await wait_frames()
	game.session.set_process(false)
	var initial_size:=root.size
	var initial_position:=root.position
	check(root.mode==Window.MODE_WINDOWED,"starts windowed")
	await press_f11()
	check(DisplayServer.window_get_mode()==DisplayServer.WINDOW_MODE_FULLSCREEN,"real F11 enters native fullscreen")
	check(root.size==DisplayServer.screen_get_size(root.current_screen),"fullscreen fills current monitor")
	check(game.hud.exploration_map.get_global_rect().end.x<=root.get_visible_rect().size.x+1,"fullscreen HUD fits")
	var ground:=Vector3(-3,0,6)
	var picked: Vector3=game.resolver._ground_at(game.world.camera.unproject_position(ground))
	print("PICK error=",picked.distance_to(ground)," viewport=",root.get_visible_rect()," picked=",picked)
	check(picked.distance_to(ground)<.02,"fullscreen world picking within 2cm")
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+"fullscreen.png")
	await press_f11(true)
	check(root.mode==Window.MODE_FULLSCREEN,"held key does not toggle repeatedly")
	await press_f11(false,false)
	check(root.mode==Window.MODE_FULLSCREEN,"key release does not toggle")
	await press_f11()
	check(root.mode==Window.MODE_WINDOWED and root.size==initial_size and root.position==initial_position,"restores window size and position")
	game.hud.open_lodge_panel()
	game.hud.lodge_btn.grab_focus()
	await press_f11()
	check(paused and game.hud.lodge_panel.visible and root.mode==Window.MODE_FULLSCREEN,"paused modal keeps state while fullscreen toggles")
	await press_f11()
	check(paused and root.mode==Window.MODE_WINDOWED,"paused window restore")
	game.hud.close_lodge_panel()
	var file:=FileAccess.open(OUT+("pack-" if "--pack" in OS.get_cmdline_user_args() else "")+"verification.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"passed":failures.is_empty(),"checks":checks,"failures":failures,"window_size":initial_size},"\t"))
	print("FULLSCREEN_CHECK passed=",failures.is_empty()," failures=",failures)
	quit(0 if failures.is_empty() else 1)
