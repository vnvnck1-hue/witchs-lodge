# 쇠붙이 이름 변경 카드 v01 · 실제 생성 프롬프트

2026-10-19 · imagegen 스킬의 내장 `image_gen` 사용. 두 호출 모두 `transparent_background=true`, `referenced_image_paths`로 아래 5개 PNG를 실제 입력했다. 카드마다 1회 생성했고 두 결과를 채택했다. 추가 이미지 재생성은 없었다.

## 실제 참고 입력과 보존

1. `art/concepts/cards/roles-individual-v02/03-resource-timber.png` — 승인 자원 포맷
2. `godot/assets/cards/scrap.png` — 교체 전 scrap / 주된 화풍·프레임 기준
3. `godot/assets/cards/junk_sack.png` — 교체 전 junk_sack / 문구 수정 대상
4. `godot/assets/cards/timber.png` — 같은 역할의 게임 화풍
5. `godot/assets/cards/rabbit_pelt.png` — 같은 역할의 게임 화풍

두 교체 대상의 **입력 당시 원본**은 `output/scrap-rename-v01/before/scrap.png`, `output/scrap-rename-v01/before/junk_sack.png`에 보존했다. 위 게임 경로는 납품 이후 새 카드로 바뀌므로 재현 시 이 사본을 사용한다. 기존 `art/cards/goblin-v01/`는 수정하지 않았다.

## scrap · 채택 01

이유: 표시 이름을 **쇠붙이**로 바꾸고, 쓸 만한 제작 재료인 쇠 조각·경첩·리벳을 중심으로 원화를 새로 만들었다. 원화 하단 자원 표식도 쇠 조각으로 단순화했다. 겨울 산장·숲, 승인 자원 프레임과 기존 고블린 카드 색조를 유지했다.

가공 전 생성본: `art/cards/scrap-rename-v01/drafts/scrap-generated-01.png`  
납품 원본: `art/cards/scrap-rename-v01/scrap.png`

```text
Use case: precise-object-edit. Deliver a single finished upright 1024x1536, true 2:3, Korean illustrated resource card for Witch's Lodge. Image 1 is the APPROVED resource layout reference; image 2 is the SCRAP EDIT TARGET and main style/geometry reference; image 3 is the same-set junk sack companion; images 4 and 5 are current resource style references. Match image 2's exact purple card stock, rounded outer silhouette, variable-width black ink wave frame, cream title and continuous cream description panel, typeface and printed painterly texture. Set the artwork in a medieval-based fantasy world, allowing familiar fantasy adaptations while keeping medieval daily life and atmosphere. Keep winter blue fir forest, snow and the small amber-windowed timber lodge behind the objects. Change the main art to a modest useful pile of salvageable iron crafting materials, roughly sorted flat iron offcuts stacked loosely on a wooden workbench with a small leather cloth, a dented spoon, one usable hinge and a few rivets. Silver iron glints show between patches of coppery rust, with restrained moss green accents. Large readable silhouettes and thick ink contours consistent with all references. No large broken pot, no bucket, no broken can or garbage heap. Replace the small resource emblem at the illustration/description transition with just two or three flat iron offcuts, NOT a spoon and hinge emblem. Keep the simple rectangular resource art window and single continuous rules panel. Preserve title field x110..914 y72..236 with room for two lines; classification around y267..307; reserve clean four-line rules field x110..914 y1185..1445. No ornament, icon, divider or frame point inside text fields. Exact centered black Korean brush lettering, same family as image 2. Title: "쇠붙이". Classification: "고블린 · 판매용". Description line 1: "산장에 놓으면 팝니다." Description line 2: "1개 4G." Render ONLY these strings; preserve spaces and punctuation and centered middle dot. No old title 고물 anywhere, no placeholder, no added letters, no numbers inside the illustration. Genuine alpha transparency only outside softly rounded card corners; solid opaque artwork and paper inside. Keep full card edges uncropped.
```

## junk_sack · 채택 01

이유: 설명 둘째 줄을 **가끔 쇠붙이도 섞입니다.** 로 교체한다. 생성본 전체를 교체하지 않고 요청서가 권장한 설명 패널 재합성을 적용했다. 그림·제목·분류·첫 줄과 프레임은 기존 픽셀을 그대로 보존했다.

가공 전 생성본: `art/cards/scrap-rename-v01/drafts/junk_sack-generated-01.png`  
납품 원본: `art/cards/scrap-rename-v01/junk_sack.png`

