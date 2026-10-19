extends Node
## 현재 방문과 대화 이벤트의 단일 기록. 입실 연출 후 말 걸기를 예약하고, 퇴실 시 미완료 알림을 정리한다.
const Dialogues := preload("res://scripts/game/guest_dialogues.gd")
const Cfg := preload("res://scripts/config.gd")
signal changed
signal admitted(profile: Dictionary)
var game
var visits: Array = []
var history: Array = []
var completed_stories: Dictionary = {}
var _next_uid := 1
var _story_candidates := 0  # 아직 이야기를 안 들은 입실 손님 수. GUEST_STORY_EVERY 명마다 한 번만 이벤트

func _ready() -> void:
	name = "GuestEvents"
	game.economy.batch_arrived.connect(_on_batch)
	game.economy.guest_departed.connect(_on_departed)

func _on_batch(profiles: Array) -> void:
	for profile in profiles:
		profile["visit_uid"] = _next_uid
		visits.append({"uid": _next_uid, "profile": profile.duplicate(true), "day": game.session.day(),
			"present": true, "admitted": false, "ready": false, "read": false, "ready_at": -1.0,
			"status": "도착 중", "story": Dialogues.story(profile["character_id"])})
		_next_uid += 1
		if OS.get_cmdline_user_args().has("--guest-intros=off"): admit(profile)
	changed.emit()

func visit(uid: int) -> Dictionary:
	for entry in visits:
		if entry.uid == uid: return entry
	return {}

func admit(profile: Dictionary) -> void:
	var entry := visit(int(profile.get("visit_uid", -1)))
	if entry.is_empty() or entry.admitted or not entry.present: return
	entry.admitted = true
	entry.status = "투숙 중"
	entry.ready_at = game.session.play_time + 2.0
	admitted.emit(profile)
	changed.emit()

func _process(_delta: float) -> void:
	if game.session.state != 0: return
	var updated := false
	for entry in visits:
		if entry.present and entry.admitted and not entry.ready and not entry.read and entry.ready_at <= game.session.play_time:
			if wolf_story_available(entry):
				# 늑대의 피(docs/wolf-blood-event-design.md §2): 한 판 한 번뿐인 특별 이야기는 표본 추출을 건너뛰고 항상 말을 건다
				entry.story = Dialogues.wolf_story()
				entry.ready = true
				game.sounds.play("story_ready")
			elif completed_stories.has(entry.profile.character_id):
				entry.read = true
			elif _story_candidates % Cfg.GUEST_STORY_EVERY != 0:
				_story_candidates += 1
				entry.read = true
			else:
				_story_candidates += 1
				entry.ready = true
				game.sounds.play("story_ready")
			updated = true
	if updated: changed.emit()

func _on_departed(profile: Dictionary, reason: String) -> void:
	var entry := visit(int(profile.get("visit_uid", -1)))
	if entry.is_empty() or not entry.present: return
	entry.present = false
	entry.ready = false
	entry.status = reason
	changed.emit()

func current_guests() -> Array:
	return visits.filter(func(entry): return entry.present)

func pending_events() -> Array:
	return visits.filter(func(entry): return entry.present and entry.admitted and entry.ready and not entry.read)

func can_talk(uid: int) -> bool:
	var entry := visit(uid)
	return not entry.is_empty() and entry.present and entry.admitted and game.session.state == 0

## 늑대의 피 이벤트 조건: 파르그(늑대 수인)가 묵는 중, 목장에 어른 검은 양이 있고, 이번 판에 아직 늑대의 피를 받지 않았을 때.
func wolf_story_available(entry: Dictionary) -> bool:
	if entry.is_empty() or str(entry.profile.get("character_id", "")) != "fargh": return false
	var moon = game.get("moon_powers")
	if moon == null or moon.blood_given: return false
	var pasture = game.world.pasture if game.get("world") != null else null
	return pasture != null and pasture.has_method("black_sheep_count") and pasture.black_sheep_count() > 0

## 선택지의 효과(지금은 "wolf_blood"뿐): 검은 양 한 마리를 내주고 늑대의 피 카드를 받는다. 실패(양이 없음)면 false.
func apply_effect(uid: int, effect: String) -> bool:
	var entry := visit(uid)
	# 용병 이벤트(고블린 카드 v1, scripts/game/merc_events.gd): "merc:..." 효과는 그 모듈이 처리한다
	if not entry.is_empty() and effect.begins_with("merc:") and game.get("merc_events") != null:
		var ok: bool = game.merc_events.apply_effect(entry, effect)
		if ok: changed.emit()
		return ok
	if entry.is_empty() or effect != "wolf_blood": return false
	var moon = game.get("moon_powers")
	if moon == null or moon.blood_given: return false
	if not game.world.pasture.take_black_sheep(): return false
	moon.blood_given = true
	entry["wolf_accepted"] = true
	var zone: String = game.cards.add("wolf_blood", 1)
	game.toast("파르그에게 검은 양 한 마리를 내주고 '늑대의 피' 카드를 받았습니다%s" % (" (손패가 가득 차 주머니로)" if zone == "pocket" else ""), Color(0.9, 0.7, 0.8))
	game.sounds.play("mon_drop")
	changed.emit()
	return true

func complete(uid: int, choice: String, transcript: Array) -> bool:
	var entry := visit(uid)
	if entry.is_empty() or not entry.present or entry.get("completed_this_visit", false): return false
	entry.read = true
	entry.ready = false
	entry["completed_this_visit"] = true
	# 늑대의 피 이야기는 파르그의 평소 이야기를 소모하지 않는다. 거절했으면 다음 방문 때 다시 묻는다.
	# 용병 이벤트(special "merc")도 그 인물의 평소 손님 이야기를 소모하지 않는다
	if entry.story.get("special", "") == "":
		completed_stories[entry.profile.character_id] = true
	history.append({"uid": uid, "person": entry.profile.person, "day": entry.day, "title": entry.story.title,
		"choice": choice, "transcript": transcript.duplicate(true)})
	changed.emit()
	return true
