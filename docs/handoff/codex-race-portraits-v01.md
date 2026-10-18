# Codex에게 요청하는 에셋 작업 — 다섯 종족 손님 포트레이트 35장 (v01)

요청자: Claude (게임 구현 담당) · 2026-10-18 · 기획: [종족 시스템 1차](../races-guests-v01.md) §3 (인물 표), [세계관·종족 기획](../narrative-pack/world-races-card-formats-v01.md) §3·§6

## 역할 분담

- **Codex 책임:** 아래 35장의 투명 배경 상반신 포트레이트 생성·검증·문서화. 작업 폴더는 **이 워크트리**(이 문서가 있는 저장소 루트)다.
- **Claude 책임:** 종족 데이터·손님 프로필·대사·도착 UI 코드. 포트레이트가 없는 동안은 익명 실루엣으로 동작하므로 **경로·파일명·규격만 맞으면 납품 즉시 화면에 보인다.**
- **수정 금지:** `godot/scripts/**`, `godot/scenes/**`, `godot/shaders/**`, `godot/assets/cards/catalog.json`, `godot/project.godot`, `godot/tools/**`, `docs/races-guests-v01.md`. 다른 변경을 되돌리지 말 것. **커밋하지 말 것.**

## 반드시 따를 기존 기준 — 카드 화풍 포트레이트(2026-10-18 확정)

현재 게임의 손님 7명은 **카드 일러스트 화풍**으로 교체됐다. 그 기준 자료는 메인 체크아웃에 있다(읽기 전용, 복사하지 말 것):

- 승인 기준 그림: `D:\2020_이전승찬파일\작업,내파일\2026\프로토타입 게임\마녀산장\art\portraits\card-style-v01\bram.png` (브람 v02, **화풍·구도·하단 마감의 1순위 기준**)
- 같은 폴더의 `mira.png`·`olaf.png`·`torbin.png`·`neri.png`·`oswin.png`·`sera.png` (동일 화풍 7인 세트)
- 실제 사용 프롬프트: 같은 폴더의 `prompts/*.md` — **`prompts/mira.md`의 공통 문단(Use case ~ World 줄)을 그대로 쓰고 Subject만 바꾼다.**
- 적용 기록: `...\마녀산장\docs\portrait-card-style-rollout-v01.md`
- 종족 원화(그림체·종족 외형 참고): 이 저장소의 `art/concepts/cards/roles-races-v01/02-goblin-nib-v01.png`(고블린 니브), `04-beastfolk-luka-v01.png`(여우 수인 루카), `01-role-formats-v02.png`.
- 아트 가이드 `docs/art-direction.md`, 세계관 `docs/narrative-pack/world-races-card-formats-v01.md` §3·§6.

핵심 요건(브람 v02 기준):

- **굵고 가늘어지는 검은 먹선, 큰 색면, 2~3단계 명암, 절제된 인쇄 질감.** 실사·3D·에어브러시·애니메 금지. 같은 카드 일러스트레이터가 그린 것처럼.
- **상반신(머리~허리), 머리·양 어깨·양 팔꿈치·손·소품이 모두 캔버스 안.** 사방 6% 이상 투명 여백. 하단은 브람 v02처럼 불규칙한 손그림 비네트로 마감(직선 크롭 금지). 다리·전신 금지.
- **RGBA 1122×1402(4:5)**, 바깥은 진짜 투명 알파. 안개·후광·사각 배경·프레임·글자·워터마크·추가 인물 금지.
- 세계: **중세 기반 판타지**. 총기·현대 의복·고글·플라스틱 금지. 가죽·양모·철·나무·뼈·동전·양초.
- 인물마다 포즈·손 위치를 달리한다(전부 팔짱 금지). 얼굴은 알림 창에서 읽힐 만큼 크게. 종족 특징(엄니·귀·날개·주둥이)이 실루엣에서 바로 읽혀야 한다.
- 종족 보조색(§2)은 의상·소품의 포인트로만: 드워프 구리·암석, 요정 연두·은빛, 고블린 이끼·구리, 수인 호박색·크림, 오크 붉은 흙·뼈. 보라 기본 배경은 없다(투명).

## 생성 규격

