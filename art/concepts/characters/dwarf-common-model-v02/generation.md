# 드워프 종족 공용 모델 v02 제작 기록

- 요청: `docs/handoff/codex-race-common-models-3q-v02.md`의 dwarf 행만 수행.
- 방식: 내장 `image_gen`, `transparent_background: true`, 실제 로컬 입력 이미지 3장 전달. CLI/API 대체 경로 사용 없음.
- 범위: 이 폴더 안의 최종 PNG, raw 원본, 이 기록만 작성. 게임·문서·기존 원화·다른 종족 폴더 수정 및 커밋 없음.
- 상태: 2026-10-20 제작·최종 검수 완료. 3차 선택, 납품 PNG 규격 정리 및 원본 보존 완료.

## 실제로 열고 생성 입력으로 전달한 이미지

1. `art/concepts/characters/goblin-nib-model-v03/nib-3q-v03.png` — 비율·화풍·카메라·화면 크기 최우선.
2. `art/references/characters/stylized-toy-chibi-ref-01.png` — 보조 화풍.
3. `art/concepts/characters/dwarf-harald-model-v01/harald-3q-b-v01.png` — 드워프 수염·의복·색상만 참고. v01 등신과 대머리 개인 특징 제외.

세 입력 모두 `view_image`로 실제로 열어 확인했다. 생성 호출의 `referenced_image_paths`에도 같은 세 파일을 위 순서로 전달했다.

## 실제 생성 프롬프트 전문 — 1차

```text
Use case: stylized-concept.
Asset type: one reusable DWARF race common guest, full-body 3/4 concept image for 3D modeling, not a portrait or character card.
Reference inputs: Image 1 nib-3q-v03.png is the STRICT primary reference for head-to-body ratio, overall on-canvas size, camera and smooth matte clay/vinyl toy finish. Image 2 stylized-toy-chibi-ref-01.png is secondary simplification/style reference only. Image 3 harald-3q-b-v01.png is ONLY dwarf identity and clothing/palette reference; REJECT its taller proportions and bald personal identity.
Generate a NEW generic dwarf traveler, no named-character markers.
TOP PRIORITY PROPORTION: match Nib v03 exactly in head-to-body ratio. On a 1536x1536 transparent canvas the entire character is about 1100 pixels tall (roughly y=220 through 1330). The actual round skull including its short hair, measured crown to anatomical chin EXCLUDING the hanging beard, is about 500 pixels tall: 45-47% of total height. The skull itself must be huge, NOT a small face above a long beard. Treat the head as almost as tall as torso+boots combined. The beard cannot be counted as head height to satisfy this condition. Broad round cranium, extremely short round torso, very stubby legs with chunky boots immediately underneath the torso, no extended shins. Change racial build by WIDTH ONLY: this dwarf has the broadest low barrel torso. Head width equal to or greater than shoulder width excluding arms. About 2.2 heads tall, no adult/anatomical/heroic proportions.
Dwarf identity: warm peach skin, short simple full gray hair (no bald crown), thick gray eyebrows modeled as two simple solid shapes, two large plain dark round button eyes with NO white glints, small rounded nose, tiny mouth, gentle calm neutral expression, no wrinkles or detailed eyelids. Large gray beard formed as exactly TWO chunky simplified braided masses hanging only to chest, minimal rounded overlapping lobes and plain dark ties, no individual hair strands. Skull is large even before beard is added.
Clothing: plain gray wool tunic with sleeves, simple warm brown leather apron and brown belt with one modest plain buckle, thick brown boots. Gray, warm brown, peach and dark charcoal as large 3-5 dominant color groups. No fabric weave, weathering, stitching ornament, tools or jewelry. Smooth matte clay/vinyl toy, very broad rounded forms, subtle soft form shading, no ink outlines.
Pose/composition: one full-body standing upright relaxed A-pose. Front-left three-quarter view 30-45 degrees, body/face oriented slightly toward image left, camera height and framing same as Nib. Both hands EMPTY, blunt mitten-like hands. Arms angle downward and away from torso with real transparent gaps; both legs and boots visibly separated by a transparent gap. All body parts inside frame with generous margins. No equipment, weapon, shield, backpack, stand, pedestal or ground shadow.
World: medieval-based fantasy; preserve medieval everyday life and atmosphere while allowing fantasy adaptation. No modern items.
Output: exactly 1536x1536 PNG with genuine transparent alpha background outside the character, NOT an opaque checkerboard, black background or white backdrop. No text, borders, labels, other characters or props. Only one dwarf.
```

