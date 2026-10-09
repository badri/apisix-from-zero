#!/bin/sh
# Simulate a provider outage: point "hosted" at a host that doesn't exist.
# Same request, same endpoint for the app. The local model answers instead.
HOSTED_ENDPOINT=https://llm-provider.invalid/v1/chat/completions ./04-llm.sh
