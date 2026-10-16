# 기존 카드 전체 포맷 적용 v02

2026-10-16 · [카드 디자인 가이드](card-design-guide.md)에 따라 사용자가 요청한 기존 카드 전체 에셋 교체.

사용 중인 앞면 25종, 보존 중인 도끼 용병 1종, 공용 뒷면 1종을 모두 재제작했다. **원본 27장, 게임용 1024×1536 27장, 손패용 256×384 27장**이다. 카드 종류에 맞는 승인 개별 PNG와 기존 카드 원화를 각각 포맷/인물·물건 참조로 내장 image_gen에 제공했다. 생성 후 코드에서는 크롭·Lanczos 크기 정규화와 검증만 수행했다.

## 적용 결과

![전체 게임 에셋과 손패 축소본](../godot/screenshots/cards/asset-gallery.png)

| 카드 | 적용한 시각 포맷 | 새 원본 | 게임용 | 손패용 |
| --- | --- | --- | --- | --- |
| 잠자는 가시 씨앗 | 시설 | [PNG](../art/cards/role-format-v02/sleeping_thorn_seed.png) | [PNG](../godot/assets/cards/sleeping_thorn_seed.png) | [PNG](../godot/assets/cards/hand/sleeping_thorn_seed.png) |
| 목장의 검은 양 | 인물·생물 | [PNG](../art/cards/role-format-v02/black_sheep.png) | [PNG](../godot/assets/cards/black_sheep.png) | [PNG](../godot/assets/cards/hand/black_sheep.png) |
| 검은 털 | 자원 | [PNG](../art/cards/role-format-v02/black_wool.png) | [PNG](../godot/assets/cards/black_wool.png) | [PNG](../godot/assets/cards/hand/black_wool.png) |
| 양털 | 자원 | [PNG](../art/cards/role-format-v02/wool.png) | [PNG](../godot/assets/cards/wool.png) | [PNG](../godot/assets/cards/hand/wool.png) |
| 목재 | 자원 | [PNG](../art/cards/role-format-v02/timber.png) | [PNG](../godot/assets/cards/timber.png) | [PNG](../godot/assets/cards/hand/timber.png) |
| 숲의 괴물 | 인물·생물 | [PNG](../art/cards/role-format-v02/forest_monster.png) | [PNG](../godot/assets/cards/forest_monster.png) | [PNG](../godot/assets/cards/hand/forest_monster.png) |
| 서리 룬 | 스킬 | [PNG](../art/cards/role-format-v02/frost_rune.png) | [PNG](../godot/assets/cards/frost_rune.png) | [PNG](../godot/assets/cards/hand/frost_rune.png) |
| 수호 등불 | 시설 | [PNG](../art/cards/role-format-v02/ward_lantern.png) | [PNG](../godot/assets/cards/ward_lantern.png) | [PNG](../godot/assets/cards/hand/ward_lantern.png) |
| 숙박 초대장 | 사건 | [PNG](../art/cards/role-format-v02/guest_invitation.png) | [PNG](../godot/assets/cards/guest_invitation.png) | [PNG](../godot/assets/cards/hand/guest_invitation.png) |
| 새끼양 | 인물·생물 | [PNG](../art/cards/role-format-v02/lamb.png) | [PNG](../godot/assets/cards/lamb.png) | [PNG](../godot/assets/cards/hand/lamb.png) |
| 나무꾼 | 인물·생물 | [PNG](../art/cards/role-format-v02/lumberjack.png) | [PNG](../godot/assets/cards/lumberjack.png) | [PNG](../godot/assets/cards/hand/lumberjack.png) |
| 사냥꾼 | 인물·생물 | [PNG](../art/cards/role-format-v02/hunter.png) | [PNG](../godot/assets/cards/hunter.png) | [PNG](../godot/assets/cards/hand/hunter.png) |
| 전투용병 | 인물·생물 | [PNG](../art/cards/role-format-v02/warrior.png) | [PNG](../godot/assets/cards/warrior.png) | [PNG](../godot/assets/cards/hand/warrior.png) |
| 채집가 | 인물·생물 | [PNG](../art/cards/role-format-v02/gatherer.png) | [PNG](../godot/assets/cards/gatherer.png) | [PNG](../godot/assets/cards/hand/gatherer.png) |
| 생고기 | 자원 | [PNG](../art/cards/role-format-v02/raw_meat.png) | [PNG](../godot/assets/cards/raw_meat.png) | [PNG](../godot/assets/cards/hand/raw_meat.png) |
| 토끼 가죽 | 자원 | [PNG](../art/cards/role-format-v02/rabbit_pelt.png) | [PNG](../godot/assets/cards/rabbit_pelt.png) | [PNG](../godot/assets/cards/hand/rabbit_pelt.png) |
| 보물상자 | 사건 | [PNG](../art/cards/role-format-v02/treasure_chest.png) | [PNG](../godot/assets/cards/treasure_chest.png) | [PNG](../godot/assets/cards/hand/treasure_chest.png) |
| ? | 장비·유물 | [PNG](../art/cards/role-format-v02/relic_unknown.png) | [PNG](../godot/assets/cards/relic_unknown.png) | [PNG](../godot/assets/cards/hand/relic_unknown.png) |
| 달빛 부적 | 장비·유물 | [PNG](../art/cards/role-format-v02/moonlit_charm.png) | [PNG](../godot/assets/cards/moonlit_charm.png) | [PNG](../godot/assets/cards/hand/moonlit_charm.png) |
| 화로의 온기석 | 장비·유물 | [PNG](../art/cards/role-format-v02/hearth_ember.png) | [PNG](../godot/assets/cards/hearth_ember.png) | [PNG](../godot/assets/cards/hand/hearth_ember.png) |
| 고목의 심장 | 장비·유물 | [PNG](../art/cards/role-format-v02/old_tree_heart.png) | [PNG](../godot/assets/cards/old_tree_heart.png) | [PNG](../godot/assets/cards/hand/old_tree_heart.png) |
| 늑대 송곳니 목걸이 | 장비·유물 | [PNG](../art/cards/role-format-v02/wolf_fang_pendant.png) | [PNG](../godot/assets/cards/wolf_fang_pendant.png) | [PNG](../godot/assets/cards/hand/wolf_fang_pendant.png) |
| 서리 여왕의 눈물 | 장비·유물 | [PNG](../art/cards/role-format-v02/frost_queen_tear.png) | [PNG](../godot/assets/cards/frost_queen_tear.png) | [PNG](../godot/assets/cards/hand/frost_queen_tear.png) |
| 독버섯 | 스킬 | [PNG](../art/cards/role-format-v02/poison_mushroom.png) | [PNG](../godot/assets/cards/poison_mushroom.png) | [PNG](../godot/assets/cards/hand/poison_mushroom.png) |
| 오래된 마법서적 | 스킬 | [PNG](../art/cards/role-format-v02/old_spellbook.png) | [PNG](../godot/assets/cards/old_spellbook.png) | [PNG](../godot/assets/cards/hand/old_spellbook.png) |
| 도끼 용병 | 인물·생물 | [PNG](../art/cards/role-format-v02/axe_mercenary.png) | [PNG](../godot/assets/cards/axe_mercenary.png) | [PNG](../godot/assets/cards/hand/axe_mercenary.png) |
| 공용 뒷면 | 공용 뒷면 | [PNG](../art/cards/role-format-v02/card_back.png) | [PNG](../godot/assets/cards/card_back.png) | [PNG](../godot/assets/cards/hand/card_back.png) |

