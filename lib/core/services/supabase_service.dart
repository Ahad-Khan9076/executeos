import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env.dart';

class SupabaseService {
  SupabaseService._();
  static final instance = SupabaseService._();

  bool _initialized = false;

  bool get isAvailable => Env.hasSupabase && _initialized;

  SupabaseClient? get client =>
      isAvailable ? Supabase.instance.client : null;

  Future<void> init() async {
    if (!Env.hasSupabase) {
      // Running in local/guest mode — no cloud
      return;
    }

    if (_initialized) return;

    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );

    _initialized = true;
  }

  User? get currentUser => client?.auth.currentUser;

  Stream<AuthState>? get authStateChanges =>
      client?.auth.onAuthStateChange;
}
