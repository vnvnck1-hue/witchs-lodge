extends Node
## 개발용 화면 캡처. 실행 인자 예:
##   godot --path . -- --shot=out.png --scenario=dragon
## 시나리오: start(기본), guests, combat, dragon, extension, panel

var game
var opts: Dictionary = {}


static func parse_args() -> Dictionary:
	var out := {}
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--") and a.contains("="):
			var kv := a.substr(2).split("=", true, 1)
			out[kv[0]] = kv[1]
	if not out.has("shot"):
		return {}
	return out


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var scenario: String = opts.get("scenario", "start")
	var delay := float(opts.get("delay", "2.5"))
	await get_tree().process_frame
	if opts.get("ui", "on") == "off":
		game.hud.visible = false
	if opts.get("lighting", "normal") == "flat":
		game.world.env.ssao_enabled = false
		game.world.sun.shadow_enabled = false
	if opts.get("lighting", "normal") == "no_ssao":
		game.world.env.ssao_enabled = false
	if opts.get("lighting", "normal") == "no_shadow":
		game.world.sun.shadow_enabled = false
	match scenario:
		"guests":
			game.session.prep_elapsed = 3.0
			delay = float(opts.get("delay", "7.5"))
		"combat":
			game.session.wave_index = 2
			game.session.start_wave()
			game.player.set_destination(Vector3(-3.0, 0, 4.0))
			Engine.time_scale = 3.0
			delay = float(opts.get("delay", "22"))
		"dragon":
			game.session.wave_index = 2
			game.session.start_wave()
			Engine.time_scale = 3.0
			await get_tree().create_timer(14.0, true, false, false).timeout
			Engine.time_scale = 1.0
			game.economy.debug_add_gold(200)
			game.economy.buy("dragon")
			delay = float(opts.get("delay", "3.4"))
		"extension":
			game.economy.debug_add_gold(100)
			game.economy.buy("extension")
			delay = float(opts.get("delay", "2.0"))
		"panel":
			game.hud.open_lodge_panel()
			delay = float(opts.get("delay", "1.0"))
	await get_tree().create_timer(delay, true, false, false).timeout
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	img.save_png(opts["shot"])
	print("SHOT saved: ", opts["shot"])
	get_tree().quit()
