/*
 * Copyright © 2020 Birju Vachhani
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// Author: Birju Vachhani
// Created Date: February 02, 2020

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:spider/src/cli/command_processor.dart';
import 'package:spider/src/data/json_config_template.dart';
import 'package:spider/src/data/yaml_config_template.dart';
import 'package:spider/src/formatter.dart';
import 'package:spider/src/spider_config.dart';
import 'package:sprintf/sprintf.dart' show sprintf;

import 'src/constants.dart';
import 'src/dart_class_generator.dart';
import 'src/utils.dart';

/// Entry point of all the command process
/// provides various functions to execute commands
/// Responsible for triggering dart code generation
class Spider {
  SpiderConfiguration config;

  Spider(this.config);

  /// Triggers build
  void build([List<String> options = const []]) {
    if (config.groups.isEmpty) {
      exitWith('No groups found in config file.');
    }
    for (final group in config.groups) {
      final generator = DartClassGenerator(group, config.globals);
      generator.initAndStart(
          options.hasArg('watch', 'w'), options.contains('--smart-watch'));
    }
    if (config.globals.export) {
      exportAsLibrary();
    }
  }

  /// initializes config file (spider.yaml) in the root of the project
  static void createConfigs({
    bool isJson = false,
    bool addInPubspec = false,
    String? path,
  }) {
    try {
      if (addInPubspec) {
        createConfigsInPubspec();
        return;
      }
      if (path != null && path.isNotEmpty) {
        createConfigFileAtCustomPath(path, isJson);
        return;
      }
      final filename = isJson ? 'spider.json' : 'spider.yaml';
      final dest = File(p.join(Directory.current.path, filename));
      final content = isJson ? JSON_CONFIG_TEMPLATE : YAML_CONFIG_TEMPLATE;
      if (dest.existsSync()) {
        info('Config file already exists. Overwriting configs...');
      }
      dest.writeAsStringSync(content);
      success('Configuration file created successfully.');
    } on Error catch (e) {
      exitWith('Unable to create config file', e.stackTrace);
    }
  }

  /// Generates library export file for all the generated references files.
  void exportAsLibrary() {
    final content = getExportContent(
      noComments: config.globals.noComments,
      usePartOf: config.globals.usePartOf ?? false,
      fileNames: config.groups
          .map<String>((group) => Formatter.formatFileName(group.fileName))
          .toList(),
    );
    writeToFile(
        name: Formatter.formatFileName(config.globals.exportFileName),
        path: config.globals.package,
        content: DartClassGenerator.formatter.format(content));
  }

  /// Appends spider config into project's pubspec.yaml file.
  static void createConfigsInPubspec() {
    final pubspecFile = file('pubspec.yaml') ?? file('pubspec.yml');
    if (pubspecFile == null) {
      exitWith(ConsoleMessages.pubspecNotFound);
      return;
    }
    final pubspecContent = pubspecFile.readAsStringSync();
    if (pubspecContent.contains('spider')) {
      exitWith(ConsoleMessages.configExistsInPubspec);
      return;
    }
    try {
      final lines = pubspecFile.readAsLinesSync();
      String configContent = YAML_PUBSPEC_CONFIG_TEMPLATE;
      if (lines.last.trim().isNotEmpty || !lines.last.endsWith('\n')) {
        configContent = '\n\n$YAML_PUBSPEC_CONFIG_TEMPLATE';
      }
      pubspecFile.openWrite(mode: FileMode.writeOnlyAppend)
        ..write(configContent)
        ..close();
      success(ConsoleMessages.configCreatedInPubspec);
    } on Error catch (e) {
      exitWith(ConsoleMessages.unableToAddConfigInPubspec, e.stackTrace);
    }
  }

  /// Creates config file at custom path.
  static void createConfigFileAtCustomPath(String path, bool isJson) {
    String filePath;
    if (path.startsWith('/')) path = '.$path';
    if (FileSystemEntity.isDirectorySync(path)) {
      // provided path is an existing directory
      Directory(path).createSync(recursive: true);
      filePath = p.join(path, isJson ? 'spider.json' : 'spider.yaml');
    } else {
      final String extension = p.extension(path);
      if (extension.isNotEmpty) {
        exitWith('Provided path is not a valid directory.');
        return;
      }
      Directory(path).createSync(recursive: true);
      filePath = p.join(path, isJson ? 'spider.json' : 'spider.yaml');
    }
    final content = p.extension(filePath) == '.json'
        ? JSON_CONFIG_TEMPLATE
        : YAML_CONFIG_TEMPLATE;
    final file = File(filePath);
    if (file.existsSync()) {
      exitWith('Config file already exists at $filePath.');
      return;
    }
    file.writeAsStringSync(content);
    success(sprintf(ConsoleMessages.fileCreatedAtCustomPath, [filePath]));
  }
}
