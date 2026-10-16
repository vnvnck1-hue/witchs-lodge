extends SceneTree
## Headless checks for approved art bindings, layout and unchanged UI transactions.
const Ext := preload("res://scripts/ui/moon/moon_extension.gd")
const SkinUI := preload("res://scripts/ui/moon/moon_skin.gd")
const Profiles := preload("res://scripts/ui/guest_profiles.gd")
const Cfg := preload("res://scripts/config.gd")
var game
var checks: Array = []
var failures: Array = []
var out := "res://../output/ui-extension-implementation/verification.json"

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): out = arg.trim_prefix("--out=")
	create_timer(60, true, false, true).timeout.connect(func(): push_error("UI verification timeout"); quit(2))
	run.call_deferred()

func check(ok: bool, title: String) -> void:
	checks.append({"ok": ok, "check": title})
	if not ok: failures.append(title)
	print("UI_EXTENSION ", "PASS " if ok else "FAIL ", title)

func frames(n := 5) -> void:
	for i in n: await process_frame

func click(control: Control) -> void:
	var at := control.get_global_rect().get_center()
	var move := InputEventMouseMotion.new()
	move.position = at
	move.global_position = at
	root.push_input(move, true)
	await frames(2)
	for down in [true, false]:
		var e := InputEventMouseButton.new()
		e.position = at
		e.global_position = at
		e.button_index = MOUSE_BUTTON_LEFT
		e.pressed = down
		root.push_input(e, true)
		await frames(2)

