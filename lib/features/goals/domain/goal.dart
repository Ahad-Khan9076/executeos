import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

enum GoalStatus { active, completed, abandoned }

class Goal extends Equatable {
  final String id;
  final String title;
  final String? description;
  final GoalStatus status;
  final DateTime? targetDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  const Goal({
    required this.id,
    required this.title,
    this.description,
    this.status = GoalStatus.active,
    this.targetDate,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  factory Goal.create({
    required String title,
    String? description,
    DateTime? targetDate,
  }) {
    final now = DateTime.now();
    return Goal(
      id: const Uuid().v4(),
      title: title.trim(),
      description: description?.trim(),
      status: GoalStatus.active,
      targetDate: targetDate,
      createdAt: now,
      updatedAt: now,
    );
  }

  Goal copyWith({
    String? title,
    String? description,
    GoalStatus? status,
    DateTime? targetDate,
    DateTime? updatedAt,
    DateTime? completedAt,
    bool clearTargetDate = false,
    bool clearCompletedAt = false,
  }) {
    return Goal(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      targetDate: clearTargetDate ? null : (targetDate ?? this.targetDate),
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
    );
  }

  bool get isActive => status == GoalStatus.active;
  bool get isCompleted => status == GoalStatus.completed;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        status,
        targetDate,
        createdAt,
        updatedAt,
        completedAt,
      ];
}
