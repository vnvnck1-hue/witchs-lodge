# beastfolk 공용 손님 3/4뷰 v02 — 생성·검수 기록

- 요청: `docs/handoff/codex-race-common-models-3q-v02.md`의 **beastfolk 행만** 수행.
- 제작일: 2026-10-20. 방식: 내장 `image_gen`, `transparent_background=true`.
- 납품: `beastfolk-common-3q-v02.png`. 1536×1536, PNG RGBA, 1,213,866 bytes.
- 종족 공용 회색 늑대 여행자. 개인 이름·흉터·찢긴 귀·장신구·무기·등짐을 제거하고 중세 기반 판타지 복식으로 제작.
- 직접 만든 프로젝트 파일은 이 `beastfolk-common-model-v02/` 폴더에만 저장. 다른 종족 폴더, docs, godot, 기존 원화는 수정하지 않았으며 커밋하지 않았다. 게임 적용·실행파일 내보내기는 이번 원화 작업에 포함하지 않는다.
- 생성 도구가 자동 저장한 내부 원본은 그대로 두고 아래 raw/에 복사했다. API/CLI 대체 경로는 사용하지 않았다.

## 입력 이미지 — 실제 열람 및 생성 입력

모두 실제 이미지로 열어 확인하고 첫 생성의 `referenced_image_paths`로 전달했다. 비율·화풍은 1번이 최우선이며, 3번의 키/몸 비율과 개인 특징은 따르지 않았다.

1. `art/concepts/characters/goblin-nib-model-v03/nib-3q-v03.png`
   - 비율·질감·카메라 기준.
   - SHA256: `D33657A5A0B50B9B8BDD4F6384A3014B49AA0610111DFE8015480D038FF71F1B`
2. `art/references/characters/stylized-toy-chibi-ref-01.png`
   - 단순한 장난감 조형 보조 기준.
   - SHA256: `C26F3E21A10E119047DF10986BF4D27720C2E6B7A266ACA142BA2FCF78BF8687`
3. `art/concepts/characters/beastfolk-fargh-model-v01/fargh-3q-b-v01.png`
   - 회색 늑대 정체성과 복식 색만 참고.
   - SHA256: `8DD4093F8F5D127276E7331562564393E144FB92C627F44E9215C6BBCB255B17`

## 생성 이력과 원본

- 1차: `raw/beastfolk-common-3q-v02-gen01.png`, 1254×1254. 귀 제외 머리 비율이 시각 측정 약 40%라 반려하고 보존.
  - SHA256: `0643CD416B237740464B622E82B0EB62E135849990F028A899D7A3B71AD65051`
- 2차: `raw/beastfolk-common-3q-v02-gen02.png`, 1254×1254. 머리를 키우고 몸·다리를 줄이는 내장 image_gen 보정. 입력 순서는 1차 수인 PNG, 니브 v03 PNG.
  - SHA256: `9E1A3FE2F010453F2EF61F9246B58EE1DE3C09ED74489FCFBA5CE68423055894`
- 생성 도구가 요청한 1536 대신 1254 정사각 원본을 반환하여, 최종 파일은 System.Drawing으로 **균등 배율과 위치만 정규화**했다. 부위별 변형·색 변경·배경 제거·알파 임계화는 하지 않았다.
  - 배율 1.0955665024630541, 이동 (29.588177339901563, 49.282758620689663), 고품질 bicubic.
  - 1536 투명 캔버스에 전신 높이와 수직 위치를 니브에 맞춤.
  - 재현 스크립트: `raw/verify.ps1`. 기계 측정: `raw/validation.json`.

## 니브와 비율 비교 — 최우선 검수

`raw/nib-beastfolk-proportion-comparison.png`를 실제로 열어 두 캐릭터를 같은 캔버스 배율로 나란히 비교했다. 푸른 가로선은 머리 위/아래와 발바닥 높이의 보조선이다.

