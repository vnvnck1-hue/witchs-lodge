# 북쪽의 마녀 — 3D 모델링용 3/4뷰 시안 v01

- 제작일: 2026-10-19 (Asia/Seoul).
- 요청서: `docs/handoff/codex-witch-north-model-3q-v01.md`를 UTF-8로 읽고 수행.
- 납품: [witch-3q-a-v01.png](witch-3q-a-v01.png), [witch-3q-b-v01.png](witch-3q-b-v01.png). 각각 **1536×1536, RGBA PNG**.
- **A:** HUD 초상의 두건·갈색 웨이브 머리·크림 원피스 계열. **B:** 현재 모델 시트의 뾰족 모자·연보라 단발·털 깃·보라 코트 계열.
- 생성: 내장 `image_gen.imagegen` **2회**, 시안마다 별도 프롬프트, 각각 `transparent_background=true`. CLI/API 대체 생성이나 추가 수정 생성 없음.
- 모든 새 프로젝트 파일은 `art/concepts/characters/witch-north-model-v01/` 안에만 저장했다. 기존 원화·초상·레퍼런스·니브 시안, `godot/**`, `docs/**`를 수정하지 않았다. 요청서도 그대로다. 커밋하지 않았다.
- 게임 자산 연결·실행파일 갱신은 수행하지 않았다. 이번 납품은 사용자 선택 전 원화 시안 단계다.

## 실제 이미지 입력과 설정

아래 **4장을 모두 직접 열어 확인**했고, **A와 B 두 호출에 모두 같은 순서로 `referenced_image_paths`에 실제 첨부**했다. 경로를 프롬프트에 적기만 한 것이 아니다. 호출에는 프로젝트 루트 기준 아래 경로를 절대 경로로 확장해 전달했다.

| 입력 순서 | 실제 이미지 | 역할 |
| --- | --- | --- |
| 1 | `art/concepts/characters/goblin-nib-model-v03/nib-3q-v03.png` | 승인된 니브 v03. 최우선 화풍·비례·카메라·마감 기준. |
| 2 | `art/references/characters/stylized-toy-chibi-ref-01.png` | 단순 점토 장난감 덩어리 조형만 보조. 인물·의상 복제 금지. |
| 3 | `godot/assets/ui/ftue/witch_portrait.png` | A 정체성. 두건·갈색 머리·크림 의상·등불. 초상의 먹선·세부 질감·눈 가림·등불을 든 자세는 배제. |
| 4 | `art/model-sheets/starter/02-witch-player.png` | B 정체성. 꺾인 모자·연보라 단발·털 깃·보라 코트·벨트·부츠. 다면도·로우폴리 면 표현은 배제. |

설정 자료 `docs/four-witches-v01.md` §2.3, `docs/character-3d-pipeline.md`, `docs/art-direction.md`, `docs/world-races-card-formats-v01.md`의 시대 배경 기준을 확인했다. 감정을 크게 드러내지 않는 차분한 원칙주의자, 창백한 얼굴, 짙은 남색~보라 의복과 오래된 등불을 반영했다. 프롬프트에 중세 기반 판타지, 중세의 생활감과 분위기를 유지하면서 판타지적 각색을 허용하는 방향을 명시했다.

## 생성 원본 보존

| 시안 | 원본 | 원본 크기 | 원본 bytes | 최종 bytes |
| --- | --- | --- | ---: | ---: |
| A | [raw/witch-3q-a-v01.png](raw/witch-3q-a-v01.png) | 1254×1254 RGBA | 809,878 | 1,025,051 |
| B | [raw/witch-3q-b-v01.png](raw/witch-3q-b-v01.png) | 1254×1254 RGBA | 722,804 | 906,933 |

도구에는 1536²를 요청했으나 실제 반환 이미지는 두 장 모두 1254²였다. 도구 파일을 `raw/`에 **바이트 그대로 복사**했고, 생성 원본의 RGB·알파는 변경하지 않았다. 최종본은 원본을 확대·축소하지 않고 사방 **141px 투명 패딩**을 추가해 1536²로 마감했다. 부위별 형태 변형이나 비균등 변형 없음.

