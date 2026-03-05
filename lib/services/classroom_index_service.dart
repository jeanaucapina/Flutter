import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/search_classroom.dart';

class ClassroomIndexService {

  static Future<List<SearchClassroom>> loadIndex() async {

    // lista de archivos JSON de plantas
    List<String> files = [
      "assets/data/bloque_b_planta1.json",
      "assets/data/bloque_b_planta2.json",
      "assets/data/bloque_c_planta1.json",
    ];

    List<SearchClassroom> index = [];

    for (String file in files) {

      final jsonString = await rootBundle.loadString(file);
      final data = json.decode(jsonString);

      String building = data["building"];
      int floor = data["floor"];

      List classrooms = data["classrooms"];

      for (var classroom in classrooms) {
        index.add(
          SearchClassroom(
            name: classroom["name"],
            building: building,
            floor: floor,
          ),
        );
      }
    }

    return index;
  }
}