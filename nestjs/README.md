# Reins NestJS Slice

Knowledge / RAG slice for CleanSlice projects. Bundles knowledge base CRUD, source ingestion, LightRAG HTTP client, and config gateway.

## Prerequisites

The host CleanSlice project must provide:

- Prisma + `prisma-import` configured to merge slice prismas (`schemas: "./src/**/!(schema).prisma"`).
- `llm` slice exporting `ILlmGateway` with method `hasCredentialWithCapability(capability: 'chat' | 'embedding'): Promise<boolean>`. The `LlmCredential` model must have `supportsChat: Boolean` and `supportsEmbedding: Boolean` columns.
- `setting` slice exporting `ISettingGateway` with `findByKey(group: string, key: string)`.
- `aws/s3` slice exporting `S3Repository` and `AwsModule`.
- A LightRAG service reachable from the API. See `../docs/lightrag.md`.

The slice imports host modules via the following path aliases:

| Alias | Resolves to |
|---|---|
| `#/setup/prisma/prisma.module` | host's PrismaService and module |
| `#/setup/prisma/prisma.service` | host's PrismaService |
| `#/aws/aws.module` | host's AWS module |
| `#/aws/s3` | host's S3Repository (named export) |
| `#/llm/domain` | host's `ILlmGateway` and llm types |
| `#/setting/domain` | host's `ISettingGateway` |

CleanSlice projects with the standard layout configure these aliases in `tsconfig.json` paths and Nest's module resolution.

## Dependencies

```bash
npm i @nestjs/common @nestjs/config @nestjs/core @nestjs/swagger @prisma/client class-transformer class-validator reflect-metadata rxjs
```

Prisma client and prisma CLI come from the host's `api/package.json`.

## Setup

1. Copy this directory into `api/src/slices/reins/`.

2. Run the host's migrate command:

   ```bash
   npm --prefix api run migrate
   ```

   This runs `prisma-import` to merge `knowledge.prisma` and `source.prisma` into the host's combined schema, then generates the migration.

3. Import the umbrella module:

   ```ts
   // api/src/app.module.ts
   import { ReinsModule } from './slices/reins';

   @Module({ imports: [ReinsModule, /* other slices */] })
   export class AppModule {}
   ```

4. Set runtime configuration. Either via environment variables or via the `setting` table at runtime:

   | Source | Variable / setting key | Purpose |
   |---|---|---|
   | env | `LIGHTRAG_URL` | LightRAG service URL |
   | env | `LIGHTRAG_API_KEY` | LightRAG shared secret |
   | env | `REINS_S3_BUCKET` | S3 bucket for source files |
   | setting | `knowledge/url` | Same as `LIGHTRAG_URL`, overrides env |
   | setting | `knowledge/api_key` | Same as `LIGHTRAG_API_KEY` |
   | setting | `knowledge/s3_bucket` | Same as `REINS_S3_BUCKET` |
   | setting | `knowledge/enabled` | `true` / `false`. When `false`, `/knowledges/*` returns 503. |
   | setting | `knowledge/chat_credential_id` | Pointer into `LlmCredential.id` for chat completions in LightRAG. |
   | setting | `knowledge/embedding_credential_id` | Pointer into `LlmCredential.id` for embeddings in LightRAG. |

   Settings take precedence over env vars when set.

## HTTP API

| Endpoint | Description |
|---|---|
| `GET /knowledges` | List all knowledge bases (returns `[]` when `knowledge/enabled` is `false`) |
| `GET /knowledges/status` | Service status and setup readiness (used by the wizard) |
| `GET /knowledges/:id` | Single knowledge by id |
| `POST /knowledges` | Create knowledge |
| `PUT /knowledges/:id` | Update knowledge |
| `DELETE /knowledges/:id` | Delete knowledge |
| `POST /knowledges/:id/index` | Trigger LightRAG ingestion of all sources |
| `POST /knowledges/:id/query` | Query the knowledge graph (mode: hybrid / local / global / naive) |
| `GET /knowledges/graph/labels` | Entity labels in the graph |
| `GET /knowledges/graph` | Get graph subgraph by label |
| `GET /knowledges/:knowledgeId/sources` | List sources |
| `POST /knowledges/:knowledgeId/sources` | Add source (text / url / file) |
| `DELETE /knowledges/:knowledgeId/sources/:sourceId` | Delete source |

`GET /knowledges/status` response shape:

```json
{
  "enabled": true,
  "setup": {
    "hasChatCredential": true,
    "hasEmbeddingCredential": false,
    "hasUrl": true,
    "hasBucket": true,
    "hasCredentialsSelected": false,
    "isHealthy": true
  }
}
```

## Architecture

```
KnowledgeController
  |-> KnowledgeService -> IKnowledgeGateway (Prisma)
  |-> IKnowledgeConfigGateway (settings + env)
  |-> ILightragClient (HTTP to LightRAG)
  |-> ILlmGateway (host)

SourceController
  |-> SourceService -> ISourceGateway (Prisma + S3)
  |-> ILightragClient
  |-> S3Repository (host)

LightragHttpClient -> LightRAG service
```

The `ILightragClient.health()` call has a 2-second `AbortController` timeout to keep the wizard's status probe responsive.

## Known constraints

- LightRAG configures its LLM and embedding bindings at container start. Reins admin picks credentials but does not push them into the LightRAG container in this phase. Restart the container after changing the credential settings. See `../docs/credentials.md`.
- `Source.url` for `type='file'` stores an `s3://bucket/key` URI. Other source types use `type='url'` (external URL) or `type='text'` (inline content).
