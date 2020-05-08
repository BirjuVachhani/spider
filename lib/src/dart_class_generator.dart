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
// Created Date: February 03, 2020

import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as path;
import 'package:watcher/watcher.dart';

import 'Formatter.dart';
import 'asset_group.dart';
import 'constants.dart';
import 'utils.dart';

/// Generates dart class code using given data
class DartClassGenerator {
  final AssetGroup group;
  bool _processing = false;
  static final formatter = DartFormatter();
  final bool generateTest;
  final bool noComments;
  final String projectName;

  DartClassGenerator(
    this.group, {
    this.projectName,
    this.noComments = false,
    this.generateTest = false,
  });

  /// generates dart class code and returns it as a single string
  void generate(bool watch, bool smartWatch) {
    if (watch) {
      verbose('path ${group.paths} is requested to be watched');
      group.paths.forEach((dir) => _watchDirectory(dir));
    } else if (smartWatch) {
      verbose('path ${group.paths} is requested to be watched smartly');
      group.paths.forEach((dir) => _smartWatchDirectory(dir));
    }
    process();
  }

  void process() {
    final startTime = DateTime.now();
    var properties = <String, String>{};
    group.paths.forEach((dir) => properties.addAll(createFileMap(dir)));
    _generateDartCode(properties);
    if (generateTest) {
      _generateTests(properties);
    }
    _processing = false;
    final endTime = DateTime.now();
    final elapsedTime =
        endTime.millisecondsSinceEpoch - startTime.millisecondsSinceEpoch;
    success(
        'Processed items for class ${group.className}: ${properties.length} '
        'in ${elapsedTime / 1000} seconds.');
  }

  /// Creates map from files list of a [dir] where key is the file name without
  /// extension and value is the path of the file
  Map<String, String> createFileMap(String dir) {
    var files = Directory(dir).listSync().where((file) {
      final valid = _isValidFile(file);
      verbose('Valid: $file');
      verbose(
          'Asset - ${path.basename(file.path)} is ${valid ? 'selected' : 'not selected'}');
      return valid;
    })?.toList();

    if (files.isEmpty) {
      info('Directory $dir does not contain any assets!');
      return <String, String>{};
    }
    return {
      for (var file in files)
        path.basenameWithoutExtension(file.path): file.path
    };
  }

  /// checks whether the file is valid file to be included or not
  /// 1. must be a file, not a directory
  /// 2. should be from one of the allowed types if specified any
  bool _isValidFile(dynamic file) {
    return FileSystemEntity.isFileSync(file.path) &&
        path.extension(file.path).isNotEmpty &&
        (group.types.isEmpty ||
            group.types.contains(path.extension(file.path)));
  }

  /// Watches assets dir for file changes and rebuilds dart code
  void _watchDirectory(String dir) {
    info('Watching for changes in directory ${dir}...');
    final watcher = DirectoryWatcher(dir);

    watcher.events.listen((event) {
      verbose('something changed...');
      if (!_processing) {
        _processing = true;
        Future.delayed(Duration(seconds: 1), () => process());
      }
    });
  }

  /// Smartly watches assets dir for file changes and rebuilds dart code
  void _smartWatchDirectory(String dir) {
    info('Watching for changes in directory ${dir}...');
    final watcher = DirectoryWatcher(dir);
    watcher.events.listen((event) {
      verbose('something changed...');
      final filename = path.basename(event.path);
      if (event.type == ChangeType.MODIFY) {
        verbose('$filename is modified. '
            '${group.className} class will not be rebuilt');
        return;
      }
      if (!group.types.contains(path.extension(event.path))) {
        verbose('$filename does not have allowed extension for the group '
            '${dir}. ${group.className} class will not be rebuilt');
        return;
      }
      if (!_processing) {
        _processing = true;
        Future.delayed(Duration(seconds: 1), () => process());
      }
    });
  }

  void _generateDartCode(Map<String, String> properties) {
    var references = properties.keys
        .map<String>((name) {
          verbose('processing ${path.basename(properties[name])}');
          final staticProperty = group.useStatic ? 'static' : '';
          final constProperty = group.useConst ? ' const' : '';
          return getReference(
              properties: staticProperty + constProperty,
              assetName: Formatter.formatName(name),
              assetPath: Formatter.formatPath(properties[name]));
        })
        ?.toList()
        ?.join();

    verbose('Constructing dart class for ${group.className}');
    final content = getDartClass(
      className: group.className,
      references: references,
      noComments: noComments,
    );
    verbose('Writing class ${group.className} to file ${group.fileName}');
    writeToFile(
        name: Formatter.formatFileName(group.fileName ?? group.className),
        path: group.package,
        content: formatter.format(content));
  }

  void _generateTests(Map<String, String> properties) {
    info('Generating tests for class ${group.className}');
    final fileName = path.basenameWithoutExtension(
        Formatter.formatFileName(group.fileName ?? group.className));
    final tests = properties.keys
        .map<String>(
            (key) => getTestCase(group.className, Formatter.formatName(key)))
        ?.toList()
        ?.join();
    verbose('generating test dart code');
    final content = getTestClass(
      project: projectName,
      fileName: fileName,
      package: group.package,
      noComments: noComments,
      tests: tests,
    );

    // create test directory if doesn't exist
    if (!Directory(Constants.TEST_FOLDER).existsSync()) {
      Directory(Constants.TEST_FOLDER).createSync();
    }
    var classFile =
        File(path.join(Constants.TEST_FOLDER, '${fileName}_test.dart'));
    verbose('writing test ${fileName}_test.dart for class ${group.className}');
    classFile.writeAsStringSync(formatter.format(content));
    verbose('File ${path.basename(classFile.path)} is written successfully');
  }
}
