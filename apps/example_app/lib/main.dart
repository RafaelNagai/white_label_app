import 'package:design_system_app/design_system_app.dart';
import 'package:example_app/src/core/config/app_config.dart';
import 'package:example_app/src/core/handlers/json_handler.dart';
import 'package:example_app/src/features/test/presentation/test_page.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final flavorJson = await JsonHandler.readJson('config/config_app.json');
  runApp(
    AppConfigScope(
      config: AppConfig.fromJson(flavorJson),
      child: MaterialApp(
        initialRoute: '/',
        routes: {'/': (context) => TestPage()},
        theme: ThemeExample.buildTheme(
          config: ThemeExampleConfig.json(Brightness.light, flavorJson),
        ),
        darkTheme: ThemeExample.buildTheme(
          config: ThemeExampleConfig.json(Brightness.dark, flavorJson),
        ),
      ),
    ),
  );
}