func run() -> void:
	var regions: Array = JSON.parse_string(FileAccess.get_file_as_string("res://assets/ui/moon_runes/extension_v01/atlas-regions.json"))
	check(regions.size() >= 36, "all production atlas parts present")
	for r in regions:
		var texture := Ext.tex(r.id)
		check(texture is AtlasTexture and texture.get_width() > 4 and texture.get_height() > 4, "atlas resource " + r.id)
	var theme := SkinUI.make_theme()
	for type in ["Button", "OptionButton"]:
		for state in ["normal", "hover", "pressed", "disabled", "focus"]:
			check(theme.get_stylebox(state, type) is StyleBoxTexture, type + " art state " + state)
	for state in ["tab_selected", "tab_unselected", "tab_hovered", "tab_disabled"]:
		check(theme.get_stylebox(state, "TabContainer") is StyleBoxTexture, "tabs " + state)
	check(theme.get_icon("checked", "CheckButton") != null and theme.get_icon("unchecked", "CheckButton") != null, "both moon toggle states bound")
	check(theme.get_icon("arrow", "OptionButton") != null and theme.get_stylebox("panel", "PopupMenu") is StyleBoxTexture, "dropdown arrow and menu art")
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await frames(8)
	game.session.set_process(false)
	var hud = game.hud
	var hand = hud.card_hand
	for p in [hud.lodge_panel, hud.pause_panel, hud.end_panel, hand.pocket_panel, hand.sale_panel]:
		check(p.get_theme_stylebox("panel") is StyleBoxTexture, "modal textured " + str(p.get_path()))
	check(hand.tooltip.get_theme_stylebox("panel") is StyleBoxTexture and hand.preview.get_theme_stylebox("panel") is StyleBoxTexture, "tooltip and drag preview artwork")
	check(hud.map_window.get_theme_stylebox("panel") is StyleBoxTexture, "map frame artwork")
	check(game.get_node("LambBubble").bubble.get_theme_stylebox("panel") is StyleBoxTexture, "growth speech artwork")
	check(game.guest_ui.badge.get_theme_stylebox("panel") is StyleBoxTexture, "guest count badge artwork")
	var originals := []
	for profile in Profiles.all_profiles():
		var path: String = profile.portrait
		var expected: String = "res://assets/portraits/guest_" + profile.id + "_cutout.png"
		check(path == expected and ResourceLoader.exists(path), "existing portrait binding " + profile.id)
		originals.append({"id": profile.id, "path": path, "sha256": FileAccess.get_sha256(path) if FileAccess.file_exists(path) else "packed-import"})
	for viewport in [Vector2i(960, 540), Vector2i(1280, 720), Vector2i(1774, 887), Vector2i(1920, 1080)]:
		root.size = viewport
		await frames(6)
		hud.open_lodge_panel()
		await frames(6)
		check(root.get_visible_rect().grow(-10).encloses(hud.lodge_panel.get_global_rect()), "facility modal fits " + str(viewport))
		hud.close_lodge_panel()
		hand.open_pocket()
		await frames(6)
		check(root.get_visible_rect().grow(-10).encloses(hand.pocket_panel.get_global_rect()), "pocket modal fits " + str(viewport))
		hand.close_pocket()
		hud._toggle_pause()
		if not hud.pause_settings.visible: hud._toggle_section(hud.pause_settings)
		if not hud.pause_help.visible: hud._toggle_section(hud.pause_help)
		await frames(6)
		check(root.get_visible_rect().grow(-10).encloses(hud.pause_panel.get_global_rect()), "expanded settings and help fit " + str(viewport))
		hud._toggle_pause()
	root.size = Vector2i(1774, 887)
	await frames(6)
	# Buy through real themed controls; the economy remains the transaction owner.
	game.economy.debug_add_gold(100)
	game.world.lodge.take_damage(50)
	hud.open_lodge_panel(0)
	await frames(5)
	var gold: int = game.economy.gold
	var hp: float = game.world.lodge.hp
	await click(hud.shop_rows.repair.button)
	check(game.economy.gold == gold - Cfg.COST_REPAIR and game.world.lodge.hp == minf(hp + Cfg.REPAIR_AMOUNT, game.world.lodge.max_hp), "themed repair click keeps exact cost and healing")
	check(paused, "management still pauses preparation")
	hud.close_lodge_panel()
	check(not paused, "management close resumes")
	game.cards.add("wool", 5)
	var uid := -1
	for e in game.cards.hand():
		if e.id == "wool": uid = e.uid
	check(uid != -1, "sale test inventory exists")
	hand.open_sale(uid)
	hand._set_qty(2)
	check(hand.sale_qty == 2 and hand.sale_total.text.contains(str(2 * Cfg.WOOL_PRICE)), "quantity and dynamic price label")
	gold = game.economy.gold
	hand._confirm_sale()
	check(game.economy.gold == gold + 2 * Cfg.WOOL_PRICE and game.cards.get_entry(uid).count == 3, "sale exact payment and consumption")
	check(not hand.sale_panel.visible and not paused, "sale closes and resumes")
	var count: int = game.cards.hand().size()
	hand.open_pocket()
	check(paused and game.cards.hand().size() == count, "pocket is inspection only and retains cards")
	hand.close_pocket()
	hud._toggle_pause()
	await frames(3)
	var enabled: bool = game.world.fog_of_war.enabled
	await click(hud.fog_toggle)
	check(game.world.fog_of_war.enabled != enabled, "moon toggle still controls fog")
	hud._toggle_pause()
	check(not paused, "pause resume after settings")
	game.relics.grant("moonlit_charm")
	await frames(5)
	check(hud.relic_tray.get_child_count() > 0 and hud.relic_tray.get_child(0).get_theme_stylebox("panel") is StyleBoxTexture, "relic slot art")
	game.session.report_defeat("UI verification")
	await frames(5)
	check(hud.end_panel.visible and paused, "result screen preserves defeat and pause")
	check(hud.end_title.get_meta("extension_header") == "defeat_header", "defeat header variant")
	var file := FileAccess.open(out, FileAccess.WRITE)
	if file != null: file.store_string(JSON.stringify({"checks": checks, "failures": failures, "portraits": originals, "renderer": DisplayServer.get_name()}, "\t"))
	print("RESULT ", checks.size() - failures.size(), "/", checks.size())
	quit(0 if failures.is_empty() else 1)
