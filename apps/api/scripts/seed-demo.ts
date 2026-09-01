import 'reflect-metadata';
import { PrismaClient } from '@prisma/client';
import { LlmWorkspaceClient } from '../src/workspace/llm-workspace.client';

const prisma = new PrismaClient();
const prompt = "I'm prepping for a hackathon pitch this week and also have two assignments due";
const userId = process.env.DEMO_USER_ID || 'demo-user';

function dateFromOffset(now: Date, offsetDays: number) {
  const date = new Date(now);
  date.setDate(date.getDate() + offsetDays);
  date.setHours(9, 0, 0, 0);
  return date;
}

async function main() {
  const generated = await new LlmWorkspaceClient().generate(prompt);
  const now = new Date();

  await prisma.user.upsert({
    where: { id: userId },
    update: {},
    create: { id: userId, email: 'demo@dayzero.local', name: 'DayZero Demo User' },
  });

  const workspace = await prisma.workspace.create({
    data: {
      userId,
      title: generated.workspace_title,
      summary: generated.summary,
      sourcePrompt: prompt,
    },
  });

  const tasksByTitle = new Map<string, string>();
  for (const task of generated.tasks) {
    const createdTask = await prisma.task.create({
      data: {
        workspaceId: workspace.id,
        title: task.title,
        priority: task.priority,
        deadline: dateFromOffset(now, task.deadline_offset_days),
        estimatedMinutes: task.estimated_minutes,
        notes: {
          create: {
            workspaceId: workspace.id,
            body: task.notes,
          },
        },
      },
    });
    tasksByTitle.set(task.title, createdTask.id);
  }

  for (const block of generated.schedule) {
    for (const title of block.task_titles) {
      const taskId = tasksByTitle.get(title);
      if (!taskId) {
        continue;
      }

      await prisma.scheduleBlock.create({
        data: {
          workspaceId: workspace.id,
          taskId,
          label: block.block_label,
          date: dateFromOffset(now, block.day_offset),
        },
      });
    }
  }

  console.log(`Seeded demo workspace: ${workspace.id}`);
}

main()
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