도구 기본 저장 위치:

- A: `C:/Users/Loadcomplete/.codex/generated_images/01a15316-cf3d-7080-99ab-245c45bb30df/exec-63d0e6c5-89c5-4d8f-b947-7f72e405d5a6.png`
- B: `C:/Users/Loadcomplete/.codex/generated_images/01a15316-cf3d-7080-99ab-245c45bb30df/exec-b1c6d3e6-2bcd-4650-8156-7abc9e29f8f6.png`

## 알파 정리와 검수

[raw/alpha-cleanup.ps1](raw/alpha-cleanup.ps1)은 니브 v03의 기존 마감 구현을 읽고 이번 폴더에 복제·조정한 System.Drawing 기반 결정적 후처리다. 원본 스크립트는 수정하지 않았다. 생성 알파를 기준으로만 처리하며 색상 키를 쓰지 않는다.

1. 원본 알파 ≥192를 후보 실루엣으로 삼는다. 원본은 본체 상당수가 252~253으로 약하게 반투명했다.
2. 3×3 침식·팽창의 1px opening으로 가는 외곽 잡티를 정리하고 가장 큰 연결 성분을 유지한다.
3. 16px 이하의 닫힌 핀홀만 채워 손·몸통 사이와 두 다리 사이의 실제 빈 공간을 보존한다.
4. 내부를 255로 복구하고 [1,6,1] 3×3 가중치로 경계 안팎 각 1px 범위의 좁은 안티에일리어싱을 만든다. 알파 8 미만은 0, 247 초과는 255로 정리한다.
5. 부분 알파 경계 RGB는 가까운 내부 색으로 보완한다. 알파 0인 픽셀의 RGB도 0이다.
6. 원본 크기를 유지한 채 중앙에 141px씩 패딩한다. 최종 PNG와 [A 흰색·회색 배경 검수](raw/alpha-proof-a.png), [B 흰색·회색 배경 검수](raw/alpha-proof-b.png)를 직접 열어 확인했다.

수치: [raw/alpha-report.json](raw/alpha-report.json).

| 항목 | A | B |
| --- | ---: | ---: |
| 최종 크기 | 1536×1536 | 1536×1536 |
| 내부 알파 255 | 467,640 / 467,640 = 100% | 411,888 / 411,888 = 100% |
| 바깥 알파 0 | 1,881,368 / 1,881,368 = 100% | 1,935,652 / 1,935,652 = 100% |
| 전체 알파 255 | 469,248px | 413,699px |
| 전체 알파 0 | 1,882,974px | 1,937,455px |
| 경계 부분 알파 | 7,074px | 8,142px |
| 알파 1~7 / 252~253 | 0 / 0px | 0 / 0px |
| 부분 알파 범위 | 경계 안팎 각 1px 이내 | 경계 안팎 각 1px 이내 |
| 최종 연결 성분 | 1 | 1 |
| 최종 실루엣 inclusive (x0,y0,x1,y1) | (439,257,1097,1304) | (456,264,1107,1303) |
| 투명 여백 좌/상/우/하 | 439 / 257 / 438 / 231px | 456 / 264 / 428 / 232px |

여기서 내부는 3×3 이웃이 전부 후보 실루엣인 픽셀, 바깥은 그 이웃에 실루엣이 없는 픽셀이다. 좁은 경계는 두 분모에서 제외한다. 흰색·회색 바탕에서 후드·모자·머리·소매·손·등불·치맛단·부츠의 외곽을 확인했으며 넓은 반투명 영역, 바닥 그림자, 분리 잡티, 눈에 띄는 테두리 색 번짐은 보이지 않는다.

