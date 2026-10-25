# 용비늘 카드 원화 v01 — 프롬프트·합성 기록

- 작업일: 2026-10-24 (Asia/Seoul)
- 도구: 내장 `image_gen` (imagegen 스킬), 투명 배경 요청. CLI/API 대체 사용 없음.
- 기준: `docs/handoff/codex-dragon-scale-card-v01.md`, `docs/card-design-guide.md`, `docs/card-text-runtime.md`, `docs/art-direction.md`, `docs/world-races-card-formats-v01.md`.
- 중세 기반 판타지. 글자는 런타임에서 렌더하므로 제목·분류·설명 미인쇄.

## 실제 이미지 입력

1. 편집 대상·빈 프레임: `godot/assets/cards/rowan_charm.png`.
2. 사용자 승인 장비·유물 포맷: `art/concepts/cards/roles-individual-v02/04-relic-moonlit-charm.png`. 모든 생성 호출에 실제 입력했고, 승인본의 인쇄 글자는 복제하지 않도록 지시했다.
3. 1차 화풍·겨울 색감 참고: `godot/assets/cards/frost_rune.png` (마름모 프레임은 사용하지 않음).
4. 2·3차에서는 직전 생성본을 편집 대상으로, 승인 유물 PNG와 rowan_charm PNG를 포맷 참고로 입력.

## 1차 생성 — 미채택

저장: `art/cards/dragon-scale-v01/drafts/01-leaf-like.png`.
재생성 이유: 위끝이 뾰족하고 가지처럼 갈라지는 홈 때문에 붉은 잎으로 읽힐 수 있었다.

```text
Use case: precise-object-edit.
Asset type: production medieval fantasy equipment/relic playing-card art for Witch's Lodge.
Inputs: Image 1 (rowan_charm.png) is the EDIT TARGET: keep its exact purple rectangular card stock, rounded corners with transparent outside, bold variable-width black ink waves, gold-edged tall SHIELD-SHAPED illustration window, large completely blank cream title/category plate at top, and one continuous completely blank cream rules panel at bottom. Image 2 is the user APPROVED relic role reference, for shield frame geometry and painted ink style only; DO NOT reproduce any of its lettering, moon pendant, chain, candles or architecture. Image 3 is supporting watercolor/ink/winter palette reference only, do not use its diamond-shaped frame or rune motifs.
Primary request: replace ONLY the illustration inside Image 1's shield-shaped art window (approximately y=320..1100), keeping every surrounding frame and blank plate in precisely the same position. Remove all rowan branches, berries, hanging rope, curtains, candle, interior room and window.
New subject: ONE SINGLE thick RED DRAGON SCALE, palm-sized but shown in close-up, standing upright centered in the shield window, broad rounded shoulders and a softly tapered rounded point at bottom, a convex organic teardrop / lotus-petal / shield silhouette. Make its width 50–65 percent of the illustration-window width (roughly x=290..735), height about y=460..960. ONE solid organic scale, not a cluster of scales, not a gemstone, not an egg, not a feather, not a pendant, no mounting or chain. Bold black ink outline, a few lengthwise natural ridges; broad readable crimson #B33026 and vermilion #ED572F planes, subtle warm gold-tinted edge; restrained orange and yellow ember light shining gently from inside the ridges, preserving a predominantly RED surface.
Backdrop: winter night, deep indigo-purple darkness above a small bed of lavender-blue snow. The scale rests in snow with a small melted depression around its bottom, a delicate curl of steam and a FEW tiny orange embers. Keep backdrop simple and darker to show the single scale silhouette clearly even at 256x384.
Style/medium: SAME hand-painted watercolor and tapering bold ink outline style as input cards; large clear color shapes, print texture, controlled bright/dark contrast. Medieval-based fantasy world; allow familiar fantasy adaptations while maintaining medieval atmosphere.
Canvas: one upright 1024x1536 card, true 2:3. Transparent ONLY outside rounded card corners, the card and paintings themselves opaque.
Invariants: preserve Image 1's entire frame silhouette and blank cream plates. All title/category/rules fields COMPLETELY EMPTY: no text, numbers, letters, symbols, runes, badges, marks, dividers or ornaments in these fields. Title safe rectangle x=110..914,y=72..236; rules safe rectangle x=110..914,y=1185..1445. Leave room for two title lines and four rules lines. No frame point may intrude on them. No full dragon, dragon head, person, hand, animal, building, modern object, watermark or logo. Output just the single finished card.
```

