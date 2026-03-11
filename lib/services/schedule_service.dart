import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/search_classroom.dart';

class ScheduleItem {
  final int weekday;
  final TimeOfDay start;
  final String classroomName;
  final String building;
  final int floor;
  final String subject;

  const ScheduleItem({
    required this.weekday,
    required this.start,
    required this.classroomName,
    required this.building,
    required this.floor,
    required this.subject,
  });

  Map<String, dynamic> toJson() {
    return {
      'weekday': weekday,
      'hour': start.hour,
      'minute': start.minute,
      'classroomName': classroomName,
      'building': building,
      'floor': floor,
      'subject': subject,
    };
  }

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    return ScheduleItem(
      weekday: json['weekday'] as int,
      start: TimeOfDay(
        hour: json['hour'] as int,
        minute: json['minute'] as int,
      ),
      classroomName: json['classroomName'] as String,
      building: json['building'] as String,
      floor: json['floor'] as int,
      subject: json['subject'] as String,
    );
  }
}

class ScheduleService {
  static const String _scheduleKey = 'user_schedule_items';

  static final List<ScheduleItem> _defaultSchedule = [
    const ScheduleItem(
      weekday: DateTime.monday,
      start: TimeOfDay(hour: 8, minute: 0),
      classroomName: 'B101',
      building: 'Bloque B',
      floor: 1,
      subject: 'Matematicas I',
    ),
    const ScheduleItem(
      weekday: DateTime.monday,
      start: TimeOfDay(hour: 10, minute: 0),
      classroomName: 'B202',
      building: 'Bloque B',
      floor: 2,
      subject: 'Programacion',
    ),
    const ScheduleItem(
      weekday: DateTime.tuesday,
      start: TimeOfDay(hour: 9, minute: 0),
      classroomName: 'C101',
      building: 'Bloque C',
      floor: 1,
      subject: 'Fisica',
    ),
    const ScheduleItem(
      weekday: DateTime.wednesday,
      start: TimeOfDay(hour: 11, minute: 0),
      classroomName: 'B204',
      building: 'Bloque B',
      floor: 2,
      subject: 'Base de Datos',
    ),
  ];

  static List<ScheduleItem>? _cache;

  static Future<List<ScheduleItem>> loadSchedule() async {
    if (_cache != null) {
      return List<ScheduleItem>.from(_cache!);
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_scheduleKey);

    if (raw == null || raw.isEmpty) {
      _cache = List<ScheduleItem>.from(_defaultSchedule);
      return List<ScheduleItem>.from(_cache!);
    }

    final List<dynamic> decoded = json.decode(raw);
    _cache = decoded
        .map((e) => ScheduleItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    return List<ScheduleItem>.from(_cache!);
  }

  static Future<void> saveSchedule(List<ScheduleItem> items) async {
    _cache = List<ScheduleItem>.from(items);
    final prefs = await SharedPreferences.getInstance();
    final payload = json.encode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_scheduleKey, payload);
  }

  static Future<ScheduleItem?> nextForNow(DateTime now) async {
    final schedule = await loadSchedule();
    final today = schedule.where((item) => item.weekday == now.weekday).toList()
      ..sort((a, b) => _toMinutes(a.start).compareTo(_toMinutes(b.start)));

    final nowMinutes = now.hour * 60 + now.minute;
    for (final item in today) {
      if (_toMinutes(item.start) >= nowMinutes) {
        return item;
      }
    }
    return null;
  }

  static String weekdayLabel(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Lunes';
      case DateTime.tuesday:
        return 'Martes';
      case DateTime.wednesday:
        return 'Miercoles';
      case DateTime.thursday:
        return 'Jueves';
      case DateTime.friday:
        return 'Viernes';
      case DateTime.saturday:
        return 'Sabado';
      case DateTime.sunday:
        return 'Domingo';
      default:
        return 'Dia';
    }
  }

  static SearchClassroom toSearchClassroom(ScheduleItem item) {
    return SearchClassroom(
      name: item.classroomName,
      building: item.building,
      floor: item.floor,
      aliases: [item.subject],
    );
  }

  static int _toMinutes(TimeOfDay time) => time.hour * 60 + time.minute;
}
