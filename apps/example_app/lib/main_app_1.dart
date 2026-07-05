import 'package:design_system_app/design_system_app.dart';
import 'package:example_app/main_base.dart';
import 'package:example_app/src/core/handlers/json_handler.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final flavorJson = await JsonHandler.readJson('config/config_app.json');
  mainBase(
    lightTheme: ThemeExample.buildTheme(
      config: ThemeExampleConfig.json(Brightness.light, flavorJson),
    ),
    darkTheme: ThemeExample.buildTheme(
      config: ThemeExampleConfig.json(Brightness.dark, flavorJson),
    ),
  );
}
