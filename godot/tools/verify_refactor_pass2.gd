extends SceneTree
## 2026-10-21 리팩토링·2차 최적화가 결과를 바꾸지 않았는지 검증한다.
## - 공유 캐시: MoonSkin.flat_shared·Mats.unshaded_shared·Build.torus 가 같은 인자에 같은 자원을 주고, 값은 새로 만든 것과 같다.
## - 종족 표: GuestProfiles.race_of 가 예전 선형 탐색과 같다.
## - 카드 묶음 모듈: 넷 다 card_module 을 상속하고, 판정기 분기표가 모듈 action 과 맞는다.
## - 손패·주머니 세기: pocket_size·hand_full·eligible_pocket_empty 가 배열로 센 예전 값과 같다.
## - 종족 수: distinct_races(true) 가 roster() 로 센 예전 값과 같다.
## - 거미 다리: 캐시한 엉덩이·도달 거리·서 있는 발끝이 예전 식과 같다.
## - 낮 주기: 값이 그대로면 조명을 다시 쓰지 않고, 화면 스타일을 다시 적용하면 다음 프레임에 시각 조명을 다시 깐다.
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_refactor_pass2.gd

const MoonSkin := preload("res://scripts/ui/moon/moon_skin.gd")
const Mats := preload("res://scripts/visual/mats.gd")
const Build := preload("res://scripts/visual/build.gd")
const GuestProfiles := preload("res://scripts/ui/guest_profiles.gd")
const CardModule := preload("res://scripts/game/card_module.gd")
const Resolver := preload("res://scripts/game/card_use_resolver.gd")
const SpiderVisual := preload("res://scripts/visual/spider_visual.gd")
const Styles := preload("res://scripts/visual/screen_style.gd")

var failures := 0
var total := 0
var game


func check(name: String, ok: bool, detail := "") -> void:
	total += 1
	if not ok:
		failures += 1
	print(("PASS " if ok else "FAIL ") + name + ("  — " + detail if detail != "" else ""))


func _initialize() -> void:
	create_timer(150.0, true, false, true).timeout.connect(func(): print("FAIL timeout"); quit(2))
	call_deferred("_run")


func ticks(count: int) -> void:
	for i in count:
		await physics_frame
	await process_frame


func _run() -> void:
	_check_shared_caches()
	_check_race_index()
	_check_spider_legs()
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await ticks(6)
	_check_card_modules()
	_check_inventory_counts()
	_check_distinct_races()
	await _check_day_cycle()
	print("RESULT %d/%d" % [total - failures, total])
	quit(1 if failures > 0 else 0)


