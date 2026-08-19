import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../goals/application/goal_list_provider.dart';
import '../../goals/presentation/create_goal_sheet.dart';
import '../../meetings/application/meeting_list_provider.dart';
import '../../meetings/presentation/post_meeting_followup_sheet.dart';
import '../../tasks/application/task_list_provider.dart';
import '../../tasks/presentation/widgets/task_tile.dart';
import '../../tasks/presentation/create_task_sheet.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayTasks = ref.watch(todayTasksProvider);
    final overdue = ref.watch(overdueTasksProvider);
    final completedToday = ref.watch(completedTodayProvider);
    final todayMeetings = ref.watch(todayMeetingsProvider);
    final activeGoals = ref.watch(activeGoalsProvider);

    final totalRelevant = todayTasks.length + completedToday.length;
    final score = totalRelevant == 0
        ? null
        : ((completedToday.length / totalRelevant) * 100).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'AI Coach',
            onPressed: () => context.go('/ai'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              _greeting(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'What should you focus on right now?',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 20),

            // Discipline Score
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      child: Text(
                        score == null ? '—' : '$score',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Discipline Score',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            score == null
                                ? 'Complete tasks to build your score'
                                : '${completedToday.length} completed · ${todayTasks.length} remaining',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Active Goals
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Goals',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                TextButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      builder: (_) => const CreateGoalSheet(),
                    );
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                ),
              ],
            ),
            if (activeGoals.isEmpty)
              const Card(
                child: ListTile(
                  leading: Icon(Icons.flag_outlined),
                  title: Text('No active goals'),
                  subtitle: Text('Set a goal to stay oriented'),
                ),
              )
            else
              ...activeGoals.map((g) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.flag),
                      title: Text(g.title),
                      subtitle: g.targetDate != null
                          ? Text(
                              'Target ${DateFormat('MMM d, y').format(g.targetDate!)}',
                            )
                          : (g.description),
                      trailing: IconButton(
                        icon: const Icon(Icons.check_circle_outline),
                        tooltip: 'Mark complete',
                        onPressed: () {
                          ref.read(goalListProvider.notifier).completeGoal(g.id);
                        },
                      ),
                    ),
                  )),

            // Meetings today
            if (todayMeetings.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Meetings',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              ...todayMeetings.map((m) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.event),
                    title: Text(m.title),
                    subtitle: Text(
                      '${DateFormat('h:mm a').format(m.startAt)} – ${DateFormat('h:mm a').format(m.endAt)}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        useSafeArea: true,
                        builder: (_) => PostMeetingFollowUpSheet(meeting: m),
                      );
                    },
                  ),
                );
              }),
            ],

            // Overdue
            if (overdue.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Overdue',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade700,
                    ),
              ),
              const SizedBox(height: 8),
              ...overdue.map((t) => TaskTile(task: t)),
            ],

            // Focus Now
            const SizedBox(height: 24),
            Text(
              'Focus Now',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),

            if (todayTasks.isEmpty)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.check_circle_outline),
                  title: const Text('All clear for now'),
                  subtitle: const Text('Create a task or enjoy the breathing room'),
                  trailing: const Icon(Icons.add),
                  onTap: () => _openCreateTask(context),
                ),
              )
            else
              ...todayTasks.map((t) => TaskTile(task: t)),

            // Completed today
            if (completedToday.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Completed Today',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              ...completedToday.map((t) => TaskTile(task: t)),
            ],

            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateTask(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }

  void _openCreateTask(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const CreateTaskSheet(),
    );
  }
}
