# Codex에게 요청하는 에셋 작업 — 보름달 늑대인간 B 시안 회색 늑대 버전 (v02)

요청자: Claude · 2026-10-21 · 이전: [v01 요청서](codex-werewolf-witch-model-3q-v01.md)

## 배경

사용자가 v01 **B 시안**(`art/concepts/characters/werewolf-witch-model-v01/werewolf-3q-b-v01.png`)을 승인했다.
수정 지시: **"갈색 말고 회색 늑대로 다시 그려 봐."**

## 할 일 — B 시안의 색만 바꾼다

- **기준 이미지:** `art/concepts/characters/werewolf-witch-model-v01/werewolf-3q-b-v01.png` 를 실제 입력으로 열어, **형태·자세·비례·카메라·조명·화풍을 최대한 그대로** 유지한다(이미지 편집 우선).
- **털색 변경:** 몸·팔·다리·꼬리·머리·갈기(지금 갈색 웨이브 머리 덩어리 포함)를 모두 **회색 늑대**로.
  - 주 털: 차가운 중간 회색~짙은 회색(푸른 기가 살짝 도는 슬레이트 회색). 등·갈기·팔 바깥은 조금 더 어둡게, 정수리 갈기 덩어리는 한 톤 밝거나 어두운 회색으로 구분.
  - 크림색 부위(주둥이·가슴·배·꼬리 끝·발가락)는 그대로 밝은 크림~연회색.
  - 귀 안쪽은 크림 유지.
- **그대로 둘 것:** 연보라 눈, 찢긴 보라 망토 조각(한쪽 어깨), 갈색 벨트·금색 버클, 크림 천 자락, 짧은 송곳니, 점토 무광 마감.
- 기존 순한 회색 수인 손님(`art/concepts/characters/beastfolk-common-model-v02/beastfolk-common-3q-v02.png`)과 색은 비슷해져도 되지만, 덩치·자세·눈으로 충분히 구분되는지 확인.
- 진짜 투명 알파(본체 255·바깥 0, 외곽 1~2px 안티에일리어싱), 원본 `raw/` 보존, 1536×1536.

## 역할·제한

- 새 파일은 `art/concepts/characters/werewolf-witch-model-v02/` 안에만 만든다.
- **수정 금지:** `godot/**`, `docs/**`, v01 시안 포함 기존 원화 전부. **커밋하지 말 것.**

## 납품

- `art/concepts/characters/werewolf-witch-model-v02/werewolf-3q-b-v02.png` (+ `raw/`)
- 비교판 `werewolf-v02-contact.png`: v01 B · v02 · 마녀 A · 수인 공용을 같은 배율로(불투명 배경 가능).
- `generation.md`: 입력 이미지·실제 프롬프트 전문·알파 검수·크기·SHA256·v01 B 대비 형태 유지 여부·한계.
- 마지막 응답에 파일 경로와 요약.
