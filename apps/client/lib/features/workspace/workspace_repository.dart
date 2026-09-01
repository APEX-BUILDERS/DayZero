import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import 'workspace_models.dart';

final workspaceRepositoryProvider = Provider<WorkspaceRepository>((ref) {
  return WorkspaceRepository(ref.watch(dioProvider));
});

class WorkspaceRepository {
  WorkspaceRepository(this._dio);

  final Dio _dio;

  Future<Workspace> generate(String prompt) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/workspace/generate',
      data: {'prompt': prompt},
    );
    return Workspace.fromJson(response.data!);
  }

  Future<WorkspaceTask> updateTask(
    String taskId, {
    String? title,
    String? priority,
    DateTime? deadline,
    String? status,
    DateTime? scheduleDate,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/task/$taskId',
      data: {
        if (title != null) 'title': title,
        if (priority != null) 'priority': priority,
        if (deadline != null) 'deadline': deadline.toIso8601String(),
        if (status != null) 'status': status,
        if (scheduleDate != null) 'scheduleDate': scheduleDate.toIso8601String(),
      },
    );
    return WorkspaceTask.fromJson(response.data!);
  }

  Future<WorkspaceTask> reschedule(String taskId) async {
    final response = await _dio.post<Map<String, dynamic>>('/task/$taskId/reschedule');
    return WorkspaceTask.fromJson(response.data!);
  }
}
