// AI English Learning App Widget Tests
//
// Basic widget tests for the AI English Learning application.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import the main app
import 'package:ai_english_learning/main.dart';

void main() {
  testWidgets('App should build without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // Verify that the app builds successfully
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('App should have correct title', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // Get the MaterialApp widget
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    
    // Verify the app title
    expect(materialApp.title, 'AI English Learning');
  });
}
