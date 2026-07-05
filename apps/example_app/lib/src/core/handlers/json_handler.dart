import 'dart:convert';

import 'package:flutter/services.dart';

class JsonHandler {
  static Future<Map<String, dynamic>> readJson(String path) async {
    final text = await rootBundle.loadString(path);
    return jsonDecode(text);
  }
}
