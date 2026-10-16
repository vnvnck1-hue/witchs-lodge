extends SceneTree
## 마녀의 주머니(덱)·아침 드로우·버림패·드로우 카드 자동 검증 실행기.
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_pocket.gd
func _initialize():
	change_scene_to_file("res://scenes/main.tscn")
	root.add_child(load("res://tools/pocket_check.gd").new())
