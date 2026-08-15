import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/notification_service.dart';
import '../data/task_local_repository.dart';
import '../domain/task.dart';

class TaskListNotifier extends StateNotifier<List<Task>> {
  final TaskLocalRepository _repo;
  final NotificationService _notifications;

  TaskListNotifier(this._repo, this._notifications) : super([]) {
    _load();
  }

  Future<void> _load() async {
    final tasks = await _repo.loadTasks();
    if (tasks.isEmpty) {
      _seed();
    } else {
      state = tasks;
      // Re-schedule reminders for active tasks
      for (final t in tasks.where((t) => !t.isCompleted && t.dueAt != null)) {
        await _notifications.scheduleTaskReminders(t);
      }
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
    for (final t in state) {
      _notifications.scheduleTaskReminders(t);
    }
  }

  Future<void> addTask(Task task) async {
    state = [task, ...state];
    await _persist();
    await _notifications.scheduleTaskReminders(task);
  }

  Future<void> updateTask(Task updated) async {
    state = [
      for (final t in state)
        if (t.id == updated.id) updated else t,
    ];
    await _persist();
    await _notifications.cancelTaskReminders(updated);
    if (!updated.isCompleted) {
      await _notifications.scheduleTaskReminders(updated);
    }
  }

  Future<void> completeTask(String id) async {
    Task? completed;
    state = [
      for (final t in state)
        if (t.id == id)
          completed = t.copyWith(
            status: TaskStatus.completed,
            completedAt: DateTime.now(),
          )
        else
          t,
    ];
    await _persist();
    if (completed != null) {
      await _notifications.cancelTaskReminders(completed);
    }
  }

  Future<void> deleteTask(String id) async {
    final task = state.cast<Task?>().firstWhere(
          (t) => t?.id == id,
          orElse: () => null,
        );
    state = state.where((t) => t.id != id).toList();
    await _persist();
    if (task != null) {
      await _notifications.cancelTaskReminders(task);
    }
  }

  Future<void> postponeTask(String id, {Duration by = const Duration(days: 1)}) async {
    Task? updated;
    state = [
      for (final t in state)
        if (t.id == id)
          updated = t.copyWith(
            dueAt: (t.dueAt ?? DateTime.now()).add(by),
            status: TaskStatus.notStarted,
            clearCompletedAt: true,
          )
        else
          t,
    ];
    await _persist();
    if (updated != null) {
      await _notifications.cancelTaskReminders(updated);
      await _notifications.scheduleTaskReminders(updated);
    }
  }
}

final taskLocalRepositoryProvider = Provider<TaskLocalRepository>((ref) {
  return TaskLocalRepository();
});

final taskListProvider =
    StateNotifierProvider<TaskListNotifier, List<Task>>((ref) {
  final repo = ref.watch(taskLocalRepositoryProvider);
  final notifications = ref.watch(notificationServiceProvider);
  return TaskListNotifier(repo, notifications);
});

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
