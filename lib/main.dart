import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../data/campus_data.dart';
import '../models/block.dart';
import '../screens/floor_plan_screen.dart';
import '../services/classroom_index_service.dart';
import '../models/search_classroom.dart';
import '../search/classroom_search.dart';
import '../services/theme_provider.dart';
import '../widgets/animated_routes.dart';
import '../services/route_handler.dart';
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
  LatLng? userLocation;
  LatLng? destination;
  SearchClassroom? selectedClassroom;
 
  List<SearchClassroom> classroomIndex = [];

  final MapController _mapController = MapController();

  bool _hasCentered = false;
  bool _followUser = true;
  

  @override
  void initState() {
    super.initState();
     _startLocationTracking();

    //para busqueda

    ClassroomIndexService.loadIndex().then((index) {
       setState(() {
         classroomIndex = index;
         
       });
    });
  }

  Future<void> _startLocationTracking() async {
    bool serviceEnabled;
     

    LocationPermission permission;

    // Verifica si el GPS está activado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activa los servicios de ubicación en tu dispositivo.')),
        );
      });
      return;
    }

    // Verifica permisos
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permiso de ubicación denegado. Actívalo en la configuración.')),
          );
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permiso de ubicación denegado permanentemente. Ve a configuración para activarlo.')),
        );
      });
      return;
    }
    //FIN COMPROBACION DE PERMISOS

        const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // actualiza cada 5 metros
      );

      _positionStream =
          Geolocator.getPositionStream(locationSettings: locationSettings);

      _positionStream!.listen((Position position) {
          final LatLng newLocation =
              LatLng(position.latitude, position.longitude);

          setState(() {
            userLocation = newLocation;
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
    // Aquí centramos el mapa dinámicamente
    //_mapController.move(newLocation, 18);


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
              delegate: ClassroomSearch(classroomIndex),
            );
            if (result != null) {
              _handleClassroomSelection(result);
            }
          },
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

    body: FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: const LatLng(-2.891600, -79.037200),
        initialZoom: 17,
      ),

      children: [
        TileLayer(
          urlTemplate:
              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                    Icons.apartment,
                    size: 40,
                    color: Colors.blue,
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
                  size: 40,
                  color: Colors.red,
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