재실행 명령(프로젝트 루트):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File art/concepts/characters/witch-north-model-v01/raw/alpha-cleanup.ps1
```

## 시각 검수

| 확인 항목 | 결과 |
| --- | --- |
| 니브 v03과 화풍 | 둘 다 매끈한 무광 점토·비닐 장난감, 큰 둥근 덩어리, 어두운 단추 눈과 작은 둥근 코, 부드러운 명암이다. 외곽 먹선·하이라이트 눈·세밀한 붓질·로우폴리 면 표현 없이 같은 장난감 시리즈로 읽힌다. |
| 비례·색면 | 머리가 큰 약 2등신 계열 SD. 니브보다 귀와 등짐이 없어 좁고 단정한 실루엣이다. 보라·갈색·크림/연보라·피부색·작은 앰버/금속 악센트 중심이며 작은 무늬가 없다. |
| A 정체성 | 보라 두건을 쓰고도 얼굴과 양쪽 눈이 전부 보인다. 갈색 웨이브 머리를 굵은 덩어리로 단순화했다. 크림 원피스와 갈색 벨트, 작은 허리 등불이 있다. |
| B 정체성 | 끝이 꺾인 보라 모자, 갈색 띠와 버클, 연보라 단발, 큰 둥근 털 깃 덩어리, 보라 코트, 갈색 벨트·버클, 짙은 보라 바지와 갈색 부츠가 있다. 모자 챙 아래 얼굴과 양쪽 눈이 보인다. |
| 성격·표정 | 작은 닫힌 입의 옅은 미소, 하이라이트 없는 단순한 눈으로 차분하게 표현했다. 니브의 크게 올라가는 장난스러운 입꼬리보다 절제되어 있다. |
| 3/4와 카메라 | 화면 왼쪽으로 향한 앞-왼쪽 3/4 전신이며, 니브와 유사한 약한 상부 시점이다. 양쪽 눈·팔·발이 읽힌다. |
| A자·빈손 | 똑바로 선 자세에서 양팔이 몸통 바깥으로 내려온다. 손과 몸 사이의 빈 공간이 있고, 손에 지팡이·등불·책 등 아무것도 들지 않는다. |
| 등불·망토·보행 | 등불은 화면 오른쪽 허리 벨트에 매달려 손과 분리된다. 짧은 어깨 망토/깃이 팔을 이어 붙이지 않는다. 원피스/코트 아래 두 다리와 부츠, 두 발 사이 틈이 구분된다. |
| 완결성·시대감 | 단일 인물·단일 방향. 모자/두건 끝과 발까지 잘림 없이 여백 안에 있다. 배경·바닥·문자·워터마크가 없다. 단순 천·가죽·옛 금속 등불이 중세 기반 판타지에 어울린다. |

### 한계

- 생성형 참고 작업이므로 니브 v03과 정확히 같은 3D 카메라 수치·렌즈·물리 재질·절대 축척을 보증하는 자료가 아니다. 얼굴 회전과 높이는 시각적으로 비교했다. 두 시안의 실제 모델링 크기는 후속 단계에서 정한다.
- 원본 해상도는 1254²이고 1536² 납품은 여백 추가다. 업스케일로 디테일을 늘렸다고 해석하면 안 된다. 알파 정리로 얇은 외곽 1px 정도가 달라질 수 있다.
- SD 단추 눈·둥근 얼굴에서는 실제 나이, 창백함, 무표정과 건조한 유머의 표현 범위가 제한된다. 두 안 모두 아주 옅은 미소와 약한 홍조가 남아 있다.
- B의 모자는 단순하고 얼굴을 가리지 않지만 머리 위 실루엣에서 비중이 크다. 더 높은 실제 게임 카메라에서도 얼굴이 항상 보인다는 보장은 없다.
- A는 어깨의 짧은 망토와 별도로 뒤쪽 보라 자락이 엉덩이까지 일부 보인다. 팔은 분리되며 바닥까지 흐르는 망토는 아니다. 머리의 굵은 웨이브는 후면에서 추가 겹침이 있고, 단일 뷰만으로 3D 전체 구조를 확정할 수 없다.
- 이 자료는 3/4 원화이며 정투영도·후면 설계·리깅이나 Tripo 생성 품질을 보증하지 않는다. 승인·3D 제작·게임 적용은 이후 사용자 선택에 따른다.

## 수정 금지 경로 확인

[raw/protected-files-before.csv](raw/protected-files-before.csv)에 작업 시작 시 출력 폴더 밖 `godot/`, `docs/`, `art/` 기존 파일 **7,225개**의 경로·크기·UTC 수정 시각을 보존했다. [raw/protected-files-report.json](raw/protected-files-report.json) 비교 결과 **기존 파일 삭제·크기·수정 시각 변화 0개, 출력 폴더 밖 신규 파일 0개**다. 전체 보호 파일을 암호학적으로 비교한 것은 아니며 이 검사는 메타데이터 비교다.

네 입력 이미지와 요청서의 SHA256은 [raw/input-hashes.json](raw/input-hashes.json), 납품·원본·프롬프트·스크립트·보고서 등 파일별 bytes와 SHA256은 [raw/artifact-hashes.json](raw/artifact-hashes.json)에 보존했다. 후자는 자기 자신과 `generation.md`를 제외한다. 커밋 명령을 실행하지 않았다.

## SHA256

| 파일 | SHA256 |
| --- | --- |
| `witch-3q-a-v01.png` | `105EFB88D1A6B0449523C1C9B8BC0BA466B41E3B2C3946F77C9424CADDEB3682` |
| `witch-3q-b-v01.png` | `FE4E38BC34E9A348AF117C7ECCB0A6365376DA043A4D7CB222912E71CF775878` |
| `raw/witch-3q-a-v01.png` | `F1345B69B709D707C9EAB26C80497A79B480ED9E0FC4AAD2A8D334927ACA56CA` |
| `raw/witch-3q-b-v01.png` | `5A12E00AB0E8390FACCC9A38A61DC83CD04994D4B235A02BEEE2D79B1CEB0195` |
| 니브 v03 입력 | `D33657A5A0B50B9B8BDD4F6384A3014B49AA0610111DFE8015480D038FF71F1B` |
| 화풍 보조 입력 | `C26F3E21A10E119047DF10986BF4D27720C2E6B7A266ACA142BA2FCF78BF8687` |
| HUD 초상 입력 | `77738AC82F35D225144F7A7B8EAEBF5124016B429456424286FF5845CB2D8404` |
| 모델 시트 입력 | `7029475050485CCA8F7A608324BDE5D11E05DC2D417E4A995BAA1E8C06D34099` |
| 요청서 | `57D3D04334902104B3B0B30603760CB74A3439D5EF6121DAA6358B5FE8B0F51A` |

## 실제 프롬프트 전문

아래 문자열을 각각 별도 생성 호출에 전달했다. 공통 부분도 생략하지 않았다. 각 호출은 위의 4장 실제 입력과 `transparent_background=true`를 사용했다. [raw/prompt-a.txt](raw/prompt-a.txt), [raw/prompt-b.txt](raw/prompt-b.txt)에도 동일한 프롬프트를 보존했다.

### A — 두건 / HUD 초상 기반

```text
Use case: stylized-concept.
Asset type: ONE full-body front-left three-quarter character concept for Tripo 3D modeling, the Northern Witch from Witch's Lodge.
Use ALL FOUR attached images as actual visual references with the following strict hierarchy:
IMAGE 1 nib-3q-v03.png: APPROVED PRIMARY STYLE / PROPORTIONS / CAMERA reference. The witch must stand beside this exact goblin as a character from the SAME toy collection: same smooth matte clay/vinyl finish, same simple sculptural language, similarly oversized head, roughly TWO HEADS TALL excluding headwear, stubby body, tiny rounded feet and mitten hands. Slightly slimmer and neater than Nib. Match the mild elevated camera height and the front-left three-quarter view, face and body turned toward SCREEN LEFT about 30-45 degrees; retain both eyes readable. Do not copy the goblin species, ears, costume, backpack or mischievous smile.
IMAGE 2 stylized-toy-chibi-ref-01.png: secondary sculptural simplification reference ONLY. No copying its individual people or costumes, no collage or four-panel layout.
IMAGE 3 witch_portrait.png: identity reference for concept A (hood, brown wavy hair, cream inner dress, lantern), NOT a rendering-style reference. Do not reproduce its ink outlines, painted texture, hidden eyes, hand-held lantern, long floor-length robe, lighting or pose.
IMAGE 4 02-witch-player.png: identity reference for concept B (bent pointed hat, lavender bob, lavender fur collar, purple coat, brown belt and boots), NOT a rendering-style or multiple-view reference. Do not reproduce its low-poly faceting, huge hat or three-view sheet.

