// Applies a client's config from configs/<client_id>/ onto apps/example_app
// so a subsequent `flutter build` produces that client's app.
//
// Usage: dart tool/apply_client.dart <client_id>
import 'dart:convert';
import 'dart:io';

final _packageNameRegex = RegExp(
  r'^[a-zA-Z][a-zA-Z0-9_]*(\.[a-zA-Z][a-zA-Z0-9_]*)+$',
);
final _hexColorRegex = RegExp(r'^[0-9a-fA-F]{6}$');
final _urlRegex = RegExp(r'^https?://');

const _appDir = 'apps/example_app';

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln('Usage: dart tool/apply_client.dart <client_id>');
    stderr.writeln('Available clients: ${_listClientIds().join(', ')}');
    exit(1);
  }

  final clientId = args[0];
  final configDir = 'configs/$clientId';
  final configFile = File('$configDir/config.json');

  if (!configFile.existsSync()) {
    stderr.writeln("Unknown client_id '$clientId'.");
    stderr.writeln('Available clients: ${_listClientIds().join(', ')}');
    exit(1);
  }

  final json =
      jsonDecode(configFile.readAsStringSync()) as Map<String, dynamic>;
  _validate(clientId, json);

  // 1. Runtime config asset (theme + backend/feature flags read at startup).
  configFile.copySync('$_appDir/config/config_app.json');

  // 2. Icon + flutter_launcher_icons config.
  final iconFile = File('$configDir/icon.png');
  if (iconFile.existsSync()) {
    Directory('$_appDir/assets/icon').createSync(recursive: true);
    iconFile.copySync('$_appDir/assets/icon/icon.png');
  }
  File('$_appDir/flutter_launcher_icons.yaml').writeAsStringSync('''
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/icon.png"
  remove_alpha_ios: true
  min_sdk_android: 21
''');

  final identity = json['identity'] as Map<String, dynamic>;
  final appName = identity['appName'] as String;
  final applicationId =
      (identity['android'] as Map<String, dynamic>)['applicationId']
          as String;
  final bundleId =
      (identity['ios'] as Map<String, dynamic>)['bundleId'] as String;

  // 3. Android identity, read by android/app/build.gradle.kts. Must live in
  // android/app/ — Gradle's file(...) resolves relative to the :app module.
  File('$_appDir/android/app/client.properties').writeAsStringSync(
    _propertiesFile({
      'clientApplicationId': applicationId,
      'clientAppName': appName,
    }),
  );

  // 4. iOS identity, included by Debug.xcconfig/Release.xcconfig.
  File('$_appDir/ios/Flutter/Client.xcconfig').writeAsStringSync(
    _xcconfigFile({'CLIENT_BUNDLE_ID': bundleId, 'CLIENT_APP_NAME': appName}),
  );

  // 5. iOS export options (bundle id must be a literal key even under a
  // wildcard provisioning profile).
  final profileName = Platform.environment['IOS_PROFILE_NAME'] ?? '';
  final teamId = Platform.environment['IOS_TEAM_ID'] ?? '';
  File('$_appDir/ios/ExportOptions.plist').writeAsStringSync(
    _exportOptionsPlist(
      bundleId: bundleId,
      profileName: profileName,
      teamId: teamId,
    ),
  );

  print(
    'Applied client=$clientId applicationId=$applicationId '
    'bundleId=$bundleId appName=$appName',
  );
}

List<String> _listClientIds() {
  final dir = Directory('configs');
  if (!dir.existsSync()) return [];
  return dir.listSync().whereType<Directory>()
      .where((d) => File('${d.path}/config.json').existsSync())
      .map((d) => d.path.split(Platform.pathSeparator).last)
      .toList()
    ..sort();
}

