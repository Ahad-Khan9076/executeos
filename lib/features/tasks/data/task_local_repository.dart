import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../domain/task.dart';

/// Simple file-based persistence for tasks.
/// Easy to replace with Hive / Supabase later.
class TaskLocalRepository {
  static const _fileName = 'tasks.json';

  Future<File> get _file async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<List<Task>> loadTasks() async {
    try {
      final file = await _file;
      if (!await file.exists()) return [];

      final content = await file.readAsString();
      if (content.isEmpty) return [];

      final List<dynamic> jsonList = jsonDecode(content);
      return jsonList.map((e) => _taskFromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      // On any error, start fresh rather than crash
      return [];
    }
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final file = await _file;
    final jsonList = tasks.map(_taskToJson).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }

  Map<String, dynamic> _taskToJson(Task t) => {
        'id': t.id,
        'title': t.title,
        'description': t.description,
        'priority': t.priority.name,
        'status': t.status.name,
        'dueAt': t.dueAt?.toIso8601String(),
        'startAt': t.startAt?.toIso8601String(),
        'estimatedMinutes': t.estimatedMinutes,
        'projectId': t.projectId,
        'tags': t.tags,
        'createdAt': t.createdAt.toIso8601String(),
        'updatedAt': t.updatedAt.toIso8601String(),
        'completedAt': t.completedAt?.toIso8601String(),
      };

  Task _taskFromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TaskStatus.notStarted,
      ),
      dueAt: json['dueAt'] != null ? DateTime.parse(json['dueAt'] as String) : null,
      startAt: json['startAt'] != null ? DateTime.parse(json['startAt'] as String) : null,
      estimatedMinutes: json['estimatedMinutes'] as int?,
      projectId: json['projectId'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }
}
