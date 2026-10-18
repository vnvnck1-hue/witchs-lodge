# 감시탑 모델링용 투명 원화

제작일: 2026-10-18 (Asia/Seoul)
사용 도구: 내장 image_gen, transparent_background=true.
결과: [watchtower-levels-1-2-transparent.png](watchtower-levels-1-2-transparent.png).
입력·수정 대상: [실제 게임 산장 텍스처에 맞춘 v04](../watchtower-upgrade-v04/watchtower-levels-1-2-v04.png).

요청: 모델링에 사용할 수 있도록 단계 텍스트와 배경을 깨끗하게 제거.
검수: RGBA PNG의 실제 알파 0 배경을 확인했다. 흰색 배경에 합성한 검수용 이미지로 글자·바닥 그림자 제거와 사다리·가새·망루 창 사이의 투명 공간, 얇은 종·초승달 실루엣을 확인했다. 검수용 합성은 output/watchtower-cutout-qa/white-composite.png이며 최종 PNG의 알파를 변경하지 않았다. 생성 편집이므로 원본 픽셀과 동일한 색·배치를 보장하는 결정적 마스크 작업은 아니다.

## 최종 생성 프롬프트

```text
Background removal edit of the attached image ONLY. Use the existing pixels as closely as possible. Remove the light gray backdrop, all floor shadows, and the two text labels under the watchtowers. Output actual transparent PNG. Remove the backdrop through every visible gap between ladder rungs, timber legs, crossed braces, and lookout roof supports. Preserve the two buildings exactly as supplied: same scale, same positions, same camera, same red-brown subdued dark wood colors, same muted stone colors, same shapes and geometry, same soft painted lighting and material finish. Do not recolor the wood orange, brighten highlights, enlarge buildings, change framing or redraw decoration. Keep ONLY both original towers isolated on genuine transparent alpha with clean anti-aliased silhouettes. No text, no floor shadow, no glow beyond the lamps, no new background. Preserve the original empty margins around and between towers.
```

