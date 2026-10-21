# 화염 VFX (FireVfx)

2026-10-21. 사용자 레퍼런스: Unity VFX Graph `FX_Fire_Scalable` 그래프와, 그 최종 모습인 세 불(빨강+남색 연기 / 초록+자홍 연기 / 청록+보라 연기).
그래프 구성(불꽃·연기 시스템 + 불티 시스템, Size·Puffiness·Spawn Amount·Cinders On·색 그라디언트 노출, "Scale VFX" 비례 스케일)을 Godot 로 옮겼다. 표시 전용이며 게임 판정·진행 값은 바꾸지 않는다.

## 구조

| 파일 | 역할 |
| --- | --- |
| `godot/scripts/visual/vfx/fire_vfx.gd` | `FireVfx`(Node3D, `@tool`). GPUParticles3D 세 겹 + 선택 불빛. 노출 파라미터와 프리셋 |
| `godot/shaders/vfx/fire/fire_flame.gdshader` | 불꽃. premultiplied(일부 가산) — 흰 심지 → core → mid → edge 로 식으며 노이즈에 깎여 덩어리로 흩어짐 |
| `godot/shaders/vfx/fire/fire_smoke.gdshader` | 연기. 반투명 — 불빛 받은 tint → smoke 색, 2톤 결, 소프트 입자·카메라 근접 페이드 |
| `godot/shaders/vfx/fire/fire_cinder.gdshader` | 불티. 가산 — 또렷한 심지 + 번짐, 깜빡임 |
| `godot/shaders/vfx/fire/fire_common.gdshaderinc` | 입자 빌보드, 값 노이즈/fbm, 몽글 마스크, 소프트 깊이 |

텍스처는 쓰지 않는다(모양은 셰이더 노이즈). 그리기 순서는 연기 < 불꽃 < 불티(`render_priority`).
`INSTANCE_CUSTOM`: x 회전, y 수명 비율, z 입자별 무작위(`anim_offset` 0~1).

## 파라미터 (레퍼런스 노출값 대응)

| FireVfx | 레퍼런스 | 설명 |
| --- | --- | --- |
| `size` | Size | 반경·속도·중력·입자 크기·소프트 거리·불빛 범위를 함께 곱한다 |
| `puffiness` | Puffiness | 노이즈로 깎는 깊이 → 덩어리 분리 |
| `spawn_amount` | Spawn Amount | 세 겹 입자 수 배율(바뀔 때만 `amount` 를 넣어 재시작을 피함) |
| `cinders_on` | Cinders On | 불티만 켜고 끈다 |
| `core/mid/edge_color` | Color Over Life | 불꽃 그라디언트 |
| `smoke_color`, `tint_color` | (연기 색) | 식은 연기 / 불빛 받은 연기 |
| `cinder_color` | Cinders Color | 불티 색 |
| `preset` | — | `hearth`(빨강) · `toxic`(초록+자홍) · `arcane`(청록+보라) · `witch`(보라) |
| `intensity` | — | 0~1 불 세기(생성 비율·불빛) — 모닥불 연료에 연결 |
| `lit` | — | 끄면 새 입자만 멈추고 남은 입자는 자연스럽게 사라짐 |
| `wind` | (Vector Field) | 연기·불티를 눕히는 바람. 매 프레임 바꿔도 재시작 없음 |
| `with_light` | — | 모듈 OmniLight(깜빡임) 사용 여부 |

## 게임 적용

- 앞마당 모닥불(`scripts/world/lodge_yard.gd`): 예전 원기둥 불꽃 3개와 풀 입자 불씨를 `FireVfx`(hearth, size 0.85)로 바꿨다.
  연료 비율 → `intensity`, 꺼짐 → `lit=false`, `WeatherVfx.wind_vector()` → `wind`(0.25초마다). 불빛은 기존 `fire_light` 가 계속 맡는다(`with_light=false`).
- 다른 곳에 쓸 때: `var f := FireVfx.new(); f.preset = "toxic"; f.size = 1.2; parent.add_child(f)`.

## 검증

- 헤드리스: `.tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_fire_vfx.gd` — 모듈 구성·프리셋·size 비례·생성량·불티·세기·바람 + 모닥불 연결(29/29).
  기존 `verify_campfire.gd`(39/39)도 새 화염 기준으로 고쳤다.
- 렌더 캡처(셰이더 컴파일·블렌딩·글로우·입자 모양은 더미 렌더러로 볼 수 없어 창으로 찍음):
  `tools/capture_fire_vfx.gd` → `godot/screenshots/fire_vfx/`(레퍼런스 구도의 프리셋 비교, 크기·덩어리, 마녀불·불티 끔·약한 불),
  `tools/capture_campfire.gd` → `godot/screenshots/campfire/`(게임 속 낮·밤 모닥불).
