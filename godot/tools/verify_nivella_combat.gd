extends SceneTree
## 니벨라 전투·보스 체력바 헤드리스 검증: 등장 차오름, 마녀 평타 사거리, 지연 게이지, 3단 스톡·격노·얼음 갑옷,
## 공격 패턴 4종의 예고·적중·회피, 거미줄 둔화, 처치.
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_nivella_combat.gd
const Sites := preload("res://scripts/world/hazard_sites.gd")

var passed := 0
var total := 0
var game


func _initialize() -> void:
	create_timer(180.0, true, false, true).timeout.connect(func(): print("FAIL timeout"); quit(1))
	call_deferred("_run")


func check(ok: bool, label: String) -> void:
	total += 1
	if ok:
		passed += 1
		print("PASS ", label)
	else:
		print("FAIL ", label)


func frames(n: int) -> void:
	for i in n:
		await physics_frame
	await process_frame


func seconds(s: float) -> void:
	var end := Time.get_ticks_msec() + int(s * 1000.0)
	while Time.get_ticks_msec() < end:
		await process_frame


func flat(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()


func _run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await frames(10)
	game.session.set_process(false)
	var room = game.world.boss_room
	var boss = room.combat
	var bar = room.hp_bar
	var p = game.player
	p.set_physics_process(false)
	p.max_hp = 5000.0
	p.hp = 5000.0
	check(boss != null and not boss.is_in_group("enemies"), "보스는 깨어나기 전엔 표적이 아니다")
	check(bar != null and bar.alpha == 0.0, "체력바는 처음엔 숨어 있다")
	# 진입 → 포효 정점에서 체력바 등장
	p.global_position = room.global_position + Vector3(3.0, 0, 9.0)
	await seconds(2.25)
	check(room.phase == room.Phase.ROAR and bar.shown, "포효 정점에 체력바가 나타난다")
	await seconds(0.6)
	var mid_fill: float = bar.main_hp
	check(mid_fill > 0.0 and mid_fill < boss.max_hp, "게이지가 비어 있다가 차오르는 중 (%.0f/%.0f)" % [mid_fill, boss.max_hp])
	await seconds(1.3)
	check(bar.intro_done and absf(bar.main_hp - boss.max_hp) < 1.0, "등장 차오름이 끝나면 가득 찬다")
	await seconds(1.2)
	check(room.phase == room.Phase.WATCH and boss.active and boss.is_in_group("enemies"), "포효가 끝나면 전투 시작(표적이 됨)")
	# 마녀 평타: 보스 몸 가장자리 기준 사거리
	boss.auto_patterns = false
	var to_boss: Vector3 = (boss.global_position - p.global_position)
	to_boss.y = 0
	p.global_position = boss.global_position - to_boss.normalized() * (boss.hit_radius + 2.5)
	await frames(3)
	check(p._edge_dist(boss) <= p.attack_range() and p._has_los(boss), "보스 몸 가장자리 2.5m 에서 평타 사거리·시야 안 (중심까지 %.1fm)" % flat(p.global_position, boss.global_position))
	check(p._nearest_enemy(p.attack_range()) == boss, "마녀가 보스를 스스로 표적으로 잡는다")
	# 지연 게이지
	boss.take_damage(40.0)
	await seconds(0.12)
	check(bar.ghost_hp - boss.hp > 20.0 and absf(bar.main_hp - boss.hp) < 6.0, "주 게이지는 바로, 흰 잔상은 뒤처져 남는다 (잔상 %.0f / 체력 %.0f)" % [bar.ghost_hp, boss.hp])
	check(bar._shake > 1.0 and bar._accum >= 40.0, "피격 흔들림·누적 대미지 표시")
	await seconds(1.2)
	check(absf(bar.ghost_hp - boss.hp) < 1.0, "잔상이 따라 내려와 정착한다")
	# 3단 스톡
	check(boss.stock_left() == 3 and not boss.enraged, "처음은 3단(보라)")
	var sh0: int = bar.shatters
	while boss.stock_left() == 3:
		boss.take_damage(60.0)
	await frames(2)
	check(boss.stock_left() == 2 and boss.enraged and bar.shatters == sh0 + 1, "첫 단이 깨지면 바가 부서지고 격노")
	while boss.stock_left() == 2:
		boss.take_damage(60.0)
	await frames(2)
	check(boss.stock_left() == 1 and boss.shield > 0.0, "둘째 단이 깨지면 얼음 갑옷 실드")
	var hp_before: float = boss.hp
	boss.take_damage(50.0)
	check(boss.hp == hp_before and boss.shield < boss.SHIELD_MAX, "실드가 먼저 피해를 받는다")
	var sh1: int = bar.shatters
	boss.take_damage(100.0)
	check(boss.shield == 0.0 and boss.hp < hp_before and bar.shatters == sh1 + 1, "실드 파괴 연출 뒤 체력이 깎인다")
	await seconds(1.5)
	# 공격 패턴(전투 루프를 멈추고 하나씩 시전)
	boss.auto_patterns = false
	await seconds(3.0)
	var dir: Vector3 = (p.global_position - boss.global_position)
	dir.y = 0
	dir = dir.normalized()
	# 1. 내려찍기: 예고 원 안에 서 있으면 맞고
	p.global_position = boss.global_position + dir * (boss.hit_radius + 2.5)
	var hp0: float = p.hp
	boss._stomp(p)
	await frames(2)
	check(_count("NivellaAttackTelegraph") >= 1, "내려찍기 예고 장판")
	await seconds(boss.STOMP.time * boss._k() + 0.25)
	check(p.hp < hp0, "내려찍기: 장판 안에 있으면 맞는다 (-%.0f)" % (hp0 - p.hp))
	# 장판이 깔린 뒤 피하면 안 맞는다
	await seconds(1.0)
	hp0 = p.hp
	boss._stomp(p)
	await frames(2)
	p.global_position = boss.global_position + dir.rotated(Vector3.UP, PI * 0.5) * (boss.hit_radius + 9.0)
	await seconds(boss.STOMP.time * boss._k() + 0.25)
	check(p.hp == hp0, "내려찍기: 장판 밖으로 피하면 안 맞는다")
	# 2. 얼음 가시 줄
	await seconds(0.8)
	p.global_position = boss.global_position + dir * (boss.hit_radius + 7.0)
	hp0 = p.hp
	boss._spikes(p)
	await seconds(boss.SPIKES.time * boss._k() + 0.9)
	check(_count("NivellaAttackSpike") >= 0 and p.hp < hp0 and hp0 - p.hp <= boss.SPIKES.damage + 0.1, "얼음 가시: 줄 위에 있으면 한 번만 맞는다 (-%.0f)" % (hp0 - p.hp))
	# 3. 거미줄 투척 + 둔화
	await seconds(0.8)
	hp0 = p.hp
	boss._web(p)
	await seconds(boss.WEB.flight * boss._k() + 0.15)
	check(p.hp < hp0 and p.slow_factor() < 1.0, "거미줄: 맞으면 피해 + 둔화 (속도 x%.2f)" % p.slow_factor())
	check(boss._patches.size() >= 1, "떨어진 자리에 거미줄이 남는다")
	# 4. 눈보라 폭발
	await seconds(2.6)
	p.global_position = boss.global_position + dir * (boss.hit_radius + 4.0)
	hp0 = p.hp
	boss._nova()
	check(boss.visual.is_roaring(), "눈보라 폭발: 포효 자세")
	await seconds(boss.NOVA.time * boss._k() + 0.2)
	check(p.hp < hp0, "눈보라 폭발: 반경 안이면 맞는다 (-%.0f)" % (hp0 - p.hp))
	check(boss.casts.stomp >= 2 and boss.casts.spikes >= 1 and boss.casts.web >= 1 and boss.casts.nova >= 1, "패턴 4종 모두 시전됨")
	# 자동 전투 루프가 스스로 패턴을 고른다
	await seconds(3.0)
	var before_casts: int = boss.casts.stomp + boss.casts.spikes + boss.casts.web + boss.casts.nova
	boss.auto_patterns = true
	await seconds(7.0)
	var after_casts: int = boss.casts.stomp + boss.casts.spikes + boss.casts.web + boss.casts.nova
	check(after_casts >= before_casts + 2, "전투 중엔 스스로 패턴을 이어 쓴다 (+%d)" % (after_casts - before_casts))
	# 빈사 박동
	boss.auto_patterns = false
	boss.hp = boss.max_hp * 0.2
	await seconds(1.2)
	var peak_beat := 0.0
	for i in 30:
		peak_beat = maxf(peak_beat, bar._beat)
		await seconds(0.04)
	check(peak_beat > 0.3, "빈사(25%%↓) 심장 박동 (%.2f)" % peak_beat)
	# 처치
	while not boss.dead:
		boss.take_damage(150.0)
	await seconds(0.3)
	check(boss.dead and not boss.is_in_group("enemies") and room.phase == room.Phase.DEAD, "처치: 표적에서 빠지고 둥지가 잠잠해진다")
	await seconds(3.5)
	check(bar.alpha < 0.05, "처치 뒤 체력바가 사라진다")
	# 나갔다 들어와도 다시 깨어나지 않는다
	p.global_position = Vector3(0, 0, -23.0)
	await seconds(1.0)
	p.global_position = room.global_position + Vector3(3.0, 0, 9.0)
	await seconds(1.5)
	check(room.phase == room.Phase.DEAD and not boss.active, "쓰러진 뒤엔 다시 포효하지 않는다")
	print("RESULT %d/%d" % [passed, total])
	quit(0 if passed == total else 1)


func _count(prefix: String) -> int:
	var n := 0
	for c in game.world.get_children():
		if str(c.name).begins_with(prefix):
			n += 1
	for c in game.world.boss_room.get_children():
		if str(c.name).begins_with(prefix):
			n += 1
	return n
