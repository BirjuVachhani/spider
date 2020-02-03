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

import 'package:spider/src/dart_class_generator.dart';
import 'package:test/test.dart';

/// runs all the test cases
void main() {
  test('format name test', () {
    var generator = DartClassGenerator(className: '', properties: {});
    expect(generator.formatName('test_case'), 'testCase');
    expect(generator.formatName('test case'), 'testCase');
    expect(generator.formatName('Test Case'), 'testCase');
    expect(generator.formatName('__Test Case'), 'testCase');
    expect(generator.formatName('Test   Case'), 'testCase');
    expect(generator.formatName('Test@)(Case'), 'testCase');
    expect(generator.formatName('TestCase'), 'testCase');
    expect(generator.formatName('test-case-with some_word'),
        'testCaseWithSomeWord');
    generator = DartClassGenerator(
        className: '', properties: {}, use_underscores: true);
    expect(generator.formatName('test_case'), 'test_case');
    expect(generator.formatName('test case'), 'test_case');
    expect(generator.formatName('Test Case'), 'test_case');
    expect(generator.formatName('__Test Case'), 'test_case');
    expect(generator.formatName('Test   Case'), 'test_case');
    expect(generator.formatName('Test@)(Case'), 'test_case');
    expect(generator.formatName('TestCase'), 'test_case');
    expect(generator.formatName('test-case-with some_word'),
        'test_case_with_some_word');
  });

  test('format path test', () {
    var generator = DartClassGenerator(className: '', properties: {});
    expect(generator.formatPath('assets\\abc.png'), 'assets/abc.png');
    expect(generator.formatPath('assets/temp.png'), 'assets/temp.png');
    expect(
        generator.formatPath('assets/temp/temp.png'), 'assets/temp/temp.png');
    expect(
        generator.formatPath('assets\\temp\\temp.png'), 'assets/temp/temp.png');
  });
}
