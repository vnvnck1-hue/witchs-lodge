# 마녀산장 · 필드 BGM과 자연 환경음 후보

검토 화면: http://127.0.0.1:8614/

**필드 BGM · 자연음** 탭에서 새 후보 12개를 듣고, 종류마다 한 개씩 체크한다. **선택한 사운드 적용** 또는 **게임 실행**을 누르면 승인한 곡만 게임에 들어간다. **기존 효과음** 탭에는 이전 후보와 승인 5개를 유지했다.

## 후보

| 종류 | 후보 | 내용 | 길이 |
| --- | --- | --- | --- |
| 기본 필드 BGM | field-chill-01.wav | 따뜻한 로즈 피아노, 부드러운 베이스와 가벼운 비트 · 72 BPM | 53.33초 |
| 기본 필드 BGM | field-chill-02.wav | 어쿠스틱 플럭과 따뜻한 패드 · 80 BPM | 48초 |
| 저녁 BGM | evening-tension-01.wav | 단조 로즈 피아노, 낮은 맥박과 은근한 긴장 · 72 BPM | 53.33초 |
| 저녁 BGM | evening-tension-02.wav | 단조 플럭, 낮은 베이스와 숲길의 신비감 · 80 BPM | 48초 |
| 낮 자연 환경음 | forest-wind-01~04.mp3 | 솔잎 사이의 부드러운 바람과 먼 새소리 | 각 20초 |
| 저녁 자연 환경음 | forest-evening-01~04.mp3 | 서늘한 바람, 먼 부엉이와 작은 가지 소리 | 각 24초 |

BGM 4개는 사용자가 승인한 추가 결제 없는 방식으로 직접 작곡·합성한 오리지널이다. 외부 음원이나 샘플 녹음을 사용하지 않았다. `create_bgm.py`로 재현할 수 있다. 48kHz 스테레오 16비트 WAV이며 악기와 딜레이의 꼬리를 앞부분으로 이어 반복 구간을 구성했다. 네 후보의 RMS는 -20dBFS로 맞췄으며 파형의 최대치는 0.54 미만이다. `bgm-manifest.json`에 길이, 음량, 반복 경계 차이와 해시를 기록했다.

자연 환경음 8개는 ElevenLabs 효과음 생성의 반복 켜짐 옵션으로 생성했고 원본 MP3를 보존했다. 모델의 반복 연결과 실제 게임 내 자연스러움은 최종 청취 판단이 필요하다. 실제 파일은 48kHz 스테레오이며 MPEG 프레임 검사를 통과했다. `audio-verification.json`은 인코딩 패딩 포함 길이를 기록하며 브라우저 재생 길이는 각각 20초·24초다.

## ElevenLabs 음악 참고 후보

서비스에서도 칠 BGM 두 곡을 생성했지만 음악 다운로드에 유료 구독이 필요했다. 사용자 요청에 따라 추가 결제를 진행하지 않고 직접 제작 후보를 준비했다. 두 AI 곡은 검토 화면 하단의 서비스 링크로 비교할 수 있으며 로컬 파일 묶음이나 게임 적용 후보에 포함하지 않는다.

- [Snowy Lodge Glow](https://elevenlabs.io/app/music/project/5DzKcb8tInxg3BiwdEst?selectedSongId=XZCcCcwTEhx95BBrAU8c)
- [Snowy Lodge Loop](https://elevenlabs.io/app/music/project/quQhOm2deUvxhc170LAN?selectedSongId=cux37lVhD4PSTmie5POt)

생성 프롬프트:

```text
Instrumental chill fantasy field background music for a cozy witch's lodge in a snowy forest. 72 BPM, warm Rhodes electric piano, soft rounded bass, gentle brushed lo-fi beat, sparse kalimba and airy warm pads. Relaxed and mellow with a tiny magical sparkle, understated melody, consistent quiet dynamics, no vocals, no dramatic build, no big ending. Designed as a repeating gameplay music bed.
```

## 자연음 프롬프트

[낮의 숲 생성 기록](https://elevenlabs.io/app/sound-effects/history?id=JRFIfGCijwwMQYr78VqQ):

```text
Seamless looping daytime ambience of a quiet snowy pine forest beside a cozy witch's lodge: soft steady wind through pine needles, gentle leaf rustle, faint distant small birds, spacious natural stereo. Calm and unobtrusive under background music. No speech, no music, no footsteps, no heavy gusts, no abrupt foreground sounds.
```

[저녁의 숲 생성 기록](https://elevenlabs.io/app/sound-effects/history?id=KdHgJvrARUInNtwrkaT2):

```text
Seamless looping evening ambience in a snowy mountain pine forest: cool gentle wind moving through trees, soft pine needle rustle, very faint distant owl calls and occasional quiet dry branch creaks. Spacious natural stereo, subtly watchful and mysterious but not horror. Low steady background for a fantasy game. No speech, no music, no insects, no footsteps, no jump scares, no loud gusts.
```

## 게임 연결과 검증

- `bgm_field` / `bgm_evening`: 준비 시간의 낮→저녁 진행에 따라 음악을 교차 페이드한다.
- `ambience_day` / `ambience_evening`: 별도의 자연음 층으로 같은 시간 변화에 맞춰 전환한다.
- 시간대 진행 0.58~0.82 사이에서 부드럽게 바뀐다. 저녁을 선택하지 않으면 기본 필드 음악은 계속 유지한다.
- 설정 변경은 약 1초마다 읽으며, 반복 WAV와 MP3를 지원한다. 아직 새 후보는 임의 승인하지 않았다.
- `game-verification.json`: 반복·WAV/MP3 로딩·낮/황혼/밤 전환·재시작 방지·일시 정지·승인 해제 등 13개 통과.
- 기존 효과음 테스트 13개와 저장 서버 테스트 13개도 통과했다. 브라우저에서 새 12개와 기존 16개가 모두 로딩되는 것을 확인했다.
- `build/WitchsLodge.pck`와 `build/audio-review/WitchsLodge.pck`에 연결 코드를 넣었다. 이전 실행 데이터는 `build/WitchsLodge-before-field-audio.pck`에 보존했다.

무료 플랜에서 생성한 ElevenLabs 자연음은 검토·비상업 사용 후보로 보관한다. 출시용으로 사용하기 전 해당 음원의 사용 권리를 확인한다.
