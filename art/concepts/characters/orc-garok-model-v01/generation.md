# 가로크 · 오크 3D 모델링용 3/4뷰 시안 v01

제작일: 2026-10-20 (Asia/Seoul)  
도구: 내장 image_gen / imagegen 스킬, A·B 각각 1회 생성. CLI/API 폴백 사용 없음.  
작업 범위: 이 출력 폴더 안의 원화·원본·검수 기록. 게임 적용·모델 제작·실행파일 내보내기·커밋 없음.

## 납품

| 파일 | 내용 | 형식 |
| --- | --- | --- |
| [garok-3q-a-v01.png](garok-3q-a-v01.png) | 초상 충실: 청동 어깨 갑옷·갈색 가죽 갑옷·짧은 붉은 망토·붉은 허리띠·별 원판 버클·이빨 목걸이·허리의 검 | 1536×1536, 8bit RGBA PNG |
| [garok-3q-b-v01.png](garok-3q-b-v01.png) | 공용 겸용: 갑옷·검·망토·금속 장식을 뺀 가죽 튜닉, 붉은 허리띠·모피 깃·이빨 목걸이 | 1536×1536, 8bit RGBA PNG |

## 읽은 기준과 실제 이미지 입력

인물 요청서: `docs/handoff/codex-orc-garok-model-3q-v01.md`  
공통 요건: `docs/handoff/codex-race-models-3q-common-v01.md`  
세계관: `docs/world-races-card-formats-v01.md`, `docs/art-direction.md`

아래 네 파일을 **view_image로 실제로 열어 확인한 뒤, A·B 모두 referenced_image_paths에 실제 이미지 입력으로 전달**했다. 참고 이미지를 복사하거나 수정하지 않았다.

1. `art/concepts/characters/goblin-nib-model-v03/nib-3q-v03.png` — 최우선 화풍·비례·카메라·단순 얼굴.
2. `art/concepts/characters/witch-north-model-v01/witch-3q-a-v01.png` — 같은 게임의 무광 점토 마감.
3. `art/references/characters/stylized-toy-chibi-ref-01.png` — 큰 덩어리 조형만 참고, 인물·복식 복제 없음.
4. `godot/assets/portraits/guest_garok_cutout.png` — 녹색 피부·아래턱 엄니·상투·희끗한 옆머리·짧은 수염·색 배치·복식 정체성.

B에는 다섯 번째 입력으로 `raw/garok-3q-a-generated-v01.png`를 추가하여 A의 얼굴·체형·자세를 이어 갔다. 이 파일도 생성 후 실제 이미지로 열어 확인했다.

## 원본과 후처리

- 원본: `raw/garok-3q-a-generated-v01.png`, `raw/garok-3q-b-generated-v01.png`. 두 파일 모두 1254×1254이며 생성 결과를 그대로 보존했다.
- 내장 도구가 생성한 캐시 원본 경로:
  - A: `C:/Users/Loadcomplete/.codex/generated_images/01a158a2-d89d-7852-b770-771337ddda51/exec-f8f31e7c-cf42-43e6-8b05-5064afda7402.png`
  - B: `C:/Users/Loadcomplete/.codex/generated_images/01a158a2-d89d-7852-b770-771337ddda51/exec-f0fa589d-2d2a-45dd-80cb-d52576c7bd19.png`
- 직접 작성·복사·수정한 프로젝트 파일은 이 출력 폴더 안에만 있다. 위 경로는 내장 생성 도구가 관리하는 기본 캐시다.
- 1536×1536 요청과 달리 도구 원본은 1254×1254였다. 원화 확대·재표본화 없이 사방에 141px 투명 여백을 더했다.
- 원본은 몸체 대부분의 알파가 255 미만이며 외부에 낮은 알파 잡음이 있었다. 이를 완제품으로 그대로 납품하지 않았다.
- `raw/verify.ps1`의 System.Drawing 처리로 원본 알파 128 이상에서 주 실루엣을 취하고, 3×3 이진 커버리지로 약 1~2px 외곽 안티에일리어싱을 만들었다. 2px보다 깊은 반투명 픽셀은 255로 정리했다.
- 본체 RGB는 유지하고, 외곽에 추가되는 안티에일리어싱 픽셀은 가장 가까운 본체 색을 사용했다. 포즈·장비·복식·피부색을 수작업으로 다시 그리거나 재생성하지 않았다.
- 재현·검수: `powershell -NoProfile -ExecutionPolicy Bypass -File art/concepts/characters/orc-garok-model-v01/raw/verify.ps1`. 실행 정책 변경은 해당 프로세스에만 적용된다.
- `raw/qa-a-gray.png`, `raw/qa-b-gray.png`는 중간 회색 배경 합성 검수용이며 최종 납품 PNG의 배경이 아니다.

