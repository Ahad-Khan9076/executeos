import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../meetings/application/meeting_list_provider.dart';
import '../../meetings/domain/meeting.dart';
import '../../tasks/application/task_list_provider.dart';
import '../../tasks/domain/task.dart';

class AiMessage {
  final String role; // 'user' | 'assistant'
  final String content;
  final DateTime at;

  AiMessage({
    required this.role,
    required this.content,
    DateTime? at,
  }) : at = at ?? DateTime.now();
}

class AiCoachService {
  final List<Task> tasks;
  final List<Meeting> meetings;

  AiCoachService({
    required this.tasks,
    required this.meetings,
  });

  String respond(String input) {
    final q = input.toLowerCase().trim();

    if (_matches(q, ['focus', 'what should i', 'priority', 'priorities'])) {
      return _focusAdvice();
    }
    if (_matches(q, ['plan my day', 'plan today', 'schedule my day'])) {
      return _planDay();
    }
    if (_matches(q, ['behind', 'overdue', 'falling behind', 'why am i'])) {
      return _behindAnalysis();
    }
    if (_matches(q, ['unfinished', 'schedule my', 'reschedule'])) {
      return _unfinishedAdvice();
    }
    if (_matches(q, ['meeting', 'meetings', 'calendar'])) {
      return _meetingsSummary();
    }
    if (_matches(q, ['score', 'discipline', 'progress'])) {
      return _scoreSummary();
    }
    if (_matches(q, ['help', 'what can you'])) {
      return _help();
    }

    return _defaultReply();
  }

  bool _matches(String q, List<String> keywords) {
    return keywords.any((k) => q.contains(k));
  }

  List<Task> get _active =>
      tasks.where((t) => !t.isCompleted).toList()
        ..sort((a, b) {
          final p = b.priority.index.compareTo(a.priority.index);
          if (p != 0) return p;
          if (a.dueAt == null) return 1;
          if (b.dueAt == null) return -1;
          return a.dueAt!.compareTo(b.dueAt!);
        });

  List<Task> get _overdue => tasks.where((t) => t.isOverdue).toList();

  String _focusAdvice() {
    if (_active.isEmpty) {
      return 'You have no open tasks. Enjoy the clear space or create the next important commitment.';
    }

    final top = _active.take(3).toList();
    final buffer = StringBuffer('Here\'s what you should focus on right now:\n\n');

    for (var i = 0; i < top.length; i++) {
      final t = top[i];
      final due = t.dueAt != null
          ? DateFormat('h:mm a').format(t.dueAt!)
          : 'no due time';
      buffer.writeln('${i + 1}. **${t.title}** ($due, ${t.priority.name})');
    }

    if (_overdue.isNotEmpty) {
      buffer.writeln(
          '\nYou also have ${_overdue.length} overdue item(s). Clear those first if they still matter.');
    }

    return buffer.toString();
  }

  String _planDay() {
    final todayMeetings = meetings.where((m) => m.isToday).toList()
      ..sort((a, b) => a.startAt.compareTo(b.startAt));

    final buffer = StringBuffer("Today's suggested plan:\n\n");

    if (todayMeetings.isNotEmpty) {
      buffer.writeln('**Meetings**');
      for (final m in todayMeetings) {
        buffer.writeln(
            '• ${DateFormat('h:mm a').format(m.startAt)} – ${m.title}');
      }
      buffer.writeln();
    }

    final todayTasks = _active.where((t) {
      if (t.dueAt == null) return true;
      final now = DateTime.now();
      return t.dueAt!.day == now.day &&
          t.dueAt!.month == now.month &&
          t.dueAt!.year == now.year;
    }).toList();

    if (todayTasks.isEmpty) {
      buffer.writeln('No tasks due today. Consider pulling one important item forward.');
    } else {
      buffer.writeln('**Tasks (by priority)**');
      for (final t in todayTasks.take(5)) {
        final est = t.estimatedMinutes != null ? ' ~${t.estimatedMinutes}m' : '';
        buffer.writeln('• ${t.title}$est');
      }
    }

    buffer.writeln(
        '\nTip: Block your highest-priority task before the first meeting.');
    return buffer.toString();
  }

  String _behindAnalysis() {
    if (_overdue.isEmpty) {
      return 'You are not behind on any tasks. Nice discipline. Keep the streak going.';
    }

    final buffer = StringBuffer(
        'You have ${_overdue.length} overdue task(s):\n\n');

    for (final t in _overdue.take(5)) {
      final days = DateTime.now().difference(t.dueAt!).inDays;
      buffer.writeln(
          '• ${t.title} (${days == 0 ? 'due earlier today' : '$days day(s) late'})');
    }

    buffer.writeln(
        '\nRecommendation: Either complete the most important one now, break it into a smaller next action, or consciously postpone/cancel it so it stops draining attention.');
    return buffer.toString();
  }

  String _unfinishedAdvice() {
    final unfinished = _active;
    if (unfinished.isEmpty) {
      return 'Nothing unfinished. You are clear.';
    }

    final buffer = StringBuffer(
        'You have ${unfinished.length} open task(s). Suggested order:\n\n');

    for (var i = 0; i < unfinished.take(5).length; i++) {
      final t = unfinished[i];
      buffer.writeln('${i + 1}. ${t.title}');
    }

    buffer.writeln(
        '\nI can\'t auto-move them yet, but start with #1 — it has the highest priority / nearest deadline.');
    return buffer.toString();
  }

  String _meetingsSummary() {
    final today = meetings.where((m) => m.isToday).toList();
    if (today.isEmpty) {
      return 'No meetings scheduled for today.';
    }

    final buffer = StringBuffer('Today\'s meetings:\n\n');
    for (final m in today) {
      buffer.writeln(
          '• ${DateFormat('h:mm a').format(m.startAt)} – ${m.title}');
    }
    buffer.writeln(
        '\nAfter each meeting, create a follow-up so nothing falls through.');
    return buffer.toString();
  }

  String _scoreSummary() {
    final completed = tasks
        .where((t) =>
            t.isCompleted &&
            t.completedAt != null &&
            t.completedAt!.day == DateTime.now().day)
        .length;
    final remaining = _active.length;
    final total = completed + remaining;
    final score = total == 0 ? 0 : ((completed / total) * 100).round();

    return 'Today\'s Discipline Score: **$score%**\n'
        '$completed completed · $remaining remaining.\n\n'
        '${score >= 70 ? 'Strong execution today.' : 'Room to close more loops before the day ends.'}';
  }

  String _help() {
    return 'I can help with:\n'
        '• "What should I focus on?"\n'
        '• "Plan my day"\n'
        '• "Why am I behind?"\n'
        '• "Schedule unfinished tasks"\n'
        '• "What meetings do I have?"\n'
        '• "How is my score?"\n\n'
        'I look at your real tasks and meetings to give practical answers.';
  }

  String _defaultReply() {
    return 'I\'m your Execution Coach. Try asking:\n'
        '• What should I focus on?\n'
        '• Plan my day\n'
        '• Why am I behind?\n\n'
        'Or type "help" to see everything I can do.';
  }
}

final aiCoachServiceProvider = Provider<AiCoachService>((ref) {
  final tasks = ref.watch(taskListProvider);
  final meetings = ref.watch(meetingListProvider);
  return AiCoachService(tasks: tasks, meetings: meetings);
});
