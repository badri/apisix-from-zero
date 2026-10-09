#!/bin/sh
# A route: /get on the gateway goes to the httpbin service.
. ./env.sh
curl -s -X PUT $ADMIN/routes/web -H "$H" -d '{
  "uri": "/get",
  "upstream": {"type": "roundrobin", "nodes": {"httpbin.apisix.svc:80": 1}}
}' >/dev/null
curl -s $GW/get
