import 'package:latlong2/latlong.dart';
import 'dart:math';

class RouteHandler {
  static const Distance distance = Distance();

  /// Calcula la distancia en metros entre dos puntos
  static double calculateDistance(LatLng start, LatLng end) {
    return distance.as(LengthUnit.Meter, start, end);
  }

  /// Calcula el bearing (dirección) entre dos puntos
  static double calculateBearing(LatLng start, LatLng end) {
    const double degToRad = 3.14159 / 180.0;
    const double radToDeg = 180.0 / 3.14159;

    double lat1 = start.latitude * degToRad;
    double lat2 = end.latitude * degToRad;
    double lon1 = start.longitude * degToRad;
    double lon2 = end.longitude * degToRad;

    double dLon = lon2 - lon1;

    double y = sin(dLon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);

    double bearing = (atan2(y, x) * radToDeg + 360) % 360;
    return bearing;
  }

  /// Obtiene el nombre de la dirección basado en el bearing
  static String getDirectionName(double bearing) {
    if (bearing >= 348.75 || bearing < 11.25) return 'N';
    if (bearing >= 11.25 && bearing < 33.75) return 'NNE';
    if (bearing >= 33.75 && bearing < 56.25) return 'NE';
    if (bearing >= 56.25 && bearing < 78.75) return 'ENE';
    if (bearing >= 78.75 && bearing < 101.25) return 'E';
    if (bearing >= 101.25 && bearing < 123.75) return 'ESE';
    if (bearing >= 123.75 && bearing < 146.25) return 'SE';
    if (bearing >= 146.25 && bearing < 168.75) return 'SSE';
    if (bearing >= 168.75 && bearing < 191.25) return 'S';
    if (bearing >= 191.25 && bearing < 213.75) return 'SSO';
    if (bearing >= 213.75 && bearing < 236.25) return 'SO';
    if (bearing >= 236.25 && bearing < 258.75) return 'OSO';
    if (bearing >= 258.75 && bearing < 281.25) return 'O';
    if (bearing >= 281.25 && bearing < 303.75) return 'ONO';
    if (bearing >= 303.75 && bearing < 326.25) return 'NO';
    if (bearing >= 326.25 && bearing < 348.75) return 'NNO';
    return 'N';
  }

  /// Formatea la distancia en metros o kilómetros
  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(2)} km';
    }
  }

  /// Genera instrucciones de ruta simplificadas
  static String getRouteInstructions(LatLng current, LatLng destination) {
    final meters = calculateDistance(current, destination);
    final bearing = calculateBearing(current, destination);
    final direction = getDirectionName(bearing);
    final distanceFormatted = formatDistance(meters);

    return 'Dirígete al $direction a $distanceFormatted de distancia';
  }
}
