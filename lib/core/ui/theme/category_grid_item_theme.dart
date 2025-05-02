import 'package:flutter/material.dart';

class CategoryGridItemTheme extends ThemeExtension<CategoryGridItemTheme> {
  final BoxDecoration decoration;
  final EdgeInsets padding;
  final Color splashColor;
  final TextStyle? textStyle; // Optional text style for the title

  CategoryGridItemTheme({
    required this.decoration,
    required this.padding,
    required this.splashColor,
    this.textStyle,
  });

  @override
  CategoryGridItemTheme copyWith({
    BoxDecoration? decoration,
    EdgeInsets? padding,
    Color? splashColor,
    TextStyle? textStyle,
  }) {
    return CategoryGridItemTheme(
      decoration: decoration ?? this.decoration,
      padding: padding ?? this.padding,
      splashColor: splashColor ?? this.splashColor,
      textStyle: textStyle ?? this.textStyle,
    );
  }

  @override
  CategoryGridItemTheme lerp(
      ThemeExtension<CategoryGridItemTheme>? other, double t) {
    if (other is! CategoryGridItemTheme) return this;
    return CategoryGridItemTheme(
      decoration: BoxDecoration.lerp(decoration, other.decoration, t)!,
      padding: EdgeInsets.lerp(padding, other.padding, t)!,
      splashColor: Color.lerp(splashColor, other.splashColor, t)!,
      textStyle: TextStyle.lerp(textStyle, other.textStyle, t),
    );
  }
}