## 비율 기준과 측정 방법

- 전체 높이: PNG 알파가 0보다 큰 픽셀의 경계 상자 높이. 좌표는 0부터 시작하며 아래 끝은 포함한다.
- 머리 높이: 귀·수염을 제외한 정수리(짧은 머리 포함)에서 해부학적 턱까지의 세로 투영 높이. 머리/턱 경계는 육안 판독이므로 근삿값이다.
- 니브 v03: 1536×1536, 알파 경계 x=326..1268 / y=217..1330, 전체 높이 **1114px**. 정수리 y≈218, 턱 y≈735 → 머리 **약 517px**, 전체의 **약 46.4%**. 턱 판독 오차 약 ±10px.
- 드워프: 전체 높이 1114px, 두상+머리 약 504px, 약 45.2%. 상세 측정과 수염 가림에 따른 오차는 아래에 기록한다.

## 실제 수정 프롬프트 전문 — 2차

입력 순서는 1차 드워프 원본, 니브 v03, 보조 토이 레퍼런스다. 새 입력인 1차 드워프 원본도 실제 이미지로 열어 확인했다.

```text
Use case: stylized-concept, precise proportional correction of image 1 (the dwarf first attempt).
Input 1 is the EDIT TARGET: keep its generic dwarf identity, gray short full hair, gray two-part braided beard, plain gray sleeved tunic, brown leather apron/belt, thick brown boots, calm button eyes without highlights, empty mitten hands and simple smooth matte toy style. Input 2 is Nib v03: PRIMARY head:body and on-canvas scale reference. Input 3 is the secondary toy style reference.
Correct ONLY the dwarf's excessive body length / small anatomical skull and framing. Make the actual round SKULL INCLUDING HAIR (NOT the hanging beard) 15% larger relative to its body, and vertically compress its torso + legs so the anatomical skull from top hair to chin is 46% of the full character height. The chin may be behind the beard but the huge round cheek/jaw volume must still be evident. Do not just enlarge or lengthen the beard. Make the two beard braids shorter, ending on upper chest rather than belt.
Reference Nib has total height 1114px, top hair y=217, chin y≈735, boots end y=1330 on a 1536 square. Match those landmarks: dwarf hair top at y≈220, anatomical chin y≈725, chunky boots bottom y≈1330. Torso must be extremely short and wide, boots immediately under the apron with almost no trouser length, no extended shins, large head at least as wide as shoulders excluding arms. The dwarf should read as a wide squat ~2.2-head toy.
Keep front-left 3/4 standing A-pose, head and body turned toward image left 30-45 degrees, Nib camera height, both hands empty and away from torso with transparent negative space, both legs/boots separated, one centered whole character.
Keep thick eyebrows simple solid shapes, two black round button eyes with no glints, small nose and tiny gentle mouth, no wrinkles, no individual hair strands or fabric weave, no jewelry, no weapons, no backpack, no props, no ground shadow.
Medieval-based fantasy; preserve medieval everyday life and atmosphere while allowing fantasy adaptation.
Deliver EXACTLY 1536x1536 pixels, RGBA PNG with a genuinely transparent alpha background. Please do not make a tighter cropped or lower resolution image. Hair top around 220 and boots end around1330 leave ample transparent margin, matching Nib reference's scale in the canvas. No text, no grid, no background, no frame.
```

## 실제 수정 프롬프트 전문 — 3차 (최종 선택)

입력 순서는 1차 드워프 원본, 니브 v03, 보조 토이 레퍼런스다. 2차는 같은 전신 높이 비교에서 두상이 다소 과장되어 채택하지 않았다.

