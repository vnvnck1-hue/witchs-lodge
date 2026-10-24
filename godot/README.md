# 마녀산장 — Godot 프로토타입

**2026-10-24 떠돌이 행상 브로크·상점:** 오소리 수인 행상 브로크(`guest_profiles.gd` `SPECIALS`, id `brock`)가 3·6·9·12일차 낮 45초에 혼자 걸어와 문 오른쪽에 좌판을 펼친다(`scripts/game/merchant.gd`, `main.merchant`). 도착 소개 뒤 상점(`offer_screen.open_merchant`)이 자동으로 열리고, 인물 카드(용병 계약·에린)·침식·내부·이야기 전용 카드를 뺀 풀에서 무작위 5장을 가치 기반 가격(`merchant_data.gd`: 종류별 기본값 + 종족 +4G + 개별 보정 + 되팔기 방지)으로 판다. 상점은 그날 한 번뿐이라 닫으면 브로크가 떠나고(상점 전에 밤이 와도 떠남), 상점이 열린 동안 손님 메달·말풍선은 숨는다. 예전 6·11일차 장날은 이 방문으로 대체(`chapter_data.gd` `market` 제거). 초상·간판·좌판·가격표는 코덱스 요청([요청서](../docs/handoff/codex-merchant-brock-v01.md)), 없으면 실루엣·단색 판. 검증 `tools/verify_merchant.gd` 52항목. [기획](../docs/merchant-shop-v01.md).

**2026-10-22 손님 말 걸기 이야기 42편 재작성(성격·세계관):** 사용자 요청 — 예전 `guest_dialogues.gd` STORIES 는 42편 전부 "숲에서 겪은 기괴한 일"이라 딱딱하고 단조로웠다. 인물마다 소재를 달리해 다시 썼다: 마녀사냥 때 각 종족이 한 일, 워록의 흔적, 네 자매·네 귀퉁이의 등불, 종족 문화(돌·셈·맹세·솥), 산장 일상 농담(감자 소금 버섯·고기는 추가 요금·빗자루 내기). 숲의 미스터리는 몇 편(오르무·윌로우 등)에만 남겼다. 첫인사 3종·늑대의 피·에린 이야기는 그대로. 구조(prompt·title·opening·choices 2·closing)와 선택지가 보상에 개입하지 않는 원칙은 유지. 영문 336문장을 `tools/i18n/overrides.json`에 넣고 사전 재생성. 검증 `tools/verify_guest_stories.gd` 10항목(42명 전원·구조·도입 중복 없음·대화 창 715px/33px·도착 창 580px/28px 기준 3줄 이내·영문 누락/한글 섞임), `verify_dialogue_choices` 35·`verify_guest_roster` 316·`verify_i18n` 24·`verify_i18n_screens` 62 그대로. 읽기용 모음 [docs/dialogue-and-world-narrative.md](../docs/dialogue-and-world-narrative.md) 3부 갱신.

**2026-10-22 카드 툴팁 소개문(세계관 어조):** 사용자 결정 — 툴팁의 `description`(손패·주머니 툴팁, 제안 화면 툴팁)에서 수치·확률·조작 안내 같은 설명서식 문장을 모두 빼고, 109장 전부를 북쪽 마녀의 건조한 유머가 섞인 세계관 소개문(산장·네 마녀·종족·손님 이름을 끌어온 1~4문장)으로 다시 썼다. 규칙 요약은 카드 앞면 `printed_rules`가 그대로 맡는다. 영문은 `tools/i18n/overrides.json`에 같이 넣고 `merge`로 `assets/i18n/en.json` 재생성(다른 세션이 더한 디버그 문구 6개도 함께 채움). 검증 `tools/verify_card_lore.gd` 7항목(빈 소개문·숫자/%/초/클릭 등 설명서 표현·영문 누락·영문 속 한글), `verify_card_face.gd` 1056·`verify_i18n.gd` 24 그대로.

**2026-10-20 전설 카드 포맷·셰이더(첫 카드: 술 주정뱅이 에린):** 카탈로그 `"frame": "legendary"`(에린만). 그림은 사용자 납품 전설 프레임(`assets/cards/drunken_erin.png`, 원본 `art/cards/legendary-v01/`). 글자는 런타임 텍스트(`card_face.gd`, BM 을지로체)가 전설 그림에서 잰 크림판 프로파일(`assets/cards/text_layout.json` 의 `drunken_erin`, `tools/card_text_strip/measure_plates.py`)에 맞춰 타원 제목판·설명판에 채운다(제목 91px 한 줄 + 분류, 설명 69px 2줄). 주머니 목록 확대 카드도 `set_legendary_for()`로 전설 효과가 켜진다. 빛 효과는 `shaders/card_burn.gdshader` Legendary 그룹: 금테 숨쉬기·카드 뒤 금빛 후광(`card_view.gd` glow)·테두리 별빛 반짝임·광택 띠. 마스크 `assets/cards/fx/legendary_frame_mask.png`(R 보라 테두리, G 금테). **회전은 셰이더로 흉내 내지 않는다(사용자 확정):** 전설 카드는 `pivot_offset`을 카드 중앙으로 두고 실제로 회전하며 원근 tilt 는 0. 실제 회전 속도(`rvel`/14)·이동 속도(/1400)가 `legend_motion`(손패 드래그의 실제 회전 ±4°에서 0.2~0.6, 멈추면 0), 회전 각도가 `legend_angle`로 들어가 빛이 반응한다. 시험용 프리셋: 디버그 패널(F1) **에린·술 카드 지급**(`main.debug_tavern_cards()` — 에린·술 4종·술주정 2장·전투 용병 계약)·**에린 방문 부르기**(`debug_erin_visit()` — 술 조건을 채우고 낮이면 손님 무리를 바로 부름). 검증 `tools/verify_legendary_card.gd` 18항목, 캡처 `tools/capture_legendary_card.gd`(단독)·`tools/capture_legendary_ingame.gd`(실제 main.tscn 손패·호버·드래그·주머니) → `screenshots/legendary/`(빛·반짝임 외형은 헤드리스로 확인 불가).

**2026-10-20 술 주정뱅이 에린·주점 카드 v1:** `scripts/game/tavern_cards.gd`(`main.tavern`)가 카드 6종(`drunken_erin`·`fire_ale`·`golden_mead`·`wisp_spirit`·`dew_of_forgetting`·`drunk_rant`)의 판정·사용을 맡는다(resolver `"tavern"` 분기). 술 카드(`DRINK_IDS`, 흑맥주 통·전투 식량 포함, 술주정·에린 제외)를 `ERIN_AT`=3장 쓰면 `erin_waiting` → `lodge_economy._spawn_batch()`가 `extra_guests()`로 에린(`guest_profiles.gd` `SPECIALS`, 무작위 명부 밖)을 덤 손님으로 붙이고, `guest_events.gd`가 `Dialogues.ERIN_STORY`를 항상 띄워 선택지 효과 `"tavern:erin"`으로 에린 카드를 준다(거절하면 다음 날 재방문). 에린 카드는 `ERIN_WEIGHTS`(술주정 40·불꽃 에일 20·독주 15·이슬주 15·꿀술 10)로 3번 독립 추첨. 불꽃 에일은 `ally._damage_mult()`·`on_hit()`·숙취(`hungover()` — 다음 낮 30초 정지, 상태 글 "숙취"), 꿀술은 손님 고르는 창 → `serve_mead()`(숙박비 +50% 즉시·`favor`·다음 날 `mead_returns` 재방문, 입실 시 그 종족 카드 선물), 독주·이슬주는 `race_cards.open_choice()` 공용 창, 이슬주 드로우 감소는 `card_inventory.morning_draw()`, 술주정·독주 실패는 새 `card_inventory.stash_uid()`. 장날에 술 4종 판매(`chapter_data.gd`). 카드 원화 6장·에린 초상(`assets/portraits/guest_erin_cutout.png`)은 GPT 이미지 API(`gpt-image-2`)로 제작해 납품(원본·프롬프트 `art/cards/tavern-v01/`). 검증 `tools/verify_tavern_cards.gd`(→ `tavern_check.gd`) 49항목. [기획·에셋 목록](../docs/tavern-cards-v01.md).

