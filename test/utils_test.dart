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

import 'dart:io';

import 'package:spider/src/constants.dart';
import 'package:spider/src/utils.dart';
import 'package:sprintf/sprintf.dart';
import 'package:test/test.dart';

import 'test_utils.dart';

void main() {
  const Map<String, dynamic> testConfig = {
    "generate_tests": false,
    "no_comments": true,
    "export": true,
    "use_part_of": true,
    "package": "resources",
    "groups": [
      {
        "path": "assets/images",
        "class_name": "Assets",
        "types": ["jpg", "jpeg", "png", "webp", "gif", "bmp", "wbmp"]
      }
    ]
  };

  test('extension formatter test', () {
    expect('.png', formatExtension('png'));
    expect('.jpg', formatExtension('.jpg'));
  });

  test('checkFlutterProject test', () async {
    final handle = await startSpiderProcess('test', '../bin/main.dart');
    handle.verifyConsoleError(ConsoleMessages.notFlutterProjectError);
  });

  test('getReference test', () async {
    expect(
        getReference(
          properties: 'static const',
          assetName: 'avatar',
          assetPath: 'assets/images/avatar.png',
        ),
        equals("static const String avatar = 'assets/images/avatar.png';"));
  });

  test('writeToFile test', () async {
    writeToFile(name: 'test.txt', path: 'resources', content: 'Hello');
    final file = File('lib/resources/test.txt');
    expect(file.existsSync(), isTrue);
    expect(file.readAsStringSync(), equals('Hello'));

    addTearDown(() {
      file.deleteSync();
      Directory('lib/resources').deleteSync();
    });
  });

  test('getExportContent test', () async {
    expect(getExportContent(fileNames: ['test.dart'], noComments: true),
        equals("export 'test.dart';"));

    expect(getExportContent(fileNames: ['test.dart'], noComments: false),
        contains('Generated by spider'));

    expect(
        getExportContent(
            fileNames: ['test.dart'], noComments: true, usePartOf: true),
        equals("part 'test.dart';"));
  });

  group('parse config tests', () {
    test('no config file test', () async {
      final handle = await startSpiderProcess();
      handle.verifyConsoleError(ConsoleMessages.configNotFound);
    });

    test('empty yaml config file test', () async {
      File('spider.yaml').createSync();
      final handle = await startSpiderProcess();
      handle.verifyConsoleError(ConsoleMessages.invalidConfigFile);
    });

    test('empty yml config file test', () async {
      File('spider.yml').createSync();
      final handle = await startSpiderProcess();
      handle.verifyConsoleError(ConsoleMessages.invalidConfigFile);
    });

    test('empty json config file test', () async {
      File('spider.json').writeAsStringSync('{}');
      final handle = await startSpiderProcess();
      handle.verifyConsoleError(ConsoleMessages.invalidConfigFile);
    });

    test('invalid json config file test', () async {
      File('spider.json').createSync();
      final handle = await startSpiderProcess();
      handle.verifyConsoleError(ConsoleMessages.parseError);
    });

    test('valid config file test', () async {
      createTestConfigs(testConfig);
      createTestAssets();
      final config = parseConfig('');
      expect(config, isNotNull,
          reason: 'valid config file should not return null but it did.');

      expect(config!.groups, isNotEmpty);
      expect(config.groups.length, testConfig['groups'].length);
      expect(config.globals.generateTests, testConfig['generate_tests']);
      expect(config.globals.noComments, testConfig['no_comments']);
      expect(config.globals.export, testConfig['export']);
      expect(config.globals.usePartOf, testConfig['use_part_of']);
      expect(config.globals.package, testConfig['package']);

      addTearDown(() => deleteTestAssets());
    });

    tearDown(() {
      deleteConfigFiles();
    });
  });

  group('validateConfigs tests', () {
    test('config with no groups test', () async {
      createTestConfigs(testConfig.except('groups'));
      final handle = await startSpiderProcess();
      handle.verifyConsoleError(ConsoleMessages.noGroupsFound);
    });

    test('config with no groups test', () async {
      createTestConfigs(testConfig.copyWith({
        'groups': true, // invalid group type.
      }));
      final handle = await startSpiderProcess();
      handle.verifyConsoleError(ConsoleMessages.invalidGroupsType);
    });

    test('config group with null data test', () async {
      createTestConfigs(testConfig.copyWith({
        'groups': [
          {
            "path": null, // null data
            "class_name": "Assets",
            "types": ["jpg", "jpeg", "png", "webp", "gif", "bmp", "wbmp"]
          }
        ],
      }));
      final handle = await startSpiderProcess();
      handle.verifyConsoleError(
          sprintf(ConsoleMessages.nullValueError, ['path']));
    });

    test('config group with no path test', () async {
      createTestConfigs(testConfig.copyWith({
        'groups': [
          {
            "class_name": "Assets",
            "types": ["jpg", "jpeg", "png", "webp", "gif", "bmp", "wbmp"]
          }
        ],
      }));
      final handle = await startSpiderProcess();
      handle.verifyConsoleError(ConsoleMessages.noPathInGroupError);
    });

    test('config group path with wildcard test', () async {
      createTestConfigs(testConfig.copyWith({
        'groups': [
          {
            "path": "assets/*",
            "class_name": "Assets",
            "types": ["jpg", "jpeg", "png", "webp", "gif", "bmp", "wbmp"]
          }
        ],
      }));
      final handle = await startSpiderProcess();
      handle.verifyConsoleError(
          sprintf(ConsoleMessages.noWildcardInPathError, ['assets/*']));
    });

    test('config group with non-existent path test', () async {
      createTestConfigs(testConfig.copyWith({
        'groups': [
          {
            "path": "assets/fonts",
            "class_name": "Assets",
            "types": ["jpg", "jpeg", "png", "webp", "gif", "bmp", "wbmp"]
          }
        ],
      }));
      final handle = await startSpiderProcess();
      handle.verifyConsoleError(
          sprintf(ConsoleMessages.pathNotExistsError, ['assets/fonts']));
    });

    test('config group path with invalid directory test', () async {
      createTestConfigs(testConfig.copyWith({
        'groups': [
          {
            "path": "assets/images/test1.png",
            "class_name": "Assets",
            "types": ["jpg", "jpeg", "png", "webp", "gif", "bmp", "wbmp"]
          }
        ],
      }));
      createTestAssets();
      final handle = await startSpiderProcess();
      handle.verifyConsoleError(sprintf(
          ConsoleMessages.pathNotExistsError, ['assets/images/test1.png']));
    });

    test('config group with class name null test', () async {
      createTestConfigs(testConfig.copyWith({
        'groups': [
          {
            "path": "assets/images",
            "types": ["jpg", "jpeg", "png", "webp", "gif", "bmp", "wbmp"]
          }
        ],
      }));
      createTestAssets();
      final handle = await startSpiderProcess();
      handle.verifyConsoleError(ConsoleMessages.noClassNameError);
    });

    test('config group with empty class name test', () async {
      createTestConfigs(testConfig.copyWith({
        'groups': [
          {
            "path": "assets/images",
            "class_name": "   ",
            "types": ["jpg", "jpeg", "png", "webp", "gif", "bmp", "wbmp"]
          }
        ],
      }));
      createTestAssets();
      final handle = await startSpiderProcess();
      handle.verifyConsoleError(ConsoleMessages.emptyClassNameError);
    });

    test('config group with invalid class name test', () async {
      createTestConfigs(testConfig.copyWith({
        'groups': [
          {
            "path": "assets/images",
            "class_name": "My Assets",
            "types": ["jpg", "jpeg", "png", "webp", "gif", "bmp", "wbmp"]
          }
        ],
      }));
      createTestAssets();
      final handle = await startSpiderProcess();
      handle.verifyConsoleError(ConsoleMessages.classNameContainsSpacesError);
    });

    test('config group with invalid paths data test', () async {
      createTestConfigs(testConfig.copyWith({
        'groups': [
          {
            "paths": "assets/images",
            "class_name": "Assets",
            "types": ["jpg", "jpeg", "png", "webp", "gif", "bmp", "wbmp"]
          }
        ],
      }));
      createTestAssets();
      final handle = await startSpiderProcess();
      handle.verifyConsoleError(ConsoleMessages.configValidationFailed);
    });

    tearDown(() {
      deleteConfigFiles();
      deleteTestAssets();
    });
  });
}
