import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/meeting.dart';

class MeetingListNotifier extends StateNotifier<List<Meeting>> {
  MeetingListNotifier() : super([]) {
    _seed();
  }

  void _seed() {
    final now = DateTime.now();
    final todayAt = DateTime(now.year, now.month, now.day, 15, 0); // 3 PM today

    state = [
      Meeting.create(
        title: 'Client Strategy Call',
        description: 'Discuss Q3 roadmap and proposal',
        startAt: todayAt,
        endAt: todayAt.add(const Duration(minutes: 45)),
        meetingLink: 'https://meet.google.com/abc-defg-hij',
        participants: ['Sarah Chen', 'You'],
      ),
    ];
  }

  void addMeeting(Meeting meeting) {
    state = [...state, meeting]..sort((a, b) => a.startAt.compareTo(b.startAt));
  }
}

final meetingListProvider =
    StateNotifierProvider<MeetingListNotifier, List<Meeting>>((ref) {
  return MeetingListNotifier();
});

final todayMeetingsProvider = Provider<List<Meeting>>((ref) {
  final meetings = ref.watch(meetingListProvider);
  return meetings.where((m) => m.isToday).toList();
});
