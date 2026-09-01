import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'workspace_controller.dart';
import 'workspace_models.dart';

class WorkspaceGeneratorScreen extends ConsumerStatefulWidget {
  const WorkspaceGeneratorScreen({super.key});

  @override
  ConsumerState<WorkspaceGeneratorScreen> createState() => _WorkspaceGeneratorScreenState();
}

class _WorkspaceGeneratorScreenState extends ConsumerState<WorkspaceGeneratorScreen> {
  final _promptController = TextEditingController(
    text: "I'm prepping for a hackathon pitch this week and also have two assignments due",
  );

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workspaceControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: _PromptPanel(
                  controller: _promptController,
                  isLoading: state.isLoading,
                  onGenerate: _generate,
                ),
              ),
            ),
            state.when(
              data: (workspace) => workspace == null
                  ? const SliverFillRemaining(hasScrollBody: false, child: _EmptyState())
                  : SliverToBoxAdapter(child: _WorkspaceView(workspace: workspace)),
              error: (error, _) => SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('Workspace generation failed: $error'),
                  ),
                ),
              ),
              loading: () => const SliverToBoxAdapter(child: _LoadingWorkspace()),
            ),
          ],
        ),
      ),
    );
  }

  void _generate() {
    final prompt = _promptController.text.trim();
    if (prompt.length < 8) {
      return;
    }
    ref.read(workspaceControllerProvider.notifier).generate(prompt);
  }
}

class _PromptPanel extends StatelessWidget {
  const _PromptPanel({
    required this.controller,
    required this.isLoading,
    required this.onGenerate,
  });

  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    final suggestions = [
      'Plan my week',
      'Organize my final-year project',
      'Get my freelance work under control',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.bolt, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'DayZero',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        TextField(
          controller: controller,
          minLines: 2,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: 'What are you working on?',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            suffixIcon: Padding(
              padding: const EdgeInsets.all(8),
              child: IconButton.filled(
                tooltip: 'Generate workspace',
                onPressed: isLoading ? null : onGenerate,
                icon: const Icon(Icons.arrow_forward),
              ),
            ),
          ),
          onSubmitted: (_) => onGenerate(),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final suggestion in suggestions)
              ActionChip(
                label: Text(suggestion),
                avatar: const Icon(Icons.auto_awesome, size: 16),
                onPressed: () => controller.text = suggestion,
              ),
          ],
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.view_timeline, size: 56, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            const Text(
              'A generated task list, schedule, and notes will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkspaceView extends ConsumerWidget {
  const _WorkspaceView({required this.workspace});

  final Workspace workspace;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = _workspaceDays(workspace);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(workspace.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(workspace.summary, style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 760;
              return Flex(
                direction: narrow ? Axis.vertical : Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: narrow ? 0 : 5,
                    child: _TaskList(workspace: workspace),
                  ),
                  SizedBox(width: narrow ? 0 : 16, height: narrow ? 16 : 0),
                  Expanded(
                    flex: narrow ? 0 : 4,
                    child: _Timeline(days: days),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  List<_WorkspaceDay> _workspaceDays(Workspace workspace) {
    final byDate = <DateTime, List<WorkspaceTask>>{};
    for (final block in workspace.blocks) {
      WorkspaceTask? task;
      for (final item in workspace.tasks) {
        if (item.id == block.taskId) {
          task = item;
          break;
        }
      }
      if (task == null) {
        continue;
      }
      final day = DateTime(block.date.year, block.date.month, block.date.day);
      byDate.putIfAbsent(day, () => []).add(task);
    }

    return byDate.entries
        .map((entry) => _WorkspaceDay(date: entry.key, tasks: entry.value))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }
}

class _TaskList extends StatelessWidget {
  const _TaskList({required this.workspace});

  final Workspace workspace;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(icon: Icons.check_circle_outline, title: 'Tasks'),
        const SizedBox(height: 8),
        for (final task in workspace.tasks) _TaskCard(task: task),
      ],
    );
  }
}

class _Timeline extends ConsumerWidget {
  const _Timeline({required this.days});

  final List<_WorkspaceDay> days;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(icon: Icons.calendar_month, title: 'Schedule'),
        const SizedBox(height: 8),
        for (final day in days)
          DragTarget<WorkspaceTask>(
            onAcceptWithDetails: (details) {
              ref.read(workspaceControllerProvider.notifier).moveTaskToDay(details.data.id, day.date);
            },
            builder: (context, _, __) => Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(DateFormat('EEE, MMM d').format(day.date), style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  for (final task in day.tasks)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.drag_indicator, size: 18),
                          const SizedBox(width: 6),
                          Expanded(child: Text(task.title, maxLines: 2, overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _TaskCard extends ConsumerWidget {
  const _TaskCard({required this.task});

  final WorkspaceTask task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final priorityColor = switch (task.priority) {
      'high' => const Color(0xFFB42318),
      'medium' => const Color(0xFFB7791F),
      _ => const Color(0xFF216869),
    };

    final card = Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(task.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 8),
              _PriorityBadge(priority: task.priority, color: priorityColor),
            ],
          ),
          const SizedBox(height: 8),
          if (task.note != null) Text(task.note!, style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _MetaPill(icon: Icons.event, label: task.deadline == null ? 'No deadline' : DateFormat('MMM d').format(task.deadline!)),
              if (task.estimatedMinutes != null) _MetaPill(icon: Icons.timer, label: '${task.estimatedMinutes} min'),
              _MetaPill(icon: Icons.flag, label: task.status),
              IconButton.outlined(
                tooltip: 'Edit task',
                onPressed: () => _showEditTaskSheet(context, ref, task),
                icon: const Icon(Icons.edit),
              ),
              IconButton.outlined(
                tooltip: 'Mark missed and auto-reschedule',
                onPressed: () => ref.read(workspaceControllerProvider.notifier).markMissed(task.id),
                icon: const Icon(Icons.update),
              ),
            ],
          ),
        ],
      ),
    );

    return LongPressDraggable<WorkspaceTask>(
      data: task,
      feedback: Material(
        color: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Opacity(opacity: 0.92, child: card),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.45, child: card),
      child: card,
    );
  }

  void _showEditTaskSheet(BuildContext context, WidgetRef ref, WorkspaceTask task) {
    final titleController = TextEditingController(text: task.title);
    var priority = task.priority;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Task title'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: priority,
              decoration: const InputDecoration(labelText: 'Priority'),
              items: const [
                DropdownMenuItem(value: 'high', child: Text('High')),
                DropdownMenuItem(value: 'medium', child: Text('Medium')),
                DropdownMenuItem(value: 'low', child: Text('Low')),
              ],
              onChanged: (value) => priority = value ?? priority,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                ref.read(workspaceControllerProvider.notifier).updateTask(
                      task.id,
                      title: titleController.text.trim(),
                      priority: priority,
                    );
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.save),
              label: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority, required this.color});

  final String priority;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(priority.toUpperCase(), style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800)),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade700),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: Colors.grey.shade800)),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 6),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _LoadingWorkspace extends StatelessWidget {
  const _LoadingWorkspace();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 240, height: 28, color: Colors.grey.shade200),
          const SizedBox(height: 14),
          for (var i = 0; i < 6; i++)
            Container(
              height: 82,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
            ),
        ],
      ),
    );
  }
}

class _WorkspaceDay {
  _WorkspaceDay({required this.date, required this.tasks});

  final DateTime date;
  final List<WorkspaceTask> tasks;
}
