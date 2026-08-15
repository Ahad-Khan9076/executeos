import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../features/tasks/domain/task.dart';

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    // Request permissions on Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  /// Schedule multi-stage reminders for a task.
  /// Default offsets: 1 day, 1 hour, 15 minutes before due.
  Future<void> scheduleTaskReminders(Task task) async {
    if (task.dueAt == null || task.isCompleted) return;

    final due = task.dueAt!;
    final now = DateTime.now();

    final stages = <Duration, String>{
      const Duration(days: 1): 'Tomorrow: ${task.title}',
      const Duration(hours: 1): 'In 1 hour: ${task.title}',
      const Duration(minutes: 15): 'Starting soon: ${task.title}',
    };

    var idBase = task.id.hashCode.abs() % 100000;

    for (final entry in stages.entries) {
      final fireAt = due.subtract(entry.key);
      if (fireAt.isBefore(now)) continue;

      await _plugin.zonedSchedule(
        idBase++,
        'ExecuteOS',
        entry.value,
        tz.TZDateTime.from(fireAt, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_reminders',
            'Task Reminders',
            channelDescription: 'Reminders for upcoming tasks',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: task.id,
      );
    }
  }

  Future<void> cancelTaskReminders(Task task) async {
    final idBase = task.id.hashCode.abs() % 100000;
    for (var i = 0; i < 5; i++) {
      await _plugin.cancel(idBase + i);
    }
  }

  Future<void> showInstant({
    required String title,
    required String body,
  }) async {
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'general',
          'General',
          importance: Importance.defaultImportance,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService.instance;
});
