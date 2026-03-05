import 'package:campus_map_app/screens/floor_plan_screen.dart';
import 'package:latlong2/latlong.dart';
import '../models/block.dart';

final List<Block> campusBlocks = [
  Block(
    name: "Bloque B",
    code: "bloque_b",
    location: LatLng(-2.891727, -79.037141),
    floors: [
      Floor(
      number: 1,
      classrooms: aulasPlanta1,
    ),
      Floor(
      number: 2,
      classrooms: aulasPlanta2,
    ),
    ],
  ),
  Block(
    name: "Bloque C",
    code: "bloque_c",
    location: LatLng(-2.891215, -79.037825),
    floors: [
      Floor(
          number: 1,
          classrooms: aulasPlanta1,
        ),
      Floor(
        number: 2,
        classrooms: aulasPlanta2,
      ),
      ],
  ),
  Block(
    name: "Casona Balzay",
    code: "casona_balzay",
    location: LatLng(-2.891692, -79.036291),
    floors: [  
      
    ],
  ),
  Block(
    name: "Microred",
    code: "microred",
    location: LatLng(-2.891891, -79.038544),
    floors: [],
  ),
  Block(
    name: "Administrativo",
    code: "administrativo",
    location: LatLng(-2.891258, -79.035521),
    floors: [],
  ),
];