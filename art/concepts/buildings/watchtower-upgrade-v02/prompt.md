# 감시탑 1·2단계 비교 원화 v02

제작일: 2026-10-18 (Asia/Seoul)
방식: 내장 image_gen으로 v01 수정, 배경 포함 PNG.
결과: [watchtower-levels-1-2-v02.png](watchtower-levels-1-2-v02.png)
실제 이미지 입력·수정 대상: [v01 비교 원화](../watchtower-upgrade-v01/watchtower-levels-1-2-v01.png)
사용자 요청: 1단계 지붕 제거, 2단계 표현을 더 풍부하게.
검수: 1단계 지붕·상부 기둥 없는 개방형 망루, 2단계 보강 철물·굵은 처마와 받침·석재 장식·초승달 지붕 장식·보라색 천·경보 종을 확인했다. 두 건물의 전체 실루엣·같은 계열의 구조·앞쪽 사다리·단계 문구와 빈 배경을 확인했다. 사용자 검토용 시안이며 게임 치수·성능은 확정하지 않는다.
Tripo 개별 모델 제작 시 해당 탑 하나만 분리해 사용한다.

## 실제 생성 프롬프트

```text
Use case: precise-object-edit / stylized-concept.
Edit target: the supplied watchtower level comparison image. Produce an updated polished Tripo modeling concept sheet with exactly two complete isolated towers.
Requested changes: LEFT level 1 must have NO ROOF, an entirely open-air wooden lookout platform. RIGHT level 2 should look noticeably richer, more developed and lovingly designed than the source while staying a practical medieval woodland watchtower, not a castle.
World/style: Medieval-based fantasy, retain medieval everyday life and atmosphere while allowing fantasy adaptation. Preserve the source image's chunky proportions, warm wood, taupe gray stone, muted purple-indigo roof, painterly broad planes, strong readable toon shading, soft neutral light and clean pale warm gray background. Keep sparse large textures, avoid dense scratches and small repetitive grain.
LEFT 1단계: Remove the entire pyramid roof and all tall roof-support columns above parapet height. No roof, awning, canopy, roof frame, pergola, floating roof fragments or tall empty posts. Finish the four posts as short sturdy capped corner posts just above waist-high parapet rail, leaving the full square wooden lookout floor open to sky, visibly readable from the same slightly elevated three-quarter angle. Retain the current lower tower timber legs, crossed braces, stone footings, front access ladder, parapet and entry opening. Keep it a complete serviceable modest lookout tower, not unfinished construction. Relocate its single amber lantern onto a short bracket mounted to a parapet corner. The top ends cleanly at the parapet caps.
RIGHT 2단계: Preserve the same overall family and square single-platform layout, pyramidal purple shingle roof, front ladder and gate opening, timber crossed supports and short stone base, and current approximate total height. Enrich its silhouette and craftsmanship with visibly heavier shaped timber corbels supporting a slightly broader balcony, chamfered corner beams with a few broad carved notches, layered substantial eave beams with subtly upturned tips, elegant iron corner straps and large restrained rivets, thicker upper corner stone courses at the plinth and carved stone caps. Refine the shingle roof with a double stepped eave border and sparse aged bronze corner ridge caps, a small restrained wrought-iron crescent finial attached at the roof apex. Add one short muted deep violet hanging cloth panel on the right-facing balcony parapet with a simple small pale crescent emblem, and a small bronze alarm bell firmly suspended beneath the outer eave on the other visible side. Keep the existing warm lantern. Decorative features must be few, bold, attached and large enough for 3D modeling, not a forest of tiny ornaments. The tower should read as an upgraded lovingly crafted watch post belonging to a witch's lodge. It is still made of honest timber, forged iron and stone. No new secondary tower, observation story, weapons, guards, clutter, detached props or fantasy crystal engines.
Scale/composition invariants: Keep the two towers side by side, initial on LEFT and upgrade on RIGHT. Same world scale, baseline, three-quarter rotation, lighting and floor perspective; do NOT enlarge level 1 to compensate for removed roof. Level 2 observation deck remains only moderately taller than level 1 deck. Do not make the 2nd stage gigantic or wide like a fortress. Same landscape sheet, complete silhouettes, broad blank central gutter and comfortable margins. No clipping or touching. No ground islands, scenery, vegetation, snow or additional objects in the background.
Text: Retain only the correct labels "1단계" and "2단계" beneath the respective towers, with whitespace above labels. No other words, arrow, dimension, UI, watermark or title.
Intent: clean attractive actual modeling reference. Richness comes from purposeful structure, silhouette and several large crafted accents rather than noisy surface texture. Preserve identity of the source while applying both user revisions decisively.
```

