// Copyright © 2020 Birju Vachhani. All rights reserved.
// Use of this source code is governed by an Apache license that can be
// found in the LICENSE file.

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
    expect(Formatter.formatName('test-case-with some_word'),
        'testCaseWithSomeWord');
    expect(
        Formatter.formatName('test_case', useUnderScores: true), 'test_case');
    expect(
        Formatter.formatName('test case', useUnderScores: true), 'test_case');
    expect(
        Formatter.formatName('Test Case', useUnderScores: true), 'test_case');
    expect(
        Formatter.formatName('__Test Case', useUnderScores: true), 'test_case');
    expect(
        Formatter.formatName('Test   Case', useUnderScores: true), 'test_case');
    expect(
        Formatter.formatName('Test@)(Case', useUnderScores: true), 'test_case');
    expect(Formatter.formatName('TestCase', useUnderScores: true), 'test_case');
    expect(
        Formatter.formatName('test-case-with some_word', useUnderScores: true),
        'test_case_with_some_word');
  });

  test('format path test', () {
    expect(Formatter.formatPath('assets\\abc.png'), 'assets/abc.png');
    expect(Formatter.formatPath('assets/temp.png'), 'assets/temp.png');
    expect(
        Formatter.formatPath('assets/temp/temp.png'), 'assets/temp/temp.png');
    expect(
        Formatter.formatPath('assets\\temp\\temp.png'), 'assets/temp/temp.png');
  });

  test('format file name tests', () {
    expect(Formatter.formatFileName('Images'), 'images.dart');
  });
}
