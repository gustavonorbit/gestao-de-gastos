import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:educa_plus/core/navigation/unfocus_on_route_change_observer.dart';

import 'package:educa_plus/ui/screens/classes/list_classes_screen.dart';
import 'package:educa_plus/ui/screens/classes/turma_form_screen.dart';
import 'package:educa_plus/ui/widgets/tap_to_unfocus.dart';
import 'package:educa_plus/ui/screens/lessons/list_lessons_screen.dart';
import 'package:educa_plus/ui/screens/lessons/aula_hub_screen.dart';
import 'package:educa_plus/ui/screens/lessons/presenca_screen.dart';
import 'package:educa_plus/ui/screens/students/students_screen.dart';
import 'package:educa_plus/ui/screens/config/config_screen.dart';
import 'package:educa_plus/ui/screens/config/acessibilidade_screen.dart';
import 'package:educa_plus/ui/screens/config/lixeira_screen.dart';
import 'package:educa_plus/ui/screens/config/backup_screen.dart';
import 'package:educa_plus/app/feature_flags.dart';
import 'package:educa_plus/ui/screens/lessons/fechamento_screen.dart';

/// Paleta azul-petróleo mais leve (confortável e com bom contraste).
///
/// Se quiser ajustar mais quente/frio, altere apenas aqui.
const _petrol = Color(0xFF1E6F7A);
const _petrolDark = Color(0xFF15535B);

ThemeData buildTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: _petrol,
    brightness: Brightness.light,
  ).copyWith(
    primary: _petrol,
    onPrimary: Colors.white,
    secondary: _petrolDark,
    onSecondary: Colors.white,
    surface: const Color(0xFFF7FAFB),
    onSurface: const Color(0xFF0D1B1E),
    error: const Color(0xFFB3261E),
    onError: Colors.white,
  );

  final effectiveColorScheme = colorScheme;

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: effectiveColorScheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: effectiveColorScheme.primary,
      foregroundColor: effectiveColorScheme.onPrimary,
      elevation: 1,
      surfaceTintColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: effectiveColorScheme.primary,
        foregroundColor: effectiveColorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: effectiveColorScheme.primary,
      foregroundColor: effectiveColorScheme.onPrimary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: effectiveColorScheme.primary.withOpacity(0.35)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: effectiveColorScheme.primary.withOpacity(0.25)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: effectiveColorScheme.primary.withOpacity(0.80), width: 2),
      ),
    ),
  );
}

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/turmas',
    routes: [
      GoRoute(
        path: '/',
        redirect: (_, __) => '/turmas',
      ),
      GoRoute(
        path: '/turmas',
        builder: (context, state) => const ListClassesScreen(),
        routes: [
          GoRoute(
            path: 'nova',
            builder: (context, state) => const TapToUnfocus(child: TurmaFormScreen()),
          ),
          GoRoute(
            path: ':id/editar',
            builder: (context, state) {
              final turmaId = int.tryParse(state.pathParameters['id'] ?? '');
              final prompt = state.uri.queryParameters['promptImport'] == '1';
              return TurmaFormScreen(
                  turmaId: turmaId, autoPromptImportStudents: prompt);
            },
          ),
          GoRoute(
            path: ':id/alunos',
            builder: (context, state) {
              final turmaId = int.tryParse(state.pathParameters['id'] ?? '');
              final turmaNome = state.uri.queryParameters['nome'];
              return StudentsScreen(
                  turmaId: turmaId ?? 0, turmaNome: turmaNome);
            },
          ),
          GoRoute(
            path: ':id/aulas',
            builder: (context, state) {
              final turmaId = int.tryParse(state.pathParameters['id'] ?? '');
              final turmaNome = state.uri.queryParameters['nome'] ?? '';
              return ListLessonsScreen(
                  turmaId: turmaId ?? 0, turmaName: turmaNome);
            },
            routes: [
              GoRoute(
                path: ':aulaId',
                builder: (context, state) {
                  final turmaId =
                      int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                  final aulaId =
                      int.tryParse(state.pathParameters['aulaId'] ?? '') ?? 0;
                  final title = state.uri.queryParameters['titulo'] ?? 'Aula';
                  final turmaNome = state.uri.queryParameters['turmaNome'] ?? '';
                  return AulaHubScreen(
                    turmaId: turmaId,
                    aulaId: aulaId,
                    aulaTitle: title,
                    turmaName: turmaNome,
                  );
                },
                routes: [
                  GoRoute(
                    path: 'presenca',
                    builder: (context, state) {
                      final turmaId =
                          int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                      final aulaId =
                          int.tryParse(state.pathParameters['aulaId'] ?? '') ?? 0;
                      final turmaNome = state.uri.queryParameters['turmaNome'] ?? '';
                      return PresencaScreen(
                        turmaId: turmaId,
                        aulaId: aulaId,
                        turmaName: turmaNome,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/configuracoes',
        builder: (context, state) => const ConfigScreen(),
        routes: () {
          // Build sub-routes for the configuration area. The backup route is
          // intentionally gated behind a feature flag so the code remains in
          // place but the UI is hidden for the MVP.
          final configRoutes = <GoRoute>[
            GoRoute(
              path: 'acessibilidade',
              builder: (context, state) => const AcessibilidadeScreen(),
            ),
            GoRoute(
              path: 'lixeira',
              builder: (context, state) => const LixeiraScreen(),
            ),
          ];

          if (isBackupEnabled) {
            configRoutes.add(
              GoRoute(
                path: 'backup',
                builder: (context, state) => const BackupScreen(),
              ),
            );
          }

          return configRoutes;
        }(),
      ),
      GoRoute(
        path: '/fechamento',
        name: 'fechamento',
        builder: (context, state) => const FechamentoScreen(),
      ),
    ],
    observers: [
      UnfocusOnRouteChangeObserver(),
    ],
  );
}
