# 종족 공용 오크 3/4 모델링 원화 v02

- 제작일: 2026-10-20 (Asia/Seoul).
- 요청서: `docs/handoff/codex-race-common-models-3q-v02.md`의 **orc 행 하나만** 수행.
- 최종: [orc-common-3q-v02.png](orc-common-3q-v02.png), **1536×1536 RGBA PNG**, 1,192,522 bytes.
- 도구: 내장 `image_gen.imagegen` 2회, 모두 `transparent_background=true`. CLI/API 대체 생성 없음.
- 1차 생성 후 높은 상투를 낮춘 2차 편집을 채택했다. 일반 여행자이며 특정 인물 이름·수염·흉터·개인 장신구·이빨 목걸이는 넣지 않았다.
- 프로젝트에 작성한 파일은 모두 이 `orc-common-model-v02/` 폴더 안에만 있다. 다른 종족 출력 폴더, 입력 원화, `docs/**`, `godot/**` 수정 없음. 게임 적용·실행파일 재내보내기·커밋 없음.

## 입력 이미지를 실제로 열어 사용

세 파일을 모두 `view_image`로 열어 직접 확인한 다음 아래 순서 그대로 첫 생성의 `referenced_image_paths`에 첨부했다. 경로 텍스트만 전달한 작업이 아니다.

1. `art/concepts/characters/goblin-nib-model-v03/nib-3q-v03.png` — **최우선 비율·화풍·카메라 기준**.
2. `art/references/characters/stylized-toy-chibi-ref-01.png` — 간결한 장난감 덩어리와 색면 보조.
3. `art/concepts/characters/orc-garok-model-v01/garok-3q-b-v01.png` — 오크 특징·복색만 참고. 작은 머리·긴 몸과 다리·맨팔·수염·목걸이는 계승하지 않도록 명시.

2차 편집 입력은 실제로 연 [raw/generated-01.png](raw/generated-01.png), 니브 v03 순서다. 상투를 낮추고 머리색을 짙은 차콜로 조정하도록 요청했다.

중세 기반 판타지 및 중세 생활감과 분위기를 유지하면서 판타지적 각색을 허용한다는 세계관을 아트 가이드·세계관 기획에서 확인하고 두 프롬프트에 반영했다.

## 원본 보존·크기·마감

- 첫 도구 원본: [raw/generated-01.png](raw/generated-01.png), 1254×1254. 도구 저장본을 바이트 그대로 복사.
- 채택 도구 원본: [raw/generated-02.png](raw/generated-02.png), 1254×1254. 도구 저장본을 바이트 그대로 복사.
- 도구 원본 디렉터리: `C:/Users/Loadcomplete/.codex/generated_images/01a158b3-fded-79a2-9190-92f98f979e6e/`.
- 1차 파일: `exec-5354e67f-ca7d-43d7-bf00-c7174d505f69.png`; 2차 파일: `exec-eba92a84-9bf2-4f11-a71f-18ecdac36c0b.png`.
- 도구 실제 반환 크기가 1536² 요청과 달라, [raw/normalize-layout.ps1](raw/normalize-layout.ps1)로 니브 v03과 같은 캔버스 내 높이에 정렬했다. **균등 1.1855010660980809배**, X 이동 48.35608, Y 이동 -28.5842285. High-quality bicubic 사용. 부위별 크기 조절·비균등 왜곡 없음.
- 알파 ≥192 기준 원본 경계: (252,208)–(1011,1145), 정렬 기준 니브: (327,218)–(1267,1329). 상세 [raw/layout-report.json](raw/layout-report.json).
- 중간 배치 이미지: [raw/layout-normalized.png](raw/layout-normalized.png). 최종본과 구분한다.
- 니브 v03의 기존 정렬·알파 마감 스크립트를 읽고 **오크 폴더 내부에 사본을 작성**, 클래스·입출력 경로만 맞춰 사용했다. 원래 스크립트는 수정하지 않았다.
- [raw/alpha-cleanup.ps1](raw/alpha-cleanup.ps1): 알파 ≥192 마스크, 1px opening, 최대 연결 성분 유지, 16px 이하 내부 핀홀 채움, 좁은 경계 AA 재구성, 경계 RGB를 인접 내부색으로 보완. 색상 키 사용 없음. 본체의 RGB 색면을 다시 그리거나 채색하지 않았다.
- 알파 마감은 생성본에 남은 본체 알파 252~253 및 미세 외곽 잔여를 정리하기 위한 결정적 후처리다. 캐릭터 그림과 상투 수정은 내장 이미지 도구로 수행했다.

