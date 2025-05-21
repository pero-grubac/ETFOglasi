import 'package:etf_oglasi/core/ui/theme/theme.dart';
import 'package:flutter/material.dart';

const primaryColor = Color(0xFF1976D2);
const secondaryColor = Color(0xFF00ACC1);
const errorColor = Color(0xFFD32F2F);

var kColorScheme = const ColorScheme(
  primary: primaryColor,
  primaryContainer: Color(0xFFBBDEFB),
  secondary: secondaryColor,
  secondaryContainer: Color(0xFFB2EBF2),
  surface: Color(0xFFFAFAFA),
  error: errorColor,
  onPrimary: Colors.white,
  onSecondary: Colors.black,
  onSurface: Color(0xFF202124),
  onError: Colors.white,
  brightness: Brightness.light,
);

const darkPrimaryColor = Color(0xFF1976D2);
const darkSecondaryColor = Color(0xFF4DB6AC);
const darkErrorColor = Color(0xFFEF5350);

var kDarkColorScheme = const ColorScheme(
  primary: darkPrimaryColor,
  primaryContainer: Color(0xFF42A5F7),
  secondary: darkSecondaryColor,
  secondaryContainer: Color(0xFF00695C),
  surface: Color(0xFF1E1E1E),
  error: darkErrorColor,
  onPrimary: Colors.black,
  onSecondary: Colors.black,
  onSurface: Colors.white,
  onError: Colors.black,
  brightness: Brightness.dark,
);

var lightTheme = AppTheme(kColorScheme).getThemeData();

var darkTheme = AppTheme(kDarkColorScheme).getThemeData();
