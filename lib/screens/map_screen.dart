import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../data/campus_data.dart';
import '../models/app_role.dart';
import '../models/search_classroom.dart';
import '../search/classroom_search.dart';
import '../services/classroom_index_service.dart';
import '../services/favorites_service.dart';
import '../services/schedule_service.dart';
import '../services/theme_provider.dart';
import '../widgets/animated_routes.dart';
import 'block_detail_screen.dart';
import 'floor_plan_screen.dart';
import 'schedule_screen.dart';
import 'widgets/map_screen_sections.dart';

class MapScreen extends StatefulWidget {
  final AppRole role;
  final VoidCallback? onChangeRole;

  const MapScreen({
    super.key,
    required this.role,
    this.onChangeRole,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Stream<Position>? _positionStream;
  StreamSubscription<Position>? _positionSubscription;
  final MapController _mapController = MapController();

  LatLng? userLocation;
  LatLng? destination;
  SearchClassroom? selectedClassroom;

  String _locationStatus = 'Iniciando ubicacion...';
  bool _locationAvailable = false;
  bool _isRequestingLocation = false;
  bool _hasCentered = false;
  bool _followUser = true;

  List<SearchClassroom> classroomIndex = [];
  Set<String> _favoriteClassroomIds = <String>{};
  ScheduleItem? _nextClassItem;

  bool get _isStudent => widget.role == AppRole.student;

  @override
  void initState() {
    super.initState();
    _startLocationTracking();
    if (_isStudent) {
      _loadFavorites();
      _refreshNextClass(notify: false);
    }

    ClassroomIndexService.loadIndex().then((index) {
      if (!mounted) return;
      setState(() {
        classroomIndex = index;
      });
      if (_isStudent) {
        _refreshNextClass();
      }
    });
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
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

  List<SearchClassroom> _favoriteClassrooms() {
    final favorites =
        classroomIndex.where((c) => _favoriteClassroomIds.contains(c.id)).toList();
    favorites.sort((a, b) => a.name.compareTo(b.name));
    return favorites;
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

  void _handleClassroomSelection(SearchClassroom classroom) {
    final block = campusBlocks.firstWhere((b) => b.name == classroom.building);

    setState(() {
      destination = block.location;
      selectedClassroom = classroom;
    });

    _mapController.move(block.location, 18);
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

  void _clearSelectedRoute() {
    setState(() {
      destination = null;
      selectedClassroom = null;
    });
  }

  Future<void> _openScheduleScreen() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ScheduleScreen(),
      ),
    );
    await _refreshNextClass();
  }

  Future<void> _startLocationTracking() async {
    setState(() {
      _isRequestingLocation = true;
      _locationStatus = 'Solicitando permisos de ubicacion...';
    });

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      setState(() {
        _locationAvailable = false;
        _locationStatus = 'Activa los servicios de ubicacion.';
        _isRequestingLocation = false;
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        setState(() {
          _locationAvailable = false;
          _locationStatus = 'Permiso de ubicacion denegado.';
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

    if (!mounted) return;
    setState(() {
      _locationAvailable = true;
      _locationStatus = 'Ubicacion activa';
      _isRequestingLocation = false;
    });

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings);

    _positionSubscription = _positionStream!.listen((position) {
      final newLocation = LatLng(position.latitude, position.longitude);

      if (!mounted) return;

      setState(() {
        userLocation = newLocation;
        _locationStatus = 'Ubicacion actualizada';
      });

      if (!_hasCentered) {
        _mapController.move(newLocation, 18);
        _hasCentered = true;
      }

      if (_followUser) {
        _mapController.move(newLocation, _mapController.camera.zoom);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final favoriteClassrooms = _favoriteClassrooms();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Map'),
        actions: [
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
          if (_isStudent)
            IconButton(
              icon: const Icon(Icons.schedule),
              tooltip: 'Ver y editar horario',
              onPressed: _openScheduleScreen,
            ),
          if (widget.onChangeRole != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: TextButton.icon(
                onPressed: widget.onChangeRole,
                icon: const Icon(Icons.switch_account_outlined, size: 18),
                label: const Text('Perfil'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                tooltip: 'Cambiar tema',
                onPressed: themeProvider.toggleTheme,
              );
            },
          ),
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
                child: const Text('Texto pequeno'),
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
          CampusMapLayer(
            mapController: _mapController,
            userLocation: userLocation,
            destination: destination,
            blocks: campusBlocks,
            onBlockTap: (block) {
              Navigator.push(
                context,
                ScalePageRoute(
                  child: BlockDetailScreen(block: block),
                ),
              );
            },
          ),
          if (_isStudent)
            TopQuickPanel(
              nextClassItem: _nextClassItem,
              favoriteClassrooms: favoriteClassrooms,
              onOpenNextClass: _openNextClass,
              onSelectFavorite: _handleClassroomSelection,
            ),
          LocationStatusCard(
            isRequestingLocation: _isRequestingLocation,
            locationAvailable: _locationAvailable,
            locationStatus: _locationStatus,
            onRetry: _startLocationTracking,
          ),
        ],
      ),
      floatingActionButton: RouteActionButtons(
        selectedClassroom: selectedClassroom,
        userLocation: userLocation,
        destination: destination,
        followUser: _followUser,
        onToggleFollow: () {
          setState(() {
            _followUser = !_followUser;
          });
        },
        onClearRoute: _clearSelectedRoute,
        onOpenIndoorRoute: () {
          if (selectedClassroom == null) return;
          Navigator.push(
            context,
            ScalePageRoute(
              child: FloorPlanScreen(
                jsonPath:
                    'assets/data/${selectedClassroom!.building.toLowerCase().replaceAll(' ', '_')}_planta${selectedClassroom!.floor}.json',
                highlightClassroom: selectedClassroom!.name,
              ),
            ),
          );
        },
      ),
    );
  }
}
