extends Node
## GameSession: 준비 → 웨이브 → (정리 연출) → 준비 … → 완료 / 실패.
## 패배(플레이어 사망·산장 파괴)는 피해가 들어온 즉시 확정되며, 같은 프레임의 웨이브 완료보다 우선한다.

const Cfg := preload("res://scripts/config.gd")

signal state_changed(state: int)

enum State { PREP, COMBAT, CLEARING, VICTORY, DEFEAT }

var game
var state := State.PREP
var wave_index := 0
var prep_elapsed := 0.0
var clear_timer := 0.0
var defeat_reason := ""
var play_time := 0.0


func _ready() -> void:
	name = "GameSession"


func start() -> void:
	_enter_prep()


func prep_remaining() -> float:
	return maxf(Cfg.PREP_TIME - prep_elapsed, 0.0)


func is_over() -> bool:
	return state == State.VICTORY or state == State.DEFEAT


func day() -> int:
	return wave_index + 1


func _enter_prep() -> void:
	state = State.PREP
	prep_elapsed = 0.0
	game.economy.begin_prep()
	# 새 낮: 생산·고용 기회만 갱신하고 미사용 카드는 그대로 유지한다(v0.3 §10)
	var wool: int = game.world.pasture.produce_wool(day())
	if wool > 0:
		game.toast("양 %d마리의 털이 자랐습니다 — 양을 클릭해 수확" % wool, Color(1.0, 0.97, 0.85))
	game.contracts.on_prep_start()
	state_changed.emit(state)


func _process(delta: float) -> void:
	if is_over():
		return
	play_time += delta
	match state:
		State.PREP:
			prep_elapsed += delta
			game.economy.update_prep(prep_elapsed)
			if prep_elapsed >= Cfg.PREP_TIME:
				start_wave()
		State.COMBAT:
			if game.waves.is_wave_done():
				_on_wave_cleared()
		State.CLEARING:
			clear_timer -= delta
			if clear_timer <= 0.0:
				_after_clear()


func start_wave() -> void:
	if state != State.PREP:
		return
	game.economy.end_prep()
	wave_index += 1
	state = State.COMBAT
	game.dragon.on_wave_start()
	game.player.cancel_harvest()
	game.contracts.on_wave_start()
	game.waves.start_wave(wave_index)
	game.toast("웨이브 %d — 숲에서 괴물이 몰려옵니다!" % wave_index, Color(1.0, 0.6, 0.6))
	state_changed.emit(state)


func _on_wave_cleared() -> void:
	if state != State.COMBAT:
		return
	game.waves.stop()
	state = State.CLEARING
	game.contracts.on_combat_end()
	var leave: float = game.dragon.dismiss()
	clear_timer = maxf(leave, 2.0)
	game.toast("웨이브 %d 정리!" % wave_index, Color(0.8, 1.0, 0.8))
	state_changed.emit(state)


func _after_clear() -> void:
	if is_over():
		return
	if wave_index >= Cfg.WAVES.size():
		state = State.VICTORY
		get_tree().paused = true
		state_changed.emit(state)
	else:
		_enter_prep()


func report_defeat(reason: String) -> void:
	if is_over():
		return
	state = State.DEFEAT
	defeat_reason = reason
	get_tree().paused = true
	state_changed.emit(state)
