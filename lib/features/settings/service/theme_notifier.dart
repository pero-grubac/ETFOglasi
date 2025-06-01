import 'package:etf_oglasi/features/settings/model/local_settings.dart';
import 'package:etf_oglasi/features/settings/service/local_settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier(super.state);
  void setTheme(ThemeMode themeMode) {
    state = themeMode;
  }
}

final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>(
  (ref) {
    final localSettings = ref.watch(localSettingsProvider);
    final initialThemeMode = localSettings.themeMode == LocalSettings.darkMode
        ? ThemeMode.dark
        : ThemeMode.light;
    return ThemeNotifier(initialThemeMode);
  },
);
