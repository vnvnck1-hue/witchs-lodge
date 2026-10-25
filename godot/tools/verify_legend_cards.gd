extends SceneTree
## 전설 카드 5장 + 광석 v1 자동 검증(docs/legend-cards-v01.md).
## 실행: godot --headless --path . --script res://tools/verify_legend_cards.gd
func _initialize():
	change_scene_to_file("res://scenes/main.tscn")
	root.add_child(load("res://tools/legend_check.gd").new())
