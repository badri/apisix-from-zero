#!/bin/sh
# Limit by tokens, not requests: 300 tokens a minute on this route.
. ./env.sh
curl -s -X PATCH $ADMIN/routes/llm -H "$H" -d '{"plugins": {"ai-rate-limiting": {
  "limit": 300, "time_window": 60, "limit_strategy": "total_tokens", "rejected_code": 429
}}}' >/dev/null
for i in 1 2 3 4 5 6; do ./ask.sh "Explain Kubernetes in three sentences."; echo; done
