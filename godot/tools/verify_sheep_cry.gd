extends SceneTree
## 양 울음 반복 버그: 계속 맞거나 위협이 범위를 들락날락해도 울음이 적당한 간격(양마다 1.5초·도망 4초·무리 0.5초)으로만 나는지,
## 쓰러지는 마지막 한 대는 항상 우는지 SoundBank.history 로 센다.
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_sheep_cry.gd

const Sheep := preload("res://scripts/actors/sheep.gd")

var failures := 0
var total := 0


func _initialize() -> void:
	create_timer(90.0, true, false, true).timeout.connect(func(): print("FAIL timeout"); quit(1))
	_run.call_deferred()


func check(name: String, ok: bool, detail := "") -> void:
	total += 1
	if not ok:
		failures += 1
	print(("PASS " if ok else "FAIL ") + name + ("  — " + detail if detail != "" else ""))


func count(sb, event: String, from: int) -> int:
	return sb.history.slice(from).count(event)


## seconds 동안 매 프레임 hit 를 부른다(실제 시간 기준).
func hammer(seconds: float, hit: Callable) -> void:
	var end := Time.get_ticks_msec() + int(seconds * 1000.0)
	while Time.get_ticks_msec() < end:
		hit.call()
		await process_frame


func _run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	current_scene = game  # Sfx 는 current_scene.sounds 를 찾는다
	for i in 8:
		await process_frame
	var sb = game.sounds
	var herd: Array = get_nodes_in_group("sheep").filter(func(s): return s is Sheep and not s.dead)
	check("양 두 마리 이상", herd.size() >= 2, str(herd.size()))
	if herd.size() < 2:
		print("RESULT %d/%d" % [total - failures, total])
		quit(1)
		return
	var a = herd[0]
	var b = herd[1]
	for s in [a, b]:
		s.hp = 1.0e6
		s.max_hp = 1.0e6
	await create_timer(0.6, true, false, true).timeout

	# 한 마리를 3초 동안 매 프레임 때린다: 예전엔 100ms 마다(약 30번) 울었다
	var h: int = sb.history.size()
	await hammer(3.0, func(): a.take_damage(0.01))
	var n: int = count(sb, "sheep_hurt", h)
	check("계속 맞아도 1.5초 간격으로만 운다(3초에 2~3번)", n >= 2 and n <= 3, "%d번" % n)

	# 두 마리가 같이 맞으면 무리 간격(0.5초)으로 울음이 겹치지 않는다
	await create_timer(1.6, true, false, true).timeout
	h = sb.history.size()
	var stamps: Array = []
	var seen := [0]  # 지금까지 센 sheep_hurt 수. 람다는 지역 변수를 값으로 잡으므로 배열에 둔다
	await hammer(1.0, func():
		a.take_damage(0.01)
		b.take_damage(0.01)
		if count(sb, "sheep_hurt", h) > seen[0]:
			stamps.append(Time.get_ticks_msec())
			seen[0] = count(sb, "sheep_hurt", h))
	n = count(sb, "sheep_hurt", h)
	var min_gap := 100000
	for i in range(1, stamps.size()):
		min_gap = mini(min_gap, stamps[i] - stamps[i - 1])
	check("두 마리 동시 피격: 1초에 두 번 이하로 운다", n >= 1 and n <= 2, "%d번" % n)
	check("울음 사이 최소 0.5초", stamps.size() < 2 or min_gap >= 480, "%dms" % min_gap)

	# 도망 울음: 위협이 들락날락해도 4초에 한 번
	await create_timer(0.6, true, false, true).timeout
	h = sb.history.size()
	a._flee_cry_ms = -100000
	for i in 6:  # 위협이 0.3초마다 범위 밖으로 나갔다 다시 들어오는 상황
		a._cry_flee()
		await create_timer(0.3, true, false, true).timeout
	check("도망 울음은 들락날락해도 한 번", count(sb, "sheep_flee", h) == 1, "%d번" % count(sb, "sheep_flee", h))

	# 쓰러지는 한 대는 간격과 상관없이 운다
	a.hp = 1.0
	a.take_damage(0.01)  # 방금 울게 해 간격(1.5초) 안으로
	await create_timer(0.2, true, false, true).timeout  # SoundBank 같은 소리 100ms 제한은 피한다
	h = sb.history.size()
	a.take_damage(5.0)
	check("마지막 한 대는 간격 무시하고 운다", count(sb, "sheep_hurt", h) == 1 and a.dead)

	# 실제 밤 전투: 괴물이 모두 양을 노리고, 쫓긴 양이 울타리에 몰리는 상황.
	# 예전엔 몰린 양이 매 프레임 '도착'해 풀 뜯는 울음(sheep_bleat)을 0.1초마다 냈다.
	for s in get_nodes_in_group("sheep"):
		s.hp = 1.0e6  # 오래 버티며 계속 쫓기게
	game.session.prep_elapsed = preload("res://scripts/config.gd").PREP_TIME - 0.05
	await process_frame
	h = sb.history.size()
	var fled := [false]
	var stamps2: Array = []
	var seen2 := [0]
	var end := Time.get_ticks_msec() + 24000
	while Time.get_ticks_msec() < end:
		await process_frame
		for m in get_nodes_in_group("enemies"):
			if "goal" in m and m.goal != 1:
				m.goal = 1  # Goal.SHEEP
		for s in get_nodes_in_group("sheep"):
			if s._fleeing:
				fled[0] = true
		var c := 0
		for ev in sb.history.slice(h):
			if str(ev).begins_with("sheep_"):
				c += 1
		while seen2[0] < c:
			stamps2.append(Time.get_ticks_msec())
			seen2[0] += 1
	var bleats: int = count(sb, "sheep_bleat", h)
	var worst := 0
	for i in stamps2.size():
		var n2 := 0
		for j in range(i, stamps2.size()):
			if stamps2[j] - stamps2[i] < 2000:
				n2 += 1
		worst = maxi(worst, n2)
	check("밤 전투: 양이 실제로 쫓김", fled[0])
	# 쫓기지 않는 양은 여전히 가끔(6초 간격) 풀 뜯으며 울 수 있다. 예전 버그는 몰린 뒤 1초에 열 번씩 울었다.
	check("전투 중 풀 뜯는 울음은 드물게(24초에 5번 이하)", bleats <= 5, "%d번" % bleats)
	check("양 울음은 2초에 4번 이하", worst <= 4, "최대 %d번 / 전체 %d번" % [worst, stamps2.size()])

	print("RESULT %d/%d" % [total - failures, total])
	quit(1 if failures > 0 else 0)
