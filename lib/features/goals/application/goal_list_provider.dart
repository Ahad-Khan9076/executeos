import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/goal.dart';

class GoalListNotifier extends StateNotifier<List<Goal>> {
  GoalListNotifier() : super([]) {
    _load();
  }

  Future<File> get _file async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/goals.json');
  }

  Future<void> _load() async {
    try {
      final file = await _file;
      if (!await file.exists()) {
        _seed();
        return;
      }
      final content = await file.readAsString();
      if (content.isEmpty) {
        _seed();
        return;
      }
      final list = (jsonDecode(content) as List)
          .map((e) => _fromJson(e as Map<String, dynamic>))
          .toList();
      state = list;
    } catch (_) {
      _seed();
    }
  }

  Future<void> _persist() async {
    final file = await _file;
    final json = state.map(_toJson).toList();
    await file.writeAsString(jsonEncode(json));
  }

  void _seed() {
    state = [
      Goal.create(
        title: 'Launch ExecuteOS MVP',
        description: 'Ship the personal execution core to first users',
        targetDate: DateTime.now().add(const Duration(days: 30)),
      ),
    ];
    _persist();
  }

  Future<void> addGoal(Goal goal) async {
    state = [goal, ...state];
    await _persist();
  }

  Future<void> updateGoal(Goal goal) async {
    state = [
      for (final g in state)
        if (g.id == goal.id) goal else g,
    ];
    await _persist();
  }

  Future<void> completeGoal(String id) async {
    state = [
      for (final g in state)
        if (g.id == id)
          g.copyWith(
            status: GoalStatus.completed,
            completedAt: DateTime.now(),
          )
        else
          g,
    ];
    await _persist();
  }

  Future<void> deleteGoal(String id) async {
    state = state.where((g) => g.id != id).toList();
    await _persist();
  }

  Map<String, dynamic> _toJson(Goal g) => {
        'id': g.id,
        'title': g.title,
        'description': g.description,
        'status': g.status.name,
        'targetDate': g.targetDate?.toIso8601String(),
        'createdAt': g.createdAt.toIso8601String(),
        'updatedAt': g.updatedAt.toIso8601String(),
        'completedAt': g.completedAt?.toIso8601String(),
      };

  Goal _fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: GoalStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => GoalStatus.active,
      ),
      targetDate: json['targetDate'] != null
          ? DateTime.parse(json['targetDate'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }
}

final goalListProvider =
    StateNotifierProvider<GoalListNotifier, List<Goal>>((ref) {
  return GoalListNotifier();
});

final activeGoalsProvider = Provider<List<Goal>>((ref) {
  return ref.watch(goalListProvider).where((g) => g.isActive).toList();
});
