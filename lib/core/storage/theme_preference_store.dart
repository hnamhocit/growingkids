import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemePreferenceStore {
  static const _themeModeKey = 'theme_mode_preference';

  final SharedPreferences _sharedPreferences;

  const ThemePreferenceStore(this._sharedPreferences);

  ThemeMode loadThemeMode() {
    final savedValue = _sharedPreferences.getString(_themeModeKey);
    return switch (savedValue) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> saveThemeMode(ThemeMode mode) {
    return _sharedPreferences.setString(_themeModeKey, switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    });
  }
}