**2026-10-19 서리 룬 VFX — VisualShader 업그레이드:** 단색 토러스·막대 문양과 범용 파티클을 VisualShader 5종으로 교체했다(`shaders/vfx/frost_rune/*.tres`, 편집기에서 노드 그래프로 조정 가능, 재생성 `tools/build_frost_rune_shaders.gd`). `frost_sigil` 위에서부터 그려지는 지면 룬 문양(이중 고리·회전하는 룬 띠·여섯 갈래 서리 결정·육각형) 가산, `frost_rime` 결정 세포 서리가 번졌다가 바깥부터 녹음, `frost_shock` 톱니 결정 충격 고리, `frost_pillar` 짧게 솟는 냉기 빛기둥, `frost_crystal` 3단 툰 명암·프레넬·굴절 줄무늬에 끝부터 녹는 알파 시저 디졸브. 연출 전담 `scripts/visual/vfx/frost_rune_vfx.gd`(시간표 2.7초: 문양 0.22초·충격 0.4초·결정 무리 12개가 안쪽부터 솟음·1.25초부터 녹음·차가운 OmniLight·얼음 파편/눈송이/연무/반짝이, 맞은 적 자리에 작은 결빙 결정 `encase()`). `actors/frost_rune.gd`는 판정(피해·감속·hits)만 남기고 연출이 끝나면 함께 사라진다. 감속 표식은 괴물·독벌레 모두 같은 서리 셰이더 자국(`slow_mark()`·`set_slow_mark()`, 풀리면 녹음). 검증 `tools/verify_frost_rune_vfx.gd` 18항목, 렌더 캡처 `tools/capture_frost_rune.gd` → `screenshots/frost_rune/`(VisualShader 컴파일·가산 합성·문양 모양은 헤드리스 확인 불가).

**2026-10-19 리팩토링·1차 최적화(동작 변화 없음):** 액터 공용 계산은 `scripts/actors/actor_util.gd`(`flat_dist`·`face`·`has_los`·`shed_leaves`)로 모으고 각 액터의 `_flat`·`_face`·`_has_los`·`_shed_leaves`는 이를 부르는 얇은 함수로 남겼다(검증 도구 호환). `main.gd`의 모듈 생성은 `_add_module(script)` 하나로(붙이는 순서 그대로). 매 프레임 UI 테마 덮어쓰기는 `MoonSkin.set_font_color()`·`set_stylebox()`로 값이 바뀔 때만 건다. 최적화: 시야 안개 `fog_of_war.gd`는 `_reveal`이 건드린 칸(이번·지난 갱신)만 지우고 인코딩하며 버퍼·Image·레이 쿼리를 재사용, 미니맵 `exploration_map.gd`는 카메라 회전 cos·sin을 스타일이 바뀔 때만 계산, 낮밤 `day_cycle.gd`는 스타일별 키 프로필을 캐시, VFX `vfx_pool.gd`는 MultiMesh를 256개로 시작해 필요할 때만 두 배로(매 프레임 올리는 버퍼 축소), `aerial_perspective.gd`는 OmniLight3D 목록을 트리 신호로 유지, 카드 목록 `card_catalog.gd`는 JSON을 한 번만 읽어 id 색인(`read()`는 여전히 새 사본), 괴물 `_pick_foe`·`_separation`과 용병 `_separation`은 배열 이어 붙이기·제곱근을 줄였다. 손패 카드 셰이더 값·달 게이지 다시 그리기·손님 알림 초상 `load()`·도착 고리 다시 그리기·모닥불 숯 재질·사거리 고리 색은 바뀔 때만 보낸다. 검증 `tools/verify_refactor_pass.gd` 34항목(안개 결과를 전체 재계산과 바이트 단위로 비교, 괴물 대상 고르기를 예전 방식과 비교 포함).

**2026-10-21 리팩토링·2차 최적화(동작 변화 없음):** 카드 묶음 모듈(고블린·종족·언데드·주점)은 공통 베이스 `scripts/game/card_module.gd`(`_fail`·`_night`·`_anywhere`·`_point`·`_flat`·`_worn`)를 상속하고, 판정기 `card_use_resolver.gd`의 모듈 분기는 `CARD_MODULES` 표 하나로 돈다(묻는 순서 그대로). F8·F9 안내 글자는 `scripts/ui/top_toast.gd` 하나로. 쓰이지 않던 기본 도형 블록아웃(`models.gd` 약 450줄)·죽은 함수 14개·미사용 상수/preload 20여 개를 지웠다. 최적화: 낮 주기는 시각·스타일·모드가 그대로이고 독 지역이 섞지 않으면 조명 전체를 다시 쓰지 않으며(`screen_style.apply`가 `day_cycle.mark_dirty()`로 다시 깔게 함), 독 지역은 영향 0이면 조명 보간을 건너뛴다. 매 프레임 그리는 UI는 `MoonSkin.flat_shared()`로 상자를 재사용(파티 프레임)·기다림 게이지는 상자 둘을 재사용·초상 원 UV는 한 번만·HUD 화면 고정 층과 맥주잔 게이지는 움직일 것이 있을 때만 다시 그린다. 손패는 정렬·`get_entry` 선형 탐색을 프레임당 표 하나로, 카드 휨 값은 사전을 새로 만들지 않는다. 액터 발밑 고리는 `Mats.unshaded_shared()`·`Build.torus` 메시 캐시로 공유, 거미 다리 상수·사슴 다리 뼈 번호는 한 번만 계산, 거미 깜박임·잔디 밀기·독 지역 셰이더 값은 바뀔 때만 보낸다. `actor_vfx`는 액터 종류를 처음 볼 때만 가리고, 들짐승 위협·용병 이동·주머니/손패 세기는 배열·람다를 만들지 않는다. `GuestProfiles.race_of`는 이름→종족 표, `distinct_races(true)`는 활동 용병만 돈다. 실행파일 내보내기에서 쓰지 않는 BM 폰트 11종·`art_sources/`를 뺐다(원본은 그대로). 검증 `tools/verify_refactor_pass2.gd` 21항목·`tools/verify_scripts_compile.gd`(모든 스크립트 컴파일).

**2026-10-22 용병 동행(사냥꾼·전투용병이 마녀를 따라 숲을 다닌다):** 낮에 마녀가 산장 중심 14m 밖으로 나가면 전투직이 정찰·대기·사냥을 끊고 후다닥 따라나와(마녀와의 거리에 비례해 3m 걷기 → 18m 이상 2.4배 6.2m/s로 달림, 필드에서 벌어져도 같음, 30m 밖 4초면 곁으로 순간이동) 마녀 곁(전투용병 2.2m·사냥꾼 3.0m)에 붙어 다닌다. 동행 중에는 마녀 10m 안의 모든 적(맹독 곤충 포함)과 교전하고 14m 밖이면 놓아준다. 사냥꾼은 마녀가 0.6초 이상 서 있을 때만 마녀 10m 안 토끼·사슴을 쏘고, 마녀가 움직이면 바로 따라간다. 마녀가 11m 안으로 돌아오거나 일몰이면 정찰로 복귀(밤에는 동행 없음). 부상자도 따라온다. `scripts/actors/ally.gd` `State.ESCORT`·`escort`·`_update_escort()`·`_escort()`·`_find_enemy_near_witch()`, 출발 토스트 `contract_director.gd` `note_escort_start()`, 수치 `config.gd` `ESCORT_*`. 검증 `tools/verify_merc_escort.gd` 30항목. [기획](../docs/merc-escort-v01.md).

