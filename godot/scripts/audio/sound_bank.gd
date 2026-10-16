extends Node
## 승인된 효과음만 재생하며 실행 중 선택 변경을 1초마다 반영한다.
## selected.json 의 sounds 에 적힌 이벤트는 모두 쓸 수 있다(이름은 영문 소문자·숫자·_).
const BACKGROUND := ["bgm_field", "bgm_evening", "bgm_combat", "ambience_day", "ambience_evening"]
const COMBAT_IN := 6.0     # 밤 웨이브가 시작될 때 전투 곡으로 넘어가는 시간(초)
const COMBAT_OUT := 10.0   # 웨이브가 끝나고 전투 곡이 물러나는 시간(초)
const EVENING_FADE := 8.0  # 낮↔저녁 곡이 시간으로 따라가는 최소 전환 시간(초)
const MUSIC_XF := 4.0      # 같은 곡의 끝→처음을 겹치는 시간(초)
const MAX_VOICES := 32
## 자주 반복되는 바탕 소리: 알림음을 막는 "방금 소리가 났다" 판단에서 뺀다.
const AMBIENT := ["chop", "witch_step", "sheep_bleat", "btn_hover", "card_hover", "shear_loop", "move_click"]
const DEFAULT_DB := {"magic_bolt": -12.0, "card_play": -10.0, "gold_reward": -10.0, "dragon_arrival": -8.0, "bgm_field": -8.0, "bgm_evening": -8.0, "ambience_day": -18.0, "ambience_evening": -18.0,
	"card_draw": -10.0, "card_pickup": -12.0, "card_target": -12.0, "card_cancel": -12.0, "card_deny": -10.0, "card_stash": -11.0, "card_shuffle": -12.0, "card_inspect": -11.0}
## 배경음은 게임이 멈춰도 끄지 않는다. 산장 메뉴(실내)에서는 살짝 줄이며 고음을 깎아 벽 너머처럼,
## 대화·창고·판매 창·Esc 메뉴 등 그 밖의 정지 화면에서는 음량만 잠시 낮춘다.
const BG_BUS := "Background"
const ROOM_DB := -6.0
const DUCK_DB := -9.0
const ROOM_CUTOFF := 1600.0
const OPEN_CUTOFF := 20000.0
const ROOM_FADE := 0.35
var game
var room := false
var ducked := false
var _bg_bus := -1
var _bus_db := 0.0
var _cutoff := OPEN_CUTOFF
var _room_tween: Tween
var background_players: Dictionary = {}
var streams: Dictionary = {}
var gains: Dictionary = {}
var cursors: Dictionary = {}
var last_play: Dictionary = {}
var revision := ""
var elapsed := 0.0
var config_path := ""
var last_event := ""
var play_count := 0
var last_any_ms := -100000
var history: Array = []  # 재생된 이벤트 기록(검증용)
var combat_mix := 0.0
var evening_mix := -1.0
var _decks: Dictionary = {}  # 음악 이벤트 → 번갈아 쓰는 플레이어 두 개
var _field_day := -1
## 반복음: 주인(id)마다 하나. 주인이 매 프레임 loop() 로 0~1 무게를 알려 주고, 끊기면 서서히 사라진다.
var loops: Dictionary = {}  # id → {player, event, weight, seen}

func _ready() -> void:
	name = "SoundBank"
	config_path = "res://assets/audio/selected.json"
	var sidecar := OS.get_executable_path().get_base_dir().path_join("audio/selected.json")
	if FileAccess.file_exists(sidecar): config_path = sidecar
	_ensure_bus()
	reload_selection()
	# 모든 버튼에 클릭·오버·불가 소리를 단다(지금 있는 것과 이후에 생기는 것 모두)
	get_tree().node_added.connect(_hook_button)
	_hook_tree.call_deferred(get_tree().root)

func _ensure_bus() -> void:
	_bg_bus = AudioServer.get_bus_index(BG_BUS)
	if _bg_bus != -1: return
	AudioServer.add_bus()
	_bg_bus = AudioServer.bus_count - 1
	AudioServer.set_bus_name(_bg_bus, BG_BUS)
	AudioServer.set_bus_send(_bg_bus, "Master")
	var lowpass := AudioEffectLowPassFilter.new()
	lowpass.cutoff_hz = OPEN_CUTOFF
	lowpass.resonance = 0.5
	AudioServer.add_bus_effect(_bg_bus, lowpass)

