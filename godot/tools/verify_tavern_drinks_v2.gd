extends SceneTree
## 에린의 술 카드 v2(용의 숨결·서리 거인의 독주·건배!) 자동 검증.
## 실행(프로젝트 루트): .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_tavern_drinks_v2.gd
func _initialize():
	change_scene_to_file("res://scenes/main.tscn")
	root.add_child(load("res://tools/tavern_drinks_v2_check.gd").new())
