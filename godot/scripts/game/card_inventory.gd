extends Node
## CardInventory: 소유 카드·수량·손패/주머니의 단일 기록(기획 region-season-pocket-design.md §6).
## 주머니(pocket)가 곧 덱이다. 플레이어가 원하는 카드를 마음대로 넣거나 꺼낼 수 없고,
## 아침 드로우·카드 효과 드로우로만 손패에 들어온다. 같은 자원은 한 구역 안에서 한 장에 수량으로 묶는다.
## 새 카드는 손패에 먼저 들어가고, 손패(8장)가 가득 차면 주머니로 간다(확정 규칙 1·3).
## 자원 외의 사용 카드는 버림패(discard)로 가고 자동으로 재순환하지 않는다(확정 규칙 5·6).
## 용병·입식·설치물처럼 활동이 이어지는 카드는 in_play에 머물다 활동이 끝나면 버림패로 간다.
## entries 에는 손패·주머니 카드만 있다(활동 중·버림패는 별도 목록).

const Cfg := preload("res://scripts/config.gd")
const Catalog := preload("res://scripts/ui/card_catalog.gd")

signal changed
signal drawn(uids: Array)   # 주머니에서 손패로 들어온 카드(연출용)

var game
var entries: Array = []      # {uid, id, count, zone("hand"|"pocket"), person}
var in_play: Array = []      # 활동 중인 카드 {uid, id, person}
var discard: Array = []      # 버림패 {uid, id, person}
var defs: Dictionary = {}    # id -> catalog entry
var stats := {"hired": 0, "timber": 0, "wool": 0, "wool_sold": 0, "monster": 0, "used": 0, "raw_meat": 0, "rabbit_pelt": 0, "chests": 0, "relics": 0,
	"drawn": 0, "morning_draws": 0, "skipped_draws": 0, "discarded": 0}
var last_drawn: Array = []   # 마지막 드로우로 손패에 들어온 uid 목록(손패 UI가 읽고 비운다)
var _next_uid := 1


func _ready() -> void:
	name = "CardInventory"
	for entry in Catalog.read().get("cards", []):
		defs[entry["id"]] = entry


func def(id: String) -> Dictionary:
	return defs.get(id, {})


func stackable(id: String) -> bool:
	return bool(def(id).get("stackable", false))


func hand() -> Array:
	return entries.filter(func(e): return e["zone"] == "hand")


func pocket() -> Array:
	return entries.filter(func(e): return e["zone"] == "pocket")


## (구 이름 호환) 창고 = 주머니.
func storage() -> Array:
	return pocket()


func hand_full() -> bool:
	return hand().size() >= Cfg.HAND_VISIBLE


func pocket_empty() -> bool:
	return pocket().is_empty()


## 주머니 안의 카드 수(묶음 자원은 수량만큼).
func pocket_units() -> int:
	var n := 0
	for e in pocket():
		n += int(e["count"])
	return n


func get_entry(uid: int) -> Dictionary:
	for e in entries:
		if e["uid"] == uid:
			return e
	return {}


## 손패에 뽑힌 수량(확정 규칙 9: 모든 자원 사용은 손패의 자원만 가능).
func hand_count_of(id: String) -> int:
	var n := 0
	for e in entries:
		if e["id"] == id and e["zone"] == "hand":
			n += int(e["count"])
	return n


## 주머니 안의 수량(아직 뽑지 않아 쓸 수 없는 자원).
func pocket_count_of(id: String) -> int:
	return count_of(id) - hand_count_of(id)


## 손패+주머니의 보유 수량. 활동 중·버림패는 세지 않는다.
func count_of(id: String) -> int:
	var n := 0
	for e in entries:
		if e["id"] == id:
			n += int(e["count"])
	return n


func _find_stack(id: String, zone: String) -> Dictionary:
	for e in entries:
		if e["id"] == id and e["zone"] == zone:
			return e
	return {}


func _new_entry(id: String, amount: int, zone: String, person: String) -> Dictionary:
	var e := {"uid": _next_uid, "id": id, "count": amount, "zone": zone, "person": person}
	_next_uid += 1
	entries.append(e)
	return e


