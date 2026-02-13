import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kAppTextScaleKey = 'app_text_scale';

/// Notifier that stores a global text scale factor for the app.
/// Allowed values: 1.0, 1.1, 1.2
class AppTextScaleNotifier extends Notifier<double> {
  @override
  double build() {
    // schedule async load
    Future.microtask(() async => await _load());
    return 1.0;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
  final v = prefs.getDouble(_kAppTextScaleKey);
  final loaded = (v != null && (v == 1.1 || v == 1.2)) ? v : 1.0;
    if (!ref.mounted) return;
    if (state == 1.0) state = loaded;
  }

  Future<void> setScale(double value) async {
    if (!(value == 1.0 || value == 1.1 || value == 1.2)) return;
    if (!ref.mounted) return;
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kAppTextScaleKey, value);
  }
}

final appTextScaleProvider = NotifierProvider<AppTextScaleNotifier, double>(AppTextScaleNotifier.new);
