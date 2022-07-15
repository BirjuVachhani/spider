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
        "class_name": "Images",
        "path": "assets/images",
        "types": [".png", ".jpg", ".jpeg", ".webp", ".webm", ".bmp"]
      },
      {
        "class_name": "Svgs",
        "sub_groups": [
          {
            "path": "assets/svgsMenu",
            "prefix": "menu",
            "types": [".svg"]
          },
          {
            "path": "assets/svgsOther",
            "prefix": "other",
            "types": [".svg"]
          }
        ]
      },
      {
        "class_name": "Ico",
        "types": [".ico"],
        "prefix": "ico",
        "sub_groups": [
          {
            "path": "assets/icons",
            "prefix": "test1",
            "types": [".ttf"]
          },
          {
            "path": "assets/vectors",
            "prefix": "test2",
            "types": [".pdf"]
          }
        ]
      },
      {
        "class_name": "Video",
        "types": [".mp4"],
        "path": "assets/moviesOnly",
        "sub_groups": [
          {"path": "assets/movies", "prefix": "common"},
          {"path": "assets/moviesExtra", "prefix": "extra"}
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

      final genFile1 =
          File(p.join('lib', 'resources', 'images', 'images.dart'));
      expect(genFile1.existsSync(), isTrue);
      final genFile2 = File(p.join('lib', 'resources', 'svgs', 'svgs.dart'));
      expect(genFile2.existsSync(), isTrue);
      final genFile3 = File(p.join('lib', 'resources', 'ico', 'ico.dart'));
      expect(genFile3.existsSync(), isTrue);
      final genFile4 = File(p.join('lib', 'resources', 'video.dart'));
      expect(genFile4.existsSync(), isTrue);

      addTearDown(() {
        File(p.join('test', 'images_test.dart')).deleteSync();
      });
      addTearDown(() {
        File(p.join('test', 'svgs_test.dart')).deleteSync();
      });
      addTearDown(() {
        File(p.join('test', 'ico_test.dart')).deleteSync();
      });
      addTearDown(() {
        File(p.join('test', 'video_test.dart')).deleteSync();
      });

      final classContent1 = genFile1.readAsStringSync();
      final classContent2 = genFile2.readAsStringSync();
      final classContent3 = genFile3.readAsStringSync();
      final classContent4 = genFile4.readAsStringSync();

      expect(
          classContent1,
          contains(
            '// ignore_for_file: public_member_api_docs, member-ordering-extended, test_rule',
          ));
      expect(classContent1, contains('class Images'));
      expect(classContent1, contains('static const String test1'));
      expect(classContent1, contains('static const String test2'));
      expect(classContent1, contains('assets/images/test1.png'));
      expect(classContent1, contains('assets/images/test2.jpg'));

      expect(classContent2, contains('class Svgs'));
      expect(classContent2, contains('static const String menuTest4'));
      expect(classContent2, contains('static const String otherTest6'));
      expect(classContent2, contains('assets/svgsMenu/test4.svg'));
      expect(classContent2, contains('assets/svgsOther/test6.svg'));

      expect(classContent3, contains('class Ico'));
      expect(classContent3, contains('static const String icoTest8'));
      expect(classContent3, contains('static const String icoTest11'));
      expect(classContent3, contains('assets/icons/test8.ico'));
      expect(classContent3, contains('assets/vectors/test11.ico'));

      expect(classContent4, contains('class Video'));
      expect(classContent4, contains('static const String test16'));
      expect(classContent4, contains('assets/moviesOnly/test16.mp4'));

      final exportFile = File(p.join('lib', 'resources', 'resources.dart'));
      expect(exportFile.existsSync(), isTrue);
      final exportContent = exportFile.readAsStringSync();

      expect(exportContent,
          contains("part 'package:spider/resources/images/images.dart';"));
      expect(exportContent,
          contains("part 'package:spider/resources/svgs/svgs.dart';"));
      expect(exportContent,
          contains("part 'package:spider/resources/ico/ico.dart';"));
      expect(exportContent,
          contains("part 'package:spider/resources/video.dart';"));
    });

    test('asset generation test with library export on spider', () async {
      createTestConfigs(testConfig);
      createTestAssets();

      final spider = Spider(retrieveConfigs()!);

      verifyNever(processTerminatorMock.terminate(any, any));

      spider.build();

      final genFile1 = File(p.join('lib', 'resources', 'images.dart'));
      expect(genFile1.existsSync(), isTrue);
      final genFile2 = File(p.join('lib', 'resources', 'svgs.dart'));
      expect(genFile2.existsSync(), isTrue);
      final genFile3 = File(p.join('lib', 'resources', 'ico.dart'));
      expect(genFile3.existsSync(), isTrue);
      final genFile4 = File(p.join('lib', 'resources', 'video.dart'));
      expect(genFile4.existsSync(), isTrue);

      final classContent1 = genFile1.readAsStringSync();
      final classContent2 = genFile2.readAsStringSync();
      final classContent3 = genFile3.readAsStringSync();
      final classContent4 = genFile4.readAsStringSync();

      expect(classContent1, contains('class Images'));
      expect(classContent1, contains('static const String test1'));
      expect(classContent1, contains('static const String test2'));
      expect(classContent1, contains('assets/images/test1.png'));
      expect(classContent1, contains('assets/images/test2.jpg'));

      expect(classContent2, contains('class Svgs'));
      expect(classContent2, contains('static const String menuTest4'));
      expect(classContent2, contains('static const String otherTest6'));
      expect(classContent2, contains('assets/svgsMenu/test4.svg'));
      expect(classContent2, contains('assets/svgsOther/test6.svg'));

      expect(classContent3, contains('class Ico'));
      expect(classContent3, contains('static const String icoTest8'));
      expect(classContent3, contains('static const String icoTest11'));
      expect(classContent3, contains('assets/icons/test8.ico'));
      expect(classContent3, contains('assets/vectors/test11.ico'));

      expect(classContent4, contains('class Video'));
      expect(classContent4, contains('static const String test16'));
      expect(classContent4, contains('assets/moviesOnly/test16.mp4'));

      final exportFile = File(p.join('lib', 'resources', 'resources.dart'));
      expect(exportFile.existsSync(), isTrue);
      final exportContent = exportFile.readAsStringSync();
      expect(exportContent,
          contains("export 'package:spider/resources/images.dart';"));
      expect(exportContent,
          contains("export 'package:spider/resources/svgs.dart';"));
      expect(exportContent,
          contains("export 'package:spider/resources/ico.dart';"));
      expect(exportContent,
          contains("export 'package:spider/resources/video.dart';"));
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