## 획득. 손패에 먼저 넣고, 손패가 가득 차면 주머니로 보낸다. 같은 자원은 그 구역의 기존 카드에 수량을 더한다.
## zone 을 "pocket" 으로 주면 손패를 거치지 않고 주머니에 넣는다(시작 카드). 반환: 넣은 구역.
func add(id: String, amount := 1, person := "", zone := "") -> String:
	if not defs.has(id) or amount <= 0:
		return ""
	match id:
		"lumberjack", "hunter", "warrior", "gatherer": stats["hired"] += 1
		"timber": stats["timber"] += amount
		"wool": stats["wool"] += amount
		"raw_meat": stats["raw_meat"] += amount
		"rabbit_pelt": stats["rabbit_pelt"] += amount
		"treasure_chest": stats["chests"] += 1
		"forest_monster": stats["monster"] += 1
	# 낱장 카드를 여러 장 받으면(채집가가 독버섯 2개를 건넴) 한 장씩 따로 넣는다
	if not stackable(id) and amount > 1:
		var last := ""
		for i in amount:
			last = add(id, 1, person, zone)
		return last
	var target := zone
	if target == "":
		if stackable(id) and not _find_stack(id, "hand").is_empty():
			target = "hand"
		else:
			target = "hand" if not hand_full() else "pocket"
	if stackable(id):
		var stack := _find_stack(id, target)
		if not stack.is_empty():
			stack["count"] += amount
			changed.emit()
			return target
	_new_entry(id, amount, target, person)
	if target == "pocket" and zone == "" and game != null:
		game.toast("손패가 가득 차 '%s' 카드를 주머니에 넣었습니다" % def(id).get("name", id), Color(0.95, 0.85, 1.0))
	changed.emit()
	return target


## 사용 확정 시에만 호출한다. 자원은 수량만 차감하고, 그 밖의 카드는 버림패로 보낸다. 수량이 부족하면 아무것도 바꾸지 않는다.
func consume(uid: int, amount := 1) -> bool:
	for i in entries.size():
		var e: Dictionary = entries[i]
		if e["uid"] != uid:
			continue
		if int(e["count"]) < amount:
			return false
		e["count"] -= amount
		if e["count"] <= 0:
			entries.remove_at(i)
			if not stackable(e["id"]):
				_to_discard(e)
		stats["used"] += 1
		changed.emit()
		return true
	return false


## 묶음 자원(목재·양털)을 종류로 소비한다. **손패에 뽑힌 자원만** 쓴다(확정 규칙 9). 부족하면 아무것도 바꾸지 않는다.
func consume_id(id: String, amount: int) -> bool:
	if amount <= 0:
		return true
	if hand_count_of(id) < amount:
		return false
	var left := amount
	for e in hand():
		if left <= 0:
			break
		if e["id"] != id:
			continue
		var take := mini(left, int(e["count"]))
		if not consume(e["uid"], take):
			return false
		left -= take
	return true


## 활동 카드(용병·하수인·입식·설치물)를 사용: 손패에서 빠져 활동 중 목록으로 간다. 활동이 끝나면 retire()로 버림패에 보낸다.
func activate(uid: int) -> bool:
	for i in entries.size():
		var e: Dictionary = entries[i]
		if e["uid"] != uid:
			continue
		entries.remove_at(i)
		in_play.append({"uid": e["uid"], "id": e["id"], "person": e["person"]})
		stats["used"] += 1
		changed.emit()
		return true
	return false


## 활동 종료(사망·파괴·소멸·자발적 종료): 활동 중 카드를 버림패로 보낸다.
func retire(uid: int) -> bool:
	for i in in_play.size():
		if in_play[i]["uid"] == uid:
			var e: Dictionary = in_play[i]
			in_play.remove_at(i)
			_to_discard(e)
			changed.emit()
			return true
	return false


func _to_discard(e: Dictionary) -> void:
	discard.append({"uid": e["uid"], "id": e["id"], "person": e.get("person", "")})
	stats["discarded"] += 1


# ───────────────────────── 드로우 ─────────────────────────

