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

import 'src/asset_group.dart';
import 'src/dart_class_generator.dart';
import 'src/emojis.dart';
import 'src/utils.dart';

/// Entry point of all the command process
/// provides various functions to execute commands
/// Responsible for triggering dart code generation
class Spider {
  final String _path;
  List<AssetGroup> groups;

  Spider(this._path) : groups = parseConfig(_path);

  /// Triggers build
  /// [watch] determines if the directory should be watched for changes
  void build(bool watch, {bool verbose = false}) {
    if (groups == null) {
      exit_with('No groups found in config file.');
    }
    for (var group in groups) {
      var generator = DartClassGenerator(group: group, verbose: verbose);
      generator.generate(watch);
    }
  }

  /// initializes config file (spider.yaml) in the root of the project
  static void createConfigs(bool isJson) {
    var ext = isJson ? 'json' : 'yaml';
    var src =
        path.join(path.dirname(Platform.script.toFilePath()), '../config.$ext');
    var dest = 'spider' + path.extension(src);
    File(src).copySync(dest);
    stdout.writeln(
        'Configuration file created successfully. ${Emojis.flash}${Emojis.success}');
  }
}
