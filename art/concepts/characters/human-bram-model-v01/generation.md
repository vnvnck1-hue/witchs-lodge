# 브람 3/4뷰 모델링 원화 A·B 제작 기록 v01

- 제작일: 2026-10-20
- 요청 기준: `docs/handoff/codex-human-bram-model-3q-v01.md`, `docs/handoff/codex-race-models-3q-common-v01.md`.
- 방식: 내장 `image_gen`, `transparent_background=true`. A 1회 생성, A를 실제 편집 입력으로 사용한 B 1회 생성. CLI/API 대체 경로 미사용.
- 신규 작업 파일은 모두 `art/concepts/characters/human-bram-model-v01/` 내부에 보존했다. 기존 원화·초상·문서·다른 종족 폴더·게임 파일은 수정하지 않았으며 커밋하지 않았다.
- 생성 도구는 원본을 도구 기본 저장소에도 자동 생성한다. 원본을 아래 raw 경로에 복사해 보존했으며 도구 기본 저장소를 수동 수정/삭제하지 않았다.

## 실제 이미지 입력

아래 네 파일을 `view_image`로 실제 열어 확인했으며, A 호출의 `referenced_image_paths`에 아래 순서로 모두 전달했다.

1. `art/concepts/characters/goblin-nib-model-v03/nib-3q-v03.png` — 1순위 화풍·비례·카메라.
2. `art/concepts/characters/witch-north-model-v01/witch-3q-a-v01.png` — 2순위 화풍·동일 게임 마감.
3. `art/references/characters/stylized-toy-chibi-ref-01.png` — 조형 언어만 참고.
4. `godot/assets/portraits/guest_bram_cutout.png` — 얼굴 정체성·복식·색 배치.

B 호출은 `raw/bram-3q-a-generated.png`를 첫 번째 편집 대상 입력으로 추가하고 위 네 파일을 2~5번으로 전달했다. A의 얼굴·자세·마감을 유지하며 의상과 장비만 바꾸도록 요청했다. 입력 파일들은 읽기만 했다.
세계관·아트 지침도 읽고 중세 기반 판타지의 생활감, 의복·가죽·금속의 단순화에 반영했다.

## 납품물

| 파일 | 규격 | 바이트 | SHA256 |
| --- | --- | ---: | --- |
| [bram-3q-a-v01.png](bram-3q-a-v01.png) | 1536×1536 RGBA PNG | 959016 | `EF352C83F573BAAA2A18F0E07A4B0C9931D256AF9068F4AA9E83E7179462750C` |
| [bram-3q-b-v01.png](bram-3q-b-v01.png) | 1536×1536 RGBA PNG | 1036758 | `E086783C11A8F022694835618E24BDDFC3E2FB752AFFCF2F1B756567FF9AA753` |

- **A:** 초상 충실. 크림 모피 깃, 짧은 초록 망토, 갈색 가죽 옷·장화·벨트, 한쪽 강철 어깨받이와 팔토시, 인물의 왼쪽 허리에 칼집째 찬 검.
- **B:** 같은 브람의 인간 공용 여행복. 검·칼집·갑옷을 모두 없애고 귀리색 셔츠·갈색 조끼, 두건 없는 짧은 초록 망토와 크림 모피 깃을 유지했다.

## 원본과 마감

