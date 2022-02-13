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

import 'dart:async';
import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as path;
import 'package:spider/src/spider_config.dart';
import 'package:watcher/watcher.dart';

import 'asset_group.dart';
import 'constants.dart';
import 'formatter.dart';
import 'utils.dart';

/// Generates dart class code using given data
class DartClassGenerator {
  final AssetGroup group;
  bool _processing = false;
  static final formatter = DartFormatter();
  final GlobalConfigs globals;

  StreamSubscription? subscription;

  DartClassGenerator(this.group, this.globals);

  /// generates dart class code and returns it as a single string
  void initAndStart(bool watch, bool smartWatch) {
    if (watch) {
      verbose('path ${group.paths} is requested to be watched');
      for (final dir in group.paths) {
        _watchDirectory(dir);
      }
    } else if (smartWatch) {
      verbose('path ${group.paths} is requested to be watched smartly');
      for (final dir in group.paths) {
        _smartWatchDirectory(dir);
      }
    }
    process();
  }

  /// Starts to process/scan all the asset files picked by the configuration
  /// and generates dart references code.
  void process() {
    final startTime = DateTime.now();
    var properties = <String, String>{};
    for (final dir in group.paths) {
      properties.addAll(createFileMap(dir));
    }
    _generateDartCode(properties);
    if (globals.generateTests) _generateTests(properties);
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
    }).toList();

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
    info('Watching for changes in directory $dir...');
    final watcher = DirectoryWatcher(dir);

    subscription = watcher.events.listen((event) {
      verbose('something changed...');
      if (!_processing) {
        _processing = true;
        Future.delayed(Duration(seconds: 1), () => process());
      }
    });
  }

  /// Smartly watches assets dir for file changes and rebuilds dart code
  void _smartWatchDirectory(String dir) {
    info('Watching for changes in directory $dir...');
    final watcher = DirectoryWatcher(dir);
    subscription = watcher.events.listen((event) {
      verbose('something changed...');
      final filename = path.basename(event.path);
      if (event.type == ChangeType.MODIFY) {
        verbose('$filename is modified. '
            '${group.className} class will not be rebuilt');
        return;
      }
      if (!group.types.contains(path.extension(event.path))) {
        verbose('$filename does not have allowed extension for the group '
            '$dir. ${group.className} class will not be rebuilt');
        return;
      }
      if (!_processing) {
        _processing = true;
        Future.delayed(Duration(seconds: 1), () => process());
      }
    });
  }

  void _generateDartCode(Map<String, String> properties) {
    final staticProperty = group.useStatic ? 'static' : '';
    final constProperty = group.useConst ? ' const' : '';
    var references = properties.keys
        .map<String>((name) {
          verbose('processing ${path.basename(properties[name]!)}');
          return getReference(
              properties: staticProperty + constProperty,
              assetName: Formatter.formatName(name,
                  prefix: group.prefix ?? '',
                  useUnderScores: group.useUnderScores),
              assetPath: Formatter.formatPath(properties[name]!));
        })
        .toList()
        .join();

    final valuesList = globals.useReferencesList
        ? getListOfReferences(
            properties: staticProperty + constProperty,
            assetNames: properties.keys
                .map((name) => Formatter.formatName(name,
                    prefix: group.prefix ?? '',
                    useUnderScores: group.useUnderScores))
                .toList())
        : null;

    verbose('Constructing dart class for ${group.className}');
    final content = getDartClass(
      className: group.className,
      references: references,
      noComments: globals.noComments,
      usePartOf: globals.export && globals.usePartOf!,
      exportFileName: Formatter.formatFileName(globals.exportFileName),
      valuesList: valuesList,
    );
    verbose('Writing class ${group.className} to file ${group.fileName}');
    writeToFile(
        name: Formatter.formatFileName(group.fileName),
        path: globals.package,
        content: formatter.format(content));
  }

  void _generateTests(Map<String, String> properties) {
    info('Generating tests for class ${group.className}');
    final fileName =
        path.basenameWithoutExtension(Formatter.formatFileName(group.fileName));
    final tests = properties.keys
        .map<String>((key) => getTestCase(
            group.className,
            Formatter.formatName(
              key,
              prefix: group.prefix ?? '',
              useUnderScores: group.useUnderScores,
            )))
        .toList()
        .join();
    verbose('generating test dart code');
    final content = getTestClass(
      project: globals.projectName!,
      fileName: fileName,
      package: globals.package!,
      noComments: globals.noComments,
      tests: tests,
      importFileName: globals.export && globals.usePartOf!
          ? Formatter.formatFileName(globals.exportFileName)
          : Formatter.formatFileName(group.fileName),
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

  void cancelSubscriptions() {
    subscription?.cancel();
  }
}
