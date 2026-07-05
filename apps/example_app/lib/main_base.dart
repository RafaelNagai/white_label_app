import 'package:example_app/src/features/test/presentation/test_page.dart';
import 'package:flutter/material.dart';

void mainBase({required ThemeData lightTheme, required ThemeData darkTheme}) {
  runApp(
    MaterialApp(
      initialRoute: '/',
      routes: {'/': (context) => TestPage()},
      theme: lightTheme,
      darkTheme: darkTheme,
    ),
  );
}
