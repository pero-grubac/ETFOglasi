import 'package:flutter/material.dart';

class AnnouncementCardTheme extends ThemeExtension<AnnouncementCardTheme> {
  final BoxDecoration decoration;
  final EdgeInsets padding;
  final Color splashColor;
  final TextStyle? textStyle; // Optional text style for the title

  AnnouncementCardTheme({
    required this.decoration,
    required this.padding,
    required this.splashColor,
    this.textStyle,
  });

  @override
  AnnouncementCardTheme copyWith({
    BoxDecoration? decoration,
    EdgeInsets? padding,
    Color? splashColor,
    TextStyle? textStyle,
  }) {
    return AnnouncementCardTheme(
      decoration: decoration ?? this.decoration,
      padding: padding ?? this.padding,
      splashColor: splashColor ?? this.splashColor,
      textStyle: textStyle ?? this.textStyle,
    );
  }

  @override
  AnnouncementCardTheme lerp(
      ThemeExtension<AnnouncementCardTheme>? other, double t) {
    if (other is! AnnouncementCardTheme) return this;
    return AnnouncementCardTheme(
      decoration: BoxDecoration.lerp(decoration, other.decoration, t)!,
      padding: EdgeInsets.lerp(padding, other.padding, t)!,
      splashColor: Color.lerp(splashColor, other.splashColor, t)!,
      textStyle: TextStyle.lerp(textStyle, other.textStyle, t),
    );
  }
}