- 경로·이름: `godot/assets/portraits/guest_<id>_cutout.png` (id는 아래 표). 원본 고해상도는 `art/portraits/card-style-v01/races/<id>.png` 에 보존.
- 공통 프롬프트 = `prompts/mira.md` 공통 문단 + 아래 Subject. 참고 입력은 브람 v02(화풍·구도) + 니브 카드(그림체) + 해당 종족 원화(있으면).
- 니브·루카는 기존 원화 인물의 **정체성을 유지**하고 포맷만 포트레이트로 바꾼다(카드 프레임·글자 제거, 상반신 재구성).

## Subject 35종

### 드워프 (dwarf) — 땅딸막하고 넓은 어깨, 머리 크기 비례 큼. 도구와 조상 장식.

| id | Subject (영문, 프롬프트에 그대로) |
| --- | --- |
| harald | Harald, a retired dwarf mine-guard warrior, late middle age, broad square face, thick grey braided beard with two iron rings, heavy brow, calm stubborn eyes. Mail shirt over a scorched leather apron, round iron-rimmed wooden shield held at his side, copper-studded belt. One hand resting on the shield rim, the other knocking two knuckles against an unseen wall as if testing stone. Expression: slow deliberate appraisal. |
| brynhild | Brynhild, a boisterous dwarf huntress, adult, ruddy round face, bright red hair in thick braids pinned up, small healed scar on one cheekbone, wide grin showing a gap tooth. Wolf-pelt collar over a rust-brown quilted coat, crossbow slung over her shoulder with the stock visible, bolt quiver strap. One fist on hip, other hand holding up a coin as if offering a bet. Expression: loud confident challenge. |
| thorgrim | Thorgrim, a meticulous dwarf timber-carpenter turned lumberjack, middle age, long black beard dusted with sawdust, narrowed measuring eyes, lined forehead. Thick grey wool vest, rolled sleeves, belt with folding rule, chisel and a small hatchet handle. Hands holding a short plank up to his eye, sighting along its grain. Expression: quiet professional scrutiny, mouth a flat line. |
| durga | Durga, an elderly dwarf woman gatherer, deeply wrinkled kind-grumpy face, white hair in a tight bun with a bone pin, thick round spectacles on a nose chain, pursed mouth. Dark green shawl over a patched ochre dress, moss basket on one arm, small ore pouch at her belt, lantern hook. One hand raised wagging a finger mid-scold while the other clutches the basket. Expression: scolding but warm. |
| ormu | Ormu, a dwarf ruin surveyor traveler, middle age, dust-grey beard trimmed short, intense squinting eyes, stone dust on cheeks. Heavy hooded travel coat with many sample pockets, a chipped carved stone fragment held up in one hand, small geologist hammer and chisel at belt, rolled leather map case. Expression: absorbed fascination, as if about to argue. |
| ketil | Ketil, a wandering dwarf blacksmith traveler, adult, burn-scarred forearms, soot-dark short beard, shaved temples with tattooed knotwork, tired steady eyes. Singed leather apron over bare muscular shoulders and a wool undershirt, small travel anvil strapped on his back visible behind one shoulder, hammer resting across his forearms. Expression: silent, reserved nod. |
| signy | Signy, a cheerful dwarf brewer traveler, adult woman, round flushed cheeks, golden hair in a crown braid, laughing eyes, freckles. Cream linen blouse, red-brown bodice, small wooden cask slung by a strap over her shoulder, pewter tankard hooked to belt. One hand raising the tankard in a toast, other hand on the cask. Expression: hearty laughing welcome. |

### 요정 (fairy) — 작은 자연의 존재. 날개·더듬이·잎, 사람보다 큰 눈. 상반신 구도이므로 크기는 소품(도토리·잎·열매)의 비례로 암시.

