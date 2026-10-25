extends SceneTree
## 배경판의 「이어하기」 밑줄·글자 그림자 자국(x1505~1780, y598~640)을 위아래 깨끗한 줄 사이 보간으로 덮는다.
func _init():
	var path := ProjectSettings.globalize_path("res://assets/ui/lobby/lobby_bg.png")
	var img := Image.load_from_file(path)
	img.convert(Image.FORMAT_RGB8)
	var x0 := 1495; var x1 := 1790; var y0 := 596; var y1 := 644
	var rng := RandomNumberGenerator.new(); rng.seed = 11
	for x in range(x0, x1):
		var top := Color(0,0,0); var bot := Color(0,0,0)
		for k in 4:
			top += img.get_pixel(x, y0 - 6 + k) / 4.0
			bot += img.get_pixel(x, y1 + 2 + k) / 4.0
		var fx := minf(smoothstep(0.0, 14.0, x - x0), smoothstep(0.0, 14.0, x1 - x))
		for y in range(y0, y1):
			var t := float(y - y0) / float(y1 - y0)
			var fy := minf(smoothstep(0.0, 5.0, y - y0), smoothstep(0.0, 5.0, y1 - y))
			var n := rng.randf_range(-0.006, 0.006)   # 종이 결 정도의 작은 흔들림
			var fill := top.lerp(bot, t) + Color(n, n, n)
			img.set_pixel(x, y, img.get_pixel(x, y).lerp(fill, fx * fy))
	img.save_png(path)
	quit()
