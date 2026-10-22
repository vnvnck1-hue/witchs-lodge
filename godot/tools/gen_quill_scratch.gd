extends SceneTree
## 펜촉이 거친 종이를 긁는 반복음(quill_scratch)을 합성해 assets/audio/sfx-quill_scratch.wav 로 쓴다.
## 외부 녹음 없이 자체 제작(라이선스 걱정 없음). 고정 시드라 다시 돌려도 같은 파일이 나온다.
## 실녹음(CC0)으로 바꾸려면 selected.json 의 quill_scratch files 만 바꾸면 된다(docs/dialogue-handwriting.md).
##   .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/gen_quill_scratch.gd
const RATE := 48000
const LENGTH := 2.4     # 반복 구간(초)
const XFADE := 0.06     # 끝→처음 이음매 겹침(초)
const OUT := "res://assets/audio/sfx-quill_scratch.wav"

## RBJ 대역 통과 biquad
class Band:
	var b0: float; var b1: float; var b2: float; var a1: float; var a2: float
	var x1 := 0.0; var x2 := 0.0; var y1 := 0.0; var y2 := 0.0
	func _init(freq: float, q: float, rate: float) -> void:
		var w := TAU * freq / rate
		var alpha := sin(w) / (2.0 * q)
		var a0 := 1.0 + alpha
		b0 = alpha / a0; b1 = 0.0; b2 = -alpha / a0
		a1 = -2.0 * cos(w) / a0; a2 = (1.0 - alpha) / a0
	func step(x: float) -> float:
		var y := b0 * x + b1 * x1 + b2 * x2 - a1 * y1 - a2 * y2
		x2 = x1; x1 = x; y2 = y1; y1 = y
		return y

func _init() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 20261022
	var n := int((LENGTH + XFADE) * RATE)
	var body := Band.new(3300.0, 0.8, RATE)    # 긁힘의 몸통
	var hiss := Band.new(7200.0, 1.3, RATE)    # 종이 결 쉿 소리
	var tick := Band.new(2400.0, 2.5, RATE)    # 펜촉이 섬유에 걸리는 톡
	var grain := 0.6
	var grain_target := 0.6
	var grain_left := 0
	var click := 0.0
	var raw := PackedFloat32Array()
	raw.resize(n)
	for i in n:
		# 섬유 결: 2~6ms 마다 바뀌는 거친 진폭
		grain_left -= 1
		if grain_left <= 0:
			grain_target = rng.randf_range(0.25, 1.0)
			grain_left = rng.randi_range(int(0.002 * RATE), int(0.006 * RATE))
		grain = lerpf(grain, grain_target, 0.02)
		# 초당 약 30번 펜촉이 걸린다
		if rng.randf() < 30.0 / RATE: click = rng.randf_range(0.6, 1.0)
		click *= 0.985
		var white := rng.randf_range(-1.0, 1.0)
		var t := float(i) / RATE
		var stroke := 0.82 + 0.18 * sin(TAU * 3.1 * t + 0.6 * sin(TAU * 0.7 * t))  # 아주 느린 손힘 흔들림
		raw[i] = (body.step(white) * grain * 1.0 + hiss.step(white) * 0.35 + tick.step(white) * click * 2.6) * stroke
	# 이음매: 마지막 XFADE 를 처음과 겹쳐 반복할 때 끊기지 않게
	var count := int(LENGTH * RATE)
	var fade := n - count
	var out := PackedFloat32Array()
	out.resize(count)
	for i in count: out[i] = raw[i]
	for i in fade:
		var k := float(i) / fade
		out[i] = raw[i] * sqrt(k) + raw[count + i] * sqrt(1.0 - k)
	var peak := 0.0
	for v in out: peak = maxf(peak, absf(v))
	var gain := db_to_linear(-3.0) / maxf(peak, 0.0001)
	var data := PackedByteArray()
	data.resize(count * 2)
	for i in count: data.encode_s16(i * 2, int(clampf(out[i] * gain, -1.0, 1.0) * 32767.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = RATE
	wav.data = data
	var err := wav.save_to_wav(ProjectSettings.globalize_path(OUT))
	print("quill_scratch %s  %.2fs  err=%d" % [OUT, LENGTH, err])
	quit(1 if err != OK else 0)