| id | Subject |
| --- | --- |
| thistle | Thistle, a tiny fairy guardian warrior, pale violet skin, sharp proud features, large dark eyes, thin antennae, dragonfly wings folded upright behind. Acorn-cup helmet, armor of overlapping thistle bracts, a long thistle-spine spear held vertically beside the face so its scale reads as a whole plant stem. Posture stiffly formal, chin raised. Expression: grave ceremonial dignity on a small face. |
| tilia | Tilia, a mischievous fairy archer, warm honey-tan skin dotted with freckle-like glowing specks, pointed ears, moth wings patterned brown and cream, hair like loose maple-seed tufts. Maple-leaf cloak, a bow made from a bent twig with a strand of spider-silk, quiver of pine-needle arrows. One eye winking, drawing an arrow lazily. Expression: playful aim, half-smile. |
| larch | Larch, a stern fairy pruner (lumberjack role), olive-green skin, pine-needle hair swept back, furrowed brow, thin mouth, beetle-shell wing covers in dark bronze. Bark-plate vest, a tiny pruning saw and shears at belt, holding a cut diseased twig up with disapproval. Expression: strict gardener's frown, inspecting. |
| fern | Fern, a shy fairy seed gatherer, pale green skin, hair of unfurling fern fronds, very large glossy eyes, translucent veined wings. Seed pouch belt with many small bulging pockets, a single oversized dandelion seed held in both hands close to the chest. Shoulders drawn in, peeking up. Expression: timid curiosity. |
| willow | Willow, a formal fairy forest envoy traveler, silver-white skin with faint green veins, long willow-leaf robe, a crown of silver pollen dust, folded long narrow wings, serene elongated face. Hands folded inside sleeves, a tiny scroll of birch bark tucked at the sash. Expression: composed, cool warning in the eyes. |
| pip | Pip, a hyperactive fairy seed courier, small round face, hair a puff of dandelion fluff, bee-like striped wings in motion blur, bright wide eyes, open mouth mid-sentence. Acorn backpack stuffed with seeds, a leaf map clutched in one hand, other hand pointing somewhere. Expression: breathless excited chatter. |
| nivel | Nivel, a drowsy fairy dream-chronicler traveler, dusky blue-grey skin, half-closed heavy-lidded eyes, moth-wing hood of soft grey pulled over the head, wrapped in a moss blanket. Holding an open birch-bark book with a tiny quill, head tilted as if dozing. Expression: sleepy, cryptic faint smile. |

### 고블린 (goblin) — 니브 카드 원화의 종족 외형을 따른다: 긴 귀, 뾰족 코, 이끼빛 피부, 작은 체구·큰 머리.

| id | Subject |
| --- | --- |
| graz | Graz, a goblin warrior in mismatched scrap armor, mossy green skin, very long ears one bent, big forced brave grin with crooked teeth, nervous darting eyes. Dented cooking-pot helmet, one steel pauldron and one leather pauldron, a chipped shortsword held up in a would-be heroic pose with the other hand hiding behind the back. Expression: bluster covering fear. |
| pikl | Pikl, a goblin trapper hunter, narrow suspicious eyes, thin pursed lips, leather cap with ear flaps for long ears, olive skin. Coils of snare cord and small iron traps hanging from belt and shoulder strap, a knotted tally string held up while counting on the fingers of the other hand. Expression: calculating, lips moving as he counts. |
| rusk | Rusk, a goblin lumberjack who collects saws, gap-toothed delighted smile, sawdust in bristly hair, long ears, grey-green skin. Three different saws strapped across his back with handles visible above the shoulders, patched vest, hands lovingly polishing a saw blade with a rag. Expression: affectionate pride in tools. |
| tak | Tak, a goblin gatherer of shiny things, large sparkling eyes, long twitchy ears with earrings made of buttons, yellowish-green skin. Coat covered in dozens of small bulging pockets, necklace of glass beads and buttons and a spoon, one hand pulling a glittering pebble from a pocket to show. Expression: bursting curiosity. |
| nib | Nib, the goblin peddler from the approved card art `art/concepts/cards/roles-races-v01/02-goblin-nib-v01.png`: KEEP that character's face, skin tone, ears, copper rivets, coin ornaments and pack. Reframe as a half-body portrait: one hand rubbing fingers together in a bargaining gesture, other hand on a bundled pack strap. Expression: sly friendly haggling smile. |
| grik | Grik, a goblin explorer traveler, feathered wide-brim hat with a torn brim, bandaged fingers, one missing ear tip, animated face mid-boast with eyebrows high. A torn hand-drawn map held open across the chest, rope coil and compass-less brass sighting tube at belt. Expression: exaggerated storytelling. |
| mala | Mala, a goblin antiques collector traveler, elegant for a goblin: a monocle on a chain, velvet plum shawl over a dark dress, long ears with a tiny gem stud, thin appraising smile. Holding a small brass jewel scale in one hand and a tarnished locket up to the monocle in the other. Expression: shrewd evaluation. |

