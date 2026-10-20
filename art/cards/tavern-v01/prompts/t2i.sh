#!/bin/bash
# usage: t2i.sh <out.png> <prompt.txt> [size]
out="$1"; prompt="$2"; size="${3:-1536x1024}"
python - "$prompt" "$size" > body.$$.json <<'PY'
import sys,json
print(json.dumps({"model":"gpt-image-2","prompt":open(sys.argv[1],encoding='utf-8').read(),"size":sys.argv[2],"quality":"high","n":1}))
PY
curl -s --max-time 600 https://api.openai.com/v1/images/generations -H "Authorization: Bearer $OPENAI_API_KEY" -H "Content-Type: application/json" --data-binary @body.$$.json > "${out%.png}.json"; rm -f body.$$.json
python - "${out%.png}.json" "$out" <<'PY'
import sys,json,base64
d=json.load(open(sys.argv[1],encoding='utf-8'))
if 'data' not in d: print("ERR", json.dumps(d)[:600]); sys.exit(1)
open(sys.argv[2],'wb').write(base64.b64decode(d['data'][0]['b64_json'])); print("OK", sys.argv[2])
PY
