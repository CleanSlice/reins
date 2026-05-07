# Reins

Knowledge / RAG slice for CleanSlice projects. Reins lets a CleanSlice host manage knowledge bases backed by LightRAG: ingest sources, query with hybrid retrieval, visualize the knowledge graph.

## Architecture

```
Browser (admin Nuxt)         CleanSlice API (NestJS)         LightRAG (separate service)
       |                              |                                 |
       |--- /knowledges/* ----------->|                                 |
       |                              |--- POST /documents/text ------->|
       |                              |--- POST /query --------------->|
       |<--- response -----------|<--- response ------------------|
                                      |
                                      |--- GET ILlmGateway.* (host's llm slice)
                                      |--- GET ISettingGateway.* (host's setting slice)
                                      |--- S3Repository.* (host's aws slice)
```

Reins ships:

- A NestJS slice (`nestjs/`) that goes into `api/src/slices/reins/`.
- A Nuxt layer (`nuxt/`) that goes into `admin/slices/reins/`.
- These docs.

What it does not ship:

- Identity / auth (use the host's existing auth).
- The LightRAG service itself (deploy via docker-compose or k8s; see [LightRAG setup](./lightrag)).
- LLM credentials (use the host's `llm` slice; see [LLM credentials](./credentials)).
- Generic settings UI (use the host's `setting` slice).

## Quick install

See [Getting started](./getting-started). Two-minute summary:

1. Make sure your CleanSlice host has prisma + prisma-import, an `llm` slice with capability flags, a `setting` slice, and an `aws/s3` slice.
2. Deploy LightRAG.
3. Copy `nestjs/` into `api/src/slices/reins/`.
4. Copy `nuxt/` into `admin/slices/reins/`.
5. Open `/knowledges` and follow the wizard.
