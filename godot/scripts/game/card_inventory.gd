extends Node
## CardInventory: 소유 카드·수량·손패/창고의 단일 기록(기획서 v0.3 §9).
## 같은 자원은 한 장에 수량으로 묶고, 용병 계약·몬스터 카드는 한 장씩 따로 둔다.
## 손패가 가시 장수를 넘으면 새 카드를 창고에 넣는다. 보상을 버리지 않는다.

const Cfg := preload("res://scripts/config.gd")
const Catalog := preload("res://scripts/ui/card_catalog.gd")

signal changed

var game
var entries: Array = []      # {uid, id, count, zone("hand"|"storage"), person}
var defs: Dictionary = {}    # id -> catalog entry
var stats := {"hired": 0, "timber": 0, "wool": 0, "wool_sold": 0, "monster": 0, "used": 0}
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


func storage() -> Array:
	return entries.filter(func(e): return e["zone"] == "storage")


func get_entry(uid: int) -> Dictionary:
	for e in entries:
		if e["uid"] == uid:
			return e
	return {}


func count_of(id: String) -> int:
	var n := 0
	for e in entries:
		if e["id"] == id:
			n += int(e["count"])
	return n


## 획득. 같은 자원은 기존 카드에 수량을 더한다. 반환: 넣은 구역.
func add(id: String, amount := 1, person := "") -> String:
	if not defs.has(id) or amount <= 0:
		return ""
	match id:
		"axe_mercenary": stats["hired"] += 1
		"timber": stats["timber"] += amount
		"wool": stats["wool"] += amount
		"forest_monster": stats["monster"] += 1
	if stackable(id):
		for e in entries:
			if e["id"] == id:
				e["count"] += amount
				changed.emit()
				return e["zone"]
	var zone := "hand" if hand().size() < Cfg.HAND_VISIBLE else "storage"
	entries.append({"uid": _next_uid, "id": id, "count": amount, "zone": zone, "person": person})
	_next_uid += 1
	if zone == "storage" and game != null:
		game.toast("손패가 가득 차 '%s' 카드를 창고에 보관했습니다" % def(id).get("name", id), Color(0.95, 0.85, 1.0))
	changed.emit()
	return zone


## 사용 확정 시에만 호출한다. 수량이 부족하면 아무것도 바꾸지 않는다.
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
		stats["used"] += 1
		changed.emit()
		return true
	return false


func move(uid: int, zone: String) -> bool:
	var e := get_entry(uid)
	if e.is_empty() or e["zone"] == zone:
		return false
	if zone == "hand" and hand().size() >= Cfg.HAND_VISIBLE:
		return false
	e["zone"] = zone
	changed.emit()
	return true


func persons_in_use() -> Array:
	var out: Array = []
	for e in entries:
		if e["person"] != "":
			out.append(e["person"])
	return out
