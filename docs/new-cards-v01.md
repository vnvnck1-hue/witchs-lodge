# 신규 카드 v01 — 서리 룬 · 수호 등불 · 숙박 초대장 · 새끼양

2026-10-15 · 구현 Claude · 카드 원화 Codex([요청서](handoff/codex-new-cards-v01.md))

첫 시작 손패가 비어 있던 문제를 풀기 위해 만든 카드 4종이다. 게임을 시작하면 네 장을 한 장씩 손패로 받는다(`Cfg.STARTER_CARDS`). 마녀의 주문·설치물·산장 운영·목장 확장을 한 장씩 맛보게 하는 구성이다.

## 카드 규칙

| 카드 | 사용 시점 | 대상 | 효과 |
|---|---|---|---|
| 서리 룬 `frost_rune` | 밤 전투 중 | 적 또는 이동 가능한 지면 | 반경 2.6m 즉시 피해 18 + 5초 동안 이동 속도 45% |
| 수호 등불 `ward_lantern` | 낮·밤 전투 | 이동 가능한 지면 | 반경 3.5m 안의 적 이동 속도 65%, 반경 5m 안개 제거. 그날 밤 전투가 끝나면 꺼짐. 동시 2개까지 |
| 숙박 초대장 `guest_invitation` | 낮(준비 시간 22초 이상 남음) | 산장 | 손님 한 무리(정원만큼)가 즉시 도착 → 20초 뒤 숙박비 → 한 명 고용 제안 |
| 새끼양 `lamb` | 낮 | 목장(빈자리 필요) | 새끼양 입식. 체력 15, 크기 0.6배, 털 없음. **들인 날 +2일 낮 시작에 어른 양으로 자라 그날 바로 털 수확 가능** |

새끼양 예시: 1일차 낮에 들이면 → 2일차 낮에는 아직 새끼양 → 3일차 낮이 시작될 때 어른 양으로 자라고 털이 바로 준비된다. 남은 날은 마녀가 새끼양 2.4m 안으로 다가갈 때만 작은 말풍선("음매~ 2일 뒤면 다 자라요")으로 보인다(`godot/scripts/ui/lamb_bubble.gd`). 새끼양도 목장 정원을 차지하며, 적의 표적이 될 수 있다.

수치는 모두 `godot/scripts/config.gd`의 "신규 카드 v01" 절에 있는 시험값이다.

## 구현 위치

- 카드 데이터: `godot/assets/cards/catalog.json` (원화가 없으면 `card_catalog.gd`가 공용 뒷면으로 대체)
- 판정·사용: `godot/scripts/game/card_use_resolver.gd` (`_eval_frost/_eval_lantern/_eval_invite/_eval_lamb`, `commit`)
- 서리 룬 폭발·문양: `godot/scripts/actors/frost_rune.gd`
- 수호 등불 모델·감속·소등: `godot/scripts/actors/ward_lantern.gd`, 안개 제거는 `fog_of_war.gd`의 `sight_sources` 그룹
- 적 감속: `godot/scripts/actors/monster.gd` (`apply_slow`, 출처별 배율 중 가장 강한 값, 발밑 서리 고리)
- 손님 초대: `godot/scripts/game/lodge_economy.gd` (`invite_block_reason`, `invite_batch`, 초대 묶음은 고용 제안 포함)
- 새끼양: `godot/scripts/actors/sheep.gd` (`is_lamb`, `grow_day`, 성장 표시 라벨, `grow_up`), `godot/scripts/world/pasture.gd` (`add_lamb`, `grow_lambs`), `game_session.gd`가 낮 시작마다 성장 → 털 생산 순으로 호출
- 손패 안내·범위 고리: `godot/scripts/ui/card_hand.gd`
- 시작 손패: `godot/scripts/main.gd` `_grant_starter_cards()` — `--script` 검증 실행이나 `--no-starter-cards` 인자에서는 지급하지 않는다(기존 검증은 빈 손패를 전제로 함). 디버그 카드 지급에도 4종 포함.

## 검증

```powershell
& '.tools/Godot-4.7.2.exe' --headless --path godot --script res://tools/verify_new_cards.gd   # 신규 카드 22개 검사
& '.tools/Godot-4.7.2.exe' --headless --path godot --script res://tools/verify_card_core.gd   # 기존 카드 코어 회귀 52개
& '.tools/Godot-4.7.2.exe' --path godot --script res://tools/capture_new_cards.gd             # 실제 화면 캡처
& '.tools/Godot-4.7.2.exe' --path godot --script res://tools/verify_guest_click_lamb.gd           # 손님 소개 클릭 넘김·새끼양 말풍선 9개(창 모드)
```

## 손님 소개 클릭 넘김

손님 소개 패널(`guest_arrival.gd`)은 글 줄이 모두 올라온 뒤(`ready_time`, 약 0.9초)부터 패널이나 초상화를 클릭하면 바로 산장으로 날아가는 다음 동작으로 넘어간다. 그 전의 클릭은 넘기지 않지만 월드로 새지 않게 소비한다. 넘길 수 있게 되면 패널 오른쪽 아래에 "클릭하여 계속 ▸"가 뜬다. 클릭하지 않으면 기존처럼 자동으로 넘어간다.

검증 결과는 `godot/art_sources/new-cards-verify.json`, 캡처는 `godot/screenshots/new-cards/`.