인물 포맷은 계약 인물·가축·소환 생물까지 확장해 적용했다. 인간 용병은 인간, 양은 가축, 숲의 괴물은 하수인 배지로 구분한다. 이 중 가축·하수인은 종족 확정이 아니라 기존 기능 표기다. 드로우 카드 두 종은 즉시 효과를 표현하는 스킬 포맷, 초대장·보물상자는 초대·발견을 표현하는 사건 포맷, 설치물·가시 씨앗은 시설 포맷으로 연결했다. **카탈로그의 kind·이름·category·printed_rules·효과 데이터는 변경하지 않았다.** 보존용 도끼 용병도 파일은 유지하며 새 포맷을 적용했다.

공용 뒷면은 보라 카드 바탕·검은 웨이브·크림색 타원·눈 덮인 산장 정체성을 유지하며 새 앞면과 선 굵기·인쇄 질감을 맞췄다. 뒷면에는 앞면의 제목·설명 패널을 넣지 않는다.

## 레이아웃·시각 검수

- 인물은 초상창과 작은 배지, 스킬은 마름모, 자원은 직사각형 창과 자원 표식, 유물은 방패, 시설은 낮은 지붕과 넓은 제목판, 사건은 접힘 배너와 장면창을 유지했다.
- 제목 2줄·설명 최소 4줄을 배치할 여백을 확보하는 제작 지시를 적용했다. 짧은 한국어 본문 때문에 설명 패널을 축소하지 않았다. 설명칸은 한 덩어리로 열어 두었다.
- 자원의 중복 가로 띠·먹선, 사건의 중앙 갈래 문양·V자 홈, 시설의 좁은 제목판·작은 설명란을 넣지 않았다.
- 생성 결과마다 기존 카드 원문과 이름·분류·효과를 직접 대조했다. 미공개 유물에 따라온 예시 효과는 제거해 본문을 비웠다. 원화의 물건·인물 정체성은 기존 카드에서 유지했다.
- 목재·보물상자·미공개 유물의 모서리 알파, 시설 2종의 보라 바탕·직사각형 외곽을 추가 수정했다. 최종 PNG만 실사용 경로에 배치했다.
- 실제 Godot 임포트 텍스처를 밝고 어두운 배경에 렌더해 전체 프레임과 손패 축소본을 확인했다. 실 렌더는 알파 합성과 축소된 이미지 확인을 위해 사용했다.

