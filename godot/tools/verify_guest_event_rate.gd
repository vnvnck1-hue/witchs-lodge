extends SceneTree
## 인물 대화 이벤트 빈도: 이야기를 아직 안 들은 입실 손님 중 GUEST_STORY_EVERY 명당 1명만 말 걸기 알림이 뜬다.
const Profiles := preload("res://scripts/ui/guest_profiles.gd")
const Cfg := preload("res://scripts/config.gd")
var failures := 0
var total := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	total += 1
	print("PASS " if ok else "FAIL ", message)
	if not ok: failures += 1

func arrive(events, profiles: Array) -> Array:
	var uids: Array = []
	var batch: Array = []
	for source in profiles:
		var profile: Dictionary = source.duplicate(true)
		profile["character_id"] = profile["id"]
		batch.append(profile)
	events._on_batch(batch)
	for profile in batch:
		events.admit(profile)
		uids.append(int(profile.visit_uid))
	for uid in uids: events.visit(uid).ready_at = -1.0
	events._process(0.0)
	return uids

func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	for i in 4: await process_frame
	var events = game.guest_events
	var catalog: Array = Profiles.all_profiles()
	check(Cfg.GUEST_STORY_EVERY == 2, "config halves dialogue events (every 2nd candidate)")
	var uids := arrive(events, catalog)
	var offered: int = uids.filter(func(uid): return events.visit(uid).ready).size()
	var expected := int(ceil(catalog.size() / float(Cfg.GUEST_STORY_EVERY)))
	check(offered == expected, "%d명 중 %d명만 대화 이벤트 (기대 %d)" % [catalog.size(), offered, expected])
	check(events.pending_events().size() == offered, "pending list matches offered events")
	check(events.visit(uids[0]).ready and not events.visit(uids[1]).ready, "alternates starting with first guest")
	check(events.visit(uids[1]).read and events.can_talk(uids[1]), "skipped guest has no notice but can still be talked to in lodge")
	# 건너뛴 손님은 이야기를 완료하지 않았으므로 다음 방문에 다시 후보가 된다.
	var skipped_id: String = events.visit(uids[1]).profile.character_id
	check(not events.completed_stories.has(skipped_id), "skipped guest's story stays unheard for later visits")
	for uid in uids: events._on_departed(events.visit(uid).profile, "퇴실")
	var again := arrive(events, [catalog[1]])
	var again_more := arrive(events, [catalog[3]])
	check([again[0], again_more[0]].filter(func(uid): return events.visit(uid).ready).size() == 1, "revisiting unheard guests still follows the 1-in-2 rate")
	print("RESULT %d/%d" % [total - failures, total])
	quit(0 if failures == 0 else 1)
