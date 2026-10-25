# Codex 요청서 — 전설 카드 5장 + 광석 원화 v01

요청자: Claude (게임 구현 담당) · 2026-10-25 · 기획·규칙: [docs/legend-cards-v01.md](../legend-cards-v01.md)
카드 기준: [카드 디자인 가이드](../card-design-guide.md) · [카드 글자 런타임](../card-text-runtime.md) · 세계 기준: [CLAUDE.md](../../CLAUDE.md)(중세 기반 판타지) · [아트 가이드](../art-direction.md)

## 사용자 요청

카드 검토에서 승인한 6장을 "만들어줘. 에셋은 코덱스에게 요청해". 게임 규칙·카탈로그·코드는 Claude가 만든다. **Codex는 원화 6장만** 만든다.

## 0. 역할 분담·수정 금지

- **Codex 책임:** 아래 6장의 원화 생성·합성·축소·검증·기록.
- **수정 금지:** `godot/scripts/**`, `godot/scenes/**`, `godot/shaders/**`, `godot/tools/**`, `godot/assets/cards/catalog.json`, `catalog_en.json`, `text_layout.json`, `godot/project.godot`, 이 6장 외의 모든 카드 PNG, 루트 `WitchsLodge.exe`.
- **커밋하지 말 것.** `git stash`·`git checkout`·`git reset` 금지. 다른 세션이 같은 저장소에서 동시에 작업 중이다. 다른 작업의 변경을 되돌리지 말 것.
- `.import` 파일은 만들어도 되고 안 만들어도 된다(Claude가 `--import` 를 다시 돌린다).

## 1. 반드시 지킬 것 — 글자 없음, 프레임 픽셀 보존

카드 글자는 게임이 그린다(사용자 확정 2026-10-20). **원화에 글자·숫자·기호를 넣지 않는다.** 제목판·설명판은 비워 둔다.

### 1.1 전설 5장 — 에린 전설 프레임 그대로

- **틀:** `art/cards/legendary-v01/drunken_erin_legendary_blank.png`(= 현재 `godot/assets/cards/drunken_erin.png` 와 같은 프레임). 금테·보라 별빛 테두리·위 타원 제목판·아래 설명판·네 모서리 투명은 **픽셀 그대로** 둔다. 게임의 전설 셰이더 마스크(`godot/assets/cards/fx/legendary_frame_mask.png`)와 글자판 프로파일이 이 프레임 모양으로 측정돼 있어, 프레임이 조금이라도 움직이면 금테 빛과 글자가 어긋난다.
- **바꿀 곳:** ① 가운데 **그림 창**(에린 그림이 있는 둥근 사각 창 안쪽) ② 그림 창 아래 가운데 **둥근 배지 안 아이콘**(지금 맥주잔). 그림 창 마스크는 `art/cards/tavern-v06/original-art-mask.png`(흰 영역 = 에린 원화를 복사한 영역)를 참고해 만든다.
- 권장 방법: 그림만 따로 생성(1024 폭 정도, 글자 없음) → 그림 창 마스크로 잘라 틀 위에 합성 → 배지 원 안만 새 아이콘으로 합성 → **창·배지 밖 픽셀은 틀 원본으로 되돌림**. 보존 영역 RGBA 변경 픽셀 수를 검증 JSON 에 기록(0 이어야 함).
- 그림 표현: [주점 술 카드](../tavern-cards-v01.md) 4종처럼 **하스스톤 아이템 원화 느낌** — 대상이 그림 창 **중앙에 크게**, 대각선·소용돌이 같은 **역동적 구도**, 큼직하고 단순한 형태(자잘한 질감 금지), 강한 림라이트·발광, 채도 높은 매끈한 페인팅. 블리자드 원화를 베끼지 않는다(방향만).

### 1.2 광석 — 일반 자원 프레임

- **틀:** 현재 게임 카드 `godot/assets/cards/timber.png`(목재, 글자 없는 판)를 편집 대상으로, **그림 창 안쪽과 작은 표식 아이콘만** 광석으로 바꾼다. 프레임·빈 글자판·모서리 투명은 픽셀 보존(글자판 프로파일이 목재와 같게 쓰인다). 역할 승인 PNG `art/concepts/cards/roles-individual-v02/03-resource-timber.png` 를 포맷 참고 입력으로.
- 화풍은 목재·양털 같은 기존 자원 카드(수채·먹선, 큰 색면, 또렷한 먹선).

## 2. 대상 6장

