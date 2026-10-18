extends SceneTree
## 감시탑 자동 검증 실행기(docs/watchtower-v01.md). 실행: godot --headless --path . --script res://tools/verify_watchtower.gd
func _initialize():
	change_scene_to_file("res://scenes/main.tscn")
	root.add_child(load("res://tools/watchtower_check.gd").new())
