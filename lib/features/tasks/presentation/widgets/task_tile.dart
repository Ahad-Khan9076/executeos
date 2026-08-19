import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/motivation.dart';
import '../../application/task_list_provider.dart';
import '../../domain/task.dart';

class TaskTile extends ConsumerWidget {
  final Task task;

  const TaskTile({super.key, required this.task});

  Color _priorityColor() {
    switch (task.priority) {
      case TaskPriority.urgent:
        return AppColors.priorityUrgent;
      case TaskPriority.high:
        return AppColors.priorityHigh;
      case TaskPriority.medium:
        return AppColors.priorityMedium;
      case TaskPriority.low:
        return AppColors.priorityLow;
    }
  }

  String? _dueLabel() {
    if (task.dueAt == null) return null;
    final now = DateTime.now();
    final due = task.dueAt!;
    final diff = due.difference(now);

    if (task.isOverdue) return 'Overdue';
    if (diff.inMinutes < 60) return 'In ${diff.inMinutes}m';
    if (diff.inHours < 24 && due.day == now.day) {
      return DateFormat('h:mm a').format(due);
    }
    if (diff.inDays == 0) return 'Today ${DateFormat('h:mm a').format(due)}';
    if (diff.inDays == 1) return 'Tomorrow';
    return DateFormat('MMM d').format(due);
  }

  void _onComplete(BuildContext context, WidgetRef ref) {
    if (task.isCompleted) return;

    ref.read(taskListProvider.notifier).completeTask(task.id);

    final completedCount = ref.read(completedTodayProvider).length + 1;
    final message = Motivation.forCount(completedCount);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dueLabel = _dueLabel();
    final priorityColor = _priorityColor();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: () => context.push('/tasks/${task.id}'),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.04),
              ),
            ),
            child: Row(
              children: [
                // Priority-colored checkbox
                GestureDetector(
                  onTap: () => _onComplete(context, ref),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: task.isCompleted
                          ? priorityColor.withValues(alpha: 0.15)
                          : Colors.transparent,
                      border: Border.all(
                        color: priorityColor,
                        width: 2,
                      ),
                    ),
                    child: task.isCompleted
                        ? Icon(Icons.check, size: 16, color: priorityColor)
                        : null,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
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
                              color: task.isCompleted
                                  ? Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant
                                  : null,
                            ),
                      ),
                      if (dueLabel != null) ...[
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(
                              task.isOverdue
                                  ? Icons.warning_amber_rounded
                                  : Icons.schedule_rounded,
                              size: 13,
                              color: task.isOverdue
                                  ? AppColors.overdue
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              dueLabel,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: task.isOverdue
                                        ? AppColors.overdue
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                    fontWeight: task.isOverdue
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                if (task.estimatedMinutes != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.black.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      '${task.estimatedMinutes}m',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