| id | 이름 (게임이 씀) | 틀 | 그림 창에 그릴 것 | 배지·표식 아이콘 | 색 |
| --- | --- | --- | --- | --- | --- |
| `frost_crown` | 서리 여왕의 왕관 | 전설 | 날카로운 **얼음 결정으로 된 여왕의 왕관**이 공중에 떠 있고, 왕관에서 얼음창 같은 냉기 줄기와 눈보라가 소용돌이로 뿜어 나온다. 뒤로 눈 덮인 침엽수 숲 밤하늘(흐리게) | 얼음 왕관 | 빙청·은백·남보라, 차갑게 빛남 |
| `lich_crown` | 망자의 왕관 | 전설 | **검은 철과 뼈로 짠 군주의 왕관**, 이마에 보랏빛 보석. 왕관 둘레로 초록·보라 영혼불이 혀처럼 타오르고, 아래로 묘지 안개와 기울어진 비석 실루엣. 피·내장·잔혹 표현 없음 | 뼈 왕관 | 검정·뼈색·영혼불 청록·보라 |
| `wild_grimoire` | 폭주하는 마법서 | 전설 | 공중에 **활짝 펼쳐진 낡은 가죽 마법서**에서 불꽃·얼음 조각·덩굴·번개·별빛이 제멋대로 소용돌이치며 터져 나오고 책장이 흩날린다. 혼돈스럽지만 신나는 느낌 | 펼친 책 | 보라 바탕에 주황·청록·초록 섞인 섬광 |
| `fire_brazier` | 불의 정령 화로 | 전설 | 다리 셋 달린 **돌·무쇠 화로** 안에서 **불의 정령**(두 눈과 입이 있는 거대한 불꽃 얼굴, 팔처럼 일렁이는 불길)이 솟아오르고, 위로 큰 불덩이 하나를 들어 올린다. 귀엽지 않고 위엄 있게 | 불꽃 | 주황·진홍·금색, 뜨겁게 발광 |
| `winter_bell` | 겨울의 끝 종 | 전설 | 서리에 덮인 **고대 청동 종**이 낡은 나무 종루 들보에 매달려 크게 흔들리고, 종소리 충격파가 흰 눈보라 고리로 퍼져 나간다. 고리 바깥으로 그림자 괴물 실루엣들이 흩어지며 부서진다(잔혹 표현 없음) | 종 | 청동·흰 눈·짙은 남색, 장엄하고 조금 무서움 |
| `ore` | 광석 | 자원 | 회색 바위 덩이 속에 **푸르스름한 금속 광맥과 결정**이 박힌 광석 덩어리 두세 개, 곁에 드워프 곡괭이 머리와 광부 등불. 갱도 돌벽 배경 | 광석 덩이 | 회색·청회색·등불 주황 |

기획상 이 카드들이 하는 일(그림 연기 참고, 카드에 쓰지 말 것): 왕관 둘은 마녀를 영구 변신시키는 전설 카드, 마법서는 무작위 주문 폭발, 화로는 밤마다 불덩이를 떨구는 시설, 종은 모든 적과 우리 시설을 무너뜨리는 최후의 버튼, 광석은 드워프 시설·장비 강화 재료.

## 3. 산출물 경로·형식

| 용도 | 경로 | 형식 |
| --- | --- | --- |
| 생성 원본·초안 | `art/cards/legend-v01/<id>.png`, 미채택 `art/cards/legend-v01/drafts/` | 1024×1536 RGBA |
| 게임용 | `godot/assets/cards/<id>.png` | RGBA 1024×1536, 모서리 바깥 투명(틀과 같은 알파) |
| 손패용 | `godot/assets/cards/hand/<id>.png` | RGBA 256×384 |
| 프롬프트 기록 | `docs/prompts/cards/legend-v01-prompts.md` | 실제 프롬프트·합성 방법 |
| 미리보기 시트 | `godot/screenshots/legend-cards/sheet-v01.png` | 6장 + 비교용 에린·목재 |
| 검증 기록 | `output/legend-v01/verification.json` | 파일별 크기·채널·모서리 알파·보존 영역 차이·SHA-256·`passed` |

게임은 이 경로의 PNG 가 없으면 카드 뒷면으로 대신 보인다(납품하면 `--import` 뒤 바로 반영).

## 4. 완료 기준

1. 6장 × (게임용 + 손패용)이 위 규격으로 저장됨. 모서리 바깥 투명.
2. 전설 5장은 에린 전설 프레임과 프레임 픽셀이 같고(보존 영역 변경 0), 광석은 목재 프레임과 같다.
3. 글자·숫자 없음. 손패 크기(256×384)에서도 대상이 한눈에 읽힌다.
4. 검증 JSON `passed=true`, 미리보기 시트 저장.
5. 이 문서 끝에 `## Codex 납품 결과 · <날짜>` 절(파일 목록, 재생성 이유, 남은 문제)을 붙이고 마지막 메시지에 같은 요약. 기준 미달은 숨기지 말고 id별로 적는다.


## Codex 납품 결과 · 2026-10-25

내장 `image_gen`으로 전설 5종과 광석 1종을 제작했다. 아래 **최종 원본 6장 + 게임용 6장 + 손패용 6장**을 저장했다. 원본/게임용은 1024×1536 RGBA, 손패용은 256×384 RGBA다. 최종 원본과 게임용은 SHA-256이 동일하다.

