# 고블린 니브 모델링용 3/4 원화 v03 — B 베이스 등짐 교체

- 제작일: 2026-10-19 (Asia/Seoul).
- 요청서: `docs/handoff/codex-goblin-nib-model-3q-v03.md`를 UTF-8로 읽고 수행.
- 사용자 지시: “B로 하되, 보따리가 아닌 배낭·담요·등불로 변경해 줘. B를 베이스로.”
- 납품 이미지: [nib-3q-v03.png](nib-3q-v03.png), **1536×1536 RGBA PNG**, 1,240,219 bytes. 최종 시안은 이 한 장이다.
- 생성 도구: 내장 `image_gen.imagegen` **1회**, `transparent_background=true`. CLI/API 대체 생성 없음.
- 변경 내용: 흰 보따리·묶음·기존 운반 끈을 갈색 둥근 배낭, 위에 가로로 얹은 크림색 말린 담요, 옆에 매단 노란 유리 면의 작은 등불, 배낭 멜빵으로 교체.
- 작업 중 작성한 모든 프로젝트 파일은 이 `art/concepts/characters/goblin-nib-model-v03/` 안에만 있다. v01·v02, 기존 원화·초상·레퍼런스, `godot/**`, `docs/**`를 수정하거나 삭제하지 않았다. 요청서도 그대로 보존했다. 게임 적용·실행파일 재내보내기·커밋 없음.

## 실제 이미지 입력

세 이미지를 모두 직접 열어 확인한 뒤, 아래 순서로 `referenced_image_paths`에 실제 첨부했다. 프롬프트에 경로만 적은 작업이 아니다.

1. **편집 대상 / 최우선 베이스 B:** `art/concepts/characters/goblin-nib-model-v02/nib-3q-b-v02.png`.
2. **등짐만 참고 A:** `art/concepts/characters/goblin-nib-model-v02/nib-3q-a-v02.png`. 갈색 둥근 배낭·크림색 담요 롤·노란 유리 등불만 참고. A의 얼굴 각도·귀걸이 위치·긴 목도리는 가져오지 않도록 명시.
3. **화풍 보조:** `art/references/characters/stylized-toy-chibi-ref-01.png`. v02의 매끈한 점토 장난감 덩어리감을 유지하는 보조 입력.

중세 기반 판타지, 중세의 생활감과 분위기를 유지하면서 판타지적 각색을 허용한다는 세계관과 아트 가이드를 읽었다. 프롬프트에도 medieval-based fantasy, medieval everyday clothing, leather backpack, plain cloth blanket, simple metal lantern으로 명시했다.

## 원본 보존과 캔버스 마감

- 생성 원본: [raw/nib-3q-v03.png](raw/nib-3q-v03.png), **1254×1254**. 도구 저장본을 바이트 그대로 복사했으며 원본 알파·RGB는 수정하지 않았다.
- 도구 원본 위치: `C:/Users/Loadcomplete/.codex/generated_images/01a152a8-6285-7e91-b2e7-f78d8d2b5945/exec-7c31e45f-9e8f-41ba-bacf-867b5140fced.png`.
- 실제 도구 반환 크기는 요청한 1536²와 달랐다. B와 납품본의 인물 높이·배치를 가깝게 맞추기 위해 [raw/normalize-layout.ps1](raw/normalize-layout.ps1)로 생성 원본을 **균등 1.1300813008130082배** 재표본화하고 1536² 투명 캔버스에 배치했다. 비균등 변형이나 부위별 형태 편집은 하지 않았다.
- 정렬 기준은 알파 ≥192 실루엣의 위·아래와 가로 중심. 원본 경계는 (247,157)–(1078,1140), B 기준 경계는 (331,218)–(1265,1329). 배치 이동값은 X=49.321167, Y=40.57724이며 high-quality bicubic을 사용했다.
- 중간 결과 [raw/layout-normalized.png](raw/layout-normalized.png), 변환 수치 [raw/layout-report.json](raw/layout-report.json)를 보존했다. 해당 중간 결과는 최종 납품본이 아니다.
- v02는 투명 여백만 추가했지만 이번에는 **B와 인물 크기를 맞추는 균등 확대**를 먼저 수행했다. 확대가 원본에 없는 세부 정보를 추가하는 것은 아니다.

