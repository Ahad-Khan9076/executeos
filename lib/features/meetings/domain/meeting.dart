import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class Meeting extends Equatable {
  final String id;
  final String title;
  final String? description;
  final DateTime startAt;
  final DateTime endAt;
  final String? location;
  final String? meetingLink;
  final List<String> participants;
  final DateTime createdAt;

  const Meeting({
    required this.id,
    required this.title,
    this.description,
    required this.startAt,
    required this.endAt,
    this.location,
    this.meetingLink,
    this.participants = const [],
    required this.createdAt,
  });

  factory Meeting.create({
    required String title,
    String? description,
    required DateTime startAt,
    required DateTime endAt,
    String? location,
    String? meetingLink,
    List<String> participants = const [],
  }) {
    return Meeting(
      id: const Uuid().v4(),
      title: title.trim(),
      description: description?.trim(),
      startAt: startAt,
      endAt: endAt,
      location: location,
      meetingLink: meetingLink,
      participants: participants,
      createdAt: DateTime.now(),
    );
  }

  bool get isToday {
    final now = DateTime.now();
    return startAt.year == now.year &&
        startAt.month == now.month &&
        startAt.day == now.day;
  }

  bool get isUpcoming => startAt.isAfter(DateTime.now());

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        startAt,
        endAt,
        location,
        meetingLink,
        participants,
        createdAt,
      ];
}
