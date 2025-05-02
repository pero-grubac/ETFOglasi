import 'package:flutter/material.dart';

class GeneralItemTheme extends ThemeExtension<GeneralItemTheme> {
  final BoxDecoration decoration;
  final EdgeInsets padding;
  final Color splashColor;
  final TextStyle? textStyle; // Optional text style for the title

  GeneralItemTheme({
    required this.decoration,
    required this.padding,
    required this.splashColor,
    this.textStyle,
  });

  @override
  GeneralItemTheme copyWith({
    BoxDecoration? decoration,
    EdgeInsets? padding,
    Color? splashColor,
    TextStyle? textStyle,
  }) {
    return GeneralItemTheme(
      decoration: decoration ?? this.decoration,
      padding: padding ?? this.padding,
      splashColor: splashColor ?? this.splashColor,
      textStyle: textStyle ?? this.textStyle,
    );
  }

  @override
  GeneralItemTheme lerp(ThemeExtension<GeneralItemTheme>? other, double t) {
    if (other is! GeneralItemTheme) return this;
    return GeneralItemTheme(
      decoration: BoxDecoration.lerp(decoration, other.decoration, t)!,
      padding: EdgeInsets.lerp(padding, other.padding, t)!,
      splashColor: Color.lerp(splashColor, other.splashColor, t)!,
      textStyle: TextStyle.lerp(textStyle, other.textStyle, t),
    );
  }
}
