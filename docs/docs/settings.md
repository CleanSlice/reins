# Settings reference

Reins reads runtime configuration from the host's `setting` table (group `knowledge`). Env vars provide fallback defaults. When a setting is non-empty, it takes precedence over the env var.

## Keys

| Setting key | Env fallback | Type | Description |
|---|---|---|---|
| `knowledge/url` | `LIGHTRAG_URL` | string | LightRAG service URL. |
| `knowledge/api_key` | `LIGHTRAG_API_KEY` | string | Shared secret matching LightRAG's `LIGHTRAG_API_KEY`. |
| `knowledge/s3_bucket` | `REINS_S3_BUCKET` | string | S3 bucket where source files are stored. |
| `knowledge/enabled` | (true) | boolean | Master switch. When `false`, all `/knowledges/*` mutations return 503 and the admin shows a wizard. |
| `knowledge/chat_credential_id` | (none) | string | Pointer to a row in `LlmCredential.id`. Used to provision LightRAG's LLM binding (manual restart required after change). |
| `knowledge/embedding_credential_id` | (none) | string | Pointer to a row in `LlmCredential.id`. Used to provision LightRAG's embedding binding. |

## Storage type

`knowledge/enabled` is stored as JSON (`true` or `false` boolean). All others are strings.

## Validation

`knowledge/enabled = true` requires both credential ids to be set. The admin's `/settings/knowledge` page rejects the save with an error message until the user fills both pickers.

## Endpoint exposure

`GET /knowledges/status` returns:

```json
{
  "enabled": true,
  "setup": {
    "hasChatCredential": true,
    "hasEmbeddingCredential": true,
    "hasUrl": true,
    "hasBucket": true,
    "hasCredentialsSelected": true,
    "isHealthy": true
  }
}
```

The wizard reads `setup` to color its 4 steps.
