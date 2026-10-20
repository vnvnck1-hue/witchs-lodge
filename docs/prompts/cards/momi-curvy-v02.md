# 모미 채집가 카드 체형 수정 v02

2026-10-20 · 사용자 요청: 토끼 수인 채집가의 몸매를 더 글래머러스하게 수정.

내장 image_gen 편집 사용. 최신 게임용 무문자 카드와 승인 인물 역할 카드를 실제 참고 입력으로 전달했다. 성인 여성 토끼 수인의 풍만한 체형을 의복 위 실루엣으로 표현하고 기존 얼굴·귀·채집 도구·중세 판타지 분위기와 빈 글 패널을 유지한다.

참고 입력:
- `godot/assets/cards/races/beastfolk/gatherer.png` — 수정 대상
- `art/concepts/cards/roles-individual-v02/01-character-nib.png` — 승인 인물 역할 프레임·화풍

실제 프롬프트:

```text
Use case: precise-object-edit.
Asset: existing rabbit beastfolk gatherer Momi fantasy game card, 1024x1536 upright true 2:3.
Image 1 is the EDIT TARGET, current Momi card. Image 2 is the APPROVED character-role frame/style reference only. Edit image 1.
Primary request: make this clearly ADULT female anthropomorphic rabbit gatherer noticeably more voluptuous, with a fuller bust, a gently defined waist and fuller hips. Natural balanced mature adult proportions. Adapt her existing fully covering cream medieval blouse and green patched travel cloak to fit the fuller figure; show the curvy clothed torso silhouette clearly, slightly repositioning the herb basket lower if necessary. Keep the same cautious shy face, gray-brown rabbit fur, rabbit muzzle, amber eyes, asymmetric long rabbit ears (one folded), ochre scarf, leather straps, traveling pack, trowel, wicker herb basket and mushrooms. She remains an anthropomorphic rabbit woman, not a human with rabbit ears. Keep the same quiet gathering pose and framing as closely as possible.
World: medieval-based fantasy, familiar fantasy adaptations allowed while preserving medieval daily-life atmosphere. Preserve snowy forest, amber-lit lodge and lantern, purple/indigo snow shadows, bold tapered black ink outlines and rich painterly print texture.
STRICT invariants: preserve image 1's purple rectangular rounded card border, black flowing character-role art-window frame, completely BLANK cream top title/category panel and completely BLANK continuous cream bottom rules panel, compact amber paw badge and its BLANK cream name plaque. DO NOT copy goblin or lettering from image 2. No text anywhere. Preserve title two-line and rules four-line safe areas; all artwork and ornaments stay outside these blank text zones. No new UI, stats or symbols. Keep badge and frame geometry as close to identical as possible. Genuine transparent alpha only OUTSIDE the rounded card; entire interior opaque. Tasteful fully clothed adventurer character design, no nudity, no sexual activity, no pinup pose. The requested change is the clothed adult body silhouette.
```
