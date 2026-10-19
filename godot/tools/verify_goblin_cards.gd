extends SceneTree
## 고블린 카드 v1 · 용병 이벤트 · 적 처치 골드 자동 검증(docs/goblin-cards-v01.md).
## 실행: godot --headless --path . --script res://tools/verify_goblin_cards.gd
func _initialize():
	change_scene_to_file("res://scenes/main.tscn")
	root.add_child(load("res://tools/goblin_check.gd").new())