- [A 생성 원본](raw/bram-3q-a-generated.png): 1254×1254, 759392 bytes, SHA256 `C09722A7B85E5DCB9A15A1363DBFBF32EDA4C69EA7D3B05DA266BAEBD2B7F380`.
- [B 생성 원본](raw/bram-3q-b-generated.png): 1254×1254, 825067 bytes, SHA256 `0EE1C349E04B7FF98142F74176ECFD072C710714904E6C9E7A5BF6C32E4590BF`.
- 원본 픽셀 크기를 유지하며 상하좌우에 141px씩 투명 여백을 추가해 1536×1536으로 맞췄다. 확대 보간·늘리기·자르기는 하지 않았다.
- 원본은 본체 대부분이 alpha253이고 배경에 낮은 알파의 미세한 잔여 픽셀이 있었다. 납품 조건에 따라 alpha16 이상 최대 8방향 연결 실루엣을 유지하고 고립된 배경 잔여를 제거했다. 외곽 2px보다 안쪽은 alpha255로 정규화하고 바깥은 alpha0으로 처리했다.
- 외곽 2px 이내에서만 원래 알파 계조를 253→255 환산해 유지했다. 경계 RGB는 가장 가까운 본체 색으로 정리했으며 내부 RGB·의상·구도는 유지했다.
- 재실행 가능한 마감·검수 코드: [raw/validate.ps1](raw/validate.ps1).
- 수치 검사 전문(알파 256단계 히스토그램 포함): [raw/alpha-report.json](raw/alpha-report.json).
- 회색 배경 합성 QA 이미지: [A](raw/qa-a-gray.png), [B](raw/qa-b-gray.png). 이 두 파일은 경계 검수용 불투명 미리보기이며 실제 납품 PNG는 투명하다.
- 모든 파일의 해시 목록: [raw/file-manifest.json](raw/file-manifest.json).

## 알파 수치 검수

전체 픽셀 수는 각 2,359,296개. 외곽 깊이는 alpha0 픽셀에서부터의 8방향 격자 거리로 계산했다.

| 항목 | A | B |
| --- | ---: | ---: |
| alpha0 픽셀 | 1,932,814 | 1,864,470 |
| alpha255 픽셀 | 416,969 | 485,058 |
| alpha1~254 경계 픽셀 | 9,513 | 9,768 |
| 외곽에서 2px 초과 깊이의 반투명 픽셀 | 0 | 0 |
| 반투명 픽셀 최대 깊이 | 2px | 2px |
| 실루엣 bbox (좌·상·우·하, 포함 좌표) | 418·252·1118·1293 | 405·221·1143·1332 |
| 사방 투명 여백 (좌·상·우·하) | 418·252·417·242px | 405·221·392·203px |

## 시각 검수와 한계

최종 투명 PNG 두 장과 회색 배경 합성본 두 장을 실제 이미지로 열어 확인했다.

| 항목 | 확인 결과 |
| --- | --- |
| 니브 v03·마녀 A와 화풍 | 매끈한 무광 점토 장난감, 큰 머리·짧은 팔다리, 부드러운 명암, 먹선 없음. 갈색·초록·크림·피부의 큰 색면과 소량 금속색. |
| 브람 정체성 | 갈색 덩어리 머리, 일부 회색 옆머리, 턱을 감싸는 단일 갈색 수염, 둥근 인간 귀, 단추 눈, 비대칭 눈썹·담담한 입. 웃는 입으로 만들지 않음. |
| 전신·방향 | 앞-왼쪽 3/4, 이미지 왼쪽을 향한 얼굴·발, 사방 여백, 한 명·한 방향. |
| A자·빈손 | 두 팔이 아래 대각선으로 몸통에서 떨어져 있고 손에 든 물건 없음. |
| 다리 분리 | 두 바짓단·장화와 중앙 틈이 드러남. 짧은 망토가 다리 사이를 덮지 않음. |
| A 장비 | 한쪽 어깨받이·양쪽 팔토시, 인물 왼쪽/화면 오른쪽 허리의 검과 칼집이 몸과 구분됨. |
| B 공용성 | 갑옷·검·칼집 제거, 셔츠·조끼·벨트·장화. 짧은 망토에 두건 없음. |
| 중세 기반 | 가죽·셔츠·망토·모피·단순 금속 장비, 현대 소재/재봉/장신구 없이 판타지 각색. |
| 투명 마감 | 실제 alpha0 배경, 내부alpha255, 반투명 외곽 최대2px. 회색 합성본에서 경계·전신 실루엣 재확인. |

