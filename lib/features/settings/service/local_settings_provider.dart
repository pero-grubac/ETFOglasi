import 'package:etf_oglasi/core/service/provider/locale_notifier.dart';
import 'package:etf_oglasi/core/service/provider/theme_notifier.dart';
import 'package:etf_oglasi/features/settings/data/model/local_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalSettingsNotifier extends StateNotifier<LocalSettings> {
  final Ref ref;
  LocalSettingsNotifier(this.ref)
      : super(LocalSettings(
          language: LocalSettings.srLatLang,
          themeMode: LocalSettings.darkMode,
        )) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeMode = prefs.getString('themeMode') ?? LocalSettings.lightMode;
    final language = prefs.getString('language') ?? LocalSettings.srLatLang;

    state = LocalSettings(themeMode: themeMode, language: language);

    final themeModeEnum =
        themeMode == LocalSettings.darkMode ? ThemeMode.dark : ThemeMode.light;
    ref.read(themeNotifierProvider.notifier).setTheme(themeModeEnum);

    final locale = Locale(language);
    ref.read(localeProvider.notifier).updateLocale(locale);
  }

  void updateTheme(String themeMode) {
    state = LocalSettings(themeMode: themeMode, language: state.language);
    _saveSettings();

    final themeModeEnum =
        themeMode == LocalSettings.darkMode ? ThemeMode.dark : ThemeMode.light;
    ref.read(themeNotifierProvider.notifier).setTheme(themeModeEnum);
  }

  void updateLanguage(String language) {
    state = LocalSettings(themeMode: state.themeMode, language: language);
    _saveSettings();

    final locale = Locale(language);
    ref.read(localeProvider.notifier).updateLocale(locale);
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', state.themeMode);
    await prefs.setString('language', state.language);
  }
}

final localSettingsProvider =
    StateNotifierProvider<LocalSettingsNotifier, LocalSettings>((ref) {
  return LocalSettingsNotifier(ref);
});
