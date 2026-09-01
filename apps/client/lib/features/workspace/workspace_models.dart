class Workspace {
  Workspace({
    required this.id,
    required this.title,
    required this.summary,
    required this.sourcePrompt,
    required this.tasks,
    required this.blocks,
  });

  final String id;
  final String title;
  final String summary;
  final String sourcePrompt;
  final List<WorkspaceTask> tasks;
  final List<ScheduleBlock> blocks;

  factory Workspace.fromJson(Map<String, dynamic> json) {
    return Workspace(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      sourcePrompt: json['sourcePrompt'] as String? ?? '',
      tasks: ((json['tasks'] as List?) ?? [])
          .map((item) => WorkspaceTask.fromJson(item as Map<String, dynamic>))
          .toList(),
      blocks: ((json['blocks'] as List?) ?? [])
          .map((item) => ScheduleBlock.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Workspace copyWith({
    List<WorkspaceTask>? tasks,
    List<ScheduleBlock>? blocks,
  }) {
    return Workspace(
      id: id,
      title: title,
      summary: summary,
      sourcePrompt: sourcePrompt,
      tasks: tasks ?? this.tasks,
      blocks: blocks ?? this.blocks,
    );
  }
}

class WorkspaceTask {
  WorkspaceTask({
    required this.id,
    required this.title,
    required this.priority,
    required this.status,
    this.deadline,
    this.estimatedMinutes,
    this.note,
    this.scheduleBlocks = const [],
  });

  final String id;
  final String title;
  final String priority;
  final String status;
  final DateTime? deadline;
  final int? estimatedMinutes;
  final String? note;
  final List<ScheduleBlock> scheduleBlocks;

  factory WorkspaceTask.fromJson(Map<String, dynamic> json) {
    final notes = (json['notes'] as List?) ?? [];
    return WorkspaceTask(
      id: json['id'] as String,
      title: json['title'] as String,
      priority: json['priority'] as String,
      status: json['status'] as String,
      deadline: json['deadline'] == null ? null : DateTime.parse(json['deadline'] as String),
      estimatedMinutes: json['estimatedMinutes'] as int?,
      note: notes.isEmpty ? null : notes.first['body'] as String?,
      scheduleBlocks: ((json['scheduleBlocks'] as List?) ?? [])
          .map((item) => ScheduleBlock.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  WorkspaceTask copyWith({
    String? title,
    String? priority,
    String? status,
    DateTime? deadline,
  }) {
    return WorkspaceTask(
      id: id,
      title: title ?? this.title,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      deadline: deadline ?? this.deadline,
      estimatedMinutes: estimatedMinutes,
      note: note,
      scheduleBlocks: scheduleBlocks,
    );
  }
}

class ScheduleBlock {
  ScheduleBlock({
    required this.id,
    required this.taskId,
    required this.label,
    required this.date,
  });

  final String id;
  final String taskId;
  final String label;
  final DateTime date;

  factory ScheduleBlock.fromJson(Map<String, dynamic> json) {
    return ScheduleBlock(
      id: json['id'] as String,
      taskId: json['taskId'] as String,
      label: json['label'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }

  ScheduleBlock copyWith({DateTime? date, String? label}) {
    return ScheduleBlock(
      id: id,
      taskId: taskId,
      label: label ?? this.label,
      date: date ?? this.date,
    );
  }
}
