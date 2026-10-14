"""Check downloaded MP3 frame structure; this does not assess sound quality."""
from pathlib import Path
import hashlib
import json

ROOT = Path(__file__).resolve().parent
BITRATES = {
    3: [0, 32, 40, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320],
    2: [0, 8, 16, 24, 32, 40, 48, 56, 64, 80, 96, 112, 128, 144, 160],
    0: [0, 8, 16, 24, 32, 40, 48, 56, 64, 80, 96, 112, 128, 144, 160],
}


def inspect(path):
    data = path.read_bytes()
    pos = 0
    if data[:3] == b"ID3":
        size = 0
        for value in data[6:10]:
            size = (size << 7) | (value & 127)
        pos = 10 + size + (10 if data[5] & 16 else 0)
    frames, duration, rates, channels, skipped = 0, 0.0, set(), set(), 0
    while pos + 4 <= len(data):
        if data[pos:pos + 3] == b"TAG" and len(data) - pos == 128:
            pos += 128
            break
        h = int.from_bytes(data[pos:pos + 4], "big")
        version, layer = (h >> 19) & 3, (h >> 17) & 3
        bi, si = (h >> 12) & 15, (h >> 10) & 3
        if h >> 21 != 2047 or version == 1 or layer != 1 or bi in (0, 15) or si == 3:
            skipped += 1
            pos += 1
            continue
        rate = [44100, 48000, 32000][si] // {3: 1, 2: 2, 0: 4}[version]
        bitrate = BITRATES[version][bi] * 1000
        length = (144 if version == 3 else 72) * bitrate // rate + ((h >> 9) & 1)
        if pos + length > len(data):
            raise ValueError(f"{path.name}: incomplete MPEG frame")
        frames += 1
        duration += (1152 if version == 3 else 576) / rate
        rates.add(rate)
        channels.add(1 if (h >> 6) & 3 == 3 else 2)
        pos += length
    if not frames or skipped:
        raise ValueError(f"{path.name}: {frames} frames, {skipped} unexpected bytes")
    return {
        "file": path.name, "bytes": len(data), "sha256": hashlib.sha256(data).hexdigest(),
        "mpeg_frames": frames, "frame_duration_seconds": round(duration, 4),
        "sample_rates": sorted(rates), "channels": sorted(channels),
        "trailing_bytes": len(data) - pos,
    }


results = [inspect(p) for p in sorted(ROOT.glob("*.mp3"))]
report = {
    "file_count": len(results), "files": results,
    "note": "Duration includes encoded frame padding; no listening or playback decode quality assessment.",
}
(ROOT / "audio-verification.json").write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
print(json.dumps(report, ensure_ascii=False, indent=2))