**2026-10-22 스킬 바 자리:** 플레이어 스킬(마녀 Q 번개 일격 / 늑대 Q 할퀴기·E 덮치기)을 손패 위 가운데에서 화면 오른쪽 아래, 물약 소품과 산장 관리 버튼 사이 빈자리로 옮김. `hud.gd` `HpOverlay.SKILL_BAR_AT`(디자인 px 1246,732, 우·하 앵커)·`SKILL_GAP`·`skill_bar_center()`. 검증 `tools/verify_wolf_blood.gd` 61항목(버튼과 겹치지 않음·하단 안쪽), 실제 캡처 `tools/capture_skill_bar.gd` → `screenshots/skill-bar/`(헤드리스로 못 보는 것: 소품·버튼과의 실제 겹침).

**2026-10-18 늑대의 피·달 카드:** `scripts/game/moon_powers.gd`(blood_given·tonight·used_tonight, `block_reason()`·`use()`·`drink_blood()`→`grant_moons()`가 달 카드 3장을 주머니에 직접 넣고 `card_hand.fly_to_pocket()` 연출). 파르그의 특별 이야기는 `guest_dialogues.gd` `WOLF_STORY`(선택지 `effect`·`fail_reply`), 발동·효과는 `guest_events.gd` `wolf_story_available()`·`apply_effect()`(검은 양 `pasture.take_black_sheep()`), 거절은 `completed_stories`에 넣지 않는다. 카드 판정 `card_use_resolver.gd` `_eval_wolf_blood()`·`_eval_moon()`(늑대면 모든 카드 거부). 플레이어 `player.gd`: `suffer()`·`apply_moon()`·`set_wolf()`(마녀 몸 숨김 + `visual/wolf_visual.gd` 임시 블록아웃), `move_speed()`·`attack_interval()`·`windup_time()`, 늑대 물기 `_bite()`, `cast_claw()`/`_update_claw()`, `cast_pounce()`/`_update_pounce()`, 발밑 `moon_ring`. 키 Q·E는 `lol_controls.gd`, 스킬 바 `hud.gd` `HpOverlay._draw_wolf_skills()`(아이콘 `assets/ui/skills/`), 손패 잠금 `card_hand.gd` `wolf_locked()`. 수치 `config.gd` `MOON_*`·`WOLF_*`. 검증 `tools/verify_wolf_blood.gd` 59항목, 캡처 `tools/capture_wolf_blood.gd` → `screenshots/wolf-blood/`. [기획](../docs/wolf-blood-event-design.md).

**2026-10-18 손패 흐름 v1(낮·밤 손패·달빛 스택·태우기):** `config.gd` `CARD_PHASE`(id → day/night/both/none)·`DRAW_STACK_SIZE`·`BURN_DRAW_PER_DAY`·`BURN_CORRUPTION_HP`. `card_inventory.gd`: `phase_of()`·`current_phase()`(PREP=낮, 그 외 밤)·`eligible_pocket()`(모든 드로우의 후보), `add()`는 지금 시간대에 못 쓰는 카드를 주머니로, `phase_swap(phase)`는 반대 시간대 카드를 주머니로 보내고(묶음은 주머니 묶음에 합침) 넣은 만큼 `_draw_whole()`로 묶음째 뽑는다. 스택: `consume()`·`activate()`가 `_count_use()`, `consume_id()`는 1회, `try_stack_draw()`는 `changed` 지연 호출과 `_process`에서 대기분을 뽑는다(`stack_changed` 신호). 태우기: `burn()`·`burn_block_reason()`·`burns_today`·`on_prep_start()`. 전환 호출은 `game_session.gd` `start_wave()`(밤)·`_enter_prep()`(낮, 아침 드로우 전). 판정은 `card_use_resolver.gd` `evaluate()` 맨 앞의 모닥불 분기 `_eval_burn()`(목재·생고기 제외)과 시간대 안전장치, `commit()` `"burn"`. HUD는 `moon_hud.gd` `DrawStack`(주머니 그룹, 돌 3개)·`stack_hover` 툴팁. 전환 순차 연출: 인벤토리 `phase_swapped(out, in)` 신호 → `card_hand.gd` `_on_phase_swapped()`가 `_pending_out`(제자리 대기 후 한 장씩 주머니로)·`_pending_in`(주머니에 투명하게 숨었다가 한 장씩 가운데 공개) 대기열을 만들고 `_step_swap()`이 진행(`SWAP_OUT_STEP`·`SWAP_GAP`·`SWAP_IN_STEP`). 캡처 `tools/capture_phase_swap.gd` → `screenshots/phase_swap/`. 검증 `tools/verify_hand_flow.gd`(→ `hand_flow_check.gd`) 54항목 → `art_sources/hand-flow-verify.json`. 옛 검증은 낮에 밤 카드를 손패에 넣던 전제를 고쳤다(`pocket_check`·`occult_cards_check`·`new_cards_check`·`campfire_check`·`verify_moon_runtime`). [문서](../docs/hand-draw-flow-design-v01.md).

**2026-10-18 모닥불 연료·고기 스튜:** `scripts/world/lodge_yard.gd` 가 모닥불 연료(`fuel`, 초)를 가진다. 낮·밤·정리 중에 줄고, 0이면 불꽃·`fire_light`·불씨·타닥 소리가 꺼진다. `add_timber()`·`timber_block_reason()`·`heal_rate_at()`·링 표시값 `gauge_shown`. 카드 판정은 `card_use_resolver.gd` 의 `campfire_hit()`·`campfire_fuel`(목재)·`cook_stew`(생고기, 켜진 불만)·`stew`(`meat_stew` → `merc_at()` 한 명, 최대 체력 × `STEW_HEAL_RATIO`). 링은 `hud.gd` `HpOverlay._draw_campfire_gauge()`. 낮 회복은 `ally.gd` 의 `campfire_heal_rate()` 로 바뀌었다(예전 전역 `MERC_REGEN` 낮 회복은 제거, 산장 안 대피 회복은 유지). 다친 전투직은 `wants_campfire_rest()` 로 낮에 모닥불 자리(`yard_spot`)에서 쉰다. 수치 `config.gd` `CAMPFIRE_*`·`STEW_HEAL_RATIO`. 검증 `tools/verify_campfire.gd` 39항목 → `art_sources/campfire-verify.json`. [문서](../docs/resource-uses-expansion-v01.md).

**2026-10-18 롤식 전투 조작:** 마녀 전투를 League of Legends 방식으로 바꿨다(`scripts/game/lol_controls.gd`, `player.gd` 의 `command_attack/command_attack_move/command_stop`). **우클릭** 땅=이동(평타 대상 해제)·적=대상 지정 후 사거리까지 다가가 평타 계속, **A→좌클릭** 공격 이동(커서 아래 적 우선), **S** 정지, **Space** 카메라 복귀, **C** 사거리 표시. 평타는 선딜 0.22초(이때 이동 명령이 오면 취소·쿨다운 소모 없음)+후딜이 있고 주기는 `BOLT_INTERVAL`. 서 있을 때만 사거리 안 적을 스스로 잡고, 이동 중에는 쏘지 않는다. 적 마우스오버 시 공격 커서와 **밝은 붉은 외곽선**, 공격 대상은 **진하고 두꺼운 붉은 외곽선**(`shaders/target_outline.gdshader`, 화면 공간 두께의 반전 헐을 `material_overlay` 로 붙여 거미 IK·스킨을 따라감). 땅 좌클릭 이동과 WASD 이동은 제거(방향키 이동은 유지). [조작 정리·결정](../docs/lol-controls-v01.md). 검증 `tools/verify_lol_controls.gd` 43항목, 외곽선 렌더 캡처 `tools/capture_lol_outline.gd` → `screenshots/lol_controls/`(셰이더 실제 색·두께는 헤드리스 확인 불가).

