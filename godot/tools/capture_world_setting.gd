extends SceneTree
## '산장 주변 소식' 패널의 실제 화면 캡처(배치·색·초상은 헤드리스 더미 렌더러로 확인할 수 없다).
##   .tools/Godot-4.7.2.exe --path godot --script res://tools/capture_world_setting.gd
## 결과: screenshots/world-setting/<majors>.png (1600×900, 960×540)
const PanelScript := preload("res://scripts/ui/world_setting_panel.gd")

const WORLDS := [["orc", "fairy"], ["dwarf", "goblin"], ["beastfolk", "human"]]

func _initialize() -> void:
	call_deferred("run")

func frames(n := 4) -> void:
	for i in n: await process_frame

func run() -> void:
	var out := ProjectSettings.globalize_path("res://screenshots/world-setting/")
	DirAccess.make_dir_recursive_absolute(out)
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await frames(8)
	var panel = PanelScript.new()
	game.add_child(panel)
	for size in [Vector2i(1600, 900), Vector2i(960, 540)]:
		root.size = size
		for majors in WORLDS:
			game.world_setting.force(majors)
			panel.show_setting(game.world_setting)
			await frames(6)
			panel.panel.modulate.a = 1.0
			await RenderingServer.frame_post_draw
			var name := "%s-%dx%d.png" % ["-".join(majors), size.x, size.y]
			root.get_texture().get_image().save_png(out + name)
			print("CAPTURE ", name)
			panel.confirm()
	quit(0)
