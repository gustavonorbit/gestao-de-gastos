// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import 'package:educa_plus/app/router.dart' as app;

void main() {
  testWidgets('App shows welcome scaffold', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          title: 'Educa+',
          theme: app.buildTheme(),
          routerConfig: app.buildRouter(),
        ),
      ),
    );

    // Verify that we land on the classes list.
    // (Avoid pumpAndSettle because Riverpod/async loading can keep scheduling frames.)
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Turmas'), findsOneWidget);
  });
}
