import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../application/task_list_provider.dart';
import '../domain/task.dart';
import 'edit_task_sheet.dart';

class TaskDetailScreen extends ConsumerWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskListProvider);
    final task = tasks.cast<Task?>().firstWhere(
          (t) => t?.id == taskId,
          orElse: () => null,
        );

    if (task == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Task not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                builder: (_) => EditTaskSheet(task: task),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, ref, task),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            task.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  decoration:
                      task.isCompleted ? TextDecoration.lineThrough : null,
                ),
          ),
          if (task.description != null && task.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              task.description!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
          const SizedBox(height: 24),
          _InfoRow(
            icon: Icons.flag_outlined,
            label: 'Priority',
            value: task.priority.name[0].toUpperCase() +
                task.priority.name.substring(1),
          ),
          _InfoRow(
            icon: Icons.circle_outlined,
            label: 'Status',
            value: task.status.name
                .replaceAllMapped(
                  RegExp(r'([A-Z])'),
                  (m) => ' ${m[0]}',
                )
                .trim()
                .split(' ')
                .map((w) => w[0].toUpperCase() + w.substring(1))
                .join(' '),
          ),
          if (task.dueAt != null)
            _InfoRow(
              icon: Icons.event,
              label: 'Due',
              value: DateFormat('EEE, MMM d · h:mm a').format(task.dueAt!),
              valueColor: task.isOverdue ? Colors.red : null,
            ),
          if (task.estimatedMinutes != null)
            _InfoRow(
              icon: Icons.timer_outlined,
              label: 'Estimate',
              value: '${task.estimatedMinutes} minutes',
            ),
          if (task.completedAt != null)
            _InfoRow(
              icon: Icons.check_circle_outline,
              label: 'Completed',
              value: DateFormat('EEE, MMM d · h:mm a').format(task.completedAt!),
            ),
          const SizedBox(height: 32),
          if (!task.isCompleted) ...[
            FilledButton.icon(
              onPressed: () {
                ref.read(taskListProvider.notifier).completeTask(task.id);
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.check),
              label: const Text('Mark Complete'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                ref.read(taskListProvider.notifier).postponeTask(task.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Postponed by 1 day')),
                );
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.schedule),
              label: const Text('Postpone 1 day'),
            ),
          ] else
            OutlinedButton.icon(
              onPressed: () {
                ref.read(taskListProvider.notifier).updateTask(
                      task.copyWith(
                        status: TaskStatus.notStarted,
                        clearCompletedAt: true,
                      ),
                    );
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.undo),
              label: const Text('Mark as not done'),
            ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Task task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('"${task.title}" will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(taskListProvider.notifier).deleteTask(task.id);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: valueColor,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
