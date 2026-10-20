# 에린 카드 제목 정리 v03

설명 문구의 최신판은 사용자 요청으로 ‘네 가지’와 술주정 안내를 반영한 [v04](../tavern-v04/README.md)다. 이 폴더는 제목 정리 이력으로 보존한다.

2026-10-20 · 사용자 선택 구도 유지 · 내장 `image_gen` 이미지 편집.

사용자가 고른 `exec-450b686f-3873-4df2-bd58-87fb49653d97.png`의 앉은 자세와 넓게 보이는 무릎·치마 구도, 얼굴·복식·술잔·배경·하단 설명을 유지하고 상단의 두 줄 제목을 **술 주정뱅이 에린** 한 줄로 정리했다. 역할별 승인 인물 PNG를 붓글씨 참고 입력으로 사용했다. 사용자 요청에 따라 선택한 원화의 그림 창 높이를 유지했다.

- [최종 카드](drunken_erin.png): 1024×1536 RGBA
- [손패](hand/drunken_erin.png): 256×384 RGBA
- [실제 프롬프트·참고 입력](erin-title-prompt.json)
- [메타데이터·해시](manifest.json)
- [검증](validation.json)

생성 원본과 사용자가 고른 수정 전 이미지는 `sources/`에 보존했다. 직전 배포 파일은 `before/`에 보존했다. 최종 카드는 `art/cards/tavern-v01/drunken_erin.png`, `godot/assets/cards/drunken_erin.png`, `godot/assets/cards/hand/drunken_erin.png`에도 반영했다. v02 원화는 이전 버전으로 보존했다.

그림·글자는 내장 이미지 편집으로 제작했다. 패키징은 기존 게임 카드의 외곽 알파 복사와 축소만 수행했다. 게임 스크립트·카탈로그·씬은 편집하지 않았다. 검증 상세 로그는 `output/tavern-v03-validation/`에 있다.

검증: 재임포트 종료 코드 0, 주점 검사 **RESULT 49/49**, Windows Desktop 내보내기 종료 코드 0, 갱신한 `WitchsLodge.exe` 헤드리스 시작 검사 종료 코드 0. 최종 내보내기 오류 로그는 비어 있다. 검사 종료의 기존 리소스 정리 경고는 해당 로그에 남는다.
