import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/task_list_provider.dart';
import 'widgets/task_tile.dart';
import 'create_task_sheet.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskListProvider);
    final active = tasks.where((t) => !t.isCompleted).toList();
    final completed = tasks.where((t) => t.isCompleted).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (active.isEmpty && completed.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 48),
                child: Text('No tasks yet. Create your first one!'),
              ),
            )
          else ...[
            if (active.isNotEmpty) ...[
              Text(
                'Active (${active.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              ...active.map((t) => TaskTile(task: t)),
              const SizedBox(height: 24),
            ],
            if (completed.isNotEmpty) ...[
              Text(
                'Completed (${completed.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              ...completed.map((t) => TaskTile(task: t)),
            ],
          ],
          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (_) => const CreateTaskSheet(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }
}
