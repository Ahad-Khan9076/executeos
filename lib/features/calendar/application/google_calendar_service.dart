import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Google Calendar bi-directional sync scaffold.
///
/// To enable:
/// 1. Create a Google Cloud project
/// 2. Enable Google Calendar API
/// 3. Configure OAuth 2.0 (iOS + Android client IDs)
/// 4. Add `google_sign_in` + `googleapis` packages
/// 5. Implement the methods below
///
/// This service is intentionally a clear interface so the rest of the app
/// can call it without knowing the OAuth details yet.
class GoogleCalendarService {
  bool get isConnected => false; // TODO: track OAuth session

  Future<bool> connect() async {
    // TODO: Google Sign-In → request calendar.events scope
    return false;
  }

  Future<void> disconnect() async {
    // TODO: sign out + clear tokens
  }

  /// Pull events from primary calendar into local meetings.
  Future<int> pullEvents({
    DateTime? from,
    DateTime? to,
  }) async {
    // TODO: calendar.events.list + map to Meeting entities
    return 0;
  }

  /// Push a local meeting to Google Calendar.
  Future<String?> pushMeeting({
    required String title,
    required DateTime start,
    required DateTime end,
    String? description,
  }) async {
    // TODO: calendar.events.insert → return event id
    return null;
  }

  /// Update an existing Google event from a local meeting change.
  Future<void> updateEvent(String googleEventId, {
    String? title,
    DateTime? start,
    DateTime? end,
  }) async {
    // TODO: calendar.events.patch
  }
}

final googleCalendarServiceProvider = Provider<GoogleCalendarService>((ref) {
  return GoogleCalendarService();
});
