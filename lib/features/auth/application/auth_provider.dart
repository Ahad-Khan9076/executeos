import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthStatus { unknown, guest, authenticated }

class AuthState {
  final AuthStatus status;
  final String? email;
  final String? userId;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.email,
    this.userId,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? email,
    String? userId,
  }) {
    return AuthState(
      status: status ?? this.status,
      email: email ?? this.email,
      userId: userId ?? this.userId,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState(status: AuthStatus.guest));

  void continueAsGuest() {
    state = const AuthState(status: AuthStatus.guest);
  }

  // Placeholder for future Supabase integration
  Future<void> signInWithEmail(String email, String password) async {
    // TODO: supabase.auth.signInWithPassword(...)
    state = AuthState(
      status: AuthStatus.authenticated,
      email: email,
      userId: 'local-dev-user',
    );
  }

  Future<void> signOut() async {
    state = const AuthState(status: AuthStatus.guest);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