Character/expression: adult woman with a calm pale face, composed and reserved principled innkeeper in her mid-to-late twenties, expressed within toy-chibi proportions. Two dark simple button eyes with ZERO catchlights, a small rounded nose, tiny nearly-neutral closed mouth or very faint restrained smile. Subtly lowered gaze/lids acceptable but no heavy lashes or extra expressive features. No broad smile, playful smirk, large shiny anime eyes or realistic facial anatomy.
Style: smooth matte clay/vinyl toy, soft neutral studio shading like Nib, no ink outlines, no brush texture, no visible polygon facets, no shiny plastic glare. Three to five broad dominant color families, very sparse decoration, large simple sculpted masses. Medieval-based fantasy, preserving medieval everyday atmosphere with permitted fantasy adaptation; plain cloth, leather, simple old metal lantern, no modern items.
Pose/framing: one character, one direction, full body centered in a SQUARE 1536 x 1536 RGBA image with generous transparent margin on every side. Straight upright neutral modeling A-pose. BOTH arms angle diagonally downward AWAY from the torso with visible empty space between hands/forearms and torso. BOTH hands EMPTY: no staff, wand, book, held lantern or magic. One SMALL old lantern with muted amber/yellow solid glass attached to the WAIST BELT, visibly hanging at the hip clear of the nearby hand, no light bloom. Two distinct short legs and separate boots must show below the dress/coat hem for walking animation. Short cape, if any, rests close to the upper torso and stays above/elbow-clear of the arms rather than bridging the hands to the body.
Background/output: REAL transparent alpha, not a checkerboard illustration. Character fully opaque alpha 255; outside alpha 0; only a narrow 1-2 pixel antialiased contour. No floor, ground plane, contact/cast shadow, halo, vignette, backdrop, frame, text, watermark, comparison panel, extra character or additional view.

