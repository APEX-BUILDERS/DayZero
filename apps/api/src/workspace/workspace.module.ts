import { Module } from '@nestjs/common';
import { WorkspaceController } from './workspace.controller';
import { LlmWorkspaceClient } from './llm-workspace.client';
import { WorkspaceService } from './workspace.service';

@Module({
  controllers: [WorkspaceController],
  providers: [WorkspaceService, LlmWorkspaceClient],
  exports: [WorkspaceService],
})
export class WorkspaceModule {}