```text
Use case: text-localization. Image 3 is the EDIT TARGET, the current Witch's Lodge "잡동사니 자루" card. Image 1 is the approved RESOURCE layout reference; image 2 is the companion scrap card; images 4 and 5 are current resource style references. Output one 1024x1536 upright 2:3 card matching image 3 pixel-for-pixel wherever possible. Make ONE localized change only: replace its SECOND description line "가끔 쓸모없는 고물도 섞입니다." with EXACTLY "가끔 쇠붙이도 섞입니다." Keep the first line "낮에 열면 자원이 나옵니다." completely unchanged. New second line must match the FIRST line's exact Korean brush typeface, font size, weight, black ink color, centered horizontal alignment and existing line spacing. Its baseline must be the old second-line baseline, around y1350. Cleanly repaint just the old second line on matching naturally textured cream paper, with absolutely no old-letter ghosts, smudges, seams, halo, or old word 고물 left. Title "잡동사니 자루", classification "고블린 · 자원 꾸러미", sack illustration, all sack contents, lantern, winter forest and lodge, resource emblem, purple stock, black wave frame, cream panels, entire geometry and all other pixels remain invariant. Do NOT add any iron object to the sack. Maintain the medieval-based fantasy daily-life atmosphere and painterly printed ink style. Title two-line space and description four-line space remain available, no ornaments inside safe text regions. No other text, numbers, or placeholder. Genuine alpha outside the four softly rounded outer corners only; card interior opaque.
```

## 납품 후처리와 시각 검수

- `scrap`: 생성본의 RGB·원화·인쇄 글자를 유지하고, 기존 카드의 알파를 복사해 동일한 라운드 외곽과 불투명 카드지를 적용했다.
- `junk_sack`: 기존 카드 위에 생성본의 둘째 줄 패널 사각형 `[180,1306,845,1385)`만 합성했다. 경계 8px에 smoothstep 혼합을 적용해 종이 질감 경계를 정리했다. 이 사각형 밖 변경 픽셀은 **0**이다. 실제 변경 경계는 `x182..842, y1307..1382`이고 첫 줄은 `y1250..1300`에 있어 전혀 바뀌지 않았다. 새 글자와 옛 글자의 경계를 원본 크기로 확인해 잔상·얼룩 없음으로 검수했다.
- 완성 원본과 게임용은 동일한 PNG다. 손패는 같은 그림을 HighQualityBicubic / TileFlipXY로 가로·세로 각각 정확히 1/4 축소했다. 글자를 코드로 새로 그리지 않았다.
- 새 카드 두 장의 제목·분류·설명·띄어쓰기·가운뎃점·마침표를 원본 크기 크롭에서 대조했다. 옛 이름과 임시 문구가 없고, 원화에는 임의 수치가 없다. `scrap`의 승인된 인쇄 문구 `1개 4G.`는 유지했다.
- 새 2장·이전 2장·승인 자원 PNG를 모두 같은 256×384 비율로 배치한 [미리보기 시트](../../../godot/screenshots/scrap-rename/sheet.png)로 프레임·화풍·쇠 조각 실루엣을 확인했다. 시트의 이전 비교 카드는 요청대로 옛 문구를 유지한다.
- 검수 이미지는 `output/scrap-rename-v01/review-scrap.png`, `review-junk_sack.png`. 문구 시각 검수 기록은 `visual-review.json`, 픽셀 보존 검증은 `junk-sack-pixel-diff.json`.

## import와 검증

요청된 게임 프로젝트에서 `.tools/Godot-4.7.2.exe --headless --path godot --import`를 실행했고 종료 코드 0이었다. 게임용·손패용 4개 텍스처의 실제 로드·크기·알파가 4/4 통과했다. 각각의 `.import`가 가리키는 캐시의 source MD5와 현재 PNG의 MD5도 일치한다.

[검증 JSON](../../../output/scrap-rename-v01/verification.json)에 6개 PNG의 치수·RGBA 채널·PNG 색상 유형·모서리 알파·SHA-256, 원본/게임 동일성, 손패 축소 일치, 캐시 일치와 시각 검수 결과를 기록했다. 재현 스크립트는 `output/scrap-rename-v01/package.ps1`, `run-import.ps1`, `verify.ps1`이다.

Godot 로그의 `Failed to read the root certificate store` 오류는 남아 있다. 로컬 이미지 import와 텍스처 검증은 정상 종료했다. 한국어 인쇄 PNG 납품이며 다국어 동적 텍스트 구현을 의미하지 않는다. 코드·카탈로그·다른 카드·기존 고블린 원본·실행파일을 수정하거나 커밋하지 않았다.

