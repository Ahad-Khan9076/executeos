import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/services/notification_service.dart';
import 'core/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Local notifications (multi-stage reminders)
  await NotificationService.instance.init();

  // Supabase (only if SUPABASE_URL + SUPABASE_ANON_KEY are provided)
  await SupabaseService.instance.init();

  runApp(
    const ProviderScope(
      child: ExecuteOSApp(),
    ),
  );
}