## 알파·크기 검수

1536×1536 = 2,359,296 픽셀. 전체 캔버스 알파를 검사했다. 사방 끝 행·열이 모두 0인지, 불투명·투명 영역이 존재하는지, 외곽 2px를 넘는 반투명이 없는지 스크립트에서 실패 조건으로 검사한다. 깊이는 투명 픽셀까지의 8방향 격자 거리다.

| 항목 | A | B |
| --- | --- | --- |
| 최종 크기 | 1536×1536 | 1536×1536 |
| 본체 alpha=255 | 565,614px | 572,132px |
| 바깥 alpha=0 | 1,781,472px | 1,773,696px |
| 외곽 alpha=1~254 | 12,210px | 13,468px |
| 반투명 최대 깊이 | 2px | 2px |
| 2px보다 깊은 반투명 | 0px | 0px |
| alpha>0 바운딩 박스, 양 끝 포함 | (294,195)–(1240,1325) | (298,179)–(1237,1355) |
| 최소 사방 투명 여백 | 195px | 179px |

상세 측정: `raw/alpha-audit.txt`.

## SHA256

| 파일 | SHA256 |
| --- | --- |
| garok-3q-a-v01.png | `95B5DB045F43BF72A0BA814DDC37B3B8299AAA1DA8EDF084AE3373C85A816B94` |
| garok-3q-b-v01.png | `C84B42656DCE2637A3036C033ED718D50D17C795E98EA83E0A17ADEBEE905AAA` |
| raw/garok-3q-a-generated-v01.png | `87187ABC1132A7E596463FFB3410C7079528956D272F1E6A0A44BA6B17A19658` |
| raw/garok-3q-b-generated-v01.png | `5A947F3F0231603FFC77741F769C3E397BA584787F5581B698612FE12962C6B0` |

## 시각 검수

생성 원본・회색 합성・최종 투명 PNG를 실제 이미지로 열어 확인했다.

| 항목 | 결과 |
| --- | --- |
| 니브 v03·마녀 A와 화풍 | 무광 점토 장난감, 큰 둥근 머리와 짧고 굵은 팔다리, 검은 먹선 없음, 부드러운 명암. 장비·모피·머리카락을 큰 조형으로 단순화 |
| 얼굴 | 하이라이트 없는 단추 눈 둘, 작은 코·닫힌 작은 입. 녹색 피부·흰 엄니 둘·검은 상투·회색 옆머리·짧은 턱수염. 위협적이지 않은 차분한 표정 |
| 체격·비례 | 약 2등신 계열의 큰 머리, 넓은 어깨와 굵은 팔. A·B 동일 인물로 읽히는 얼굴과 체형 |
| 3/4 | 니브와 같은 이미지 왼쪽을 향한 앞-왼쪽 3/4, 두 눈과 귀·옆면이 보이며 윗면이 조금 보이는 시점 |
| 전신·여백 | 머리·상투·양손·발·검집까지 잘림 없음. 한 명·한 방향, 사방 투명 여백 |
| A자·빈손 | 똑바로 선 자세에서 양팔을 아래 바깥으로 벌림. 손은 모두 비어 있고 몸통 옆에 빈 공간 확보 |
| 다리 분리 | 짧은 옷자락 아래 두 다리와 두 부츠가 각각 보이며 사이가 투명하게 분리됨 |
| A의 정체성 | 청동 어깨 갑옷, 가죽 갑옷, 크림 모피, 붉은 망토·허리띠, 별 황동 원판, 이빨 목걸이. 검은 손이 아니라 허리의 별도 검집에 있음 |
| B 공용성 | 갑옷·검·망토·별 버클 제거. 단순 가죽 튜닉과 붉은 띠, 모피·목걸이를 유지하여 색상 교체용 공용 복식으로 사용 가능 |
| 시대 기준 | 가죽·천·모피·뼈·청동의 중세 판타지 복식. 현대 도구·현대 재봉 장식·플라스틱 장신구 없음 |

## 한계와 모델링 인계

