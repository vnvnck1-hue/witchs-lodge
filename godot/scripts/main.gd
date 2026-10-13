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
const CardsScript := preload("res://scripts/game/card_inventory.gd")
const ContractsScript := preload("res://scripts/game/contract_director.gd")
const ResolverScript := preload("res://scripts/game/card_use_resolver.gd")

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


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--style=") and arg.trim_prefix("--style=") in ScreenStyle.IDS:
			ScreenStyle.current_id = arg.trim_prefix("--style=")
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

	cards = CardsScript.new()
	cards.game = self
	add_child(cards)
	contracts = ContractsScript.new()
	contracts.game = self
	add_child(contracts)
	resolver = ResolverScript.new()
	resolver.game = self
	add_child(resolver)
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

	hud = HudScript.new()
	hud.game = self
	add_child(hud)

	session.start()

	var shot := ShotScript.parse_args()
	if not shot.is_empty():
		var runner := ShotScript.new()
		runner.game = self
		runner.opts = shot
		add_child(runner)


func toast(text: String, color := Color.WHITE) -> void:
	if hud != null:
		hud.toast(text, color)


func on_sheep_died() -> void:
	sheep_lost += 1
	toast("양 한 마리를 잃었습니다", Color(1.0, 0.65, 0.65))


func _unhandled_input(event: InputEvent) -> void:
	var mb := event as InputEventMouseButton
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
	var ground := from + dir * t
	var nav_map := get_world_3d().navigation_map
	var dest := NavigationServer3D.map_get_closest_point(nav_map, ground)
	dest.y = 0.0
	player.set_destination(dest)
	world.show_click_marker(dest)


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
	cards.add("axe_mercenary", 1, economy._pick_name())
	cards.add("forest_monster")
	cards.add("wool", 3)
	cards.add("timber", 10)
	toast("[디버그] 카드 지급", Color(0.6, 1.0, 0.7))


func debug_toggle_draw() -> void:
	world.debug_draw = not world.debug_draw
