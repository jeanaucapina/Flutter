import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TaskItem {
  final String title;
  final DateTime dueAt;
  final bool done;

  const TaskItem({
    required this.title,
    required this.dueAt,
    this.done = false,
  });

  TaskItem copyWith({
    String? title,
    DateTime? dueAt,
    bool? done,
  }) {
    return TaskItem(
      title: title ?? this.title,
      dueAt: dueAt ?? this.dueAt,
      done: done ?? this.done,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'dueAt': dueAt.toIso8601String(),
      'done': done,
    };
  }

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      title: json['title'] as String,
      dueAt: DateTime.parse(json['dueAt'] as String),
      done: (json['done'] as bool?) ?? false,
    );
  }
}

class TasksService {
  static const String _tasksKey = 'user_task_items';
  static List<TaskItem>? _cache;

  static Future<List<TaskItem>> loadTasks() async {
    if (_cache != null) {
      return List<TaskItem>.from(_cache!);
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_tasksKey);
    if (raw == null || raw.isEmpty) {
      _cache = <TaskItem>[];
      return [];
    }

    final List<dynamic> decoded = json.decode(raw);
    _cache = decoded
        .map((e) => TaskItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    return List<TaskItem>.from(_cache!);
  }

  static Future<void> saveTasks(List<TaskItem> items) async {
    _cache = List<TaskItem>.from(items);
    final prefs = await SharedPreferences.getInstance();
    final raw = json.encode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_tasksKey, raw);
  }
}
