extends Node
## 승인된 효과음만 재생하며 실행 중 선택 변경을 1초마다 반영한다.
const EVENTS := ["magic_bolt", "card_play", "gold_reward", "dragon_arrival", "bgm_field", "bgm_evening", "ambience_day", "ambience_evening"]
const BACKGROUND := ["bgm_field", "bgm_evening", "ambience_day", "ambience_evening"]
const DEFAULT_DB := {"magic_bolt": -12.0, "card_play": -10.0, "gold_reward": -10.0, "dragon_arrival": -8.0, "bgm_field": -8.0, "bgm_evening": -8.0, "ambience_day": -18.0, "ambience_evening": -18.0}
var game
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

func _ready() -> void:
	name = "SoundBank"
	config_path = "res://assets/audio/selected.json"
	var sidecar := OS.get_executable_path().get_base_dir().path_join("audio/selected.json")
	if FileAccess.file_exists(sidecar): config_path = sidecar
	reload_selection()

func _process(delta: float) -> void:
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
	for event in EVENTS:
		var entry = parsed["sounds"].get(event, {})
		if not entry is Dictionary: continue
		var loaded: Array[AudioStream] = []
		for filename in entry.get("files", []):
			if not filename is String or filename != filename.get_file() or filename.get_extension() not in ["mp3", "wav"]: continue
			var path: String = config_path.get_base_dir().path_join(filename)
			if not FileAccess.file_exists(path): continue
			var stream: AudioStream
			if filename.ends_with(".mp3"):
				var mp3 := AudioStreamMP3.new()
				mp3.data = FileAccess.get_file_as_bytes(path)
				stream = mp3
			else:
				stream = AudioStreamWAV.load_from_file(path)
			if stream != null and stream.get_length() > 0.0: loaded.append(stream)
		if loaded.is_empty(): continue
		next_streams[event] = loaded
		next_gains[event] = clampf(float(entry.get("volume_db", DEFAULT_DB[event])), -30.0, 0.0)
	streams = next_streams
	gains = next_gains
	cursors.clear()
	revision = text
	background_players.clear()
	for child in get_children(): child.queue_free()

func update_background(progress: float) -> void:
	if get_tree().paused: return
	var evening := smoothstep(0.58, 0.82, progress)
	for pair in [["bgm_field", "bgm_evening"], ["ambience_day", "ambience_evening"]]:
		var has_evening: bool = streams.has(pair[1])
		for i in 2:
			var event: String = pair[i]
			if not streams.has(event): continue
			if not background_players.has(event):
				var stream: AudioStream = streams[event][0]
				if stream is AudioStreamMP3:
					stream.loop = true
				elif stream is AudioStreamWAV:
					stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
					stream.loop_end = int(round(stream.get_length() * stream.mix_rate))
				var player := AudioStreamPlayer.new()
				player.name = event
				player.stream = stream
				player.volume_db = -80.0
				add_child(player)
				player.play()
				background_players[event] = player
			var weight: float = evening if i == 1 else (1.0 - evening if has_evening else 1.0)
			background_players[event].volume_db = gains[event] + linear_to_db(maxf(weight, 0.0001))

func play(event: String) -> bool:
	if event in BACKGROUND: return false
	if not streams.has(event) or streams[event].is_empty() or get_tree().paused: return false
	var now := Time.get_ticks_msec()
	if now - int(last_play.get(event, -10000)) < 100 or get_child_count() >= 12: return false
	var variants: Array = streams[event]
	var index := int(cursors.get(event, 0)) % variants.size()
	cursors[event] = index + 1
	var player := AudioStreamPlayer.new()
	player.stream = variants[index]
	player.volume_db = gains[event]
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()
	last_play[event] = now
	last_event = event
	play_count += 1
	return true
