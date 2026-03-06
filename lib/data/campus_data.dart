import 'package:latlong2/latlong.dart';
import '../models/block.dart';

final List<Classroom> aulasPlanta1 = [
  Classroom(
    name: "B101",
    x: 0.17,
    y: 0.21,
    directions: "Desde la entrada principal avance recto y gire a la izquierda.",
  ),
  Classroom(
    name: "B102",
    x: 0.30,
    y: 0.21,
    directions: "Suba por la escalera y avance por el pasillo derecho.",
  ),
  Classroom(
    name: "B104",
    x: 0.17,
    y: 0.63,
    directions: "Desde la entrada principal avance recto y gire a la izquierda.",
  ),
  Classroom(
    name: "B105",
    x: 0.30,
    y: 0.63,
    directions: "Suba por la escalera y avance por el pasillo derecho.",
  ),
];

final List<Classroom> aulasPlanta2 = [
  Classroom(
    name: "B201",
    x: 0.17,
    y: 0.21,
    directions: "Desde la entrada principal avance recto y gire a la izquierda.",
  ),
  Classroom(
    name: "B202",
    x: 0.30,
    y: 0.21,
    directions: "Suba por la escalera y avance por el pasillo derecho.",
  ),
  Classroom(
    name: "B204",
    x: 0.17,
    y: 0.63,
    directions: "Desde la entrada principal avance recto y gire a la izquierda.",
  ),
  Classroom(
    name: "B205",
    x: 0.30,
    y: 0.63,
    directions: "Suba por la escalera y avance por el pasillo derecho.",
  ),
];

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
    floors: [],
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