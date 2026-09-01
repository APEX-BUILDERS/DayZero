import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';

@Injectable()
export class SchedulerService {
  constructor(private readonly prisma: PrismaService) {}

  async rescheduleTask(userId: string, taskId: string) {
    const task = await this.prisma.task.findFirst({
      where: {
        id: taskId,
        workspace: { userId },
      },
      include: { workspace: true },
    });

    if (!task) {
      throw new NotFoundException('Task not found');
    }

    const nextDate = this.nextOpenDemoSlot(task.deadline ?? new Date());
    await this.prisma.scheduleBlock.deleteMany({ where: { taskId } });
    await this.prisma.scheduleBlock.create({
      data: {
        workspaceId: task.workspaceId,
        taskId,
        date: nextDate,
        label: 'Auto-rescheduled focus block',
      },
    });

    return this.prisma.task.update({
      where: { id: taskId },
      data: {
        status: 'rescheduled',
        deadline: nextDate,
      },
      include: {
        notes: true,
        scheduleBlocks: true,
      },
    });
  }

  private nextOpenDemoSlot(anchor: Date) {
    const next = new Date(Math.max(anchor.getTime(), Date.now()));
    next.setDate(next.getDate() + 1);
    next.setHours(10, 0, 0, 0);
    return next;
  }
}
