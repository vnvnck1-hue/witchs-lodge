# 사운드 빠진 항목 목록 v01 (2026-10-18)

기준: 코드에서 실제로 소리를 부르는지(`Sfx.play`·`sounds.play/voice/loop`)와 `godot/assets/audio/selected.json`의 등록 이벤트를 맞춰 봤다.
코드가 부르는 이벤트는 모두 파일이 있다. 빠진 것은 **소리를 부르는 코드 자체가 없거나, 이름별 목소리 파일이 없는 경우**다.

## 1. 새 종족 손님 목소리 — 35명 전원 없음

> **2026-10-18 해결:** 35명 × 4개 목소리를 만들어 적용했다 → [output/audio-guest-voices-v02](../output/audio-guest-voices-v02/README.md) (검증 54/54, 2026-10-18 사용자 승인 — 전부 적용).

`sounds.voice(profile)`는 `voice_<손님id>` 이벤트를 찾는다. 등록된 목소리는 인간 7명(bram·mira·olaf·torbin·neri·oswin·sera)뿐이다.
새 종족 손님은 도착 인사(`guest_arrival.gd:291`)와 대화 넘김(`guest_interactions.gd:378, 392`)에서 대체음이 없어 **무음**이고, 대화 열기(`:335`)만 `talk_open`으로 대신한다.
인간 손님처럼 한 명당 짧은 말소리 4개(`voice-<id>-01~04.wav`)가 필요하다.

| 종족 | 말투(races.gd) | 손님(id) |
|---|---|---|
| 드워프 | 짧고 단단함, 사물 품평 | 하랄(harald)·브륀힐드(brynhild)·토르그림(thorgrim)·두르가(durga)·오르무(ormu)·케틸(ketil)·시그뉘(signy) |
| 요정 | 수수께끼·비유, 존댓말 반말 섞임 | 티슬(thistle)·틸리아(tilia)·라르크(larch)·페른(fern)·윌로우(willow)·핍(pip)·니벨(nivel) |
| 고블린 | 빠른 수다, 값·숫자 | 그라즈(graz)·피클(pikl)·러스크(rusk)·타크(tak)·니브(nib)·그릭(grik)·말라(mala) |
| 수인 | 늑대 과묵·여우 능청·토끼 조급 | 파르그(fargh)·사야(saya)·우르소(urso)·모미(momi)·루카(luka)·타스(tass)·셀렌(selen) |
| 오크 | 크고 직설적, 음식 권함 | 가로크(garok)·크라냐(kranya)·모가(moga)·샤가(shaga)·울마(ulma)·바르두(bardu)·에쉬카(eshka) |

종족 공통 소리(종족 등장음·종족 표식)도 따로 없다.

## 2. 새 콘텐츠 중 소리를 부르는 코드가 없는 것

| 콘텐츠 | 파일 | 현재 상태 |
|---|---|---|
| 프롤로그 모션 코믹스 | `scripts/ui/prologue.gd` | 컷 전환·넘김·건너뛰기·장면 분위기 모두 무음 |
| 반딧불이 떼 카드 | `scripts/actors/firefly_swarm.gd` | 놓을 때·지속(반복음)·흩어질 때 무음(카드 사용 공통음만) |
| 마녀의 제단 | `scripts/world/altar.gd` | 해금(문양)·복구(촛불)·제단 반복음 무음. 창 열기만 `altar_panel.gd`에서 남 |
| 탐험 랜드마크 | `scripts/world/exploration.gd`, `scripts/ui/exploration_map.gd` | 랜드마크 발견·지도 열기/표시 무음 |
| 손패 작업대(달 UI) | `scripts/ui/moon/hand_workbench.gd` 외 `moon/*` | 자체 소리 없음(카드 동작음은 `card_hand.gd`가 냄) |
| 여행자(숲길 손님) | `scripts/actors/traveler.gd` | 걸음·입실·퇴장 무음 |
| 종족 직업 계약 카드 | `contract_director.gd` | 공통음(`chop_done`·`mon_drop`)만, 종족별 차이 없음 |
| 세계 설정(판마다 우세 종족) | `scripts/game/world_setting.gd` | 플레이어에게 숨김 — 소리 불필요 |

## 3. 공통음으로 때우고 있는 것(전용음 후보)

- 야생동물 토끼·사슴: `animal_flee`·`animal_hurt` 하나를 같이 씀.
- 몬스터 거미·벌레·광신도·보스: `mon_spawn/hit/die/attack` 공통(벌레만 `insect_*`, 서리 거미 폭발만 `frost_burst`).
