// Author: Birju Vachhani
// Created Date: August 20, 2020

import 'dart:io';

import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as p;
import 'package:spider/spider.dart';
import 'package:spider/src/cli/config_retriever.dart';
import 'package:spider/src/process_terminator.dart';
import 'package:test/test.dart';

import 'test_utils.dart';

void main() {
  final MockProcessTerminator processTerminatorMock = MockProcessTerminator();
  const Map<String, dynamic> testConfig = {
    "generate_tests": false,
    "no_comments": true,
    "export": true,
    "use_part_of": false,
    "use_references_list": true,
    "package": "resources",
    "groups": [
      {
        "class_name": "Assets",
        "subgroups": [
          {
            "path": "assets/images",
            "types": ["jpg"],
            "prefix": "jpg"
          },
          {
            "path": "assets/images",
            "types": ["png"],
            "prefix": "png"
          }
        ]
      }
    ]
  };

  test('create config test test', () {
    Spider.createConfigs(isJson: true);
    expect(File('spider.json').existsSync(), true);
    File('spider.json').deleteSync();

    Spider.createConfigs(isJson: false);
    expect(File('spider.yaml').existsSync(), true);
    File('spider.yaml').deleteSync();
  });

  test('exportAsLibrary tests', () {
    // Spider.exportAsLibrary();
    // TODO: add test if possible.
  });

  group('Spider tests', () {
    setUp(() {
      ProcessTerminator.setMock(processTerminatorMock);
      deleteConfigFiles();
    });

    test('asset generation test on spider', () async {
      Spider.createConfigs(isJson: false);
      createTestAssets();

      final spider = Spider(retrieveConfigs()!);
      verifyNever(processTerminatorMock.terminate(any, any));

      spider.build();

      final genFile = File(p.join('lib', 'resources', 'images.dart'));
      expect(genFile.existsSync(), isTrue);

      addTearDown(() {
        File(p.join('test', 'images_test.dart')).deleteSync();
      });

      final classContent = genFile.readAsStringSync();

      expect(classContent, contains('class Images'));
      expect(classContent, contains('static const String pngTest1'));
      expect(classContent, contains('static const String jpgTest2'));
      expect(classContent, contains('assets/images/test1.png'));
      expect(classContent, contains('assets/images/test2.jpg'));

      final exportFile = File(p.join('lib', 'resources', 'resources.dart'));
      expect(genFile.existsSync(), isTrue);
      final exportContent = exportFile.readAsStringSync();
      expect(exportContent, contains("part 'images.dart';"));
    });

    test('asset generation test with library export on spider', () async {
      createTestConfigs(testConfig);
      createTestAssets();

      final spider = Spider(retrieveConfigs()!);

      verifyNever(processTerminatorMock.terminate(any, any));

      spider.build();

      final genFile = File(p.join('lib', 'resources', 'assets.dart'));
      expect(genFile.existsSync(), isTrue);

      final classContent = genFile.readAsStringSync();

      expect(classContent, contains('class Assets'));
      expect(classContent, contains('static const String pngTest1'));
      expect(classContent, contains('static const String jpgTest2'));
      expect(classContent, contains('assets/images/test1.png'));
      expect(classContent, contains('assets/images/test2.jpg'));

      final exportFile = File(p.join('lib', 'resources', 'resources.dart'));
      expect(genFile.existsSync(), isTrue);
      final exportContent = exportFile.readAsStringSync();
      expect(exportContent, contains("export 'assets.dart';"));
    });

    tearDown(() {
      ProcessTerminator.clearMock();
      reset(processTerminatorMock);
      deleteTestAssets();
      deleteConfigFiles();
      deleteGeneratedRefs();
    });
  });
}
