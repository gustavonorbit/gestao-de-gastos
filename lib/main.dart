import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:educa_plus/app/router.dart';
import 'package:educa_plus/app/providers.dart' show appTextScaleProvider;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  runApp(const ProviderScope(child: EducaApp()));
}

class EducaApp extends ConsumerWidget {
  const EducaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
  // Global text scale (1.0, 1.1, 1.2)
  final double scale = ref.watch(appTextScaleProvider);

  // App uses only a light theme; primary color is provided by accessibility provider.

    return Builder(builder: (ctx) {
      return MaterialApp.router(
        title: 'Educa+',
  theme: buildTheme(),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('pt', 'BR'),
          Locale('en'),
        ],
        routerConfig: buildRouter(),
        builder: (context, child) {
          // Wrap with MediaQuery to apply global textScaleFactor
          final data = MediaQuery.of(context).copyWith(textScaleFactor: scale);
          return MediaQuery(data: data, child: child ?? const SizedBox.shrink());
        },
      );
    });
  }
}
