# 전설 에린 카드 최종 에셋 v05

최신 에셋은 상단까지 모든 글자를 제거하고 최초 금발 원화 픽셀을 직접 복원한 [v06](../tavern-v06/README.md)이다. v05는 반복 이미지 편집 전후를 비교하기 위한 이력으로 보존한다.

2026-10-20 · 사용자 승인: 전설 프레임 3번 ‘보랏빛 마법 금박’.

승인된 3번 프레임에서 하단 설명 세 줄을 모두 지워 빈 크림색 패널로 정리했다. 상단 이름 ‘술 주정뱅이 에린’, 분류 ‘인물 · 주점 손님’, 술잔 배지, 에린의 얼굴·자세·치마까지 보이는 구도와 보라색·금박 프레임을 유지했다.

| 용도 | 파일 | 규격 |
| --- | --- | --- |
| 최종 원본 | [drunken_erin.png](drunken_erin.png) | 1024×1536 RGBA |
| 손패 | [hand/drunken_erin.png](hand/drunken_erin.png) | 256×384 RGBA |
| 게임용 | `godot/assets/cards/drunken_erin.png` | 원본과 동일 |
| 게임 손패 | `godot/assets/cards/hand/drunken_erin.png` | 손패와 동일 |

`art/cards/tavern-v01/drunken_erin.png`도 최신 원화로 갱신했다. 기존 배포 파일과 이전 카탈로그 항목은 `before/`, 생성 원본과 승인 시안은 `sources/`에 보존했다. 카탈로그의 해당 `printed_rules`는 빈 배열로 정리했다. 기능 안내용 `description`과 게임 규칙·추첨 확률은 이번 작업에서 변경하지 않았다.

제작: 내장 `image_gen`으로 설명 글자만 제거한 뒤, 패키징에서 기존 게임 카드의 둥근 모서리 알파를 복사하고 원본·손패 크기로 저장했다. 카드 내부는 불투명, 모서리 바깥은 투명이다.

- [실제 프롬프트·승인 참고 이미지](erin-final-prompt.json)
- [파일 메타데이터·해시](manifest.json)
- [패키징](package-erin.ps1)
- [검증 결과](validation.json)
- 상세 검증 로그: `output/tavern-v05-validation/`

검증: 재임포트 성공, 주점 검사 **RESULT 56/56**, Windows Desktop 내보내기 종료 코드 0, 갱신한 `WitchsLodge.exe` 헤드리스 시작 검사 종료 코드 0. 최종 내보내기 오류 로그는 비어 있다. 원화·게임용·손패 파일의 해시 일치와 빈 `printed_rules`를 확인했다. 기존 종료 정리 경고는 검사 로그에 남는다.
