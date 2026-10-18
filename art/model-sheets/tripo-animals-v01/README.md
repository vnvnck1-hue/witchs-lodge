# Tripo용 동물 단독 3/4 뷰 v01

2026-10-18 (Asia/Seoul). 사용자 요청에 따라 기존 사슴·토끼·양 원화를 각 한 마리의 3/4 뷰로 재제작했다.

| 파일 | 대상 |
| --- | --- |
| [01-deer-three-quarter.png](01-deer-three-quarter.png) | 사슴 |
| [02-rabbit-three-quarter.png](02-rabbit-three-quarter.png) | 토끼 |
| [03-sheep-three-quarter.png](03-sheep-three-quarter.png) | 일반 양 |
| [04-lamb-three-quarter.png](04-lamb-three-quarter.png) | 새끼양 |
| [05-black-sheep-three-quarter.png](05-black-sheep-three-quarter.png) | 검은 양 |

각 파일은 1254×1254 투명 PNG다. 동물 한 마리의 전신만 포함하며 글자·색상표·지면·배경·바닥 그림자를 제거했다. 기존 원화의 색·형태·새끼양 목방울·검은 양의 작은 뿔과 목방울을 유지했다. Tripo에 사용할 때 개별 PNG를 선택한다. PNG 다섯 장만 묶은 파일은 `animals-tripo-transparent.zip`이다.

내장 image_gen의 이미지 편집 모드와 `transparent_background: true`를 사용했다. 각 대상의 기존 모델링 시트 한 장을 실제 참고 입력으로 제공했고, 전체 실제 프롬프트와 원본 출력 이름은 [prompts.md](prompts.md)에 기록했다. 생성 PNG의 알파와 해상도를 그대로 보존했다.

## 검수

- 각 이미지에서 한 마리 전신·3/4 방향·귀·뿔·발·꼬리의 프레이밍을 확인했다.
- PNG 알파 채널에 실제 완전 투명 픽셀이 존재함을 검사했다. [verification.json](verification.json)은 크기·알파 픽셀 통계·SHA-256을 기록한다.
- [흰색/회색 배경 검수 합성](../../../output/tripo-animals-v01/transparency-preview.png)으로 배경 제거와 외곽을 확인했다. 이 합성은 검수용이며 업로드용 원본은 위 개별 PNG다.
- Tripo에서 모델 생성은 실행하지 않았다. 이번 작업은 입력 원화 제작이며 게임 모델·소스·배포 실행파일은 변경하지 않았다.

세계관은 프로젝트 [아트 가이드](../../../docs/art-direction.md)의 중세 기반 판타지와 간결한 형태·큰 색면·툰 명암을 따른다.

