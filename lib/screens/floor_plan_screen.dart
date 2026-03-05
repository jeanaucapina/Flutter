import 'package:campus_map_app/models/block.dart';
import 'package:flutter/material.dart';
import '../services/floor_loader.dart';


class FloorPlanScreen extends StatefulWidget {

  final String jsonPath;
  final String? highlightClassroom;

  const FloorPlanScreen({
    super.key,
    required this.jsonPath,
    this.highlightClassroom,
  });

  @override
  State<FloorPlanScreen> createState() => _FloorPlanScreenState();
}



class _FloorPlanScreenState extends State<FloorPlanScreen> {

  String? selectedClassroom;
  
  FloorData? floorData;

  @override
  void initState() {
    super.initState();

    loadFloor(widget.jsonPath).then((data) {
      setState(() {
        floorData = data;
      });

      if (widget.highlightClassroom != null) {

        final classroom = data.classrooms.firstWhere(
          (c) => c.name == widget.highlightClassroom,
          orElse: () => data.classrooms.first,
        );

        Future.delayed(const Duration(milliseconds: 400), () {
          _showClassroomInfo(context, classroom);
        });

      }



    });
  }

  @override
  Widget build(BuildContext context) {
    if (floorData == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("${floorData!.building} - Planta ${floorData!.floor}"),
      ),
        body: LayoutBuilder(
        builder: (context, constraints) {

          final double containerWidth = constraints.maxWidth;
          final double containerHeight = constraints.maxHeight;

          // Relación real de tu imagen (ajusta si es diferente)
          const double imageAspectRatio = 2.5; // ejemplo A4 vertical (ancho/alto)

          double displayedWidth;
          double displayedHeight;

          if (containerWidth / containerHeight > imageAspectRatio) {
            // Se ajusta por altura
            displayedHeight = containerHeight;
            displayedWidth = displayedHeight * imageAspectRatio;
          } else {
            // Se ajusta por ancho
            displayedWidth = containerWidth;
            displayedHeight = displayedWidth / imageAspectRatio;
          }

          final double offsetX = (containerWidth - displayedWidth) / 2;
          final double offsetY = (containerHeight - displayedHeight) / 2;

          return InteractiveViewer(
            minScale: 1,
            maxScale: 5,
            child: Stack(
              children: [

                Positioned(
                  left: offsetX,
                  top: offsetY,
                  width: displayedWidth,
                  height: displayedHeight,
                  child: Image.asset(
                    floorData!.image,
                    fit: BoxFit.fill,
                  ),
                ),

                // Classroom ejemplo
                ...floorData!.classrooms.map((classroom) {
                  return Positioned(
                    left: offsetX + displayedWidth * classroom.x,
                    top: offsetY + displayedHeight * classroom.y,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedClassroom = classroom.name;
                        });

                        _showClassroomInfo(context, classroom);
                      },
                      child: Container(
                        width: displayedWidth * 0.05,
                        height: displayedWidth * 0.05,
                        decoration: BoxDecoration(
                          color: (classroom.name == widget.highlightClassroom || classroom.name == selectedClassroom)
                              ? Colors.red.withOpacity(0.7)
                              : Colors.blue.withOpacity(0.5),
                          border: Border.all(color: Colors.black),
                        ),
                        child: Center(
                          child: Text(
                            classroom.name,
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),




    );
  }

  void _showClassroomInfo(BuildContext context, Classroom Classroom) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Aula ${Classroom.name}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(Classroom.directions),
            ],
          ),
        );
      },
    );
  }
}

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
    name: "B101",
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
