import 'package:latlong2/latlong.dart';

class Block {
  final String name;
  final String code;
  final LatLng location;
  final List<Floor> floors;

  Block({
    required this.name,
    required this.code,
    required this.location,
    required this.floors,
  });
}

class Floor {
  final int number;
  final List<Classroom> classrooms;

  Floor({
    required this.number,
    required this.classrooms,
  });
}

class Classroom {
  final String name;
  final double x;
  final double y;
  final String directions;

  Classroom({
    required this.name,
    required this.x,
    required this.y,
    required this.directions,
  });

  factory Classroom.fromJson(Map<String, dynamic> json) {
    return Classroom(
      name: json["name"],
      x: (json["x"] as num).toDouble(),
      y: (json["y"] as num).toDouble(),
      directions: json["directions"],
    );
  }
}