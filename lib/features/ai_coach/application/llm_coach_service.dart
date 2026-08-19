import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/env.dart';
import '../../meetings/application/meeting_list_provider.dart';
import '../../tasks/application/task_list_provider.dart';
import 'ai_coach_service.dart';

class LlmCoachService {
  final AiCoachService fallback;
  final Dio _dio;

  LlmCoachService({required this.fallback})
      : _dio = Dio(BaseOptions(
          baseUrl: Env.openAiBaseUrl,
          headers: {
            'Authorization': 'Bearer ${Env.openAiApiKey}',
            'Content-Type': 'application/json',
          },
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 40),
        ));

  bool get isLlmAvailable => Env.hasOpenAi;

  Future<String> respond(String input) async {
    if (!isLlmAvailable) {
      return fallback.respond(input);
    }

    try {
      final context = _buildContext();
      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content': '''
You are the Execution Coach inside ExecuteOS.
Your job is to help the user get important work done on time.
Be concise, practical, and action-oriented. No fluff.
Never invent tasks the user does not have.
Use the context below about their real tasks and meetings.

$context
''',
            },
            {'role': 'user', 'content': input},
          ],
          'temperature': 0.4,
          'max_tokens': 500,
        },
      );

      final content =
          response.data['choices']?[0]?['message']?['content'] as String?;
      if (content == null || content.trim().isEmpty) {
        return fallback.respond(input);
      }
      return content.trim();
    } catch (_) {
      // Network / key / rate-limit → graceful fallback
      return fallback.respond(input);
    }
  }

  String _buildContext() {
    final tasks = fallback.tasks;
    final meetings = fallback.meetings;

    final active = tasks.where((t) => !t.isCompleted).take(10).map((t) {
      final due = t.dueAt?.toIso8601String() ?? 'no due';
      return '- ${t.title} [${t.priority.name}] due: $due';
    }).join('\n');

    final overdue = tasks.where((t) => t.isOverdue).map((t) => t.title).join(', ');

    final todayMeetings = meetings.where((m) => m.isToday).map((m) {
      return '- ${m.title} at ${m.startAt.hour}:${m.startAt.minute.toString().padLeft(2, '0')}';
    }).join('\n');

    return '''
Active tasks:
$active

Overdue: ${overdue.isEmpty ? 'none' : overdue}

Today's meetings:
${todayMeetings.isEmpty ? 'none' : todayMeetings}
''';
  }
}

final llmCoachServiceProvider = Provider<LlmCoachService>((ref) {
  final fallback = ref.watch(aiCoachServiceProvider);
  return LlmCoachService(fallback: fallback);
});
