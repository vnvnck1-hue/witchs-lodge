# 달빛 UI 확장 v01

사용자 결정: **현재 원화 채택 후 게임에 적용**. 인물 포트레이트는 기존 7개 PNG만 사용한다.

- 결과: `output/ui-extension-implementation/report.html` (25개 항목, 실제 배포판 캡처, 검증 기록).
- 원화 기록: `output/ui-extension-art-v01/review/index.html`.
- 기존 HUD·손패 그림·초상·잉크 대화 연출은 유지한다. 새 창·행·버튼·말풍선·체력 바·지도 재질·결과 헤더를 확장했다.
- UI 부품: `godot/assets/ui/moon_runes/extension_v01/`. 생성된 RGBA PNG는 그대로 보존하고, `textures/*.tres`의 AtlasTexture 영역으로 나눈다. 미세한 알파 노이즈는 영역 계산에서만 제외한다.
- 공통 부품: `godot/assets/ui/moon_runes/common/` (기존 승인 그래픽 복사).
- 생성: 내장 image_gen. 최종 프롬프트 4개는 `output/ui-extension-implementation/source/`에 보존했다.
- 연결: `moon_extension.gd`가 그림·9분할 프레임·작은 화면 창 크기를 담당하고, 기존 `moon_skin.gd`와 UI 표시 스크립트에서 재사용한다. 거래·고용·대화 진행은 기존 게임 컨트롤러에 전달한다.
- 초상 원본 무결성: `output/ui-extension-implementation/portrait-integrity.json`.
- 적용 전 UI 스크립트와 PCK 백업: `output/ui-extension-implementation/before/`.

## 검증 재현

프로젝트 루트에서:

```powershell
.tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_ui_extension.gd
.tools/Godot-4.7.2.exe --path godot --script res://tools/verify_guest_events.gd -- --out=../output/ui-extension-implementation/guest-check
.tools/Godot-4.7.2.exe --path godot --script res://tools/capture_ui_audit.gd -- --out=res://screenshots/ui-extension-v01
.tools/Godot-4.7.2.exe --path godot --script res://tools/capture_ui_audit.gd -- --extras --out=res://screenshots/ui-extension-v01
.tools/Godot-4.7.2.exe --path godot --script res://tools/capture_ui_audit.gd -- --world-details --out=res://screenshots/ui-extension-v01
```

실제 렌더 캡처 사유: 헤드리스에서 확인할 수 없는 UI 이미지 색·알파·9분할 여백·기존 HUD와의 조화를 확인한다.

검증 도구의 BGM 참조는 현재 두 덱 크로스페이드 구조에 맞췄다. `background_players`에는 현재 환경음만 들어 있으므로 음악 플레이어는 `_decks`에서 확인한다. 실제 음원·재생 코드는 변경하지 않았다.

Windows 샌드박스에서 내보낼 때는 `TEMP`와 `TMP`를 쓰기 가능한 `.tools/export-temp`로 지정한다. `project.binary` 생성 실패 없이 `--headless --path godot --export-pack "Windows Desktop" ../build/WitchsLodge.pck`로 내보냈으며, 결과 PCK와 배포 실행파일에서 다시 검사한다.

## 진단 범위

헤드리스 카드 셰이더는 더미 렌더러 진단을 출력할 수 있다. 실제 렌더 검사는 이를 보완한다. 일부 검증 종료 시 기존 `card_view.gd`의 재 입자 정리에서 트리 참조 진단이 남는다. 이번 변경은 해당 카드 연출의 수명 코드를 수정하지 않는다. UI 캡처 실행에는 런타임 오류가 없다.

묘지·가시 성장·피해 숫자는 원래의 간결한 텍스트로 유지한다. 개발용 디버그 메뉴에는 공통 프레임과 버튼만 재사용한다.

## 레이아웃 정리 v01-fix (2026-10-16)

Codex 납품 뒤 사용자 지적을 반영해 UI 레이아웃을 정리했다. 그림 에셋은 바꾸지 않고 배치·여백·비율만 고쳤다.

- 손패 카드: `CARD_DESIGN` 을 2:3(98×147)으로 바꿨다. 손패 그림(`assets/cards/hand`, 256×384)이 옛 임시 카드 비율(256:308)로 눌려 보이던 문제. `MoonSkin.card_surface` 는 임시 표면의 비율이 카탈로그 그림과 다르면 쓰지 않는다. 카드 위 "계약 인물" 이름표는 규칙 문구를 가리므로 없앴고 이름은 확대 설명(툴팁)에만 보인다.
- 헤더(산장 관리·일시 정지·주머니·판매·승리·패배): `Extension.title` 이 헤더 그림을 9분할로 늘리지 않고 비율을 지켜 가운데에 두고, 글은 `HEADER_SPECS` 의 크림 띠 비율 안에 놓는다. 산장 관리창의 보유 골드는 제목 옆이 아니라 제목 아래 상태 줄(왼쪽 골드·오른쪽 목재)로 옮겨 제목 가운데 정렬을 지킨다. 창 높이는 820.
- 탭·버튼·행·말풍선·행동 표식: 장식 테두리 두께에 맞춰 안쪽 여백을 키웠다(`Extension.tab/button/row/speech/action/paper`). 손님 말풍선은 고정 크기 대신 글 길이에 맞춰 커지고 꼬리가 초상 얼굴 높이에 오도록 세로 위치를 맞춘다.
- 검증: `verify_ui_extension.gd` 96/96, `verify_guest_events.gd` 131 PASS. 실제 렌더 캡처는 `godot/screenshots/ui-layout-fix/`(카드 비율·헤더 그림·말풍선 여백은 헤드리스로 확인 불가).
