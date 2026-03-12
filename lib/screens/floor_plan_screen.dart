import 'package:campus_map_app/models/block.dart';
import 'dart:ui' as ui;
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
  double _imageAspectRatio = 2.5;

  @override
  void initState() {
    super.initState();

    loadFloor(widget.jsonPath).then((data) {
      if (!mounted) return;

      setState(() {
        floorData = data;
      });
      _loadImageAspectRatio(data.image);
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

  Future<void> _loadImageAspectRatio(String assetPath) async {
    try {
      final bytes = await rootBundle.load(assetPath);
      final codec = await ui.instantiateImageCodec(bytes.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      final image = frame.image;
      if (!mounted || image.height == 0) return;
      setState(() {
        _imageAspectRatio = image.width / image.height;
      });
    } catch (_) {
      // Keep default ratio if the image cannot be decoded.
    }
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

          final double imageAspectRatio = _imageAspectRatio;

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
          final double shortestSide = MediaQuery.of(context).size.shortestSide;
          final bool isCompactScreen = shortestSide < 700;
          final double markerBaseRatio = isCompactScreen ? 0.04 : 0.055;
          final double markerMinSize = isCompactScreen ? 18.0 : 24.0;
          final double markerMaxSize = isCompactScreen ? 34.0 : 56.0;

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
                ...() {
                  final List<Rect> occupiedLabelRects = <Rect>[];
                  return floorData!.classrooms.map((classroom) {
                  final double markerSize =
                      (displayedWidth * markerBaseRatio).clamp(markerMinSize, markerMaxSize).toDouble();
                  final bool isSelected =
                      classroom.name == widget.highlightClassroom || classroom.name == selectedClassroom;
                  final double labelMaxWidth =
                      (displayedWidth * (isCompactScreen ? 0.30 : 0.22)).clamp(90.0, 210.0).toDouble();
                  final double labelHeight = isCompactScreen ? 28.0 : 32.0;
                  final pointX = offsetX + displayedWidth * classroom.x;
                  final pointY = offsetY + displayedHeight * classroom.y;

                  final Rect labelRect = Rect.fromLTWH(
                    pointX - (labelMaxWidth / 2),
                    pointY + (markerSize / 2) + 4,
                    labelMaxWidth,
                    labelHeight,
                  );

                  final bool overlapsAnother = occupiedLabelRects.any((rect) => rect.overlaps(labelRect));
                  final bool showLabel = isSelected || !overlapsAnother;
                  if (showLabel) {
                    occupiedLabelRects.add(labelRect);
                  }

                  return Positioned(
                    left: pointX - markerSize / 2,
                    top: pointY - markerSize / 2,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedClassroom = classroom.name;
                        });

                        _showClassroomInfo(context, classroom);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: markerSize,
                            height: markerSize,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.red.withValues(alpha: 0.85)
                                  : Colors.blue.withValues(alpha: 0.75),
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(markerSize * 0.24),
                            ),
                            child: Icon(
                              Icons.place,
                              size: markerSize * 0.55,
                              color: Colors.white,
                            ),
                          ),
                          if (showLabel) ...[
                            const SizedBox(height: 4),
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: labelMaxWidth),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.black.withValues(alpha: 0.78)
                                      : Colors.black.withValues(alpha: 0.62),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  classroom.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isCompactScreen ? 10 : 11,
                                    fontWeight: FontWeight.w600,
                                    height: 1.1,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                  });
                }(),
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
