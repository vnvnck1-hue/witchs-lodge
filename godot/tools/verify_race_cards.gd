extends SceneTree
## 종족·언데드·화합 카드 v1 · 전 종족 용병 이벤트 · 산장의 소문 자동 검증(docs/race-cards-v01.md).
## 실행: godot --headless --path . --script res://tools/verify_race_cards.gd
func _initialize():
	change_scene_to_file("res://scenes/main.tscn")
	root.add_child(load("res://tools/race_check.gd").new())
