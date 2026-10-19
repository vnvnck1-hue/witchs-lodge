# 인수인계 — 종족·언데드·화합 카드 v1 (2026-10-20 08시 기준)

카드 컨셉 검토 2라운드 판정(승인 41 + 코멘트만 2 = 43장)을 게임에 적용한 작업의 이어 하기 문서다.
규칙·수치·구조는 [종족·언데드·화합 카드 v1](../race-cards-v01.md), 원화 요청은 [코덱스 요청서](codex-race-cards-v01.md)에 있다.

## 1. 끝난 것

| 항목 | 상태 | 커밋 |
| --- | --- | --- |
| 카드 43장 게임 적용(효과·카탈로그·시간대·장비 9종) | 완료 | `280a418` |
| 전 종족 용병 대화 이벤트 33건(사건 카드 10장 포함) | 완료 | `280a418` |
| 산장의 소문(평판) + 화면 막대(왼쪽 위 장비 칸 옆) | 완료 | `280a418` |
| 언데드 진입(묘지 확장·제단 복구 → 제물의 단검, 첫 사용으로 해금, 쓰러진 용병 자동 시체) | 완료 | `280a418` |
| 선택 창(오퍼 화면 '선택' 모드, 여러 줄) · 시설·소환물 블록아웃 | 완료 | `280a418` |
| 검토 키트 `cards.json` 43장 `approved`·`applied`, 3라운드 기록, 페이지 재생성 | 완료 | `280a418` |
| 헤드리스 검증 `verify_race_cards` **111/111** | 통과 | `280a418` |
| 카드 원화 **15/43장** 게임 반영 + 실행파일 재내보내기(03:55판) | 부분 | `09aba97`·`ea631d8`·`f18dffd` + 이 문서 커밋(원본·초안·시트·기록) |

사용자 결정(2026-10-19): 평판은 막대로 표시 · 언데드는 단검 사용이 트리거, 쓰러질 때마다 묻지 않음 · 3D는 블록아웃 · 사건 카드는 용병 대화 이벤트. 코멘트 반영 내용은 [race-cards-v01 §0](../race-cards-v01.md).

## 2. 남은 것 — 카드 원화 28장

납품 완료 15장: 요정 4(`fae_swap` `dream_journal` `thistle_oath` `forest_promise`) · 드워프 6(`rune_hammer` `dark_ale` `stone_wall` `ancestor_shield` `mine_prop` `stone_song`) · 수인 3(`pack_scent` `porter_pack` `hibernation`) · 언데드 2(`sacrifice_dagger` `corpse`).

| 갈래 | 요청 파일 | 남은 카드 |
| --- | --- | --- |
| A | `output/race-cards-v01/codex-request-A.txt` | 오크 8(`war_drum` `feast_table` `blood_oath` `bone_throw` `victory_roar` `ancestor_path` `ash_sigil` `spit_roast`) + `battle_ration` = **9** |
| B | `output/race-cards-v01/codex-request-B.txt` | 인간 6(`introduction_letter` `guild_writ` `village_militia` `old_records` `pilgrim_blessing` `merchant_wagon`) + 화합 3(`crest_banner` `interpreter_pen` `lodge_festival`) + 중립 2(`stranger_gift` `lodge_cleanup`) = **11** |
| C | `output/race-cards-v01/codex-request-C.txt` | 언데드 8(`rise_up` `bone_barricade` `soul_jar` `ghoul_feast` `death_march` `bone_hounds` `black_rumor` `ledger_of_dead`) |

원화가 없는 카드는 게임에서 카드 뒷면으로 보인다(기능은 정상). `verify_card_art_coverage`는 남은 28장을 미납으로 센다.

### 2.1 코덱스 다시 돌리는 법

- **막힌 이유:** ChatGPT 코덱스 **사용량 한도**. 3갈래 병렬이면 한도 한 번에 10장 남짓 그린다. 마지막 안내는 "try again at 8:41 AM"(2026-10-20).
- **08:42 자동 재시작은 실행되지 않았다**(그 대화 세션이 끝나면서 대기 작업도 종료). 아래를 직접 실행한다.
- **CLI 경로 주의:** `~/.codex/.sandbox-bin/codex.exe`는 `codex-code-mode-host.exe`가 없어 도구를 못 쓴다. **앱에 딸린 CLI**를 쓴다.

