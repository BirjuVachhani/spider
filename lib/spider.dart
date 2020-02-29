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

import 'package:path/path.dart' as path;
import 'package:spider/src/data/json_config.dart';
import 'package:spider/src/data/yaml_config.dart';

import 'src/asset_group.dart';
import 'src/dart_class_generator.dart';
import 'src/utils.dart';

/// Entry point of all the command process
/// provides various functions to execute commands
/// Responsible for triggering dart code generation
class Spider {
  List<AssetGroup> groups;

  Spider(String path) : groups = parseConfig(path);

  /// Triggers build
  /// [watch] determines if the directory should be watched for changes
  void build([List<String> options = const []]) {
    if (groups == null) {
      exit_with('No groups found in config file.');
    }
    validateGroups();
    for (var group in groups) {
      var generator = DartClassGenerator(group);
      generator.generate(
          options.contains('--watch'), options.contains('--smart-watch'));
    }
  }

  /// initializes config file (spider.yaml) in the root of the project
  static void createConfigs(bool isJson) {
    try {
      var filename = isJson ? 'spider.json' : 'spider.yaml';
      var content = isJson ? JSON_CONFIGS : YAML_CONFIGS;
      var dest = File(path.join(Directory.current.path, filename));
      if (dest.existsSync()) {
        info('Config file already exists. Overwritting configs...');
      }
      dest.writeAsStringSync(content);
      success('Configuration file created successfully.');
    } on Error catch (e) {
      exit_with('Unable to create config file', e.stackTrace);
    }
  }

  /// performs validation checks on provided group configurations
  void validateGroups() {
    for (final group in groups) {
      if (group.path.isEmpty) {
        exit_with('Exmpty paths are not allowed');
      }
      if (File(group.path).existsSync()) {
        exit_with('Path ${group.path} is not a directory');
      }
      if (!Directory(group.path).existsSync()) {
        exit_with('Path ${group.path} does not exist!');
      }
      final dirName = path.basename(group.path);
      if (RegExp(r'^2.0x|3.0x$').hasMatch(dirName)) {
        exit_with('${group.path} is not a valid asset directory.');
      }
    }
  }
}
