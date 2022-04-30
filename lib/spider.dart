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
import 'package:spider/src/data/json_config.dart';
import 'package:spider/src/data/yaml_config.dart';
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
          options.contains('--watch'), options.contains('--smart-watch'));
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
      final content = isJson ? JSON_CONFIGS : YAML_CONFIGS;
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
      String configContent = YAML_PUBSPEC_CONFIGS;
      if (lines.last.trim().isNotEmpty || !lines.last.endsWith('\n')) {
        configContent = '\n\n$YAML_PUBSPEC_CONFIGS';
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
    if (FileSystemEntity.isDirectorySync(path)) {
      // provide path is a directory
      Directory(path).createSync(recursive: true);
      filePath = p.join(path, isJson ? 'spider.json' : 'spider.yaml');
    } else {
      String providedFileName = p.basename(path);
      if (providedFileName == 'pubspec.yaml' ||
          providedFileName == 'pubspec.yml') {
        exitWith(ConsoleMessages.customPathIsPubspec);
        return;
      }
      if (providedFileName != 'spider.yaml' &&
          providedFileName != 'spider.json' &&
          providedFileName != 'spider.yml') {
        providedFileName = isJson ? 'spider.json' : 'spider.yaml';
      }
      final dirName = p.dirname(path);
      Directory(dirName).createSync(recursive: true);
      filePath = p.join(dirName, providedFileName);
    }
    final content =
        p.extension(filePath) == '.json' ? JSON_CONFIGS : YAML_CONFIGS;
    final file = File(filePath);
    if (file.existsSync()) {
      info('Config file already exists. Overwriting configs...');
    }
    file.writeAsStringSync(content);
    success(sprintf(ConsoleMessages.fileCreatedAtCustomPath, [filePath]));
  }
}
