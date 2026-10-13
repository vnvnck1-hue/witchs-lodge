# 마녀산장 카드 에셋

2026-10-13 · 내장 image_gen 생성/수정 · 카드 코어 기획 v0.3 기준

![카드 전체 미리보기](../../godot/screenshots/cards/asset-gallery.png)

현재 기획의 등장 카드 **도끼 용병·양털·목재·숲의 괴물** 네 종류와 공용 뒷면이다. 기존 세 카드의 원화·한글·비대칭 S자 포맷을 이어가고, 빠져 있던 목재 카드를 추가했다. 네 모서리를 살짝 둥글게 처리하고 카드 밖의 검정 사각 여백을 투명 알파로 교체했다.

| 에셋 | 원화 수정/생성본 | 게임용 PNG |
| --- | --- | --- |
| 도끼 용병 | [원화](rounded/axe_mercenary.png) | [1024×1536](../../godot/assets/cards/axe_mercenary.png) |
| 양털 | [원화](rounded/wool.png) | [1024×1536](../../godot/assets/cards/wool.png) |
| 목재 | [원화](rounded/timber.png) | [1024×1536](../../godot/assets/cards/timber.png) |
| 숲의 괴물 | [원화](rounded/forest_monster.png) | [1024×1536](../../godot/assets/cards/forest_monster.png) |
| 공용 뒷면 | [원화](rounded/card_back.png) | [1024×1536](../../godot/assets/cards/card_back.png) |

모든 게임용 PNG는 **RGBA, 세로 2:3**이다. [손패용 PNG](../../godot/assets/cards/hand/)는 같은 파일명으로 **256×384**를 제공한다. 확대·상세 화면에는 큰 파일을, 일반 손패에는 작은 파일을 쓴다. PNG에 배경색이나 그림자를 합성하지 않아 월드나 밝은 패널 위에서도 라운드 외곽이 드러난다. 그림자는 UI에서 별도로 처리한다.

[카드 데이터](../../godot/assets/cards/catalog.json)는 이름·분류·인쇄 문구·상세 설명·획득 경로·대상 태그·수량 묶음 여부·텍스처 경로를 담는다. 가격·체력·공격력·작업 시간·하수인 수명 등 시험 중인 수치는 이미지에 고정하지 않았다. 자원 수량과 상세 설명은 런타임 UI로 표시한다. 도끼 용병 원화의 짧은 문구는 벌목 사용법을 표시하며 상세 설명에는 전투 사용도 포함했다.

골드·증축·유료 수리·마녀 회복·양 구입·용 공물은 v0.3에서 공용 수치와 관리 UI로 유지한다. 이 행위를 새 획득 카드로 만들지 않았다. 후속 제작물·전문 용병·다른 몬스터는 아직 카드 이름과 효과가 정해지지 않아 현재 세트에 포함하지 않는다.

## Godot에서 사용

프로젝트 안의 `res://assets/cards/` 경로를 사용한다. 프로젝트 밖 원화 경로는 배포 코드에서 사용하지 않는다. `export_presets.cfg`에 카드 JSON 포함 필터도 설정했다.

```gdscript
const Cards = preload("res://scripts/ui/card_catalog.gd")

card_texture.texture = Cards.texture("axe_mercenary", true) # 손패
detail_texture.texture = Cards.texture("axe_mercenary")    # 확대
back_texture.texture = Cards.back()
var details := Cards.find("timber")
tooltip_label.text = details.description
```

카드 텍스처에 월드 조명·색보정을 적용하지 않고 `TextureRect`의 `STRETCH_KEEP_ASPECT_CENTERED`로 비율을 유지한다. 게임의 손패(`scripts/ui/card_hand.gd`)와 카드 소유 기록(`scripts/game/card_inventory.gd`)이 이 카탈로그를 읽는다. 획득·드래그·소환 규칙은 [카드 코어 C0 구현 기록](../../docs/card-core-c0-implementation.md)을 본다.

## 재생성과 확인

수정 전 승인 원본과 이전 시안은 `art/concepts/cards/`에 보존한다. 현재 사용할 원화는 이 폴더의 `rounded/`, 게임에 넣을 최종본은 `godot/assets/cards/`다. [최종 프롬프트](../../docs/prompts/cards/production-rounded-v02-prompts.md)와 [파일 목록·해시](manifest.json)를 함께 보관한다.

```powershell
$cardLogDir = (Resolve-Path godot/art_sources).Path
& '.tools/Godot-4.7.2.exe' --headless --path godot --log-file "$cardLogDir/card-package.log" --script res://tools/package_card_assets.gd
& '.tools/Godot-4.7.2.exe' --headless --path godot --log-file "$cardLogDir/card-import.log" --editor --import
& '.tools/Godot-4.7.2.exe' --headless --path godot --log-file "$cardLogDir/card-verify.log" --script res://tools/verify_card_assets.gd
& '.tools/Godot-4.7.2.exe' --path godot --log-file "$cardLogDir/card-preview.log" --script res://tools/preview_card_assets.gd
```

패키징은 90% 이상 불투명한 카드 본체를 기준으로 바깥 여백을 크롭하고 크기를 통일한다. 원화·문구·생성 알파는 유지하며 새 그림이나 라운드 마스크를 그리지 않는다. 검증은 10개 PNG의 크기·RGBA·투명한 네 모서리·불투명한 중앙·Godot 텍스처 로딩과 네 카드 ID를 확인한다. 별도 미리보기는 밝고 어두운 배경 위에 실제 임포트된 PNG와 손패 크기를 렌더한다.

### 납품 검증 결과

- [PNG 및 로딩 검사](../../godot/assets/cards/verification.json): 네 카드·공용 뒷면의 10개 텍스처 모두 통과. 네 모서리 투명도와 카드 본체 네 변의 불투명도도 확인했다.
- [갤러리](../../godot/screenshots/cards/asset-gallery.png): 최종 PNG를 실제 Godot로 렌더해 원화·한글·라운드 경계·손패 크기를 확인했다.
- [배포 포함 검사](export-verification.json): 별도 Windows Desktop PCK를 내보내고 그 패키지에서 JSON 및 10개 텍스처의 로딩까지 통과했다. 테스트 PCK는 확인 후 제거했다.
