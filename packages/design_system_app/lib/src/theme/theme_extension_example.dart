import 'package:flutter/material.dart';

class ThemeExtensionExample extends ThemeExtension<ThemeExtensionExample> {
  final Color primary;
  final double spacing;

  ThemeExtensionExample({required this.primary, required this.spacing});

  @override
  ThemeExtensionExample copyWith({Color? primary, double? spacing}) {
    return ThemeExtensionExample(
      primary: primary ?? this.primary,
      spacing: spacing ?? this.spacing,
    );
  }

  @override
  ThemeExtensionExample lerp(covariant ThemeExtensionExample? other, double t) {
    if (other == null) {
      return this;
    }

    return ThemeExtensionExample(
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      spacing: spacing + (other.spacing - spacing) * t,
    );
  }
}
