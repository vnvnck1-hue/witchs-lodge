extends SceneTree
## 볼륨 확장 E0~E3(12일 챕터·적 종류·보스·제단·신규 카드·침식·새벽 보상·장날) 자동 검증 실행기.
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_chapter.gd
func _initialize():
	change_scene_to_file("res://scenes/main.tscn")
	root.add_child(load("res://tools/chapter_check.gd").new())