## 니브와 비율 직접 비교

[raw/nib-orc-proportion-proof.png](raw/nib-orc-proportion-proof.png)를 실제로 열어 나란히 비교했다. 두 그림을 같은 1536² 패널에 **추가 확대·축소 없이** 배치하고 정수 좌표 보조선을 표시했다. 제작 스크립트: [raw/compare-proportions.ps1](raw/compare-proportions.ps1).

측정 정의: 최종 알파 >0 경계 기준 전체 키(머리카락/상투 최고점부터 가장 낮은 장화 밑창까지, inclusive). 머리 높이는 같은 최고점부터 턱 아래까지이며 **귀의 좌우 돌출은 제외, 머리카락과 상투는 포함**한다. 턱은 목·깃에 가려지는 부분이 있어 시각 추정 ±4px이다. 정확한 3D 해부 치수가 아니다.

| 항목 | 니브 v03 | 오크 v02 |
| --- | ---: | ---: |
| 캔버스 | 1536×1536 | 1536×1536 |
| 최고점 Y | 217 | 217 |
| 밑창 최저점 Y | 1330 | 1330 |
| 전체 키 | 1,114px | 1,114px |
| 턱 아래 Y, 추정 | 734 | 729 |
| 머리 높이, 추정 | 518px | 513px |
| 머리 / 전체 키 | **46.50%** | **46.05%** |
| 전체 키 / 머리 높이 | 약 2.15등신 | 약 2.17등신 |

차이 약 **0.45%p**. 요청의 약 45%, 전체 약 1100px·머리 약 500px 조건과 니브의 실제 비율을 가깝게 맞췄다. 1차 시안은 상투 포함 머리 비율이 시각상 약 49%여서 채택하지 않았고, 2차에서 상투를 낮췄다. 얼굴·두상은 크게 유지했다. 몸통은 짧고 넓게, 무릎 구간은 매우 짧으며 장화가 튜닉 바로 아래에 온다. 귀 포함 머리 실루엣은 어깨보다 넓다.

## 알파·시각 검수

상세 [raw/alpha-report.json](raw/alpha-report.json). 이 보고서의 Raw 항목은 도구 원본이 아니라 **1536² 배치 정규화 중간본**이다.

| 항목 | 최종 결과 |
| --- | ---: |
| PNG 크기 | 1536×1536 |
| 알파 0 | 1,717,309px |
| 알파 255 | 633,056px |
| 경계 부분 알파 | 8,931px |
| 내부 코어 완전 불투명 | 631,129 / 631,129 = 100% |
| 바깥 완전 투명 | 1,715,423 / 1,715,423 = 100% |
| 경계 부분 알파 반경 | 실루엣 안팎 1px 이내 |
| 알파 1~7 / 252~253 | 0 / 0px |
| 연결 성분 | 1개 |
| 최종 실루엣 경계, inclusive | (345,217)–(1247,1330) |
| 투명 여백 좌/상/우/하 | 345 / 217 / 288 / 205px |

코어는 3×3 이웃이 모두 마스크 내부인 픽셀, 바깥은 3×3 이웃에 마스크가 없는 픽셀로 정의한다. 좁은 AA 경계는 두 분모에서 제외한다.

최종 PNG, [흰색·회색 알파 검수판](raw/alpha-proof.png), 니브와의 비교판을 모두 실제로 열어 확인했다.

