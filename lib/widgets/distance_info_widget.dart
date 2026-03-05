import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../services/route_handler.dart';

class DistanceInfoWidget extends StatelessWidget {
  final LatLng currentLocation;
  final LatLng destination;
  final String destinationName;

  const DistanceInfoWidget({
    super.key,
    required this.currentLocation,
    required this.destination,
    required this.destinationName,
  });

  @override
  Widget build(BuildContext context) {
    final distance = RouteHandler.calculateDistance(
      currentLocation,
      destination,
    );
    final bearing = RouteHandler.calculateBearing(
      currentLocation,
      destination,
    );
    final direction = RouteHandler.getDirectionName(bearing);
    final formattedDistance = RouteHandler.formatDistance(distance);

    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ruta a $destinationName',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  _getDirectionIcon(direction),
                  size: 32,
                  color: Colors.blue,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dirección: $direction',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Distancia: $formattedDistance',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getDirectionIcon(String direction) {
    switch (direction) {
      case 'N':
        return Icons.arrow_upward;
      case 'S':
        return Icons.arrow_downward;
      case 'E':
        return Icons.arrow_forward;
      case 'O':
      case 'W':
        return Icons.arrow_back;
      default:
        return Icons.navigation;
    }
  }
}
