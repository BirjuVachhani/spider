// Copyright © 2020 Birju Vachhani. All rights reserved.
// Use of this source code is governed by an Apache license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sprintf/sprintf.dart';
import 'package:yaml/yaml.dart';

import '../models/default_config_templates.dart';
import 'utils.dart';

/// A utility class that helps create config file using create command.
class ConfigCreator {
  /// A logger for logging information, errors and exceptions.
  final BaseLogger? logger;

  /// Default constructor.
  /// [logger] is used to output all kinds of logs, errors and exceptions.
  ConfigCreator([this.logger]);

  /// Creates a config file in 3 different ways.
  ///   1. Creates a config file in the root directory of the project when [path]
  ///      is not provided.
  ///   2. Creates a config file in the [path] directory if it is provided.
  ///   3. Appends configs in pubspec.yaml file if [addInPubspec] is true.
  /// [isJson] allows to create a json config file. This does not work if
  /// [addInPubspec] is true.
  Result<void> create({
    bool addInPubspec = false,
    bool isJson = false,
    String? path,
  }) {
    try {
      if (addInPubspec) {
        final result = createConfigsInPubspec();
        if (result.isError) return result;
        return Result.success();
      }
      if (path != null && path.isNotEmpty) {
        final result = createConfigFileAtCustomPath(path, isJson);
        if (result.isError) return result;
        return Result.success();
      }
      final result = createConfigFileInCurrentDirectory(isJson);
      if (result.isError) return result;
      return Result.success();
    } on Error catch (error, stacktrace) {
      return Result.error('Unable to create config file', error, stacktrace);
    }
  }

  /// Adds configs in pubspec.yaml file of the project. This requires the
  /// pubspec.yaml file to be present in the current directory where command
  /// is being executed.
  Result<void> createConfigsInPubspec() {
    final pubspecFile = file(p.join(Directory.current.path, 'pubspec.yaml')) ??
        file(p.join(Directory.current.path, 'pubspec.yml'));
    if (pubspecFile == null) {
      return Result.error(ConsoleMessages.pubspecNotFound);
    }
    final pubspecContent = pubspecFile.readAsStringSync();
    final pubspec = loadYaml(pubspecContent);
    if (pubspec['spider'] != null) {
      return Result.error(ConsoleMessages.configExistsInPubspec);
    }
    try {
      final lines = pubspecFile.readAsLinesSync();
      String configContent = DefaultConfigTemplates.pubspecFormat;
      if (lines.last.trim().isNotEmpty || !lines.last.endsWith('\n')) {
        configContent = '\n\n$configContent';
      }
      pubspecFile.openWrite(mode: FileMode.writeOnlyAppend)
        ..write(configContent)
        ..close();
      logger?.success(ConsoleMessages.configCreatedInPubspec);
      return Result.success();
    } on Error catch (error, stacktrace) {
      return Result.error(
          ConsoleMessages.unableToAddConfigInPubspec, error, stacktrace);
    }
  }

  /// Creates config file at custom path.
  Result<void> createConfigFileAtCustomPath(String path, bool isJson) {
    String filePath;
    if (path.startsWith('/')) path = '.$path';
    if (FileSystemEntity.isDirectorySync(path)) {
      // provided path is an existing directory
      Directory(path).createSync(recursive: true);
      filePath = p.join(path, isJson ? 'spider.json' : 'spider.yaml');
    } else {
      final String extension = p.extension(path);
      if (extension.isNotEmpty) {
        return Result.error('Provided path is not a valid directory.');
      }
      Directory(path).createSync(recursive: true);
      filePath = p.join(path, isJson ? 'spider.json' : 'spider.yaml');
    }
    final content = p.extension(filePath) == '.json'
        ? DefaultConfigTemplates.jsonFormat
        : DefaultConfigTemplates.yamlFormat;
    final file = File(filePath);
    if (file.existsSync()) {
      return Result.error('Config file already exists at $filePath.');
    }
    file.writeAsStringSync(content);
    logger
        ?.success(sprintf(ConsoleMessages.fileCreatedAtCustomPath, [filePath]));
    return Result.success();
  }

  /// Creates config file in current directory where the command is being
  /// executed.
  /// [isJson] allows to create a json config file.
  Result<void> createConfigFileInCurrentDirectory(bool isJson) {
    final filename = isJson ? 'spider.json' : 'spider.yaml';
    final dest = File(p.join(Directory.current.path, filename));
    final content = isJson
        ? DefaultConfigTemplates.jsonFormat
        : DefaultConfigTemplates.yamlFormat;
    if (dest.existsSync()) {
      logger?.info('Config file already exists. Overwriting configs...');
    }
    dest.writeAsStringSync(content);
    logger?.success('Configuration file created successfully.');
    return Result.success();
  }
}
