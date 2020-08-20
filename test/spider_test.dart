// Author: Birju Vachhani
// Created Date: August 20, 2020

import 'dart:io';

import 'package:spider/spider.dart';
import 'package:test/test.dart';

void main() {
  test('spider test', () {
    final spider = Spider('');
    expect(spider.config != null, true);
    spider.build();
  }, timeout: Timeout(Duration(minutes: 2)));

  test('create config test test', () {
    Spider.createConfigs(true);
    expect(File('spider.json').existsSync(), true);
    File('spider.json').deleteSync();

    Spider.createConfigs(false);
    expect(File('spider.yaml').existsSync(), true);
    File('spider.yaml').deleteSync();
  });
}
