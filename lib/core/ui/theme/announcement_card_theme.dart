import 'package:flutter/material.dart';

class AnnouncementCardTheme extends ThemeExtension<AnnouncementCardTheme> {
  final BoxDecoration decoration;
  final EdgeInsets padding;
  final Color splashColor;
  final Color foregroundColor; // Color for text and icons inside the card
  final TextStyle? textStyle; // Optional text style for the title

  AnnouncementCardTheme({
    required this.decoration,
    required this.padding,
    required this.splashColor,
    required this.foregroundColor,
    this.textStyle,
  });

  @override
  AnnouncementCardTheme copyWith({
    BoxDecoration? decoration,
    EdgeInsets? padding,
    Color? splashColor,
    Color? foregroundColor,
    TextStyle? textStyle,
  }) {
    return AnnouncementCardTheme(
      decoration: decoration ?? this.decoration,
      padding: padding ?? this.padding,
      splashColor: splashColor ?? this.splashColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      textStyle: textStyle ?? this.textStyle,
    );
  }

  @override
  AnnouncementCardTheme lerp(
    ThemeExtension<AnnouncementCardTheme>? other,
    double t,
  ) {
    if (other is! AnnouncementCardTheme) return this;
    return AnnouncementCardTheme(
      decoration: BoxDecoration.lerp(decoration, other.decoration, t)!,
      padding: EdgeInsets.lerp(padding, other.padding, t)!,
      splashColor: Color.lerp(splashColor, other.splashColor, t)!,
      foregroundColor: Color.lerp(foregroundColor, other.foregroundColor, t)!,
      textStyle: TextStyle.lerp(textStyle, other.textStyle, t),
    );
  }
}