- 납품은 단일 시점 원화 두 장이다. 실제 메시·리깅·파츠 분리·걷기 동작을 검증한 것은 아니다.
- 카메라는 참고 이미지와 시각적으로 맞춘 생성 결과이며 정밀 각도나 직교 투영을 측정한 도면이 아니다. 후면은 이 원화로 확정할 수 없다.
- A·B는 독립 생성이므로 미세한 크기·포즈·얼굴 형태 차이가 있다. 동일 메시의 의상 교체나 픽셀 일치를 보장하지 않는다.
- 인간 대표 원화를 이번 입력으로 쓰지 않았으므로 ‘인간보다 머리 반 개 큰’ 월드 단위 상대 축척은 실제 모델 배치 시 맞춰야 한다. 이미지는 넓은 어깨·굵은 팔로 오크의 큰 체격을 전달한다.
- 점토 표면에 미세한 생성 질감은 남는다. 모피는 큰 둥근 덩어리로 단순화했지만 뒤쪽 겹침까지 포함하면 3~4개보다 많은 분절이 읽힐 수 있다. 실제 모델에서는 3~4개의 주 덩어리로 합치면 된다.
- A의 어깨 갑옷은 상완 시작부와, 짧은 망토는 팔 뒤쪽과 일부 겹친다. 팔과 몸통 사이 빈 공간 및 빈손은 보이며, 모델 제작 시 갑옷·망토를 몸통 파츠로 두고 어깨 관절 간섭을 확인해야 한다.
- 알파 정리는 경계의 극미세 픽셀에 영향을 준다. 원본 RGB·알파 검토가 필요하면 `raw/` 원본을 사용한다. 보간 확대 없이 여백만 더했으므로 실질 원화 해상도는 생성 원본 수준이다.

## 실제 프롬프트 전문 · A

아래 텍스트를 그대로 내장 image_gen에 전달했다. `transparent_background=true`, 위 공통 입력 이미지 4개의 절대경로를 `referenced_image_paths`로 전달했다. 프롬프트 사본: `raw/prompt-a.txt`.

```text
Use case: stylized-concept.
Create ONE final character concept image, Variant A: GAROK the orc mercenary, for 3D modeling in Witch's Lodge. Requested canvas 1536 x 1536, genuine transparent RGBA background.
Use ALL FOUR attached local images as actual visual references, in this exact order:
1. nib-3q-v03.png: PRIMARY approved style, two-head-tall proportions, camera height and front-left three-quarter orientation, matte smooth clay toy finish and simple face.
2. witch-3q-a-v01.png: SECONDARY approved same-game style and finish.
3. stylized-toy-chibi-ref-01.png: sculptural language only, do NOT copy any person or outfit.
4. guest_garok_cutout.png: Garok's identity, green skin, color placement, topknot, tusks, costume and accessories ONLY. Completely discard its ink outlines, realism, texture and detail density.

Scene/backdrop: absolutely transparent empty background, no floor, no pedestal, no cast shadow, no checkerboard artwork.
Subject: one full-body male orc oathkeeping escort captain, calm, solid, dependable, not angry. Huge rounded head, roughly TWO heads tall including body, wide shoulders and thick arms, the largest race build; eventual intended height about half a human head taller than the human representative at the same world scale. Broad chunky toy-like silhouette, not realistic musculature. Green skin, two small white upward tusks emerging from lower jaw beside a SMALL CLOSED mouth. Exactly two dark button eyes WITHOUT highlights or sclera; small rounded nose. Minimal relaxed eyebrows if needed, no scowl or wrinkles. Black hair in a compact crown topknot, simple grey temple patches and compact short charcoal chin beard. Short modest orc ears, not Nib's giant goblin ears.
Outfit A: plain brown leather armor as large smooth slabs; simplified bronze shoulder armor with NO rivets or engraving, compact so it cannot cover the arms; cream fur collar built from ONLY 3 or 4 large smooth rounded clumps close to neck, no individual fur strands. Short deep-red cloak closely attached behind torso, ending around hip height, never covering the arms or legs. Deep-red waist sash with one round brass disk buckle bearing one simple embossed star. Small tooth/bone necklace reduced to a few broad ivory pendants, not intricate beads. Simple brown trousers and chunky brown boots.
Sword: a single clearly separate sheathed sword suspended at the hip, unmistakable hilt, guard and scabbard, short and simplified, alongside outer thigh without merging into a hand or leg. Both hands completely EMPTY; no raised weapon, no objects held.
Pose: upright neutral MODELING A-POSE, BOTH arms spread diagonally down and outward with a clear transparent air gap from torso on each side; hands away from hip and sword. Both separate legs visible from short tunic hem down, broad clear transparent gap between legs and between boots for walk animation. Collar, pauldrons and cloak must not obscure arms. One character, one direction, no sheet or extra views.
Composition: match Nib's front-left 3/4 view at approximately 30 to 45 degrees, face directed toward image-left and both eyes visible. Match Nib camera elevation with a little top surface visible. Whole silhouette centered with generous empty alpha margin on all four sides, no cropping.
Style/medium: match Nib and witch exactly: a polished but matte clay/vinyl collectible TOY rendering, large softly rounded sculpted forms, soft lighting and restrained ambient contact shading, no hard outlines. Vinyl is only the rendering language, the in-world clothes are medieval leather, cloth, fur, bronze and bone. Group colors into 3 to 5 dominant masses: green skin, brown outfit and black hair, red cloth, cream fur/bone, muted bronze accents. NO microtexture, pores, hair strands, fur fibers, chain links, stitches, scratches, leather grain, ornate patterns or cinematic harsh shadows.
World: medieval-based fantasy, maintaining medieval daily-life atmosphere while permitting conventional fantasy adaptation. No modern materials, modern tailoring or plastic jewelry.
Output: image only, no lettering, labels, watermark or frame. Genuine alpha: opaque character interior alpha 255, empty exterior alpha 0 and only a narrow 1 to 2 px antialiased silhouette edge. Preserve the full figure.
```

