# LightRAG setup

Reins uses [LightRAG](https://github.com/HKUDS/LightRAG) as the underlying RAG engine. Reins does not ship LightRAG itself; you deploy it and point reins at it.

## Local (docker-compose)

A minimal `docker-compose.yml` snippet:

```yaml
services:
  lightrag-postgres:
    image: gzdaniel/postgres-for-rag:16.6
    ports: ['5433:5432']
    volumes: [lightrag-postgres-data:/var/lib/postgresql]

  ollama:
    image: ollama/ollama:latest
    ports: ['11434:11434']
    volumes: [ollama-data:/root/.ollama]

  lightrag:
    image: ghcr.io/hkuds/lightrag:latest
    ports: ['9621:9621']
    environment:
      LIGHTRAG_API_KEY: dev-secret-change-me
      LLM_BINDING: ollama
      LLM_MODEL: llama3.2:latest
      LLM_BINDING_HOST: http://ollama:11434
      EMBEDDING_BINDING: ollama
      EMBEDDING_MODEL: nomic-embed-text:latest
      EMBEDDING_BINDING_HOST: http://ollama:11434
      EMBEDDING_DIM: 768
      POSTGRES_HOST: lightrag-postgres
      POSTGRES_PORT: 5432
      POSTGRES_USER: rag
      POSTGRES_PASSWORD: rag
      POSTGRES_DATABASE: rag
      LIGHTRAG_KV_STORAGE: PGKVStorage
      LIGHTRAG_DOC_STATUS_STORAGE: PGDocStatusStorage
      LIGHTRAG_VECTOR_STORAGE: PGVectorStorage
      LIGHTRAG_GRAPH_STORAGE: PGGraphStorage
    depends_on: [lightrag-postgres, ollama]

volumes:
  lightrag-postgres-data:
  ollama-data:
```

After `docker compose up -d`, LightRAG is at `http://localhost:9621`. Set in your API's `.env`:

```
LIGHTRAG_URL=http://localhost:9621
LIGHTRAG_API_KEY=dev-secret-change-me
```

## Local with OpenAI bindings

Replace the LLM and embedding bindings:

```yaml
LLM_BINDING: openai
LLM_MODEL: gpt-4o-mini
LLM_BINDING_API_KEY: sk-...
EMBEDDING_BINDING: openai
EMBEDDING_MODEL: text-embedding-3-small
EMBEDDING_BINDING_API_KEY: sk-...
```

## Kubernetes

Apply a deployment + service + secret:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: lightrag
  namespace: platform
spec:
  replicas: 1
  selector:
    matchLabels: { app: lightrag }
  template:
    metadata:
      labels: { app: lightrag }
    spec:
      containers:
        - name: lightrag
          image: ghcr.io/hkuds/lightrag:latest
          ports: [{ containerPort: 9621 }]
          env:
            - name: LIGHTRAG_API_KEY
              valueFrom: { secretKeyRef: { name: lightrag-api, key: apiKey } }
            - name: LLM_BINDING
              value: openai
            - name: LLM_MODEL
              value: gpt-4o-mini
            - name: LLM_BINDING_API_KEY
              valueFrom: { secretKeyRef: { name: lightrag-api, key: openaiApiKey } }
            - name: EMBEDDING_BINDING
              value: openai
            - name: EMBEDDING_MODEL
              value: text-embedding-3-small
            - name: EMBEDDING_BINDING_API_KEY
              valueFrom: { secretKeyRef: { name: lightrag-api, key: openaiApiKey } }
            # ... postgres connection vars
          readinessProbe:
            tcpSocket: { port: 9621 }
            initialDelaySeconds: 30
            periodSeconds: 10
```

Provision the secret out-of-band:

```bash
kubectl create secret generic lightrag-api -n platform \
  --from-literal=apiKey=$(openssl rand -hex 32) \
  --from-literal=openaiApiKey=sk-...
```

## Restart after credential changes

LightRAG configures its bindings at container start. Changing the chat or embedding credential in the reins admin does not automatically restart the container. Restart manually:

- Local: `docker compose restart lightrag`
- Kubernetes: `kubectl rollout restart deploy/lightrag -n platform`

The setup wizard's step 4 fails the health probe until LightRAG is back up. Auto-sync of credential settings into the LightRAG container env is on the Phase 2 roadmap.

## Troubleshooting

- **Wizard step 4 stays red.** Verify `LIGHTRAG_URL` is reachable from the API process: `curl $LIGHTRAG_URL/health -H "x-api-key: $LIGHTRAG_API_KEY"`. Should return 200.
- **Queries return empty results.** Check that the embedding model in LightRAG matches what was used during ingestion. Switching embedding models without re-ingesting all sources produces empty matches.
- **5xx from LightRAG on /documents/text.** Check the LightRAG container logs for OpenAI rate limits or postgres connection errors.
