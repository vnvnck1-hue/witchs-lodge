# 니벨라 포효 — 눈보라 효과 합성 v01

- 제작일: 2026-10-22
- 도구: 내장 image_gen, 불투명 배경.
- 결과: [포효 효과 합성](nivella-roar-blizzard-v01.png)
- 입력: 사용자 첨부 실제 게임 화면 codex-clipboard-074e8335-3df9-4179-aedb-940fc18e8ccf.png.
- 용도: 포효가 최고조에 달한 순간의 연출 콘셉트. 런타임 효과를 구현한 것은 아님.
- 표현: 보스의 입과 발밑을 기점으로 여러 겹의 눈보라 충격파가 바깥으로 퍼지며, 방사형 눈가루 궤적과 휘말리는 눈 덩어리로 속도를 강조.
- 검수: 기존 카메라 구도와 보스·플레이어·유적 배치가 식별되며, HUD 대부분이 보임. 얼굴·배 실루엣을 유지하고 바닥 일부를 남겨 폭발의 중심과 공간감을 읽을 수 있음.
- 한계: 생성형 합성이므로 원본 UI 글자와 세부 픽셀이 일부 달라질 수 있음. 정지 시안은 연속 펄스의 순간을 중첩해 표현한 것으로 실제 애니메이션 타이밍은 미확정.

## 실제 생성 프롬프트

```text
Use case: compositing.
Asset type: in-game boss ROAR VFX paint-over concept, single finished 16:9 gameplay screenshot.
Input image 1: EDIT TARGET, the user's actual Witch's Lodge game screenshot. Preserve the exact screenshot camera, composition, giant spider model, character positions, arena geometry, existing web meshes, pillars, rubble, icy floor, and all UI panels/icons/text at the same locations. Keep the original indigo-blue stylized low-poly game art. This is medieval fantasy magic. Add only an explosive SNOW-BLIZZARD ROAR visual effect centered on the giant spider, around image position x=800 y=405 in the 1600x900 source. Do not replace the boss with a different design or use an earlier concept.
Core effect: a very forceful roar makes ground snow erupt and BLAST RAPIDLY OUTWARD in all directions. Freeze the strongest instantaneous pulse in a spectacular but gameplay-readable keyframe. Visually convey several rapid successive WHUMP-WHUMP pulses using TWO or THREE expanding broken elliptical blizzard shock fronts at different distances from the spider, conforming to the arena ground perspective. The inner ring under the legs is a dense sharp flash of white-blue powder; a stronger middle wave is a low rolling turbulent crest of snow sweeping outward; the outer broad wave has already reached the arena's left/right edges and toward the lower foreground, fragmented into wind-swept snow spray and sharp streaks. These are physical wind/snow shock waves, NOT neon outlined magic circles. No runic rings or spell glyphs.
Hundreds of snow particles of varied scale blast away from boss, with short and long tapered white/cyan motion streaks radially pointing OUT from the spider. Several large nearby soft snow clumps travel toward foreground, smaller sharp icy grains behind; keep them visually hand-painted and stylized. Give snow plumes broad energetic curved shapes and stretched directional wisps, minimal small noise, a strong visible center-to-outside velocity. Some low snow vortices lift at the wave's leading edge. Sparse sparkling ice flecks, no huge ice spikes. A compact roaring burst of pale icy breath at the mouth spreads into the expanding front wave; preserve face and glowing eyes clearly, do not obscure the giant round abdomen. Light cyan rim-light briefly catches the existing legs and nearby stone edges. Inner wave shines most strongly near the creature but no giant opaque white explosion ball.
Composition and readability: giant spider remains clearly identifiable as the source of the roar. Keep its face, eyes, fangs, legs, and abdomen visible. Layer portions of snow behind the spider and in front of its feet for depth. Strong foreground snow streaks may cross floor but preserve portions of the blue stone pattern and small player silhouette at lower center. Effect occupies the playable arena, especially below/around boss, and does NOT cover or redesign the HUD at top, task panel on left or bottom controls. Preserve UI lettering exactly, do not add captions, labels, diagrams or new health bars. Preserve screenshot edges and original 16:9 crop. Avoid regular concentric thin laser rings, a stationary circular fog cloud, gentle falling snow, generic rain, fire, lightning, yellow light, photorealistic smoke, overwhelming full-screen whiteout or cinematic camera changes. The main read is an aggressive frosty ROAR kicking a fast expanding ground-level blizzard shockwave across the entire room. Single image, not a storyboard.
```

