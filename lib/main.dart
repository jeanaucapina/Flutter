import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../data/campus_data.dart';
import '../models/block.dart';
import '../screens/floor_plan_screen.dart';
import '../screens/schedule_screen.dart';
import '../services/classroom_index_service.dart';
import '../models/search_classroom.dart';
import '../search/classroom_search.dart';
import '../services/theme_provider.dart';
import '../services/favorites_service.dart';
import '../services/schedule_service.dart';
import '../widgets/animated_routes.dart';
import '../widgets/distance_info_widget.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          home: const MapScreen(),
          debugShowCheckedModeBanner: false,
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        );
      },
    );
  }
}

class MapScreen extends StatefulWidget {
    const MapScreen({super.key});
    

  @override
  State<MapScreen> createState() => _MapScreenState();
}
class _MapScreenState extends State<MapScreen> {
  Stream<Position>? _positionStream;
  StreamSubscription<Position>? _positionSubscription;
  LatLng? userLocation;
  LatLng? destination;
  SearchClassroom? selectedClassroom;
 
  String _locationStatus = 'Iniciando ubicación...';
  bool _locationAvailable = false;
  bool _isRequestingLocation = false;

  List<SearchClassroom> classroomIndex = [];
  Set<String> _favoriteClassroomIds = <String>{};
  ScheduleItem? _nextClassItem;

  final MapController _mapController = MapController();

  bool _hasCentered = false;
  bool _followUser = true;
  

  @override
  void initState() {
    super.initState();
    _startLocationTracking();
    _loadFavorites();
    _refreshNextClass(notify: false);

    //para busqueda

    ClassroomIndexService.loadIndex().then((index) {
      if (!mounted) return;
      setState(() {
        classroomIndex = index;
      });
      _refreshNextClass();
    });
  }

  Future<void> _loadFavorites() async {
    final favorites = await FavoritesService.loadFavorites();
    if (!mounted) return;
    setState(() {
      _favoriteClassroomIds = favorites;
    });
  }

  Future<void> _toggleFavorite(SearchClassroom classroom) async {
    setState(() {
      if (_favoriteClassroomIds.contains(classroom.id)) {
        _favoriteClassroomIds.remove(classroom.id);
      } else {
        _favoriteClassroomIds.add(classroom.id);
      }
    });
    await FavoritesService.saveFavorites(_favoriteClassroomIds);
  }

  Future<void> _refreshNextClass({bool notify = true}) async {
    final next = await ScheduleService.nextForNow(DateTime.now());
    if (!mounted) return;
    if (!notify) {
      _nextClassItem = next;
      return;
    }
    setState(() {
      _nextClassItem = next;
    });
  }

  SearchClassroom? _findClassroom({
    required String name,
    required String building,
    required int floor,
  }) {
    for (final classroom in classroomIndex) {
      if (classroom.name == name &&
          classroom.building == building &&
          classroom.floor == floor) {
        return classroom;
      }
    }
    return null;
  }

