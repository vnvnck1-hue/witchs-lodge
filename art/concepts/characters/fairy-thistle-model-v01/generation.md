# 티슬 · 요정 3D 모델링용 3/4뷰 시안 v01 제작 기록

- 제작일: 2026-10-20 (Asia/Seoul)
- 기준 요청서: `docs/handoff/codex-fairy-thistle-model-3q-v01.md`, `docs/handoff/codex-race-models-3q-common-v01.md`
- 방법: 내장 `image_gen.imagegen`, `transparent_background: true`. CLI/API 우회 생성 없음.
- 작업 파일은 이 폴더와 `raw/` 안에만 저장했다. 입력 이미지는 읽기 전용으로 열어 보고 실제 이미지 참조로 전달했다. 다른 종족 폴더·문서·게임·실행파일 수정 및 커밋 없음.
- 생성 도구가 자동 관리하는 원본 캐시는 `C:/Users/Loadcomplete/.codex/generated_images/01a158a2-d7f1-7433-911a-e0f70c92e180/`에 생겼으며, 납품에 필요한 모든 원본을 이 폴더의 `raw/`로 복사했다.

## 납품

| 파일 | 내용 | 크기 | 바이트 | SHA256 |
| --- | --- | --- | ---: | --- |
| [thistle-3q-a-v01.png](thistle-3q-a-v01.png) | 도토리 깍정이 투구·엉겅퀴 꽃·보라/초록 잎 갑옷·짧은 망토·등에 비스듬히 멘 엉겅퀴 창 | 1536×1536, 8bit RGBA PNG | 1389646 | `DA4ABBE0A730C777CC83066BC76FCA9994FCCF84BEDB6AFC6BBF8ED727386438` |
| [thistle-3q-b-v01.png](thistle-3q-b-v01.png) | 투구·창·꽃 장식 제거, 단순한 초록 잎 튜닉·작은 망토, 은발 땋은 머리 노출 | 1536×1536, 8bit RGBA PNG | 1154853 | `8B2EF729EB013F12828DA8A74443CCB4316FD6A9F6DA006AED82E91A4D0663C2` |

## 실제 입력 이미지

아래 네 파일을 `view_image`로 실제로 열어 확인하고, 모든 생성 호출의 `referenced_image_paths`에 전달했다. 티슬 초상의 세부 카드 화풍은 채택하지 않았다.

| 순서 | 프로젝트 루트 기준 경로 | 역할 | SHA256 |
| --- | --- | --- | --- |
| 1 | `art/concepts/characters/goblin-nib-model-v03/nib-3q-v03.png` | 1순위 화풍·큰 머리 비례·카메라·마감 | `D33657A5A0B50B9B8BDD4F6384A3014B49AA0610111DFE8015480D038FF71F1B` |
| 2 | `art/concepts/characters/witch-north-model-v01/witch-3q-a-v01.png` | 2순위 동일 게임의 점토 조형 | `105EFB88D1A6B0449523C1C9B8BC0BA466B41E3B2C3946F77C9424CADDEB3682` |
| 3 | `art/references/characters/stylized-toy-chibi-ref-01.png` | 조형 언어만, 인물·의상 복제 금지 | `C26F3E21A10E119047DF10986BF4D27720C2E6B7A266ACA142BA2FCF78BF8687` |
| 4 | `godot/assets/portraits/guest_thistle_cutout.png` | 피부·은발·더듬이·귀·잎 갑옷·자연 소품의 정체성 | `ACE2AB063A4825D1D3E47894EAECB0364082EB1EC8761FD1BB134A5688B5BB10` |

세계관은 `docs/art-direction.md`와 `docs/world-races-card-formats-v01.md`의 중세 기반 판타지 기준을 읽고 적용했다. 현대 재봉·현대 소품을 넣지 않았고, 장난감 재질은 렌더링 표현이다.

## 생성 순서와 원본

| 호출 | 실제 참조 순서 | 원본 보존 파일 | 도구 캐시 파일명 | SHA256 |
| --- | --- | --- | --- | --- |
| A 1차 | 공통 입력 1, 2, 3, 4 | `raw/thistle-3q-a-generated-01.png` | `exec-49b10e9e-0b42-4ac9-8df2-22f38aaa9435.png` | `DFF7CF795D56F7A51014707A2BD988D419BF9045A5D3AD3B98A28306BBCE93B3` |
| A 보정 | A 1차, 공통 입력 1, 2, 3, 4 | `raw/thistle-3q-a-generated-02.png` | `exec-a5b6cae7-bc48-4199-b374-80b9e9731985.png` | `E2CA9130618FCBC44F34C1B477A563971EBBBA584EB514A48BB21016EB4C3AD8` |
| B | A 보정, 공통 입력 1, 2, 3, 4 | `raw/thistle-3q-b-generated-01.png` | `exec-017a06e5-ba6c-473d-abfb-39dc9f24c5c2.png` | `EDCD821D286CA31CE69BFBEB6BCC37787B717C8DC4576576E1482AE26B1C5746` |

