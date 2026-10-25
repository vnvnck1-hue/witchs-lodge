extends SceneTree
## UI audit only: controlled runtime states, no resource or gameplay source changes.
## Actual renderer is required to inspect theme textures and default widget shapes.
const SkinUI := preload("res://scripts/ui/moon/moon_skin.gd")
const Session := preload("res://scripts/game/game_session.gd")
var game
var out := "res://screenshots/ui-audit-2026-10-16/"
var shots: Array = []
var scan_only := false
var extra_only := false
var world_only := false

func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a == "--scan-only": scan_only = true
		if a == "--extras": extra_only = true
		if a == "--world-details": world_only = true
		if a.begins_with("--out="): out = a.trim_prefix("--out=").trim_suffix("/") + "/"
	create_timer(240.0, true, false, true).timeout.connect(func(): push_error("UI audit timed out"); quit(2))
	call_deferred("run")

func frames(n := 5) -> void:
	for i in n: await process_frame

func seconds(t: float) -> void:
	await create_timer(t, true, false, true).timeout

func rect(c: Control) -> Array:
	var r := c.get_global_rect()
	return [r.position.x, r.position.y, r.size.x, r.size.y]

func capture(id: String, targets: Array = []) -> void:
	await frames(5)
	var record := {"id": id, "regions": targets, "viewport": [root.size.x, root.size.y]}
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		var error := root.get_texture().get_image().save_png(out + id + ".png")
		if error != OK: push_error("Capture failed: " + id); quit(1); return
	shots.append(record)
	print("AUDIT_CAPTURE ", id)

func clean_toasts() -> void:
	for c in game.hud.toast_box.get_children(): c.queue_free()

func inventory(n: Node, list: Array) -> void:
	if n is Control:
		var c := n as Control
		var d := {"path": str(game.get_path_to(c)), "type": c.get_class(), "visible": c.is_visible_in_tree()}
		if c is BaseButton: d["text"] = c.get("text")
		if c is TextureRect: d["texture"] = str(c.texture.resource_path) if c.texture != null else ""
		if c is PanelContainer: d["panel_style"] = c.get_theme_stylebox("panel").get_class()
		list.append(d)
	for child in n.get_children(): inventory(child, list)

func write_manifest() -> void:
	var controls: Array = []
	inventory(game, controls)
	var sources := {}
	for id in ["player_status", "objective", "phase", "resources", "pause", "storage", "lodge_button", "dragon_disabled", "dragon_active", "hand_tray", "gauge_fill_red", "gauge_fill_teal", "phase_fill", "stack_badge"]:
		sources[id] = SkinUI.source_of(id)
	var theme: Theme = game.hud.theme_res
	var stock := {}
	for type in ["TabContainer", "TabBar", "CheckButton", "OptionButton"]:
		stock[type] = {"styles_overridden": theme.get_stylebox_list(type), "icons_overridden": theme.get_icon_list(type)}
	var f := FileAccess.open(out + ("world-evidence.json" if world_only else ("extras-evidence.json" if extra_only else "runtime-evidence.json")), FileAccess.WRITE)
	f.store_string(JSON.stringify({"renderer": DisplayServer.get_name(), "engine": Engine.get_version_info(), "shots": shots, "controls": controls, "sources": sources, "widget_theme_overrides": stock, "chest_closed": ResourceLoader.exists("res://assets/ui/chest_closed.png"), "chest_open": ResourceLoader.exists("res://assets/ui/chest_open.png")}, "\t"))

