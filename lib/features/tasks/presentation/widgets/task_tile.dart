import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../application/task_list_provider.dart';
import '../../domain/task.dart';

class TaskTile extends ConsumerWidget {
  final Task task;

  const TaskTile({super.key, required this.task});

  Color _priorityColor(BuildContext context) {
    switch (task.priority) {
      case TaskPriority.urgent:
        return Colors.red.shade600;
      case TaskPriority.high:
        return Colors.orange.shade700;
      case TaskPriority.medium:
        return Theme.of(context).colorScheme.primary;
      case TaskPriority.low:
        return Colors.grey;
    }
  }

  String? _dueLabel() {
    if (task.dueAt == null) return null;
    final now = DateTime.now();
    final due = task.dueAt!;
    final diff = due.difference(now);

    if (task.isOverdue) {
      return 'Overdue';
    }
    if (diff.inMinutes < 60) {
      return 'In ${diff.inMinutes}m';
    }
    if (diff.inHours < 24 && due.day == now.day) {
      return DateFormat('h:mm a').format(due);
    }
    if (diff.inDays == 0) {
      return 'Today ${DateFormat('h:mm a').format(due)}';
    }
    if (diff.inDays == 1) {
      return 'Tomorrow';
    }
    return DateFormat('MMM d').format(due);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dueLabel = _dueLabel();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/tasks/${task.id}'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // Complete checkbox
              GestureDetector(
                onTap: () {
                  ref.read(taskListProvider.notifier).completeTask(task.id);
                },
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _priorityColor(context),
                      width: 2,
                    ),
                  ),
                  child: task.isCompleted
                      ? Icon(Icons.check, size: 16, color: _priorityColor(context))
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                    ),
                    if (dueLabel != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        dueLabel,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: task.isOverdue
                                  ? Colors.red.shade600
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                              fontWeight:
                                  task.isOverdue ? FontWeight.w600 : FontWeight.normal,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              if (task.estimatedMinutes != null)
                Text(
                  '${task.estimatedMinutes}m',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