A 1차는 잎 조각이 많아 보정했고, A 보정본을 최종 A의 소스로 선택했다. B는 A 보정본을 편집 대상으로 사용해 정체성과 화풍을 유지했다.

## 실제 프롬프트 전문

아래는 요약이 아닌 세 호출에 전달한 원문이다. 모든 호출에서 `transparent_background=true`를 별도 인자로 전달했다.

### A 1차

```text
Use case: stylized-concept.
Asset type: Thistle fairy mercenary, concept A, 3D modeling reference for Witch's Lodge.
Create exactly ONE full-body character, square 1536 x 1536 PNG, genuinely transparent background.
REFERENCE INPUTS (in order): 1 approved Nib goblin is the PRIMARY source of sculpt style, roughly two-head-tall proportion, camera and finish; 2 approved witch is SECONDARY same-game sculpt style; 3 toy chibi sheet for shape language only, never copy its characters/clothes; 4 Thistle portrait for identity/colors/costume only, DISCARD its realistic anatomy, linework and detailed textures.
Subject: a tiny slender fairy nature spirit, NOT an elf, narrower shoulders and a slightly smaller stature than Nib, oversized round head and short body, approximately 2 heads tall excluding antennae. Light lavender skin, pointed ears, silver-white hair simplified into broad smooth locks and a short chunky braid. Two distinct curved antennae emerging from the top of the head. A serious proud little knight face, chin slightly lifted, two solid dark button eyes without highlights, tiny rounded nose, small closed determined mouth, very minimal eyebrows.
Concept A costume: simple brown acorn-cup helmet, recognize the acorn cup with a smooth rounded cap and just 3-4 broad facets, NO tiny scales. One simplified purple thistle flower decoration. Leaf armor tunic formed from only 3-4 BIG smooth leaf lobes in muted purple and dark forest green, no tiny leaves, thorns, veins, embroidery or rivets. Very short close-fitting dark green cape behind the torso, never covers the upper arms. Brown mitten-like gloves, simple brown little boots, two exposed lavender lower legs clearly separated with transparent gap between them.
FOUR WINGS, exactly two pairs: simple thick opaque elongated dragonfly-wing plates in pale cream and pale lavender, rooted to the back, swept UP and BACK with clean visible silhouettes above/behind the shoulders. Both wing pairs must be visibly countable, two on each side. They are opaque modeling pieces, not translucent glass: NO veins, no membranes, no thin lines. Keep wings clearly distinct from arms and torso; do not fill the negative spaces beneath the A-pose arms.
A separate simple thistle spear is strapped diagonally across the BACK, not held, a smooth green shaft with one simplified purple thistle-flower spearhead, maximum height barely above helmet and below antenna tips. Keep weapon clearly distinct as a detachable shape and do not obscure the wings, face or hands.
Pose and camera: match image 1, front-left three-quarter view 30-45 degrees, face turned slightly toward viewer's left; gentle elevated camera as Nib, upright and still, feet standing apart. BOTH arms angled down and away from body in a readable relaxed A-pose; BOTH EMPTY HANDS fully visible, hands hold nothing. Torso, both arms and both lower legs are distinct forms, transparent gaps beneath arms and between legs. Entire character including all antennae, wing tips, spear and boots inside canvas with generous transparent padding on ALL four sides.
Style/medium: same smooth matte clay/vinyl toy sculpt rendering and soft rounded forms as approved Nib and witch. Broad restrained color families (lavender, ivory silver, forest green, muted purple, brown), soft form shading, clean untextured color masses, no outlines or ink, no realistic anatomy, no detailed surface texture. Medieval-based fantasy retaining medieval everyday atmosphere with fantasy adaptation permitted; natural leaf/acorn/cloth/leather forms, no modern tailoring, no manufactured plastic accessories (toy is only the rendering style).
Lighting: soft studio lighting, no ground plane, no cast shadow outside the character, no scenery, no text, labels, frames or watermark. True alpha: character surfaces including wings fully opaque 255, empty exterior and interior gaps alpha 0, only a tight 1-2 pixel antialias edge. Deliver just the single finished character image.
```

