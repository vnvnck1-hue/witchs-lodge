extends SceneTree
## 웹(WebGL 2 / Compatibility) 빌드 준비 상태 검증.
##   .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_web_export.gd
## 셰이더 실제 컴파일은 더미 렌더러로 확인할 수 없어
## `--rendering-method gl_compatibility` 캡처(screenshots/webgl/)로 따로 확인했다.

var failures: Array[String] = []
var checks := 0

func _initialize() -> void:
	var cfg := ConfigFile.new()
	_check(cfg.load("res://export_presets.cfg") == OK, "export_presets.cfg 로드")
	var web := ""
	for s in cfg.get_sections():
		if cfg.get_value(s, "platform", "") == "Web":
			web = s
	_check(web != "", "Web 프리셋 존재")
	if web != "":
		_check(cfg.get_value(web, "export_path", "") == "../build/web/index.html", "Web export_path = ../build/web/index.html")
		_check(cfg.get_value(web + ".options", "variant/thread_support", true) == false, "스레드 미사용(COOP/COEP 헤더 불필요)")
		_check(cfg.get_value(web + ".options", "vram_texture_compression/for_desktop", false) == true, "데스크톱 VRAM 압축(S3TC) 사용")
	_check(str(ProjectSettings.get_setting("rendering/renderer/rendering_method.web", "")) == "gl_compatibility", "웹 렌더러 = gl_compatibility")

	var outline := FileAccess.get_file_as_string("res://shaders/toon_outline.gdshader")
	var guard := outline.find("#if CURRENT_RENDERER != RENDERER_COMPATIBILITY")
	var hint := outline.find("hint_normal_roughness_texture")
	_check(guard >= 0 and hint > guard and outline.find("#endif", guard) > hint, "아웃라인: normal_roughness 버퍼는 Forward+ 분기 안에서만 선언")
	_check(outline.contains("cross(dy,dx)"), "아웃라인: Compatibility는 깊이로 법선 재구성")
	_check(outline.contains("depth = depth*2.0-1.0"), "아웃라인: Compatibility NDC z 변환")
	var fog := FileAccess.get_file_as_string("res://shaders/fog_of_war.gdshader")
	_check(fog.contains("RENDERER_COMPATIBILITY") and fog.contains("depth = depth*2.0-1.0"), "전장 안개: Compatibility NDC z 변환")
	_check(load("res://shaders/toon_outline.gdshader") is Shader, "아웃라인 셰이더 리소스 로드")
	_check(load("res://shaders/fog_of_war.gdshader") is Shader, "전장 안개 셰이더 리소스 로드")

	var Skin := load("res://scripts/ui/moon/moon_skin.gd")
	var kr := load(Skin.BUNDLED_KR_FONT) as FontFile
	_check(kr != null, "번들 한글 폰트 로드: " + Skin.BUNDLED_KR_FONT)
	_check(kr != null and kr.has_char("마".unicode_at(0)) and kr.has_char("◆".unicode_at(0)), "번들 폰트에 한글·◆ 글리프 포함")
	_check(FileAccess.file_exists("res://assets/fonts/OFL.txt"), "OFL 라이선스 동봉")
	for bold in [false, true]:
		var f: Font = Skin.font(bold)
		var ok: bool = f is SystemFont and f.fallbacks.size() == 1 \
			and f.fallbacks[0] is FontVariation and f.fallbacks[0].base_font == kr
		_check(ok, "MoonSkin.font(%s): SystemFont → 번들 폰트 폴백" % bold)

	print("RESULT %d/%d" % [checks - failures.size(), checks])
	quit(1 if failures.size() > 0 else 0)

func _check(ok: bool, message: String) -> void:
	checks += 1
	print(("PASS " if ok else "FAIL ") + message)
	if not ok: failures.append(message)
