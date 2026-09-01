import { Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../database/prisma.service';
import { SchedulerService } from '../scheduler/scheduler.service';
import { UpdateTaskDto } from '../workspace/dto/update-task.dto';

@Injectable()
export class TaskService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly scheduler: SchedulerService,
  ) {}

  async update(userId: string, taskId: string, dto: UpdateTaskDto) {
    const existing = await this.prisma.task.findFirst({
      where: { id: taskId, workspace: { userId } },
    });

    if (!existing) {
      throw new NotFoundException('Task not found');
    }

    const data: Prisma.TaskUpdateInput = {
      title: dto.title,
      priority: dto.priority,
      status: dto.status,
      estimatedMinutes: dto.estimatedMinutes,
      deadline: dto.deadline ? new Date(dto.deadline) : undefined,
    };

    const updated = await this.prisma.task.update({
      where: { id: taskId },
      data,
      include: {
        notes: true,
        scheduleBlocks: true,
      },
    });

    if (dto.scheduleDate) {
      await this.prisma.scheduleBlock.deleteMany({ where: { taskId } });
      await this.prisma.scheduleBlock.create({
        data: {
          workspaceId: existing.workspaceId,
          taskId,
          date: new Date(dto.scheduleDate),
          label: 'Moved focus block',
        },
      });

      return this.prisma.task.findUniqueOrThrow({
        where: { id: taskId },
        include: {
          notes: true,
          scheduleBlocks: true,
        },
      });
    }

    if (dto.status === 'missed') {
      return this.scheduler.rescheduleTask(userId, taskId);
    }

    return updated;
  }

  reschedule(userId: string, taskId: string) {
    return this.scheduler.rescheduleTask(userId, taskId);
  }
}
