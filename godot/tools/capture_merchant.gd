extends SceneTree
## 떠돌이 행상 브로크 실제 화면 캡처(docs/merchant-shop-v01.md). 헤드리스 더미 렌더러로는 확인할 수 없는
## 상점 화면의 실제 배치(간판·초상·좌판·가격표·등급 색)와 좌판 자리에 선 행상 모델을 짧게 확인한다.
## 실행(창 모드): godot --path . --script res://tools/capture_merchant.gd
## 결과: res://screenshots/merchant/*.png

const OUT := "res://screenshots/merchant/"
const SessionScript := preload("res://scripts/game/game_session.gd")
const MerchantScript := preload("res://scripts/game/merchant.gd")
const Data := preload("res://scripts/game/merchant_data.gd")

var main


func _initialize() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	_run.call_deferred()


func _wait(n: int) -> void:
	for i in n:
		await process_frame


func _shot(name: String) -> void:
	await _wait(4)
	var img := root.get_viewport().get_texture().get_image()
	img.save_png(OUT + name + ".png")
	print("SHOT ", name)


func _run() -> void:
	while current_scene == null or current_scene.get("session") == null:
		await process_frame
	main = current_scene
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	await _wait(30)
	var s = main.session
	s.wave_index = 2
	s.state = SessionScript.State.PREP
	s.prep_elapsed = Data.ARRIVE_AT + 0.1
	main.economy.batches.clear()
	await _wait(5)
	s.set_process(false)
	var m = main.merchant
	# 1. 좌판 자리에 선 행상(카메라는 기본 산장 시점)
	m.actor.position = MerchantScript.STALL_SPOT
	m.actor.route.clear()
	m.actor.visual.rotation.y = deg_to_rad(35.0)
	await _wait(40)
	await _shot("01-stall-world")
	# 2. 상점 화면(가격 구간이 섞이게 고정한 5장, 한 장은 팔림·골드 부족 표시 포함)
	var defs: Dictionary = main.cards.defs
	m.offers = ["wool", "frost_rune", "goblin_gang", "treasure_chest", "moonlit_charm"].map(
		func(id): return {"id": id, "price": Data.price_of(id, defs[id]), "sold": false})
	main.economy.gold = 50
	main.guest_arrival.root.visible = false
	main.offer_ui.open_merchant(m.offers, m.profile)
	await _wait(10)
	main.offer_ui.buy(1)
	await _wait(20)
	await _shot("02-shop")
	main.offer_ui.close()
	quit(0)
