import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:campus_map_app/services/route_handler.dart';

void main() {
  group('RouteHandler Tests', () {
    test('calculateDistance returns correct value', () {
      final start = LatLng(-2.8916, -79.0372);
      final end = LatLng(-2.8920, -79.0375);
      
      final distance = RouteHandler.calculateDistance(start, end);
      
      expect(distance, isA<double>());
      expect(distance, greaterThan(0));
      expect(distance, lessThan(1000)); // Should be less than 1km
    });

    test('formatDistance handles meters correctly', () {
      final distance = RouteHandler.formatDistance(500);
      expect(distance, equals('500 m'));
    });

    test('formatDistance handles kilometers correctly', () {
      final distance = RouteHandler.formatDistance(1500);
      expect(distance, equals('1.50 km'));
    });

    test('getDirectionName returns valid directions', () {
      expect(RouteHandler.getDirectionName(0), equals('N'));
      expect(RouteHandler.getDirectionName(90), equals('E'));
      expect(RouteHandler.getDirectionName(180), equals('S'));
      expect(RouteHandler.getDirectionName(270), equals('O'));
    });

    test('getRouteInstructions returns non-empty string', () {
      final start = LatLng(-2.8916, -79.0372);
      final end = LatLng(-2.8920, -79.0375);
      
      final instructions = RouteHandler.getRouteInstructions(start, end);
      
      expect(instructions, isNotEmpty);
      expect(instructions, contains('Dirígete'));
    });
  });
}
