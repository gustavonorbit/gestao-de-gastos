import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:educa_plus/app/text_scale.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('defaults and persistence of app text scale', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final initial = container.read(appTextScaleProvider);
    expect(initial, 1.0);

    final notifier = container.read(appTextScaleProvider.notifier);
    await notifier.setScale(1.1);

    final after = container.read(appTextScaleProvider);
    expect(after, 1.1);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getDouble('app_text_scale'), 1.1);
  });

  test('loads text scale from prefs on startup', () async {
    SharedPreferences.setMockInitialValues({
      'app_text_scale': 1.2,
    });

    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Trigger provider creation and allow async load
    container.read(appTextScaleProvider);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final value = container.read(appTextScaleProvider);
    expect(value, 1.2);
  });
}
