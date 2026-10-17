# VoiceStudio로 인물 대사 음성 만들기 — 1차 시도 기록 (보류)

2026-10-17 · 상태: **보류** — GPU VRAM이 넉넉한 다른 PC에서 다시 시도한다.

## 목표

[VoiceStudio](https://github.com/debpalash/VoiceStudio)(로컬 TTS·보이스 디자인 툴)를 설치하고,
게임 인물 대사 하나를 **상업적으로 쓸 수 있는** 음성으로 만든다.

- 시험 대사: **미라(채집가)** 2번째 대사 — `godot/scripts/ui/guest_profiles.gd`
  > 숲에서는 이름을 불러도 돌아보지 말라던데… 여기서는 쉬어도 되겠죠?
- 목소리 설명(보이스 디자인): `A young woman, soft and warm voice, quiet, slightly uneasy`

## 라이선스 판단 (상업 사용 기준)

| 대상 | 라이선스 | 판단 |
| --- | --- | --- |
| VoiceStudio 앱 | AGPL-3.0 | 앱 코드에만 적용. 생성한 음성 파일엔 영향 없음 → 사용 가능 |
| OmniVoice (기본 모델) | 가중치 **CC-BY-NC** (+Higgs Audio 2, Llama 3 조건) | **비상업 → 게임에 사용 불가.** 설치하지 않음 |
| **VoxCPM2** (`openbmb/VoxCPM2`) | Apache-2.0 | 상업 가능 · 한국어 · 설명만으로 보이스 디자인 → **채택** |
| CosyVoice3 0.5B | Apache-2.0 | 상업 가능 · 9.8GB. 대안 후보 |
| MOSS-TTS-Nano | Apache-2.0 | 참조 음성 복제만 가능(디자인 불가) |

- VoiceStudio 자체 라이선스 목록에서는 VoxCPM2가 "검토 전(unreviewed)"이다. Apache-2.0 표기는 모델 제작사가 올린 정보이므로,
  출시 전에 [모델 페이지](https://huggingface.co/openbmb/VoxCPM2)의 추가 조건을 확인한다.
- 실존 인물 녹음으로 복제하지 않고 **보이스 디자인만** 쓰면 목소리 권리 문제를 피할 수 있다.

## 이 PC에서 막힌 이유

PC: i7-11370H · RAM 16GB · **RTX 3050 Ti Laptop 4GB** · C: 여유 약 40GB.

1. **VRAM 부족** — VoxCPM2 가중치(bf16)가 4.6GB라 CUDA 로드 중 `Windows fatal exception: access violation`
   (safetensors 로드)으로 사이드카가 죽는다. VoiceStudio 화면에는 "sidecar closed pipe mid-generate"로만 보인다.
2. **CPU로 돌리면 느리고, API 경로에서 끝나지 않는다**
   - 엔진을 직접 호출하면(CPU, `retry_badcase` 기본값 켬, `max_len=90`) 대사 1줄에 약 90~130초 걸려 **정상 생성**된다.
   - VoiceStudio API(`POST /generate`)는 `retry_badcase=False`, `max_len=max(256, 글자수×6)`로 호출한다.
     모델이 말을 끝내지 못하는 경우 재시도 없이 수백 스텝을 돌다가, 메모리 압박(여유 RAM 1~2GB)으로 스텝당 3~6초까지 느려진다.
     그 결과 **905초 CPU 예산 초과로 503 실패**(2회 시도 모두 실패).
   - 대사 속 `…`과 긴 영어 설명이 이런 현상을 부추기는 것으로 보여, 쉼표와 짧은 설명으로 바꿨다.

## 현재 결과물 (임시)

`output/voice-test/` — **VoiceStudio API가 아니라 VoxCPM2 엔진을 직접 호출해** 만든 시험본(CPU, seed 미고정):

- `mira_line2_voxcpm2-direct_designed.wav` — 목소리 설명 적용, 5.1초
- `mira_line2_voxcpm2-direct_plain.wav` — 설명 없음(기본 목소리), 7.0초

사람이 들어서 확인하지는 않았다(발음·톤 미검증).

## 이 PC에 설치된 것 (정리 대상)

| 항목 | 위치 |
| --- | --- |
| VoiceStudio 앱 0.5.6 (Electron) | `%LOCALAPPDATA%\Programs\VoiceStudio` (제거: 같은 폴더의 `Uninstall VoiceStudio.exe`) |
| 소스 + 백엔드 venv (main 481cf4c, 백엔드 0.5.7, torch cu128) | `C:\Users\vnvnc\VoiceStudio` (`.venv`, `setup-api.log`, `backend.log`) |
| VoxCPM2 엔진 venv | `%APPDATA%\OmniVoice\engines\voxcpm2` |
| VoxCPM2 가중치 (리비전 2개가 받아져 있음, **9.3GB**) | Claude 앱 안에서 실행했기 때문에 `%LOCALAPPDATA%\Packages\Claude_pzs8sxrjxfjjc\LocalCache\Local\OmniVoice\hf_cache`로 리디렉트됨 |

디스크 사용량: 앱 0.9GB · 소스 `.venv` 9.2GB · 엔진 venv 5.1GB · 가중치 9.3GB — **합계 약 24.5GB**.

앱의 첫 실행 "런타임 설치" 화면은 진행하지 않았다(소스 백엔드로 대체).

## 다른 PC에서 다시 할 때

권장 사양: **NVIDIA VRAM 8GB 이상**(VoxCPM2 bf16 4.6GB + 여유), RAM 16GB 이상, 디스크 20GB 이상.

1. 앱 설치: [Releases](https://github.com/debpalash/VoiceStudio/releases/latest)에서 `VoiceStudio-Electron-<ver>-win-x64.exe`를 받아
   `SHA256SUMS.txt`와 대조한 뒤 설치하고, 첫 화면의 런타임 설치를 진행한다(이번에는 이 단계를 앱 대신 소스로 했다).
   - 또는 소스: `git clone` → `node scripts/setup-api.mjs` → `uv run --no-sync uvicorn main:app --app-dir backend --port 3900`
2. 모델은 **OmniVoice 라이선스에 동의하지 말고** VoxCPM2만 설치한다:
   `POST /models/install {"repo_id":"openbmb/VoxCPM2"}` → `POST /engines/sidecar/voxcpm2/install`
3. `GET /health`의 `device`가 `cuda`인지 확인한다.
4. 생성:
   ```text
   curl -X POST http://127.0.0.1:3900/generate -F engine=voxcpm2 -F language=ko -F seed=7 \
     -F "instruct=A young woman, soft and warm voice, quiet, slightly uneasy" \
     -F "text=숲에서는 이름을 불러도 돌아보지 말라던데, 여기서는 쉬어도 되겠죠?" -o mira_line2.wav
   ```
   GPU에서도 끝나지 않는 현상이 반복되면 seed를 바꾸거나, 앱의 Settings → Performance & Device에서 CPU budget을 늘린다.
5. 결과는 소리별 코멘트 칸이 있는 검토 페이지(`output/audio-review-kit`)로 확인한다.
6. 인물별 목소리 설명을 고정해 두면(시드 + 설명, 또는 마음에 든 결과를 VoiceStudio 보이스 프로필로 저장) 대사 전체를 같은 목소리로 일괄 생성할 수 있다.