## 2차 수정 — 미채택

저장: `art/cards/dragon-scale-v01/drafts/02-rounded-volume.png`.
재생성 이유: 둥근 윗부분은 개선됐으나 볼륨과 방사형 홈이 강해 알·열매처럼 보일 여지가 있었다.

```text
Use case: precise-object-edit. Production medieval fantasy equipment/relic card, 1024x1536 RGBA.
Input 1 is the previous draft to correct; Input 2 is the user-approved equipment/relic role and frame reference (ignore all its lettering); Input 3 is the exact blank runtime relic frame reference.
Change ONLY the single red scale and simplify the background of Input 1. Keep the same 2:3 card layout, purple stock, tapering black ink waves, tall gold-edged shield art window, completely empty cream title/category plate, and completely empty continuous bottom cream panel. Preserve broad blank text safe rectangles x110..914,y72..236 and x110..914,y1185..1445.
The important correction: the subject must read as ONE solid thick organic DRAGON SCALE, NOT a leaf. Its TOP edge must be a BROAD SMOOTH ROUND DOME with rounded broad shoulders, like an upside-down teardrop / rounded heater-shield. NO POINT AT THE TOP. The widest part is in the UPPER THIRD. The sides taper down toward ONE softly rounded downward point. Slight convex 3D thickness and a dark beveled edge, no metallic mounting. Center it roughly x290..735,y450..975, occupying about 60% of window width. Show a few simple nearly parallel lengthwise grooves that follow the convex surface; NO branching leaf veins, no diagonal leaf veins, no concentric overlapping plates. A single contiguous solid crimson and vermilion scale, #B33026 through #ED572F. Mostly deep red with broad painterly planes and strong thick black contour. Subtle warm gold-tinted edge, restrained orange/yellow ember glow ONLY in a few grooves and lower rim; NOT a brightly flaming jewel or glowing leaf.
Winter-night backdrop: dark navy/purple darkness above simple lavender-blue snow, a shallow melted hollow underneath the one scale, a small curl of steam and only 3–5 tiny ember dots. Remove distracting detailed fir trees, simplify to dark night backdrop and broad snow forms. The scale is resting in snow, tilted slightly upright to display its face.
Match the supplied cards' medieval-based fantasy watercolor, bold tapering ink and painted print texture, large clear color shapes, readable at 256x384. Fantasy adaptation is allowed while keeping medieval atmosphere.
Absolutely no text, numbers, letters, runes, glyphs, badges, ornamental symbols, dragon face/body, persons, animals, hands, buildings, berries, branches, pendant chains, watermark or logo. No leaf, feather, egg, crystal or gem. Rounded card corners with transparent outside; all card interior opaque. Output only the single corrected card.
```

## 3차 수정 — 채택

생성 원본: `art/cards/dragon-scale-v01/dragon_scale-generated.png`.
넓은 윗부분·아래로 모이는 끝·납작한 판형과 세로 홈 3개로 정리했다.

