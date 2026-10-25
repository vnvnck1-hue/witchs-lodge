"""Archive the exact deterministic target used before the third image_gen call."""
from pathlib import Path
from PIL import Image
import numpy as np

D=Path(__file__).resolve().parent
gen=Image.open(D/'01-characters-imagegen.png').convert('RGBA').resize((2640,1080),Image.Resampling.LANCZOS)
src=Image.open(D/'lobby_characters-source.png')
strip=gen.crop((0,0,714,1080)).resize((720,1080),Image.Resampling.LANCZOS)
a=np.array(strip,dtype=np.float32)
delta=np.array(src,dtype=np.float32)[:,0,:]-a[:,-1,:]
a+=delta[:,None,:]*np.exp(-(719-np.arange(720,dtype=np.float32))/9)[None,:,None]
a=np.uint8(np.clip(np.rint(a),0,255))
a[a[:,:,3]==0,:3]=0
im=Image.new('RGBA',(2640,1080))
im.paste(Image.fromarray(a),(0,0)); im.paste(src,(720,0))
im.save(D/'03-wing-correction-input.png')