### 수인 (beastfolk) — 루카 카드 원화의 접근을 따른다: 동물 머리·털·귀가 실루엣을 만든다. 의인화된 중세 복장.

| id | Subject |
| --- | --- |
| fargh | Fargh, a wolf beastfolk warrior, grey wolf head with a torn ear and pale muzzle scar, amber eyes, calm closed muzzle. Fur-collared dark leather armor with iron studs, two-handed sword hilt rising over one shoulder, a pack-token of braided cord at the neck. Arms crossed low, standing guard. Expression: silent watchful loyalty. |
| saya | Saya, a lynx beastfolk huntress, spotted tawny fur, tufted ears, slit pupils reflecting light, short whiskers. Dark green hood pushed back, short recurve bow held low, a small bird-feather fletching tucked in the hood. Head turned slightly as if listening to the dark. Expression: terse, alert, unbothered. |
| urso | Urso, a bear beastfolk lumberjack, massive brown bear head and shoulders, small sleepy eyes, soft half-smile. Enormous wool coat straining at the shoulders, a honey jar tied by a cord at the belt, a felling axe resting easily on one shoulder. Scratching behind one ear. Expression: unhurried, amused patience. |
| momi | Momi, a rabbit beastfolk gatherer, soft grey-brown fur, one long ear folded down, wide anxious eyes, twitching nose. Patched travel cloak, herb basket hugged tightly to the chest, a tiny digging trowel at the belt. Shoulders hunched, glancing sideways. Expression: nervous but determined. |
| luka | Luka, the fox beastfolk guide from the approved card art `art/concepts/cards/roles-races-v01/04-beastfolk-luka-v01.png`: KEEP that character's fox face, fur colors, ears, amber cloak and ornaments. Reframe as a half-body portrait: one hand raised with a charming open palm as if saying "this way", tail tip visible at the edge of the silhouette. Expression: sly cheerful reassurance. |
| tass | Tass, a badger beastfolk porter traveler, black-and-white striped badger face, small stubborn eyes, thick neck, grizzled fur. Heavy pack straps gripped tightly in both fists across the chest, rope-bound bundles rising behind the shoulders, worn canvas coat. Expression: obstinate refusal to put anything down. |
| selen | Selen, an owl beastfolk night courier traveler, feathered owl face with huge round dark eyes, feather tufts, pale moon-grey plumage. Feather-trimmed cloak, a letter satchel with wax-sealed envelopes peeking out, head tilted at an owl-like angle. Expression: wide-awake eerie calm. |

### 오크 (orc) — 큰 체격, 녹색~올리브 피부, 짧은 엄니, 뼈·가죽·붉은 흙 안료 장식. 잔혹하지 않고 공동체적으로.

| id | Subject |
| --- | --- |
| garok | Garok, an orc guard-captain warrior, dark green skin, short lower tusks, square jaw, deliberate heavy-browed eyes, hair in a tight topknot. Layered leather and bronze pauldrons, a bone-bead necklace of oath tokens, a thick cloak. One fist pressed flat over the heart in a vow gesture, other hand on a sheathed broad blade. Expression: solemn, binding promise. |
| kranya | Kranya, an orc huntress, olive skin, long black braids with animal teeth woven in, one tusk chipped, bright competitive grin. Hide vest with trophy claws, a throwing spear held upright, a brace of hares hanging from her belt. Expression: proud boast, chin up. |
| moga | Moga, a gigantic orc lumberjack, huge shoulders filling the frame, wide joyful gap-toothed laugh, small tusks, bald head with red earth paint stripes. Double-bitted axe across the back, a carved wooden tree charm on a cord, sleeveless wool tunic. Both big hands raised in an apologetic shrug as if saying sorry to a tree. Expression: booming warmth. |
| shaga | Shaga, a young orc shaman apprentice gatherer, slender for an orc, grey-green skin, ash-drawn white lines across the face, thoughtful downcast eyes, short tusks. Bundles of roots and dried mushrooms tied across the chest, a small clay bowl of ash held in both hands. Expression: quiet concentration, reverence. |
| ulma | Ulma, an elderly orc shaman traveler, deeply lined dark green face, white wild hair, milky one eye, worn tusks, knowing crooked smile. Staff hung with bones and feathers, leather pouch open with carved bone dice spilling into her palm. Expression: amused prophecy. |
| bardu | Bardu, an orc ancestor-pilgrim traveler, gaunt weathered face, long grey-streaked hair, eyes distant and kind, small tusks. Pilgrim staff with ancestor cloth strips tied at the top, a sash painted with handprint marks, simple travel robe. One hand touching the sash reverently. Expression: serene, far-looking. |
| eshka | Eshka, an orc cook traveler, plump friendly face, green skin, beaming smile with rounded tusks, hair tied in a cloth wrap. Stained apron over a wool dress, a huge wooden ladle raised in one hand, strings of dried peppers and spice pouches across the chest. Expression: generous hospitality, inviting. |

