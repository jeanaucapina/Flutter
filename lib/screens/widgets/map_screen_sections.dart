import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../models/block.dart';
import '../../models/search_classroom.dart';
import '../../services/schedule_service.dart';
import '../../widgets/distance_info_widget.dart';

class CampusMapLayer extends StatelessWidget {
  final MapController mapController;
  final LatLng? userLocation;
  final LatLng? destination;
  final List<Block> blocks;
  final ValueChanged<Block> onBlockTap;

  const CampusMapLayer({
    super.key,
    required this.mapController,
    required this.userLocation,
    required this.destination,
    required this.blocks,
    required this.onBlockTap,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: const MapOptions(
        initialCenter: LatLng(-2.891600, -79.037200),
        initialZoom: 17,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.campus_map_app',
        ),
        MarkerLayer(
          markers: [
            ...blocks.map((block) {
              return Marker(
                point: block.location,
                width: 50,
                height: 50,
                child: GestureDetector(
                  onTap: () => onBlockTap(block),
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.blue,
                    size: 32,
                  ),
                ),
              );
            }),
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
                points: [userLocation!, destination!],
                strokeWidth: 4,
                color: Colors.blue,
              ),
            ],
          ),
      ],
    );
  }
}

class TopQuickPanel extends StatelessWidget {
  final ScheduleItem? nextClassItem;
  final List<SearchClassroom> favoriteClassrooms;
  final VoidCallback onOpenNextClass;
  final ValueChanged<SearchClassroom> onSelectFavorite;

  const TopQuickPanel({
    super.key,
    required this.nextClassItem,
    required this.favoriteClassrooms,
    required this.onOpenNextClass,
    required this.onSelectFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
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
              if (nextClassItem != null)
                Row(
                  children: [
                    const Icon(Icons.auto_awesome_motion_outlined, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Siguiente: ${nextClassItem!.subject} - ${nextClassItem!.classroomName} (${nextClassItem!.building}) ${nextClassItem!.start.format(context)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton(
                      onPressed: onOpenNextClass,
                      child: const Text('Ir'),
                    ),
                  ],
                )
              else
                Text(
                  'No hay clases pendientes hoy en tu horario.',
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
                      onPressed: () => onSelectFavorite(classroom),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class LocationStatusCard extends StatelessWidget {
  final bool isRequestingLocation;
  final bool locationAvailable;
  final String locationStatus;
  final VoidCallback onRetry;

  const LocationStatusCard({
    super.key,
    required this.isRequestingLocation,
    required this.locationAvailable,
    required this.locationStatus,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 12,
      bottom: 16,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 240),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: locationStatus.isEmpty ? 0 : 1,
          child: Card(
            color: locationAvailable ? Colors.green[800] : Colors.red[700],
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isRequestingLocation)
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
                      locationAvailable ? Icons.gps_fixed : Icons.gps_off,
                      color: Colors.white,
                      size: 18,
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      locationStatus,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (!locationAvailable)
                    TextButton(
                      onPressed: onRetry,
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
    );
  }
}

class RouteActionButtons extends StatelessWidget {
  final SearchClassroom? selectedClassroom;
  final LatLng? userLocation;
  final LatLng? destination;
  final bool followUser;
  final VoidCallback onToggleFollow;
  final VoidCallback onClearRoute;
  final VoidCallback onOpenIndoorRoute;

  const RouteActionButtons({
    super.key,
    required this.selectedClassroom,
    required this.userLocation,
    required this.destination,
    required this.followUser,
    required this.onToggleFollow,
    required this.onClearRoute,
    required this.onOpenIndoorRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (selectedClassroom != null && userLocation != null && destination != null)
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
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selectedClassroom != null)
              FloatingActionButton.extended(
                heroTag: 'goToClassroom',
                icon: const Icon(Icons.meeting_room),
                label: Text('Ir a ${selectedClassroom!.name}'),
                onPressed: onOpenIndoorRoute,
              ),
            const SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selectedClassroom != null)
                  FloatingActionButton.small(
                    heroTag: 'clearRoute',
                    onPressed: onClearRoute,
                    tooltip: 'Quitar ruta',
                    child: const Icon(Icons.clear),
                  ),
                if (selectedClassroom != null) const SizedBox(width: 8),
                FloatingActionButton(
                  heroTag: 'followUser',
                  onPressed: onToggleFollow,
                  tooltip: followUser ? 'Dejar de seguir' : 'Seguir ubicacion',
                  child: Icon(
                    followUser ? Icons.gps_fixed : Icons.gps_not_fixed,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
