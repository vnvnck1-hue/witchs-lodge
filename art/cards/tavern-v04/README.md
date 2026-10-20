# 에린 설명 문구 수정 v04

최종 게임 에셋은 3번 전설 프레임을 채택하고 하단 설명을 삭제한 [v05](../tavern-v05/README.md)다. 이 폴더는 이전 문구 이력이다.

2026-10-20 · 내장 `image_gen` 이미지 편집.

사용자 요청에 따라 에린 카드 설명을 아래 세 줄로 수정했다. 치마까지 보이는 기존 구도와 한 줄 제목을 유지했다.

```text
술병 네 가지 가운데
세 병을 아무렇게나 꺼냅니다.
[가끔 술주정을 부립니다]
```

- [최종 카드](drunken_erin.png): 1024×1536 RGBA
- [손패](hand/drunken_erin.png): 256×384 RGBA
- [실제 프롬프트](erin-rules-prompt.json)
- [메타데이터·해시](manifest.json)
- [검증](validation.json)

생성 원본과 수정 전 이미지는 `sources/`, 교체 전 배포 파일은 `before/`에 보존했다. 최종 원화는 `art/cards/tavern-v01/drunken_erin.png`, 게임용은 `godot/assets/cards/drunken_erin.png`, 손패는 `godot/assets/cards/hand/drunken_erin.png`에도 반영했다. 게임 카탈로그의 `drunken_erin.printed_rules`도 세 줄과 동일하게 갱신했다. 게임 규칙·추첨 확률·스크립트·씬은 이번 작업에서 편집하지 않았다.

이미지 제작은 내장 도구를 사용했고, 패키징은 기존 카드 알파 복사와 크기 변환만 수행했다. 검증 로그는 `output/tavern-v04-validation/`에 있다.

검증: 재임포트 성공, 현재 주점 검사 **RESULT 56/56**, Windows Desktop 내보내기 종료 코드 0, 갱신한 `WitchsLodge.exe` 헤드리스 시작 검사 종료 코드 0. 최종 내보내기 오류 로그는 비어 있다. 원화·손패 배포 파일의 해시 일치와 카탈로그 인쇄 문구 일치를 확인했다.