void _validate(String clientId, Map<String, dynamic> json) {
  final errors = <String>[];

  if (json['clientId'] != clientId) {
    errors.add(
      "clientId '${json['clientId']}' does not match directory name "
      "'$clientId'",
    );
  }

  final identity = json['identity'] as Map<String, dynamic>?;
  if (identity == null) {
    errors.add('missing "identity" block');
  } else {
    final appName = identity['appName'];
    if (appName is! String || appName.trim().isEmpty) {
      errors.add('identity.appName must be a non-empty string');
    }
    final android = identity['android'] as Map<String, dynamic>?;
    final applicationId = android?['applicationId'];
    if (applicationId is! String ||
        !_packageNameRegex.hasMatch(applicationId)) {
      errors.add(
        'identity.android.applicationId must be a valid package name '
        '(e.g. com.company.app)',
      );
    }
    final ios = identity['ios'] as Map<String, dynamic>?;
    final bundleId = ios?['bundleId'];
    if (bundleId is! String || !_packageNameRegex.hasMatch(bundleId)) {
      errors.add(
        'identity.ios.bundleId must be a valid bundle id '
        '(e.g. com.company.app)',
      );
    }
  }

  final theme = json['theme'] as Map<String, dynamic>?;
  if (theme == null) {
    errors.add('missing "theme" block');
  } else {
    for (final brightness in ['light', 'dark']) {
      final brightnessJson = theme[brightness] as Map<String, dynamic>?;
      if (brightnessJson == null) {
        errors.add('missing theme.$brightness');
        continue;
      }
      final primary = brightnessJson['primary'];
      if (primary is! String || !_hexColorRegex.hasMatch(primary)) {
        errors.add(
          'theme.$brightness.primary must be a 6-digit hex color '
          '(e.g. "00AA00")',
        );
      }
      final spacing = brightnessJson['spacing'];
      if (spacing is! num) {
        errors.add('theme.$brightness.spacing must be a number');
      }
    }
  }

  final backend = json['backend'] as Map<String, dynamic>?;
  if (backend == null) {
    errors.add('missing "backend" block');
  } else {
    final apiBaseUrl = backend['apiBaseUrl'];
    if (apiBaseUrl is! String || !_urlRegex.hasMatch(apiBaseUrl)) {
      errors.add('backend.apiBaseUrl must be an http(s) URL');
    }
    final featureFlags = backend['featureFlags'];
    if (featureFlags != null && featureFlags is! Map) {
      errors.add('backend.featureFlags must be an object of booleans');
    }
  }

  if (errors.isNotEmpty) {
    stderr.writeln("Invalid config for client '$clientId':");
    for (final e in errors) {
      stderr.writeln('  - $e');
    }
    exit(1);
  }
}

String _propertiesFile(Map<String, String> entries) {
  final buffer = StringBuffer()
    ..writeln('# Generated by tool/apply_client.dart — do not edit by hand.');
  entries.forEach((key, value) {
    buffer.writeln('$key=${_escapeProperties(value)}');
  });
  return buffer.toString();
}

String _escapeProperties(String value) {
  final buffer = StringBuffer();
  for (final rune in value.runes) {
    if (rune == 0x5C) {
      buffer.write(r'\\'); // backslash
    } else if (rune == 0x3D) {
      buffer.write(r'\='); // =
    } else if (rune == 0x3A) {
      buffer.write(r'\:'); // :
    } else if (rune == 0x23) {
      buffer.write(r'\#'); // #
    } else if (rune == 0x21) {
      buffer.write(r'\!'); // !
    } else if (rune > 0x7E) {
      buffer.write('\\u${rune.toRadixString(16).padLeft(4, '0')}');
    } else {
      buffer.writeCharCode(rune);
    }
  }
  return buffer.toString();
}

String _xcconfigFile(Map<String, String> entries) {
  final buffer = StringBuffer()
    ..writeln(
      '// Generated by tool/apply_client.dart — do not edit by hand.',
    );
  entries.forEach((key, value) {
    buffer.writeln('$key = ${_escapeXcconfig(value)}');
  });
  return buffer.toString();
}

String _escapeXcconfig(String value) {
  return value
      .replaceAll(r'\', r'\\')
      .replaceAll('"', r'\"')
      .replaceAll(r'$', r'\$')
      .replaceAll('\n', ' ');
}

String _escapeXml(String value) {
  return value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&apos;');
}

String _exportOptionsPlist({
  required String bundleId,
  required String profileName,
  required String teamId,
}) {
  return '''
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>ad-hoc</string>
    <key>teamID</key>
    <string>${_escapeXml(teamId)}</string>
    <key>signingStyle</key>
    <string>manual</string>
    <key>provisioningProfiles</key>
    <dict>
        <key>${_escapeXml(bundleId)}</key>
        <string>${_escapeXml(profileName)}</string>
    </dict>
</dict>
</plist>
''';
}
