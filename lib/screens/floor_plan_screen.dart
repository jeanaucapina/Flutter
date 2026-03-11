import 'package:campus_map_app/models/block.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/floor_loader.dart';
import '../widgets/route_painter.dart';


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
  bool _hasPreviousFloor = false;
  bool _hasNextFloor = false;

  @override
  void initState() {
    super.initState();

    loadFloor(widget.jsonPath).then((data) {
      if (!mounted) return;

      setState(() {
        floorData = data;
      });
      _refreshFloorNavigation(data.floor);

      if (widget.highlightClassroom != null) {

        final classroom = data.classrooms.firstWhere(
          (c) => c.name == widget.highlightClassroom,
          orElse: () => data.classrooms.first,
        );

        Future.delayed(const Duration(milliseconds: 400), () {
          if (!mounted) return;
          _showClassroomInfo(context, classroom);
        });

      }



    });
  }

  String? _floorPathFor(int floor) {
    final match = RegExp(r'^(assets/data/.+_planta)\d+(.json)$').firstMatch(widget.jsonPath);
    if (match == null) return null;
    return '${match.group(1)}$floor${match.group(2)}';
  }

  Future<bool> _assetExists(String assetPath) async {
    try {
      await rootBundle.loadString(assetPath);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _refreshFloorNavigation(int currentFloor) async {
    final previousPath = _floorPathFor(currentFloor - 1);
    final nextPath = _floorPathFor(currentFloor + 1);

    final hasPrevious = previousPath != null && await _assetExists(previousPath);
    final hasNext = nextPath != null && await _assetExists(nextPath);

    if (!mounted) return;
    setState(() {
      _hasPreviousFloor = hasPrevious;
      _hasNextFloor = hasNext;
    });
  }

  Future<void> _navigateToFloor(int floor) async {
    final path = _floorPathFor(floor);
    if (path == null) return;

    if (!await _assetExists(path) || !mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => FloorPlanScreen(
          jsonPath: path,
          highlightClassroom: widget.highlightClassroom,
        ),
      ),
    );
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
        actions: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down),
            tooltip: 'Bajar planta',
            onPressed: _hasPreviousFloor ? () => _navigateToFloor(floorData!.floor - 1) : null,
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_up),
            tooltip: 'Subir planta',
            onPressed: _hasNextFloor ? () => _navigateToFloor(floorData!.floor + 1) : null,
          ),
        ],
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
                  }),

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
                              ? Colors.red.withValues(alpha: 0.7)
                              : Colors.blue.withValues(alpha: 0.5),
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
                }),
              ],
            ),
          );
        },
      ),




    );
  }

  void _showClassroomInfo(BuildContext context, Classroom classroom) {
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
                "Aula ${classroom.name}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(classroom.directions),
            ],
          ),
        );
      },
    );
  }
}
