import { Body, Controller, Param, Patch, Post } from '@nestjs/common';
import { CurrentUser, RequestUser } from '../common/current-user.decorator';
import { UpdateTaskDto } from '../workspace/dto/update-task.dto';
import { TaskService } from './task.service';

@Controller('task')
export class TaskController {
  constructor(private readonly taskService: TaskService) {}

  @Patch(':id')
  update(@CurrentUser() user: RequestUser, @Param('id') id: string, @Body() dto: UpdateTaskDto) {
    return this.taskService.update(user.id, id, dto);
  }

  @Post(':id/reschedule')
  reschedule(@CurrentUser() user: RequestUser, @Param('id') id: string) {
    return this.taskService.reschedule(user.id, id);
  }
}
