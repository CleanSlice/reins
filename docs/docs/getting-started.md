# Getting started

This page walks through installing reins into a CleanSlice project.

## Prerequisites

The host must have:

- Prisma + `prisma-import` configured (`schemas: "./src/**/!(schema).prisma"` in `api/package.json`).
- `llm` slice with `LlmCredential` table including `supportsChat: Boolean` and `supportsEmbedding: Boolean` columns. `ILlmGateway` interface with `hasCredentialWithCapability(capability: 'chat' | 'embedding'): Promise<boolean>`.
- `setting` slice with `ISettingGateway.findByKey(group: string, key: string)` that returns a record with a `value: unknown` field.
- `aws/s3` slice with an `S3Repository` class and `AwsModule`.
- A LightRAG service deployed and reachable (see [LightRAG setup](./lightrag)).
- Nuxt admin with `#theme` alias resolving to shadcn-vue components.

## Quick Install via Claude Code

The fastest path is to paste the Quick Install prompt from the [repo README](https://github.com/CleanSlice/reins#quick-install) into Claude Code. The agent clones the repo, copies files into the right slices, sets env vars, and walks the verification.

## Manual install

If you prefer to do it by hand:

1. Clone the reins repo:

   ```bash
   git clone https://github.com/CleanSlice/reins.git
   ```

2. Copy the NestJS slice into your API:

   ```bash
   cp -r reins/nestjs/* /path/to/your-project/api/src/slices/reins/
   ```

3. Run the migrate command in the host's `api/`:

   ```bash
   cd /path/to/your-project/api
   npm run migrate
   ```

   This merges `knowledge.prisma` and `source.prisma` into your combined schema and creates an auto migration.

4. Add `ReinsModule` to the host's `app.module.ts`:

   ```ts
   import { ReinsModule } from './slices/reins';
   @Module({ imports: [ReinsModule] })
   export class AppModule {}
   ```

5. Set env vars in the host's `api/.env`:

   ```
   LIGHTRAG_URL=http://localhost:9621
   LIGHTRAG_API_KEY=<shared secret>
   REINS_S3_BUCKET=<bucket name>
   ```

6. Copy the Nuxt layer into your admin:

   ```bash
   cp -r reins/nuxt/* /path/to/your-project/admin/slices/reins/
   ```

7. Add the layer to the host's `admin/nuxt.config.ts`:

   ```ts
   export default defineNuxtConfig({
     extends: ['./slices/reins'],
   });
   ```

8. Add a sidebar link to `/settings/knowledge` in your settings nav. The page itself ships from the layer.

9. Start the API and admin. Open `/knowledges` in the browser. The setup wizard guides you through creating credentials, configuring the service, and verifying the LightRAG connection.

## Verifying the install

After all four wizard steps are green, you should see:

- The knowledge list at `/knowledges` (the wizard collapses).
- The settings page at `/settings/knowledge` with three cards (service toggle, LLM credential pickers, service connection details).
- The LLM credential form at `/llms/create` showing capability checkboxes.

If the wizard stays red on step 4 (LightRAG unreachable), see [LightRAG setup](./lightrag) for troubleshooting.
