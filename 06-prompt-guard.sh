#!/bin/sh
# Stop secrets from leaving the building: block prompts that look like keys or card numbers.
. ./env.sh
curl -s -X PATCH $ADMIN/routes/llm -H "$H" -d '{"plugins": {"ai-prompt-guard": {
  "deny_patterns": ["(?i)password", "sk-[A-Za-z0-9]{10,}", "\\b[0-9]{4}[ -]?[0-9]{4}[ -]?[0-9]{4}[ -]?[0-9]{4}\\b"]
}}}' >/dev/null
./ask.sh "My card is 4111 1111 1111 1111, is it valid?"
