// Copyright © 2020 Birju Vachhani. All rights reserved.
// Use of this source code is governed by an Apache license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sprintf/sprintf.dart';
import 'package:yaml/yaml.dart';

import '../models/spider_config.dart';
import 'utils.dart';

/// A top-level method that would retrieve the config file from either root,
/// pubspec or custom path and return parsed [SpiderConfiguration] object.
/// [allowEmpty] if set to true, would consider configs as valid even if no
/// groups are provided and fonts is not set.
Result<SpiderConfiguration> retrieveConfigs({
  String? customPath,
  BaseLogger? logger,
  bool allowEmpty = false,
  bool fontsOnly = false,
}) {
  final Result<JsonMap>? result = readConfigFileFromPath(customPath, logger) ??
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
    final validationResult = validateConfigs(
      configJson,
      allowEmpty: allowEmpty,
      fontsOnly: fontsOnly,
    );
    if (validationResult.isError) {
      return Result.error(
        validationResult.error,
        validationResult.exception,
        validationResult.stacktrace,
      );
    }

    final Result<JsonMap> result = retrievePubspecData();
    if (result.isError) {
      return Result.error(result.error, result.exception, result.stacktrace);
    }
    configJson['pubspec'] = result.data;
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
      logger?.info(
          sprintf(ConsoleMessages.configFoundAtTemplate, [yamlFile.path]));
      logger?.info(sprintf(ConsoleMessages.loadingConfigsFromTemplate,
          [p.basename(yamlFile.path)]));
      map = yamlToMap(yamlFile.path);
    } else if (jsonFile != null) {
      logger?.info(
          sprintf(ConsoleMessages.configFoundAtTemplate, [jsonFile.path]));
      logger?.info(sprintf(ConsoleMessages.loadingConfigsFromTemplate,
          [p.basename(jsonFile.path)]));
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
    logger?.info(
        sprintf(ConsoleMessages.configFoundAtTemplate, [pubspecFile.path]));
    return Result.success(JsonMap.from(parsed));
  } catch (error, stacktrace) {
    return Result.error(ConsoleMessages.parseError, error, stacktrace);
  }
}

/// Reads the config from the path provided in the command line.
Result<JsonMap>? readConfigFileFromPath(String? customPath,
    [BaseLogger? logger]) {
  if (customPath == null) return null;

  final File? configFile = file(customPath);
  if (configFile == null) {
    return Result.error(ConsoleMessages.invalidConfigFilePath);
  }
  try {
    final extension = p.extension(configFile.path);
    logger?.info(
        sprintf(ConsoleMessages.configFoundAtTemplate, [configFile.path]));
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
      return Result.success(json.decode(json.encode(pubspec)));
    }
    return Result.error(ConsoleMessages.unableToLoadPubspecFile);
  } catch (error, stacktrace) {
    return Result.error(
        ConsoleMessages.unableToLoadPubspecFile, error, stacktrace);
  }
}
