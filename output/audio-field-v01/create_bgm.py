"""Original instrumental game loops, synthesized locally; no sampled recordings."""
from pathlib import Path
import hashlib
import json
import wave
import numpy as np

ROOT = Path(__file__).resolve().parent
SR = 48000


def frequency(note):
    return 440 * 2 ** ((note - 69) / 12)


def voice(note, duration, kind, seed=0):
    t = np.arange(round(duration * SR), dtype=np.float64) / SR
    f = frequency(note)
    if kind == 'rhodes':
        sound = np.sin(2*np.pi*f*t + 1.6*np.exp(-t/0.4)*np.sin(2*np.pi*2*f*t))
        sound += .13*np.sin(2*np.pi*3*f*t)*np.exp(-t/.28)
        envelope = (1-np.exp(-t/.012))*np.exp(-t/1.5)
    elif kind == 'guitar':
        sound = sum(np.sin(2*np.pi*f*k*t + .13*k)*np.exp(-t*(.65+.43*k))/k**1.7 for k in range(1,9))
        envelope = (1-np.exp(-t/.006))*np.exp(-t/1.7)
    elif kind == 'bell':
        sound = np.sin(2*np.pi*f*t) + .15*np.sin(2*np.pi*2.01*f*t)*np.exp(-t/.4)
        envelope = (1-np.exp(-t/.006))*np.exp(-t/.55)
    elif kind == 'pad':
        sound = .48*np.sin(2*np.pi*f*.999*t)+.48*np.sin(2*np.pi*f*1.001*t)+.10*np.sin(2*np.pi*2*f*t)
        envelope = np.minimum(t/.9, 1) * np.minimum((duration-t)/1.4, 1)
        envelope *= .9+.1*np.sin(2*np.pi*.13*t)
    elif kind == 'bass':
        sound = np.sin(2*np.pi*f*t)+.1*np.sin(2*np.pi*2*f*t)
        envelope = (1-np.exp(-t/.018))*np.exp(-t/1.0)
    elif kind == 'kick':
        sound = np.sin(2*np.pi*(45*t+2.8*(1-np.exp(-t/.035))))
        envelope = (1-np.exp(-t/.002))*np.exp(-t/.13)
    else:
        rng = np.random.default_rng(seed)
        noise = rng.normal(0,1,len(t))
        spec = np.fft.rfft(noise)
        freq = np.fft.rfftfreq(len(noise),1/SR)
        if kind == 'hat':
            spec *= (freq/(freq+2800))**3 / (1+(freq/8500)**4)
            decay = .035
        else:
            spec *= np.exp(-((freq-1500)/1100)**2)
            decay = .07
        sound = np.fft.irfft(spec,n=len(noise))
        envelope = (1-np.exp(-t/.003))*np.exp(-t/decay)
    release = min(.07, duration/4)
    envelope *= np.clip((duration-t)/release,0,1)
    return (sound*envelope).astype(np.float32)


