#!/bin/sh
# Delete everything the steps created, to run the demo again.
. ./env.sh
for p in routes/web routes/llm consumers/alice; do curl -s -o /dev/null -X DELETE $ADMIN/$p -H "$H"; done