func run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out))
	root.size = Vector2i(1774, 887)
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await frames(12)
	game.session.set_process(false)
	game.world.day_cycle.set_mode("day")
	if scan_only:
		write_manifest()
		print("AUDIT_SCAN PASS")
		quit()
		return
	if world_only:
		await world_details()
		write_manifest()
		print("AUDIT_WORLD PASS shots=", shots.size())
		quit()
		return
	if extra_only:
		await extras()
		write_manifest()
		print("AUDIT_EXTRAS PASS shots=", shots.size())
		quit()
		return
	game.cards.add("lumberjack", 1, "토르빈")
	game.cards.add("wool", 5)
	game.cards.add("timber", 6)
	game.cards.add("forest_monster", 1)
	for id in ["ward_lantern", "frost_rune", "lamb", "old_spellbook"]: game.cards.add(id, 1, "", "pocket")
	await seconds(1.5)
	clean_toasts()
	await capture("00-main-hud")
	var hud = game.hud
	var hand = hud.card_hand
	hud.open_lodge_panel(0)
	await capture("01-lodge-facilities", [rect(hud.lodge_panel)])
	hud.close_lodge_panel()
	game.economy.update_prep(5.1)
	for entry in game.guest_events.visits:
		game.guest_events.admit(entry.profile)
		entry.ready = true
	game.guest_arrival.finish()
	game.guest_events.changed.emit()
	await frames()
	hud.open_lodge_panel(1)
	await capture("02-lodge-guests", [rect(hud.lodge_panel)])
	hud.close_lodge_panel()
	var uid: int = game.guest_events.visits[0].uid
	game.guest_ui.open_conversation(uid)
	await seconds(1.7)
	await capture("03-dialogue-next", [rect(game.guest_ui.next_button), rect(game.guest_ui.close_button)])
	game.guest_ui.advance_dialogue()
	await capture("04-dialogue-choices", [rect(game.guest_ui.choices), rect(game.guest_ui.close_button)])
	game.guest_ui.choose(0)
	game.guest_ui.advance_dialogue()
	game.guest_ui.advance_dialogue()
	hud.open_lodge_panel(2)
	await capture("05-dialogue-history", [rect(hud.lodge_panel)])
	hud.close_lodge_panel()
	await capture("06-guest-notification", [rect(game.guest_ui.notification), rect(game.guest_ui.badge)])
	hud._toggle_pause()
	await capture("07-pause", [rect(hud.pause_panel)])
	hud._toggle_section(hud.pause_settings)
	await capture("08-settings", [rect(hud.pause_panel), rect(hud.fog_toggle)])
	var popup: PopupMenu = hud.style_select.get_popup()
	popup.position = Vector2i(hud.style_select.get_global_rect().position + Vector2(0, hud.style_select.size.y))
	popup.size.x = int(hud.style_select.size.x)
	popup.popup()
	await capture("09-settings-dropdown", [rect(hud.style_select)])
	popup.hide()
	hud._toggle_section(hud.pause_settings)
	hud._toggle_section(hud.pause_help)
	await capture("10-help", [rect(hud.pause_panel)])
	hud._toggle_pause()
	game.economy.update_prep(25.1)
	clean_toasts()
	await capture("11-hire-offer", [rect(hand.offer_box)])
	for offer in game.economy.offers.duplicate(): game.economy._close_offer(offer, false)
	hand.open_pocket()
	await capture("12-pocket", [rect(hand.pocket_panel)])
	var scroll: ScrollContainer = hand.pocket_list.get_parent()
	scroll.scroll_vertical = 10000
	await capture("13-pocket-lower", [rect(hand.pocket_panel)])
	hand.close_pocket()
	var wool := -1
	var lumber := -1
	for e in game.cards.hand():
		if e.id == "wool": wool = e.uid
		if e.id == "lumberjack": lumber = e.uid
	hand.open_sale(wool)
	await capture("14-sale", [rect(hand.sale_panel)])
	hand.close_sale()
	hand.set_hover(lumber, true)
	await seconds(0.7)
	await capture("15-card-tooltip", [rect(hand.tooltip)])
	hand.set_hover(lumber, false)
	hand.begin_drag(lumber)
	hand.drag_pos = game.world.camera.unproject_position(Vector3(0, 0, 5.0))
	await seconds(0.5)
	await capture("16-drag-preview", [rect(hand.preview)])
	hand._cancel_drag()
	hud.set_map_visible(true)
	await capture("17-map", [rect(hud.map_window)])
	hud.set_map_visible(false)
	game.toast("양털을 판매했습니다 · +15G", SkinUI.GOOD)
	game.toast("골드가 부족합니다", SkinUI.BAD)
	await seconds(0.25)
	await capture("18-toasts", [rect(hud.toast_box)])
	clean_toasts()
	game.relics.grant("moonlit_charm")
	game.relics.grant("hearth_ember")
	await seconds(0.6)
	await capture("19-relic-slots", [rect(hud.relic_tray)])
	clean_toasts()
	game.chest_ui.open(Vector3.ZERO)
	await seconds(0.6)
	await capture("20-chest-art")
	await seconds(2.1)
	await capture("21-relic-selection")
	game.chest_ui._on_pick(1)
	await seconds(0.9)
	await capture("22-relic-reveal")
	await seconds(1.4)
	game.spellbook_ui.open()
	await seconds(1.5)
	await capture("23-spellbook-selection")
	game.spellbook_ui.close()
	await seconds(0.4)
	game.world.fog_of_war.set_enabled(false)
	game.player.position = Vector3(2.0, 0, 7.0)
	game.player.set_physics_process(false)
	game.contracts.spawn_guard("merc", "브람", Vector3(0.0, 0, 7.0), null, "warrior")
	var ally = game.contracts.allies.back()
	ally.set_physics_process(false)
	ally.add_carry("timber", 8)
	ally.add_carry("raw_meat", 2)
	ally.hp = ally.max_hp * 0.55
	game.player.hp = game.player.max_hp * 0.7
	game.world.lodge.hp = game.world.lodge.max_hp * 0.7
	var monster = load("res://scripts/actors/monster.gd").new()
	monster.setup(game, 36.0, false)
	monster.position = Vector3(-2.0, 0, 8.0)
	monster.card_drop = "forest_monster"
	game.actors.add_child(monster)
	monster.set_physics_process(false)
	await seconds(0.5)
	clean_toasts()
	await capture("24-world-hp-tags-carry")
	var thorn = load("res://scripts/actors/thorn_seed.gd").new()
	thorn.game = game
	thorn.position = Vector3(3.0, 0, 9.0)
	game.actors.add_child(thorn)
	game.world.graveyard.bury("올라프", 1)
	await capture("25-thorn-label")
	game.cards.add("lamb")
	var lamb_uid := -1
	for e in game.cards.hand():
		if e.id == "lamb": lamb_uid = e.uid
	var pasture = game.world.pasture
	game.resolver.commit(lamb_uid, game.world.camera.unproject_position(Vector3(pasture.rect.get_center().x, 0, pasture.rect.get_center().y)))
	var lamb = pasture.slots.back()
	game.player.position = lamb.position + Vector3(-1.2, 0, 0.6)
	await seconds(0.5)
	await capture("26-lamb-bubble", [rect(game.get_node("LambBubble").bubble)])
	game.player.position = Vector3(7.5, 0, 2.2)
	game.world.pasture.produce_wool(2)
	game.player.shearing = true
	game.player.harvest_t = 1.4
	game.player.harvest_target = null
	await capture("27-shear-gauge")
	game.player.shearing = false
	game.player.position = Vector3(5.5, 0, -1.0)
	await seconds(0.5)
	await capture("28-grave-label")
	hud.debug_panel.visible = true
	await capture("29-debug", [rect(hud.debug_panel)])
	hud.debug_panel.visible = false
	game.session.report_defeat("산장이 파괴되었습니다")
	await capture("30-defeat", [rect(hud.end_panel)])
	game.session.state = Session.State.CLEARING
	game.session.wave_index = 3
	game.session._after_clear()
	await capture("31-victory", [rect(hud.end_panel)])
	write_manifest()
	print("AUDIT_CAPTURE PASS shots=", shots.size())
	quit()