```text
Use case: stylized-concept / precise-object-edit.
Image 1 is the dwarf EDIT TARGET (first attempt). Image 2 is Nib v03, strict priority reference for actual cranium:body proportions and matte toy finish. Image 3 is secondary simplified toy style.
Make one SMALL targeted proportion correction to image 1: enlarge ONLY its round anatomical skull/face and short full gray hair by approximately EIGHT PERCENT (8%) relative to the untouched body. Scale the head around the chin/neck junction so its crown rises slightly. Head means cranium+hair, NOT the hanging beard. Preserve the torso, arms, hands, apron, belt and boots at their current size and shape. Keep overall squattiness. Do not enlarge head by more than 8 percent and do not shorten the torso further. The intent is a moderate in-between correction: the first dwarf skull is about43% of its total height, and after this slight enlargement it should be approximately45-46%, matching Nib's 46.4%. A 50%-of-height skull would be too big.
Keep the beard as TWO clearly simplified chunky gray braids, shorten their tips a little so they end at chest above belt. Two solid simple thick gray eyebrows, two dark button eyes without any white highlights, small round nose and tiny calm mouth. Full short gray hair, no bald crown. Ordinary reusable dwarf race common guest, no individual named-character details.
Retain all existing colors and clothes: plain gray sleeved wool tunic, warm brown leather apron, simple belt/buckle, very thick brown boots. Smooth matte clay/vinyl toy with broad color masses, no outlines or realistic details, no wrinkles or texture weave.
Retain front-left three-quarter 30-45deg angle and standing A-pose, two empty blunt hands clearly outside torso silhouette, separately readable legs and boots with transparent gap, no props, equipment, backpack or shadow.
Medieval-based fantasy; preserve medieval everyday life and atmosphere while allowing fantasy adaptation.
One whole character fully inside the frame on genuine transparent alpha. Final requested square canvas1536x1536 with character about1100px high, matching Nib's canvas footprint. No text, border, labels or background.
```

## 최종 파일·알파·해시·시각 검수

## 최종 선택 및 납품용 정리

- **최종 선택: 3차**, `raw/dwarf-common-3q-v02-attempt-03.png`.
- 생성 원본 3개는 모두 1254×1254 RGBA이며 도구의 원본 파일을 그대로 복사해 보존했다. 도구가 프롬프트의 1536×1536 출력 크기를 그대로 반환하지 않아 납품 파일만 규격에 맞게 정리했다.
- 원본에 남아 있던 알파 1..16의 극미세 잔여 픽셀 16,623개를 투명하게 정리했다. 알파 17..255의 생성 색·알파는 유지했다.
- 정리 후 원본 캐릭터 경계 x=167..1112 / y=72..1216, 높이 1145px를 기준으로 **가로·세로 동일 배율 1114/1145 = 0.9729257642**를 적용했다.
- .NET System.Drawing으로 1536×1536 투명 캔버스에 고품질 bicubic 리샘플링했다. 배치 사각형 x=307.8061, y=218, 너비=920.3878, 높이=1114. 머리와 몸을 따로 늘리거나 줄이지 않았다.
- 결과: `dwarf-common-3q-v02.png`, 1536×1536, 32bit RGBA PNG, **1,293,173 bytes**.
- 캐릭터 생성·비율 수정은 모두 내장 image_gen으로 수행했다. 로컬 처리는 납품 크기·투명 캔버스·낮은 알파 잔여 정리와 검수 비교판 제작에 한정했다.

## 니브 v03과의 최종 비율 비교

`raw/qa-nib-v03-comparison.png`를 실제로 열어 나란히 비교했다. 양쪽 모두 원본 1536 캔버스를 같은 50% 배율로 표시했으며, 개별 머리·몸 변형은 하지 않았다.

| 항목 | 니브 v03 | 드워프 최종 |
| --- | --- | --- |
| 캔버스 | 1536×1536 | 1536×1536 |
| 알파 > 0 전신 경계 | x=326..1268, y=217..1330 | x=308..1227, y=218..1331 |
| 전체 높이 | 1114px | 1114px |
| 머리 정수리(머리 포함) | y≈218 | y≈218 |
| 해부학적 턱 위치 | y≈735 | y≈722 (수염 아래 추정) |
| 두상+머리 높이, 귀·늘어진 수염 제외 | 약 517px | **약 504px** |
| 머리 / 전신 | 약 46.4% | **약 45.2%** |

- 드워프 턱은 수염에 가려져 있으므로 약 ±25px, 비율 약 ±2.2%p의 판독 오차를 둔다. 수염 끝을 턱으로 사용하지 않았다. 측정값은 3D 해부학 검증값이 아닌 2D 투영 이미지의 육안 추정이다.
- 같은 1114px 높이로 비교했을 때 두상이 몸통+장화에 가까운 크기로 읽히고, 다리는 짧으며 장화가 튜닉 바로 아래에 있다.
- 귀를 제외한 머리 너비는 약 620px, 소매를 제외한 어깨는 약 510~540px로 머리가 더 넓다. 어깨 경계는 앞치마 끈·머리카락 일부 가림 때문에 대략값이다.
- 니브와 체격 차이는 낮고 넓은 몸통과 굵은 장화로 주었고 키는 늘리지 않았다.

## 알파 검수