## 산출물 기록

- 프롬프트 기록: `art/portraits/card-style-v01/races/prompts/<id>.md` (실제 프롬프트·참고 입력·재생성 이력).
- 미리보기 시트: `godot/screenshots/races/portrait-sheet.png` (35장 축소 배치, id 라벨, 종족별 행).
- 검증 기록: `output/race-portraits-v01/asset-verification.json` (파일별 크기·채널·알파·사방 여백(알파 8/255 초과 영역이 캔버스 모서리에 닿지 않음)·SHA-256, passed). 기존 `art/portraits/card-style-v01/verify-assets.ps1`(메인 체크아웃)의 검사 방식을 재사용해도 된다.
- 납품 후 이 워크트리에서 `.tools/Godot-4.7.2.exe --headless --path godot --import` 를 한 번 실행해 `.import` 파일을 만든다(이미지 전용 격리 프로젝트 방식도 허용).

## 완료 기준

1. 35장이 `godot/assets/portraits/guest_<id>_cutout.png` 에 RGBA 1122×1402, 진짜 투명 배경, 사방 여백 확보로 존재.
2. 브람 v02와 같은 먹선·색면·마감. 종족 특징이 실루엣에서 읽힘. 니브·루카는 원화 정체성 유지.
3. 글자·프레임·후광·추가 인물 없음, 중세 판타지 재료만.
4. `--import` 종료 코드 0, 검증 JSON `passed=true`.
5. 이 문서 끝에 `## Codex 납품 결과 · <날짜>` 절을 붙여 파일 목록·확인 결과 요약. 마지막 메시지에도 같은 요약. 실패하거나 기준을 못 맞춘 인물은 숨기지 말고 id별로 적는다.


## Codex 납품 결과 · 2026-10-18

다섯 종족 포트레이트 35장 제작·검증·문서화를 완료했다.

- 원본 35장·런타임 35장·프롬프트 35개와 종족별 미리보기 시트를 납품했다.
- 35장 모두 RGBA 1122×1402·투명 알파·사방 6% 이상 여백 검사를 통과했다. 검증 JSON은 `passed=true`다.
- Godot import와 35개 텍스처 검증은 종료 코드 0이며, 루트 `WitchsLodge.exe`도 다시 내보냈다.
- 수정 금지 경로를 직접 수정하거나 커밋하지 않았다. 병행 작업의 기존 변경은 보존했다. 최종 미충족 id는 없다.

### 파일 목록

[35장 미리보기](../../godot/screenshots/races/portrait-sheet.png) · [최종 실행파일](../../WitchsLodge.exe)

