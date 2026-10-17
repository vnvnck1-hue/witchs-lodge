# 실제 이미지 수정 프롬프트 · v03

2026-10-17, 내장 `image_gen`, 불투명 PNG. 사용자 요청: “조금만 눈 덜 아프게 수정해봐”.

## 낮

실제 입력: `../gameplay-warcraft-lol-v02/01-day-concept.png`

```text
Use case: precise-object-edit / gentle color grading of the attached finished environment concept art.
The user asks ONLY: "make it a little easier on the eyes." Make a SMALL, careful revision, around 10–15% gentler, retaining the OLD WARCRAFT / classic LEAGUE OF LEGENDS art direction.
INVARIANTS: keep the exact composition, camera, image crop, geometry, object positions, silhouettes, brushwork and details of this existing painting. Preserve the same lodge, single chimney, door, three sheep, pen, barrel, open gate, purple witch, paths, stones, trees and shrubs. Keep the medieval-based fantasy everyday atmosphere. This is a restrained finishing pass on the original artwork, not a redraw.
ADJUST ONLY: gently lower overall saturation by roughly 10–15%, especially the electric cobalt/blue-violet snow shadows; shift these to quieter dusty periwinkle/slate-lavender while keeping their blue-purple identity. Slightly compress extreme contrast: soften the brightest snow/highlight peaks about 8–10%, and lift only the very darkest creases a touch, retaining chunky readable shadows and silhouette clarity. Slightly soften tiny competing high-contrast marks on background snow/shrubs without losing crispness of main objects. Keep amber-orange light warm but less glaring; gently reduce its saturation and bloom. Favor comfortable midtones and broader calm value areas. Keep visual focus on the cottage and witch.
Do not blur, haze-wash, desaturate to gray, add fog, flatten all lighting, erase detail, change the style to pastel/watercolor, add anything, or move anything. No text, frame, UI, logos or watermark. Preserve original landscape aspect and output a single edited painting.
Time-of-day constraint: DAY remains clearly daytime. Retain ivory sunlit snow, brown paths, quiet deep green trees and golden brown timber. Reduce brightness slightly, not enough to make it dusk.
```

## 밤

실제 입력: `../gameplay-warcraft-lol-v02/02-night-concept.png`

```text
Use case: precise-object-edit / gentle color grading of the attached finished environment concept art.
The user asks ONLY: "make it a little easier on the eyes." Make a SMALL, careful revision, around 10–15% gentler, retaining the OLD WARCRAFT / classic LEAGUE OF LEGENDS art direction.
INVARIANTS: keep the exact composition, camera, image crop, geometry, object positions, silhouettes, brushwork and details of this existing painting. Preserve the same lodge, single chimney, door, three sheep, pen, barrel, open gate, purple witch, paths, stones, trees and shrubs. Keep the medieval-based fantasy everyday atmosphere. This is a restrained finishing pass on the original artwork, not a redraw.
ADJUST ONLY: gently lower overall saturation by roughly 10–15%, especially the electric cobalt/blue-violet snow shadows; shift these to quieter dusty periwinkle/slate-lavender while keeping their blue-purple identity. Slightly compress extreme contrast: soften the brightest snow/highlight peaks about 8–10%, and lift only the very darkest creases a touch, retaining chunky readable shadows and silhouette clarity. Slightly soften tiny competing high-contrast marks on background snow/shrubs without losing crispness of main objects. Keep amber-orange light warm but less glaring; gently reduce its saturation and bloom. Favor comfortable midtones and broader calm value areas. Keep visual focus on the cottage and witch.
Do not blur, haze-wash, desaturate to gray, add fog, flatten all lighting, erase detail, change the style to pastel/watercolor, add anything, or move anything. No text, frame, UI, logos or watermark. Preserve original landscape aspect and output a single edited painting.
Time-of-day constraint: NIGHT remains clearly night. Retain the midnight blue-purple setting and small warm amber light pools. Reduce glaring saturated blue in the snow and foliage. Modestly lift near-black foliage shadows, not the whole image; keep night clearly darker than day. The small staff-tip light stays restrained.
```
