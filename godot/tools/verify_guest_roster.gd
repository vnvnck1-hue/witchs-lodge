extends SceneTree
## Seven portraits/dialogue sets + real two-day lodging rotation, repeat greetings and mercenary identity.
const Profiles := preload("res://scripts/ui/guest_profiles.gd")
const Cfg := preload("res://scripts/config.gd")
var game
var checks: Array = []
var failures: Array = []
var seen: Array[String] = []
var rendered: Array[String] = []
var emitted: Array = []
var out := ""
var render := true

func _initialize() -> void:
	out = ProjectSettings.globalize_path("res://../output/guest-roster-v3/")
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): out = arg.trim_prefix("--out=").trim_suffix("/") + "/"
	render = DisplayServer.get_name() != "headless"
	create_timer(90.0, true, false, true).timeout.connect(func(): push_error("Roster timeout"); quit(2))
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	checks.append({"ok": ok, "check": message})
	print("ROSTER ", "PASS " if ok else "FAIL ", message)
	if not ok: failures.append(message)

func frames(count := 3) -> void:
	for i in count: await process_frame

func cutout(texture: Texture2D) -> bool:
	var image := texture.get_image()
	if image.is_compressed(): image.decompress()
	var clear := 0
	var solid := 0
	var total := 0
	for y in range(0, image.get_height(), 16):
		for x in range(0, image.get_width(), 16):
			var alpha := image.get_pixel(x, y).a
			clear += int(alpha < 0.01)
			solid += int(alpha > 0.98)
			total += 1
	return clear > total * 0.08 and solid > total * 0.3

func capture_guest(profile: Dictionary) -> void:
	var intro = game.guest_arrival
	intro._show_guest()
	intro.phase_time = 2.0
	intro._animate_guest()
	await frames(3)
	check(intro.name_label.text == profile["person"] and intro.portrait.texture.resource_path == profile["portrait"], "live notification matches " + profile["id"])
	check(not paused and game.hud.root.visible and game.movement_input_allowed(), "live gameplay preserved for " + profile["id"])
	if profile["id"] in rendered: return
	rendered.append(profile["id"])
	if render:
		await RenderingServer.frame_post_draw
		check(root.get_texture().get_image().save_png(out + profile["id"] + ".png") == OK, "capture " + profile["id"])

func run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await frames(5)
	game.world.day_cycle.set_mode("day")
	game.economy.batch_arrived.connect(func(batch: Array): emitted.append(batch.duplicate(true)))
	var roster := Profiles.all_profiles()
	check(roster.size() == 42, "42 character definitions (7 human + 5 races x 7, docs/races-guests-v01.md)")
	var ids: Array = []
	var names: Array = []
	var paths: Array = []
	for profile in roster:
		check(not profile.id in ids and not profile.person in names and (profile.get("portrait_missing", false) or not profile.portrait in paths), "distinct id/name/portrait for " + profile.id)
		ids.append(profile.id)
		names.append(profile.person)
		paths.append(profile.portrait)
		var texture := load(profile.portrait) as Texture2D
		if profile.get("portrait_missing", false):
			check(texture != null and profile.portrait == Profiles.PLACEHOLDER_PORTRAIT, "placeholder silhouette until Codex delivers portrait for " + profile.id)
		else:
			check(texture != null and texture.get_height() > 1000 and cutout(texture), "production transparent portrait for " + profile.id)
		check(profile.lines.size() == 3, "three authored greeting/lore lines for " + profile.id)
		for line in profile.lines:
			var wrapped: Array[String] = game.guest_arrival._wrap_dialogue(line)
			var fits := wrapped.size() <= 3
			for row in wrapped:
				var font: Font = game.guest_arrival.dialogue_lines[0].get_theme_font("font")
				fits = fits and font.get_string_size(row, HORIZONTAL_ALIGNMENT_LEFT, -1, game.guest_arrival.dialogue_font_size).x <= game.guest_arrival.text_width
			check(fits, "complete readable dialogue for " + profile.id + ": " + line.replace("\n", " / "))
	# Normal two-person capacity: day 1 = 브람/네리, 하랄/오르무, 티슬/윌로우; day 2 batch 0 = 티슬(재방문)/니브 (races rotate, docs/races-guests-v01.md §1).
	for day in [1, 2]:
		if day == 2:
			game.economy.end_prep()
			await frames(3)
			game.session.wave_index = 1
			game.session._enter_prep()
		for batch_index in (3 if day == 1 else 1):
			var arrive: float = Cfg.GUEST_ARRIVALS[batch_index] + 0.05
			game.session.prep_elapsed = arrive
			game.economy.update_prep(arrive)
			check(game.economy.batches[batch_index].count == 2, "unchanged lodging capacity day %d batch %d" % [day, batch_index])
			var party: Array = emitted[-1]
			check(party.size() == 2 and party[0].id != party[1].id, "different people in actual party day %d batch %d" % [day, batch_index])
			for profile in party:
				if not profile.id in seen: seen.append(profile.id)
				var visit: int = game.economy.guest_visit_counts[profile.id] - 1
				check(profile.line == Profiles.greeting(profile, visit), "first/repeat greeting comes from actual visit count for " + profile.id)
				await capture_guest(profile)
			game.guest_arrival.finish()
			var before: int = game.economy.gold
			game.economy.update_prep(arrive + Cfg.GUEST_STAY)
			check(game.economy.gold == before + 2 * Cfg.GUEST_FEE, "unchanged exact lodging payment day %d batch %d" % [day, batch_index])
			if day == 1 and batch_index in Cfg.HIRE_BATCHES:
				var offer: Dictionary = game.economy.offers[-1]
				check(offer.person == party[0].person, "same introduced person in hiring offer: " + offer.person)
				var name: String = offer.person
				check(game.economy.hire(offer), "existing mercenary contract can hire " + name)
				check(game.cards.persons_in_use().has(name), "contract card keeps name " + name)
	check(seen.size() == 7, "seven distinct guests (4 races) appear in real first-two-day arrival batches at base capacity")
	check(game.economy.guest_visit_counts.get("thistle", 0) > 1 and Profiles.greeting(Profiles.character("nib"), 1) != Profiles.greeting(Profiles.character("nib"), 0), "returning guest 티슬 counts a second visit and repeat greetings differ")
	var used_before: Array = game.cards.persons_in_use()
	check(not game.economy._pick_name("브람") in used_before, "preferred mercenary never duplicates an owned contract identity")
	var result := {"checks": checks, "failures": failures, "seen": seen, "rendered": rendered}
	var file := FileAccess.open(out + "verification.json", FileAccess.WRITE)
	if file != null: file.store_string(JSON.stringify(result, "\t"))
	print("GUEST_ROSTER_VERIFY ", "PASS" if failures.is_empty() else "FAIL", " checks=", checks.size(), " seen=", seen)
	quit(0 if failures.is_empty() else 1)
