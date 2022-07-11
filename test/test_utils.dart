import 'dart:convert';
import 'dart:io';

import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as p;
import 'package:spider/src/cli/process_terminator.dart';
import 'package:spider/src/cli/utils/utils.dart';

void deleteConfigFiles() {
  if (File('spider.json').existsSync()) {
    File('spider.json').deleteSync();
  }
  if (File('spider.yaml').existsSync()) {
    File('spider.yaml').deleteSync();
  }
  if (File('spider.yml').existsSync()) {
    File('spider.yml').deleteSync();
  }
}

void createTestConfigs(Map<String, dynamic> config) {
  File('spider.json')
      .writeAsStringSync(JsonEncoder.withIndent(' ').convert(config));
}

void createTestAssets() {
  File(p.join('assets', 'images', 'test1.png')).createSync(recursive: true);
  File(p.join('assets', 'images', 'test2.jpg')).createSync(recursive: true);
  File(p.join('assets', 'images', 'test3.unknown')).createSync(recursive: true);
  File(p.join('assets', 'images2x', 'test1.png')).createSync(recursive: true);

  File(p.join('assets', 'svgsMenu', 'test4.svg')).createSync(recursive: true);
  File(p.join('assets', 'svgsOther', 'test5.ttf')).createSync(recursive: true);
  File(p.join('assets', 'svgsOther', 'test6.svg')).createSync(recursive: true);
  File(p.join('assets', 'svgsMenu2x', 'test4.svg')).createSync(recursive: true);

  File(p.join('assets', 'icons', 'test8.ico')).createSync(recursive: true);
  File(p.join('assets', 'icons', 'test9.ttf')).createSync(recursive: true);
  File(p.join('assets', 'icons', 'test10.pdf')).createSync(recursive: true);
  File(p.join('assets', 'iconsPng', 'test8.ico')).createSync(recursive: true);
  File(p.join('assets', 'vectors', 'test11.ico')).createSync(recursive: true);

  File(p.join('assets', 'movies', 'test12.mp4')).createSync(recursive: true);
  File(p.join('assets', 'movies', 'test13.mp4')).createSync(recursive: true);
  File(p.join('assets', 'moviesExtra', 'test14.mp4'))
      .createSync(recursive: true);
  File(p.join('assets', 'moviesExtra', 'test15.mp4'))
      .createSync(recursive: true);
  File(p.join('assets', 'moviesOnly', 'test16.mp4'))
      .createSync(recursive: true);
  File(p.join('assets', 'moviesOnly', 'test17.ico'))
      .createSync(recursive: true);
}

void createMoreTestAssets() {
  File(p.join('assets', 'fonts', 'test1.otf')).createSync(recursive: true);
  File(p.join('assets', 'fonts', 'test2.otf')).createSync(recursive: true);
  File(p.join('assets', 'fonts', 'test3.otf')).createSync(recursive: true);
}

void deleteTestAssets() {
  if (Directory('assets').existsSync()) {
    Directory('assets').deleteSync(recursive: true);
  }
}

void deleteGeneratedRefs() {
  if (Directory(p.join('lib', 'resources')).existsSync()) {
    Directory(p.join('lib', 'resources')).deleteSync(recursive: true);
  }
}

extension MapExt<K, V> on Map<K, V> {
  Map<K, V> without(List<K> keys) {
    final Map<K, V> newMap = Map.from(this);
    for (final key in keys) {
      newMap.remove(key);
    }
    return newMap;
  }

  Map<K, V> except(K key) => Map.from(this)..remove(key);

  Map<K, V> copyWith(Map<K, V> other) => Map.from(this)..addAll(other);
}

class MockProcessTerminator extends Mock implements ProcessTerminator {
  @override
  void terminate(String? message, dynamic stackTrace, [BaseLogger? logger]) =>
      super.noSuchMethod(
          Invocation.method(#terminate, [message, stackTrace, logger]),
          returnValueForMissingStub: null);
}
