# 산장 굴뚝 연기 — Stable Fluids

2026-10-17. 기존 `GPUParticles3D` 난류 입자 연기를 Jos Stam의 **Stable Fluids** 격자 유체로 교체했다.

## 구조

| 파일 | 역할 |
| --- | --- |
| `godot/scripts/visual/vfx/stable_fluid.gd` | 2D 유체 해법(순수 로직, 렌더링 없음) |
| `godot/scripts/visual/vfx/chimney_smoke.gd` | 게임 노드 `ChimneySmoke`: 입력(불 숨결·바람), 작업 스레드 실행, 텍스처 업로드, 판 방향 |
| `godot/shaders/chimney_smoke.gdshader` | 밀도장 → 연기 색·투명도(시간 보간, 결 노이즈, 자기 그림자) |
| `godot/scripts/world/world.gd` `_build_fx()` | `ChimneySmoke`를 `Layout.CHIMNEY_TOP`에 두고 `weather_vfx`(바람)·카메라를 연결 |
| `godot/scripts/visual/user_cottage.gd` `open_flue()` | 산장 GLB의 막힌 연도 윗면을 잘라 구멍(테두리·안쪽 벽·그을린 바닥)을 낸다 |
| `godot/shaders/chimney_flue.gdshader` | 연도 안쪽: 그을린 돌 정점색 + 바닥 쪽 은은한 화덕 불빛, 산장과 같은 빛·색 공기 |

## 해법 (stable_fluid.gd)

Stam 1999 / 2003("Real-Time Fluid Dynamics for Games")의 격자 방식 그대로, `(nx+2)×(ny+2)` 격자(가장자리 1칸은 경계)에 속도 `u,v`·밀도·온도를 둔다. 한 단계:

1. **속도 이류**: 반-라그랑주 역추적 + 쌍선형 보간(무조건 안정).
2. **힘**: 온도 부력(`buoyancy·T − weight·ρ`), 위로 갈수록 센 바람(지붕이 굴뚝 바로 위를 가린다고 보고 아래는 약하게), Fedkiw·Stam·Jensen(2001) **와도 보존**(작은 소용돌이 유지).
3. **압력 투영**: 발산 계산 → 압력 푸아송 방정식을 Gauss-Seidel(SOR 1.65, 10회)로 풀고 기울기를 빼서 비압축성으로. 압력은 다음 단계 초기값으로 재사용(warm start)해 적은 반복으로 수렴.
4. **밀도·온도 이류**, 지수 감쇠(냉각·소산). 선택적으로 Stam `lin_solve` 확산.

경계: 바닥은 벽(수직 속도 반사)이고 **굴뚝 입구 칸만 유입구**(속도·밀도·열이 경계값으로 들어옴, 가운데가 빠른 포물선 분포). 위·양옆은 열린 경계(압력 0, 연기는 빠져나가고 옆 공기는 빨려 들어옴) — 그래서 연기가 격자 안에 고이지 않고 정상상태가 된다.

## 게임 연결 (chimney_smoke.gd)

- 격자 40×56칸, 칸 0.11m → 굴뚝 위 4.4m × 6.2m 세로 판. 입구는 9~12칸(바람이 부는 화면 오른쪽에 여유).
- **불 숨결**: 느린 노이즈로 뿜는 세기(퍼프 0.35~1.2)와 좌우 흔들림을 매 단계 바꾼다.
- **바람**: `WeatherVfx.wind_vector()`를 판 가로축(카메라 오른쪽의 수평 성분)에 투영해 칸/초로 넣는다. 돌풍·밤 눈보라 때 연기가 눕는다.
- **실행**: `WorkerThreadPool`에서 30Hz로 한 단계씩(데스크톱 기준 약 7ms/단계, 메인 스레드 비용 없음). 시작 시 2.5초를 미리 돌려(역시 스레드) 처음부터 피어오른 상태로 서서히 나타난다.
- **그리기**: 밀도 배열을 그대로 `FORMAT_RF` 이미지로 올리고(복사 루프 없음), 셰이더가 직전/현재 두 장을 보간해 매 프레임 부드럽게 움직인다. 판은 세로축을 고정한 채 카메라 쪽으로 돈다.
- **셰이더**: 위로 흐르는 노이즈 두 겹으로 격자보다 작은 결을 더하고, 위쪽 밀도를 몇 번 더 읽어 자기 그림자를 흉내 낸다. 색은 굴뚝 불빛의 복숭아색 → 크림빛 흰색 → 라벤더. 판 가장자리는 부드럽게 사라진다.
- 일시 정지 중에도 계속 피어오른다(`PROCESS_MODE_ALWAYS`, 기존과 같음). 굴뚝 불씨(`weather_vfx._lodge_life`)는 그대로 둔다.

