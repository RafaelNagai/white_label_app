import 'package:flutter/material.dart';

class ButtonExample extends StatelessWidget {
  final Function()? onPressed;
  final String text;
  const ButtonExample({super.key, required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onPressed, child: Text(text));
  }
}
