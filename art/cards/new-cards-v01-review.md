# 신규 카드 v01 납품·확대 검수 기록

2026-10-15 · [요청서](../../docs/handoff/codex-new-cards-v01.md) · 생성 도구: 내장 image_gen

## 납품 파일

각 ID에 아래 세 경로의 PNG가 있다. 신규 납품은 총 **12개 PNG**다.

| ID | 이름 | 원화 | 게임용 | 손패용 |
| --- | --- | --- | --- | --- |
| frost_rune | 서리 룬 | [PNG](rounded/frost_rune.png) | [PNG](../../godot/assets/cards/frost_rune.png) | [PNG](../../godot/assets/cards/hand/frost_rune.png) |
| ward_lantern | 수호 등불 | [PNG](rounded/ward_lantern.png) | [PNG](../../godot/assets/cards/ward_lantern.png) | [PNG](../../godot/assets/cards/hand/ward_lantern.png) |
| guest_invitation | 숙박 초대장 | [PNG](rounded/guest_invitation.png) | [PNG](../../godot/assets/cards/guest_invitation.png) | [PNG](../../godot/assets/cards/hand/guest_invitation.png) |
| lamb | 새끼양 | [PNG](rounded/lamb.png) | [PNG](../../godot/assets/cards/lamb.png) | [PNG](../../godot/assets/cards/hand/lamb.png) |

원화와 게임용은 1024×1536, 손패용은 256×384, 모두 RGBA다. 생성 PNG를 프로젝트로 복사했고, Godot 패키징은 생성 알파를 유지한 크롭·리사이즈만 수행했다.

## 최종 인쇄 문구 확대 확인

[인쇄 문구 모음](../../godot/screenshots/cards/new-cards-v01-text-proof.png)은 **최종 게임용 PNG의 제목/분류/본문을 원본 픽셀 크기로 잘라 모은 2048×1360 검수 이미지**다. 새 글씨를 덧쓰지 않았다. 이 이미지를 원본 해상도로 직접 열어 아래 문구와 글자·띄어쓰기·마침표를 대조했고, 오탈자를 발견하지 않았다.

| 이름 | 분류 | 본문 1줄 | 본문 2줄 | 결과 |
| --- | --- | --- | --- | --- |
| 서리 룬 | 주문 · 마녀의 룬 | 적이나 땅에 새기면 터집니다. | 주변 적을 얼려 느리게 합니다. | 일치 |
| 수호 등불 | 설치물 · 마녀의 등불 | 땅에 놓으면 불을 밝힙니다. | 빛 안의 적은 느려집니다. | 일치 |
| 숙박 초대장 | 산장 · 손님 초대 | 산장에 놓으면 손님이 옵니다. | 낮에만 사용할 수 있습니다. | 일치 |
| 새끼양 | 가축 · 목장 입식 | 목장에 놓으면 새끼양이 옵니다. | 이틀 뒤 어른 양이 됩니다. | 일치 |

최종 [8종+뒷면 갤러리](../../godot/screenshots/cards/asset-gallery.png)도 실제 Godot 임포트 텍스처로 렌더한 뒤 열어 확인했다. 보라 프레임·비대칭 검은 S자 곡선·크림색 패널·굵은 한글·붓터치가 기존 4종과 한 세트를 이룬다. 서리 룬의 달 문양/방사형 결정/찬 김, 등불의 굽은 장대/따뜻한 빛/나방, 초대장의 달·전나무 밀랍 봉인/리본/산장, 새끼양의 크림색 털/방울/건초/울타리를 확인했다. 가격·체력·지속시간 등의 시험 수치는 없다. “이틀 뒤”는 요청서 지정 본문이다.

## 기술 검증

- [verification.json](../../godot/assets/cards/verification.json): `passed=true`, `texture_count=18`, `failures=[]`.
- 8개 ID와 공용 뒷면, 크기·RGBA·네 모서리 알파·중앙/외곽 불투명도·실제 Godot 텍스처 로딩/크기를 검사했다.
- 신규 카드의 이름·분류·본문 두 줄을 현재 카탈로그와 요청서 기준으로 비교했다. 없는 ID는 현재 카탈로그 구현에 따라 공용 뒷면으로 대체되는지 검사한다.
- 최종 PNG를 Godot 4.7.2에 재임포트한 뒤 검증했다. OpenGL Compatibility 렌더링으로 갤러리와 문구 검수 PNG를 저장했으며 두 작업의 반환값은 `OK(0)`이다.
- [manifest.json](manifest.json): 원화 9개+배포 PNG 18개, 총 27개 파일의 크기·모드·바이트 수·SHA-256·알파 메타데이터를 갱신했다. 별도 PowerShell SHA-256 대조에서 **27개 모두 일치**했다.
- 기존 4종+뒷면의 배포 PNG 10개는 제작 전 manifest의 SHA-256과 대조해 **변경 없음**을 확인했다.
- Godot의 시스템 인증서 저장소 읽기 오류는 로그에 남았지만 로컬 에셋 검사와 렌더링은 정상 완료했다.
- 신규 카드의 PCK 내보내기는 이번 검증 범위에 포함하지 않았다. 기존 `export-verification.json`은 2026-10-13 기존 세트의 기록이다.

## 갱신한 보조 파일

- `art/cards/README.md`, `art/cards/manifest.json`, 이 검수 기록.
- `docs/prompts/cards/new-cards-v01-prompts.md`: 모든 제작 프롬프트와 채택/미채택 보정 경과.
- `godot/tools/package_card_assets.gd`: 8종+뒷면 패키징.
- `godot/tools/verify_card_assets.gd`: 18개 텍스처와 신규 문구 검사.
- `godot/tools/preview_card_assets.gd`: 3×3 갤러리와 원본 크기 문구 검수 이미지.
- `godot/tools/update_card_manifest.gd`: 생성 이력과 파일 해시/메타데이터 재생성.
- `godot/assets/cards/packaging.json`, `godot/assets/cards/verification.json`.
- `godot/screenshots/cards/asset-gallery.png`, `godot/screenshots/cards/new-cards-v01-text-proof.png`.
- 신규 게임용/손패용 PNG의 Godot 자동 생성 `.import` 메타데이터.

`godot/scripts/**`, `godot/assets/cards/catalog.json`, `godot/scenes/**`는 이 작업에서 직접 수정하지 않았다. 제작 중 동시 작업으로 두 게스트 UI 스크립트가 바뀐 것을 읽기 전용 해시 비교에서 확인했으며 되돌리지 않았다. Git 커밋은 하지 않았다.