## 산장 메뉴가 열려 있는지(room), 그 밖의 이유로 화면이 멈췄는지(duck)를 hud.refresh_pause가 매번 알려 준다.
func set_room(on: bool, duck := false) -> void:
	if on == room and duck == ducked: return
	room = on
	ducked = duck
	var to_db := ROOM_DB if room else (DUCK_DB if ducked else 0.0)
	var to_cutoff := ROOM_CUTOFF if room else OPEN_CUTOFF
	if _room_tween != null and _room_tween.is_valid(): _room_tween.kill()
	_room_tween = create_tween()
	_room_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_room_tween.tween_method(_apply_mix.bind(_bus_db, to_db, _cutoff, to_cutoff), 0.0, 1.0, ROOM_FADE).set_trans(Tween.TRANS_SINE)

func _apply_mix(t: float, from_db: float, to_db: float, from_cutoff: float, to_cutoff: float) -> void:
	_bus_db = lerpf(from_db, to_db, t)
	# 차단 주파수는 귀에 고르게 들리도록 로그 간격으로 옮긴다.
	_cutoff = exp(lerpf(log(from_cutoff), log(to_cutoff), t))
	AudioServer.set_bus_volume_db(_bg_bus, _bus_db)
	(AudioServer.get_bus_effect(_bg_bus, 0) as AudioEffectLowPassFilter).cutoff_hz = _cutoff

func _process(delta: float) -> void:
	_step_loops(delta)
	elapsed += delta
	if elapsed >= 1.0:
		elapsed = 0.0
		reload_selection()
	if game != null and game.world != null and game.world.day_cycle != null:
		update_background(game.world.day_cycle.progress)

func reload_selection() -> void:
	if not FileAccess.file_exists(config_path): return
	var text := FileAccess.get_file_as_string(config_path)
	if text == revision: return
	var parsed = JSON.parse_string(text)
	if not parsed is Dictionary or not parsed.has("sounds") or not parsed["sounds"] is Dictionary: return
	var next_streams := {}
	var next_gains := {}
	for event in parsed["sounds"].keys():
		var entry = parsed["sounds"][event]
		if not event is String or not entry is Dictionary or not event.is_valid_ascii_identifier(): continue
		var loaded: Array[AudioStream] = []
		# 파일별 음량 보정(trim_db: {파일: dB}) — 같은 이벤트의 곡끼리 크기를 맞춘다
		var trims = entry.get("trim_db", {})
		for filename in entry.get("files", []):
			if not filename is String or filename != filename.get_file() or filename.get_extension() not in ["mp3", "wav"]: continue
			var path: String = config_path.get_base_dir().path_join(filename)
			var stream: AudioStream
			# PCK에서는 원본 오디오 대신 import remap만 있을 수 있다. 외부 선택 파일은 기존 로더를 유지한다.
			if not FileAccess.file_exists(path):
				if ResourceLoader.exists(path): stream = load(path) as AudioStream
			elif filename.ends_with(".mp3"):
				var mp3 := AudioStreamMP3.new()
				mp3.data = FileAccess.get_file_as_bytes(path)
				stream = mp3
			else:
				stream = AudioStreamWAV.load_from_file(path)
			if stream != null and stream.get_length() > 0.0:
				if trims is Dictionary and trims.has(filename): stream.set_meta("trim_db", clampf(float(trims[filename]), -24.0, 12.0))
				loaded.append(stream)
		if loaded.is_empty(): continue
		next_streams[event] = loaded
		next_gains[event] = clampf(float(entry.get("volume_db", DEFAULT_DB.get(event, -10.0))), -30.0, 0.0)
	streams = next_streams
	gains = next_gains
	cursors.clear()
	revision = text
	background_players.clear()
	_decks.clear()
	_field_day = -1
	evening_mix = -1.0
	loops.clear()
	for child in get_children(): child.queue_free()

