import { Injectable } from '@nestjs/common';
import { GeneratedWorkspace, generatedWorkspaceSchema } from './workspace-generator.schema';
import { workspaceSystemPrompt } from './workspace-prompts';

@Injectable()
export class LlmWorkspaceClient {
  async generate(prompt: string): Promise<GeneratedWorkspace> {
    const apiKey = process.env.ANTHROPIC_API_KEY || process.env.LLM_API_KEY;
    if (!apiKey) {
      return this.demoWorkspace(prompt);
    }

    const first = await this.callAnthropic(apiKey, prompt);
    const parsed = this.parseAndValidate(first);
    if (parsed) {
      return parsed;
    }

    const repaired = await this.callAnthropic(
      apiKey,
      `Repair the previous malformed output. Return strict JSON only matching the requested schema. User prompt: ${prompt}`,
    );
    const repairedParsed = this.parseAndValidate(repaired);
    return repairedParsed ?? this.demoWorkspace(prompt);
  }

  private async callAnthropic(apiKey: string, prompt: string): Promise<string> {
    const response = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'content-type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: JSON.stringify({
        model: process.env.ANTHROPIC_MODEL || 'claude-sonnet-4-6',
        max_tokens: 2200,
        temperature: 0.2,
        system: workspaceSystemPrompt,
        messages: [{ role: 'user', content: prompt }],
      }),
    });

    if (!response.ok) {
      throw new Error(`Anthropic workspace generation failed: ${response.status}`);
    }

    const data = (await response.json()) as { content?: Array<{ type: string; text?: string }> };
    return data.content?.find((part) => part.type === 'text')?.text ?? '';
  }

  private parseAndValidate(raw: string): GeneratedWorkspace | null {
    try {
      const jsonStart = raw.indexOf('{');
      const jsonEnd = raw.lastIndexOf('}');
      const json = jsonStart >= 0 && jsonEnd >= jsonStart ? raw.slice(jsonStart, jsonEnd + 1) : raw;
      return generatedWorkspaceSchema.parse(JSON.parse(json));
    } catch {
      return null;
    }
  }

  private demoWorkspace(prompt: string): GeneratedWorkspace {
    const lower = prompt.toLowerCase();
    const isHackathon = lower.includes('hackathon') || lower.includes('pitch');
    const isStudent = lower.includes('assignment') || lower.includes('project') || lower.includes('college');
    const title = isHackathon
      ? 'Hackathon Pitch Launch Plan'
      : isStudent
        ? 'Project and Assignment Control Plan'
        : 'Focused Weekly Action Plan';

    const tasks = [
      {
        title: isHackathon ? 'Lock the pitch story arc' : 'Define the top outcome for the week',
        notes: 'Write the problem, promise, and demo moment in plain language.',
        priority: 'high' as const,
        deadline_offset_days: 0,
        estimated_minutes: 45,
      },
      {
        title: isHackathon ? 'Polish the live demo path' : 'Break the main goal into milestones',
        notes: 'Keep the demo flow short enough to repeat confidently.',
        priority: 'high' as const,
        deadline_offset_days: 1,
        estimated_minutes: 90,
      },
      {
        title: isHackathon ? 'Finish the assignment due first' : 'Clear the nearest deadline',
        notes: 'Handle the highest-risk academic or client deliverable before expanding scope.',
        priority: 'high' as const,
        deadline_offset_days: 1,
        estimated_minutes: 120,
      },
      {
        title: isHackathon ? 'Create three judge-ready screenshots' : 'Prepare progress proof',
        notes: 'Capture the output that makes the plan feel concrete and real.',
        priority: 'medium' as const,
        deadline_offset_days: 2,
        estimated_minutes: 40,
      },
      {
        title: isHackathon ? 'Draft the second assignment outline' : 'Draft the next deliverable outline',
        notes: 'Start with headings and required sources so the remaining work is obvious.',
        priority: 'medium' as const,
        deadline_offset_days: 3,
        estimated_minutes: 60,
      },
      {
        title: isHackathon ? 'Run a timed pitch rehearsal' : 'Review and adjust the weekly plan',
        notes: 'Practice once with the actual device and trim anything that slows the story.',
        priority: 'medium' as const,
        deadline_offset_days: 4,
        estimated_minutes: 30,
      },
      {
        title: isHackathon ? 'Prepare fallback answers for Q&A' : 'Prepare blockers and next actions',
        notes: 'List the likely questions, risks, and next steps before the final review.',
        priority: 'low' as const,
        deadline_offset_days: 5,
        estimated_minutes: 35,
      },
    ];

    return {
      workspace_title: title,
      summary: `A practical schedule for: ${prompt}`,
      tasks,
      schedule: [
        { day_offset: 0, block_label: 'Today focus block', task_titles: [tasks[0].title] },
        { day_offset: 1, block_label: 'Tomorrow deep work', task_titles: [tasks[1].title, tasks[2].title] },
        { day_offset: 2, block_label: 'Proof and polish', task_titles: [tasks[3].title] },
        { day_offset: 3, block_label: 'Assignment progress block', task_titles: [tasks[4].title] },
        { day_offset: 4, block_label: 'Rehearsal and review', task_titles: [tasks[5].title] },
        { day_offset: 5, block_label: 'Final buffer', task_titles: [tasks[6].title] },
      ],
    };
  }
}
