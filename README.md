![Reins](./docs/docs/.vitepress/public/cleanslice-reins-background.png)

# Reins

Knowledge / RAG slice for CleanSlice projects. Reins lets a CleanSlice host manage knowledge bases backed by LightRAG: ingest text, urls, and files; query with hybrid retrieval; visualize the knowledge graph.

**[Full documentation: reins.cleanslice.org](https://reins.cleanslice.org)**

[NestJS slice](./nestjs/README.md) - [Nuxt layer](./nuxt/README.md) - [LightRAG setup](./docs/docs/lightrag.md) - [Settings reference](./docs/docs/settings.md) - [LLM credentials](./docs/docs/credentials.md)

## Quick Install

Copy this prompt into Claude Code to add Reins to your CleanSlice project:

````
Add reins (Knowledge / RAG) to this CleanSlice project. The repo is at https://github.com/CleanSlice/reins

Prerequisites:
  - prisma + prisma-import configured in api/
  - llm slice with supportsChat / supportsEmbedding columns on LlmCredential and ILlmGateway.hasCredentialWithCapability
  - setting slice with ISettingGateway.findByKey
  - aws/s3 slice with S3Repository
  - LightRAG service deployed (docker-compose or k8s)

Steps:

1. Clone reins next to this project (or reference it if already cloned).

2. NestJS API:
   - Copy reins/nestjs/* into api/src/slices/reins/
   - Run `npm --prefix api run migrate` to create Knowledge and Source tables.
   - Add ReinsModule to api/src/app.module.ts:
       import { ReinsModule } from './slices/reins';
       @Module({ imports: [ReinsModule, /* other slices */] })
   - Set api/.env values:
       LIGHTRAG_URL=<your LightRAG URL>
       LIGHTRAG_API_KEY=<your LightRAG shared secret>
       REINS_S3_BUCKET=<bucket name for sources>
     (or set them via the settings table at runtime: knowledge/url, knowledge/api_key, knowledge/s3_bucket)

3. Nuxt admin:
   - Copy reins/nuxt/* into admin/slices/reins/
   - Add to admin/nuxt.config.ts: extends: ['./slices/reins']
   - Add a sidebar link to /settings/knowledge in your settings nav. The page itself ships from this layer.

4. LightRAG runtime:
   - Make sure LightRAG is reachable from the API. See https://reins.cleanslice.org/lightrag for the docker-compose snippet and k8s manifests.
   - Configure LightRAG's LLM and embedding bindings (OpenAI, Ollama, Azure) at the container level. Reins picks credentials in the admin but does not push them into the LightRAG container in this phase; restart the container after changing credentials.

5. Verify:
   - Open /knowledges in the admin. The wizard renders with 4 steps.
   - Walk through: create an embedding LLM credential (OpenAI text-embedding-3-small), create a chat credential (OpenAI gpt-4o-mini or Anthropic Claude), configure /settings/knowledge, restart LightRAG. The wizard collapses and the knowledge list appears.

Read the package READMEs (reins/nestjs/README.md and reins/nuxt/README.md) for full reference.
````

## Packages

| Directory | Description | Stack |
|---|---|---|
| `nestjs/` | API slice: Knowledge + Source CRUD, LightRAG client, config gateway | NestJS, Prisma 6 |
| `nuxt/` | Nuxt layer: knowledge admin pages, components, store, setup wizard | Nuxt 3, Vue 3, Pinia, shadcn-vue |
| `docs/` | Documentation site (VitePress), published at [reins.cleanslice.org](https://reins.cleanslice.org) | VitePress |

## Architecture

```
Browser (admin Nuxt)         CleanSlice API (NestJS)         LightRAG (separate)
       |                              |                                |
       |--- /knowledges/* ----------->|                                |
       |                              |--- POST /documents/text ------>|
       |                              |--- POST /query --------------->|
       |<--- response -----------|<--- response -----------------|
                                      |
                                      |--- ILlmGateway.* (host's llm slice)
                                      |--- ISettingGateway.* (host's setting slice)
                                      |--- S3Repository.* (host's aws slice)
```

## What reins is not

- An identity / auth provider. Use the host's existing auth.
- A LightRAG deployment. Deploy LightRAG via your own docker-compose or k8s.
- A generic LLM credentials manager. Use the host's `llm` slice.
- A standalone application. Reins is a template for CleanSlice projects.

## Status

Phase 1 (this release): NestJS slice + Nuxt layer + core docs. Manual restart required after credential changes.

Phase 2 (planned): auto-sync of credential settings into the LightRAG container env, removing the manual restart step.

## License

TBD by CleanSlice.