func extras() -> void:
	clean_toasts()
	game.economy.update_prep(5.1)
	await seconds(0.2)
	await capture("32-arrival-count")
	await seconds(1.5)
	await capture("33-arrival-portrait")
	game.guest_arrival.finish()
	var mv := InputEventMouseMotion.new()
	mv.position = game.hud.moon.status_hover.get_global_rect().get_center()
	mv.global_position = mv.position
	root.push_input(mv, true)
	await seconds(1.0)
	await capture("34-hud-tooltip")
	mv = InputEventMouseMotion.new()
	mv.position = Vector2(900, 500)
	mv.global_position = mv.position
	root.push_input(mv, true)
	game.session.start_wave()
	game.dragon.summon()
	await seconds(0.6)
	clean_toasts()
	await capture("35-dragon-active", [rect(game.hud.moon.lodge_btn)])
	game.session.state = Session.State.PREP
	game.hud._on_state_changed(Session.State.PREP)
	game.hud.open_lodge_panel(0)
	var scroll: ScrollContainer = game.hud.lodge_tabs.get_child(0)
	scroll.scroll_vertical = 10000
	await capture("36-facilities-lower", [rect(game.hud.lodge_panel)])
	game.hud.close_lodge_panel()
	game.hud._toggle_pause()
	game.hud._toggle_section(game.hud.pause_settings)
	game.hud.fog_toggle.button_pressed = false
	await capture("37-settings-toggle-off", [rect(game.hud.pause_panel)])
	root.size = Vector2i(1280, 720)
	game.hud._toggle_section(game.hud.pause_help)
	await capture("38-settings-help-720p", [rect(game.hud.pause_panel)])

func world_details() -> void:
	game.player.set_physics_process(false)
	game.world.fog_of_war.set_enabled(false)
	var pasture = game.world.pasture
	pasture.spawn_sheep(1, true)
	var lamb = pasture.slots.back()
	lamb.set_physics_process(false)
	game.player.global_position = lamb.global_position + Vector3(-1.2, 0, 0.6)
	var pc = game.world.player_camera
	pc.height = 12.0
	pc.desired_height = 12.0
	pc.recenter()
	pc.set_process(false)
	await seconds(0.6)
	clean_toasts()
	await frames()
	await capture("26-lamb-bubble", [rect(game.get_node("LambBubble").bubble)])
	game.player.global_position = Vector3(7.5, 0, 2.2)
	pc.recenter()
	await seconds(0.4)
	game.player.shearing = true
	game.player.harvest_t = 1.4
	var sp: Vector2 = game.world.camera.unproject_position(game.player.global_position + Vector3(0, game.player.hp_offset + 0.35, 0))
	await capture("27-shear-gauge", [[sp.x - 110, sp.y - 60, 240, 160]])
	game.player.shearing = false
	game.world.graveyard.bury("올라프", 1)
	await seconds(1.2)
	var cam := Camera3D.new()
	game.world.add_child(cam)
	var focus := Vector3(2.4, 0.6, -4.4)
	cam.global_position = focus + Vector3(3.2, 4.5, -5.5)
	cam.look_at(focus)
	cam.current = true
	cam.fov = 35
	await frames(10)
	clean_toasts()
	await capture("28-grave-label", [[650, 240, 480, 400]])