## 배경음악·환경음.
## 음악(bgm_*)은 이벤트마다 플레이어 두 개를 번갈아 쓴다: 곡이 끝나기 MUSIC_XF초 전에 다음 회차를 처음부터 겹쳐
## 틀어 끝→처음이 툭 끊기지 않는다. 곡 사이 전환은 사인·코사인(동등 전력) 곡선이라 겹치는 동안 전체 음량이 꺼지지 않는다.
## 낮 곡(bgm_field)에 파일이 여럿이면 새 날마다 그중 하나를 무작위로, 낮 곡이 들리지 않는 동안(밤) 바꾼다.
func update_background(progress: float, step := -1.0) -> void:
	var dt: float = step if step >= 0.0 else get_process_delta_time()  # 검증에서는 고정 시간 간격을 넘긴다
	var target_e := smoothstep(0.58, 0.82, progress)
	# 새벽에 하루 진행도가 0으로 돌아가도 저녁 곡이 한 번에 끊기지 않도록 시간으로 따라간다
	evening_mix = target_e if evening_mix < 0.0 else move_toward(evening_mix, target_e, dt / EVENING_FADE)
	var fighting: bool = game.session != null and game.session.state in [1, 2] and streams.has("bgm_combat")
	var was := combat_mix
	combat_mix = move_toward(combat_mix, 1.0 if fighting else 0.0, dt / (COMBAT_IN if fighting else COMBAT_OUT))
	if was <= 0.0 and combat_mix > 0.0:
		_restart_deck("bgm_combat")  # 전투 곡은 시작할 때마다 처음부터
	var e: float = evening_mix if streams.has("bgm_evening") else 0.0
	var rest := cos(combat_mix * PI * 0.5)
	var weights := {
		"bgm_field": rest * cos(e * PI * 0.5),
		"bgm_evening": rest * sin(e * PI * 0.5),
		"bgm_combat": sin(combat_mix * PI * 0.5),
	}
	# 낮 곡 고르기: 처음 한 번, 그 뒤로는 날이 바뀌었고 낮 곡이 거의 안 들릴 때
	var day: int = game.session.day() if game.session != null and game.session.has_method("day") else 0
	if streams.has("bgm_field") and (not _decks.has("bgm_field") or (day != _field_day and weights["bgm_field"] < 0.02)):
		var options: Array = streams["bgm_field"]
		var pick: AudioStream = options[randi() % options.size()]
		if not _decks.has("bgm_field") or _decks["bgm_field"]["stream"] != pick or options.size() == 1:
			_set_deck_stream("bgm_field", pick)
		_field_day = day
	for ev in weights:
		_music(ev, weights[ev], dt)
	# 환경음: 엔진 반복 재생, 낮·저녁만 섞는다
	var has_evening_amb: bool = streams.has("ambience_evening")
	for i in 2:
		var event: String = ["ambience_day", "ambience_evening"][i]
		if not streams.has(event): continue
		if not background_players.has(event):
			var stream: AudioStream = streams[event][0]
			if stream is AudioStreamMP3:
				stream.loop = true
			elif stream is AudioStreamWAV:
				stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
				stream.loop_end = int(round(stream.get_length() * stream.mix_rate))
			var player := _bg_player(event)
			player.stream = stream
			player.play()
			background_players[event] = player
			if history.size() < 4000: history.append(event)
		var weight: float = evening_mix if i == 1 else (1.0 - evening_mix if has_evening_amb else 1.0)
		background_players[event].volume_db = gains[event] + linear_to_db(maxf(weight, 0.0001))

func _bg_player(n: String) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.name = n
	p.volume_db = -80.0
	p.bus = BG_BUS
	p.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(p)
	return p

func _deck(event: String) -> Dictionary:
	if not _decks.has(event):
		_decks[event] = {"a": _bg_player(event + "_a"), "b": _bg_player(event + "_b"), "cur": "a", "stream": null, "xf": 0.0}
	return _decks[event]

## 덱의 곡을 바꾸고 처음부터 튼다(끝에서 직접 겹치므로 엔진 반복은 끈다).
func _set_deck_stream(event: String, stream: AudioStream) -> void:
	var d := _deck(event)
	if stream is AudioStreamMP3:
		stream.loop = false
	elif stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_DISABLED
	d["stream"] = stream
	for k in ["a", "b"]:
		d[k].stop()
		d[k].stream = stream
	d["cur"] = "a"
	d["xf"] = 0.0
	d["a"].play(0.0)
	if history.size() < 4000: history.append(event)

func _restart_deck(event: String) -> void:
	if _decks.has(event) and _decks[event]["stream"] != null:
		_set_deck_stream(event, _decks[event]["stream"])

func _music(event: String, weight: float, dt: float) -> void:
	if not streams.has(event): return
	var d := _deck(event)
	if d["stream"] == null:
		_set_deck_stream(event, streams[event][0])
	var cur: AudioStreamPlayer = d[d["cur"]]
	var nxt: AudioStreamPlayer = d["b" if d["cur"] == "a" else "a"]
	var length: float = (d["stream"] as AudioStream).get_length()
	var xf := minf(MUSIC_XF, length * 0.25)
	if d["xf"] <= 0.0 and cur.playing and cur.get_playback_position() >= length - xf:
		nxt.play(0.0)
		d["xf"] = 0.0001
	elif d["xf"] <= 0.0 and not cur.playing:
		cur.play(0.0)  # 정지 화면 동안 끝까지 갔으면 다시 처음부터
	var t_cur := 1.0
	var t_nxt := 0.0
	if d["xf"] > 0.0:
		d["xf"] += dt
		var u := clampf(d["xf"] / xf, 0.0, 1.0)
		t_cur = cos(u * PI * 0.5)
		t_nxt = sin(u * PI * 0.5)
		if u >= 1.0:
			cur.stop()
			d["cur"] = "b" if d["cur"] == "a" else "a"
			d["xf"] = 0.0
	var g: float = gains[event] + float((d["stream"] as AudioStream).get_meta("trim_db", 0.0))
	cur.volume_db = g + linear_to_db(maxf(weight * t_cur, 0.0001))
	nxt.volume_db = g + linear_to_db(maxf(weight * t_nxt, 0.0001))