한계: 생성 원화이므로 카메라의 정확한 수치·3D 등신·종족 간 절대 키를 계측한 결과는 아니다. 니브 대비 인간의 더 넓은 어깨를 조형으로 표현했으며, 모델링 단계에서 실제 축척을 맞춰야 한다. A/B는 동일 정체성·자세를 참고하지만 완전한 픽셀 일치가 아니며 B의 실루엣 높이가 A보다 약6.7% 크다. 모피 깃과 머리카락은 둥근 덩어리로 단순화했으나 일부 얕은 표면 질감은 남는다. 어깨 망토가 상완 맨 위에 조금 걸치지만 팔의 주요 실루엣과 몸통 사이 간격은 보인다. 검의 후면 부착 구조와 실제 파츠·리깅·걷기 간섭은 이 단일 3/4뷰만으로 검증할 수 없다. 실제 3D 모델 제작이나 게임 적용은 수행하지 않았다.

## 실제 A 생성 프롬프트 전문

`transparent_background=true`; 위 네 원본 이미지를 순서대로 참조 입력.

```text
Use-case: stylized-concept. Create ONE final 3D-modeling reference image, Bram variant A, on a genuinely transparent RGBA canvas, square 1536x1536.
REFERENCE INPUTS (all actual attached images):
Image 1 = approved Nib v03, PRIMARY authority for sculptural language, two-head-tall proportions, finish, camera elevation and front-left three-quarter orientation.
Image 2 = approved witch A, SECONDARY authority for the same game's smooth matte clay/vinyl toy finish.
Image 3 = toy chibi sculptural-language reference ONLY, do not copy its people or costumes.
Image 4 = Bram portrait, IDENTITY/color/clothing reference ONLY. Completely discard its ink lines, detailed textures, realistic face, crossed arms and portrait cropping.
SUBJECT: Bram, a cautious adult human male mercenary from a medieval fantasy world. One character, full body, standing straight, approximately TWO HEADS TALL (oversized head about half the complete height), slightly taller and broader-shouldered than Nib but identical chibi proportion system. Normal rounded human ears. Tousled brown hair sculpted as a few large smooth locks, one small broad grey temple patch. A short brown beard wrapping the chin in ONE smooth sculpted mass, not strands or scalloped locks. Two dark button eyes without highlights, tiny nose, tiny neutral closed mouth, one eyebrow slightly raised: guarded, calm, blunt, NOT smiling or angry.
VARIANT A CLOTHES: cream fur collar simplified into only 3 or 4 large rounded smooth clumps; short dark forest-green cloak held tight behind the torso, stopping at waist/upper hip, does NOT blanket the arms or legs. Brown leather tunic, trousers and boots, simple broad belt and one plain brass buckle. One simple smooth steel shoulder plate on the character's RIGHT shoulder, two simple steel forearm bracers. No rivets, filigree, chain loops or tiny ornamental details. A medieval sword IN ITS CLOSED SCABBARD attached at the character's anatomical LEFT hip (viewer's right), with simple visible hilt and sheath cleanly distinguishable from torso and leg as a detachable prop; it is NOT held.
POSE AND CAMERA: match Image 1's camera direction and height exactly: front-left three-quarter view around 30-45 degrees, face and feet turned slightly toward image-left, see front and side, no back view. Neutral modeling A-pose: both arms extend diagonally downward AWAY from the torso, visible clear negative-space gaps from armpits to wrists, hands relaxed and completely EMPTY. Two separate short legs and two separate boots fully visible with an unmistakable transparent walking gap between them; short clothes do not hide knees/leg separation.
STYLE: same collection as Images 1 and 2: rounded smooth matte clay, subtle soft diffuse shading, no outline or ink, no painterly texture, no fabric grain or fur hairs, large simple 3-5 main color families (brown, dark green, cream, skin, small steel/brass accents). Medieval fantasy hand-made clothing forms, no modern seams/materials or plastic accessories. Simple toy mitt hands, not realistic fingers.
COMPOSITION/ALPHA: ONE character, ONE view only. Center full silhouette with generous empty transparent margins on ALL sides, nothing cropped. Body opaque alpha 255, exterior alpha 0, only 1-2 pixel antialias along silhouette. No ground plane, no cast/drop shadow, no backdrop, no painted checkerboard, no pedestal, no text, no frame, no watermark. This is a reference illustration for later 3D work, not an actual model.
```

