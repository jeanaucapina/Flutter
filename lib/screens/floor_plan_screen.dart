import 'package:campus_map_app/models/block.dart';
import 'package:flutter/material.dart';
import '../services/floor_loader.dart';
import 'dart:math';


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

                // Línea de ruta visual
                if (selectedClassroom != null)
                  ...floorData!.classrooms.where((c) => c.name == selectedClassroom).map((destinationClass) {
                    // Point where the indoor route starts, fully configurable in JSON.
                    final Offset startPoint = Offset(
                      offsetX + displayedWidth * floorData!.routeStart.dx,
                      offsetY + displayedHeight * floorData!.routeStart.dy,
                    );
                    final Offset endPoint = Offset(
                      offsetX + displayedWidth * destinationClass.x,
                      offsetY + displayedHeight * destinationClass.y,
                    );

                    return Positioned.fill(
                      child: CustomPaint(
                        painter: RoutePainter(
                          startPoint: startPoint,
                          endPoint: endPoint,
                        ),
                      ),
                    );
                  }).toList(),

                // Classroom ejemplo
                ...floorData!.classrooms.map((classroom) {
                  final double markerSize = (displayedWidth * 0.06).clamp(30.0, 56.0).toDouble();
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
                        width: markerSize,
                        height: markerSize,
                        decoration: BoxDecoration(
                          color: (classroom.name == widget.highlightClassroom || classroom.name == selectedClassroom)
                              ? Colors.red.withOpacity(0.7)
                              : Colors.blue.withOpacity(0.5),
                          border: Border.all(color: Colors.black),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                classroom.name,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: markerSize * 0.34,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
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

// CustomPainter para dibujar la línea de ruta con flecha
class RoutePainter extends CustomPainter {
  final Offset startPoint;
  final Offset endPoint;

  RoutePainter({
    required this.startPoint,
    required this.endPoint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.withOpacity(0.8)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Dibujar línea principal
    canvas.drawLine(startPoint, endPoint, paint);

    // Dibujar círculo en el inicio (salida)
    canvas.drawCircle(
      startPoint,
      6,
      Paint()
        ..color = Colors.green
        ..style = PaintingStyle.fill,
    );

    // Dibujar flecha en el destino
    _drawArrow(canvas, endPoint, startPoint, paint);

    // Etiqueta "Ruta"
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '🛣️ Ruta',
        style: TextStyle(
          color: Colors.green,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final midPoint = Offset(
      (startPoint.dx + endPoint.dx) / 2,
      (startPoint.dy + endPoint.dy) / 2,
    );
    textPainter.paint(canvas, midPoint - Offset(textPainter.width / 2, 0));
  }

  void _drawArrow(Canvas canvas, Offset endPoint, Offset startPoint, Paint paint) {
    // Calcular ángulo de la línea
    final angle = (endPoint - startPoint).direction;
    final arrowSize = 20.0;

    // Crear puntos de la punta de la flecha
    final arrowPoint1 = Offset(
      endPoint.dx - arrowSize * cos(angle - 0.4),
      endPoint.dy - arrowSize * sin(angle - 0.4),
    );

    final arrowPoint2 = Offset(
      endPoint.dx - arrowSize * cos(angle + 0.4),
      endPoint.dy - arrowSize * sin(angle + 0.4),
    );

    // Dibujar triángulo de la flecha
    final path = Path()
      ..moveTo(endPoint.dx, endPoint.dy)
      ..lineTo(arrowPoint1.dx, arrowPoint1.dy)
      ..lineTo(arrowPoint2.dx, arrowPoint2.dy)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.green.withOpacity(0.8)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(RoutePainter oldDelegate) {
    return oldDelegate.startPoint != startPoint || oldDelegate.endPoint != endPoint;
  }
}
