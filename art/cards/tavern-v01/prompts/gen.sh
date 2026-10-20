#!/bin/bash
# usage: gen.sh <out.png> <prompt.txt> <ref1> [ref2 ...]
out="$1"; prompt="$2"; shift 2
args=()
for r in "$@"; do args+=(-F "image[]=@$r;type=image/png"); done
resp="${out%.png}.json"
curl -s --max-time 600 https://api.openai.com/v1/images/edits -H "Authorization: Bearer $OPENAI_API_KEY" \
  -F model=gpt-image-2 -F size=1024x1536 -F quality=high -F background=${BG:-transparent} \
  "${args[@]}" -F "prompt=<$prompt" > "$resp"
python - "$resp" "$out" <<'PY'
import sys,json,base64
d=json.load(open(sys.argv[1],encoding='utf-8'))
if 'data' not in d: print("ERR", json.dumps(d)[:600]); sys.exit(1)
open(sys.argv[2],'wb').write(base64.b64decode(d['data'][0]['b64_json'])); print("OK", sys.argv[2], d.get('usage',{}))
PY
