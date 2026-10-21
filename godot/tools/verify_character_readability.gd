extends SceneTree
## F10 캐릭터 분리 시험(visual/character_readability.gd) 헤드리스 검증: 네 단계 각각의 외곽선·림·그림자·강조색 상태.
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_character_readability.gd

const R := preload("res://scripts/visual/character_readability.gd")
var passed := 0
var total := 0


func _initialize() -> void:
	create_timer(60.0, true, false, true).timeout.connect(func(): print("RESULT timeout"); quit(2))
	call_deferred("_run")


func check(ok: bool, label: String) -> void:
	total += 1
	if ok: passed += 1
	print(("PASS " if ok else "FAIL ") + label)


func _run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	for i in 10: await physics_frame
	var mod = game.find_child("CharacterReadability", true, false)
	check(mod != null, "F10 모듈이 main 아래에 붙음")
	if mod == null:
		print("RESULT %d/%d" % [passed, total]); quit(1); return
	mod.settings_path = "user://verify_readability.cfg"
	var p = game.player
	check(p.is_in_group(R.GROUP) and p.is_in_group(R.LEAD_GROUP), "플레이어가 대상·주인공 그룹에 있음")
	mod.set_mode("off", false)   # 사용자 설정에 저장된 단계와 무관하게 기존 상태에서 원래 그림자 값을 잰다
	var meshes: Array = R._meshes(p.visual)
	check(meshes.size() > 0, "플레이어 몸 메시 %d개" % meshes.size())
	var casts: Array = meshes.map(func(m): return m.cast_shadow)

	mod.set_mode("off", false)
	check(meshes.all(func(m): return m.material_overlay == null), "기존: 외곽선 없음")
	check(p.get_node_or_null("ReadabilityBlob") == null or not p.get_node("ReadabilityBlob").visible, "기존: 둥근 그림자 숨김")

	mod.set_mode("rim", false)
	check(meshes.all(func(m): return m.material_overlay == R.overlay()), "①: 모든 몸 메시에 외곽선+림")
	check(R.overlay().next_pass != null and (R.overlay().next_pass as ShaderMaterial).shader == R.RIM_SHADER, "①: 림이 외곽선 next_pass")
	check(meshes.map(func(m): return m.cast_shadow) == casts, "①: 실제 그림자는 그대로")

	mod.set_mode("rim_shadow", false)
	check(meshes.all(func(m): return m.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_OFF), "②: 몸 그림자 끔")
	check(p.get_node("ReadabilityBlob").visible, "②: 둥근 그림자 보임")
	var acc = p.get_node_or_null("ReadabilityAccent")
	check(acc == null or not acc.get_meta("parts")[1].visible, "②: 강조 빛은 아직 없음")

	mod.set_mode("all", false)
	acc = p.get_node_or_null("ReadabilityAccent")
	check(acc != null and acc.get_meta("parts").all(func(n): return n.visible), "③: 랜턴 빛망울·점광원 켬")
	var light = acc.get_meta("parts")[1] if acc != null else null
	check(light is OmniLight3D and str(light.get_parent().get_meta("part_group", "")) == "lantern", "③: 빛이 랜턴 피벗에 붙음")
	mod.refresh()
	check(R._meshes(p.visual).size() == meshes.size(), "③: 빛망울은 몸 메시 목록에 섞이지 않음")
	check(not R._meshes(p.visual).any(func(m): return m.name == "ReadabilityGlow"), "③: 빛망울에 외곽선 안 붙음")

	# 나중에 생긴 손님도 같은 상태로 맞춘다
	var Traveler := load("res://scripts/actors/traveler.gd")
	var t = Traveler.new()
	t.profile = {"character_id": "nib", "race": "goblin"}
	game.world.add_child(t)
	await process_frame
	mod.refresh()
	var tm: Array = R._meshes(t.visual)
	check(tm.size() > 0 and tm.all(func(m): return m.material_overlay == R.overlay()), "손님(니브)에 외곽선+림")
	check(t.get_node("ReadabilityBlob").visible and t.get_node_or_null("ReadabilityAccent") == null, "손님: 둥근 그림자만, 강조 빛은 주인공만")

	mod.set_mode("off", false)
	check(meshes.all(func(m): return m.material_overlay == null) and meshes.map(func(m): return m.cast_shadow) == casts, "기존으로 되돌리면 원래 그림자·재질 복구")
	check(not acc.get_meta("parts")[1].visible, "기존: 강조 빛 끔")

	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)