```bash
cd "C:/Users/vnvnc/Documents/ChatGPT/마녀산장"
CX="$LOCALAPPDATA/OpenAI/Codex/bin/896a0166b774037a/codex.exe"
for L in A B C; do ( cat output/race-cards-v01/codex-request-$L.txt; echo; echo "## 이어서 하기"; echo "art/cards/race-cards-v01/ 에 이미 있는 카드는 다시 만들지 말고, 아직 없는 이 갈래 카드부터 이어서 만드세요." ) | "$CX" exec -C "$(pwd -W)" -s workspace-write - >> output/race-cards-v01/codex-run-$L.log 2>&1 & sleep 5; done; wait
```

- 코덱스 앱 버전이 바뀌면 `bin/<해시>` 폴더 이름이 달라진다: `Get-ChildItem $env:LOCALAPPDATA\OpenAI\Codex\bin -Recurse -Filter codex.exe`.
- 갈래마다 기록이 따로 쌓인다: `docs/prompts/cards/race-cards-v01-prompts-<A|B|C>.md`, `output/race-cards-v01/generation-<갈래>-<id>-vNN.json`·`verification-<갈래>.json`·`delivery-<갈래>.md`(아직 없음), 시트 `godot/screenshots/race-cards/sheet-<그룹>.png`.
- 코덱스는 게임 프로젝트에서 `--import`를 하지 않도록 지시했다(동시 실행 충돌).

### 2.2 납품 뒤 할 일(Claude)

1. 시트(`godot/screenshots/race-cards/sheet-*.png`)로 문구·포맷 확인. 게임용·손패용이 둘 다 있는지: `godot/assets/cards/<id>.png`, `godot/assets/cards/hand/<id>.png`.
2. `.tools/Godot-4.7.2.exe --headless --path godot --import` → 실행 중인 게임을 끈 뒤 `--export-release "Windows Desktop" ../WitchsLodge.exe`(약 1분, 게임이 켜져 있으면 임시 파일 이름 바꾸기에 실패).
3. 바뀐 기존 `.import`(줄바꿈만 다름)는 `git checkout --`로 되돌리고, 새 카드의 png·`.import`·원본·초안·시트·기록만 커밋.
4. `delivery-A/B/C.md`가 생기면 [코덱스 요청서](codex-race-cards-v01.md) 끝 `## 납품 결과`에 합친다.
5. 다 받으면 `verify_card_art_coverage` 재실행(새 카드 미납 0이어야 함).

## 3. 검증 상태

```text
.tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_race_cards.gd   # 111/111
```

- 회귀: `goblin_cards` 68/68 · `races` 38/38 · `world_setting` 25/25 · `pocket` 61/61 · `hand_flow` 59/59(사건 카드를 시간대 검사에서 제외) · `watchtower` 38/38 · `card_assets` · `spellbook_copy` · `wolf_blood` · `jobs` · `occult_cards` · `new_cards` 통과.
- **원래부터 실패(변경 전 커밋 `4567600`에서도 같음, 이번 작업과 무관):** `equipment` 24/30 · `chapter` 55/63 · `card_core` 3건 · `guest_events` "existing facility repair" 1건 · `first_session` 57/58.
- 실제 화면 캡처: `tools/capture_race_cards.gd` → `godot/screenshots/race-cards/01~05-*.png`(소문 막대 겹침·선택 창·블록아웃 확인용).

## 4. 열린 결정 · 다음 후보

- 길드 증서는 미사용 계약 카드만 바꾼다(활동 중 용병 직업 변경은 상태가 꼬여 보류).
- 구울의 만찬은 손패의 시체를 모두 쓴다('원하는 만큼' 선택 UI 없음).
- 평판 '음산' 이하의 고용 후보 감소·종족 기피·마녀사냥꾼은 아직 없음([덱 방향성 §5.4·§6](../deck-archetypes-v01.md)).
- 새 효과음 이름(`war_drum` `stone_song` `skeleton_rise` `sacrifice` 등)은 없으면 기존 소리로 대체 — 소리 작업 때 채운다(보고는 소리별 코멘트 칸 있는 HTML 검토 페이지).
- 카드 컨셉 검토 키트에 **미검토 47장**이 남아 있다([card-concepts.html](../../output/card-concept-review/card-concepts.html)). 다음 라운드는 사용자 판정을 받아 같은 방식으로 적용.
