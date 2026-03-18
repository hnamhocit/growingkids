import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:growingkids/core/storage/theme_preference_store.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final ThemePreferenceStore _themePreferenceStore;

  ThemeCubit({required ThemePreferenceStore themePreferenceStore})
    : _themePreferenceStore = themePreferenceStore,
      super(themePreferenceStore.loadThemeMode());

  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (state == themeMode) {
      return;
    }

    emit(themeMode);
    await _themePreferenceStore.saveThemeMode(themeMode);
  }

  Future<void> setDarkMode(bool isDarkMode) {
    return setThemeMode(isDarkMode ? ThemeMode.dark : ThemeMode.light);
  }
}
