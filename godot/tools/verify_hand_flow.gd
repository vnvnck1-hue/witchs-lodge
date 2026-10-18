extends SceneTree
## 손패 흐름 v1(낮·밤 손패 분리·전환 교체, 달빛 스택 드로우, 모닥불 태우기) 자동 검증 실행기.
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_hand_flow.gd
func _initialize():
	change_scene_to_file("res://scenes/main.tscn")
	root.add_child(load("res://tools/hand_flow_check.gd").new())
