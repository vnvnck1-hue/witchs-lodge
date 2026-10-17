extends SceneTree
## 앱 아이콘 설정 검증.
##   .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_app_icon.gd

var _pass := 0
var _total := 0

func _check(label: String, ok: bool) -> void:
	_total += 1
	if ok:
		_pass += 1
	print(("PASS " if ok else "FAIL ") + label)

func _init() -> void:
	var png := Image.load_from_file(ProjectSettings.globalize_path("res://icon.png"))
	_check("icon.png 256x256", png != null and png.get_size() == Vector2i(256, 256))
	_check("icon.png 모서리 투명", png != null and png.get_pixel(0, 0).a == 0.0)

	var f := FileAccess.open("res://icon.ico", FileAccess.READ)
	_check("icon.ico 존재", f != null)
	if f:
		_check("ICO 헤더", f.get_16() == 0 and f.get_16() == 1)
		var count := f.get_16()
		var sizes: Array[int] = []
		for i in count:
			var w := f.get_8()
			sizes.append(256 if w == 0 else w)
			f.seek(f.get_position() + 15)
		for s in [16, 32, 48, 256]:
			_check("ICO %dpx 포함" % s, s in sizes)

	_check("config/icon", ProjectSettings.get_setting("application/config/icon", "") == "res://icon.png")
	_check("config/windows_native_icon", ProjectSettings.get_setting("application/config/windows_native_icon", "") == "res://icon.ico")

	var cfg := ConfigFile.new()
	_check("export_presets.cfg 로드", cfg.load("res://export_presets.cfg") == OK)
	_check("Windows 프리셋 modify_resources", cfg.get_value("preset.0.options", "application/modify_resources", false) == true)
	_check("Windows 프리셋 icon", cfg.get_value("preset.0.options", "application/icon", "") == "res://icon.ico")

	print("RESULT %d/%d" % [_pass, _total])
	quit(0 if _pass == _total else 1)
