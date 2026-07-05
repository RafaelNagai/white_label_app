import 'package:flutter/widgets.dart';

class AppConfig {
  final String apiBaseUrl;
  final Map<String, bool> featureFlags;

  AppConfig({required this.apiBaseUrl, required this.featureFlags});

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    final backendJson = json['backend'] as Map<String, dynamic>;
    final featureFlagsJson =
        backendJson['featureFlags'] as Map<String, dynamic>? ?? {};
    return AppConfig(
      apiBaseUrl: backendJson['apiBaseUrl'] as String,
      featureFlags: featureFlagsJson.map(
        (key, value) => MapEntry(key, value as bool),
      ),
    );
  }
}

class AppConfigScope extends InheritedWidget {
  final AppConfig config;

  const AppConfigScope({super.key, required this.config, required super.child});

  static AppConfig of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppConfigScope>()!.config;
  }

  @override
  bool updateShouldNotify(AppConfigScope oldWidget) => config != oldWidget.config;
}
