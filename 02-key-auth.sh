#!/bin/sh
# Only callers with a key get through. alice is a consumer with one key.
. ./env.sh
curl -s -X PUT $ADMIN/consumers -H "$H" -d '{
  "username": "alice",
  "plugins": {"key-auth": {"key": "alice-key"}}
}' >/dev/null
curl -s -X PATCH $ADMIN/routes/web -H "$H" -d '{"plugins": {"key-auth": {}}}' >/dev/null
echo "no key:   $(curl -s -o /dev/null -w '%{http_code}' $GW/get)"
echo "with key: $(curl -s -o /dev/null -w '%{http_code}' -H 'apikey: alice-key' $GW/get)"