### A 보정

```text
Use case: precise-object-edit / stylized-concept.
Edit image 1, Thistle concept A, into the final single-character 3D modeling concept, square 1536x1536 with real transparent alpha.
Inputs: image 1 is the edit target; image 2 approved Nib is the primary STYLE, TWO-HEAD proportion and CAMERA reference; image 3 approved witch is secondary style; image 4 toy sheet is only shape-language reference; image 5 portrait is Thistle identity only.
Preserve the lavender fairy, matte smooth clay toy finish, proud small closed mouth, solid highlight-free button eyes, short chunky silver-white braid, two pointed ears, two curved antennae, simplified brown acorn-cup helmet with one purple thistle ornament, brown gloves and boots, four distinct opaque cream/lavender wing plates, short dark green cape, and diagonal green thistle spear carried on the BACK with both hands EMPTY.
Make these focused corrections:
1. Simplify the entire armored TUNIC to only FOUR LARGE broad smooth overlapping leaf shapes total, two dark green and two muted purple, no leaf scales or rows of small leaves. Clean broad shape masses like Nib, no leaf veins.
2. Turn the entire body, head and feet together to the same clear front-left THREE-QUARTER angle as Nib, approximately 35 degrees, looking toward the viewer's left, with a subtly elevated camera matching Nib. No frontal view.
3. Keep the tiny narrow-shouldered fairy's head large, approximately TWO HEADS tall excluding antennae. Upright relaxed A pose, both arms completely separate from torso, visible transparent gaps under arms, empty mitten hands, two separately visible lavender lower legs and separated feet.
4. Keep all FOUR WINGS as simple fully OPAQUE smooth solid plates (two cream upper, two pale lavender lower), swept UP and BACK, behind rather than crossing arms. Keep both pairs countable. Short cape does not cover arms. Spear is a separate detachable diagonal back-mounted form with simplified purple thistle-flower spear tip; tip remains below antenna tops.
5. Center the full character smaller inside a square 1536x1536 canvas, with generous transparent padding, at least 160 pixels on every side including above antennae and around wing/spear tips. No isolated speckles, no ground shadow, no background or checkerboard drawn into pixels.
Keep same same-game Nib/witch smooth matte sculpt and soft form shading, broad lavender/ivory/green/purple/brown color families, NO outlines, ink, fine textures, realistic anatomy, detailed flower petals, tiny acorn scales, veins, rivets or embroidery. Medieval-based fantasy preserving medieval life atmosphere, fantasy adaptation allowed. Natural leaves/acorn/cloth/leather costume, no modern tailoring or plastic costume accessories.
Output exactly one full-body fairy facing one direction, no labels/text/extra objects. True alpha: all character surfaces and wings alpha255, empty space alpha0, only 1-2px antialiasing at silhouette; no translucent colored fringes or scattered dots.
```

### B

