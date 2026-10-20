# 모미 포트레이트 v02 · 기본 및 수줍은 포즈

2026-10-21. 최초 API 요청 후 사용자가 “그냥 일반적으로 작업해줘 api 말고”로 변경하여 내장 image_gen 편집을 사용한다. API 호출은 하지 않았다.

기본 참고 입력: 기존 모미 포트레이트, 최신 모미 카드, 승인 브람 포트레이트. 추가 포즈는 갱신된 기본 포트레이트를 직접 편집해 동일 인물·체형·의상·화풍을 유지한다.

수줍은 포즈의 실제 입력과 프롬프트는 [별도 기록](momi-portrait-shy-v02.md)에 보존했다.

## 기본 포트레이트 실제 프롬프트

```text
Use case: precise-object-edit / identity-preserve.
Asset: ONE production half-body portrait for the medieval fantasy game Witch's Lodge, isolated with genuine transparent alpha. Upright 4:5, ideally 1122x1402.
Input 1 is the existing Momi PORTRAIT EDIT TARGET. Input 2 is Momi's latest approved curvy CARD ART: authoritative identity, body silhouette and outfit reference. Input 3 is the approved Bram portrait: illustration style and half-body finish reference ONLY.
Update Momi's old portrait to match her adult female figure in image 2: noticeably full bust under a fully covering cream blouse, softly defined waist and fuller hips, naturally balanced mature proportions. Keep her recognizable gray-brown anthropomorphic rabbit head, rabbit muzzle and nose, amber anxious eyes, one long ear folded down and the other upright. Keep her cautious side glance, ochre scarf, patched moss-green traveling cloak, cream blouse, leather gloves and harness, rolled bedroll/backpack, small digging trowel and herb-filled wicker basket. This is a rabbit beastfolk woman with an animal head and fur, not a human with bunny ears.
BASE POSE: relaxed shy gatherer posture matching the card. Hold the herb basket low at the waist with both gloved hands naturally supporting it; arrange arms and basket low enough that the blouse and fuller clothed upper torso are clearly visible. Keep shoulders gently hunched and her timid personality.
Match thick tapered black ink contours, large painted color planes, decisive two/three-value shadows, restrained drybrush/gouache print texture. Medieval-based fantasy daily-life materials and atmosphere, familiar fantasy adaptations allowed. Same illustrator as supplied card and portraits.
CRITICAL composition: entire head, both ears, shoulders, BOTH elbows/forearms/hands, cloak and all props fit inside the canvas, with at least 6 percent transparent breathing room on ALL FOUR sides. Head-to-waist HALF-BODY only. Lower torso/cloak ends in a deliberate gently irregular curved hand-painted vignette, fully surrounded by transparent margin. No straight cropped edge, severed limbs, full body or legs. Face remains prominent.
Genuine transparent alpha everywhere outside the figure and props; clean antialiased silhouette. No snowy scenery, lodge, ground, colored fog, halo, background, cast shadow, frame, badge, UI or text. Do not copy the card panels or border from image 2. Preserve outfit coverage and everyday adventurer mood.
```