| 종족 | id | 런타임 | 생성 원본 | 실제 프롬프트·이력·검수 |
| --- | --- | --- | --- | --- |
| 드워프 | harald | [PNG](../../godot/assets/portraits/guest_harald_cutout.png) | [PNG](../../art/portraits/card-style-v01/races/harald.png) | [기록](../../art/portraits/card-style-v01/races/prompts/harald.md) |
| 드워프 | brynhild | [PNG](../../godot/assets/portraits/guest_brynhild_cutout.png) | [PNG](../../art/portraits/card-style-v01/races/brynhild.png) | [기록](../../art/portraits/card-style-v01/races/prompts/brynhild.md) |
| 드워프 | thorgrim | [PNG](../../godot/assets/portraits/guest_thorgrim_cutout.png) | [PNG](../../art/portraits/card-style-v01/races/thorgrim.png) | [기록](../../art/portraits/card-style-v01/races/prompts/thorgrim.md) |
| 드워프 | durga | [PNG](../../godot/assets/portraits/guest_durga_cutout.png) | [PNG](../../art/portraits/card-style-v01/races/durga.png) | [기록](../../art/portraits/card-style-v01/races/prompts/durga.md) |
| 드워프 | ormu | [PNG](../../godot/assets/portraits/guest_ormu_cutout.png) | [PNG](../../art/portraits/card-style-v01/races/ormu.png) | [기록](../../art/portraits/card-style-v01/races/prompts/ormu.md) |
| 드워프 | ketil | [PNG](../../godot/assets/portraits/guest_ketil_cutout.png) | [PNG](../../art/portraits/card-style-v01/races/ketil.png) | [기록](../../art/portraits/card-style-v01/races/prompts/ketil.md) |
| 드워프 | signy | [PNG](../../godot/assets/portraits/guest_signy_cutout.png) | [PNG](../../art/portraits/card-style-v01/races/signy.png) | [기록](../../art/portraits/card-style-v01/races/prompts/signy.md) |
| 요정 | thistle | [PNG](../../godot/assets/portraits/guest_thistle_cutout.png) | [PNG](../../art/portraits/card-style-v01/races/thistle.png) | [기록](../../art/portraits/card-style-v01/races/prompts/thistle.md) |
| 요정 | tilia | [PNG](../../godot/assets/portraits/guest_tilia_cutout.png) | [PNG](../../art/portraits/card-style-v01/races/tilia.png) | [기록](../../art/portraits/card-style-v01/races/prompts/tilia.md) |
| 요정 | larch | [PNG](../../godot/assets/portraits/guest_larch_cutout.png) | [PNG](../../art/portraits/card-style-v01/races/larch.png) | [기록](../../art/portraits/card-style-v01/races/prompts/larch.md) |
| 요정 | fern | [PNG](../../godot/assets/portraits/guest_fern_cutout.png) | [PNG](../../art/portraits/card-style-v01/races/fern.png) | [기록](../../art/portraits/card-style-v01/races/prompts/fern.md) |
| 요정 | willow | [PNG](../../godot/assets/portraits/guest_willow_cutout.png) | [PNG](../../art/portraits/card-style-v01/races/willow.png) | [기록](../../art/portraits/card-style-v01/races/prompts/willow.md) |
| 요정 | pip | [PNG](../../godot/assets/portraits/guest_pip_cutout.png) | [PNG](../../art/portraits/card-style-v01/races/pip.png) | [기록](../../art/portraits/card-style-v01/races/prompts/pip.md) |
| 요정 | nivel | [PNG](../../godot/assets/portraits/guest_nivel_cutout.png) | [PNG](../../art/portraits/card-style-v01/races/nivel.png) | [기록](../../art/portraits/card-style-v01/races/prompts/nivel.md) |
| 고블린 | graz | [PNG](../../godot/assets/portraits/guest_graz_cutout.png) | [PNG](../../art/portraits/card-style-v01/races/graz.png) | [기록](../../art/portraits/card-style-v01/races/prompts/graz.md) |
| 고블린 | pikl | [PNG](../../godot/assets/portraits/guest_pikl_cutout.png) | [PNG](../../art/portraits/card-style-v01/races/pikl.png) | [기록](../../art/portraits/card-style-v01/races/prompts/pikl.md) |
| 고블린 | rusk | [PNG](../../godot/assets/portraits/guest_rusk_cutout.png) | [PNG](../../art/portraits/card-style-v01/races/rusk.png) | [기록](../../art/portraits/card-style-v01/races/prompts/rusk.md) |
| 고블린 | tak | [PNG](../../godot/assets/portraits/guest_tak_cutout.png) | [PNG](../../art/portraits/card-style-v01/races/tak.png) | [기록](../../art/portraits/card-style-v01/races/prompts/tak.md) |
| 고블린 | nib | [PNG](../../godot/assets/portraits/guest_nib_cutout.png) | [PNG](../../art/portraits/card-style-v01/races/nib.png) | [기록](../../art/portraits/card-style-v01/races/prompts/nib.md) |
| 고블린 | grik | [PNG](../../godot/assets/portraits/guest_grik_cutout.png) | [PNG](../../art/portraits/card-style-v01/races/grik.png) | [기록](../../art/portraits/card-style-v01/races/prompts/grik.md) |
| 고블린 | mala | [PNG](../../godot/assets/portraits/guest_mala_cutout.png) | [PNG](../../art/portraits/card-style-v01/races/mala.png) | [기록](../../art/portraits/card-style-v01/races/prompts/mala.md) |
| 수인 | fargh | [PNG](../../godot/assets/portraits/guest_fargh_cutout.png) | [PNG](../../art/portraits/card-style-v01/races/fargh.png) | [기록](../../art/portraits/card-style-v01/races/prompts/fargh.md) |
| 수인 | saya | [PNG](../../godot/assets/portraits/guest_saya_cutout.png) | [PNG](../../art/portraits/card-style-v01/races/saya.png) | [기록](../../art/portraits/card-style-v01/races/prompts/saya.md) |
| 수인 | urso | [PNG](../../godot/assets/portraits/guest_urso_cutout.png) | [PNG](../../art/portraits/card-style-v01/races/urso.png) | [기록](../../art/portraits/card-style-v01/races/prompts/urso.md) |
| 수인 | momi | [PNG](../../godot/assets/portraits/guest_momi_cutout.png) | [PNG](../../art/portraits/card-style-v01/races/momi.png) | [기록](../../art/portraits/card-style-v01/races/prompts/momi.md) |
| 수인 | luka | [PNG](../../godot/assets/portraits/guest_luka_cutout.png) | [PNG](../../art/portraits/card-style-v01/races/luka.png) | [기록](../../art/portraits/card-style-v01/races/prompts/luka.md) |
| 수인 | tass | [PNG](../../godot/assets/portraits/guest_tass_cutout.png) | [PNG](../../art/portraits/card-style-v01/races/tass.png) | [기록](../../art/portraits/card-style-v01/races/prompts/tass.md) |
| 수인 | selen | [PNG](../../godot/assets/portraits/guest_selen_cutout.png) | [PNG](../../art/portraits/card-style-v01/races/selen.png) | [기록](../../art/portraits/card-style-v01/races/prompts/selen.md) |
| 오크 | garok | [PNG](../../godot/assets/portraits/guest_garok_cutout.png) | [PNG](../../art/portraits/card-style-v01/races/garok.png) | [기록](../../art/portraits/card-style-v01/races/prompts/garok.md) |
| 오크 | kranya | [PNG](../../godot/assets/portraits/guest_kranya_cutout.png) | [PNG](../../art/portraits/card-style-v01/races/kranya.png) | [기록](../../art/portraits/card-style-v01/races/prompts/kranya.md) |
| 오크 | moga | [PNG](../../godot/assets/portraits/guest_moga_cutout.png) | [PNG](../../art/portraits/card-style-v01/races/moga.png) | [기록](../../art/portraits/card-style-v01/races/prompts/moga.md) |
| 오크 | shaga | [PNG](../../godot/assets/portraits/guest_shaga_cutout.png) | [PNG](../../art/portraits/card-style-v01/races/shaga.png) | [기록](../../art/portraits/card-style-v01/races/prompts/shaga.md) |
| 오크 | ulma | [PNG](../../godot/assets/portraits/guest_ulma_cutout.png) | [PNG](../../art/portraits/card-style-v01/races/ulma.png) | [기록](../../art/portraits/card-style-v01/races/prompts/ulma.md) |
| 오크 | bardu | [PNG](../../godot/assets/portraits/guest_bardu_cutout.png) | [PNG](../../art/portraits/card-style-v01/races/bardu.png) | [기록](../../art/portraits/card-style-v01/races/prompts/bardu.md) |
| 오크 | eshka | [PNG](../../godot/assets/portraits/guest_eshka_cutout.png) | [PNG](../../art/portraits/card-style-v01/races/eshka.png) | [기록](../../art/portraits/card-style-v01/races/prompts/eshka.md) |

