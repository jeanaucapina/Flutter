import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:campus_map_app/main.dart';
import 'package:campus_map_app/services/theme_provider.dart';

void main() {
  testWidgets('MyApp renders core UI', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const MyApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Campus Map'), findsOneWidget);
    expect(find.byIcon(Icons.search), findsWidgets);
  });
}
