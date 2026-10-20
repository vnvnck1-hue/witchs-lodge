# 전설 에린 최종 에셋 v06 · 원화 원본 복원

2026-10-20 · 사용자 요청: 상단까지 모든 텍스트 삭제, 최초 에린 일러스트를 변형 없이 사용.

카드 전체를 반복 생성하면서 생긴 일러스트 변형을 바로잡기 위해 이번 작업은 이미지 생성 없이 직접 합성했다. 초기 금발 에린 생성 원본 `art/cards/tavern-v01/drafts/drunken_erin_v02.png`에서 일러스트 픽셀을 복사하고, 승인된 3번 전설 프레임을 유지했다. 상단 이름·분류와 하단 설명은 모두 미인쇄 상태다.

원화는 1024×1536 원본 좌표 그대로 복사했다. 확대·축소·이동·회전·색보정·재생성을 하지 않았다. 기존 카드 외곽선과 새 전설 프레임이 겹치는 경계, 술잔 배지는 프레임 마스크로 처리했다. 상단 글자는 기존 빈 크림 패널의 텍스처를 복사해 지웠다. 모서리 바깥은 투명하게 정리했다.

- [최종 원본](drunken_erin.png): 1024×1536 RGBA
- [손패](hand/drunken_erin.png): 256×384 RGBA
- [픽셀 대조 결과](pixel-verification.json): 복사 영역 **703,161픽셀**, RGB 불일치 **0**; 얼굴 영역 x430..739/y370..629 불일치 **0**
- [합성 코드](restore-erin.ps1)
- [패키징](package-erin.ps1)
- [파일 메타데이터·해시](manifest.json)
- [Godot 검증](validation.json)

`sources/original-blonde-erin.png`에 최초 원본 사본, `sources/legendary-frame-before.png`에 수정 전 전설 카드, `original-art-mask.png`에 직접 복사 영역을 보관했다. 마스크의 흰 영역은 원본 RGB와 정확히 같다. 원본 PNG는 합성 후 재리샘플링하지 않고 게임 경로로 그대로 복사했다. 손패용만 256×384로 축소했다.

배포: `art/cards/tavern-v01/drunken_erin.png`, `godot/assets/cards/drunken_erin.png`, `godot/assets/cards/hand/drunken_erin.png`. 교체 전 배포 파일은 `before/`에 보존했다. 게임 스크립트·카탈로그·규칙은 이번 복원에서 편집하지 않았다. 게임에서 사용하는 이름·분류 메타데이터는 유지되며 카드 PNG에는 문자가 없다.

로그: `output/tavern-v06-validation/`.

검증: 재임포트 성공, 주점 검사 **RESULT 56/56**, Windows Desktop 내보내기 종료 코드 0, 갱신한 `WitchsLodge.exe` 헤드리스 시작 검사 종료 코드 0. 최종 내보내기 오류 로그는 비어 있다. 배포 PNG와 손패의 해시가 납품 파일과 같음을 확인했다. 기존 검사 종료 정리 경고는 상세 로그에 남는다.
