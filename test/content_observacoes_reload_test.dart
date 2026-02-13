import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';

import 'package:educa_plus/app/providers.dart';
import 'package:educa_plus/data/database.dart';
import 'package:educa_plus/data/repositories/conteudo_repository_impl.dart';
import 'package:educa_plus/data/repositories/observacoes_repository_impl.dart';
import 'package:educa_plus/ui/screens/lessons/conteudo_screen.dart';
import 'package:educa_plus/ui/screens/lessons/observacoes_screen.dart';

// Regression: after saving, leaving the screen and reopening should always
// reflect what is persisted in the DB.
void main() {
  group('Conteúdo/Observações screens reload from DB', () {
    setUp(() {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      binding.window.physicalSizeTestValue = const Size(1200, 1600);
      binding.window.devicePixelRatioTestValue = 1.0;
    });

    tearDown(() {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      binding.window.clearPhysicalSizeTestValue();
      binding.window.clearDevicePixelRatioTestValue();
    });

    testWidgets(
        'ConteudoScreen: remove item, save, reopen does not show removed item',
        (tester) async {
      final db = AppDatabase.test(NativeDatabase.memory());
      addTearDown(db.close);

      // Seed DB with 2 items.
      final repo = ConteudoRepositoryImpl(db);
      await repo.replaceForAula(1, ['A', 'B']);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dbProvider.overrideWithValue(db),
            conteudoRepositoryProvider.overrideWithValue(repo),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ConteudoScreen(
                              aulaId: 1,
                              turmaId: 1,
                              subtitle: '1º A',
                            ),
                          ),
                        );
                      },
                      child: const Text('Open'),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Open and ensure 2 fields are shown.
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(TextField), findsNWidgets(2));

      // Simulate removal by clearing the second field.
      await tester.enterText(find.byType(TextField).at(1), '');
      await tester.pump();

      // Save and reopen.
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // After reopening, only the trimmed non-empty item survives.
      expect(find.byType(TextField), findsOneWidget);
      final tf = tester.widget<TextField>(find.byType(TextField).first);
      expect(tf.controller?.text, 'A');
    });

    testWidgets('ConteudoScreen reloads on reopen and shows saved text',
        (tester) async {
      final db = AppDatabase.test(NativeDatabase.memory());
      addTearDown(db.close);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dbProvider.overrideWithValue(db),
            conteudoRepositoryProvider.overrideWithValue(
              ConteudoRepositoryImpl(db),
            ),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ConteudoScreen(
                              aulaId: 1,
                              turmaId: 1,
                              subtitle: '1º A',
                            ),
                          ),
                        );
                      },
                      child: const Text('Open'),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Initial empty field exists.
      expect(find.byType(TextField), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'Conteúdo salvo');
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      // Reopen.
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // The TextField should be prefilled from DB via controller.
      final tf = tester.widget<TextField>(find.byType(TextField).first);
      expect(tf.controller?.text, 'Conteúdo salvo');
    });

    testWidgets('ObservacoesScreen reloads on reopen and shows saved text',
        (tester) async {
      final db = AppDatabase.test(NativeDatabase.memory());
      addTearDown(db.close);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dbProvider.overrideWithValue(db),
            observacoesRepositoryProvider.overrideWithValue(
              ObservacoesRepositoryImpl(db),
            ),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ObservacoesScreen(
                              aulaId: 1,
                              turmaId: 1,
                              subtitle: '1º A',
                            ),
                          ),
                        );
                      },
                      child: const Text('Open'),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(TextField), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'Observação salva');
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      final tf = tester.widget<TextField>(find.byType(TextField).first);
      expect(tf.controller?.text, 'Observação salva');
    });

    testWidgets(
        'ObservacoesScreen: remove item, save, reopen does not show removed item',
        (tester) async {
      final db = AppDatabase.test(NativeDatabase.memory());
      addTearDown(db.close);

      // Seed DB with 2 items.
      final repo = ObservacoesRepositoryImpl(db);
      await repo.replaceForAula(1, ['A', 'B']);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dbProvider.overrideWithValue(db),
            observacoesRepositoryProvider.overrideWithValue(repo),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ObservacoesScreen(
                              aulaId: 1,
                              turmaId: 1,
                              subtitle: '1º A',
                            ),
                          ),
                        );
                      },
                      child: const Text('Open'),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(TextField), findsNWidgets(2));

      // Simulate removal by clearing the second field.
      await tester.enterText(find.byType(TextField).at(1), '');
      await tester.pump();

      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(TextField), findsOneWidget);
      final tf = tester.widget<TextField>(find.byType(TextField).first);
      expect(tf.controller?.text, 'A');
    });
  });
}