| 항목 | 니브 v03 | beastfolk v02 |
| --- | ---: | ---: |
| 캔버스 | 1536×1536 | 1536×1536 |
| 전신 bbox (alpha > 127, 포함 좌표) | (327,218)–(1267,1329) | (352,218)–(1185,1330) |
| 전체 높이 (귀 포함) | 1112px | 1113px |
| 머리 위 경계 (귀 제외, 두상+머리/털) | 약 y218 | 약 y312 |
| 턱 아래 경계 | 약 y733 | 약 y832 |
| 머리 높이 | 약 515px | 약 520px |
| 머리/전체 키 | 약 46.3% | 약 46.7% |

- 니브와 차이 약 **0.4%p**, 요청의 약 45%에 근접. 귀 높이를 머리에 포함해서 비율을 부풀리지 않았다.
- 머리 너비는 어깨보다 넓고, 짧은 둥근 몸통·아주 짧은 다리·큰 장화·뭉툭한 손으로 구성.
- 머리 경계는 2D 투영 원화에서 사람이 읽은 약값이다. 대략 ±10px 오차가 가능하며 3D 해부 측정값이 아니다. 전체 bbox는 알파로 자동 측정했다.

## 알파·시각 검수

- 최종 PNG RGBA / 1536×1536 확인.
- 완전 투명 픽셀 1,736,581개, 중간 알파 620,251개, 완전 불투명 2,464개. 생성 원본 내부도 대체로 alpha 253의 거의 불투명 값이므로 알파를 강제로 255로 바꾸지 않았다.
- 네 모서리와 캔버스 테두리는 alpha 0. 테두리의 비투명 픽셀 0개. 단색 배경이나 체크무늬가 그려진 이미지가 아니다.
- 최종 투명 PNG와 밝은 바탕의 비교판을 직접 열어 전신, 온전한 두 귀, 크림 주둥이, 하이라이트 없는 단추 눈, 작은 코·입, 빈 양손, 두 다리의 분리, 짧은 망토와 꼬리, 무광 장난감 질감을 확인.
- 평범한 여행자용 가죽 조끼·귀리색 긴 소매 셔츠·벨트·장화이며 현대 소품 없음.
- 한계: 꼬리 뿌리는 뒤쪽 손/몸에 일부 가려진다. 가장자리에는 생성 원본의 미세한 저알파 색 흔적이 일부 남으며, 완전한 3D 메시·리깅·후면 구조나 게임 축소 가독성을 검증한 자료는 아니다. 부드러운 재질 음영은 남아 있으며 단색 벡터 도안은 아니다.

## 최종 SHA256

`7B68157C1ED5B23217A92CD0CD55BBAE51A93ADF84C589DE89C8D9FA44803762`

## 실제 프롬프트 전문 — 1차

입력 순서: 니브 v03 / 장난감 참고 / fargh v01 B.