CREATE CONCEPT A ONLY — HUD PORTRAIT IDENTITY:
A dark muted purple HOOD worn on the head with its opening pulled wide enough to reveal the entire pale face and BOTH button eyes. Hood attached to a SHORT purple capelet, close to upper torso, separate from the arms. Long warm BROWN wavy hair emerges under the hood, reduced to TWO OR THREE broad smooth sculpted locks; no fine strands. A simple CREAM inner dress with modest sleeves and a plain BROWN leather waist belt. Keep the skirt short enough above ankles to clearly show two separate legs and rounded brown shoes/boots below it; not a floor-length silhouette. The long hair should stay clear of arms and not become extra cape layers. Small belt-hung antique lantern with simple dark metal frame and flat amber glass. Restrained purple/cream/brown/pale-skin palette. No pointed hat, lavender hair, fur collar, backpack, brooch or extra ornaments. Prioritize matching Nib's toy simplicity over portrait detail.
```

### B — 뾰족 모자 / 현재 모델 시트 기반

```text
Use case: stylized-concept.
Asset type: ONE full-body front-left three-quarter character concept for Tripo 3D modeling, the Northern Witch from Witch's Lodge.
Use ALL FOUR attached images as actual visual references with the following strict hierarchy:
IMAGE 1 nib-3q-v03.png: APPROVED PRIMARY STYLE / PROPORTIONS / CAMERA reference. The witch must stand beside this exact goblin as a character from the SAME toy collection: same smooth matte clay/vinyl finish, same simple sculptural language, similarly oversized head, roughly TWO HEADS TALL excluding headwear, stubby body, tiny rounded feet and mitten hands. Slightly slimmer and neater than Nib. Match the mild elevated camera height and the front-left three-quarter view, face and body turned toward SCREEN LEFT about 30-45 degrees; retain both eyes readable. Do not copy the goblin species, ears, costume, backpack or mischievous smile.
IMAGE 2 stylized-toy-chibi-ref-01.png: secondary sculptural simplification reference ONLY. No copying its individual people or costumes, no collage or four-panel layout.
IMAGE 3 witch_portrait.png: identity reference for concept A (hood, brown wavy hair, cream inner dress, lantern), NOT a rendering-style reference. Do not reproduce its ink outlines, painted texture, hidden eyes, hand-held lantern, long floor-length robe, lighting or pose.
IMAGE 4 02-witch-player.png: identity reference for concept B (bent pointed hat, lavender bob, lavender fur collar, purple coat, brown belt and boots), NOT a rendering-style or multiple-view reference. Do not reproduce its low-poly faceting, huge hat or three-view sheet.

