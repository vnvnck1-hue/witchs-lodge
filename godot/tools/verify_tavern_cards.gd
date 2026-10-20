extends SceneTree
## 술 주정뱅이 에린·주점 카드 v1 자동 검증(docs/tavern-cards-v01.md).
## 실행: godot --headless --path . --script res://tools/verify_tavern_cards.gd
func _initialize():
	change_scene_to_file("res://scenes/main.tscn")
	root.add_child(load("res://tools/tavern_check.gd").new())
