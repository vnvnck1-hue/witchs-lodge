# 용비늘 — 용 소환을 카드로 (2026-10-24)

## 사용자 요청 (그대로)

> 이제 용을 소환하려면 전투중에 몬스터에게 드랍되는 [용비늘]을 얻어서 사용해야 하는것으로 바꿔줘.
> 용 소환 버튼은 이제 아예 삭제해주고, 그대신 이제 몬스터들에게 0.1% 확률로 [용비늘] 이라는 카드를 얻을 수 있도록 해줘.

## 확정 사항 (2026-10-24 질문 답변)

| 항목 | 결정 |
| --- | --- |
| 용 공물 버튼(120G) | **삭제.** HUD 오른쪽 아래에는 산장 관리 버튼만 남고 모서리로 옮겼다. 골드로 용을 부르는 길은 없다 |
| 드랍 | 일반 적 처치 시 **0.1%**(`Cfg.DRAGON_SCALE_DROP`), **보스는 확정**(빈 굴의 주인·니벨라). 말라의 외알 안경(드랍 ×1.5)을 낀 용병이 처치하면 0.15% |
| 사용 | **밤 전투 중 산장(지붕)에 끌어 놓기.** 지붕에 용이 내려와 2초마다 가장 밀집한 적 무리에 불덩이(피해 200). 웨이브가 끝나면 떠난다. 웨이브당 1번, 카드 1장 소비, 골드 없음 |
| 카드 | id `dragon_scale`, 밤 카드(낮에 얻으면 주머니로), 유물 포맷, 상인 좌판에 오르지 않음 |
| 원화 | Codex 에 요청([요청서](handoff/codex-dragon-scale-card-v01.md)). 도착 전에는 마가목 부적 그림을 임시로 쓴다 |
| 디버그(F1) | `용 강제 소환` → **`용비늘 얻기`**(카드 1장 지급) |

## 구현

| 부분 | 파일 |
| --- | --- |
| 카드 문구 | `godot/assets/cards/catalog.json`·`catalog_en.json`, 판 프로파일 `text_layout.json`(마가목 부적과 같은 유물 판) |
| 드랍 판정 | `scripts/dragon/dragon_defense.gd` `scale_drop_chance()`·`on_enemy_killed()` — `kill_gold.on_enemy_killed`(일반 괴물·맹독 곤충·빈 굴의 주인)와 `nivella_boss.die` 가 부른다 |
| 사용 | `scripts/game/card_use_resolver.gd` `_eval_dragon_scale` → 행동 `"dragon"`(소비 후 `dragon.summon()`). 막히는 사유는 `dragon.block_reason()` 하나로 손패 설명과 공유 |
| 버튼 삭제 | `scripts/ui/moon/moon_hud.gd`, `scripts/game/lodge_economy.gd`(`"dragon"` 구매 항목 제거), `config.gd`(`COST_DRAGON` 제거) |

## 검증

```text
.tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_dragon_scale.gd
```

카드 데이터·영문·판 프로파일·상인 제외, 버튼 없음·디버그 항목, 낮 사용 거부, 0.1% 판정(1만 번 굴림), 보스 실제 처치 경로 드랍, 밤 드랍은 손패로,
땅에 놓으면 거부·산장에 놓으면 소환·카드 소비·골드 불변, 같은 웨이브 두 번째 거부(카드 보존), 손패 설명, 용의 실제 공격, 다음 웨이브 재사용.
`verify_moon_runtime.gd`·`verify_game_sfx.gd`·`autoplay_check.gd`·`capture_ui_audit.gd` 의 용 버튼 사용을 새 흐름으로 바꿨다.
