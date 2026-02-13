import 'package:educa_plus/ui/widgets/aula_date_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  testWidgets('AppBar leading remains tappable with AulaDateBadge in actions',
      (tester) async {
    var backTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => backTapped = true,
            ),
            title: const Text('Title'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: AulaDateBadge(date: DateTime(2026, 1, 24)),
              ),
            ],
          ),
          body: const SizedBox.expand(),
        ),
      ),
    );

    // Tap the leading/back button and ensure it receives the event.
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pump();
    expect(backTapped, isTrue);
  });

  testWidgets(
      'AulaDateBadge does not cause AppBar overflow at large text scale',
      (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {},
              ),
              title: const Text('Title'),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: AulaDateBadge(date: DateTime(2026, 1, 24)),
                ),
              ],
            ),
            body: const SizedBox.expand(),
          ),
        ),
      ),
    );

    // Let any layout-related errors surface.
    await tester.pump();

    final ex = tester.takeException();
    expect(ex, isNull,
        reason:
            'Expected no layout exception (e.g. overflow) when text is large');
  });

  testWidgets('Weekday respects device locale (pt, en, es)', (tester) async {
    await initializeDateFormatting();

    Future<void> pumpWithLocale(Locale locale) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: locale,
          supportedLocales: const [
            Locale('pt', 'BR'),
            Locale('en'),
            Locale('es'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            appBar: AppBar(
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: AulaDateBadge(date: DateTime(2026, 1, 22)),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
    }

    // 2026-01-22 is a Thursday.
    await pumpWithLocale(const Locale('pt', 'BR'));
    expect(find.textContaining('Quinta', findRichText: true), findsOneWidget);

    await pumpWithLocale(const Locale('en'));
    expect(find.textContaining('Thursday', findRichText: true), findsOneWidget);

    await pumpWithLocale(const Locale('es'));
    // Some platforms capitalize, others don't; we capitalize in the widget.
    expect(find.textContaining('Jueves', findRichText: true), findsOneWidget);
  });
}
