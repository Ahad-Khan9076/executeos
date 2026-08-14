import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/task.dart';

class TaskListNotifier extends StateNotifier<List<Task>> {
  TaskListNotifier() : super([]) {
    // Seed with a couple of example tasks so the UI isn't empty on first run
    _seed();
  }

  void _seed() {
    final now = DateTime.now();
    state = [
      Task.create(
        title: 'Review client proposal',
        description: 'Finalize the pricing section and send to Sarah',
        priority: TaskPriority.high,
        dueAt: now.add(const Duration(hours: 4)),
        estimatedMinutes: 45,
      ),
      Task.create(
        title: 'Prepare for strategy call',
        priority: TaskPriority.medium,
        dueAt: now.add(const Duration(hours: 6)),
        estimatedMinutes: 30,
      ),
      Task.create(
        title: 'Send follow-up email to Alex',
        priority: TaskPriority.medium,
        dueAt: now.add(const Duration(days: 1)),
        estimatedMinutes: 15,
      ),
    ];
  }

  void addTask(Task task) {
    state = [task, ...state];
  }

  void updateTask(Task updated) {
    state = [
      for (final t in state)
        if (t.id == updated.id) updated else t,
    ];
  }

  void completeTask(String id) {
    state = [
      for (final t in state)
        if (t.id == id)
          t.copyWith(
            status: TaskStatus.completed,
            completedAt: DateTime.now(),
          )
        else
          t,
    ];
  }

  void deleteTask(String id) {
    state = state.where((t) => t.id != id).toList();
  }

  void postponeTask(String id, {Duration by = const Duration(days: 1)}) {
    state = [
      for (final t in state)
        if (t.id == id)
          t.copyWith(
            dueAt: (t.dueAt ?? DateTime.now()).add(by),
            status: TaskStatus.notStarted,
            clearCompletedAt: true,
          )
        else
          t,
    ];
  }
}

final taskListProvider =
    StateNotifierProvider<TaskListNotifier, List<Task>>((ref) {
  return TaskListNotifier();
});

/// Derived providers for the Today view
final todayTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(taskListProvider);
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));

  return tasks.where((t) {
    if (t.isCompleted) return false;
    if (t.dueAt == null) return true; // undated tasks show in today for now
    return t.dueAt!.isBefore(endOfDay);
  }).toList()
    ..sort((a, b) {
      // Higher priority first, then earlier due date
      final priorityCompare = b.priority.index.compareTo(a.priority.index);
      if (priorityCompare != 0) return priorityCompare;
      if (a.dueAt == null && b.dueAt == null) return 0;
      if (a.dueAt == null) return 1;
      if (b.dueAt == null) return -1;
      return a.dueAt!.compareTo(b.dueAt!);
    });
});

final overdueTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(taskListProvider);
  return tasks.where((t) => t.isOverdue).toList();
});

final completedTodayProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(taskListProvider);
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);

  return tasks.where((t) {
    return t.isCompleted &&
        t.completedAt != null &&
        t.completedAt!.isAfter(startOfDay);
  }).toList();
});
