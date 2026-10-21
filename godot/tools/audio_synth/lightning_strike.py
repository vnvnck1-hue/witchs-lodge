"""마녀 Q 번개 일격 효과음(sfx-lightning_strike.wav)을 절차적으로 합성한다(외부 음원·라이선스 없음).
실행: python tools/audio_synth/lightning_strike.py  (godot/ 기준)
구성: 지직거리는 방전 딱딱이(0~0.12s) + 날카로운 균열음 + 짧은 저음 쿵(우르릉 꼬리 0.9s)."""
import numpy as np, wave, os

SR = 44100
rng = np.random.default_rng(7)
dur = 1.1
n = int(SR * dur)
t = np.arange(n) / SR
out = np.zeros(n)

# 1) 방전 딱딱이: 무작위 시점의 짧은 고역 펄스 묶음
for _ in range(90):
    t0 = rng.uniform(0.0, 0.14) ** 1.3
    i0 = int(t0 * SR)
    L = int(SR * rng.uniform(0.0015, 0.005))
    if i0 + L >= n: continue
    burst = rng.standard_normal(L) * np.exp(-np.linspace(0, 6, L))
    out[i0:i0 + L] += burst * rng.uniform(0.3, 1.0) * (1.0 - t0 * 4)

# 2) 균열음: 하이패스 노이즈, 아주 빠른 감쇠
noise = rng.standard_normal(n)
hp = noise - np.convolve(noise, np.ones(6) / 6, mode="same")
crack = hp * np.exp(-t * 28.0) * 1.6
out += crack

# 3) 저음 쿵 + 우르릉: 로우패스 노이즈 + 하강 사인
lp = np.convolve(noise, np.ones(180) / 180, mode="same") * 9.0
rumble = lp * np.exp(-t * 4.0) * np.clip(t / 0.02, 0, 1)
f = 70.0 * np.exp(-t * 2.0) + 38.0
boom = np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-t * 7.0) * 0.9
out += rumble * 0.8 + boom

# 4) 전기 윙윙(짧은 톱니파 지터)
buzz_f = 120 + 40 * rng.standard_normal(n).cumsum() / np.sqrt(n)
buzz = ((np.cumsum(buzz_f) / SR) % 1.0 - 0.5) * np.exp(-t * 14.0) * 0.35
out += buzz

out = np.tanh(out * 1.3)
out /= np.max(np.abs(out)) * 1.05
fade = np.clip((dur - t) / 0.15, 0, 1)
out *= fade
pcm = (out * 32767).astype(np.int16)
path = os.path.join("assets", "audio", "sfx-lightning_strike.wav")
with wave.open(path, "wb") as w:
    w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR); w.writeframes(pcm.tobytes())
print("wrote", path, len(pcm) / SR, "s")
