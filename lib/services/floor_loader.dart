import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/block.dart';

class FloorData {
  final String building;
  final int floor;
  final String image;
  final Offset entrance;
  final Offset routeStart;
  final List<Classroom> classrooms;

  FloorData({
    required this.building,
    required this.floor,
    required this.image,
    required this.entrance,
    required this.routeStart,
    required this.classrooms,
  });
}

Future<FloorData> loadFloor(String path) async {

  final jsonString = await rootBundle.loadString(path);

  final data = json.decode(jsonString);

  List classroomsJson = data["classrooms"];

  List<Classroom> classrooms =
      classroomsJson.map((c) => Classroom.fromJson(c)).toList();

  final entranceData = data["entrance"];
  final entrance = Offset(
    (entranceData["x"] as num).toDouble(),
    (entranceData["y"] as num).toDouble(),
  );

  // Dedicated point for drawing indoor routes. Falls back to entrance if absent.
  final routeStartData = data["route_start"] ?? entranceData;
  final routeStart = Offset(
    (routeStartData["x"] as num).toDouble(),
    (routeStartData["y"] as num).toDouble(),
  );

  return FloorData(
    building: data["building"],
    floor: data["floor"],
    image: data["image"],
    entrance: entrance,
    routeStart: routeStart,
    classrooms: classrooms,
  );
}