**2026-10-18 양털 연속 수확:** 털 난 양 하나를 클릭해 깎기 시작하면 `scripts/actors/player.gd` 의 수확 체인(`harvest_chain`)이 같은 목장의 털 난 양을 **가장 가까운 순서로 차례차례** 깎는다(`harvest_plan()`, 매번 남은 양 중 최근접). 도중에 다른 털 난 양을 클릭하면 그 양부터 바로 깎고, 깎던 양은 진행을 `sheep.shear_progress` 에 남긴 채 순서로 돌아가 나중에 이어서 깎는다. 체인 중에는 HUD가 대상 양에 '수확하러 가는 중', 나머지에 '1번째·2번째…(깎다 만 양은 %)'를 띄운다. 땅 클릭·키보드 이동·밤 시작·쓰러짐이면 끝나고, 두 마리 이상 깎았으면 합계 토스트. 검증 `tools/verify_wool_chain.gd` 23항목(실제 클릭 입력 경로 포함).

**2026-10-18 감시탑:** `scripts/world/watchtower.gd` 가 감시탑 공터 하나(단계 0~2·목재 적립 `stock`·체력·붕괴 `collapsed`·사냥꾼 자리 `perched`·사다리 앞 `climb_spot()`)를 맡고 `world.towers` 에 두 곳이 있다. 목재 카드를 공터에 끌면 `card_use_resolver` 의 `tower_deposit`/`tower_repair`, 골드 건설은 관리창 `tower_left`/`tower_right`(`lodge_economy.tower_of`). 밤 사냥꾼은 `ally.gd` `TOWER_GO`→`TOWER_POST`(발판 위 고정 사격, `Cfg.TOWER_RANGE`·`TOWER_DAMAGE_MULT`), 괴물은 `watchtowers` 그룹을 표적 후보로 삼고 `foe_radius` 만큼 뺀 거리로 친다. 모델 `scripts/visual/watchtower_model.gd` 가 사용자 GLB `assets/structures/watchtower/watchtower.glb`(1·2단계가 한 메시)를 X로 나눠 배율 6.5. 수치 `config.gd` `TOWER_*`. 검증 `tools/verify_watchtower.gd` 38항목, 캡처 `tools/capture_watchtower.gd`(GLB 실제 크기·방향·칠은 헤드리스로 확인 불가) → `screenshots/watchtower/`. [문서](../docs/watchtower-v01.md).

**2026-10-18 프롤로그 모션 코믹스(4컷 레이어 적용):** `scripts/ui/prologue.gd` 가 정지 그림 4장 대신 `assets/ui/ftue/motion/cutN.json` 매니페스트의 **분리 레이어**를 설계 화면 1920×1080 위에 겹쳐 `CUTS` 타임라인(순차 등장·이동·창문 점등·룬 점등·밤 전환, 전환 T1 연기 덮기·T2 지하로 내려가기·T3 룬 섬광)으로 재생한다. 자막은 카드 종이 패널에 한 글자씩. 매니페스트·레이어가 없는 컷은 기존 `prologue_0N.png` 폴백. 레이어는 카드 화풍으로 코덱스 제작([요청서 v02](../docs/handoff/codex-prologue-motion-comics-v02.md), [기획](../docs/prologue-motion-comics-design.md)). v02에서 컷 1·2·4를 하스스톤 2.5D 시네마틱 구도(큰 전경·로우 앵글·대각선·3단 깊이)로 재기획, 카메라 틸트 트랙(`cam_tilt`)과 컷 1 연기 빛 화면 덮기 전환 추가. 네 컷 모두 레이어(44장)·매니페스트 납품·적용(컷 1 재작업 완료). 검증 `tools/verify_prologue_motion.gd` 72항목, 실제 렌더 캡처 `tools/capture_prologue_motion.gd`(레이어 알파·가산 글로우·자막 패널 겹침은 헤드리스로 확인 불가) → `screenshots/ftue/motion/cap-cut*.png`.

**2026-10-18 산장 주변 식생 구분선 C안 적용 · 산장 뒤 구석 진동 버그 수정:** `scripts/world/yard_hedges.gd` 가 구분선 중심선 11개 + 공터 테두리 3개(`BANDS`)에 시안별 단면(`PROFILES`: hedge·wedge·ridge·edge)을 얹어 나무·바위(충돌, 벌목 불가)·관목(장식)을 놓는다. 기본 `c`(바위 능선), **F7** 순환 또는 `--yard-hedge=none|a|b|c`. 산장 둘레 안쪽 풀밭 `GrassLodge`(`grass_meadow.gd`), 공터는 불규칙 다져진 자리(`lodge_yard.gd`). 내비메시 굽기 높이 y −1~1 + 장애물 충돌 최소 높이 `Cfg.OBSTACLE_MIN_HEIGHT` 1.2m 로 장애물 윗면 고립 섬 제거, `scripts/world/nav_util.gd` 의 지면·도달 가능 보정을 정찰·벌목·채집·클릭 이동이 사용, `ally.gd` 멈춤 감시. 검증 `tools/verify_rear_nav.gd` 12항목, `tools/verify_yard_hedges.gd` 85항목, 캡처 `tools/capture_yard_hedges.gd` → `screenshots/yard-hedges/`, 평면도 `tools/plot_yard_map.gd`. [문서](../docs/yard-hedge-proposals-v01.md).

**2026-10-18 판마다 바뀌는 월드 설정:** `scripts/game/world_setting.gd`가 새 판마다 주요 종족 둘을 굴리고(가중치 6:1, 주요 둘이 손님의 75%), `LodgeEconomy._roll_guest()`·`GuestProfiles.pick_guest()`가 묶음마다 가중 무작위로 손님을 고른다(고정 순서 `preferred_mercenary` 삭제). 1일차 첫 손님은 첫 주요 종족의 전투용병. 내부 설정이라 화면에 종족 이름·확률을 보여 주지 않는다(사용자 결정). `-- --world-seed=N`, `-- --world=orc,fairy`. [설계](../docs/races-guests-v01.md) · 검증 `tools/verify_world_setting.gd` 25항목.

**2026-10-18 종족 시스템 1차:** `scripts/game/races.gd` 종족 등록부(인간·드워프·요정·고블린·수인·오크 — 표시명·문장·보조색·성격 키워드)와 `scripts/ui/guest_profiles.gd` 손님 42명(인간 7 + 종족별 고용 4·여행자 3). 모든 프로필에 `race`·`race_name`·`race_accent`, 이름→종족 `GuestProfiles.race_of()`. 고용 손님 순서는 종족을 번갈아 돌며 하루 두 칸씩 넘어가(`preferred_mercenary`) 셋째 묶음 손님이 다음 날 첫 묶음에 재방문해 고용 제안을 받는다. 도착 창·대화 목록은 "종족 · 역할"을 보이고, 포트레이트 파일이 없으면 `PLACEHOLDER_PORTRAIT`(익명 실루엣, 종족색 틴트)로 뜬다. 종족 조건부 카드 효과는 아직 없다. [기획](../docs/races-guests-v01.md) · 검증 `tools/verify_races.gd` 44항목, `tools/verify_guest_roster.gd` 42명 대응.

