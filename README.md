# Apache APISIX from Zero

Demo code for the talk "Apache APISIX from Zero: One Gateway for Your APIs and Your LLMs" (CNCF Chennai, 10 October 2026) by Lakshmi Narasimhan.

One local Kubernetes cluster, one gateway, two things behind it: a plain HTTP service and an LLM. Every change goes through the APISIX Admin API and takes effect immediately. Nothing restarts or reloads.

Tested with APISIX 3.19.0 (Helm chart 2.18.0), kind, and Ollama 0.40 on an M2 Mac.

## Setup (once, needs internet)

```sh
kind create cluster --config kind.yaml
helm repo add apisix https://charts.apiseven.com
helm install apisix apisix/apisix --version 2.18.0 -n apisix --create-namespace -f values.yaml
kubectl -n apisix apply -f apps.yaml
kubectl -n apisix wait --for=condition=available deploy --all --timeout=600s

# The local LLM runs natively so it gets the GPU. Pods reach it at host.docker.internal.
brew install ollama && brew services start ollama
ollama pull qwen2.5:1.5b
```

The gateway listens on `localhost:9080` and the Admin API on `localhost:9180`.

## The demo

Set your hosted provider. Any OpenAI-compatible API works:

```sh
export HOSTED_KEY=sk-...                      # required
export HOSTED_ENDPOINT=https://api.openai.com/v1/chat/completions   # default
export HOSTED_MODEL=gpt-4o-mini               # default
```

Optionally run `./00-watch.sh` in a second terminal. It sends a request every 0.2 seconds and prints the status code, so you can see that config changes never drop a request.

| Step | What it shows |
| --- | --- |
| `01-route.sh` | A route: `/get` goes to the httpbin service. |
| `02-key-auth.sh` | A consumer with an API key. No key gets 401. |
| `03-rate-limit.sh` | 3 requests per 10 seconds per consumer. The 4th gets 429. |
| `04-llm.sh` | One `/llm` endpoint in front of a hosted model and a local model. |
| `05-token-limit.sh` | Rate limit by tokens: 300 a minute. Watch the remaining count fall. |
| `06-prompt-guard.sh` | Prompts containing card numbers, `sk-` keys or "password" are blocked. |
| `07-cut-hosted.sh` | The hosted provider "goes down". The same call is answered by the local model. |

`./ask.sh "question"` sends one question to `/llm` and prints which model answered. `./reset.sh` deletes everything the steps created.

## No internet at the venue?

Point "hosted" at Ollama with the same model and run the steps as usual. Step 7 still works, because it breaks the hosted address, not the key.

```sh
export HOSTED_ENDPOINT=http://host.docker.internal:11434/v1/chat/completions HOSTED_MODEL=qwen2.5:1.5b HOSTED_KEY=none
```

## Not for production

The Admin API is open to any IP and uses a fixed key, etcd has one replica, and there is no TLS. That is fine on a laptop and nowhere else.
