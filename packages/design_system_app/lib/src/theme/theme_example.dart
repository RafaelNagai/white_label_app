import 'package:design_system_app/src/theme/theme_extension_example.dart';
import 'package:flutter/material.dart';

class ThemeExample {
  static ThemeData buildTheme({required ThemeExampleConfig config}) {
    return ThemeData(
      primaryColor: config.primary,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          elevation: WidgetStateProperty.all(config.spacing),
          backgroundColor: WidgetStateProperty.all(config.primary),
        ),
      ),
      appBarTheme: AppBarTheme(backgroundColor: config.primary),
      extensions: [
        ThemeExtensionExample(primary: config.primary, spacing: config.spacing),
      ],
    );
  }
}

class ThemeExampleConfig {
  final Brightness brightness;
  final Color primary;
  final double spacing;

  ThemeExampleConfig(
    this.brightness, {
    required this.primary,
    required this.spacing,
  });

  factory ThemeExampleConfig.json(
    Brightness brightness,
    Map<String, dynamic> json,
  ) {
    final themeJson = json['theme'][brightness.name];
    return ThemeExampleConfig(
      brightness,
      primary: Color(int.parse('FF${themeJson['primary']}', radix: 16)),
      spacing: (themeJson['spacing'] as num).toDouble(),
    );
  }
}
