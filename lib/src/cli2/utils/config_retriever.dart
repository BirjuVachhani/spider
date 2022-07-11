import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../../spider_config.dart';
import 'utils.dart';

Result<SpiderConfiguration> retrieveConfigs(
    [ArgResults? command, BaseLogger? logger]) {
  final Result<JsonMap>? result = readConfigFileFromPath(command) ??
      readConfigsFromPubspec(logger) ??
      readConfigFileFromRoot(logger);

  if (result == null) {
    return Result.error(ConsoleMessages.configNotFoundDetailed);
  }

  if (result.isError) {
    return Result.error(result.error, result.exception, result.stacktrace);
  }

  final JsonMap configJson = result.data;

  try {
    logger?.verbose('Validating configs');
    validateConfigs(configJson, logger);
    final Result<JsonMap> result = retrievePubspecData();
    if (result.isError) {
      return Result.error(result.error, result.exception, result.stacktrace);
    }
    final JsonMap pubspec = result.data;

    configJson['project_name'] = pubspec['name'];
    configJson['flutter_project'] = pubspec['dependencies']?['flutter'] != null;
    final config = SpiderConfiguration.fromJson(configJson);
    return Result.success(config);
  } catch (error, stacktrace) {
    return Result.error(ConsoleMessages.parseError, error, stacktrace);
  }
}

/// Reads the config from the config file in the current directory.
Result<JsonMap>? readConfigFileFromRoot([BaseLogger? logger]) {
  try {
    var yamlFile = file(p.join(Directory.current.path, 'spider.yaml')) ??
        file(p.join(Directory.current.path, 'spider.yml'));
    final jsonFile = file(p.join(Directory.current.path, 'spider.json'));
    Map<String, dynamic> map;
    if (yamlFile != null) {
      logger?.info('Configs found at ${yamlFile.path}');
      logger?.verbose('Loading configs from ${p.basename(yamlFile.path)}');
      map = yamlToMap(yamlFile.path);
    } else if (jsonFile != null) {
      logger?.info('Configs found at ${jsonFile.path}');
      logger?.verbose('Loading configs from ${p.basename(jsonFile.path)}');
      map = json.decode(jsonFile.readAsStringSync());
    } else {
      return null;
    }
    if (map.isEmpty) {
      return Result.error(ConsoleMessages.invalidConfigFile);
    }
    return Result.success(map);
  } catch (error, stacktrace) {
    return Result.error(ConsoleMessages.parseError, error, stacktrace);
  }
}

/// Reads config file from pubspec.yaml file.
Result<JsonMap>? readConfigsFromPubspec([BaseLogger? logger]) {
  try {
    final File? pubspecFile = file('pubspec.yaml') ?? file('pubspec.yml');
    if (pubspecFile == null || !pubspecFile.existsSync()) return null;
    final parsed = yamlToMap(pubspecFile.path)['spider'];
    if (parsed == null) return null;
    logger?.info('Configs found at ${pubspecFile.path}');
    return Result.success(JsonMap.from(parsed));
  } catch (error, stacktrace) {
    return Result.error(ConsoleMessages.parseError, error, stacktrace);
  }
}

/// Reads the config from the path provided in the command line.
Result<JsonMap>? readConfigFileFromPath(ArgResults? command,
    [BaseLogger? logger]) {
  if (command == null) return null;
  if (command.options.isEmpty) return null;
  if (!command.options.contains('path')) return null;

  final File? configFile = file(command['path']);
  if (configFile == null) {
    return Result.error(ConsoleMessages.invalidConfigFilePath);
  }
  try {
    final extension = p.extension(configFile.path);
    logger?.info('Configs found at ${configFile.path}');
    if (extension == '.yaml' || extension == '.yml') {
      return Result.success(yamlToMap(configFile.path));
    } else if (extension == '.json') {
      return Result.success(json.decode(configFile.readAsStringSync()));
    }
    return Result.error(ConsoleMessages.invalidConfigFile);
  } catch (error, stacktrace) {
    return Result.error(ConsoleMessages.parseError, error, stacktrace);
  }
}

/// Reads pubspec.yaml file content.
Result<JsonMap> retrievePubspecData() {
  try {
    final pubspecFile = file(p.join(Directory.current.path, 'pubspec.yaml')) ??
        file(p.join(Directory.current.path, 'pubspec.yml'));
    if (pubspecFile != null) {
      final pubspec = loadYaml(pubspecFile.readAsStringSync());
      return json.decode(json.encode(pubspec));
    }
    return Result.error(ConsoleMessages.unableToLoadPubspecFile);
  } catch (error, stacktrace) {
    return Result.error(
        ConsoleMessages.unableToLoadPubspecFile, error, stacktrace);
  }
}