## 알파 정리와 검수

사용자가 요청한 알파 마감은 v02의 [기존 마감 구현](../goblin-nib-model-v02/raw/alpha-cleanup.ps1)을 읽고 같은 알고리즘을 v03 내부 [raw/alpha-cleanup.ps1](raw/alpha-cleanup.ps1)로 복제해 적용했다. 기존 스크립트는 수정하지 않았다. 그림 내용 변경은 내장 이미지 도구로, 알파 마감·균등 배치는 System.Drawing 기반 결정적 후처리로 수행했다.

1. 배치 정규화 이미지의 알파 ≥192로 후보 마스크를 만들었다.
2. 3×3 침식·팽창의 1px opening으로 얇은 외곽 돌기를 정리하고 가장 큰 연결 성분을 유지했다.
3. 16px 이하의 닫힌 내부 핀홀만 채워 실제 팔·몸 사이 공간을 보존했다.
4. 마스크 내부를 완전 불투명으로 복구하고, [1,6,1] 3×3 가중치로 좁은 경계 안티에일리어싱을 재구성했다. 8 미만은 0, 247 초과는 255로 정리했다.
5. 부분 알파 경계 RGB는 가까운 내부 색으로 보완했다. 색상 키는 쓰지 않았고, 완전 투명 픽셀 RGB는 0이다.
6. 최종 PNG와 [흰색·회색 배경 검수 이미지](raw/alpha-proof.png)를 직접 열어 머리·귀·동전·목도리·소매·손·담요·등불·신발의 경계, 본체 구멍·반투명·외곽 색 번짐을 확인했다.

상세 수치: [raw/alpha-report.json](raw/alpha-report.json). 이 보고서의 Raw 항목은 원본 1254²가 아닌 **배치 정규화 후 1536² 중간 이미지**를 뜻한다.

| 항목 | 최종 결과 |
| --- | ---: |
| 크기 | 1536×1536 |
| 본체 내부 알파 255 | 625,203 / 625,203 = **100%** |
| 바깥 알파 0 | 1,721,425 / 1,721,425 = **100%** |
| 전체 알파 255 | 627,067px |
| 전체 알파 0 | 1,723,286px |
| 경계 부분 알파 | 8,943px |
| 알파 1~7 | 0px |
| 알파 252~253 | 0px |
| 부분 알파 영역 | 실루엣 경계 안팎 각 1px 이내 |
| 연결 성분 | 1개 |
| 실루엣 경계, inclusive | (326,217)–(1268,1330) |
| 투명 여백 좌/상/우/하 | 326 / 217 / 267 / 205px |

본체 내부는 3×3 이웃이 모두 마스크인 픽셀, 바깥은 3×3 이웃에 마스크가 없는 픽셀로 정의하며 좁은 경계 영역을 두 분모에서 제외한다. 모서리, 바탕, 바닥 그림자, 분리된 알파 잡티는 최종 실루엣 바깥에서 제거했다.

## B 대비 시각 검수

