import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;
import 'package:spider/src/constants.dart';
import 'package:spider/src/spider_config.dart';
import 'package:spider/src/utils.dart';
import 'package:yaml/yaml.dart';

/// Retrieves configuration either
///
/// 1. From path provided in the command line.
/// 2. From pubspec.yaml file.
/// 3. From the config file in the current directory.
///
/// Above order of precedence is followed.
SpiderConfiguration? retrieveConfigs([ArgResults? command]) {
  final configJson = readConfigFileFromPath(command) ??
      readConfigsFromPubspec() ??
      readConfigFileFromRoot();
  if (configJson == null) {
    exitWith(ConsoleMessages.configNotFoundDetailed);

    return null;
  }
  try {
    verbose('Validating configs');
    validateConfigs(configJson);
    final pubspec = retrievePubspecData()!;
    configJson['project_name'] = pubspec['name'];
    configJson['flutter_project'] = pubspec['dependencies']?['flutter'] != null;
    final config = SpiderConfiguration.fromJson(configJson);

    return config;
  } catch (error, stacktrace) {
    verbose(error.toString());
    verbose(stacktrace.toString());
    exitWith(ConsoleMessages.parseError, stacktrace);

    return null;
  }
}

/// Reads config file from pubspec.yaml file.
Map<String, dynamic>? readConfigsFromPubspec() {
  try {
    final pubspecFile = file('pubspec.yaml') ?? file('pubspec.yml');
    if (pubspecFile == null || !pubspecFile.existsSync()) return null;
    final parsed = yamlToMap(pubspecFile.path)['spider'];
    if (parsed == null) return null;
    info('Configs found at ${pubspecFile.path}');

    return Map<String, dynamic>.from(parsed);
  } catch (error, stacktrace) {
    verbose(error.toString());
    verbose(stacktrace.toString());
    exitWith(ConsoleMessages.parseError, stacktrace);

    return null;
  }
}

/// Reads the config from the config file in the current directory.
Map<String, dynamic>? readConfigFileFromRoot() {
  try {
    final yamlFile = file(p.join(Directory.current.path, 'spider.yaml')) ??
        file(p.join(Directory.current.path, 'spider.yml'));
    final jsonFile = file(p.join(Directory.current.path, 'spider.json'));
    Map<String, dynamic> map;
    if (yamlFile != null) {
      info('Configs found at ${yamlFile.path}');
      verbose('Loading configs from ${p.basename(yamlFile.path)}');
      map = yamlToMap(yamlFile.path);
    } else if (jsonFile != null) {
      info('Configs found at ${jsonFile.path}');
      verbose('Loading configs from ${p.basename(jsonFile.path)}');
      map = json.decode(jsonFile.readAsStringSync());
    } else {
      return null;
    }
    if (map.isEmpty) {
      exitWith(ConsoleMessages.invalidConfigFile);

      return null;
    }

    return map;
  } catch (error, stacktrace) {
    verbose(error.toString());
    verbose(stacktrace.toString());
    exitWith(ConsoleMessages.parseError, stacktrace);

    return null;
  }
}

/// Reads the config from the path provided in the command line.
Map<String, dynamic>? readConfigFileFromPath(ArgResults? command) {
  if (command == null) return null;
  if (command.options.isEmpty) return null;
  if (!command.options.contains('path')) return null;

  final File? configFile = file(command['path']);
  if (configFile == null) {
    exitWith(ConsoleMessages.invalidConfigFilePath);

    return null;
  }
  try {
    final extension = p.extension(configFile.path);
    info('Configs found at ${configFile.path}');
    if (extension == '.yaml' || extension == '.yml') {
      return yamlToMap(configFile.path);
    } else if (extension == '.json') {
      return json.decode(configFile.readAsStringSync());
    }
    exitWith(ConsoleMessages.invalidConfigFile);

    return null;
  } catch (error, stacktrace) {
    verbose(error.toString());
    verbose(stacktrace.toString());
    exitWith(ConsoleMessages.parseError, stacktrace);

    return null;
  }
}

/// Reads pubspec.yaml file content.
Map<String, dynamic>? retrievePubspecData() {
  try {
    final pubspecFile = file(p.join(Directory.current.path, 'pubspec.yaml')) ??
        file(p.join(Directory.current.path, 'pubspec.yml'));
    if (pubspecFile != null) {
      final pubspec = loadYaml(pubspecFile.readAsStringSync());

      return json.decode(json.encode(pubspec));
    }
    exitWith(ConsoleMessages.unableToLoadPubspecFile);

    return null;
  } catch (error, stacktrace) {
    verbose(error.toString());
    verbose(stacktrace.toString());
    exitWith(ConsoleMessages.unableToLoadPubspecFile);

    return null;
  }
}