- 한 명의 전신, 앞-왼쪽 3/4 방향, 큰 머리·짧고 둥근 몸·아주 짧은 다리·두툼한 빈손을 확인.
- 녹색 계열 피부, 짧은 아래턱 흰 엄니 두 개, 짙은 차콜 상투, 크림 모피 깃, **손목까지 덮는 소매 있는 가죽 튜닉**, 붉은 허리띠, 장화.
- 큰 단추 눈에 흰 하이라이트가 없으며 얼굴은 작고 간결한 코·입과 차분한 표정이다.
- 두 손은 비었고 무기·방패·배낭·목걸이·별 원판·개인 장신구가 없다. 장화 사이 투명 공간과 하부 소매/손–몸통 사이 투명 틈을 유지했다.
- 무광 장난감 표면과 큰 색면을 유지하고, 털가닥·가죽 흠집·주름을 세밀하게 채우지 않았다. 배경·그림자·바닥·글자·프레임 없음.

한계: 턱 기준점은 시각 추정이며 ±4px 오차가 있다. 카메라는 투시가 있는 단일 컨셉 이미지로 정투영도나 후면 설계가 아니다. 어깨에 붙는 소매와 깃의 겹침은 남고 팔 아래 틈은 좁으므로, 리깅용으로 더 벌린 A포즈가 필요하면 별도 모델링 판단이 필요하다. 피부는 참고 복색을 따른 황록색, 머리는 조명 아래 차콜 회갈색으로 읽힐 수 있다. 상투 포함 비율 외에 개별 두상·어깨 폭의 정확한 3D 치수는 확정하지 않았다.

## SHA256

| 파일 | SHA256 |
| --- | --- |
| 최종 orc-common-3q-v02.png | `4E3B07FD431A6A0C54CAD7CCB2ABAA4871C961A6F7DCCC68612EAD4AA8549833` |
| raw/generated-01.png | `F4563872BF4325C293EBB66EBF0B7C348AD2890443211E4B4C80E0F7C850525B` |
| raw/generated-02.png | `2B3F5A5F35C22FA00C17785619DE6591F9512563AE5A124FAF410D4C98C244E3` |
| 입력 nib-3q-v03.png | `D33657A5A0B50B9B8BDD4F6384A3014B49AA0610111DFE8015480D038FF71F1B` |
| 입력 stylized-toy-chibi-ref-01.png | `C26F3E21A10E119047DF10986BF4D27720C2E6B7A266ACA142BA2FCF78BF8687` |
| 입력 garok-3q-b-v01.png | `C84B42656DCE2637A3036C033ED718D50D17C795E98EA83E0A17ADEBEE905AAA` |

## 실제 프롬프트 전문 — 1차 생성

별도 원문: [raw/prompt-01.txt](raw/prompt-01.txt).

