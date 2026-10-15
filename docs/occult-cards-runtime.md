# 숲 확장 카드 — 게임 적용

2026-10-15 · Godot 4.7.2

새 게임 시작 손패는 기존 4장에 **잠자는 가시 씨앗·목장의 검은 양**을 한 장씩 더한 6장이다. 기존 실행 중인 게임에는 자동으로 지급하지 않으며 새 게임에서 확인한다.

| 카드/생산물 | 사용 | 동작 |
| --- | --- | --- |
| 잠자는 가시 씨앗 | 낮에 보이는 이동 가능한 땅으로 드래그 | 낮 18초 동안 성장. 밤에는 반경 2.1m의 적에게 1.2초마다 피해 6과 이동 속도 35% 적용. 덜 자란 상태는 피해 3, 이동 속도 65%. |
| 목장의 검은 양 | 낮에 빈 목장으로 드래그 | 일반 양과 같은 목장 자리·체력·도망·피격·사망 규칙. 다음 날부터 하루 한 번 검은 털을 생산. |
| 검은 털 | 검은 양을 클릭해 실제 털 깎기로 수확 | 수량을 묶는 재료 카드. 가시 씨앗/방책에 드래그해 1개 봉헌. 즉시 완전 성장, 최대 체력 130, 공격력 10, 체력 전체 회복. |

가시 방책은 별도 동시 상한 4개이며 용병 활동 정원을 차지하지 않는다. 서로 1.6m 이상 떨어져 심는다. 밤 전투가 끝나도 생존한 방책은 남는다. 밤에는 새로 심을 수 없지만 검은 털로 회복할 수 있다. 이미 강화되고 체력이 가득 찬 방책에는 재료를 소비하지 않는다.

검은 양은 입식 당일에는 털이 없고 다음 낮부터 생산한다. 미수확분은 1회분만 유지한다. 일반 양은 기존 흰 양털을 생산한다. 검은 양은 개별 메시 재질을 바꾸므로 다른 양의 재질에 영향을 주지 않는다.

## 구현

- 카드 정의·텍스처: `godot/assets/cards/catalog.json`. 검은 털은 내장 image_gen으로 추가 제작했다. [생성 프롬프트](prompts/cards/black-wool-v01-prompt.md).
- 시작 지급과 시험 수치: `godot/scripts/config.gd`.
- 판정·소비: `godot/scripts/game/card_use_resolver.gd`.
- 씨앗 모델·낮 성장·밤 공격·공물·피격: `godot/scripts/actors/thorn_seed.gd`.
- 검은 양 입식·생산: `godot/scripts/world/pasture.gd`, `godot/scripts/actors/sheep.gd`.
- 실제 털 깎기 보상: `godot/scripts/actors/player.gd`.
- 적은 근처의 가시 방책을 용병과 같은 근접 방어 대상으로 인식한다. 방책은 별도 그룹이므로 직업 임무·자원 운반·무덤 처리에 섞이지 않는다.
- 손패 도움말·목장/공물 대상 강조, 검은 털 수확 알림을 연결했다.

## 검증

- `tools/verify_occult_cards.gd`: 실제 게임 장면의 카드 드래그 판정과 소비, 시작 손패, 성장/야간 제한, 목장 정원, 다음 날 생산, 실제 털 깎기, 공물 강화/회복, 적 감속/피해/방책 공격, 파괴 후 정리. **36개 검사 통과**.
- `tools/verify_new_cards.gd`: 기존 서리 룬·수호 등불·숙박 초대장·새끼양 **22개 검사 통과**.
- 내보낸 PCK를 독립 실행해 같은 **36개 검사 통과**. 검증 도구만 외부 소스에서 읽고 게임 스크립트·카탈로그·텍스처는 PCK에서 로딩했다. 결과는 `output/occult-cards-runtime/pack-verification.json`.
- 결과: `output/occult-cards-runtime/verification.json`, `godot/art_sources/new-cards-verify.json`.
- 실제 렌더 캡처: `output/occult-cards-runtime/game-applied.png`.

수치는 첫 시험값이며 장기 경제와 난이도 밸런스는 후속 플레이테스트 대상이다.

소스 실행용 `게임실행.bat`와 독립 실행용 `build/WitchsLodge.exe` 모두 새 게임에서 적용된다. 독립 실행 데이터는 검증한 PCK를 `build/WitchsLodge.pck`로 복사하고 SHA-256 일치를 확인했다. 이전 데이터는 `build/WitchsLodge-before-occult-cards-v01.pck`에 보존했다.
