#!/bin/sh
# Ask the gateway a question. Prints which model answered (or the error), then tokens left.
. ./env.sh
curl -s $GW/llm -H 'Content-Type: application/json' -D /tmp/apisix-headers \
  -d "{\"messages\": [{\"role\": \"user\", \"content\": \"$1\"}]}" \
| python3 -c 'import json,sys
body=sys.stdin.read()
try: r=json.loads(body)
except ValueError: r=None
if r and "choices" in r: print(r["model"], "->", r["choices"][0]["message"]["content"])
else: print(open("/tmp/apisix-headers").readline().strip(), body.strip()[:120])'
grep -i '^x-ai-ratelimit-remaining' /tmp/apisix-headers || :
