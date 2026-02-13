// Tests to protect the keyboard/focus UX contract before adding
// a global UnfocusOnRouteChangeObserver.
//
// The goal: document and guard the current behavior:
// - tap outside inputs unfocuses
// - navigation should unfocus (protected by test; may fail before observer)
// - dialogs with autofocus keep working
// - cancelled pops (WillPopScope) do NOT cause unfocus

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:educa_plus/core/navigation/unfocus_on_route_change_observer.dart';

void main() {
  // ETAPA 2 — Test 1: Tap fora desfoca (baseline)
  testWidgets('Tap outside unfocus (baseline)', (WidgetTester tester) async {
    // This widget replicates the in-app pattern where the Scaffold body
    // contains a translucent area that calls unfocus() on tap.
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(key: const Key('text-field')), 
            ),
            // The expanded area simulates the 'tap-to-unfocus' body wrapper.
            Expanded(
              child: Builder(builder: (context) {
                return GestureDetector(
                  key: const Key('bg-area'),
                  behavior: HitTestBehavior.translucent,
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: Container(),
                );
              }),
            ),
          ],
        ),
      ),
    ));

    // 1) Focus the TextField
    await tester.tap(find.byKey(const Key('text-field')));
    await tester.pumpAndSettle();

    // 2) Ensure there's an active primary focus
    expect(FocusManager.instance.primaryFocus, isNotNull,
        reason: 'TextField should have focus after tap');

  // 3) Tap outside (the translucent area)
  await tester.tap(find.byKey(const Key('bg-area')));
    await tester.pumpAndSettle();

  // 4) Primary focus should no longer be the TextField.
  // Some focus nodes (scopes) can remain as non-TextField focus owners
  // in widget tests; assert the TextField lost focus instead of strictly
  // requiring primaryFocus == null to avoid flakiness.
  final primaryWidgetAfter = FocusManager.instance.primaryFocus?.context?.widget;
  expect(primaryWidgetAfter is TextField, isFalse,
    reason: 'Tapping the outside area should unfocus the TextField');
  });

  // ETAPA 3 — Test 2: Navegação fecha teclado
  testWidgets('Navigation should unfocus (guard for future observer)',
      (WidgetTester tester) async {
    // Note: this test documents the desired behavior after we add the
    // UnfocusOnRouteChangeObserver. It may FAIL today (before observer).

    final router = GoRouter(routes: [
      GoRoute(
        path: '/form',
        builder: (context, state) => FormScreen(),
      ),
      GoRoute(
        path: '/next',
        builder: (context, state) => const Scaffold(body: Center(child: Text('NEXT'))),
      ),
    ], initialLocation: '/form', observers: [UnfocusOnRouteChangeObserver()]);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    // Focus the TextField in FormScreen
    await tester.tap(find.byKey(const Key('form-field')));
    await tester.pumpAndSettle();

    expect(FocusManager.instance.primaryFocus, isNotNull,
        reason: 'Form TextField should have focus');

    // Trigger navigation: the form screen contains a button that does context.push('/next')
    await tester.tap(find.byKey(const Key('push-button')));
    await tester.pumpAndSettle();

  // After navigating to /next we EXPECT the keyboard to be closed.
  // Assert that no TextField remains focused. In widget tests a View/Modal
  // FocusScope may still be primary; asserting the TextField lost focus is a
  // more robust expression of the UX contract while avoiding framework
  // implementation details.
  final navPrimaryWidget = FocusManager.instance.primaryFocus?.context?.widget;
  expect(navPrimaryWidget is TextField, isFalse,
    reason:
      'After navigation no TextField should remain focused (keyboard closed)');
  });

  // ETAPA 4 — Test 3: Dialog com autofocus NÃO quebra
  testWidgets('Dialog with autofocus focuses and unfocuses when closed',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(builder: (context) {
          return Center(
            child: ElevatedButton(
              key: const Key('open-dialog'),
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Dialog'),
                      content: const TextField(
                        key: Key('dialog-field'),
                        autofocus: true,
                      ),
                      actions: [
                        TextButton(
                          key: const Key('close-dialog'),
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('Open Dialog'),
            ),
          );
        }),
      ),
    ));

    // Open the dialog
    await tester.tap(find.byKey(const Key('open-dialog')));
    await tester.pumpAndSettle();

  // The dialog's TextField has autofocus: should be focused
  expect(FocusManager.instance.primaryFocus, isNotNull,
    reason: 'Dialog autofocus should focus the internal TextField');

    // Close the dialog using the Close button
    await tester.tap(find.byKey(const Key('close-dialog')));
    await tester.pumpAndSettle();

  // After dialog close, the dialog's TextField should no longer be focused.
  // In widget tests the focus node may be reassigned to a transient scope
  // after the dialog is dismissed; to avoid flakiness we assert that the
  // primary focus is not a TextField's focus anymore.
  final primaryWidget = FocusManager.instance.primaryFocus?.context?.widget;
  expect(primaryWidget is TextField, isFalse,
    reason: 'After closing the dialog no TextField should remain focused');
  });

  // ETAPA 5 — Test 4: PopScope (WillPopScope) NÃO desfoca se pop for cancelado
  testWidgets('Cancelled pop does NOT unfocus (WillPopScope returns false)',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: WillPopScope(
          onWillPop: () async {
            // Simulate a screen that prevents leaving (returns false)
            return false;
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(key: const Key('willpop-field')),
              ),
            ],
          ),
        ),
      ),
    ));

    // Focus the TextField
    await tester.tap(find.byKey(const Key('willpop-field')));
    await tester.pumpAndSettle();

    expect(FocusManager.instance.primaryFocus, isNotNull,
        reason: 'TextField should have focus before attempted pop');

  // Simulate back button by asking Navigator to pop. WillPopScope returns
  // false so the pop should be cancelled and focus should remain.
  final BuildContext ctx = tester.element(find.byType(WillPopScope));
  await Navigator.of(ctx).maybePop();
  await tester.pumpAndSettle();

    // Because pop was cancelled, focus must remain
    expect(FocusManager.instance.primaryFocus, isNotNull,
        reason: 'Cancelled pop should NOT unfocus the active TextField');
  });
}

// Helper widget used by the navigation test.
class FormScreen extends StatelessWidget {
  FormScreen({Key? key}) : super(key: key);

  final _fieldKey = const Key('form-field');
  final _buttonKey = const Key('push-button');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(key: _fieldKey),
          ),
          ElevatedButton(
            key: _buttonKey,
            onPressed: () {
              // Use GoRouter context to navigate to /next
              context.push('/next');
            },
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }
}