| 구분 | 직접 비교한 결과 |
| --- | --- |
| 등짐 변경 | B의 흰 보따리와 매듭이 사라졌다. 갈색 둥근 배낭, 위의 가로 담요 롤, 화면 오른쪽의 작은 등불로 읽힌다. 등불은 노란 유리 면이며 빛 번짐이 없다. |
| 멜빵 | 두 어깨에 갈색 멜빵이 보인다. 망토형 목도리 위에 겹치며 배낭과 이어지는 방향이 자연스럽다. |
| 등짐 크기 | A와 유사한 단순한 덩어리 규모로 머리에 종속된다. 담요는 오른쪽 귀 아래에 있으며 머리보다 높이 솟지 않는다. |
| 머리·얼굴 | B의 큰 둥근 캡과 두 앞머리, 짙은 단추 눈, 둥근 코, 홍조와 작은 닫힌 미소를 유지하는 외형이다. |
| 귀·귀걸이 | 큰 양쪽 귀와 **화면 왼쪽 귀의 구리 동전 하나**를 유지했다. A의 오른쪽 귀걸이로 바뀌지 않았다. |
| 목도리·의상 | B의 어깨를 덮는 짧은 붉은 망토형 목도리, 보라 조끼·흰 소매·갈색 벨트와 사각 버클·바지·연두 발목·둥근 신발을 유지했다. A의 긴 목도리 꼬리 없음. |
| 구도·자세 | B의 약한 상부 시점 3/4 전신, 비스듬히 내린 양팔 A자 자세, 빈 벙어리장갑 손, 큰 머리와 짧은 신체 비례를 유지하는 구도다. 머리 위와 발아래 높이는 B에 맞춰 정렬했다. |
| 색·조명·화풍 | 기존 연두·갈색·붉은색·보라색과 부드러운 중성 조명, 매끈한 무광 점토 장난감 느낌을 유지한다. |
| 금지 장식·시대감 | 담요 무늬·종·술·새 장식 없음. 단순한 가죽·천·금속 짐이 중세 기반 판타지에 어울린다. |
| 잘림·배경 | 귀끝·신발·등짐 모두 캔버스 안에 있다. 단일 인물·단일 뷰이며 글자·워터마크·바닥·배경 그림 없음. |

### 한계

- **B의 픽셀을 등짐 밖에서 그대로 복사해 보존한 합성본은 아니다.** B를 최우선 실제 편집 입력으로 사용했지만 생성 도구가 이미지를 재구성하므로 눈·귀·입·머리 외곽, 소매·손·의상 가장자리와 명암에 미세한 차이가 남는다. “나머지 전부 B 그대로”는 시각적인 정체성·의상·자세·구도의 유지로 검수했으며 픽셀 동일성이나 정확한 3D 카메라 각도를 보증하지 않는다.
- 균등 확대와 알파 정리는 일부 경계와 표면을 조금 부드럽게 만들 수 있다. 기존 B 실루엣 경계 (330,217)–(1266,1330)와 최종 경계는 가로 수 px 차이가 있다.
- 팔 뒤로 배낭이 겹쳐 보인다. 이 한 장은 모델링용 원화이며 정투영도·후면 구조·정확한 치수의 보증 자료는 아니다.
- 캐릭터 승인, 모델 제작, 게임 자산 교체는 이 작업에 포함하지 않는다.

## 수정 금지 경로 검수

[raw/protected-files-before.csv](raw/protected-files-before.csv)에 v03 밖의 `godot/`, `docs/`, `art/` 기존 파일 **6,907개**의 경로·크기·수정 시각을 기록했다. 마감 후 비교 시 삭제·크기·수정 시각 변경이 없었다. 입력 3장과 요청서는 아래 SHA256도 다시 비교해 동일함을 확인했다. 전체 보호 파일을 암호학적으로 비교한 것은 아니며 전체 파일 검수는 메타데이터 비교다. 어떤 커밋 명령도 실행하지 않았다.

## SHA256

| 파일 | SHA256 |
| --- | --- |
| `nib-3q-v03.png` | `D33657A5A0B50B9B8BDD4F6384A3014B49AA0610111DFE8015480D038FF71F1B` |
| `raw/nib-3q-v03.png` (도구 원본) | `1B40EC359B0C2781233B4F0B00FAEF1EFB0C2D041716DB1A855D45B321F921DD` |
| `raw/layout-normalized.png` | `64CCA499C6883FFC826C97294F065F8BEE1AA06354034169034D41D07E6DCB39` |
| `raw/alpha-proof.png` | `9A26B9DA7DF0785BE18F6C48FC28102747BA0480213451B9C6AB5A5F180DCC23` |
| 입력 B: `../goblin-nib-model-v02/nib-3q-b-v02.png` | `C47042945BB8861592AF58CF78A5C70B65FADB7526C44F09C9B825FD3B0F6BF0` |
| 입력 A: `../goblin-nib-model-v02/nib-3q-a-v02.png` | `B7CE03E51CEE6603DC1A2583AC6A5277539B49D959CC904C36B0C1AAEF1B8210` |
| 화풍 입력: `art/references/characters/stylized-toy-chibi-ref-01.png` | `C26F3E21A10E119047DF10986BF4D27720C2E6B7A266ACA142BA2FCF78BF8687` |
| 요청서: `docs/handoff/codex-goblin-nib-model-3q-v03.md` | `8822F622C20073665DF7FEC49D41A9A7F0E829FA7C4EAF5F92A67F58CD16B89F` |

