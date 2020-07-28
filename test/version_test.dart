import 'dart:io';

import 'package:spider/src/version.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  test('checks for embedded version to match with pubspec version̥', () {
    final pubspec = loadYaml(File('pubspec.yaml').readAsStringSync());
    expect(pubspec['version'].toString(), packageVersion);
  });
}
