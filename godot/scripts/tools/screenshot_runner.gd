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
		"cards":
			# 손패 + 고용 제안 + 털 난 양
			game.debug_cards()
			game.session.wave_index = 1
			game.world.pasture.produce_wool(2)
			game.session.wave_index = 0
			game.session.prep_elapsed = 25.2
			delay = float(opts.get("delay", "2.0"))
		"cards_drag":
			# 용병 카드를 자원 나무 위로 끌고 있는 장면(대상 강조·작업 위치·미리보기)
			game.debug_cards()
			await get_tree().create_timer(1.0, true, false, false).timeout
			var hand = game.hud.card_hand
			for e in game.cards.hand():
				if e["id"] == "axe_mercenary":
					hand.begin_drag(e["uid"])
			var tree: Dictionary = game.world.harvest_trees[0]
			var at: Vector2 = game.world.camera.unproject_position(tree["pos"] + Vector3(0, 1.6, 0))
			# 실제 마우스 움직임이 미리보기 위치를 덮어쓰지 않도록 매 프레임 고정
			for f in 40:
				hand.drag_pos = at
				await get_tree().process_frame
			delay = float(opts.get("delay", "0.05"))
		"cards_combat":
			# 밤: 손패에서 소환한 용병·하수인이 길을 막는다
			await get_tree().create_timer(0.5, true, false, false).timeout
			game.session.wave_index = 1
			game.session.start_wave()
			for i in 2:
				game.cards.add("axe_mercenary", 1, game.economy._pick_name())
			game.cards.add("forest_monster")
			var spots := [Vector3(-4.5, 0, 6.6), Vector3(-2.5, 0, 7.2), Vector3(-3.5, 0, 5.4)]
			var i2 := 0
			for e in game.cards.hand().duplicate():
				var r: Dictionary = game.resolver.commit(e["uid"], game.world.camera.unproject_position(spots[i2]))
				print("SHOT summon ", e["id"], " ok=", r["ok"], " ", r.get("reason", ""))
				i2 += 1
			game.player.set_destination(Vector3(-1.5, 0, 5.0))
			Engine.time_scale = 3.0
			delay = float(opts.get("delay", "16"))
		"panel":
			game.hud.open_lodge_panel()
			delay = float(opts.get("delay", "1.0"))
	await get_tree().create_timer(delay, true, false, false).timeout
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	var save_error := img.save_png(opts["shot"])
	if save_error != OK:
		push_error("Screenshot save failed: " + str(save_error) + " " + str(opts["shot"]))
		get_tree().quit(1)
		return
	print("SHOT saved: ", opts["shot"])
	print("SHOT screen style: ", preload("res://scripts/visual/screen_style.gd").current_id)
	get_tree().quit()
