extends Node3D
## 진입점: 모듈을 만들고 연결한다. 지면 클릭 → 이동 / 산장 클릭 → 관리 패널.
## 털이 자란 양 클릭 → 다가가 수확 / 고용을 기다리는 손님 클릭 → 고용. 카드 드래그는 HUD 손패가 처리한다.

const Cfg := preload("res://scripts/config.gd")
const Layout := preload("res://scripts/world/layout.gd")
const WorldScript := preload("res://scripts/world/world.gd")
const PlayerScript := preload("res://scripts/actors/player.gd")
const SessionScript := preload("res://scripts/game/game_session.gd")
const EconomyScript := preload("res://scripts/game/lodge_economy.gd")
const WaveScript := preload("res://scripts/game/wave_director.gd")
const DragonScript := preload("res://scripts/dragon/dragon_defense.gd")
const HudScript := preload("res://scripts/ui/hud.gd")
const ShotScript := preload("res://scripts/tools/screenshot_runner.gd")
const ScreenStyle := preload("res://scripts/visual/screen_style.gd")
const CameraStyle := preload("res://scripts/visual/camera_style.gd")
const WindowMode := preload("res://scripts/visual/window_mode.gd")
const CardsScript := preload("res://scripts/game/card_inventory.gd")
const ContractsScript := preload("res://scripts/game/contract_director.gd")
const ResolverScript := preload("res://scripts/game/card_use_resolver.gd")
const SoundBankScript := preload("res://scripts/audio/sound_bank.gd")
const GuestArrivalScript := preload("res://scripts/ui/guest_arrival.gd")
const LambBubbleScript := preload("res://scripts/ui/lamb_bubble.gd")
const GuestEventsScript := preload("res://scripts/game/guest_events.gd")
const GuestInteractionsScript := preload("res://scripts/ui/guest_interactions.gd")
const WildlifeScript := preload("res://scripts/game/wildlife_director.gd")
const RelicsScript := preload("res://scripts/game/relics.gd")
const CarryBubbleScript := preload("res://scripts/ui/carry_bubble.gd")
const ChestOpeningScript := preload("res://scripts/ui/chest_opening.gd")
const SpellbookScript := preload("res://scripts/ui/spellbook_picker.gd")
const MulliganScript := preload("res://scripts/ui/mulligan_screen.gd")

var world
var actors: Node3D
var player
var session
var economy
var waves
var dragon
var hud
var cards
var contracts
var resolver
var sheep_lost := 0
var sounds
var guest_arrival
var guest_events
var guest_ui
var wildlife
var relics
var chest_ui
var spellbook_ui
var mulligan_ui


func _ready() -> void:
	sounds = SoundBankScript.new()
	sounds.game = self
	add_child(sounds)
	var window_mode := WindowMode.new()
	window_mode.name = "WindowMode"
	add_child(window_mode)
	_configure_movement_input()
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--style=") and arg.trim_prefix("--style=") in ScreenStyle.IDS:
			ScreenStyle.current_id = arg.trim_prefix("--style=")
		if arg.begins_with("--camera=") and arg.trim_prefix("--camera=") in CameraStyle.IDS:
			CameraStyle.current_id = arg.trim_prefix("--camera=")
	world = WorldScript.new()
	world.name = "World"
	add_child(world)
	world.build(self)

	actors = Node3D.new()
	actors.name = "Actors"
	add_child(actors)

	player = PlayerScript.new()
	player.name = "Player"
	player.game = self
	player.position = Layout.PLAYER_START
	actors.add_child(player)
	player.visual.rotation.y = deg_to_rad(200.0)
	world.bind_player_camera(player)

	cards = CardsScript.new()
	cards.game = self
	add_child(cards)
	contracts = ContractsScript.new()
	contracts.game = self
	add_child(contracts)
	resolver = ResolverScript.new()
	resolver.game = self
	add_child(resolver)
	relics = RelicsScript.new()
	relics.game = self
	add_child(relics)
	wildlife = WildlifeScript.new()
	wildlife.game = self
	add_child(wildlife)
	contracts.bind_lodge()
	economy = EconomyScript.new()
	economy.game = self
	add_child(economy)
	waves = WaveScript.new()
	waves.game = self
	add_child(waves)
	dragon = DragonScript.new()
	dragon.game = self
	add_child(dragon)
	session = SessionScript.new()
	session.game = self
	add_child(session)
	guest_events = GuestEventsScript.new()
	guest_events.game = self
	add_child(guest_events)

	hud = HudScript.new()
	hud.game = self
	add_child(hud)
	guest_arrival = GuestArrivalScript.new()
	guest_arrival.game = self
	add_child(guest_arrival)
	var lamb_bubble := LambBubbleScript.new()
	lamb_bubble.game = self
	add_child(lamb_bubble)
	var carry_bubble := CarryBubbleScript.new()
	carry_bubble.game = self
	add_child(carry_bubble)
	chest_ui = ChestOpeningScript.new()
	chest_ui.game = self
	add_child(chest_ui)
	spellbook_ui = SpellbookScript.new()
	spellbook_ui.game = self
	add_child(spellbook_ui)
	mulligan_ui = MulliganScript.new()
	mulligan_ui.game = self
	add_child(mulligan_ui)
	guest_arrival.guest_admitted.connect(guest_events.admit)
	guest_ui = GuestInteractionsScript.new()
	guest_ui.game = self
	add_child(guest_ui)

	session.start()
	world.bind_day_and_sight()
	world.hazard_regions.bind_residents()
	_grant_starter_cards()

	var shot := ShotScript.parse_args()
	if not shot.is_empty():
		var runner := ShotScript.new()
		runner.game = self
		runner.opts = shot
		add_child(runner)