func _check_shared_caches() -> void:
	var a := MoonSkin.flat_shared(Color(0.1, 0.2, 0.3, 0.8), Color(1, 1, 1, 0.5), 8, 0, 1)
	var b := MoonSkin.flat_shared(Color(0.1, 0.2, 0.3, 0.8), Color(1, 1, 1, 0.5), 8, 0, 1)
	var fresh := MoonSkin.flat(Color(0.1, 0.2, 0.3, 0.8), Color(1, 1, 1, 0.5), 8, 0, 1)
	check("flat_shared: 같은 인자면 같은 상자", a == b)
	check("flat_shared: 값이 flat() 과 같다", a.bg_color == fresh.bg_color and a.border_color == fresh.border_color
		and a.corner_radius_top_left == fresh.corner_radius_top_left and a.border_width_left == fresh.border_width_left
		and a.content_margin_left == fresh.content_margin_left and a.anti_aliasing == fresh.anti_aliasing)
	check("flat_shared: 다른 인자면 다른 상자", MoonSkin.flat_shared(Color(0.1, 0.2, 0.3, 0.8), Color(1, 1, 1, 0.5), 9, 0, 1) != a)
	var m1 := Mats.unshaded_shared(Color(0.55, 1.0, 0.45, 0.7), true, true)
	var m2 := Mats.unshaded_shared(Color(0.55, 1.0, 0.45, 0.7), true, true)
	var m3 := Mats.unshaded(Color(0.55, 1.0, 0.45, 0.7), true, true)
	check("unshaded_shared: 같은 재질을 같이 쓴다", m1 == m2)
	check("unshaded_shared: 설정이 unshaded() 와 같다", m1.albedo_color == m3.albedo_color and m1.transparency == m3.transparency
		and m1.blend_mode == m3.blend_mode and m1.shading_mode == m3.shading_mode and m1.cull_mode == m3.cull_mode)
	check("unshaded(): 고쳐 쓰는 곳용은 여전히 새 재질", Mats.unshaded(Color.WHITE) != Mats.unshaded(Color.WHITE))
	var parent := Node3D.new()
	var t1 := Build.torus(parent, 0.45, 0.58, Vector3.ZERO, m1)
	var t2 := Build.torus(parent, 0.45, 0.58, Vector3(1, 0, 0), m1)
	var t3 := Build.torus(parent, 0.36, 0.46, Vector3.ZERO, m1)
	var tm := t1.mesh as TorusMesh
	check("torus: 같은 반지름은 메시를 같이 쓴다", t1.mesh == t2.mesh and t1.mesh != t3.mesh)
	check("torus: 메시 설정 그대로", is_equal_approx(tm.inner_radius, 0.45) and is_equal_approx(tm.outer_radius, 0.58) and tm.rings == 16 and tm.ring_segments == 8)
	check("torus: 재질은 인스턴스 덮어쓰기", t1.material_override == m1 and t2.position == Vector3(1, 0, 0))
	parent.free()


func _check_race_index() -> void:
	var same := true
	var people := ["__nobody__", ""]
	for p in GuestProfiles.CATALOG:
		people.append(p["person"])
	for person in people:
		var old := "human"
		for p in GuestProfiles.CATALOG:
			if p["person"] == person:
				old = p.get("race", "human")
				break
		if GuestProfiles.race_of(person) != old:
			same = false
			print("  다른 종족: ", person)
	check("race_of 표가 예전 선형 탐색과 같다(%d명)" % people.size(), same)


func _check_spider_legs() -> void:
	var holder := CharacterBody3D.new()
	root.add_child(holder)
	var v: Node3D = SpiderVisual.new()
	holder.add_child(v)
	v.set_process(false)
	holder.position = Vector3(3.0, 0.0, -2.0)
	holder.rotation.y = 0.7
	holder.scale = Vector3.ONE * 1.3
	var same := true
	for id in SpiderVisual.LEG_ORDER:
		var leg: Dictionary = v._rig["legs"][id]
		var j0: Vector3 = leg["joints"][0]
		var tip: Vector3 = leg["joints"][4]
		var st: Array = SpiderVisual.STANCE[id]
		var off := Basis(SpiderVisual.UP, deg_to_rad(st[0])) * Vector3(tip.x - j0.x, 0.0, tip.z - j0.z)
		off += off.normalized() * float(st[1])
		var home := Vector3(j0.x + off.x, 0.0, j0.z + off.z)
		var hip: Vector3 = v.global_transform * (j0 - Vector3(0, SpiderVisual.GROUND_DROP, 0))
		var hy: float = j0.y - SpiderVisual.GROUND_DROP
		var reach := sqrt(maxf(pow(float(leg["length"]) * 0.95, 2.0) - hy * hy, 0.01)) * v.global_transform.basis.get_scale().x
		if v._home_local(id) != home or v._hip_world(id) != hip or v._reach(id) != reach:
			same = false
			print("  다른 다리: ", id)
	check("거미 다리 상수 캐시가 예전 식과 같다(위치·회전·축척을 바꾼 뒤)", same)
	v.set_blink(0.0, 0.0)
	v.set_blink(0.4, 0.0)
	check("거미 눈 깜박임 값이 바뀌면 보낸다", v.blink_values().is_equal_approx(Vector2(0.4, 0.0)))
	v.set_blink(0.4, 0.0)
	check("같은 값은 그대로", v.blink_values().is_equal_approx(Vector2(0.4, 0.0)))
	holder.free()


