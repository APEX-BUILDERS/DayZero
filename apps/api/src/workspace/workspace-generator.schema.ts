import { z } from 'zod';

export const generatedWorkspaceSchema = z.object({
  workspace_title: z.string().min(3).max(80),
  summary: z.string().min(8).max(220),
  tasks: z
    .array(
      z.object({
        title: z.string().min(3).max(120),
        notes: z.string().min(5).max(260),
        priority: z.enum(['high', 'medium', 'low']),
        deadline_offset_days: z.number().int().min(0).max(30),
        estimated_minutes: z.number().int().min(10).max(240),
      }),
    )
    .min(5)
    .max(10),
  schedule: z
    .array(
      z.object({
        day_offset: z.number().int().min(0).max(14),
        block_label: z.string().min(3).max(80),
        task_titles: z.array(z.string().min(3)).min(1).max(4),
      }),
    )
    .min(3)
    .max(7),
});

export type GeneratedWorkspace = z.infer<typeof generatedWorkspaceSchema>;