## 첫 시작: 시작 카드(Cfg.STARTER_CARDS)를 모두 주머니에 넣고 무작위로 STARTER_DRAW장을 손패로 뽑는다(확정 규칙 2).
## 기존 검증 도구(--script 실행)는 빈 손패를 전제로 하므로 지급하지 않는다(검증 도구는 grant_starter_cards()를 직접 부른다).
func _grant_starter_cards() -> void:
	if "--script" in OS.get_cmdline_args() or "--no-starter-cards" in OS.get_cmdline_user_args():
		return
	grant_starter_cards()


## interactive=true: 시작 손패 고르기 화면(3장 공개 → 1장 교체 가능 → 손패로). false: 연출 없이 바로 3장 드로우(검증용).
func grant_starter_cards(interactive := true) -> void:
	for pair in Cfg.STARTER_CARDS:
		cards.add(pair[0], pair[1], "", "pocket")
	if interactive and mulligan_ui != null:
		mulligan_ui.open()
		return
	var got: Array = cards.draw(Cfg.STARTER_DRAW)
	if not got.is_empty():
		toast("마녀의 주머니에서 시작 손패 %d장을 뽑았습니다 — 나머지 %d장은 아침마다 한 장씩" % [got.size(), cards.pocket().size()], Color(1.0, 0.95, 0.8))


func toast(text: String, color := Color.WHITE) -> void:
	if hud != null:
		hud.toast(text, color)


func on_sheep_died() -> void:
	sheep_lost += 1
	toast("양 한 마리를 잃었습니다", Color(1.0, 0.65, 0.65))


func _unhandled_input(event: InputEvent) -> void:
	if get_tree().paused or session.is_over() or player.dead:
		return
	var key := event as InputEventKey
	if key != null and key.pressed and not key.echo:
		if key.keycode == KEY_C:
			world.player_camera.recenter()
			get_viewport().set_input_as_handled()
		elif key.keycode == KEY_H:
			player.set_destination(Layout.DOOR_FRONT)
			world.show_click_marker(Layout.DOOR_FRONT)
			get_viewport().set_input_as_handled()
		return
	var mb := event as InputEventMouseButton
	if mb != null and mb.pressed and mb.button_index in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN]:
		if hud.card_hand.drag_uid < 0:
			world.player_camera.zoom(-1.0 if mb.button_index == MOUSE_BUTTON_WHEEL_UP else 1.0)
			get_viewport().set_input_as_handled()
		return
	if mb == null or not mb.pressed or mb.button_index != MOUSE_BUTTON_LEFT:
		return
	if session.is_over() or player.dead:
		return
	var cam: Camera3D = world.camera
	var mp: Vector2 = mb.position
	var from := cam.project_ray_origin(mp)
	var dir := cam.project_ray_normal(mp)
	var q := PhysicsRayQueryParameters3D.create(from, from + dir * 400.0, Cfg.L_GROUND | Cfg.L_OBSTACLE)
	var hit := get_world_3d().direct_space_state.intersect_ray(q)
	if session.state == SessionScript.State.PREP:
		for o in economy.offers:
			var g = o["guest"]
			if is_instance_valid(g) and cam.unproject_position(g.global_position + Vector3(0, 0.8, 0)).distance_to(mp) < 44.0:
				if not economy.hire(o):
					toast("고용할 수 없습니다 — " + economy.hire_block_reason(o), Color(1.0, 0.7, 0.7))
				return
		var sheep = _ready_sheep_at(cam, mp)
		if sheep != null:
			player.harvest(sheep)
			world.show_click_marker(sheep.global_position)
			return
	if not hit.is_empty() and hit["collider"] == world.lodge and session.state == SessionScript.State.PREP:
		hud.open_lodge_panel()
		return
	if absf(dir.y) < 0.001:
		return
	var t := -from.y / dir.y
	if t <= 0.0: return
	var ground := Layout.clamp_to_map(from + dir * t)
	var nav_map := get_world_3d().navigation_map
	if NavigationServer3D.map_get_iteration_id(nav_map) == 0: return
	var dest := NavigationServer3D.map_get_closest_point(nav_map, ground)
	dest.y = 0.0
	player.set_destination(dest)
	world.show_click_marker(dest)


