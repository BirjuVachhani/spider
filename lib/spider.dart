/*
 * Copyright © $YEAR Birju Vachhani
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

import 'package:spider/src/Formatter.dart';
import 'package:spider/src/asset_group.dart';
import 'package:spider/src/configuration.dart';
import 'package:spider/src/constants.dart';
import 'package:spider/src/dart_class_generator.dart';
import 'package:spider/src/emojis.dart';

import 'src/constants.dart';

/// Entry point of all the command process
/// provides various functions to execute commands
/// Responsible for triggering dart code generation
class Spider {
  final String _path;
  Configuration configs;

  Spider(this._path) {
    configs = Configuration(_path);
  }

  /// Triggers build
  /// [watch] determines if the directory should be watched for changes
  void build(bool watch, {bool verbose = false}) {
    if (configs['groups'] != null) {
      configs['groups'].forEach(
          (conf) => _generateFor(conf, watch: watch, verbose: verbose));
    } else {
      _generateFor(configs.configs, watch: watch, verbose: verbose);
    }
  }

  void _generateFor(dynamic conf, {bool watch, bool verbose}) {
    var group = AssetGroup(
        className: conf['class_name'] ?? Constants.DEFAULT_CLASS_NAME,
        package: conf['package'] ?? Constants.DEFAULT_PACKAGE,
        path: conf['path'] ?? Constants.DEFAULT_PATH,
        prefix: conf['prefix'] ?? '',
        fileName: Formatter.formatFileName(conf['file_name'] ??
            conf['class_name'] ??
            Constants.DEFAULT_CLASS_NAME));
    var generator = DartClassGenerator(group: group, verbose: verbose);
    generator.generate(watch);
  }

  /// initializes config file (spider.yaml) in the root of the project
  static void createConfigs() async {
    var configFile = File(Constants.CONFIG_FILE_NAME);
    await configFile.writeAsString(Constants.DEFAULT_CONFIGS_STRING);
    stdout.writeln(
        'Configuration file created successfully. ${Emojis.flash}${Emojis.success}');
    // TODO
  }
}
