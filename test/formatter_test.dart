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
// Created Date: February 02, 2020

import 'package:spider/src/formatter.dart';
import 'package:test/test.dart';

/// runs all the test cases
void main() {
  test('format name test', () {
    expect(Formatter.formatName('test_case'), 'testCase');
    expect(Formatter.formatName('test case'), 'testCase');
    expect(Formatter.formatName('Test Case'), 'testCase');
    expect(Formatter.formatName('__Test Case'), 'testCase');
    expect(Formatter.formatName('Test   Case'), 'testCase');
    expect(Formatter.formatName('Test@)(Case'), 'testCase');
    expect(Formatter.formatName('TestCase'), 'testCase');
    expect(
      Formatter.formatName('test-case-with some_word'),
      'testCaseWithSomeWord',
    );
    expect(
      Formatter.formatName('test_case', useUnderScores: true),
      'test_case',
    );
    expect(
      Formatter.formatName('test case', useUnderScores: true),
      'test_case',
    );
    expect(
      Formatter.formatName('Test Case', useUnderScores: true),
      'test_case',
    );
    expect(
      Formatter.formatName('__Test Case', useUnderScores: true),
      'test_case',
    );
    expect(
      Formatter.formatName('Test   Case', useUnderScores: true),
      'test_case',
    );
    expect(
      Formatter.formatName('Test@)(Case', useUnderScores: true),
      'test_case',
    );
    expect(Formatter.formatName('TestCase', useUnderScores: true), 'test_case');
    expect(
      Formatter.formatName('test-case-with some_word', useUnderScores: true),
      'test_case_with_some_word',
    );
  });

  test('format path test', () {
    expect(Formatter.formatPath(r'assets\abc.png'), 'assets/abc.png');
    expect(Formatter.formatPath('assets/temp.png'), 'assets/temp.png');
    expect(
      Formatter.formatPath('assets/temp/temp.png'),
      'assets/temp/temp.png',
    );
    expect(
      Formatter.formatPath(r'assets\temp\temp.png'),
      'assets/temp/temp.png',
    );
  });

  test('format file name tests', () {
    expect(Formatter.formatFileName('Images'), 'images.dart');
  });
}
