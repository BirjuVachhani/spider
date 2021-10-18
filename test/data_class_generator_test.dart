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

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart' as analyzer;
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/src/dart/element/element.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as p;
import 'package:spider/src/dart_class_generator.dart';
import 'package:spider/src/process_terminator.dart';
import 'package:spider/src/utils.dart';
import 'package:test/test.dart';

import 'data_class_generator_test.mocks.dart';
import 'test_utils.dart';

@GenerateMocks([ProcessTerminator])
void main() {
  final MockProcessTerminator processTerminatorMock = MockProcessTerminator();
  const Map<String, dynamic> testConfig = {
    "generate_tests": false,
    "no_comments": true,
    "export": true,
    "use_part_of": false,
    "package": "resources",
    "groups": [
      {
        "path": "assets/images",
        "class_name": "Assets",
        "types": ["jpg", "jpeg", "png", "webp", "gif", "bmp", "wbmp"]
      }
    ]
  };

  group('process tests', () {
    setUp(() {
      ProcessTerminator.setMock(processTerminatorMock);
    });

    test('valid config file test', () async {
      createTestConfigs(testConfig);
      createTestAssets();
      var config = parseConfig('');
      expect(config, isNotNull,
          reason: 'valid config file should not return null but it did.');

      final generator =
          DartClassGenerator(config!.groups.first, config.globals);

      generator.process();
      verifyNever(processTerminatorMock.terminate(any, any));
      expect(Directory('lib/resources').existsSync(), isTrue);
      expect(Directory('lib/resources').listSync(), isNotEmpty);
      expect(File('lib/resources/assets.dart').existsSync(), isTrue);

      final ResolvedUnitResult result = await analyzer.resolveFile2(
          path: File(p.join('lib', 'resources', 'assets.dart'))
              .absolute
              .path) as ResolvedUnitResult;
      final ClassElement? parsedClass =
          result.unit.declaredElement?.classes.first;
      expect(parsedClass, isNotNull);
      expect(parsedClass!.displayName, equals('Assets'),
          reason: 'Generated class name should be Assets but it is not.');
      expect(parsedClass.constructors.first.isPrivate, isTrue,
          reason: 'Generated constructor should be private but it is not.');
      expect(parsedClass.hasStaticMember, isTrue);
      expect(parsedClass.fields, hasLength(2));
      expect(parsedClass.fields.every((element) => element.isStatic), isTrue,
          reason: 'all the generated fields should be static but it is not.');
      expect(parsedClass.fields.every((element) => element.isConst), isTrue,
          reason: 'all the generated fields should be const but it is not.');
      expect(parsedClass.fields.every((element) => element.isPublic), isTrue,
          reason: 'all the generated fields should be public but it is not.');
      expect(parsedClass.fields.map((e) => e.displayName),
          containsAll(['test1', 'test2']));
      final StringLiteral value1 =
          ((parsedClass.fields.first as ConstVariableElement)
              .constantInitializer as StringLiteral);
      final StringLiteral value2 =
          ((parsedClass.fields[1] as ConstVariableElement).constantInitializer
              as StringLiteral);
      expect(value1.stringValue, equals('assets/images/test1.png'),
          reason: 'asset path is not correct.');
      expect(value2.stringValue, equals('assets/images/test2.png'),
          reason: 'asset path is not correct.');
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