## 실제 B 생성 프롬프트 전문

`transparent_background=true`; A 생성 원본 + 위 네 원본 이미지를 순서대로 참조 입력.

```text
Use-case: stylized-concept / identity-preserve. Create ONE Bram variant B reference, a reusable unarmoured human traveler, on a genuinely transparent RGBA 1536x1536 square canvas.
INPUT ROLES:
Image 1 = Bram variant A, edit target / PRIMARY authority for EXACT identity, face, hair, grey temple patch, beard, adult human body, two-head-tall chibi proportions, A-pose, orientation, framing and lighting. Change ONLY the clothing and remove martial equipment as specified below.
Image 2 = approved Nib v03, PRIMARY collection style and camera reference.
Image 3 = approved witch A, SECONDARY collection style reference.
Image 4 = toy chibi reference, sculptural language ONLY; no copied characters or costumes.
Image 5 = Bram's painted portrait, IDENTITY/palette reference ONLY; do not introduce its ink, detail, realistic proportions or crossed-arm pose.
CHANGE TO VARIANT B: REMOVE the sword AND scabbard AND all sword attachments entirely, REMOVE the shoulder armour AND both forearm steel bracers. Dress him in a plain brown leather vest over an oat/cream-colored shirt with simple sleeves, simple brown belt with one plain brass buckle, brown trousers and boots. Keep a HOODLESS short dark forest-green traveling cloak tight behind the torso, stopping at waist/upper hip and never covering the arms or hiding separated legs. Keep the cream fur collar as just 3-4 large rounded smooth clumps. There is absolutely NO armour or weapon, no pouches or tools or extra props. This ordinary medieval fantasy travel outfit should be reusable for human visitors by color changes.
PRESERVE: Bram's tousled brown hair as a few broad smooth locks with subtle grey at the temple; short beard as ONE smooth brown mass around the chin; normal rounded human ears; two simple dark button eyes WITHOUT highlights, tiny nose, tiny neutral closed mouth, slightly raised one eyebrow, reserved wary calm with NO smile. Keep same face and broad shoulders as Image 1. Approximately TWO HEADS TALL, oversized head about half total height. Match Image 2's front-left 3/4 camera around 30-45 degrees and elevation, face/feet turned a little toward image-left.
MODELING POSE: stand straight with both arms extended diagonally down in an A-pose AWAY from torso; clear negative-space gaps from armpits through wrists, absolutely EMPTY relaxed toy-mitten hands. Two short separate legs and two boots fully visible, broad transparent walking gap. No cloak/cloth across the leg gap.
FINISH: smooth matte clay/vinyl toy, rounded chunky clean forms, no ink or outlines, soft diffuse shading, same game collection as approved Nib and witch. Broad brown, dark green, cream and skin color families with only small brass accent. No hair strands, fur texture, stitching, leather grain, decorative seams, embroidery, rivets, scratches, chains, modern materials, modern sewing or plastic accessories. Medieval-based fantasy with daily-life medieval atmosphere and permitted fantasy adaptation.
OUTPUT: exactly ONE character and ONE direction, full-body silhouette centered with generous transparent margins on every side; never crop. Genuine transparent background, body alpha 255, exterior alpha 0, only narrow 1-2px edge antialias. No floor, ground shadow, backdrop, checkerboard painting, pedestal, text, labels, frame or watermark. Preserve Image 1 scale/framing for A/B comparison. A 2D reference image for later modeling, not an actual 3D model.
```

