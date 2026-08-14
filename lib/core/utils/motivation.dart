import 'dart:math';

class Motivation {
  static final _random = Random();

  static const _messages = [
    'Nice. One more thing off your plate.',
    'Done is better than perfect. Great work.',
    'That\'s another win for today.',
    'You are building momentum.',
    'Solid progress. Keep going.',
    'Checked off. On to the next.',
    'Good execution.',
    'You closed the loop. Well done.',
    'Progress compounds. Nice one.',
    'That\'s how commitments get finished.',
  ];

  static String get random => _messages[_random.nextInt(_messages.length)];

  static String forCount(int completedToday) {
    if (completedToday <= 1) return random;
    if (completedToday == 2) return '2 tasks completed. Let\'s keep the streak going.';
    if (completedToday == 3) return '3 down. You\'re in a good flow.';
    if (completedToday >= 5) return '$completedToday completed today. Strong discipline.';
    return random;
  }
}