## 실제 프롬프트 전문 · B

아래 텍스트를 그대로 내장 image_gen에 전달했다. `transparent_background=true`, 공통 이미지 4개와 A 생성 원본을 합친 5개의 절대경로를 `referenced_image_paths`로 전달했다. 프롬프트 사본: `raw/prompt-b.txt`.

```text
Use case: stylized-concept.
Create ONE final concept image, Variant B: GAROK / reusable common ORC traveler, for 3D modeling in Witch's Lodge. Requested 1536 x 1536 square, genuine transparent RGBA.
Use all FIVE actual reference images:
1. nib-3q-v03.png: PRIMARY approved matte clay toy style, simple face, two-head proportions and front-left 3/4 camera.
2. witch-3q-a-v01.png: SECONDARY approved same-game sculptural finish.
3. stylized-toy-chibi-ref-01.png: large rounded sculptural masses only, do not copy outfits/characters.
4. guest_garok_cutout.png: original Garok identity and medieval color scheme only, NOT its realistic illustration detail or outlines.
5. garok-3q-a-generated-v01.png: Garok A, preserve this exact orc identity, face, thick limbs, topknot, ear shape, relaxed reliable expression, pose and camera. Generate its unarmored travel-clothing counterpart B. Treat this as outfit simplification with the same person; primary Nib/witch style remains authoritative.

Keep: broad largest-race orc build, thick shoulders and arms, huge rounded head and roughly TWO-head-tall chibi proportions. Olive GREEN skin; two short WHITE lower-jaw tusks clearly visible beside a SMALL CLOSED mouth; TWO simple dark button eyes without highlights, pupils or sclera; tiny rounded nose; compact black crown topknot with smooth grey temple patches; compact short charcoal chin beard. Calm and dependable, not angry, no wrinkles or anatomical realism. Same head/body balance and camera as A.
B clothing: a very plain sleeveless brown leather travel TUNIC, a simple broad DEEP-RED cloth waist sash (no metal buckle or chest plates), cream fur collar in ONLY 3 or 4 rounded smooth clumps closely around neck, one simple tooth/bone necklace with three broad ivory pendants on a plain brown cord. Plain brown trousers, chunky brown boots. Keep hem SHORT above knees and no long dangling sash over legs. This modest generic outfit must suit an orc cook, shaman or pilgrim after simple recoloring.
REMOVE ALL ARMOR, all shoulder plates, bracers, armor panels, decorative cross-belts, brass buckles, metal ornaments, weapon, sword, sword belt, scabbard, cloak, backpack and tools. No extra accessories. Exposed arms are green and clearly show orc build. Do not add buttons, modern seams, lacing or stitching.

Pose/composition: EXACT SAME front-left 3/4 as A and Nib, face toward image-left, 30 to 45 degrees, both eyes visible, slightly elevated camera. Full body upright neutral modeling A-POSE. BOTH arms angled down and away from body, obvious empty alpha air gap between each arm and the torso. BOTH HANDS EMPTY, relaxed chunky toy hands. Two separate legs clearly visible below tunic hem, clear alpha gap between the legs AND boots, no skirt or robe hiding legs. Collar must not cover arms. One character, one view, centered, generous empty transparent margin all sides. No cropping.
Rendering: approved Nib/witch smooth MATTE clay/vinyl-toy finish and minimal decoration. Large simple masses and soft light, no ink outline. Fur is 3 or 4 soft rounded clumps, hair is big sculpted lumps, not fibers. 3 to 5 dominant colors: olive green, plain brown, deep red, cream ivory, near-black hair. Medieval-world leather/cloth/fur/bone interpreted as toy sculpture, no plastic in-world accessories.
World: medieval-based fantasy, maintaining medieval daily-life atmosphere while permitting conventional fantasy adaptation. No modern materials, modern tailoring, plastic jewelry.
Backdrop/output: truly transparent, no ground, no stand, no cast shadow, no checkerboard pattern. Character interior alpha 255, empty exterior alpha 0 with only a narrow 1 to 2 pixel silhouette antialias edge. No lettering, labels, watermark or frame. Output a single finished character image.
```

