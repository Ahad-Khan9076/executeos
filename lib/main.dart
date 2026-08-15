import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local notifications (multi-stage reminders)
  await NotificationService.instance.init();

  runApp(
    const ProviderScope(
      child: ExecuteOSApp(),
    ),
  );
}
