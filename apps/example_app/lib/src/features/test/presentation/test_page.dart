import 'package:design_system_app/design_system_app.dart';
import 'package:flutter/material.dart';

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Example App")),
      body: Center(
        child: ButtonExample(
          onPressed: () {
            debugPrint("Tapped it.");
          },
          text: "Tap it",
        ),
      ),
    );
  }
}