| id | 최종 원본 | 게임용 | 손패용 |
| --- | --- | --- | --- |
| `frost_crown` | [원본](../../art/cards/legend-v01/frost_crown.png) | [게임용](../../godot/assets/cards/frost_crown.png) | [손패용](../../godot/assets/cards/hand/frost_crown.png) |
| `lich_crown` | [원본](../../art/cards/legend-v01/lich_crown.png) | [게임용](../../godot/assets/cards/lich_crown.png) | [손패용](../../godot/assets/cards/hand/lich_crown.png) |
| `wild_grimoire` | [원본](../../art/cards/legend-v01/wild_grimoire.png) | [게임용](../../godot/assets/cards/wild_grimoire.png) | [손패용](../../godot/assets/cards/hand/wild_grimoire.png) |
| `fire_brazier` | [원본](../../art/cards/legend-v01/fire_brazier.png) | [게임용](../../godot/assets/cards/fire_brazier.png) | [손패용](../../godot/assets/cards/hand/fire_brazier.png) |
| `winter_bell` | [원본](../../art/cards/legend-v01/winter_bell.png) | [게임용](../../godot/assets/cards/winter_bell.png) | [손패용](../../godot/assets/cards/hand/winter_bell.png) |
| `ore` | [원본](../../art/cards/legend-v01/ore.png) | [게임용](../../godot/assets/cards/ore.png) | [손패용](../../godot/assets/cards/hand/ore.png) |

추가 납품물:

- [미리보기 시트](../../godot/screenshots/legend-cards/sheet-v01.png): 실제 256×384 크기의 신규 6장과 비교용 에린·목재.
- [검증 JSON](../../output/legend-v01/verification.json): `passed=true`, 파일 18개 각각 치수·RGBA·모서리 알파·보존 영역 변경 수·전체 알파 변경 수·SHA-256 기록. 보존 영역 RGBA 변경과 전체 알파 변경은 모두 **0개**.
- [실제 프롬프트 전문·합성 방법·재생성 이유](../prompts/cards/legend-v01-prompts.md).
- [최초 카드 초안 폴더](../../art/cards/legend-v01/drafts/): 1024×1536 RGBA 생성 카드 6장. 전설 틀 전체는 채택하지 않고 아이콘 입력으로 사용했다.
- [그림 전용 원시 입력](../../output/legend-v01/sources/), [패키징 코드](../../output/legend-v01/package.cs), [재현 스크립트](../../output/legend-v01/package.ps1), [최종 검수 기록 스크립트](../../output/legend-v01/finalize-verification.ps1), 그림 창·배지 마스크와 검토용 색상 표시본을 `output/legend-v01/`에 보관했다.

재생성 이유:

- 전설 5종 공통: 생성된 카드 프레임에 미세한 차이가 있어, 그림만 따로 생성하고 원본 에린 틀에 합성했다. 금테·별빛·빈 글자판·배지 테두리·모서리 알파를 원본에서 보존했다.
- `frost_crown`: 금속 받침이 섞인 최초 왕관을 전체가 얼음 결정인 왕관으로 정리했다.
- `wild_grimoire`: 표지에 생긴 문양을 없애고 무문양 가죽 표지·빈 페이지로 다시 생성했다.
- `fire_brazier`: 가운데 다리가 배지 뒤에 가리지 않도록 그림 하단 여백을 늘려 재생성하고 비율을 유지해 조금 작게 합성했다. 세 다리·불꽃 얼굴·들어 올린 불덩이를 확인했다.
- `ore`: 최초 생성 그림을 채택하고 목재 원본의 프레임을 복사 보존했다.

검수와 남은 사항:

- 6종 모두 빈 제목판·설명판, 글자·숫자·룬·표지 문양 없음과 손패 크기에서의 대상 식별을 직접 확인했다. 중세 기반 판타지 소재·세계 기준을 반영했다.
- `ore`의 엄밀한 알파 주의사항: 목재 원본의 꼭짓점 알파가 TL/TR/BL/BR 순서로 **`[1,0,2,0]`**이므로 광석 원본/게임용도 그대로 보존했다. 손패는 같은 축소 방식의 목재와 동일한 `[1,0,1,0]`이다. 육안으로는 투명하지만 네 꼭짓점 모두 정확히 0인 파일은 아니다. 이를 임의로 0으로 바꾸면 원본 틀 알파·보존 영역 변경 0 조건을 어기므로 수정하지 않았다. 전설 5종의 꼭짓점 알파는 모두 0이다.
- 그 밖의 제작 기준 미달은 발견하지 않았다. 실제 Godot 임포트·런타임 표시·셰이더 동작은 이번 원화 납품 범위에서 실행하지 않았다. 구현 담당 세션에서 임포트 후 확인할 수 있다.
- 이 작업은 수정 금지 경로, 다른 카드 PNG, 루트 `WitchsLodge.exe`를 쓰지 않았다. 요청서의 실행파일 수정 금지에 따라 내보내기도 하지 않았다. 커밋·stash·checkout·reset을 수행하지 않았고 다른 세션의 기존 변경을 되돌리지 않았다.