현재 결과는 한국어가 인쇄된 PNG다. 다국어용 텍스트 공간을 고려한 레이아웃이며, 동적 번역 문자열·폰트·언어별 넘침 처리를 구현 완료한 것은 아니다. 안전 영역의 좌표는 제작 목표이므로 자동 픽셀 마스크 검증이나 모든 언어의 텍스트 수용을 보장했다고 해석하지 않는다.

## 파일·검증 근거

- [전체 생성 지시와 역할 연결](../art/cards/role-format-v02/generation-plan.json), [실제 생성 파일·추가 수정 지시](../art/cards/role-format-v02/generation-results.json)
- [납품 PNG 치수·RGBA·SHA-256·픽셀 해시](../art/cards/role-format-v02/delivery-manifest.json), [실사용 에셋 manifest](../art/cards/manifest.json)
- [카드 검사](../godot/assets/cards/verification.json): 앞면 26종+뒷면, 배포 텍스처 54개, 실패 0. 모든 카드에 같은 엄격한 알파 기준을 적용하며 이전 숲 카드의 완화 프로필은 제거했다.
- `record_role_format_assets.py`: 27종 전체가 이전 원본과 달라졌는지, 새 원본과 rounded 소스가 일치하는지, 54개 배포 PNG의 크기·모서리·바깥 테두리·중앙 알파가 맞는지, 카탈로그가 교체 전과 바이트 단위로 같은지 확인했다.
- [PCK 검사](../output/role-format-v02/export-verification.json): 새 배포본의 54개 텍스처 모두 로드되며 불투명 픽셀 해시가 배포 PNG와 일치한다. Godot의 알파 테두리 보정이 바꾸는 숨겨진 RGB를 제외하기 위해 alpha<244 픽셀을 해시에서 정규화한다. 알파·모서리 검사는 별도로 수행한다.
- `build/WitchsLodge.pck`는 검증한 후보 PCK와 SHA-256이 같다. 기존 실행 파일은 이 PCK를 사용한다.

교체 전 카드 원본·게임용·손패용, 카탈로그, 기존 manifest와 PCK는 `output/role-format-v02/before/`에 보존했다. 사용자 승인 6종 참조 PNG는 수정하지 않았다. 다른 게임 구현·씬·오디오·UI 코드는 이번 작업에서 수정하지 않았다.

재현(프로젝트 루트 PowerShell):

```powershell
& ./godot/art_sources/run_role_format_asset_pipeline.ps1
# 사용 가능한 Python + Pillow로 실행. 이 환경은 Codex 번들 Python을 사용했다.
python ./godot/art_sources/record_role_format_assets.py
& ./godot/art_sources/export_role_format_assets.ps1
```

원화 재생성에는 저장된 지시와 승인 PNG를 사용한다. 위 명령은 이미 생성한 결과를 패키징·검증·내보내기한다.

