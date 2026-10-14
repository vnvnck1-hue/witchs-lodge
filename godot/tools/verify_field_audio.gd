extends SceneTree
const Bank := preload("res://scripts/audio/sound_bank.gd")
var results: Array = []
var failed := false
var path := ""

func _initialize() -> void:
	call_deferred("run")

func check(label: String, passed: bool) -> void:
	results.append({"check":label,"passed":passed})
	failed = failed or not passed
	print(("PASS " if passed else "FAIL ") + label)

func run() -> void:
	var bank := Bank.new()
	root.add_child(bank)
	bank.set_process(false)
	path = ProjectSettings.globalize_path("res://../output/audio-field-v01/verification-selected.json")
	bank.config_path = path
	var file := FileAccess.open(path,FileAccess.WRITE)
	file.store_string(JSON.stringify({"sounds": {
		"bgm_field":{"files":["field-chill-01.wav"],"volume_db":-8},
		"bgm_evening":{"files":["evening-tension-02.wav"],"volume_db":-8},
		"ambience_day":{"files":["forest-wind-01.mp3"],"volume_db":-18},
		"ambience_evening":{"files":["forest-evening-01.mp3"],"volume_db":-18}}}))
	file.close()
	bank.reload_selection()
	check("original WAV and ElevenLabs MP3 both load",bank.streams.size()==4)
	check("BGM WAV duration and sample rate", bank.streams["bgm_field"][0].get_length()>53 and bank.streams["bgm_field"][0].mix_rate==48000)
	bank.update_background(0.0)
	check("four looping layers created",bank.background_players.size()==4)
	check("daytime music audible; evening silent",is_equal_approx(bank.background_players["bgm_field"].volume_db,-8) and bank.background_players["bgm_evening"].volume_db < -70)
	check("WAV has seamless forward loop",bank.background_players["bgm_field"].stream.loop_mode == AudioStreamWAV.LOOP_FORWARD)
	check("nature ambience repeats",bank.background_players["ambience_day"].stream.loop)
	var id: int = bank.background_players["bgm_field"].get_instance_id()
	bank.update_background(0.7)
	check("dusk gently crossfades both tracks",absf(bank.background_players["bgm_field"].volume_db+14.02)<0.1 and absf(bank.background_players["bgm_evening"].volume_db+14.02)<0.1)
	check("time updates do not restart music",bank.background_players["bgm_field"].get_instance_id()==id)
	bank.update_background(1.0)
	check("evening music and ambience replace daytime",is_equal_approx(bank.background_players["bgm_evening"].volume_db,-8) and is_equal_approx(bank.background_players["ambience_evening"].volume_db,-18) and bank.background_players["bgm_field"].volume_db < -70)
	check("background streams cannot trigger as one-shot effects",not bank.play("bgm_field"))
	paused=true
	bank.update_background(0.0)
	check("pause preserves transition state",is_equal_approx(bank.background_players["bgm_evening"].volume_db,-8))
	paused=false
	file=FileAccess.open(path,FileAccess.WRITE)
	file.store_string(JSON.stringify({"sounds":{"bgm_field":{"files":["field-chill-02.wav"],"volume_db":-12}}}))
	file.close()
	bank.reload_selection()
	await process_frame
	bank.update_background(1.0)
	check("basic BGM remains when evening has no approval",bank.background_players.size()==1 and is_equal_approx(bank.background_players["bgm_field"].volume_db,-12))
	file=FileAccess.open(path,FileAccess.WRITE)
	file.store_string('{"sounds":{}}')
	file.close()
	bank.reload_selection()
	await process_frame
	check("removing approvals clears background layers",bank.background_players.is_empty() and bank.get_child_count()==0)
	DirAccess.remove_absolute(path)
	bank.queue_free()
	await process_frame
	var report:=FileAccess.open("res://../output/audio-field-v01/game-verification.json",FileAccess.WRITE)
	report.store_string(JSON.stringify({"passed":not failed,"checks":results},"\t"))
	report.close()
	quit(1 if failed else 0)
