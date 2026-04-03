// Basic smoke test — verifies the app starts up without crashing.
// The splash screen is the first widget shown so we confirm it renders.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:continental/main.dart';

void main() {
  testWidgets('App starts without crashing', (WidgetTester tester) async {
    // Build the app inside a ProviderScope (required for Riverpod)
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // The app should render a Scaffold without throwing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