func _configure_movement_input() -> void:
	var bindings := {"walk_left":[KEY_A,KEY_LEFT], "walk_right":[KEY_D,KEY_RIGHT],
		"walk_up":[KEY_W,KEY_UP], "walk_down":[KEY_S,KEY_DOWN]}
	for action in bindings:
		if InputMap.has_action(action): continue
		InputMap.add_action(action)
		for code in bindings[action]:
			var key := InputEventKey.new()
			key.physical_keycode = code
			InputMap.action_add_event(action,key)


func movement_input_allowed() -> bool:
	if session == null or session.is_over() or get_tree().paused: return false
	if hud == null: return true
	var hand = hud.card_hand
	if chest_ui != null and chest_ui.active: return false
	return not (hud.lodge_panel.visible or hud.pause_panel.visible or hud.end_panel.visible
		or hud.debug_panel.visible or hand.drag_uid >= 0 or hand.pocket_panel.visible
		or hand.sale_panel.visible or hud.camera_select.get_popup().visible or hud.style_select.get_popup().visible)


func _ready_sheep_at(cam: Camera3D, mp: Vector2):
	var best = null
	var best_d := 40.0
	for s in world.pasture.slots:
		if s == null or s.dead or not s.wool_ready:
			continue
		var d := cam.unproject_position(s.global_position + Vector3(0, 0.4, 0)).distance_to(mp)
		if d < best_d:
			best_d = d
			best = s
	return best


# ───────────────────────── 디버그 ─────────────────────────

func debug_gold() -> void:
	economy.debug_add_gold(100)
	toast("[디버그] +100G", Color(0.6, 1.0, 0.7))


func debug_start_wave() -> void:
	if session.state == SessionScript.State.PREP:
		session.start_wave()


func debug_force_dragon() -> void:
	if session.state == SessionScript.State.PREP:
		session.start_wave()
	if session.state == SessionScript.State.COMBAT and not dragon.is_present():
		dragon.summon()
		toast("[디버그] 용 강제 소환", Color(0.6, 1.0, 0.7))


func debug_damage_lodge() -> void:
	world.lodge.take_damage(50.0)


func debug_damage_player() -> void:
	player.take_damage(25.0)


func debug_kill_all() -> void:
	for e in get_tree().get_nodes_in_group("enemies"):
		e.take_damage(99999.0)


func debug_cards() -> void:
	for job in Cfg.JOB_CARDS:
		cards.add(job, 1, economy._pick_name())
	cards.add("forest_monster")
	cards.add("wool", 3)
	cards.add("timber", 10)
	cards.add("raw_meat", 2)
	cards.add("rabbit_pelt", 2)
	cards.add("treasure_chest", 1)
	cards.add("poison_mushroom", 2)
	cards.add("old_spellbook", 1)
	if wildlife != null:
		wildlife.spawn("rabbit", player.global_position + Vector3(4, 0, 2))
		wildlife.spawn("deer", player.global_position + Vector3(-5, 0, 3))
	for pair in Cfg.STARTER_CARDS:
		cards.add(pair[0], pair[1])
	toast("[디버그] 카드 지급", Color(0.6, 1.0, 0.7))


func debug_toggle_draw() -> void:
	world.debug_draw = not world.debug_draw
