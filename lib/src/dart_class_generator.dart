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
import 'package:spider/src/pair.dart';
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
    for (final subgroup in group.subgroups) {
      if (watch) {
        verbose('path ${subgroup.paths} is requested to be watched');
        for (final dir in subgroup.paths) {
          _watchDirectory(dir);
        }
      } else if (smartWatch) {
        verbose('path ${subgroup.paths} is requested to be watched smartly');
        for (final dir in subgroup.paths) {
          _smartWatchDirectory(dir, subgroup.types);
        }
      }
    }
    process();
  }

  /// Starts to process/scan all the asset files picked by the configuration
  /// and generates dart references code.
  void process() {
    final startTime = DateTime.now();

    /// List of pairs (first: prefix, second: map(fileName: path))
    var properties = <Pair<String, Map<String, String>>>[];
    for (final subgroup in group.subgroups) {
      for (final dir in subgroup.paths) {
        properties.add(Pair<String, Map<String, String>>(
          subgroup.prefix,
          createFileMap(dir, subgroup.types),
        ));
      }
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
  Map<String, String> createFileMap(String dir, List<String> types) {
    var files = Directory(dir).listSync().where((file) {
      final valid = _isValidFile(file, types);
      verbose('Valid: $file');
      verbose(
          'Asset - ${path.basename(file.path)} is ${valid ? 'selected' : 'not selected'}');
      return valid;
    }).toList()
      ..sort((a, b) => path.basename(a.path).compareTo(path.basename(b.path)));

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
  bool _isValidFile(dynamic file, List<String> types) {
    return FileSystemEntity.isFileSync(file.path) &&
        path.extension(file.path).isNotEmpty &&
        (types.isEmpty || types.contains(path.extension(file.path)));
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
  void _smartWatchDirectory(String dir, List<String> types) {
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
      if (!types.contains(path.extension(event.path))) {
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

  void _generateDartCode(List<Pair<String, Map<String, String>>> properties) {
    final staticProperty = group.useStatic ? 'static' : '';
    final constProperty = group.useConst ? ' const' : '';
    var references = '';

    for (final subgroup in properties) {
      final currentPrefix = subgroup.first;
      final currentMap = subgroup.second;
      references += currentMap.keys
          .map<String>((name) {
            verbose('processing ${path.basename(currentMap[name]!)}');
            return getReference(
                properties: staticProperty + constProperty,
                assetName: Formatter.formatName(name,
                    prefix: currentPrefix,
                    useUnderScores: group.useUnderScores),
                assetPath: Formatter.formatPath(currentMap[name]!));
          })
          .toList()
          .join();
    }

    // Can be transformed into lambda function or simplified
    List<String> getAssetNames() {
      final assetNames = <String>[];
      for (final subgroup in properties) {
        final currentPrefix = subgroup.first;
        final currentMap = subgroup.second;
        assetNames.addAll(currentMap.keys
            .map((name) => Formatter.formatName(
                  name,
                  prefix: currentPrefix,
                  useUnderScores: group.useUnderScores,
                ))
            .toList());
      }

      return assetNames;
    }

    final valuesList = globals.useReferencesList
        ? getListOfReferences(
            properties: staticProperty + constProperty,
            assetNames: getAssetNames(),
          )
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

  void _generateTests(List<Pair<String, Map<String, String>>> properties) {
    info('Generating tests for class ${group.className}');
    final fileName =
        path.basenameWithoutExtension(Formatter.formatFileName(group.fileName));
    var tests = '';
    for (final subgroup in properties) {
      final currentPrefix = subgroup.first;
      final currentMap = subgroup.second;
      tests += currentMap.keys
          .map<String>((key) => getTestCase(
              group.className,
              Formatter.formatName(
                key,
                prefix: currentPrefix,
                useUnderScores: group.useUnderScores,
              )))
          .toList()
          .join();
    }
    verbose('generating test dart code');
    final content = getTestClass(
      project: globals.projectName,
      fileName: fileName,
      package: globals.package!,
      noComments: globals.noComments,
      tests: tests,
      testImport: globals.useFlutterTestImports ? 'flutter_test' : 'test',
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
