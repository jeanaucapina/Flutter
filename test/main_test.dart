import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:campus_map_app/main.dart';
import 'package:campus_map_app/services/theme_provider.dart';

void main() {
  group('MyApp Widget Tests', () {
    testWidgets('MyApp builds without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
          child: const MyApp(),
        ),
      );

      expect(find.byType(MyApp), findsOneWidget);
    });

    testWidgets('Theme toggle works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
          child: const MyApp(),
        ),
      );
      await tester.tap(find.text('Soy estudiante'));
      await tester.pumpAndSettle();

      // Find the theme toggle button
      final themeButton = find.byIcon(Icons.dark_mode);
      expect(themeButton, findsWidgets);
    });

    testWidgets('Search icon is present in AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
          child: const MyApp(),
        ),
      );
      await tester.tap(find.text('Soy estudiante'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search), findsWidgets);
    });

    testWidgets('AppBar title is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
          child: const MyApp(),
        ),
      );
      await tester.tap(find.text('Soy estudiante'));
      await tester.pumpAndSettle();

      expect(find.text('Campus Map'), findsOneWidget);
    });
  });
}
