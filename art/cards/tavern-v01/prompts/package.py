import sys, os, shutil
from PIL import Image
R = r"C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge"
mask = Image.open(R + "/godot/assets/cards/dark_ale.png").split()[3]
for arg in sys.argv[1:]:
    card, src = arg.split("=")
    im = Image.open(src).convert("RGBA").resize((1024, 1536), Image.LANCZOS)
    im.putalpha(mask)
    os.makedirs(R + "/art/cards/tavern-v01/drafts", exist_ok=True)
    shutil.copy(src, R + f"/art/cards/tavern-v01/drafts/{os.path.basename(src)}")
    im.save(R + f"/art/cards/tavern-v01/{card}.png")
    im.save(R + f"/godot/assets/cards/{card}.png")
    im.resize((256, 384), Image.LANCZOS).save(R + f"/godot/assets/cards/hand/{card}.png")
    print("packaged", card)