```text
Use case: precise-object-edit / stylized-concept.
Asset type: Thistle fairy concept B, reusable ordinary fairy visitor model, one full-body 3D modeling reference.
INPUTS: 1 Thistle concept A is the EDIT TARGET and locks the same fairy identity, silhouette, face, body proportions and matte clay finish. 2 Nib is the highest priority style/proportion/camera reference. 3 witch is secondary style. 4 toy sheet is shape language only. 5 portrait is original Thistle identity only; discard its realistic anatomy and ink detail.
Create the SAME tiny slender two-head-tall lavender fairy from image 1, now in simple ordinary medieval woodland travel clothing for recoloring as a seed courier or gardener. Transform A into B:
REMOVE the acorn helmet completely; REMOVE both purple thistle flower decorations completely; REMOVE the entire diagonal spear and its straps, no weapons, armor or tool of any kind.
Expose the simple SILVER-WHITE HAIR as a smooth rounded sculpt cap with just 3-4 broad hair locks framing the face and the same short chunky silver-white BRAID behind the nearer pointed ear. Keep EXACTLY TWO lavender curved antennae, very clearly rooted at the top of the exposed hair. Keep both pointed ears prominent.
Replace layered purple/green armor with a VERY SIMPLE soft green leaf-shaped TUNIC, a smooth plain upper body and only THREE LARGE rounded leaf points at its short hem. No stacked leaf scales, no purple armor plates, no ornament on chest. Add only a plain narrow brown belt with a small plain buckle. A tiny dark green LEAF CAPE rests on the BACK close to the upper torso, stops above hips and never covers either upper arm.
Keep brown simple mitten gloves and plain brown little boots, short ivory sleeves and two separate lavender lower legs visible under the hem. Keep the same serious, brave little knight-like expression: chin a little raised, dark solid highlight-free button eyes, tiny nose and tiny closed determined mouth; no anime eyes.
Preserve EXACTLY FOUR fully OPAQUE dragonfly wing plates, TWO PAIRS, two pale cream upper and two pale lavender lower wings rooted visibly behind the upper back, swept UP and BACK, countable silhouettes. No veins or translucency. Wings and cape must never fill the transparent gaps below either arm.
Camera and pose: upright, relaxed A-pose, both arms angled DOWN AND OUT with clear transparent gaps separating them from the torso; BOTH HANDS EMPTY and visible. Feet separated with a clear gap, body/head/feet all in a front-left THREE-QUARTER VIEW 30-45 degrees looking toward viewer's left, slightly elevated camera matching Nib. Maintain slender narrow shoulders and oversized head approximately TWO HEADS tall excluding antennae. Full body, all wing and antenna tips included, generous transparent padding on every side.
Smooth matte clay/vinyl toy RENDERING like Nib/witch, broad simple ivory/green/lavender/brown color masses, no outlines or linework, no tiny hair strands, leaf veins, stitches, rivets, realistic skin textures or dense detail. Medieval-based fantasy preserving medieval everyday atmosphere with fantasy adaptation allowed, natural cloth/leaves/leather, no modern tailoring or manufactured plastic costume accessories.
Square 1536x1536 PNG with true transparent alpha, no backdrop/ground plane/shadow/scattered dots, no text or watermark, one character and one view only. All character and wing surfaces alpha255, exterior and interior gaps alpha0 with only a tight 1-2px antialias edge.
```

## 크기·알파 처리와 검수

생성 프롬프트에서 1536×1536을 요청했으나 도구가 실제 저장한 세 원본은 모두 1254×1254다. 원본을 변경하지 않고 보존했다. A 보정본은 alpha0 999,583 / alpha255 2,367 / 중간 알파 570,566픽셀이고, B 원본은 alpha0 1,059,591 / alpha255 2,186 / 중간 알파 510,739픽셀이었다. 본체의 많은 픽셀이 253이어서 그대로 납품하지 않았다.

[raw/finalize.ps1](raw/finalize.ps1)은 재현 가능한 파일 규격·알파 정리 스크립트다. 조형 수정은 이미지 생성 도구로 수행했고, 이 스크립트는 외곽 정리·배치·보간만 수행한다.

1. 원본의 alpha≥128에서 8방향 연결된 가장 큰 본체 마스크를 구한다. 선택한 A·B 모두 이 마스크의 연결 성분은 1개이며, alpha≥128의 본체에서 제거된 픽셀은 0개다.
2. 본체는 alpha255로 만들고, alpha1~127은 본체에서 2px 이내만 보존한다. 본체와 멀리 떨어진 저알파 노이즈를 제거하고 반투명 외곽 RGB는 가까운 본체 RGB로 정리한다.
3. 본체 경계에 원본 3px 보호 여백을 더한 뒤, 긴 변 1216px로 종횡비를 유지해 고품질 bicubic 보간하고 1536×1536 투명 캔버스 중앙에 놓는다. A 소스 크롭 931×1138 → 약 1.06854배, B 949×1141 → 약 1.06573배다.
4. 최종 alpha≥128은 255로 정규화하고, 그 아래의 반투명 픽셀은 alpha255 픽셀의 체비쇼프 거리 1px 이내에만 남긴다. 그 밖은 RGBA0이다. 불투명 판 형태 날개에도 같은 처리를 적용했다.
5. 최종 PNG 두 장과 회색 배경의 [비교 검수 이미지](raw/qa-contact-sheet.png)를 실제로 열어 확인했다. 검수용 비교 이미지는 배경이 있는 자료이며 투명 납품본을 대체하지 않는다.

| 항목 | A | B |
| --- | ---: | ---: |
| 최종 크기 | 1536×1536 | 1536×1536 |
| alpha0 픽셀 | 1,736,896 | 1,813,068 |
| alpha255 픽셀 | 614,515 | 539,081 |
| alpha1~254 픽셀 (외곽 AA) | 7,885 | 7,147 |
| alpha255 본체에서 1px 초과 떨어진 AA | 0 | 0 |
| 유효 알파 bbox (양 끝 포함) | x272~1262, y162~1373 | x264~1270, y162~1372 |
| 투명 여백 좌/상/우/하 | 272 / 162 / 273 / 162px | 264 / 162 / 265 / 163px |