**2026-10-18 첫 실행 플로우 보강:** 실행하면 **타이틀**(`scenes/title.tscn`, main_scene: 새 이야기·이어하기(비활성)·설정·끝내기) → **마녀 선택**(이름 없는 '마녀' 1칸, 셋은 '?' 잠김) → **프롤로그 4장**(Esc 건너뛰기) → **1일차 새벽**(첫날도 새벽 전환·새벽음) + '첫째 날' 카드·혼잣말 → 시작 손패 → 첫 판만 **브람 고용 튜토리얼**(정지·시간 제한 없음 → 계약 카드 배치). 밤 진입은 가운데 배너 하나, 패배 화면은 원인별 힌트 + `다시 도전`·`타이틀로`. `--script`로 `main.tscn`을 바로 열면 예전처럼 곧장 1일차 낮. [구현·검증](../docs/first-session-flow-review.md#9-구현-결과-2026-10-18) · 검증 `tools/verify_first_session.gd` 58항목(+idle 45) · 화면 `screenshots/ftue/`.
**2026-10-18 산장 주변 맵 A안 적용:** 산장 뒤를 **닫힌 바위 띠**(`scripts/world/rear_blocker.gd`, 충돌 + 내비 제외)로 감싸 마녀·일꾼·적 모두 산장 뒤를 지나지 못한다(묘지는 띠 안 포켓). 산장 왼쪽(-X)은 **증축 예약 눈밭** `Layout.EXTENSION_RESERVE`, 오른쪽은 목장. 앞마당에 **모닥불 쉼터**(`scripts/world/lodge_yard.gd`, 현관에서 8m, 대기 용병 16자리 `Layout.rest_slots()`), 좌우 **감시탑 건설 예약 공터 2곳**, 왼쪽 아래 **제단 건설 예약 공터 1곳**(기존 북쪽 제단은 그대로). 웨이브는 **왼쪽 숲(−21.5, 2.7)·오른쪽 숲(25.5, 4.4)** 에서 앞마당으로 들어오고, 북쪽 제단은 `PATH_SHRINE` 탐험길로만 잇는다. 근처 숲 군집 6개를 옮기고 새 길의 통행 여유에 맞춰 나무·바위 76개를 밀어냈다. 검증 `tools/verify_lodge_layout.gd` 84항목, 캡처 `tools/capture_lodge_layout.gd` → `screenshots/lodge-layout/`. [구현 기록](../docs/lodge-layout-a-implementation.md) · [인수인계](../docs/handoff/lodge-map-layout-a-v01.md).
**2026-10-17 인원·나무꾼·계약 조정:** 활동 상한 6 → 16(용병만, 숲의 괴물 하수인 제외), 묘지 8·12·16(묻힌 무덤은 고용을 막지 않음), 나무꾼 벌목 1회 목재 1개·4초·최대 10개(가득 차면 마당에서 휴식), 산장 관리 **계약** 탭에서 해지(15G 환급), 괴물은 5m 안의 적을 먼저 공격. [조정 내역](../docs/mercenary-jobs-design.md#13-2026-10-17-조정-인원묘지나무꾼계약-해지괴물-우선-공격) · 검증 `tools/verify_roster_jobs.gd` 40항목.

**2026-10-21 캐릭터 부드러운 밀어내기:** 마녀·용병·하수인·소환수·고블린·괴물·독충·들짐승·양·손님이 서로의 개인 영역(반지름 0.2~0.4m, 큰 괴물은 크기 비례)을 갖는다. 단단한 충돌 대신 겹친 만큼만 천천히(1m당 3m/s, 상한 1.2m/s) 밀어내 잠깐 겹침은 허용하고 시간이 지나면 떨어진다. 무게가 큰 쪽이 덜 밀린다(마녀 4·큰 괴물 3·손님은 밀리지 않음). 양은 울타리 밖으로 밀리지 않는다. 예전 같은 편끼리만의 밀어내기는 이것으로 통합. `scripts/actors/soft_separation.gd` · 헤드리스 `tools/verify_soft_separation.gd` 16항목.

**2026-10-17 서리 거미 — 기본 몬스터:** 사용자 모델 서리 거미가 밤의 **기본 적**이다(종류 생략 그룹·보스의 부름. 표식 개체는 계속 큰 숲의 괴물). 부품 19개 GLB를 다리 8개(3번 다리 복제로 뒷다리 한 쌍)로 자동 스키닝하고, 교대 4족 위상 보행 IK·배 스프링·머리 단속 시선·송곳니·앞다리 더듬기·공격(들었다 내리찍기)·피격·죽음(뒤집혀 다리 오므림)과 **눈꺼풀 깜빡임**(`shaders/spider_eyes.gdshader`)을 그린다. 이동은 달리다 멈칫(평균 속도 동일). `scripts/visual/spider_visual.gd` · [구현·검증](../docs/frost-spider-monster.md) · 헤드리스 `tools/verify_spider.gd` 22항목 · 영상 `screenshots/spider/spider_showcase.avi`.

**2026-10-16 카드 소모 연출 업그레이드:** 카드가 타 없어질 때 같은 연소선을 따라 **보랏빛 에디티브 글로우**(`shaders/card_burn_glow.gdshader`)가 카드 밖까지 번지고, 연소선에서 **검은 재** 조각이 떨어져 나와 위로 날린다. 소스·실행판 적용, 헤드리스 검증 `tools/verify_card_burn.gd` 18항목. [구현·검증](../docs/card-burn-vfx.md).

**2026-10-15 용병 직업 분화:** 고용한 손님은 인물별 직업 계약 카드가 된다 — **토르빈=나무꾼, 올라프=사냥꾼, 브람=전투용병, 미라=채집가**. 나무꾼은 지정한 나무를 끝까지 베고 목재를 들고 있다가 마녀가 2.2m 안에 오면 건넨다(머리 위 말풍선). 사냥꾼은 낮에 토끼·사슴을 활로 사냥하고(토끼: 가죽 또는 생고기, 사슴: 생고기 2), 밤에는 사거리 7m에서 쏜다. 전투용병은 산장 주변을 정찰하다 적이 보이면 근접 전투하고, 산장이 공격받으면 공격자를 먼저 쫓는다. 채집가는 랜드마크를 돌며 목재·고기·가죽·보물상자를 주워 저녁 20초 전에 돌아온다. 나무꾼·채집가는 밤에 산장 안으로 대피한다. **모든 나무가 벌목 대상**(높이 6m ≈ 목재 40, 다 베면 쓰러져 사라짐), 둘러싸인 나무는 지정 불가. 나무꾼 카드를 끌면 마우스 아래 나무가 황금빛 덧칠·외곽선으로 강조된다(바닥 고리 삭제). **보물상자** 카드를 땅에 놓으면 물음표 카드 3장 중 하나를 골라 **유물**(달빛 부적·화로의 온기석·고목의 심장·늑대 송곳니 목걸이·서리 여왕의 눈물)을 얻으며, 유물은 왼쪽 위 유물칸의 영구 패시브다. 생고기는 판매(5G)하거나 마녀에게 끌어 체력 +25, 토끼 가죽은 판매(7G). 활동 상한 4→6. [기획·구현·검증](../docs/mercenary-jobs-design.md) · 검증 `tools/verify_jobs.gd` 47항목 · 화면 `screenshots/jobs/`.

**2026-10-15 숲 확장 카드:** 새 게임 시작 손패에 **잠자는 가시 씨앗·목장의 검은 양**을 한 장씩 추가했다. 씨앗은 낮에 심어 밤의 가시 방책으로 키우고, 검은 양은 다음 날부터 클릭해 검은 털을 수확한다. 검은 털은 방책에 바쳐 완전 성장·강화·회복에 쓴다. [규칙·구현·검증](../docs/occult-cards-runtime.md).

**2026-10-15 손님 UI v4:** 도착 소개를 카드 바로 위로 줄이고 대사 길이에 따라 3.4~5초만 유지한다. 패널이 사라지면 초상이 산장 관리 버튼으로 이동한다. 좌상단 말풍선을 클릭해 7명과 선택형 대화를 진행하며 시설·손님·대화 기록 탭을 사용할 수 있다. 직접 연 대화는 시간을 멈추고 BGM은 이어진다. [현재 구현·조작·검증](../docs/guest-events-ui.md). 아래 v2 소개는 이전 구현 기록이다.

**2026-10-17 소리 설정:** Esc 일시 정지 메뉴에 `소리 설정` 구역 추가 — 전체·배경음·효과음 음량과 음소거. 오디오 버스는 `Background`(실내 감쇠) → `Music` → `Master`, 효과음·반복음·손님 알림음은 `Sfx` → `Master`. 검증 `tools/verify_sound_settings.gd`(헤드리스, 21항목).

**2026-10-17 디스플레이·화면 비율 정렬:** 어떤 모니터 비율(16:9·16:10·21:9 울트라와이드·32:9·4:3)에서도 정렬이 맞도록 정리. stretch는 `canvas_items + expand`(기준 1774×887)를 유지해 UI 배율은 짧은 쪽에 맞추고 남는 폭은 넓게 쓴다(3440×1440 → UI 2118×887). 가운데 펼침 화면(시작 손패·보물상자·마법서적·새벽 보상·장날)은 `scripts/ui/center_stage.gd`의 가운데 앵커 무대 위에 놓여 열린 채 F11·창 크기 변경이 일어나도 새 가운데로 따라간다(전에는 열 때의 화면 크기로 위치를 고정해 1600×800 창 → 전체 화면 전환 시 왼쪽으로 치우쳤다). 제단 창도 크기 변경 시 다시 가운데로. Esc 메뉴에 `디스플레이` 구역 — 화면 모드(창·전체 화면 테두리 없음·전용)·창 크기(모니터에 들어가는 것만)·프레임 제한·3D 해상도·수직 동기화, `user://settings.cfg` `[display]`에 저장(`scripts/visual/window_mode.gd`). 처음 실행은 전체 화면(테두리 없음), `-- --windowed`로 이번만 창 모드. 검증 `tools/verify_display.gd`(헤드리스, 7개 해상도·창 변경 중 재정렬·저장, 84항목). 실제 전체 화면 전환 결과는 헤드리스로 확인할 수 없어 `tools/capture_display.gd`로 캡처(`screenshots/display/`).

**2026-10-17 굴뚝 연기 Stable Fluids:** 산장 굴뚝 연기를 입자에서 Jos Stam의 Stable Fluids 격자 유체(반-라그랑주 이류·압력 투영 + 온도 부력·와도 보존)로 교체. 불 숨결에 따라 퍼프가 바뀌고 바람·돌풍에 휘며, 작업 스레드에서 30Hz로 풀고 셰이더가 보간한다. [구현·검증](../docs/chimney-smoke-stable-fluids.md) · 헤드리스 검증 `tools/verify_chimney_smoke.gd` 29항목 · 화면 `screenshots/chimney_smoke/`. 굴뚝 연도에 실제 구멍(테두리·그을린 안쪽·화덕 불빛)을 뚫어 연기가 그 안에서 솟아난다.

**2026-10-15 손님 다섯 명 추가:** 브람·미라에 올라프·토르빈·네리·오스윈·세라를 더해 총 일곱 초상. 실제 방문 순서와 인물별 첫인사·재방문 대사에 연결했다. [인물 목록과 등장](../docs/guest-roster.md).

**2026-10-15 손님 도착 플로팅 알림 v2:** 사용자 시안에 맞춘 배경 제거 초상·어두운 VisualShader 패널·순차 텍스트 모션. 준비 시간 5초부터 두 손님을 자동 소개한다. 게임·BGM·이동·카드·HUD를 계속 유지하며 Esc는 원래 정지 메뉴로 동작한다. [구현·에셋·검증](../docs/guest-arrival-story-ui.md).

**2026-10-14 잔디 톤 프리셋:** 흰색으로 번쩍이던 바람 마루를 명도 차이로만 보이게 바꾸고, 자연스러운 톤 4종과 이전 톤을 **F6**으로 비교한다. 기본값은 이끼 숲. [비교 화면](../docs/grass-wind.md#색-톤-프리셋-f6).

**2026-10-14 산장 주변 잔디:** 산장 주변 반경 30m 설원에 바람에 파도치는 둥근 잎 잔디 군집을 배치했다. 건물·목장·묘지·디딤돌 동선·숲길·랜드마크·나무 주변은 비우고, 마녀가 지나가면 풀이 비켜난다. 소스·배포 실행판 적용, 잔디 비용 +0.3ms. [화면·구현·검증](../docs/grass-wind.md).

**2026-10-14 용병 잔류·묘지·큰 숲의 괴물·목장 증축·목재 건축:**
- 용병은 체력이 0이 되기 전까지 남는다. 임무 뒤 산장 마당에서 쉬고, 낮에는 남은 자원 나무를 스스로 벌목하고 밤에는 산장 앞을 지킨다(낮에 초당 1 회복). 쓰러지면 산장 뒤편(목장 쪽 모서리)에 이름과 날짜를 새긴 비석이 선다. 무덤은 처음 4기까지이고 **묘지 확장**으로 6→8기로 늘린다. 남은 무덤 자리가 살아 있는 용병과 미사용 계약 카드 수 이하이면 새 고용이 막힌다.
- 웨이브의 카드 대상은 **큰 숲의 괴물**(체력 ×1.7, 크기 ×1.32, 등에 꺾인 가지, 걸을 때 잎이 떨어짐)이다. 기존 숲의 괴물은 가장 약한 기본 적이다. 카드로 소환한 하수인도 큰 숲의 괴물이며, 쓰러지거나 낮이 되면 체력이 남아 있어도 시들어 **목재 1개**가 손패에 들어온다.
- 목장은 기본 크기를 키웠다(3.2×4.0 → 3.7×4.6m, 최대 4마리). **목장 증축**으로 6→8마리까지 늘리며, 빈자리가 있으면 양을 계속 살 수 있다. 털은 마녀가 목장 문으로 들어가 양 옆에서 2.2초 동안 깎으며, 머리 위에 작은 진행 게이지가 표시된다.
- 객실 증축(60G·목재 10), 목장 증축(40G·목재 8 / 60G·목재 12), 묘지 확장(30G·목재 6 / 45G·목재 10) 등 모든 건축에 목재가 든다. 값은 `scripts/config.gd`의 `BUILD_COSTS`에 있다.
- 검증: `tools/verify_card_core.gd` 51항목 통과, 화면은 `screenshots/v25-updates/`. 카드 원화에 인쇄된 문구("작업을 마치면 귀가합니다")는 아직 예전 규칙 그대로다.

**2026-10-14 배경 군집 재배치:** 격자 숲을 제거하고 길을 따라 40개 구성 군집을 연결했다. 바위·나무·고목·하층 식생 15종을 높이와 각도로 나누고, 굽은 길과 열린 공터로 리듬을 만들었다. [실제 전후 화면·편집 원본·이동 검증](../docs/forest-composition.md).

**2026-10-14 최종 기본 조합 확정:** 사용자 지정 화면대로 새 실행은 **강렬한 툰 · 심야 + 넓은 원근 34° + 극적인 공기**로 시작한다. 주변 조명색을 반영하는 공기 효과도 활성화한다. 소스와 배포 실행판에 적용했다. F2/F3/F5 비교 메뉴는 유지한다. 아래의 이전 기본값 표기는 당시 기록이다.

**2026-10-14 외곽 바닥 텍스처:** Juggernaut Wars의 핸드페인팅을 참고한 눈밭·돌길·이끼 서리 텍스처를 모든 외곽 숲과 랜드마크까지 적용했다. [실제 전후 화면·에셋·검증](../docs/painted-ground.md).

**2026-10-14 공기 원근 적용:** 가까운 프랍·산장·플레이어는 선명하게 남기고, 먼 숲의 대비와 채도를 청보라색 공기층으로 낮춘다. **극적인 공기**가 기본이다. 오른쪽 위 **공기 원근 / F5**에서 없음·은은한 공기·극적인 공기를 독립 선택하며, 플레이어 추적·줌·렌즈 변화에 맞춰 거리를 보정한다. 소스·배포 실행판 적용, 165조합과 실제 거리별 렌더 검증 통과. [전후 화면·검증](../docs/aerial-perspective.md).

**2026-10-14 플레이어 탐색 적용:** 마녀 추적 카메라, WASD/방향키 이동, 휠 줌, 작은 지도 클릭 이동을 적용했다. 숲 경계를 반경 **16→38m**로 넓히고 벌목터·돌 제단·야영지·전망터와 연결 숲길을 추가했다. **C** 마녀 보기 / **H** 산장 복귀 / **F4** 산장 전체뷰. [화면·조작·검증](../docs/player-exploration.md).

**2026-10-14 Blender 자연물 키트:** 단품 21종과 조합 5종을 `scenes/props/nature/`에 추가하고 기존 숲·바위·관목·통나무의 시각 모델에 연결했다. `nature_showcase.tscn`을 열어 F6으로 조합을 확인한다. 편집 원본은 `art_sources/nature_kit.blend`. [배치 방법·미리보기·검증](../docs/nature-prop-kit.md).

**2026-10-14 카메라 프리셋 추가·조합 메뉴 분리:** 오른쪽 위 **셰이딩(F2)**과 **카메라(F3)** 메뉴를 따로 제공한다. 약한 원근 18°·균형 원근 26°·넓은 원근 34°·높은 전략뷰 26°와 기존 직교뷰, 총 5종을 11개 셰이딩과 자유롭게 조합한다. 소스·배포 실행판에 적용했고 55조합·클릭 이동·카드 대상 선택을 검증했다. [실제 화면·조작·검증](../docs/camera-presets.md).

**2026-10-14 강렬한 툰 + 색광 조합 추가:** **강렬한 툰 · 네온**(`toon_neon`)과 **강렬한 툰 · 심야**(`toon_midnight`)을 소스·배포 실행판에 추가했다. 강렬한 툰의 2단 명암·텍스처 정리·윤곽 음영을 유지하면서 부드러운 분홍/파랑 국소광을 결합한다. 화면 스타일 메뉴 / F2로 총 11종 비교. [실제 화면·검증](../docs/reference-lighting-presets.md#강렬한-툰과-결합).

**2026-10-14 레퍼런스 라이팅 2종 추가:** **네온 달빛**(`neon_moon`)과 **심야 마법**(`midnight_magic`)을 소스와 배포 실행판에 적용했다. 오른쪽 위 화면 스타일 메뉴 / F2로 총 9종을 전환한다. 기존 기본값은 강렬한 툰 셰이딩이다. [실제 실행 화면·검증·구현 위치](../docs/reference-lighting-presets.md).

**2026-10-14 기본 셰이딩 확정:** 소스와 `build/WitchsLodge.exe` 실행판의 새 실행 기본값을 **강렬한 툰 셰이딩**으로 고정했다. 비교용 7종과 F2는 유지한다. [실제 배포판 화면에 합성한 UI 아트 시안 3종](../docs/ui-style-concepts-v01.md). 시안 UI는 검토용 이미지이며 현재 조작 HUD를 교체한 것은 아니다. 아래 2026-10-13의 부드러운 기본값 표기는 당시 기록이다.

**2026-10-13 화면 프리셋 적용 완료:** 기본 소스와 배포 실행파일에 부드러운 명암(기본)·따뜻한 산장·차가운 숲·툰 셰이딩·강렬한 툰 셰이딩·두꺼운 툰 외곽선·기존 화면 7종을 적용했다. 오른쪽 위 **화면 스타일** 메뉴 또는 **F2**로 바꾼다. 이미 켜둔 게임은 다시 실행하면 새 프리셋이 나타난다. [실제 화면·검증 기록](../docs/screen-style-presets.md).

**2026-10-14 카드 코어 C0 적용:** [카드 코어 기획 v0.3](../docs/kingdom-integration-design.md)의 하단 손패·드래그 사용·창고, 손님 고용 계약, 벌목/전투 용병, 양털 생산·수확·판매, 표식 괴물 카드·하수인을 실행판에 넣었다. 카드를 끌어 나무·지면·적·산장에 놓고, 털 난 양과 고용을 기다리는 손님은 클릭한다. 시작 골드는 40G다. [구현 기록·조작·검증](../docs/card-core-c0-implementation.md). 아래 기존 조작·120G 공물은 그대로 유지된다.

[인수인계 문서](../docs/godot-prototype-handoff.md)의 첫 프로토타입 범위(방문 → 골드 → 객실 1회 증축 → 일반 방어 → 큰 웨이브 → 용 소환 → 시연 완료)를 한 장면으로 구현했다. 본채·증축·환경 프랍·양·마녀·여행자·괴물·용은 19개 GLB로 교체했다. 실행 데이터는 v23이다. [원화와 실제 렌더 비교 및 남은 차이](../docs/art-refinement-progress.md)를 확인한다. 원화에 맞추는 작업은 진행 중이다.

![원화와 실제 렌더 비교](screenshots/art-refinement/comparison-v23.png)

## 실행

- **엔진: Godot 4.7.2-stable**(표준 또는 Mono 빌드 모두 가능, 스크립트는 GDScript). 다른 버전으로 열지 않는다.
- **렌더러: Forward+**. 문서는 Compatibility를 출발안으로 제안했지만, 원화의 라이팅에 필요한 부드러운 그림자(PCSS), SSAO, HDR 글로우, 인스턴스 셰이더 파라미터를 쓰기 위해 Forward+로 확정했다. 저사양 PC에서 문제가 생기면 SSAO와 그림자 품질부터 낮춘다.
- Godot에서 `godot/project.godot`를 열고 F5를 누른다. 창 크기 1600×800, 기준 뷰포트 1774×887.

| 입력 | 동작 |
| --- | --- |
| F11 | 전체화면 ↔ 창모드. 일시 정지·메뉴 중에도 전환, 마지막 전체 화면 모드로 복귀하고 창 모드는 고른 창 크기로 모니터 가운데에. 설정은 저장됨 |
| 우클릭(지면) / 우클릭(적) | 롤식: 땅이면 이동(평타 대상 해제), 적이면 그 적을 대상으로 사거리까지 다가가 평타 계속. 털 난 양 우클릭도 수확 |
| A → 좌클릭 | 공격 이동: 그 지점으로 가며 만나는 적을 자동 공격(커서 아래 적이 있으면 그 적 우선). A 대기 중 우클릭·Esc는 취소 |
| S / Space / C | 정지(이동·평타 취소) / 카메라를 마녀에게 복귀 / 공격 사거리 표시 켜기·끄기(A 대기 중에도 표시) |
| 방향키 | 화면 방향 기준 이동(WASD 이동은 롤 A·S와 겹쳐 제거). 키보드 조작은 이동·평타 명령을 취소 |
| 휠 | 줌 (12–28m) |
| 작은 지도 좌클릭 | 먼 탐색 지점으로 이동 |
| H / F4 | 산장 정문으로 이동 / 추적↔산장뷰 |
| 좌클릭(지면) | 아무것도 하지 않음(롤과 같음). 좌클릭은 UI·카드 드래그·양 수확·손님 고용·산장/제단 열기용 |
| 좌클릭(산장) / `산장 관리` 버튼 | 준비 시간에 관리 패널 열기(여는 동안 시간 정지) |
| `용에게 공물 — 120G` | 전투 중 용 소환(시간은 멈추지 않음) |
| Esc | 일시 정지 메뉴(지도·화면 설정·디스플레이·소리 설정·조작법) |
| Esc → `디스플레이` | 화면 모드·창 크기·프레임 제한·3D 해상도·수직 동기화. 즉시 반영되고 `user://settings.cfg` `[display]`에 저장 |
| Esc → `소리 설정` | 전체·배경음(음악·환경음)·효과음 음량 0~100% 슬라이더와 음소거. 즉시 반영되고 `user://settings.cfg` `[audio]`에 저장 |
| F1 | 디버그 메뉴(골드, 웨이브 즉시 시작, 용 강제 소환, 피해, 전체 처치, 적 경로·공격 지점 표시) |
| F2 / 오른쪽 위 셰이딩 | 셰이딩·라이팅 프리셋 전환. 카메라는 유지, 일시 정지 중에도 가능 |
| F3 / 오른쪽 위 카메라 | 렌즈·시점 프리셋 전환. 셰이딩은 유지, 일시 정지 중에도 가능 |
| F5 / 오른쪽 위 공기 원근 | 없음·은은한 공기·극적인 공기 전환. 카메라·셰이딩은 유지 |
| F12 | 손패 고민 시간 멈춤 → 거의 멈춤 → 끔. 손패 카드에 손을 올리거나 끌고 있는 동안 세상이 1초에 걸쳐 천천히 멈추고(거의 멈춤은 1/40 속도) 손을 떼면 0.35초 만에 돌아온다. 손패·연출·소리·카메라는 실제 시간으로 움직인다. 일시정지 메뉴 '화면 설정' 에서도 고르며 `user://settings.cfg` `[cards] hand_time` 에 저장([docs/hand-focus-time.md](../docs/hand-focus-time.md)) |
| F8 | 카드 언어 한국어 ↔ English(제목 Fraunces·본문 Alegreya, [docs/card-text-runtime.md](../docs/card-text-runtime.md)). 타이틀·일시 정지 중에도 가능, 보이는 카드가 바로 바뀌고 `user://settings.cfg` `[cards]`에 저장. HUD·메뉴·툴팁·대사·HUD 이미지 글자까지 함께 영문·Alegreya 로 바뀐다([docs/english-ui-runtime.md](../docs/english-ui-runtime.md)) |
| F6 | 잔디 색 톤 전환(이끼 숲·겨울 마른풀·황혼 세이지·깊은 상록·서리 청록) |
| Shift+F6 | 풀 모양 전환(잎 포기 손그림 잎 ↔ 이전 주걱 잎 카펫). 실행 인자 grass_shape=classic 으로 이전 풀로 시작 |

### 실행파일 다시 만들기

게임 실행파일은 프로젝트 루트의 `WitchsLodge.exe` 하나다(2026-10-18 통일). 게임 데이터 pck를 exe 안에 넣고 `icon.ico`를 아이콘으로 쓴다. 게임을 고칠 때마다 다시 내보낸다.

```text
godot --headless --path . --export-release "Windows Desktop" ../WitchsLodge.exe
```

`--export-pack`만으로는 exe가 갱신되지 않는다. `build/`에는 이전 pck 백업과 웹판만 남긴다. 아이콘 그림은 `tools/build_app_icon.gd`로 다시 만들고 `tools/verify_app_icon.gd`로 검증한다.

## 라이팅 — 현재 방식

프랍·밀도는 승인 원화 04, 숲의 어둠은 후속 수정본 07을 비교 기준으로 삼는다. 지면은 기준 카메라로 투영한 클린 플레이트이며 앰버색 공간 마스크를 실제 국소광과 혼합한다. 무광 프랍에는 디퓨즈 아틀라스·실제 조명·약한 보조광을 사용한다. 얇은 눈은 셀프 섀도 얼룩을 줄이기 위해 그림자를 받지 않는다. [방식과 제한](../docs/art-refinement-progress.md)에 자세히 기록했다.

- `shaders/painted_prop.gdshader`, `painted_snow.gdshader`: 무광 페인터리 디퓨즈, 넓은 확산광, GLB 양면 표시 유지.
- `shaders/painted_ground.gdshader`: 두 숲길·보라/청록 어둠의 지면 이미지와 따뜻한 공간 색 마스크.
- `scripts/visual/painted_models.gd`: GLB 연결과 재질 설정, 산장 주변 실제 국소광.
- `scripts/world/world.gd`: 달빛·주변광·그림자·성긴 눈. 굴뚝 연기는 `scripts/visual/vfx/chimney_smoke.gd`(Stable Fluids).
- `shaders/post_grade.gdshader`: 약한 가장자리 색 보정.

## 구조(문서 11절 대응)

| 책임 | 파일 |
| --- | --- |
| 상태·승패·타이머 `GameSession` | `scripts/game/game_session.gd` |
| 웨이브·출현 예약 `WaveDirector` | `scripts/game/wave_director.gd` |
| 숙박·골드·구입 `LodgeEconomy` | `scripts/game/lodge_economy.gd` |
| 이동·공격·피해 `Player`, `Monster` | `scripts/actors/player.gd`, `monster.gd`, `magic_bolt.gd` |
| 양 `Pasture`, `Sheep` | `scripts/world/pasture.gd`, `scripts/actors/sheep.gd` |
| 용 `DragonDefense`, `Fireball` | `scripts/dragon/` |
| 입력·표시 `HUD` | `scripts/ui/hud.gd`, 입력은 `scripts/main.gd` |
| 환경 `World` | `scripts/world/world.gd`, 배치값 `layout.gd`, 본채 `lodge.gd` |
| 밸런스 수치 | `scripts/config.gd` (문서의 초기 설계 값 그대로) |
| GLB 모델·재질·효과 | `scripts/visual/` (게임 판정과 분리) |

## 검증한 것

- `scripts/visual/day_cycle.gd`: 기존 준비 타이머 90초에 연동한 낮·오후·노을·황혼·밤 라이팅. 전투는 선택한 화면 프리셋의 기존 밤 값과 일치하며, 다음 준비는 12초 동안 새벽 전환. 셰이딩 단계·카메라는 별도.
- `scripts/visual/fog_of_war.gd`, `shaders/fog_of_war.gdshader`: 마녀의 장애물 시야, 산장·아군 시야, 탐색 기억을 월드 좌표 마스크로 합성. 숨겨진 적의 지도·체력·카드 대상 표시도 차단. 기존 공기 원근의 범위·밀도·곡선은 유지.
- `tools/verify_day_and_fog.gd`: 실제 렌더링·밤 기준값·타이머 연동·전환 연속성·시야 차단·탐색 기억·적 숨김·독립 토글·일시 정지 검증. 비교 실행 인자 `--time=day|sunset|dusk|night`, `--fow=off`.
- 전장의 안개 분위기는 `옅은 설무`(기본), `라벤더 안개`, `달빛 몽환` 세 가지. 실제 시야 판정과 별개로 안개 표시를 6~11m 너비로 흐리고, 검은 차폐 대신 지형을 읽을 수 있는 색의 베일을 합성한다. `--fow-style=snow_mist|lavender|moon_haze` 또는 Esc 화면 설정에서 선택. `tools/preview_fog_presets.gd`는 새 안개 세 종류만 현재 기본 카메라·셰이딩에서 비교 캡처한다.

- `tools/run_autoplay.gd` 자동 플레이(헤드리스): 준비 1에 30G씩 3회(90G) → 증축(30G 남음) → 준비 2에 45G씩 3회(135G) → 웨이브 2·3에 공물(연속 2회 클릭에도 1회만 차감) → 3웨이브 정리 후 **시연 완료**(약 5.8분).
- `-- --idle` 옵션(아무 조작 없음): 웨이브 1에서 산장 파괴로 **게임 오버**.
- 화면 캡처: `screenshots/`의 시작, 손님 도착, 전투, 용, 증축 장면.

```text
godot --headless --path . --script res://tools/run_autoplay.gd
godot --path . -- --shot=out.png --scenario=dragon   # start|guests|combat|dragon|extension|panel
```

## 원래 제안과 달라진 점과 남은 조정

- **카메라 하향 각도 50°**: 문서의 65~70°는 블록아웃 시작값이었고, 원화의 나무 옆면과 산장 벽이 보이는 정도에 맞춰 50°로 조정했다(직교, 수평 35°, size 21). `layout.gd`에서 바꿀 수 있다.
- 마녀는 가독성을 위해 시각 모델만 1.3배(모자 포함 약 1.6m)로 키웠다. 충돌 크기는 그대로다.
- 웨이브 1에서 마녀가 움직이지 않으면 약 40초 만에 산장이 무너진다(몬스터 4마리가 초당 10 피해). 문서 9절대로 플레이테스트 후 출현 간격이나 산장 목표 수부터 조정할 것.
- 환경·본채·증축·마녀·양·여행자·몬스터·용은 실제 GLB다. 원화에 맞는 실루엣·표면·비례 조정은 계속 진행 중이다.
- 내비메시는 걷는 면보다 0.5m 위에 구워지므로 바닥 충돌을 0.5m 내려 두었다(`world.gd` 주석 참고).