Character/expression: adult woman with a calm pale face, composed and reserved principled innkeeper in her mid-to-late twenties, expressed within toy-chibi proportions. Two dark simple button eyes with ZERO catchlights, a small rounded nose, tiny nearly-neutral closed mouth or very faint restrained smile. Subtly lowered gaze/lids acceptable but no heavy lashes or extra expressive features. No broad smile, playful smirk, large shiny anime eyes or realistic facial anatomy.
Style: smooth matte clay/vinyl toy, soft neutral studio shading like Nib, no ink outlines, no brush texture, no visible polygon facets, no shiny plastic glare. Three to five broad dominant color families, very sparse decoration, large simple sculpted masses. Medieval-based fantasy, preserving medieval everyday atmosphere with permitted fantasy adaptation; plain cloth, leather, simple old metal lantern, no modern items.
Pose/framing: one character, one direction, full body centered in a SQUARE 1536 x 1536 RGBA image with generous transparent margin on every side. Straight upright neutral modeling A-pose. BOTH arms angle diagonally downward AWAY from the torso with visible empty space between hands/forearms and torso. BOTH hands EMPTY: no staff, wand, book, held lantern or magic. One SMALL old lantern with muted amber/yellow solid glass attached to the WAIST BELT, visibly hanging at the hip clear of the nearby hand, no light bloom. Two distinct short legs and separate boots must show below the dress/coat hem for walking animation. Short cape, if any, rests close to the upper torso and stays above/elbow-clear of the arms rather than bridging the hands to the body.
Background/output: REAL transparent alpha, not a checkerboard illustration. Character fully opaque alpha 255; outside alpha 0; only a narrow 1-2 pixel antialiased contour. No floor, ground plane, contact/cast shadow, halo, vignette, backdrop, frame, text, watermark, comparison panel, extra character or additional view.

CREATE CONCEPT B ONLY — CURRENT MODEL SHEET IDENTITY:
A compact muted PURPLE POINTED WITCH HAT with a gently BENT TIP, simple BROWN band and ONE plain buckle. Hat crown and brim proportionate to the oversized toy head, not towering or oversized. Brim tilted/open enough that both button eyes and the whole face remain visible from the mildly elevated camera. Short LIGHT LAVENDER BOB hair modeled as a few broad rounded masses. A small LIGHT LAVENDER FUR COLLAR represented as just a few blunt soft lobes, no individual fur strands. Plain PURPLE coat with modest short split tails ending above the knees, simple BROWN leather waist belt and one buckle; DARK PURPLE trousers with two clearly distinct legs, BROWN rounded boots. Small old lantern hangs from the waist belt, clear of the empty hand. Sparse purple/lavender/brown/pale-skin palette. No hood, long brown hair, cream dress, backpack, large flowing cape, tassels, embroidered runes or extra ornaments. Convert sheet's faceted surfaces to the SAME smooth matte rounded clay finish as Nib.
```
