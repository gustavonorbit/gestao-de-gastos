import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Enums
enum FontScale { normal, medium, large }

enum AppThemeColor { appDefault, lilac, navy, pink, green }

class AccessibilitySettings {
  final FontScale fontScale;
  final AppThemeColor appColor;
  final bool highContrast;

  const AccessibilitySettings({
    this.fontScale = FontScale.normal,
  this.appColor = AppThemeColor.appDefault,
    this.highContrast = false,
  });

  AccessibilitySettings copyWith({
    FontScale? fontScale,
  AppThemeColor? appColor,
    bool? highContrast,
  }) {
    return AccessibilitySettings(
      fontScale: fontScale ?? this.fontScale,
      appColor: appColor ?? this.appColor,
      highContrast: highContrast ?? this.highContrast,
    );
  }

  Map<String, Object> toMap() => {
        'fontScale': fontScale.name,
        'appColor': appColor.name,
        'highContrast': highContrast,
      };

  static AccessibilitySettings fromMap(Map<String, Object?> map) {
    final fs = map['fontScale'] as String?;
  final tm = map['appColor'] as String?;
    final hc = map['highContrast'] as bool?;

    return AccessibilitySettings(
      fontScale: FontScale.values.firstWhere(
          (e) => e.name == fs,
          orElse: () => FontScale.normal),
      appColor: AppThemeColor.values.firstWhere((e) => e.name == tm,
          orElse: () => AppThemeColor.appDefault),
      highContrast: hc ?? false,
    );
  }
}

const _kFontKey = 'access_font_scale';
const _kAppColorKey = 'access_app_color';
const _kContrastKey = 'access_high_contrast';

class AccessibilityNotifier extends Notifier<AccessibilitySettings> {
  @override
  AccessibilitySettings build() {
    // start with defaults
    // schedule async load from prefs
    Future.microtask(() async => await _loadFromPrefs());
    return const AccessibilitySettings();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final fs = prefs.getString(_kFontKey);
  final tm = prefs.getString(_kAppColorKey);
    final hc = prefs.getBool(_kContrastKey);
    final loaded = AccessibilitySettings(
      fontScale: FontScale.values.firstWhere((e) => e.name == fs,
          orElse: () => FontScale.normal),
    appColor: AppThemeColor.values.firstWhere((e) => e.name == tm,
      orElse: () => AppThemeColor.appDefault),
      highContrast: hc ?? false,
    );

    // If the notifier was disposed while we awaited, bail out.
  if (!ref.mounted) return;

    // Only set the loaded prefs if the current state is still the default
    // (prevents the async load from overwriting user changes that happened
    // immediately after provider construction).
    if (state == const AccessibilitySettings()) {
      state = loaded;
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kFontKey, state.fontScale.name);
    await prefs.setString(_kAppColorKey, state.appColor.name);
    await prefs.setBool(_kContrastKey, state.highContrast);
  }

  Future<void> setFontScale(FontScale fs) async {
  if (!ref.mounted) return;
    state = state.copyWith(fontScale: fs);
    await _save();
  }

  Future<void> setAppColor(AppThemeColor color) async {
    if (!ref.mounted) return;
    state = state.copyWith(appColor: color);
    await _save();
  }

  Future<void> setHighContrast(bool high) async {
  if (!ref.mounted) return;
    state = state.copyWith(highContrast: high);
    await _save();
  }
}

final accessibilityProvider = NotifierProvider<AccessibilityNotifier, AccessibilitySettings>(AccessibilityNotifier.new);
