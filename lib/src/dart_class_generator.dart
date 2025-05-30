// Copyright © 2020 Birju Vachhani. All rights reserved.
// Use of this source code is governed by an Apache license that can be
// found in the LICENSE file.

// Author: Birju Vachhani
// Created Date: February 03, 2020

import 'dart:async';
import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as path;
import 'package:sprintf/sprintf.dart' hide Formatter;
import 'package:watcher/watcher.dart';

import 'cli/models/asset_group.dart';
import 'cli/models/spider_config.dart';
import 'cli/models/subgroup_property.dart';
import 'cli/utils/utils.dart';
import 'formatter.dart';
import 'generation_utils.dart';

/// Generates dart class code using given data
class DartClassGenerator {
  /// A group for which this generator will generate the code.
  final AssetGroup group;
  bool _processing = false;

  /// Dart code formatter used to format the generated code.
  static final formatter = DartFormatter(
    languageVersion: DartFormatter.latestLanguageVersion,
  );

  /// Global configuration values retrieved from the config file.
  final GlobalConfigs globals;

  /// A list of all the stream subscriptions the paths are being watched.
  List<StreamSubscription> subscriptions = [];

  /// A logger for logging information, errors and exceptions.
  final BaseLogger? logger;

  /// Default constructor.
  DartClassGenerator(this.group, this.globals, [this.logger]);

  /// generates dart class code and returns it as a single string
  void initAndStart({required bool watch, required bool smartWatch}) {
    if (watch) {
      if (group.paths != null) {
        logger?.verbose('path ${group.paths} is requested to be watched');
        for (final dir in group.paths!) {
          _watchDirectory(dir);
        }
      } else {
        for (final subgroup in group.subgroups!) {
          logger?.verbose('path ${subgroup.paths} is requested to be watched');
          for (final dir in subgroup.paths) {
            _watchDirectory(dir);
          }
        }
      }
    } else if (smartWatch) {
      if (group.paths != null) {
        logger
            ?.verbose('path ${group.paths} is requested to be watched smartly');
        for (final path in group.paths!) {
          _smartWatchDirectory(dir: path, types: group.types!);
        }
      } else {
        for (final subgroup in group.subgroups!) {
          logger?.verbose(
              'path ${subgroup.paths} is requested to be watched smartly');
          for (final path in subgroup.paths) {
            _smartWatchDirectory(dir: path, types: subgroup.types);
          }
        }
      }
    }
    process();
  }

  /// Starts to process/scan all the asset files picked by the configuration
  /// and generates dart references code.
  void process() {
    final startTime = DateTime.now();
    final properties = <SubgroupProperty>[];
    if (group.paths != null) {
      for (final path in group.paths!) {
        properties.add(
          SubgroupProperty(
            group.prefix!,
            createFileMap(dir: path, types: group.types!),
          ),
        );
      }
    } else {
      for (final subgroup in group.subgroups!) {
        for (final path in subgroup.paths) {
          properties.add(
            SubgroupProperty(
              subgroup.prefix,
              createFileMap(dir: path, types: group.types ?? subgroup.types),
            ),
          );
        }
      }
    }
    _generateDartCode(properties);
    if (globals.generateTests) _generateTests(properties);
    _processing = false;
    final endTime = DateTime.now();
    final int elapsedTime =
        endTime.millisecondsSinceEpoch - startTime.millisecondsSinceEpoch;

    logger?.success(
      sprintf(
        ConsoleMessages.processedItemsForClassTemplate,
        [
          group.className,
          if (properties.length > 1)
            properties.expand((element) => element.files.entries).length
          else
            properties.first.files.length,
          elapsedTime,
        ],
      ),
    );
  }

  /// Creates map from files list of a [dir] where key is the file name without
  /// extension and value is the path of the file
  Map<String, String> createFileMap({
    required String dir,
    required List<String> types,
  }) {
    String? packageAssetPathPrefix;

    final uri = Uri.directory(dir);
    if (uri.pathSegments.first == Constants.PACKAGE_ASSET_PATH_PREFIX &&
        !FileSystemEntity.isDirectorySync(dir) &&
        !FileSystemEntity.isFileSync(dir)) {
      packageAssetPathPrefix = path.joinAll(uri.pathSegments.sublist(0, 2));
    }

    final resolvedDir = packageAssetPathPrefix == null
        ? dir
        : path.join(
            Constants.LIB_FOLDER, path.joinAll(uri.pathSegments.sublist(2)));

    var files = Directory(resolvedDir).listSync().where((file) {
      final valid = _isValidFile(file, types);
      logger?.verbose('Valid: $file');
      logger?.verbose(
          'Asset - ${path.basename(file.path)} is ${valid ? 'selected' : 'not selected'}');
      return valid;
    }).toList()
      ..sort((a, b) => path.basename(a.path).compareTo(path.basename(b.path)));

    if (files.isEmpty) {
      logger?.info(sprintf(ConsoleMessages.directoryEmpty, [dir.toString()]));
      return <String, String>{};
    }
    return Map.fromEntries(files.map((file) {
      final resolvedFile = packageAssetPathPrefix == null
          ? file.path
          : path.join(packageAssetPathPrefix,
              path.joinAll(Uri.parse(file.path).pathSegments.sublist(1)));
      return MapEntry(path.basenameWithoutExtension(file.path), resolvedFile);
    }));
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
    logger?.info(sprintf(
        ConsoleMessages.watchingForChangesInDirectory, [dir.toString()]));
    final watcher = DirectoryWatcher(dir);

    final subscription = watcher.events.listen((event) {
      logger?.verbose('something changed...');
      if (!_processing) {
        _processing = true;
        Future.delayed(Duration(seconds: 1), () => process());
      }
    });
    subscriptions.add(subscription);
  }

