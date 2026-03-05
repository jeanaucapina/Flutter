import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/block.dart';

class FloorData {
  final String building;
  final int floor;
  final String image;
  final List<Classroom> classrooms;

  FloorData({
    required this.building,
    required this.floor,
    required this.image,
    required this.classrooms,
  });
}

Future<FloorData> loadFloor(String path) async {

  final jsonString = await rootBundle.loadString(path);

  final data = json.decode(jsonString);

  List classroomsJson = data["classrooms"];

  List<Classroom> classrooms =
      classroomsJson.map((c) => Classroom.fromJson(c)).toList();

  return FloorData(
    building: data["building"],
    floor: data["floor"],
    image: data["image"],
    classrooms: classrooms,
  );
}