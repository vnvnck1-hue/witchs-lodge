extends SceneTree
## 장착 장비 v0 + 용병 초상 프레임 자동 검증(docs/equipment-and-party-frames-v01.md).
## 실행: godot --headless --path . --script res://tools/verify_equipment.gd
func _initialize():
	change_scene_to_file("res://scenes/main.tscn")
	root.add_child(load("res://tools/equipment_check.gd").new())
