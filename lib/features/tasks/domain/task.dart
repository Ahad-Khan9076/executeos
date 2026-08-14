import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

enum TaskPriority { low, medium, high, urgent }

enum TaskStatus {
  notStarted,
  inProgress,
  blocked,
  completed,
  cancelled,
  overdue,
}

class Task extends Equatable {
  final String id;
  final String title;
  final String? description;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime? dueAt;
  final DateTime? startAt;
  final int? estimatedMinutes;
  final String? projectId;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  const Task({
    required this.id,
    required this.title,
    this.description,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.notStarted,
    this.dueAt,
    this.startAt,
    this.estimatedMinutes,
    this.projectId,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  factory Task.create({
    required String title,
    String? description,
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueAt,
    DateTime? startAt,
    int? estimatedMinutes,
    List<String> tags = const [],
  }) {
    final now = DateTime.now();
    return Task(
      id: const Uuid().v4(),
      title: title.trim(),
      description: description?.trim(),
      priority: priority,
      status: TaskStatus.notStarted,
      dueAt: dueAt,
      startAt: startAt,
      estimatedMinutes: estimatedMinutes,
      tags: tags,
      createdAt: now,
      updatedAt: now,
    );
  }

  Task copyWith({
    String? title,
    String? description,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueAt,
    DateTime? startAt,
    int? estimatedMinutes,
    String? projectId,
    List<String>? tags,
    DateTime? updatedAt,
    DateTime? completedAt,
    bool clearDueAt = false,
    bool clearCompletedAt = false,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueAt: clearDueAt ? null : (dueAt ?? this.dueAt),
      startAt: startAt ?? this.startAt,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      projectId: projectId ?? this.projectId,
      tags: tags ?? this.tags,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
    );
  }

  bool get isCompleted => status == TaskStatus.completed;
  bool get isOverdue {
    if (isCompleted || dueAt == null) return false;
    return dueAt!.isBefore(DateTime.now());
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        priority,
        status,
        dueAt,
        startAt,
        estimatedMinutes,
        projectId,
        tags,
        createdAt,
        updatedAt,
        completedAt,
      ];
}
