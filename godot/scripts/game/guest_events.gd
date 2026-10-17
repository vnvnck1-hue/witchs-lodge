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
			if completed_stories.has(entry.profile.character_id):
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

func complete(uid: int, choice: String, transcript: Array) -> bool:
	var entry := visit(uid)
	if entry.is_empty() or not entry.present or entry.get("completed_this_visit", false): return false
	entry.read = true
	entry.ready = false
	entry["completed_this_visit"] = true
	completed_stories[entry.profile.character_id] = true
	history.append({"uid": uid, "person": entry.profile.person, "day": entry.day, "title": entry.story.title,
		"choice": choice, "transcript": transcript.duplicate(true)})
	changed.emit()
	return true
