import 'dart:io';
import 'package:yaml/yaml.dart';
import 'package:args/args.dart';

/// Helper function to replace placeholders in _app_config.dart
void updateConfigFile(String filePath, Map<String, String> replacements) {
  final configFile = File(filePath);
  if (!configFile.existsSync()) {
    print('Error: $filePath not found!');
    return;
  }

  var configContent = configFile.readAsStringSync();
  replacements.forEach((key, value) {
    configContent = configContent.replaceAll(
      RegExp("$key\\s*=\\s*'[^']*'"),
      "$key = '$value'",
    );
  });
  configFile.writeAsStringSync(configContent);
  print('_app_config.dart updated successfully!');
}

/// Helper function to run external commands
Future<void> runExternalCommand(List<String> command) async {
  try {
    final result = await Process.run(command[0], command.sublist(1));
    if (result.exitCode != 0) {
      print('Error running command: ${command.join(' ')}');
      print('stdout: ${result.stdout}');
      print('stderr: ${result.stderr}');
    } else {
      print('Command executed successfully: ${command.join(' ')}');
    }
  } catch (e) {
    print('Something went wrong running command: ${command.join(' ')}: $e');
  }
}

Future<void> main(List<String> arguments) async {
  // Define command-line arguments using ArgParser <button class="citation-flag" data-index="7">
  final parser = ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      help: 'Show this help message.',
      negatable: false,
    )
    ..addFlag('icon-only', help: 'Only update the app icon.')
    ..addFlag('appName-only', help: 'Only update the app name.')
    ..addFlag('packageName-only', help: 'Only update the package name.')
    ..addFlag('orgDomain-only', help: 'Only update the organization domain.')
    ..addFlag('baseUrl-only', help: 'Only update the base URL.');

  // Parse the arguments
  final results = parser.parse(arguments);

  // Handle --help flag
  if (results['help']) {
    print('Usage: dart lib/dev_tool/.customize.dart [options]\n');
    print('Options:');
    // Print the help message <button class="citation-flag" data-index="8">
    print(parser.usage);
    return;
  }

  // Path to the customization.yaml file
  final yamlFile = File('customization.yaml');
  if (!yamlFile.existsSync()) {
    print('Error: customization.yaml not found!');
    return;
  }

  try {
    // Parse the YAML file
    final yamlContent = yamlFile.readAsStringSync();
    final yamlMap = loadYaml(yamlContent);

    // Extract variables
    final appName = yamlMap['app_name'] ?? '{{app_name}}';
    final packageName = yamlMap['package_name'] ?? '{{package_name}}';
    final orgDomain = yamlMap['org_domain'] ?? '{{org_domain}}';
    final baseUrl = yamlMap['base_url'] ?? "{{base_url}}";

    // Path to the _app_config.dart file
    const configFilePath = 'lib/app/core/static/app_config/_app_config.dart';

    // Handle --baseUrl-only flag
    if (results['baseUrl-only']) {
      print("Updating Base URL...");
      updateConfigFile(configFilePath, {'baseUrl': baseUrl});
      return;
    }

    // Handle --orgDomain-only flag
    if (results['orgDomain-only']) {
      print("Changing Organization Domain...");
      updateConfigFile(configFilePath, {'orgDomain': orgDomain});
      return;
    }

    // Handle --packageName-only flag
    if (results['packageName-only']) {
      print("Changing Package Name...");
      await runExternalCommand([
        "dart",
        "run",
        "change_app_package_name:main",
        packageName,
      ]);
      return;
    }

    // Handle --appName-only flag
    if (results['appName-only']) {
      print("Changing App Name...");
      updateConfigFile(configFilePath, {'appName': appName});
      await runExternalCommand([
        "dart",
        "run",
        "rename_app:main",
        "all=$appName",
      ]);
      return;
    }

    // Handle --icon-only flag
    if (results['icon-only']) {
      print("Changing App Icon...");
      await runExternalCommand([
        "dart",
        "run",
        "icons_launcher:create",
        "--path",
        "icons_launcher.yaml",
      ]);
      return;
    }

    // Default behavior: Perform all customizations
    if (!results['icon-only'] &&
        !results['appName-only'] &&
        !results['packageName-only'] &&
        !results['baseUrl-only'] &&
        !results['orgDomain-only']) {
      print("Performing full customization...");

      // Update _app_config.dart
      updateConfigFile(configFilePath, {
        'appName': appName,
        'orgDomain': orgDomain,
        'baseUrl': baseUrl,
      });

      // Change App Package Name
      if (packageName.isNotEmpty) {
        await runExternalCommand([
          "dart",
          "run",
          "change_app_package_name:main",
          packageName,
        ]);
      }

      // Change App Name
      if (appName.isNotEmpty) {
        await runExternalCommand([
          "dart",
          "run",
          "rename_app:main",
          "all=$appName",
        ]);
      }

      // Change App Icon
      await runExternalCommand([
        "dart",
        "run",
        "icons_launcher:create",
        "--path",
        "icons_launcher.yaml",
      ]);

      print('Customization process completed!');
    }
  } catch (e) {
    print('Something went wrong during customization: $e');
  }
}
