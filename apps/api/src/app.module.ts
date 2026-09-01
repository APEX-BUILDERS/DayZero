import { Module } from '@nestjs/common';
import { DatabaseModule } from './database/database.module';
import { SchedulerModule } from './scheduler/scheduler.module';
import { TaskModule } from './task/task.module';
import { WorkspaceModule } from './workspace/workspace.module';

@Module({
  imports: [DatabaseModule, SchedulerModule, WorkspaceModule, TaskModule],
})
export class AppModule {}
