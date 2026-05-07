# Reins Nuxt Layer

Knowledge / RAG admin UI for CleanSlice projects. Pages, components, stores, and a setup wizard.

## Prerequisites

The host Nuxt admin must provide:

- `#theme` alias resolving to a shadcn-vue compatible theme. The layer uses these components:
  - `#theme/components/ui/button` - `Button`
  - `#theme/components/ui/card` - `Card`, `CardHeader`, `CardTitle`, `CardDescription`, `CardContent`, `CardFooter`
  - `#theme/components/ui/checkbox` - `Checkbox`
  - `#theme/components/ui/input` - `Input`
  - `#theme/components/ui/label` - `Label`
  - `#theme/components/ui/textarea` - `Textarea`
  - `#theme/components/ui/scroll-area` - `ScrollArea`
  - `#theme/components/ui/table` - `Table`, `TableHeader`, `TableBody`, `TableRow`, `TableHead`, `TableCell`
  - `#theme/components/ui/badge` - (used in some layouts)
- A generated API client at `#api/data` with `KnowledgesService`, `KnowledgeSourcesService`, `LlmsService`, `SettingsService`. The store calls these.
- `useLlmStore` (from the host's `llm` slice) exposing items with `supportsChat`, `supportsEmbedding`, `status` fields.
- `useSettingStore` (from the host's `setting` slice) with `fetchAll`, `get(group, key)`, `upsert(group, key, value, valueType)`.
- A sidebar menu store at `#common/stores/menu` with `addSidebar({ id, group, title, link, active, icon, sortOrder })` and a `MenuGroupTypes` enum.

## Setup

1. Copy this directory into `admin/slices/reins/`.

2. Add the layer to the host Nuxt config:

   ```ts
   // admin/nuxt.config.ts
   export default defineNuxtConfig({
     extends: ['./slices/reins'],
   });
   ```

3. Add a sidebar link to `/settings/knowledge` in your settings nav. The page itself ships from this layer.

4. Verify dependencies are installed in the admin:

   ```bash
   npm i @vueuse/core @tabler/icons-vue clsx tailwind-merge
   ```

   Pinia, `@pinia/nuxt`, Tailwind, and Nuxt itself should already be in the host.

## Routes added by this layer

| Route | Description |
|---|---|
| `/knowledges` | List of knowledge bases. Renders the setup wizard if not fully configured. |
| `/knowledges/create` | Create a new knowledge base. |
| `/knowledges/:id` | Knowledge detail wrapper with tab navigation. |
| `/knowledges/:id/edit` | Edit knowledge metadata. |
| `/knowledges/:id/sources` | Manage sources (text, url, file). |
| `/knowledges/:id/graph` | Visualize the knowledge graph. |
| `/knowledges/:id/query` | Query the knowledge with mode and topK controls. |
| `/settings/knowledge` | Knowledge service settings: enable, URL, S3 bucket, chat / embedding credential pickers. |

## Components

| Component | Purpose |
|---|---|
| `KnowledgeSetupWizard` | Renders 4 setup steps with done / pending state and copy-to-clipboard buttons for restart commands. |
| `KnowledgeListProvider` | Search box and table of knowledge bases. |
| `KnowledgeCreateProvider` / `KnowledgeEditProvider` | Form wrapper for create / edit pages. |
| `KnowledgeSourcesProvider`, `KnowledgeSourcesAddForm` | Source list and add form. |
| `KnowledgeGraphProvider` | D3 graph rendering. |
| `KnowledgeQueryProvider` | Query input and answer display. |
| `IndexStatusBadge` | Shows index status (idle / indexing / ready / failed). |
| `KnowledgeForm` | Reusable form for create / edit. |

## Stores

`useKnowledgeStore` (from `#reins/stores/knowledge`):

| Method | Purpose |
|---|---|
| `fetchStatus()` | GET `/knowledges/status`, populates `enabled` and `setup` refs. |
| `fetchAll()` | GET `/knowledges`. |
| `fetchById(id)` | GET `/knowledges/:id`. |
| `create / update / remove` | CRUD. |
| `startIndex(id)` | POST `/knowledges/:id/index`. |
| `query(id, q, mode, topK)` | POST `/knowledges/:id/query`. |
| `listSources / addTextSource / addUrlSource / addFileSource / removeSource` | Source CRUD. |
| `getGraphLabels / getGraph` | Graph endpoints. |

## Standalone dev (for layer maintainers)

```bash
cd nuxt
npm install
npm run dev
```

This uses the local `theme/` fallback and a stub API. Useful for working on components in isolation. Note that the wizard's status probe will fail without a backend; this is expected in standalone mode.
