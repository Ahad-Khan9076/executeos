import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../core/services/supabase_service.dart';

enum AuthStatus { unknown, guest, authenticated }

class AuthState {
  final AuthStatus status;
  final String? email;
  final String? userId;
  final String? error;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.email,
    this.userId,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? email,
    String? userId,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      email: email ?? this.email,
      userId: userId ?? this.userId,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState(status: AuthStatus.guest)) {
    _listen();
  }

  void _listen() {
    final stream = SupabaseService.instance.authStateChanges;
    if (stream == null) return;

    stream.listen((event) {
      final user = event.session?.user;
      if (user != null) {
        state = AuthState(
          status: AuthStatus.authenticated,
          email: user.email,
          userId: user.id,
        );
      } else if (state.status == AuthStatus.authenticated) {
        state = const AuthState(status: AuthStatus.guest);
      }
    });
  }

  void continueAsGuest() {
    state = const AuthState(status: AuthStatus.guest);
  }

  Future<bool> signInWithEmail(String email, String password) async {
    final client = SupabaseService.instance.client;
    if (client == null) {
      // Dev fallback when Supabase is not configured
      state = AuthState(
        status: AuthStatus.authenticated,
        email: email,
        userId: 'local-dev-user',
      );
      return true;
    }

    try {
      final res = await client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      final user = res.user;
      if (user != null) {
        state = AuthState(
          status: AuthStatus.authenticated,
          email: user.email,
          userId: user.id,
        );
        return true;
      }
      state = state.copyWith(error: 'Sign in failed');
      return false;
    } on supabase.AuthException catch (e) {
      state = state.copyWith(error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> signUp(String email, String password) async {
    final client = SupabaseService.instance.client;
    if (client == null) {
      state = AuthState(
        status: AuthStatus.authenticated,
        email: email,
        userId: 'local-dev-user',
      );
      return true;
    }

    try {
      final res = await client.auth.signUp(
        email: email.trim(),
        password: password,
      );
      final user = res.user;
      if (user != null) {
        state = AuthState(
          status: AuthStatus.authenticated,
          email: user.email,
          userId: user.id,
        );
        return true;
      }
      state = state.copyWith(error: 'Sign up failed');
      return false;
    } on supabase.AuthException catch (e) {
      state = state.copyWith(error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    final client = SupabaseService.instance.client;
    if (client != null) {
      await client.auth.signOut();
    }
    state = const AuthState(status: AuthStatus.guest);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
