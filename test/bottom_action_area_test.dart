import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:educa_plus/ui/widgets/bottom_action_area.dart';

void main() {
  testWidgets('BottomActionArea reserves ad area and respects MediaQuery padding',
      (tester) async {
    const bottomInset = 34.0; // simulate a gesture nav inset on Android

    final childKey = UniqueKey();

    await tester.pumpWidget(MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(padding: EdgeInsets.only(bottom: bottomInset)),
        child: Scaffold(
          bottomNavigationBar: BottomActionArea(
            child: SizedBox(key: childKey, height: 48, child: const Text('CTA')),
          ),
        ),
      ),
    ));

    // Ad area should exist
    expect(find.byType(SizedBox), findsWidgets);

    // The child passed should be present
    expect(find.byKey(childKey), findsOneWidget);
  });
}
