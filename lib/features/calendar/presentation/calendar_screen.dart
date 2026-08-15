import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../meetings/application/meeting_list_provider.dart';
import '../../meetings/domain/meeting.dart';
import '../../tasks/application/task_list_provider.dart';
import '../../tasks/domain/task.dart';
import '../../tasks/presentation/widgets/task_tile.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDay = DateTime(now.year, now.month, now.day);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<Task> _tasksForDay(List<Task> all) {
    return all.where((t) {
      if (t.dueAt == null) return false;
      return _isSameDay(t.dueAt!, _selectedDay);
    }).toList();
  }

  List<Meeting> _meetingsForDay(List<Meeting> all) {
    return all.where((m) => _isSameDay(m.startAt, _selectedDay)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final allTasks = ref.watch(taskListProvider);
    final allMeetings = ref.watch(meetingListProvider);
    final dayTasks = _tasksForDay(allTasks);
    final dayMeetings = _meetingsForDay(allMeetings);

    final now = DateTime.now();
    final startOfWeek = _selectedDay.subtract(Duration(days: _selectedDay.weekday - 1));

    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('MMMM yyyy').format(_selectedDay)),
      ),
      body: Column(
        children: [
          // Week strip
          SizedBox(
            height: 78,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: 14,
              itemBuilder: (context, index) {
                final day = startOfWeek.add(Duration(days: index));
                final isSelected = _isSameDay(day, _selectedDay);
                final isToday = _isSameDay(day, now);

                return GestureDetector(
                  onTap: () => setState(() => _selectedDay = day),
                  child: Container(
                    width: 52,
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : isToday
                              ? Theme.of(context).colorScheme.primaryContainer
                              : null,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('E').format(day).substring(0, 1),
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${day.day}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Theme.of(context).colorScheme.onPrimary
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  DateFormat('EEEE, MMM d').format(_selectedDay),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 16),

                if (dayMeetings.isNotEmpty) ...[
                  Text(
                    'Meetings',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  ...dayMeetings.map((m) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.event),
                          title: Text(m.title),
                          subtitle: Text(
                            '${DateFormat('h:mm a').format(m.startAt)} – ${DateFormat('h:mm a').format(m.endAt)}',
                          ),
                        ),
                      )),
                  const SizedBox(height: 16),
                ],

                Text(
                  'Tasks',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                if (dayTasks.isEmpty)
                  const Card(
                    child: ListTile(
                      leading: Icon(Icons.check_circle_outline),
                      title: Text('No tasks due this day'),
                    ),
                  )
                else
                  ...dayTasks.map((t) => TaskTile(task: t)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
