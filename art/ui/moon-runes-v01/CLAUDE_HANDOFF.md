# Claude에게 전달할 구현 작업

마녀산장 UI를 사용자가 채택한 **3번 달빛 마법 시안 그대로** 구현해 주세요. Codex가 기능 명세서와 모든 필요한 아트 부품을 준비했습니다.

먼저 [기능 명세서](../../../docs/ui-moon-runes-functional-spec.md), [에셋 안내](README.md), `layout.json`, `asset-catalog.json`, `manifest.json`을 읽어 주세요. 최종 시각 기준은 `approved/mockup.png`입니다. `approved/atlas.png`와 지정된 8개 영역·슬롯으로 재조립하면 원본과 전체 픽셀이 일치하는 것까지 검증돼 있습니다. 비슷한 기본 Godot 테마로 대신 만들거나 초상/문양/프레임을 다시 그리지 마세요.

당신의 책임은 게임 UI 구현·기존 데이터/함수/입력 연결·반응형 배치·기능 검증·필요한 게임 내보내기입니다. Codex의 책임은 에셋 생성/분리/패키징이며 게임 코어·HUD 구현 파일은 이 에셋 작업에서 수정하지 않았습니다. 다른 작업의 변경을 되돌리지 마세요.

납품 runtime/common/icons/cards/fonts를 `godot/assets/ui/moon_runes/`에 설치하세요. `runtime/hand.png`·`actions.png`는 배치 참고용이며 일반 플레이에는 독립 카드, 빈 수량 필드, hand_tray, 개별 버튼을 써야 합니다. 시안의 숫자를 고정 그림으로 표시하면 안 됩니다. 동적 글 영역과 게이지는 `layout.json`을 따릅니다. 숫자는 제공된 glyph atlas+metrics로 그릴 수 있습니다. `source/`의 원본 생성 시트·미채택 초안·폰트 포맷 초안은 import 대상이 아닙니다.

구현 순서는 원본 재현 → 동적 값/게이지 → 개별 손패·hover/drag → 관리/공물/창고/고용/판매/pause·기존 설정/지도 접근 → 기능 검증입니다. 자세한 데이터 바인딩과 완료 기준은 기능 명세서 4~7절에 있습니다. 손패 한도 8·가격·시간 정지·카드 소비·전투 규칙을 UI 스타일에 맞추려고 변경하지 마세요.

`verification/package-verification.json`의 통과는 에셋 검증입니다. 실제 플레이 기능이 이미 구현됐다는 뜻이 아닙니다. 구현 후 같은 스타일 설정/카메라의 실제 실행 캡처와 지정된 기능 검증 결과를 제출해 주세요.