```text
Use case: precise-object-edit. Edit Image 1, a 1024x1536 medieval fantasy relic card. Image 2 is user-approved relic role reference, Image 3 is exact runtime blank frame reference.
Make one targeted correction to the red object in the center: it must be a SINGLE BROAD FLATTENED ARMOR SCALE, shaped like one thick naturally shed red dragon scale, NOT a bulbous egg or pumpkin. Preserve the object position, overall size and warm red palette, snowy night and all card framing / blank cream fields.
Draw its face as one large flat-ish gently convex unbroken keratin plate with broad simple red painterly planes, a wide softly rounded top ridge and rounded upper shoulders, then straight-ish sides tapering toward ONE rounded downward point. Wider upper half, narrower lower half. The object is approximately 440px wide and 500px tall. Visible thin dark thickness only at one side edge, like a shed armor plate. A broad front face without deep round radial lobes. Only THREE sparse subtle nearly vertical incised grooves in the face, with a little low orange ember glow. NO longitudinal bulb ribs and no glowing strips subdividing the object. NO branching veins or leaf texture. NO small repeated scale pattern on its surface: ONE scale, broad planes. Deep crimson #B33026 and vermilion #ED572F, subtle golden top bevel, restrained orange-yellow inner heat in just a few small seams near its lower edge. Bold tapering black contour, same watercolor and printed ink style as references. Large clean readable silhouette at hand-card size.
It stands in a shallow patch of melted lavender-blue snow under a deep indigo-purple night, a small wisp of steam and a few embers. Keep background simple.
All surrounding frame / plates must stay the same: purple card stock, black flowing waves, tall gold-edged shield art window; complete blank cream title/category plate and one continuous blank rules plate. No text, numbers, runes, glyphs, symbols, badge or ornament in the cream plates. Safe rectangles x110..914,y72..236 and x110..914,y1185..1445 fully clear. Preserve 2:3 dimensions, rounded card corners and transparent outside corners, opaque interior.
Medieval-based fantasy with familiar fantasy adaptations and medieval atmosphere. No dragon head/body, person, hand, animal, building, modern object, pendant, chain, leaf, feather, egg, pumpkin, jewel, watermark or logo. Output just the single finished card.
```

## 최종 합성·규격화

- 최종 원화: `art/cards/dragon-scale-v01/dragon_scale.png`.
- 게임용: `godot/assets/cards/dragon_scale.png` (최종 원화와 동일 바이트).
- 손패용: `godot/assets/cards/hand/dragon_scale.png` (256×384).
- 원화 창 내부를 마스크로 제한하여 새 그림을 합성했다. rowan_charm의 바깥 보라·먹선·금빛 프레임과 빈 제목/분류/설명판, 원본 모서리 알파를 보존했다.
- 생성본 내부 알파가 약 249–252로 흔들리는 현상이 있어, 원본 카드 알파를 그대로 복사하여 카드 안을 불투명하게 유지했다. 생성 결과의 RGB 회화는 유지했다.
- System.Drawing으로 창 내부 합성 및 고품질 bicubic 균등 축소. 생성 모델로 새 프레임을 다시 그리지 않았다. 손패와 최종본 모두 RGBA PNG.
- 합성 재현 코드: `output/dragon-scale-v01/build-assets.ps1`. 그림 마스크: `output/dragon-scale-v01/art-mask.png`.
- 미리보기: `godot/screenshots/dragon-scale/card-sheet.png` (512×768 비교 및 실제 256×384 손패 비교). 시트 바깥 라벨만 글자이며 카드 PNG 자체에는 글자가 없다.
- 지정 안전 좌표의 기존 빈 판과 픽셀 일치, 원화 창 밖 프레임 불변, 모서리 투명, 크기·채널·해시를 `output/dragon-scale-v01/verification.json`에 기록한다. 안전 영역 검사에서는 승인된 기존 판 윤곽을 그대로 유지하며 새 그림·장식의 침범 여부를 검사한다.

## 범위·제약

게임 코드·카탈로그·프로파일·다른 카드 PNG·실행파일·Godot import 캐시는 수정하지 않았다. 커밋·stash·checkout·reset 및 Godot 내보내기를 실행하지 않았다. 요청서의 기획 링크 `docs/dragon-scale.md`는 작업 시 존재하지 않아, 상세 주제·문구·범위는 요청서 본문을 기준으로 삼았다. 실행파일 내보내기와 게임 안의 글자 배치 확인은 요청서상 Claude 담당이다.