그 밖의 마감 스크립트·보고서 해시는 [raw/artifact-hashes.json](raw/artifact-hashes.json)에 기록했다. 이 매니페스트는 generation.md 작성 전 파일을 대상으로 하며 자기 자신과 generation.md 해시는 포함하지 않는다.

## 실제 프롬프트 전문

아래는 생성 도구에 전달한 문자열 전체다. [raw/prompt.txt](raw/prompt.txt)에도 같은 문구를 보존했다. 호출 입력은 위 세 경로와 `transparent_background=true`였으며 추가 보정 호출은 없었다.

```text
Use case: precise-object-edit.
Asset type: ONE full-body 3/4 character concept for 3D modeling, goblin Nib, Witch's Lodge medieval-based fantasy game.
This is a strictly localized edit of Image 1, NOT a new character drawing. Use all THREE attached files as real visual inputs, with this hierarchy:
IMAGE 1 (nib-3q-b-v02.png): PRIMARY EDIT TARGET / BASE. Keep this exact B image, composition and character. Change ONLY the back baggage and the straps belonging to that baggage.
IMAGE 2 (nib-3q-a-v02.png): supporting object reference ONLY for its rounded brown backpack, one horizontally rolled cream blanket on top, and one small side-hung lantern with a flat yellow glass face. Do NOT borrow its head, ear earring placement, face angle, scarf, pose, body or framing.
IMAGE 3 (stylized-toy-chibi-ref-01.png): style reference ONLY; retain Image 1's existing smooth matte clay toy appearance, broad simple masses and sparse detail. No changes from this reference to the character.

EDIT ONLY: Remove B's white tied cloth bundle, its white knot/lobes, and the old bundle carrying strap. In precisely that back area, install one rounded brown leather backpack like A's, one plain cream rolled blanket laid horizontally across its top, and one small lantern hanging at the visible image-right side of the backpack with a muted yellow glass pane and no emitted light. Match the backpack/blanket/lantern scale in A, adapting naturally to B's existing camera and position. Keep all luggage well below the top of the head. Let simple brown backpack shoulder straps be visibly readable over the shoulders with natural overlap around/beneath the existing red short capelet scarf; keep the scarf's silhouette and design. No extra pockets, ornaments, blanket patterns, bells, tassels, decorative buckles or extra props.

LOCK ALL THE REST TO B / IMAGE 1: same exact camera angle, orientation, full-body A-pose, framing, margins and scale; same rounded hair cap and two large bangs, same button eyes, small round nose, blush and tiny closed smile; same large pointed ears; copper coin earring on the SCREEN-LEFT ear exactly as B (never move it to the right as in A). Keep B's short red scarf-capelet covering the shoulders (do not replace it with A's long hanging scarf), purple vest, off-white sleeves, brown waist belt and buckle, trousers, lime-green ankle bands, round shoes, head/body proportions, colors, materials, shading and lighting. Empty mitten hands and both arms must stay unchanged. Do not redesign, re-pose, rotate or repaint the rest of the figure.

Output ONE square 1536 x 1536 RGBA PNG, genuine transparent background, same canvas layout as Image 1. Fully opaque character and baggage (alpha 255), outside alpha 0, only narrow 1-2px edge antialiasing. No floor, contact/cast shadow, halo, checkerboard, backdrop, frame, text, watermark, collage, multiple views or comparison layout. Medieval everyday clothing, leather backpack, plain cloth blanket and simple metal lantern consistent with the established medieval fantasy setting.
```

