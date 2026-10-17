# 볼륨 확장 카드 v01 · 납품 파일 목록

2026-10-17 · 내장 image_gen · 12종 × 원본/게임용/손패용 = 요청 PNG 36개 + rounded 사본 12개.

| ID | 정식 원본 | rounded 사본 | 게임용 | 손패용 |
| --- | --- | --- | --- | --- |
| moss_bandage | [PNG](../../art/cards/role-format-v02/moss_bandage.png) | [PNG](../../art/cards/rounded/moss_bandage.png) | [PNG](../../godot/assets/cards/moss_bandage.png) | [PNG](../../godot/assets/cards/hand/moss_bandage.png) |
| resin_torch | [PNG](../../art/cards/role-format-v02/resin_torch.png) | [PNG](../../art/cards/rounded/resin_torch.png) | [PNG](../../godot/assets/cards/resin_torch.png) | [PNG](../../godot/assets/cards/hand/resin_torch.png) |
| firefly_swarm | [PNG](../../art/cards/role-format-v02/firefly_swarm.png) | [PNG](../../art/cards/rounded/firefly_swarm.png) | [PNG](../../godot/assets/cards/firefly_swarm.png) | [PNG](../../godot/assets/cards/hand/firefly_swarm.png) |
| vine_snare | [PNG](../../art/cards/role-format-v02/vine_snare.png) | [PNG](../../art/cards/rounded/vine_snare.png) | [PNG](../../godot/assets/cards/vine_snare.png) | [PNG](../../godot/assets/cards/hand/vine_snare.png) |
| winter_firewood | [PNG](../../art/cards/role-format-v02/winter_firewood.png) | [PNG](../../art/cards/rounded/winter_firewood.png) | [PNG](../../godot/assets/cards/winter_firewood.png) | [PNG](../../godot/assets/cards/hand/winter_firewood.png) |
| shroud_cloth | [PNG](../../art/cards/role-format-v02/shroud_cloth.png) | [PNG](../../art/cards/rounded/shroud_cloth.png) | [PNG](../../godot/assets/cards/shroud_cloth.png) | [PNG](../../godot/assets/cards/hand/shroud_cloth.png) |
| thorn_bind | [PNG](../../art/cards/role-format-v02/thorn_bind.png) | [PNG](../../art/cards/rounded/thorn_bind.png) | [PNG](../../godot/assets/cards/thorn_bind.png) | [PNG](../../godot/assets/cards/hand/thorn_bind.png) |
| red_chalice | [PNG](../../art/cards/role-format-v02/red_chalice.png) | [PNG](../../art/cards/rounded/red_chalice.png) | [PNG](../../godot/assets/cards/red_chalice.png) | [PNG](../../godot/assets/cards/hand/red_chalice.png) |
| hibernation_pelt | [PNG](../../art/cards/role-format-v02/hibernation_pelt.png) | [PNG](../../art/cards/rounded/hibernation_pelt.png) | [PNG](../../godot/assets/cards/hibernation_pelt.png) | [PNG](../../godot/assets/cards/hand/hibernation_pelt.png) |
| corrupt_prayer | [PNG](../../art/cards/role-format-v02/corrupt_prayer.png) | [PNG](../../art/cards/rounded/corrupt_prayer.png) | [PNG](../../godot/assets/cards/corrupt_prayer.png) | [PNG](../../godot/assets/cards/hand/corrupt_prayer.png) |
| poison_spore | [PNG](../../art/cards/role-format-v02/poison_spore.png) | [PNG](../../art/cards/rounded/poison_spore.png) | [PNG](../../godot/assets/cards/poison_spore.png) | [PNG](../../godot/assets/cards/hand/poison_spore.png) |
| cursed_whisper | [PNG](../../art/cards/role-format-v02/cursed_whisper.png) | [PNG](../../art/cards/rounded/cursed_whisper.png) | [PNG](../../godot/assets/cards/cursed_whisper.png) | [PNG](../../godot/assets/cards/hand/cursed_whisper.png) |

검증: `RESULT 1334/1334`, 종료 코드 0, 39장/78개 배포 텍스처, 실패 0. [납품 해시·알파 검사](delivery-manifest.json) · [전체 카드 검증](../../godot/assets/cards/verification.json) · [실제 렌더 갤러리](../../godot/screenshots/cards/asset-gallery.png) · [확대 문구 검수](../../art/cards/expansion-cards-v01-review.md).

문서/도구:

- `docs/handoff/codex-expansion-cards-v01.md` — 말미 납품 결과
- `docs/prompts/cards/expansion-cards-v01-prompts.md` — 실제 전체 호출 문자열과 수정 이력
- `art/cards/README.md`, `art/cards/manifest.json`, `art/cards/expansion-cards-v01-review.md`
- `godot/tools/package_card_assets.gd`, `godot/tools/verify_card_assets.gd` — 39장 패키징·문구 대조·검증
- `godot/tools/preview_expansion_card_assets.gd` — 실제 임포트 텍스처 갤러리
- `tools/run_expansion_card_pipeline.ps1`, `tools/record_expansion_cards.py` — 재현·추가 검사

근거: `generation-plan.json`, `generation-results.json`, `repair-results.json`, `baseline.json`, `delivery-manifest.json`, `packaging.log`, `import.log`, `card-verify.log`, `gallery.log`. 원시 생성 22개 PNG와 제외본은 `generated/`, 교체 전 임시 PNG 24개와 기타 7개 파일은 `before/`, 최종 문구 1:1 크롭 12개는 `text-proof/`에 보존했다.

기존 카드/승인 PNG 118개 해시 일치. 수정 금지 경로의 동시 변경은 보존했다. 카탈로그·게임 코드·PCK 작업과 커밋은 수행하지 않았다.