```text
Use case: stylized-concept.
Asset: ONE reusable beastfolk race common traveler model-sheet illustration, 1536 x 1536 square, genuine transparent RGBA background.

REFERENCE PRIORITY:
Image 1 (nib-3q-v03.png) is the PRIMARY approved reference for extremely squat chibi proportions, head-to-body scale, camera, framing and smooth matte clay/vinyl toy rendering.
Image 2 (stylized-toy-chibi-ref-01.png) supports chunky simplified toy sculpting only.
Image 3 (fargh-3q-b-v01.png) gives ONLY gray wolf species, cream muzzle and clothing palette. Its taller body/smaller skull is REJECTED. Do NOT preserve its proportions, scar, damaged ear, angry eyebrows, fur textures or personal identity.

THE MOST IMPORTANT REQUIREMENT: match Nib's giant head and very short body exactly. The actual rounded wolf SKULL including sculpted crown fur but EXCLUDING the upright ears must be about 500 px high, approximately 45% of the entire character height (about 1100 px including ears) on the 1536 canvas. Ears DO NOT count as head size: do not cheat by using tall ears on a small skull. Target approximate vertical landmarks: ear tips y=220, crown of rounded skull y=300, bottom of cream jaw/chin y=805, soles y=1320. That is a 505 px skull and 1100 px whole silhouette. Keep both ears short and complete. The huge round skull is at least shoulder-width; the torso is a short round bean, the legs are extremely short stubs with oversized boots almost directly below the torso, NO long thighs or shins. Nib-like 2.2-head toy proportions. Preserve these proportions even if you simplify clothing.

SUBJECT: a calm friendly generic gray wolf beastfolk medieval traveler, not an individual named character. Huge rounded gray wolf head, two INTACT simple triangular ears, cream muzzle/cheeks in large smooth molded masses, small rounded dark nose, tiny quiet smile, two large solid dark button eyes with absolutely NO catchlights, NO visible iris/pupil detail, NO detailed brows, no wrinkles, no scars. A bushy gray tail with cream tip curves behind and to the right, separate from the hand and legs where possible. Tail is made from 2-3 large chunky rounded tufts, not individual strands.
Clothing: plain warm brown leather vest, oatmeal cream long-sleeve shirt, simple brown belt with one small muted brass buckle, dark brown stubby trousers and chunky rounded brown boots. Short muted forest green cloak hugging shoulders and upper back, no long flowing cape. Only 3-5 large main color families: gray, cream, brown, muted green, tiny dark facial details. No jewelry or personal insignia.

POSE AND CAMERA: use the same front-left three-quarter camera direction and slightly elevated toy camera height as Nib. Full body, single figure, standing upright neutral A-pose with both EMPTY mitten-like hands angled down and visibly clear of the torso, both feet grounded and visibly separated. No props, weapons, shield, backpack, bedroll, lantern or base.
STYLE: match Nib's smooth matte hand-sculpted clay/vinyl toy: large clean rounded forms, very sparse large color blocks, broad soft diffuse lighting, subtle form shading, no outline, no hair strands, no fabric grain, no realistic fur, no seam clutter, no grunge or surface cracks.
World: medieval-based fantasy, retaining medieval everyday atmosphere with fantasy adaptation allowed.
COMPOSITION: centered complete silhouette, approx y=220 to y=1320, ample transparent margin on all sides, neither ear nor tail cropped, no text or labels, no scenery, no contact-shadow plane, no checkerboard painted into image. Real transparent alpha required.
This is one standalone beastfolk illustration; do not generate Nib, the reference contact sheet, any other species, or a comparison sheet.
```

## 실제 프롬프트 전문 — 2차 보정

입력 순서: 1차 수인 원본 / 니브 v03. 두 호출 모두 transparent_background=true.

```text
Use case: precise-object-edit / stylized-concept.
Edit the FIRST attached image, the gray wolf common traveler. The SECOND attached image, Nib v03, is the approved proportion/style reference.

Correct one crucial issue: the gray wolf's rounded head EXCLUDING EARS is still too small relative to its full height. Its ear tips to sole height is about 1030 pixels, while crown-to-chin skull height is only about 415 pixels: 40%. We need 45-46%, matching Nib.
Enlarge the actual round skull vertically and a little horizontally by about 15%, WITHOUT enlarging the ears. Shorten the ears to two small intact wolf triangles rising above a larger rounded cranium. Let the crown of the huge round head rise closer to the ear tips. Compress the torso/legs slightly so the head-to-whole-height ratio reaches 45-46%. Extremely short chunky legs and boots immediately below the short torso. The visible head should feel almost as large as the entire rest of the body, just like Nib.
Keep the wolf's calm sweet face, two large dark matte button eyes without catchlights, small dark nose, cream muzzle, gray crown fur masses, plain leather vest, oatmeal sleeves, simple belt, short green cloak, empty mitten hands, brown boots and bushy cream-tipped tail. Both hands slightly clear of torso, both legs clearly separate. Keep the first image's front-left three-quarter pose, diffuse matte clay/vinyl toy style, 3-5 large color families, minimal detail and no outlines.
Render as one complete centered wolf traveler on a TRUE TRANSPARENT RGBA background, a 1536 by 1536 square. Reduce the overall figure coverage a little: total character height roughly 1100 pixels on the 1536 canvas, around 72% of canvas height, with equal ample top/bottom transparent padding, soles around y=1320 and ear tips around y=220. Crown-to-chin actual skull should be about 500px. No text, props, jewelry, weapons, backpack, scars, ear damage, ground, background or shadows on a plane.
Medieval-based fantasy retaining medieval everyday atmosphere with fantasy adaptation allowed. This is a reusable race-common traveler, not an individual portrait.
```

