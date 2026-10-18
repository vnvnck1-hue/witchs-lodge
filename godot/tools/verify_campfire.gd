extends SceneTree
## 모닥불 연료·스튜 자동 검증 실행기(docs/resource-uses-expansion-v01.md v0.3).
## 실행: godot --headless --path . --script res://tools/verify_campfire.gd
func _initialize():
	change_scene_to_file("res://scenes/main.tscn")
	root.add_child(load("res://tools/campfire_check.gd").new())