func _check_card_modules() -> void:
	var ok := true
	for m in Resolver.CARD_MODULES:
		var module = game.get(m[0])
		if module == null or not (module.get_script() as Script).get_base_script() == CardModule:
			ok = false
			print("  모듈 상속 아님: ", m[0])
	check("카드 묶음 모듈 넷이 card_module 을 상속한다", ok)
	check("판정기 분기표 action 이 모듈과 같다", Resolver.CARD_MODULES == [["goblin", "goblin"], ["race_cards", "race"], ["undead", "undead"], ["tavern", "tavern"]])
	check("모듈 _fail 이 예전 모양", game.goblin._fail("x", Vector3.ONE) == {"ok": false, "reason": "x", "pos": Vector3.ONE})


func _old_eligible_empty(cards) -> bool:
	var ph: String = cards.current_phase()
	return cards.pocket().filter(func(e): return cards.fits_phase(e["id"], ph)).is_empty()


func _check_inventory_counts() -> void:
	var cards = game.cards
	var ok := true
	var ids := ["timber", "wool", "poison_mushroom", "old_spellbook", "lamb", "meat_stew"]
	for round in 3:
		if cards.pocket_size() != cards.pocket().size() or cards.hand_full() != (cards.hand().size() >= preload("res://scripts/config.gd").HAND_VISIBLE) \
				or cards.eligible_pocket_empty() != _old_eligible_empty(cards):
			ok = false
			print("  다른 값(round %d): pocket=%d/%d" % [round, cards.pocket_size(), cards.pocket().size()])
		for id in ids:
			cards.add(id, 1, "", "pocket" if round % 2 == 0 else "")
	check("pocket_size·hand_full·eligible_pocket_empty 가 배열로 센 값과 같다", ok)


func _check_distinct_races() -> void:
	var rc = game.race_cards
	# 서로 다른 종족 셋(같은 종족 둘 포함)을 용병으로 세운 뒤 비교한다
	var people := []
	var races_seen := {}
	for p in GuestProfiles.CATALOG:
		var race: String = p.get("race", "human")
		if people.size() < 4 and (not races_seen.has(race) or people.size() == 3):
			people.append(p["person"])
			races_seen[race] = true
	for i in people.size():
		game.contracts.spawn_guard("merc", people[i], Vector3(2.0 + i, 0, 2.0), null, "warrior")
	var seen := {}
	for r in rc.roster():
		if r.has("ally") and r["race"] != "":
			seen[r["race"]] = true
	check("distinct_races(true) 가 roster() 로 센 값과 같다", rc.distinct_races(true) == seen.size(), "%d vs %d" % [rc.distinct_races(true), seen.size()])


func _check_day_cycle() -> void:
	var dc = game.world.day_cycle
	dc.mode = "night"
	await ticks(3)
	var sun_e: float = game.world.sun.light_energy
	game.world.sun.light_energy = 123.0   # 바뀌지 않은 시각이면 낮 주기가 덮어쓰지 않는다
	await ticks(2)
	var skipped: bool = game.world.sun.light_energy == 123.0 or game.world.hazard_regions.influence > 0.0
	check("값이 그대로면 낮 주기가 조명을 다시 쓰지 않는다", skipped, "energy=%.2f" % game.world.sun.light_energy)
	Styles.apply(game.world, Styles.current_id)
	await ticks(2)
	check("화면 스타일 재적용 뒤 시각 조명을 다시 깐다", is_equal_approx(game.world.sun.light_energy, sun_e), "%.3f vs %.3f" % [game.world.sun.light_energy, sun_e])
	dc.mode = "day"
	await ticks(2)
	var day_e: float = game.world.sun.light_energy
	dc.refresh()
	check("모드가 바뀌면 다시 깔고, refresh() 직접 호출과 같은 값", is_equal_approx(game.world.sun.light_energy, day_e) and not is_equal_approx(day_e, sun_e),
		"day=%.3f night=%.3f" % [day_e, sun_e])
	dc.mode = "auto"
