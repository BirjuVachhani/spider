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

import 'package:path/path.dart' as path;
import 'package:spider/src/configuration.dart';
import 'package:spider/src/constants.dart';
import 'package:spider/src/dart_class_generator.dart';
import 'package:spider/src/emojis.dart';

import 'src/utils.dart';

/// Entry point of all the command process
/// provides various functions to execute commands
/// Responsible for triggering dart code generation
class Spider {
  final String _path;
  Configuration configs;
  bool processing = false;
  final _fileRegex = RegExp(r'\.(jpe?g|png|gif|ico|svg|ttf|eot|woff|woff2)$',
      caseSensitive: false);

  Spider(this._path) {
    configs = Configuration(_path);
  }

  /// Triggers build
  /// [watch] determines if the directory should be watched for changes
  void build(bool watch) {
    _generate();
    if (watch) {
      _watchDirectory();
    }
  }

  /// generates dart code for given [configs] parsed from spider2.yaml
  void _generate() {
    stdout.writeln('Generating dart code...');
    var properties = createFileMap(configs['path']);
    var generator = DartClassGenerator(
      className: configs['class_name'],
      prefix: configs['prefix'] ?? '',
      use_underscores: configs['use_underscores'] ?? false,
      useStatic: configs['use_static'] ?? true,
      useConst: configs['use_const'] ?? true,
      properties: properties,
    );
    var data = generator.generate();
    writeToFile(
        name: formatFileName(configs['file_name'] ?? configs['class_name']),
        path: configs['package'] ?? '',
        content: data);
    stdout.writeln('Processed items: ${properties.length} ${Emojis.pin}');
    stdout.writeln('Dart code generated successfully. ${Emojis.thumbsUp}');
    processing = false;
  }

  /// initializes config file (spider.yaml) in the root of the project
  static void createConfigs() async {
    var configFile = File(Constants.CONFIG_FILE_NAME);
    await configFile.writeAsString(Constants.DEFAULT_CONFIGS_STRING);
    stdout.writeln(
        'Configuration file created successfully. ${Emojis.flash}${Emojis.success}');
  }

  /// Creates map from files list of a [dir] where key is the file name without
  /// extension and value is the path of the file
  Map<String, String> createFileMap(String dir) {
    dir = dir.endsWith('/') ? dir : dir + '/';
    if (!Directory(dir).existsSync()) {
      stderr.writeln('Directory "$dir" does not exist! ${Emojis.error}');
      exit(2);
    }
    var files = Directory(dir)
        .listSync()
        .where((file) =>
            File(file.path).statSync().type == FileSystemEntityType.file &&
            _fileRegex.hasMatch(path.basename(file.path)))
        .toList();

    if (files.isEmpty) {
      stderr.writeln(
          'Directory $dir does not contain any assets! ${Emojis.block}');
      exit(2);
    }
    return {
      for (var file in files)
        path.basenameWithoutExtension(file.path): file.path
    };
  }

  /// Watches assets dir for file changes and rebuilds dart code
  void _watchDirectory() {
    stdout.writeln('Watching for changes in directory ${configs["path"]}...');
    Directory(configs['path'])
        .watch(events: FileSystemEvent.all)
        .listen((data) {
      stdout.writeln('something changed...');
      if (!processing) {
        processing = true;
        Future.delayed(Duration(seconds: 1), () => _generate());
      }
    });
  }
}
