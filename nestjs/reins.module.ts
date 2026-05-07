import { Module } from '@nestjs/common';
import { KnowledgeModule } from './knowledge/knowledge.module';
import { SourceModule } from './source/source.module';

/**
 * Reins Module: Knowledge / RAG slice for CleanSlice projects.
 *
 * Bundles:
 *   - KnowledgeModule: CRUD for knowledge bases plus /knowledges/status with setup readiness.
 *   - SourceModule: CRUD for sources attached to a knowledge.
 *
 * Sub-modules pull their own deps transitively:
 *   - ConfigModule (knowledge config gateway, reads url/api_key/bucket/credential ids from settings)
 *   - LightragModule (HTTP client to LightRAG service)
 *   - AwsModule (S3 storage for source files)
 *
 * Host requirements:
 *   - Prisma + prisma-import configured to merge knowledge.prisma and source.prisma.
 *   - llm slice with ILlmGateway.hasCredentialWithCapability and supportsChat / supportsEmbedding columns on LlmCredential.
 *   - setting slice with ISettingGateway.findByKey.
 *   - aws/s3 slice with S3Repository.
 *   - LightRAG service deployed (docker-compose or k8s); see docs/lightrag.md.
 *
 * Usage:
 *
 * ```ts
 * import { ReinsModule } from './slices/reins';
 *
 * @Module({ imports: [ReinsModule] })
 * export class AppModule {}
 * ```
 */
@Module({
  imports: [KnowledgeModule, SourceModule],
  exports: [KnowledgeModule, SourceModule],
})
export class ReinsModule {}