func play(event: String) -> bool:
	if event in BACKGROUND: return false
	# 게임이 멈춘 동안에도 소리를 낼 수 있다. 정지 중에는 월드가 돌지 않아 호출하는 곳이
	# 산장 상점·판매·창고·대화 창과 승패 화면 같은 UI 뿐이고, 그 소리가 막히면 안 된다.
	if not streams.has(event) or streams[event].is_empty(): return false
	var now := Time.get_ticks_msec()
	if now - int(last_play.get(event, -10000)) < 100 or get_child_count() >= MAX_VOICES: return false
	var variants: Array = streams[event]
	var index := int(cursors.get(event, 0)) % variants.size()
	cursors[event] = index + 1
	var player := AudioStreamPlayer.new()
	player.stream = variants[index]
	player.volume_db = gains[event]
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()
	last_play[event] = now
	last_event = event
	if not event in AMBIENT: last_any_ms = now
	if history.size() < 4000: history.append(event)
	play_count += 1
	return true

## 반복음 갱신: 주인이 매 프레임 호출한다. weight 0이면 사라진다. 반환값은 실제로 재생 중인지.
func loop(id: String, event: String, weight: float) -> bool:
	if not streams.has(event): return false
	var l: Dictionary = loops.get(id, {})
	if l.is_empty():
		if weight <= 0.01: return false
		var stream: AudioStream = (streams[event][0] as AudioStream).duplicate()
		if stream is AudioStreamWAV:
			stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
			stream.loop_end = int(round(stream.get_length() * stream.mix_rate))
		elif stream is AudioStreamMP3:
			stream.loop = true
		var player := AudioStreamPlayer.new()
		player.stream = stream
		player.volume_db = -60.0
		add_child(player)
		player.play(randf() * stream.get_length())
		l = {"player": player, "event": event, "weight": 0.0, "target": 0.0}
		if history.size() < 4000: history.append(event)
		loops[id] = l
	l["target"] = clampf(weight, 0.0, 1.0)
	l["seen"] = Time.get_ticks_msec()
	return true

func _step_loops(delta: float) -> void:
	var now := Time.get_ticks_msec()
	for id in loops.keys():
		var l: Dictionary = loops[id]
		# 주인이 0.3초 넘게 소식이 없으면(사라졌거나 멈춤) 끄기로 본다
		var target: float = l["target"] if now - int(l["seen"]) < 300 else 0.0
		l["weight"] = move_toward(l["weight"], target, delta * 2.5)
		var p: AudioStreamPlayer = l["player"]
		if not is_instance_valid(p):
			loops.erase(id)
			continue
		p.volume_db = gains.get(l["event"], -10.0) + linear_to_db(maxf(l["weight"], 0.0001))
		if l["weight"] <= 0.001 and target <= 0.0:
			p.queue_free()
			loops.erase(id)

## 마지막 효과음 뒤로 ms 이상 조용했는지(알림음이 사건 소리와 겹치지 않게).
func quiet_for(ms: int) -> bool:
	return Time.get_ticks_msec() - last_any_ms >= ms

func _hook_tree(n: Node) -> void:
	_hook_button(n)
	for c in n.get_children():
		_hook_tree(c)

## 버튼(기본 BaseButton·달빛 MoonButton): 누르면 클릭, 올리면 오버, 비활성일 때 누르면 불가.
func _hook_button(n: Node) -> void:
	if not (n is Control) or not n.has_signal("pressed") or not ("disabled" in n) or n.has_meta("sfx_hooked"):
		return
	n.set_meta("sfx_hooked", true)
	n.pressed.connect(func(): play("btn_click"))
	n.mouse_entered.connect(func():
		if not n.disabled:
			play("btn_hover"))
	n.gui_input.connect(func(e: InputEvent):
		var mb := e as InputEventMouseButton
		if mb != null and mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT and n.disabled:
			play("btn_denied"))
