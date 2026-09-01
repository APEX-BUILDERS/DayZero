import { Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../database/prisma.service';
import { LlmWorkspaceClient } from './llm-workspace.client';

const workspaceInclude = {
  tasks: {
    include: {
      notes: true,
      scheduleBlocks: true,
    },
    orderBy: [{ deadline: 'asc' as const }, { createdAt: 'asc' as const }],
  },
  blocks: {
    include: { task: true },
    orderBy: [{ date: 'asc' as const }, { createdAt: 'asc' as const }],
  },
  notes: true,
};

@Injectable()
export class WorkspaceService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly llm: LlmWorkspaceClient,
  ) {}

  async generate(userId: string, prompt: string) {
    await this.ensureDemoUser(userId);
    const generated = await this.llm.generate(prompt);
    const now = new Date();

    const workspace = await this.prisma.$transaction(async (tx) => {
      const createdWorkspace = await tx.workspace.create({
        data: {
          userId,
          title: generated.workspace_title,
          summary: generated.summary,
          sourcePrompt: prompt,
        },
      });

      const tasksByTitle = new Map<string, { id: string; title: string }>();
      for (const task of generated.tasks) {
        const deadline = this.dateFromOffset(now, task.deadline_offset_days);
        const createdTask = await tx.task.create({
          data: {
            workspaceId: createdWorkspace.id,
            title: task.title,
            priority: task.priority,
            deadline,
            estimatedMinutes: task.estimated_minutes,
            notes: {
              create: {
                workspaceId: createdWorkspace.id,
                body: task.notes,
              },
            },
          },
        });
        tasksByTitle.set(task.title, createdTask);
      }

      for (const block of generated.schedule) {
        const date = this.dateFromOffset(now, block.day_offset);
        for (const taskTitle of block.task_titles) {
          const task = tasksByTitle.get(taskTitle);
          if (!task) {
            continue;
          }

          await tx.scheduleBlock.create({
            data: {
              workspaceId: createdWorkspace.id,
              taskId: task.id,
              date,
              label: block.block_label,
            },
          });
        }
      }

      await tx.note.create({
        data: {
          workspaceId: createdWorkspace.id,
          body: generated.summary,
        },
      });

      return tx.workspace.findUniqueOrThrow({
        where: { id: createdWorkspace.id },
        include: workspaceInclude,
      });
    });

    return workspace;
  }

  async findOne(userId: string, workspaceId: string) {
    const workspace = await this.prisma.workspace.findFirst({
      where: { id: workspaceId, userId },
      include: workspaceInclude,
    });

    if (!workspace) {
      throw new NotFoundException('Workspace not found');
    }

    return workspace;
  }

  private dateFromOffset(now: Date, offsetDays: number) {
    const date = new Date(now);
    date.setDate(date.getDate() + offsetDays);
    date.setHours(9, 0, 0, 0);
    return date;
  }

  private async ensureDemoUser(userId: string) {
    await this.prisma.user.upsert({
      where: { id: userId },
      update: {},
      create: {
        id: userId,
        email: `${userId}@dayzero.demo`,
        name: 'DayZero Demo User',
      },
    });
  }
}
