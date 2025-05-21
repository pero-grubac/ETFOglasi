import 'dart:convert';

class LocalSettings {
  static const darkMode = 'dark';
  static const lightMode = 'light';
  static const srLatLang = 'sr-lat';
  static const srLatName = 'Srpski latinica';
  static const srCyrLang = 'sr-cyr';
  static const srCyrName = 'Srpski ćirilica';
  final String language;
  final String themeMode;

  LocalSettings({required this.language, required this.themeMode});

  Map<String, dynamic> toMap() {
    return {
      'language': language,
      'themeMode': themeMode,
    };
  }

  factory LocalSettings.fromMap(Map<String, dynamic> map) {
    final themeMode = map['themeMode'] as String? ?? lightMode;
    final language = map['language'] as String? ?? srLatLang;
    return LocalSettings(
      themeMode: themeMode == darkMode ? darkMode : lightMode,
      language: language == srCyrLang ? srCyrLang : srLatLang,
    );
  }
  String toJson() => json.encode(toMap());
  factory LocalSettings.fromJson(String source) =>
      LocalSettings.fromMap(json.decode(source));
}
