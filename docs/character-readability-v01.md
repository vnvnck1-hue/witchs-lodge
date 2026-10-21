# 캐릭터–배경 분리 시험 v01 (2026-10-21, 사용자 비교 대기)

**문제:** 보라 옷의 마녀가 보라 설원 위에 서 있어 색상이 같은 계열이다. 실제 그림자가 몸통과 같은 명도(약 60)라 실루엣이 그림자에 붙는다.
측정 기준 화면은 `godot/screenshots/characters/witch_north/ingame-idle.png`.

**리서치 근거:** Dota 2 명도 계층, TF2 림라이트(Valve GDC 2008), Hades·Don't Starve 외곽선, Diablo 캐릭터 빛.

## F10 토글(기본값: 기존)

| 단계 | 내용 |
|---|---|
| 기존 | 변경 없음 |
| ① 림·외곽선 | 캐릭터 메시에만 어두운 1.3px 외곽선(처음 1.8px)(`target_outline`)과 위쪽 가장자리 앰버 림(`character_rim`, 2026-10-21 카툰 띠로 변경 — 문턱값으로 자른 한 단 띠, 비교 `rim-toon-compare.png`)을 `material_overlay` 로 건다 |
| ①+② 발밑 그림자 | 캐릭터의 실제 그림자를 끄고 몸보다 밝은 푸른 둥근 그림자(`blob_shadow`)를 깐다. 디딤돌에 묻히지 않게 카메라 쪽으로 0.35m 당겨 그린다 |
| ①+②+③ 강조색 | 주인공(마녀) 랜턴에 앰버 빛망울과 점광원(에너지 0.6, 범위 2m)을 단다 |

- 대상: 그룹 `readable_characters`(플레이어·손님·아군). 강조 빛은 그룹 `readable_lead`(플레이어)에만 단다. 적은 기존 롤식 붉은 외곽선을 쓰므로 제외한다.
- 코드: `godot/scripts/visual/character_readability.gd`. 선택값은 `user://settings.cfg [visual] readability` 에 저장되고, `--readability=<id>` 인자로도 줄 수 있다.
- 검증: `tools/verify_character_readability.gd`(헤드리스 19/19).
- 캡처: `tools/capture_character_readability.gd` → `godot/screenshots/character-readability/`(단계별 전체 화면 + `compare-sheet.png`).
  창을 띄워 캡처한 이유: 외곽선·림·그림자·빛의 실제 색과 블렌딩은 헤드리스로 확인할 수 없다.
- 시행착오: 둥근 그림자를 `render_priority -1` 로 두면 화면에 그려지지 않았다. 지금은 1이다.

**다음 결정:** 사용자가 단계를 고르면 기본값으로 정한다. 그때 외곽선 두께, 림 세기, 그림자 진하기를 조정한다.
