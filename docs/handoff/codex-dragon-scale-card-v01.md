# Codex에게 요청하는 에셋 작업 — [용비늘] 카드 원화 1장 (v01)

요청자: Claude (게임 구현 담당) · 2026-10-24 · 카드 기준: [카드 디자인 가이드](../card-design-guide.md) · 글자 규칙: [카드 글자 런타임](../card-text-runtime.md) · 기획: [용비늘](../dragon-scale.md)

## 사용자 요청 (그대로)

> 이제 용을 소환하려면 전투중에 몬스터에게 드랍되는 [용비늘]을 얻어서 사용해야 하는것으로 바꿔줘.
> 용 소환 버튼은 이제 아예 삭제해주고, 그대신 이제 몬스터들에게 0.1% 확률로 [용비늘] 이라는 카드를 얻을 수 있도록 해줘.

사용자 결정(2026-10-24): 카드 원화는 Codex 가 만든다. 카드는 밤 전투 중 **산장(지붕)에 끌어 놓으면** 지붕에 붉은 용이 내려와 불덩이를 쏜다.

## 만들 카드

| id | 역할 포맷 | 게임이 그릴 글자(원화에는 넣지 말 것) |
| --- | --- | --- |
| `dragon_scale` | **장비·유물** — [달빛 부적](../../art/concepts/cards/roles-individual-v02/04-relic-moonlit-charm.png)의 세로 방패형 원화창 | 제목 `용비늘` · 분류 `전리품 · 유물` · 설명 `산장에 놓습니다.` / `지붕에 용이 내려와 적에게 불덩이를 쏩니다.` |

### 그림 내용

