extends SceneTree
## res://scripts 아래 모든 GDScript 가 컴파일되는지 검사한다(리팩토링 뒤 상속·이름 충돌·오타를 한 번에 잡는다).
## 실행: .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_scripts_compile.gd

var failures := 0
var total := 0


func check(name: String, ok: bool, detail := "") -> void:
	total += 1
	if not ok:
		failures += 1
	print(("PASS " if ok else "FAIL ") + name + ("  — " + detail if detail != "" else ""))


func _initialize() -> void:
	var paths: Array = []
	_collect("res://scripts", paths)
	paths.sort()
	for p in paths:
		var s = ResourceLoader.load(p, "", ResourceLoader.CACHE_MODE_IGNORE)
		var ok: bool = s is GDScript and (s as GDScript).can_instantiate()
		if not ok or failures > 0:
			check(p, ok)
		else:
			total += 1
	check("스크립트 %d개 컴파일" % paths.size(), failures == 0)
	print("RESULT %d/%d" % [total - failures, total])
	quit(1 if failures > 0 else 0)


func _collect(dir: String, out: Array) -> void:
	for f in DirAccess.get_files_at(dir):
		if f.ends_with(".gd"):
			out.append(dir + "/" + f)
	for d in DirAccess.get_directories_at(dir):
		_collect(dir + "/" + d, out)