## 검증

- 헤드리스: `tools/verify_chimney_smoke.gd` **29항목**(아래 연도 구멍 8항목 포함) — 유한성, 투영 후 평균 |∇·u| < 속도의 1%, 부력 상승, 바람 양방향 휘어짐, dt=0.5(15배)에서도 안정, 와도 세기에 따른 소용돌이 증가, 열린 경계 정상상태, 입구를 닫으면 빠져나감, 노드 위치·셰이더·바람 연결, 작업 스레드 진행, 텍스처 업로드, 카메라 방향, 단계 비용.
  ```text
  .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_chimney_smoke.gd
  ```
- 실제 렌더 캡처: `tools/capture_chimney_smoke.gd` → `godot/screenshots/chimney_smoke/`(전체, 0.5초 간격 연속 6장, 강풍 1장). 이유: 반투명 합성·깊이 안개 속 연기 색과 모양은 헤드리스 더미 렌더러로 확인 불가.
- `verify_user_cottage.gd -- --packed`의 "smoke at actual chimney" 통과(노드 이름·위치 유지).

## 조정 손잡이

`chimney_smoke.gd` `_ready()`의 `buoyancy`(상승 힘) · `cooling`(얼마나 높이 오르나) · `vorticity`(소용돌이) · `dissipation`(얼마나 빨리 옅어지나), `_breathe()`의 퍼프·흔들림, 셰이더 `opacity`·`max_alpha`·`detail_strength`·색 uniform.

## 굴뚝 연도 구멍 (2026-10-17 추가)

원본 GLB의 굴뚝은 돌 머리(판석) 위 갈색 연도 블록(x 0.99–1.42, z 1.07–1.51, y 4.68–5.20)의 윗면이 막혀 있었다.
`UserCottage.open_flue()`가 불러올 때 메시를 고친다(GLB 파일·UV·텍스처는 그대로).

- 윗면(y≈5.20, 굴뚝 중심 ±0.25m 안의 위쪽 삼각형 2개)을 surface 0에서 뺀다.
- 같은 자리에 두께 0.055m 테두리(원래 윗면과 같은 페인트 UV)를 surface 0에 붙인다 → 안쪽 구멍 약 0.22m × 0.23m.
- surface 1 `ChimneyFlueSoot`: 깊이 0.36m의 안쪽 벽 4장 + 바닥(y≈4.84). 아래로 갈수록 검고, 바닥에 화덕 불빛이 살짝 비친다.
- MeshInstance는 여전히 1개(`verify_user_cottage`의 "exactly one isolated cottage mesh" 유지).

연기 쪽 맞춤(`chimney_smoke.gd`):

- 입구 = 구멍 안쪽 폭: `MOUTH` 10~11칸(2칸 × 0.11m = 0.22m). 좁아진 만큼 유입 속도 11, 밀도 3.0.
- 판 바닥을 테두리보다 `MOUTH_SINK` 0.25m 아래(구멍 안, 바닥보다 위)에 둔다 → 연기가 구멍 속에서 솟아 흘러나온다.
- 해법에 고체 칸(`add_solid`)을 추가해 테두리 높이까지 구멍 양옆 칸을 연도 벽으로 막는다(속도·연기 0, 압력은 이웃 유체 칸 값). 연기가 벽을 뚫고 옆으로 새지 않는다.

검증 `verify_chimney_smoke.gd` 3부(8항목, 총 29): 메시 1개 유지, 그을음 surface·셰이더, 윗면 제거, 구멍이 굴뚝 중심, **굴뚝 중심으로 내리꽂은 광선의 첫 충돌이 구멍 바닥**, 연기 시작점이 바닥과 테두리 사이, 입구 폭 = 구멍 폭, 벽 옆 누출 < 5%.
캡처 `hole.png`(연기 끔)·`hole_smoke.png`.
