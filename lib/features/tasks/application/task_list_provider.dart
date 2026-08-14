import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/task_local_repository.dart';
import '../domain/task.dart';

class TaskListNotifier extends StateNotifier<List<Task>> {
  final TaskLocalRepository _repo;

  TaskListNotifier(this._repo) : super([]) {
    _load();
  }

  Future<void> _load() async {
    final tasks = await _repo.loadTasks();
    if (tasks.isEmpty) {
      _seed();
    } else {
      state = tasks;
    }
  }

  Future<void> _persist() async {
    await _repo.saveTasks(state);
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
    _persist();
  }

  Future<void> addTask(Task task) async {
    state = [task, ...state];
    await _persist();
  }

  Future<void> updateTask(Task updated) async {
    state = [
      for (final t in state)
        if (t.id == updated.id) updated else t,
    ];
    await _persist();
  }

  Future<void> completeTask(String id) async {
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
    await _persist();
  }

  Future<void> deleteTask(String id) async {
    state = state.where((t) => t.id != id).toList();
    await _persist();
  }

  Future<void> postponeTask(String id, {Duration by = const Duration(days: 1)}) async {
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
    await _persist();
  }
}

final taskLocalRepositoryProvider = Provider<TaskLocalRepository>((ref) {
  return TaskLocalRepository();
});

final taskListProvider =
    StateNotifierProvider<TaskListNotifier, List<Task>>((ref) {
  final repo = ref.watch(taskLocalRepositoryProvider);
  return TaskListNotifier(repo);
});

/// Derived providers for the Today view
final todayTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(taskListProvider);
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));

  return tasks.where((t) {
    if (t.isCompleted) return false;
    if (t.dueAt == null) return true;
    return t.dueAt!.isBefore(endOfDay);
  }).toList()
    ..sort((a, b) {
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
