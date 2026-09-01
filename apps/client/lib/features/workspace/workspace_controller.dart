import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'workspace_models.dart';
import 'workspace_repository.dart';

final workspaceControllerProvider =
    StateNotifierProvider<WorkspaceController, AsyncValue<Workspace?>>((ref) {
  return WorkspaceController(ref.watch(workspaceRepositoryProvider));
});

class WorkspaceController extends StateNotifier<AsyncValue<Workspace?>> {
  WorkspaceController(this._repository) : super(const AsyncData(null));

  final WorkspaceRepository _repository;

  Future<void> generate(String prompt) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.generate(prompt));
  }

  Future<void> updateTask(String taskId, {String? title, String? priority, DateTime? deadline}) async {
    final workspace = state.valueOrNull;
    if (workspace == null) {
      return;
    }

    final updated = await _repository.updateTask(
      taskId,
      title: title,
      priority: priority,
      deadline: deadline,
    );
    _replaceTask(updated);
  }

  Future<void> moveTaskToDay(String taskId, DateTime day) async {
    final workspace = state.valueOrNull;
    if (workspace == null) {
      return;
    }

    final updated = await _repository.updateTask(taskId, deadline: day, scheduleDate: day);
    final movedBlocks = [
      ...workspace.blocks.where((block) => block.taskId != taskId),
      ...updated.scheduleBlocks,
    ];
    _replaceTask(updated, blocks: movedBlocks);
  }

  Future<void> markMissed(String taskId) async {
    final updated = await _repository.updateTask(taskId, status: 'missed');
    _replaceTask(updated);
  }

  Future<void> reschedule(String taskId) async {
    final updated = await _repository.reschedule(taskId);
    _replaceTask(updated);
  }

  void _replaceTask(WorkspaceTask updated, {List<ScheduleBlock>? blocks}) {
    final workspace = state.valueOrNull;
    if (workspace == null) {
      return;
    }

    final nextBlocks = blocks ??
        [
          ...workspace.blocks.where((block) => block.taskId != updated.id),
          ...updated.scheduleBlocks,
        ];

    state = AsyncData(
      workspace.copyWith(
        tasks: workspace.tasks.map((task) => task.id == updated.id ? updated : task).toList(),
        blocks: nextBlocks,
      ),
    );
  }
}