최종 파일을 다시 열어 픽셀을 검사했다.

- 해상도 1536×1536, 알파 채널이 있는 32bit RGBA PNG.
- 알파 0: **1,742,727 pixels**. 이미지 네 가장자리에서 알파가 0보다 큰 픽셀 **0개**.
- 알파 255: 2,134 pixels. 알파 250..255: 605,070 pixels.
- 알파 1..254: 614,435 pixels. 생성 원본의 내부도 주로 알파 250~254인 약한 반투명도를 가지고 있으며, 이를 강제로 불투명화하지 않았다.
- 흰색·어두운색·회색 배경의 파생 검수판 `raw/qa-alpha-backgrounds.png`를 실제로 열어 외곽과 실루엣을 확인했다. 배경 사각형·체커보드가 최종 PNG에 들어 있지 않다.
- 두 손은 비어 있고, 손/옆구리 사이와 장화 사이에 투명 여백이 확인된다. 주변에 눈에 띄는 흰 테두리·검은 배경·바닥 그림자는 없다.
- 검수판의 배경과 문구는 확인용 이미지에만 있으며 최종 납품 PNG에는 없다.

## 시각 검수 및 한계

- 단일 드워프 종족 공용 여행자, 앞-왼쪽 3/4 전신 A자 자세. 무기·방패·등짐·개인 장신구 없음.
- 짧게 덮인 회색 머리, 단순한 굵은 눈썹, 하이라이트 없는 큰 단추 눈, 작은 코와 작은 입, 순한 표정.
- 큰 회색 수염이 두 갈래의 땋은 덩어리로 읽힌다. 수염 끝은 짧은 몸통의 가슴에서 벨트 위까지 내려오며 해부학적 턱을 가린다.
- 회색 모직 튜닉, 갈색 가죽 앞치마·벨트, 굵은 장화. 중세 기반 판타지의 의복·재료에 어울린다.
- 무광 점토·비닐 장난감의 둥근 덩어리와 큰 색면을 확인했다. 잔주름·낱머리카락·외곽선·세밀한 무늬는 없다. 모직/가죽에는 약한 표면 질감이 남아 있다.
- 이 파일은 3D 모델링 입력 원화다. 3D 메시·리깅·후면 구조 또는 게임 내 적용은 수행하지 않았다. 수염 아래 턱의 정확한 입체 경계는 모델링 시 비교판과 위 비율을 함께 참고해야 한다.
- 1차·2차는 과정 원본으로 보존하며 최종 납품물은 지정된 루트 PNG 하나다.

## 입력 SHA256

| 입력 | SHA256 |
| --- | --- |
| nib-3q-v03.png | `D33657A5A0B50B9B8BDD4F6384A3014B49AA0610111DFE8015480D038FF71F1B` |
| stylized-toy-chibi-ref-01.png | `C26F3E21A10E119047DF10986BF4D27720C2E6B7A266ACA142BA2FCF78BF8687` |
| harald-3q-b-v01.png | `0B6930C0E61482358479092A2BFB3265719E220E4A84334E51629A061C8F017A` |

## 납품/과정 PNG SHA256

| 파일 | SHA256 |
| --- | --- |
| dwarf-common-3q-v02.png | `65D39D96A290A494691C38974631A3B6A7BBCB9E00947272DFB2C0B641C4BBCF` |
| raw/dwarf-common-3q-v02-attempt-01.png | `B207AC2605969DA0E56168E72419995A6F74BDF608D4287EE7E5D0EC2C2A63E2` |
| raw/dwarf-common-3q-v02-attempt-02.png | `B1531D79E53D61CF43EF6B2598B0261C500367DFC5B409DD7E7BDC80E5389898` |
| raw/dwarf-common-3q-v02-attempt-03.png | `45FDD86B5E8874C49783ABD06A18A53897CAAD13AF6E81C511FAA03E1D9A9F7E` |
| raw/qa-attempts-comparison.png | `30EDC036495A44DB6CD28BEAC98CBB3142B66DAB62BE155B25A0B8686D15BB97` |
| raw/qa-nib-v03-comparison.png | `7E008A8F0ACAF7B310B291C458A460CD562F68D1B6A13E935BF667E42DDBB46E` |
| raw/qa-alpha-backgrounds.png | `C99BE35879FB6EB5AF9BC08FB92EDE13802B2D128A125804ACD0D1EC897EA732` |

프로젝트 내 이 출력 폴더 밖 파일은 수정하지 않았으며 커밋하지 않았다.


