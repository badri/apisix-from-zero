#!/bin/sh
# One endpoint, two LLMs. The hosted model is tried first (priority 1).
# If it errors or fails auth, APISIX retries on the local model (Ollama on the laptop).
# Any OpenAI-compatible provider works: set HOSTED_ENDPOINT, HOSTED_KEY, HOSTED_MODEL.
. ./env.sh
: "${HOSTED_ENDPOINT:=https://api.openai.com/v1/chat/completions}"
: "${HOSTED_MODEL:=gpt-4o-mini}"
: "${HOSTED_KEY:?set HOSTED_KEY to your provider API key}"
curl -s -X PUT $ADMIN/routes/llm -H "$H" -d '{
  "uri": "/llm",
  "methods": ["POST"],
  "plugins": {"ai-proxy-multi": {
    "fallback_strategy": ["http_429", "http_5xx"],
    "fallback_http_statuses": [401, 402],
    "instances": [
      {"name": "hosted", "provider": "openai-compatible", "priority": 1, "weight": 1,
       "auth": {"header": {"Authorization": "Bearer '"$HOSTED_KEY"'"}},
       "options": {"model": "'"$HOSTED_MODEL"'"},
       "override": {"endpoint": "'"$HOSTED_ENDPOINT"'"}},
      {"name": "local", "provider": "openai-compatible", "priority": 0, "weight": 1,
       "auth": {"header": {"Authorization": "Bearer none"}},
       "options": {"model": "qwen2.5:1.5b"},
       "override": {"endpoint": "http://host.docker.internal:11434/v1/chat/completions"}}
    ]
  }}
}' >/dev/null
./ask.sh "In one sentence, what is an API gateway?"