상세 수치는 [raw/alpha-audit.txt](raw/alpha-audit.txt)에 보존했다. 각 파일의 전체 2,359,296픽셀에 대해 alpha0+alpha255+AA 합계가 일치한다. 외곽 AA를 제외한 본체·날개는 완전 불투명이고, 빈 배경·팔과 다리 사이 공간은 실제 투명이다.

## 시각 검수

- **화풍:** 니브 v03·마녀 A와 대조했다. 무광의 둥근 점토 조형, 먹선 없는 큰 색면, 하이라이트 없는 검은 단추 눈, 작은 코와 입, 부드러운 명암을 확인했다. 피부·옷에 카드 초상의 리벳·자수·미세 잎맥·사슬 묘사가 없다.
- **정체성:** 연보라 피부, 두 뾰족 귀, 은백색의 굵게 땋은 머리, 위로 나온 더듬이 두 가닥, 크림/연보라 불투명 날개 두 쌍이 두 시안에 유지된다. 작고 가는 체형과 당찬 표정을 확인했다.
- **시점과 구도:** 니브와 같은 방향의 앞-왼쪽 3/4 전신 단일 시점으로, 얼굴의 양쪽 면과 옆 땋은 머리·등 소품의 깊이가 읽힌다. 더듬이·날개·창·장화가 잘리지 않고 사방 여백이 있다.
- **자세:** 두 팔을 아래 바깥으로 벌린 A자이고, 양손이 비어 있다. 손목과 몸통 사이에 투명 공간이 있다. 창은 손이 아닌 등에 대각선으로 고정되어 있다.
- **걷기 분리:** 양쪽 연보라 하퇴와 장화가 옷자락 밑으로 따로 보이고 다리 사이가 뚫려 있다. 망토는 짧고 상완을 덮지 않는다.
- **날개:** 상부 크림 2개와 하부 연보라 2개를 구분할 수 있으며, 잎맥 없는 두꺼운 판 조형이다. 팔 뒤의 높은 위치로 펼쳐져 아래의 팔·몸통 분리 공간을 막지 않는다.
- **A:** 도토리 투구·꽃·잎 갑옷·짧은 초록 망토·갈색 장갑·등의 엉겅퀴 창을 확인했다. 창 꽃 끝은 더듬이 최고점보다 낮다. 큰 잎 중심으로 1차보다 단순화했다.
- **B:** 투구·창·꽃 장식·등의 무기 스트랩이 제거되었다. 평범한 잎 튜닉과 작은 잎 망토로 정리했고, 머리·더듬이·귀가 더 드러난다. 씨앗 배달부·정원사 등의 색 교체 기반으로 사용할 수 있다.
- **시대:** 자연의 잎·도토리·직물·가죽에 기반한 중세 판타지 의상으로 확인했다.

## 한계와 후속 모델링 주의

- 원화 시안이며 3D 모델·리깅·게임 적용·사용자 승인을 완료한 자료가 아니다. 등 뒤 날개 뿌리·창 고정 방식·망토 뒤쪽은 일부 가려져 있어 모델 제작 시 별도 구조 해석이 필요하다.
- 1536px는 원본 1254px에서 본체를 정리해 재배치·약 1.07배 보간한 납품 규격이다. 생성 원본 자체가 네이티브 1536px였다는 의미는 아니다.
- 3/4 각도와 약 2등신은 눈으로 비교한 조형 기준이며 정확한 3D 카메라 각도·실측 비례·니브보다 작은 실제 게임 스케일을 계측한 것은 아니다. 더듬이·투구를 몸 비례 측정에 포함하지 않는다.
- A의 갑옷은 큰 앞면 잎과 뒤쪽 겹침 끝이 보이는 조형이다. 3~4개 큰 덩어리라는 방향으로 단순화했지만, 정확히 3~4장의 독립 메시로 분할된 설계도는 아니다. 꽃 역시 단순화한 볼륨 묶음으로 모델링할 수 있다.
- A·B는 생성 이미지 기반이므로 얼굴과 땋은 머리 실루엣이 완전히 픽셀 단위로 일치하지는 않는다. 같은 종족·인물의 모델 기반으로 사용할 때 표정·귀·날개·머리 파츠를 공통화하는 것이 적합하다.
- 투명 마스크의 낮은 알파 노이즈 제거와 외곽 정규화가 있어 최종 파일은 원본과 해시가 다르다. 최종 알파 검수는 납품본에 대한 것이며, 보존 원본의 중간 알파까지 수정하지 않았다.

