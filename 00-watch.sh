#!/bin/sh
# Run in a second terminal: one request every 0.2s, prints the status code.
# Leave it running while you change routes. No line ever shows 000 (dropped).
. ./env.sh
while :; do printf '%s ' "$(curl -s -o /dev/null -w '%{http_code}' -H 'apikey: alice-key' $GW/get)"; sleep 0.2; done