### 확인 결과와 보존 기록

- 내장 `image_gen`으로 인물별 개별 제작했다. 메인 체크아웃의 브람 v02·공통 프롬프트는 읽기 전용으로 참조했고 기준 PNG를 워크트리로 복사하지 않았다. 니브·루카 카드도 실제 참고 입력에 포함했다.
- [프롬프트 검증](../../output/race-portraits-v01/prompt-verification.json): 35개 모두 `mira.md`의 Use case ~ World 공통 문단과 요청서 Subject가 그대로 포함되며 실제 사용 프롬프트가 해당 md에 보존된다. 신규 인물은 정체성 복제를 막는 참조 바인딩 보충 문단을 추가했다.
- [에셋 검증](../../output/race-portraits-v01/asset-verification.json): 종족별 7장, 고유 파일 35장, RGBA 8비트 1122×1402, 투명 픽셀·불투명 픽셀 존재, 가장자리 알파 0, 알파 8/255 초과 영역 기준 최소 여백 약 **6.134%**. 원본은 생성 파일과 바이트 SHA-256이 일치한다. 런타임은 원본 전체 캔버스를 비율 유지 축소해 투명 캔버스에 배치했으며, 내용 크롭·알파 추출·재채색을 하지 않았다.
- [생성 매니페스트·인물별 시각 검수](../../output/race-portraits-v01/generation-manifest.json): 브람의 먹선·색면·2~3단 명암·불규칙 하단 마감, 종족 실루엣, 손·소품 포함 여부, 중세 판타지 재료, 글자·프레임·후광·추가 인물 부재를 원본과 최종 시트에서 확인했다. 니브의 얼굴·피부·귀·동전·짐, 루카의 여우 얼굴·털색·귀·장식을 원화와 대조했다.
- 재생성은 `harald`, `thorgrim`, `ormu`, `ketil`의 드워프 개별 얼굴·체형 보강과 `luka`의 호박색 망토 보완에 각 1회씩 진행했다. 루카는 원화의 청색 외투와 크림 목깃도 망토 안쪽에 유지한다. 제외한 v01은 [drafts](../../output/race-portraits-v01/drafts/)에 보존했고 개별 프롬프트 문서에 v01/v02 전체 이력을 남겼다. 최종 기준 미충족·누락 인물은 **없다**.
- [Godot import 결과](../../output/race-portraits-v01/godot-import-result.json): 지정 워크트리에서 `--headless --path godot --import` 실행, 종료 코드 **0**. 35개 런타임 PNG의 `.import` 파일을 생성했다.
- [Godot 텍스처 검증](../../output/race-portraits-v01/godot-import-verification.json): **35/35, passed=true**. 엔진이 로드한 텍스처 크기와 RGBA SHA-256을 확인했다. 기본 `process/fix_alpha_border=true`가 투명 경계의 RGB를 보정하므로 원본 디코딩 복사본에 동일 엔진 보정을 적용한 뒤 정확히 비교했다. 납품 PNG 파일 자체는 변경하지 않았다. 이 검증은 에셋 import·디코딩 범위이며 게임 UI/등장 로테이션의 별도 플레이 검증을 뜻하지 않는다.
- [실행파일 검증](../../output/race-portraits-v01/executable-verification.json)·[export 결과](../../output/race-portraits-v01/godot-export-result.json): `Windows Desktop` 릴리스 종료 코드 **0**, 루트 `WitchsLodge.exe` 단일 파일 401,973,632바이트. PE `MZ`와 내장 PCK `GDPC` 푸터, export 로그의 35개 초상 텍스처 포함을 확인했다. 별도 실행파일·PCK·런처는 만들지 않았다.
- [작업 범위 기록](../../output/race-portraits-v01/scope-verification.json): 병행 구현에서 바뀐 스크립트·검증 파일을 관찰했고 되돌리지 않았다. Codex의 직접 변경은 초상 원본/런타임/프롬프트·검증/미리보기·이 납품 절·루트 실행파일 범위다. 수정 금지 경로를 직접 편집하지 않았고 커밋하지 않았다.
- 환경 로그에는 Windows 루트 인증서 읽기 및 샌드박스 밖 Godot 편집기 설정/사용자 로그 저장 권한 오류가 남았다. import·텍스처 검증·export 종료 코드와 산출물 검증은 모두 0/통과이며, 외부 설정 파일은 수정하지 않았다. 해당 로그는 `output/race-portraits-v01/godot-*-stderr.log`에 보존했다.

재실행 도구: [PNG 규격·알파·여백·해시 검사와 시트 생성](../../output/race-portraits-v01/prepare-assets.ps1), [Godot 텍스처 디코딩 검사](../../output/race-portraits-v01/verify-import.gd).

