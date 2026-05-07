# LLM credentials

Reins selects which LLM credential LightRAG uses for chat completions and which it uses for embeddings. Both are pointers into the host's `LlmCredential` table.

## Capability flags

The host's `LlmCredential` model must include two boolean columns:

```prisma
model LlmCredential {
  // existing fields...
  supportsChat      Boolean @default(true)
  supportsEmbedding Boolean @default(false)
}
```

A credential can support either or both. The reins admin filters credentials in the settings dropdowns by these flags:

- "Chat LLM credential" picker shows only `supportsChat = true` rows.
- "Embedding LLM credential" picker shows only `supportsEmbedding = true` rows.

The host's `ILlmGateway` must expose:

```ts
hasCredentialWithCapability(capability: 'chat' | 'embedding'): Promise<boolean>;
```

The status endpoint calls this to populate `setup.hasChatCredential` and `setup.hasEmbeddingCredential`.

## Workflow

1. The user opens `/knowledges`. The wizard shows step 1 red.
2. The user clicks "Create embedding credential" and lands on `/llms/create?capability=embedding`. The form pre-checks the embedding flag.
3. The user picks a provider (e.g. OpenAI) and an embedding model (e.g. `text-embedding-3-small`). The form auto-fills `supportsEmbedding=true, supportsChat=false` from the model's static capability definition. The user enters an API key and saves.
4. The user repeats for a chat credential.
5. The user opens `/settings/knowledge`, picks both credentials in the dropdowns, sets the URL and S3 bucket, toggles enable, and saves.
6. The user restarts the LightRAG container so it picks up the new bindings (this is manual in Phase 1; see [LightRAG setup](./lightrag)).

## Why two credentials

LightRAG uses different models for two roles:

- **Chat / completion**: answers user queries against the knowledge graph. GPT-4o, Claude, Gemini all work.
- **Embedding**: turns source chunks into vectors at ingest time. Only embedding models work here (`text-embedding-3-small`, etc).

Some providers offer both kinds of models. Some only offer one. The capability flags let users mix providers (e.g. Anthropic Claude for chat, OpenAI for embedding) without UI confusion.

## Phase 2: auto-sync

The current phase requires a LightRAG container restart after credential changes. Phase 2 will add an auto-sync step: when settings change, the API rewrites the LightRAG environment (k8s secret patch or docker-compose env file) and triggers a restart. Until then, the wizard's step 4 reminds users to do this manually.