- 주인공: **붉은 용의 비늘 한 장**. 손바닥만 한 두껍고 단단한 방패꼴(끝이 둥글게 뾰족한 물방울·연꽃잎 모양) 비늘. 진홍·주홍(게임 속 용 색: 짙은 빨강 #B33026 ~ 주홍 #ED572F)에 가장자리는 금빛이 살짝 돌고, 안쪽에서 **잉걸불처럼 은은하게 달아오르는 빛**(주황·노랑 심지)이 비친다. 비늘 결(가는 세로 홈 몇 줄)과 굵은 먹선 윤곽.
- 비늘은 방패형 창 가운데에 크게(창 폭의 50~65%) 세워 놓아 손패 256×384 에서도 한눈에 "붉은 비늘"로 읽혀야 한다.
- 배경: 겨울밤 눈 위(또는 어두운 남보라 밤하늘)에 비늘이 떨어져 있고, 주변 눈이 비늘의 열기로 조금 녹아 김·작은 불티 몇 점이 오른다. 용 전체 모습·사람·동물·건물·글자 금지(용의 존재는 비늘과 불티로만 암시).
- 중세 기반 판타지 수채·먹선 화풍, 큰 색면, 또렷한 먹선(기존 카드들과 같은 화풍). 참고: `godot/assets/cards/rowan_charm.png`, `godot/assets/cards/frost_rune.png`.

## 반드시 지킬 것

1. **카드 글자는 이미지가 아니라 게임이 그린다(사용자 확정 2026-10-20).** 제목판·분류줄·설명판은 **비워 둔다**. 글자·숫자·기호 금지.
2. 포맷은 승인 원본 `art/concepts/cards/roles-individual-v02/04-relic-moonlit-charm.png` 를 **실제 이미지 참고 입력**으로 써서 같은 골격(보라 바탕·검은 웨이브·크림 이름판·방패형 창·하나로 이어진 설명판)을 유지한다. 방패 아래 끝·장식이 설명 안전 영역(x=110..914, y=1185..1445)과 제목 안전 영역(x=110..914, y=72..236)을 침범하지 않는다.
3. 게임 안의 다른 유물 카드(예: `godot/assets/cards/rowan_charm.png`, 글자 없는 판)와 나란히 놓았을 때 프레임 모양이 같아 보여야 한다. 가장 쉬운 방법: `rowan_charm.png` 를 편집 대상으로 쓰고 그림 영역(방패 창 안·주변 그림)만 새로 그려 합성.
4. RGBA **1024×1536**, 네 모서리 라운드·모서리 바깥 투명. 손패용은 같은 그림을 **RGBA 256×384** 로 축소.

## 역할 분담·수정 금지

- **Codex 책임:** 위 1장의 원화 생성·합성·축소·검증·기록.
- **Claude 책임:** 게임 코드·카탈로그·판 프로파일·검증 스크립트·실행파일 내보내기·커밋. 원화가 오기 전까지 게임은 임시 그림으로 동작한다.
- **수정 금지:** `godot/scripts/**`, `godot/scenes/**`, `godot/shaders/**`, `godot/tools/**`, `godot/assets/cards/catalog.json`, `godot/assets/cards/catalog_en.json`, `godot/assets/cards/text_layout.json`, `godot/assets/cards/packaging.json`, `godot/project.godot`, 다른 모든 카드 PNG, 루트 `WitchsLodge.exe`. 다른 작업의 변경을 되돌리지 말 것. **커밋하지 말 것.** `git stash`·`git checkout`·`git reset` 금지. 다른 세션이 같은 저장소에서 동시에 작업 중이다.

## 산출물 경로

| 용도 | 경로 |
| --- | --- |
| 생성 원본·초안 | `art/cards/dragon-scale-v01/dragon_scale.png`, 미채택은 `art/cards/dragon-scale-v01/drafts/` |
| 게임용 | `godot/assets/cards/dragon_scale.png` — RGBA 1024×1536 (지금은 Claude 의 임시 그림이 있음 → 덮어쓰기) |
| 손패용 | `godot/assets/cards/hand/dragon_scale.png` — RGBA 256×384 (덮어쓰기) |
| 프롬프트 기록 | `docs/prompts/cards/dragon-scale-v01-prompts.md` |
| 미리보기 시트 | `godot/screenshots/dragon-scale/card-sheet.png` — 새 카드 + `rowan_charm` 나란히 |
| 검증 기록 | `output/dragon-scale-v01/verification.json` — 크기·채널·모서리 알파·SHA-256·`passed` |

`.import` 파일은 Claude 가 `--import` 로 다시 만든다(만들어도 되지만 꼭 필요하지 않다).

## 완료 기준

1. 게임용 + 손패용이 위 규격으로 교체됨. 모서리 바깥 투명. 글자·숫자 없음.
2. 방패형 창 가운데 붉은 비늘 하나가 크게 보이고 손패 크기에서도 읽힌다. 용 전체·인물·동물 없음.
3. 유물 포맷 골격이 `rowan_charm` 과 같고 글 안전 영역이 비어 있다.
4. 검증 JSON `passed=true`, 미리보기 시트 저장.
5. 이 문서 끝에 `## Codex 납품 결과 · <날짜>` 절(파일 목록, 재생성 이유, 남은 문제)을 붙이고 마지막 메시지에 같은 요약. 기준 미달은 숨기지 말고 적는다.

## Codex 납품 결과 · 2026-10-24

**용비늘 원화 교체 완료.** 내장 `image_gen`으로 제작하고, `rowan_charm`의 기존 빈 판·유물 프레임·모서리 알파를 보존해 그림 창 내부만 합성했다. 모든 생성 호출에 승인 유물 PNG를 실제 참고 입력으로 사용했다. 글자·숫자 없이 붉은 비늘 한 장과 설경·김·불티를 담았다.

### 파일 목록

| 용도 | 납품 파일 |
| --- | --- |
| 최종 원화 | `art/cards/dragon-scale-v01/dragon_scale.png` — RGBA 1024×1536 |
| 채택 생성 원본 | `art/cards/dragon-scale-v01/dragon_scale-generated.png` |
| 미채택 시안 | `art/cards/dragon-scale-v01/drafts/01-leaf-like.png`, `02-rounded-volume.png` |
| 게임용 교체 | `godot/assets/cards/dragon_scale.png` — 최종 원화와 바이트 동일 |
| 손패용 교체 | `godot/assets/cards/hand/dragon_scale.png` — RGBA 256×384 |
| 프롬프트·수정·합성 기록 | `docs/prompts/cards/dragon-scale-v01-prompts.md` |
| 비교 시트 | `godot/screenshots/dragon-scale/card-sheet.png` — `rowan_charm` 비교 및 실제 손패 크기 |
| 검증 기록 | `output/dragon-scale-v01/verification.json` — **`passed=true`** |
| 재현·검사 자료 | `output/dragon-scale-v01/build-assets.ps1`, `verify-assets.ps1`, `art-mask.png`, `protected-before.json` |

### 재생성·보정 이유

- 1차는 위끝과 갈라지는 홈이 잎처럼 보여 미채택했다.
- 2차는 둥근 볼륨과 방사형 홈이 알·열매처럼 보일 수 있어 미채택했다.
- 3차에서 넓은 윗부분·아래로 모이는 끝·납작한 판형·세로 홈 3개로 정리해 채택했다.
- 생성본 내부 알파가 미세하게 반투명해 원본 카드의 알파를 복사했다. 최종본의 카드 내부는 불투명하고 둥근 모서리 바깥은 투명하다.

### 검증 결과·작업 범위

- 게임용/손패용 PNG 크기, 8-bit RGBA, 네 모서리 및 1px 안쪽 모서리 알파 0, SHA-256 기록 완료.
- 원화 마스크 밖 변경 픽셀 0. 기존 제목 안전 영역·설명 안전 영역·빈 분류판 중심의 변경 픽셀 0. 원본 카드와 알파 차이 0.
- 최종 비교 시트에서 방패형 유물 프레임의 일치와 256×384 손패의 붉은 비늘 가독성을 확인했다. 단일 비늘이며 용 전체·사람·동물·건물·인쇄 문구는 없다.
- 수정 금지 경로에 쓰지 않았고 커밋·stash·checkout·reset·Godot import·실행파일 내보내기를 실행하지 않았다.
- 보호 파일 1,338개를 해시 대조했다. 동시 작업 세션의 스크립트/도구/실행파일 갱신 11건이 관측돼 검증 JSON에 전후 해시로 별도 기록했다. 이 작업에서 만든 변경이 아니며 되돌리지 않았다. 다른 카드 PNG와 보호 카드 메타데이터는 기준 해시와 같다.

### 남은 문제·담당 경계

원화 납품 기준의 미달 사항은 없다. 요청서의 `docs/dragon-scale.md` 링크는 작업 시 파일이 없어 요청서 본문을 기준으로 제작했다. 런타임 글자 배치·게임 동작 검증과 실행파일 내보내기는 요청서대로 Claude 담당이며 이 작업에서는 실행하지 않았다.