## 주머니의 카드 한 장(묶음 자원은 1개)을 손패로 가져온다. 손패가 가득 차거나 주머니가 비면 아무것도 하지 않는다.
## 반환: 손패에 들어간 entry(빈 사전이면 드로우 없음).
func draw_uid(uid: int) -> Dictionary:
	var e := get_entry(uid)
	if e.is_empty() or e["zone"] != "pocket":
		return {}
	# 손패가 가득 차도 같은 자원 묶음이 손패에 있으면 그 묶음에 1개 합산한다(새 칸을 쓰지 않음 — 획득 규칙 1과 같은 처리)
	if hand_full() and not (stackable(e["id"]) and not _find_stack(e["id"], "hand").is_empty()):
		return {}
	var into: Dictionary
	if stackable(e["id"]):
		var stack := _find_stack(e["id"], "hand")
		if int(e["count"]) > 1 or not stack.is_empty():
			e["count"] -= 1
			if e["count"] <= 0:
				entries.erase(e)
			if stack.is_empty():
				into = _new_entry(e["id"], 1, "hand", "")
			else:
				stack["count"] += 1
				into = stack
		else:
			into = _move_to_hand_end(e)
	else:
		into = _move_to_hand_end(e)
	stats["drawn"] += 1
	last_drawn.append(into["uid"])
	drawn.emit([into["uid"]])
	changed.emit()
	return into


## 뽑은 카드는 손패 순서의 맨 뒤(화면 오른쪽 끝)에 쌓인다. 손패 순서 = entries 순서.
func _move_to_hand_end(e: Dictionary) -> Dictionary:
	entries.erase(e)
	e["zone"] = "hand"
	entries.append(e)
	return e


## 주머니에서 무작위로 n장 드로우. 반환: 손패에 들어간 entry 목록.
func draw(n := 1) -> Array:
	var out: Array = []
	for i in n:
		var pool := pocket()
		if pool.is_empty():
			break
		var pick: Dictionary = pool[randi() % pool.size()]
		var got := draw_uid(pick["uid"])
		if got.is_empty():
			break
		out.append(got)
	return out


## 주머니에서 서로 다른 카드 n장을 무작위 후보로 고른다(오래된 마법서적·시작 손패). 부족하면 있는 만큼.
func draw_choices(n := Cfg.SPELLBOOK_CHOICES) -> Array:
	var pool := pocket().duplicate()
	pool.shuffle()
	return pool.slice(0, mini(n, pool.size()))


## 제외 목록에 없는 주머니 카드 한 장을 무작위로 고른다(시작 손패 교체). 없으면 빈 사전.
func peek_random_pocket(exclude: Array = []) -> Dictionary:
	var pool := pocket().filter(func(e): return not e["uid"] in exclude)
	if pool.is_empty():
		return {}
	return pool[randi() % pool.size()]


## 아침 드로우(확정 규칙 4): 주머니에 카드가 있으면 무작위 한 장. 손패가 가득 차면 건너뛰고 카드를 주머니에 보존한다.
func morning_draw() -> Array:
	if pocket_empty():
		return []
	if hand_full():
		stats["skipped_draws"] += 1
		if game != null:
			game.toast("손패가 가득 차 아침 드로우를 건너뜁니다 — 주머니에 %d장 보존" % pocket().size(), Color(0.85, 0.8, 0.95))
		return []
	var got := draw(Cfg.MORNING_DRAW)
	if not got.is_empty():
		stats["morning_draws"] += 1
		if game != null:
			var names: Array = got.map(func(e): return def(e["id"]).get("name", e["id"]))
			game.toast("아침 드로우 — %s" % " · ".join(names), Color(1.0, 0.95, 0.8))
			game.sounds.play("card_draw")
	return got


# ───────────────────────── 조회 ─────────────────────────

## 직업 카드인지(네 직업 계약).
func is_job(id: String) -> bool:
	return id in Cfg.JOB_CARDS


## 드로우 전용 카드(본래 효과가 없고 드로우만 하는 카드). 주머니가 비면 사용 불가·비용 없음(확정 규칙 7).
func is_draw_only(id: String) -> bool:
	return id in Cfg.DRAW_ONLY_CARDS


func persons_in_use() -> Array:
	var out: Array = []
	for e in entries + in_play:
		if e["person"] != "":
			out.append(e["person"])
	return out
