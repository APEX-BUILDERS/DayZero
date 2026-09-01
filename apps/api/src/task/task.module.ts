import { Module } from '@nestjs/common';
import { SchedulerModule } from '../scheduler/scheduler.module';
import { TaskController } from './task.controller';
import { TaskService } from './task.service';

@Module({
  imports: [SchedulerModule],
  controllers: [TaskController],
  providers: [TaskService],
})
export class TaskModule {}