  void _openNextClass() {
    if (_nextClassItem == null) return;

    final target = _findClassroom(
      name: _nextClassItem!.classroomName,
      building: _nextClassItem!.building,
      floor: _nextClassItem!.floor,
    );

    if (target != null) {
      _handleClassroomSelection(target);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('La clase del horario no existe en el indice de aulas.'),
      ),
    );
  }

  Future<void> _openScheduleScreen() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ScheduleScreen(),
      ),
    );
    await _refreshNextClass();
  }

  List<SearchClassroom> _favoriteClassrooms() {
    final favorites = classroomIndex.where((c) => _favoriteClassroomIds.contains(c.id)).toList();
    favorites.sort((a, b) => a.name.compareTo(b.name));
    return favorites;
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _startLocationTracking() async {
    setState(() {
      _isRequestingLocation = true;
      _locationStatus = 'Solicitando permisos de ubicación...';
    });

    bool serviceEnabled;
    LocationPermission permission;

    // Verifica si el GPS está activado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      setState(() {
        _locationAvailable = false;
        _locationStatus = 'Activa los servicios de ubicación.';
        _isRequestingLocation = false;
      });
      return;
    }

    // Verifica permisos
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        setState(() {
          _locationAvailable = false;
          _locationStatus = 'Permiso de ubicación denegado.';
          _isRequestingLocation = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      setState(() {
        _locationAvailable = false;
        _locationStatus = 'Permiso denegado permanentemente.';
        _isRequestingLocation = false;
      });
      return;
    }

    // Permisos OK
    if (!mounted) return;
    setState(() {
      _locationAvailable = true;
      _locationStatus = 'Ubicación activa';
      _isRequestingLocation = false;
    });

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // actualiza cada 5 metros
    );

    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings);

    _positionSubscription = _positionStream!.listen((Position position) {
      final LatLng newLocation = LatLng(position.latitude, position.longitude);

      if (!mounted) return;

      setState(() {
        userLocation = newLocation;
        _locationStatus = 'Ubicación actualizada';
      });

      // Centrar automáticamente solo la primera vez
      if (!_hasCentered) {
        _mapController.move(newLocation, 18);
        _hasCentered = true;
      }

      // Seguir usuario si está activado
      if (_followUser) {
        _mapController.move(newLocation, _mapController.camera.zoom);
      }
    });
  }

  void _handleClassroomSelection(SearchClassroom classroom) {

    final block = campusBlocks.firstWhere(
        (b) => b.name == classroom.building,
      );

      setState(() {
        destination = block.location;
        selectedClassroom = classroom;
      });

      _mapController.move(block.location, 18);
  }

  @override
  Widget build(BuildContext context) {
    final favoriteClassrooms = _favoriteClassrooms();

   return Scaffold(
    appBar: AppBar(
      title: const Text("Campus Map"),
      actions: [
        // 🔍 Búsqueda
        IconButton(
          icon: const Icon(Icons.search),
          tooltip: 'Buscar aula',
          onPressed: () async {
            final result = await showSearch(
              context: context,
              delegate: ClassroomSearch(
                classroomIndex,
                favoriteIds: _favoriteClassroomIds,
                onToggleFavorite: _toggleFavorite,
              ),
            );
            if (result != null) {
              _handleClassroomSelection(result);
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.schedule),
          tooltip: 'Ver y editar horario',
          onPressed: _openScheduleScreen,
        ),
        // 🌙 Tema
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return IconButton(
              icon: Icon(
                themeProvider.isDarkMode 
                  ? Icons.light_mode 
                  : Icons.dark_mode,
              ),
              tooltip: 'Cambiar tema',
              onPressed: themeProvider.toggleTheme,
            );
          },
        ),
        // ♿ Accesibilidad
        PopupMenuButton(
          tooltip: 'Opciones de accesibilidad',
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Text('Aumentar texto'),
              onTap: () {
                Provider.of<ThemeProvider>(context, listen: false)
                    .setTextScale(1.2);
              },
            ),
            PopupMenuItem(
              child: const Text('Texto normal'),
              onTap: () {
                Provider.of<ThemeProvider>(context, listen: false)
                    .setTextScale(1.0);
              },
            ),
            PopupMenuItem(
              child: const Text('Texto pequeño'),
              onTap: () {
                Provider.of<ThemeProvider>(context, listen: false)
                    .setTextScale(0.8);
              },
            ),
          ],
          child: const Icon(Icons.accessibility),
        ),
      ],
    ),

    body: Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: const LatLng(-2.891600, -79.037200),
            initialZoom: 17,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.campus_map_app',
            ),

            MarkerLayer(
              markers: [
                // 🔵 BLOQUES
                ...campusBlocks.map((block) {
                  return Marker(
                    point: block.location,
                    width: 50,
                    height: 50,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          ScalePageRoute(
                            child: BlockDetailScreen(block: block),
                          ),
                        );
                      },
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.blue,
                        size: 32,
                      ),
                    ),
                  );
                }),

                // 🔴 USUARIO
                if (userLocation != null)
                  Marker(
                    point: userLocation!,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.green,
                      size: 30,
                    ),
                  ),

                // 🟠 DESTINO (clase elegida)
                if (destination != null)
                  Marker(
                    point: destination!,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.flag,
                      color: Colors.orange,
                      size: 30,
                    ),
                  ),
              ],
            ),

            if (userLocation != null && destination != null)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [
                      userLocation!,
                      destination!,
                    ],
                    strokeWidth: 4,
                    color: Colors.blue,
                  ),
                ],
              ),
          ],
        ),

        Positioned(
          top: 12,
          left: 12,
          right: 12,
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_nextClassItem != null)
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome_motion_outlined, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Siguiente: ${_nextClassItem!.subject} - ${_nextClassItem!.classroomName} (${_nextClassItem!.building}) ${_nextClassItem!.start.format(context)}',
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        TextButton(
                          onPressed: _openNextClass,
                          child: const Text('Ir'),
                        ),
                      ],
                    )
                  else
                    Text(
                      'No hay clases pendientes hoy en el horario de ejemplo.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  if (favoriteClassrooms.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: favoriteClassrooms.take(6).map((classroom) {
                        return ActionChip(
                          avatar: const Icon(Icons.star, size: 16),
                          label: Text(classroom.name),
                          onPressed: () => _handleClassroomSelection(classroom),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        // Indicador de estado de ubicación
        // Se posiciona más arriba para no superponerse al botón "Seguir ubicación"
        Positioned(
          left: 12,
          bottom: 16,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: _locationStatus.isEmpty ? 0 : 1,
              child: Card(
                color: _locationAvailable ? Colors.green[800] : Colors.red[700],
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isRequestingLocation)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      else
                        Icon(
                          _locationAvailable ? Icons.gps_fixed : Icons.gps_off,
                          color: Colors.white,
                          size: 18,
                        ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _locationStatus,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                      if (!_locationAvailable)
                        TextButton(
                          onPressed: _startLocationTracking,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            minimumSize: const Size(0, 28),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Reintentar',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),

    //  INFORMACIÓN DE RUTA Y BOTÓNES
    floatingActionButton: Stack(
      children: [
        // Información de distancia cuando hay destino
        if (selectedClassroom != null && userLocation != null)
          Positioned(
            left: 16,
            bottom: 180,
            right: 16,
            child: DistanceInfoWidget(
              currentLocation: userLocation!,
              destination: destination!,
              destinationName: selectedClassroom!.name,
            ),
          ),
        // Botones de acción
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // BOTÓN IR AL AULA
            if (selectedClassroom != null)
              FloatingActionButton.extended(
                heroTag: "goToClassroom",
                icon: const Icon(Icons.meeting_room),
                label: Text("Ir a ${selectedClassroom!.name}"),
                onPressed: () {
                  Navigator.push(
                    context,
                    ScalePageRoute(
                      child: FloorPlanScreen(
                        jsonPath:
                            "assets/data/${selectedClassroom!.building.toLowerCase().replaceAll(" ", "_")}_planta${selectedClassroom!.floor}.json",
                        highlightClassroom: selectedClassroom!.name,
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 10),

            // BOTÓN SEGUIR USUARIO
            FloatingActionButton(
              onPressed: () {
                setState(() {
                  _followUser = !_followUser;
                });
              },
              tooltip: _followUser ? 'Dejar de seguir' : 'Seguir ubicación',
              child: Icon(
                _followUser ? Icons.gps_fixed : Icons.gps_not_fixed,
              ),
            ),
          ],
        ),
      ],
    ),
    

    



  );
  }
}
class BlockDetailScreen extends StatelessWidget {
  final Block block;

  const BlockDetailScreen({super.key, required this.block});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(block.name)),
      body: ListView.builder(
        itemCount: block.floors.length,
        itemBuilder: (context, index) {
          final floor = block.floors[index];
          return ListTile(
            title: Text("Planta ${floor.number}"),
            onTap: () {
              // siguiente paso: mostrar aulas
              Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => FloorPlanScreen(
                  jsonPath: "assets/data/${block.code}_planta${floor.number}.json",
                ),
              ),
            );
            },
          );
        },
      ),
      

    );
  }
}