  /// Smartly watches assets dir for file changes and rebuilds dart code
  void _smartWatchDirectory({
    required String dir,
    required List<String> types,
  }) {
    logger?.info(sprintf(
        ConsoleMessages.watchingForChangesInDirectory, [dir.toString()]));
    final watcher = DirectoryWatcher(dir);
    final subscription = watcher.events.listen((event) {
      logger?.verbose('something changed...');
      final filename = path.basename(event.path);
      if (event.type == ChangeType.MODIFY) {
        logger?.verbose('$filename is modified. '
            '${group.className} class will not be rebuilt');
        return;
      }
      if (!types.contains(path.extension(event.path))) {
        logger
            ?.verbose('$filename does not have allowed extension for the group '
                '$dir. ${group.className} class will not be rebuilt');
        return;
      }
      if (!_processing) {
        _processing = true;
        Future.delayed(Duration(seconds: 1), () => process());
      }
    });

    subscriptions.add(subscription);
  }

  void _generateDartCode(List<SubgroupProperty> properties) {
    final staticProperty = group.useStatic ? 'static' : '';
    final constProperty = group.useConst ? ' const' : '';
    var references = '';

    for (final property in properties) {
      references += property.files.keys
          .map<String>(
            (name) {
              logger?.verbose(
                  'processing ${path.basename(property.files[name]!)}');
              return getReference(
                  properties: staticProperty + constProperty,
                  assetName: Formatter.formatName(
                    name,
                    prefix: group.paths != null
                        ? group.prefix!
                        : group.prefix ?? property.prefix,
                    useUnderScores: group.useUnderScores,
                  ),
                  assetPath: Formatter.formatPath(property.files[name]!));
            },
          )
          .toList()
          .join();
    }

    // Can be transformed into lambda function or simplified
    List<String> getAssetNames() {
      final assetNames = <String>[];
      for (final property in properties) {
        assetNames.addAll(property.files.keys
            .map(
              (name) => Formatter.formatName(
                name,
                prefix: group.paths != null
                    ? group.prefix!
                    : group.prefix ?? property.prefix,
                useUnderScores: group.useUnderScores,
              ),
            )
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

    logger?.verbose('Constructing dart class for ${group.className}');
    final content = getDartClass(
      ignoredRules: globals.ignoredRules,
      className: group.className,
      references: references,
      noComments: globals.noComments,
      usePartOf: globals.export && globals.usePartOf!,
      exportFileName: Formatter.formatFileName(globals.exportFileName),
      valuesList: valuesList,
    );
    logger
        ?.verbose('Writing class ${group.className} to file ${group.fileName}');
    writeToFile(
      name: Formatter.formatFileName(group.fileName),
      path: globals.package,
      content: formatter.format(content),
      logger: logger,
    );
  }

  void _generateTests(List<SubgroupProperty> properties) {
    logger?.info(
        sprintf(ConsoleMessages.generatingTestsForClass, [group.className]));
    final fileName =
        path.basenameWithoutExtension(Formatter.formatFileName(group.fileName));
    var tests = '';
    for (final property in properties) {
      tests += property.files.keys
          .map<String>((key) {
            return getTestCase(
                group.className,
                Formatter.formatName(
                  key,
                  prefix: group.paths != null
                      ? group.prefix!
                      : group.prefix ?? property.prefix,
                  useUnderScores: group.useUnderScores,
                ));
          })
          .toList()
          .join();
    }
    logger?.verbose('generating test dart code');
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
    logger?.verbose(
        'writing test ${fileName}_test.dart for class ${group.className}');
    classFile.writeAsStringSync(formatter.format(content));
    logger?.verbose(
        'File ${path.basename(classFile.path)} is written successfully');
  }

  /// Cancels all subscriptions
  void cancelSubscriptions() {
    for (var element in subscriptions) {
      element.cancel();
    }
  }
}