def make_track(filename, evening=False, acoustic=False):
    bpm = 80 if acoustic else 72
    beat = round(SR*60/bpm)
    length = 64*beat
    mix = np.zeros((length,2),np.float32)
    rng = np.random.default_rng(870+(10 if evening else 0)+(1 if acoustic else 0))

    def add(note, at, duration, kind, amp, pan=0):
        sound = voice(note,duration,kind,int(rng.integers(1,100000))) * amp
        begin = round(at*beat) % length
        gains = np.array([np.cos((pan+1)*np.pi/4),np.sin((pan+1)*np.pi/4)],np.float32)
        part = sound[:,None]*gains
        # Notes and effects crossing the loop boundary wrap naturally.
        for start in range(0,len(sound),length):
            block = part[start:start+length]
            first = min(len(block),length-begin)
            mix[begin:begin+first] += block[:first]
            if first < len(block): mix[:len(block)-first] += block[first:]

    if acoustic:
        roots = [45,41,48,43] if evening else [48,45,41,43]
        chords = [[57,60,64,71],[53,57,60,64],[55,60,63,67],[55,58,62,69]] if evening else [[60,64,67,71],[57,60,64,67],[53,57,60,64],[55,59,62,64]]
    else:
        roots = [43,39,36,38] if evening else [43,40,36,38]
        chords = [[55,58,62,69],[51,58,62,67],[48,55,58,62],[50,57,60,63]] if evening else [[55,59,62,66,69],[52,55,59,62,66],[48,55,59,62,64],[50,57,59,62,66]]
    for bar in range(16):
        ci = bar//4
        root,chord = roots[ci], chords[ci]
        base = bar*4
        if bar%4 == 0:
            for ni,note in enumerate(chord):
                add(note,base-.08,16*beat/SR+.7,'pad',.030 if evening else .022,(ni-2)*.25)
        for step in [0,2.5]:
            add(root,base+step,1.6,'bass',.10 if evening else .07,-.02)
        if acoustic:
            for step in range(8):
                note = chord[(step+bar)%len(chord)]
                add(note,base+step*.5,1.9,'guitar',.065 if evening else .080,(-1)**step*.28)
        else:
            for step in [0,2.5]:
                for ni,note in enumerate(chord):
                    add(note,base+step+ni*.014,2.6,'rhodes',.045,(ni-2)*.18)
            for step in [1.5,3.5]:
                note = chord[(bar+int(step))%len(chord)] + (0 if evening else 12)
                add(note,base+step,1.0,'bell',.026 if evening else .030,.35 if bar%2 else -.35)
        # Soft half-time percussion; evenings add a subdued low pulse, not combat drums.
        add(35,base,.6,'kick',.068 if evening else .055)
        add(35,base+2,.6,'kick',.055 if evening else .030)
        if not acoustic:
            add(0,base+2,.3,'brush',.040 if evening else .033,.05)
        for step in range(8):
            if acoustic and step%2: continue
            add(0,base+step*.5,.22,'hat',.016 if evening else .014,(-1)**step*.2)
        if evening and bar%2 == 1:
            add(chord[-1]-12,base+3,2.5,'rhodes',.026,-.4)
    # Periodic stereo delay and room reflections preserve the loop seam.
    dry = mix.copy()
    for delay,amount in [(0.13,.12),(0.27,.08),(0.41,.05)]:
        mix += np.roll(dry,round(delay*SR),axis=0)[:,::-1]*amount
    spec = np.fft.rfft(mix,axis=0)
    freq = np.fft.rfftfreq(length,1/SR)
    spec *= (1/(1+(freq/6200)**4))[:,None]
    mix = np.fft.irfft(spec,n=length,axis=0).astype(np.float32)
    mix -= np.mean(mix,axis=0)
    peak = float(np.max(np.abs(mix)))
    rms = float(np.sqrt(np.mean(mix**2)))
    mix *= min(.68/max(peak,1e-6), .1/max(rms,1e-6))
    pcm = np.rint(np.clip(mix,-1,1)*32767).astype('<i2')
    path = ROOT/filename
    with wave.open(str(path),'wb') as w:
        w.setnchannels(2);w.setsampwidth(2);w.setframerate(SR);w.writeframes(pcm.tobytes())
    return {'file':filename,'origin':'original local synthesis','bpm':bpm,'duration':length/SR,
            'loop':True,'peak':float(np.max(np.abs(mix))),
            'rms_db':round(20*np.log10(float(np.sqrt(np.mean(mix**2)))+1e-9),2),
            'seam_delta':float(np.max(np.abs(mix[0]-mix[-1]))),
            'sha256':hashlib.sha256(path.read_bytes()).hexdigest()}


if __name__ == '__main__':
    tracks=[make_track('field-chill-01.wav'),make_track('field-chill-02.wav',acoustic=True),
            make_track('evening-tension-01.wav',evening=True),make_track('evening-tension-02.wav',evening=True,acoustic=True)]
    (ROOT/'bgm-manifest.json').write_text(json.dumps({'tracks':tracks},indent=2),encoding='utf-8')
    print(json.dumps(tracks,indent=2))