```text
Use case: stylized-concept
Asset type: single generic ORC race traveler concept for 3D modeling, Witch's Lodge medieval fantasy game.
Primary request: create ONE NEW generic orc, NOT the named individual Garok. Match reference image 1 Nib v03's extremely squat chibi proportions and smooth matte toy style as the highest priority. Image 3 is only identity/clothing palette reference; DO NOT copy its smaller head, long torso, legs, bare arms, beard or jewelry.

Input images:
1. nib-3q-v03.png: PRIMARY exact head-to-height proportion, camera direction, simple button-eye face and smooth matte clay/vinyl rendering reference.
2. stylized-toy-chibi-ref-01.png: supporting simplified large color masses and toy design only.
3. garok-3q-b-v01.png: orc species and green/brown/cream/red palette only; explicitly replace the old adult-tall anatomy and remove all personal accessories.

PROPORTION IS THE MOST IMPORTANT REQUIREMENT:
On a 1536x1536 transparent square, one character standing about 1100px tall, top near y=220 and soles near y=1320. Head including scalp hair AND a small compact black topknot, excluding lateral ears, is about 500px high (45-47% of the entire standing height). The actual face/cranium is very large; DO NOT obtain the measurement with a tall tuft on a small skull. Chin approximately y=720. The huge round head is almost as tall as torso plus legs combined, exactly the baby-like proportions of image 1. Head width at least the shoulder width. Broad stocky rounded shoulders and barrel body achieved through WIDTH ONLY. Torso very short. Extremely short separated stub legs; big plain boots immediately below the tunic. No long shins. Small blunt mitten hands. A compact black topknot, no tall ponytail.

Subject and clothing: anonymous friendly green-skinned orc traveler, intact small pointed ears, exactly two short ivory tusks projecting upward from the lower jaw, black hair gathered into a small plain topknot. Two large dark flat button eyes with NO catchlights; small simple nose, tiny calm mouth, gentle neutral expression. No detailed brows, wrinkles, scars or facial hair. Cream-colored short close-fitting fur collar modeled as only a few smooth broad lobes. Plain brown leather tunic WITH FULL SLEEVES covering both arms to the wrists (only hands exposed); muted red cloth sash around waist; tiny brown leg section and oversized plain brown boots. No exposed muscular upper arms or forearms. Just 3-5 main color groups: green skin, dark hair/eyes, brown leather/boots, cream collar/tusks, muted red sash.

Pose and camera: full-body front-left three-quarter view 30-45 degrees, facing slightly toward screen left, exact same eye-level/slightly elevated toy camera as Nib image 1, no dramatic perspective. Upright neutral A-pose: arms angle outward/down leaving clearly visible transparent gaps between BOTH arms and torso; two boots and legs visibly separated by a transparent gap. Both empty hands clearly visible. No handheld objects, weapons, shield, backpack or luggage. No cape required.

Style/medium: smooth matte clay/vinyl collectible toy, broad clean rounded forms, minimal decoration, no contour outlines, soft simple studio shading, not detailed leather or fur texture. Medieval-based fantasy, preserving the everyday atmosphere and clothing of a medieval world while allowing fantasy adaptation. No modern materials, technology or accessories.
Background: genuine transparent alpha, no backdrop, no checkerboard painted in, no floor, no cast shadow or contact shadow, no pedestal.
Output: 1536x1536 RGBA PNG, entire subject inside frame with transparent margin on all sides. One character only, no text, no labels, no props.
Avoid: adult/tall anatomy, small head, long body, long legs, huge hair tuft, shiny eyes, angry face, skin pores, embroidery, necklace, tooth pendant, star medallion, earrings, buckles or other personal jewelry, bare arms, exposed muscles, fur strands, scratches, multiple views, environmental objects.
```

## 실제 프롬프트 전문 — 2차 상투 편집

별도 원문: [raw/prompt-02.txt](raw/prompt-02.txt).

```text
Use case: precise-object-edit
Edit target: image 1, the newly generated generic orc traveler. Image 2 Nib is proportion/style comparison only.
Make one narrowly targeted refinement to image 1: reduce ONLY the black topknot protrusion vertically so it is a much smaller compact knot sitting close to the crown, with its highest point about 50 pixels lower on the current 1254-pixel canvas. Preserve the massive round cranium, front hair locks, face, lower chin, body, exact clothing, hands, pose, camera and soles in the same positions. The topknot must remain visible and recognizably tied up, just much smaller, lower and compact. Make all hair charcoal-black rather than brown, with matte broad simple forms.
Highest priority: measured from highest hair point INCLUDING the small topknot to the chin, head height should be 45-47% of the standing height from highest hair point to lowest boot sole, matching Nib image 2. Do not shrink the face or skull. Do not lengthen torso or legs. No other anatomy or costume changes.
Keep the generic green orc's two short ivory lower tusks, two large dark button eyes without catchlights, tiny nose and calm mouth, cream simple close-fitting collar, brown FULL-SLEEVED leather tunic covering the arms to the wrists, muted red sash, very short separated legs and brown boots, blunt empty mitten hands, neutral upright A-pose and front-left three-quarter view. No personal jewelry, beard, weapons, luggage or background. Smooth matte clay/vinyl toy, medieval-based fantasy preserving medieval everyday clothing atmosphere while allowing fantasy adaptation. Single full character, genuine transparent background, no floor or shadow, no text. Preserve empty margin, use 1536x1536 RGBA if possible.
```

