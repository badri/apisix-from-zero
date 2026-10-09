#!/bin/sh
# 3 requests per 10 seconds per consumer. The 4th gets a 429.
. ./env.sh
curl -s -X PATCH $ADMIN/routes/web -H "$H" -d '{"plugins": {"limit-count": {
  "count": 3, "time_window": 10, "key_type": "var", "key": "consumer_name", "rejected_code": 429
}}}' >/dev/null
for i in 1 2 3 4 5; do printf '%s ' "$(curl -s -o /dev/null -w '%{http_code}' -H 'apikey: alice-key' $GW/get)"; done; echo
