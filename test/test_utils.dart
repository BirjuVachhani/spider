import 'dart:convert';
import 'dart:io';

import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as p;
import 'package:spider/src/process_terminator.dart';

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
  File(p.join('assets', 'images', 'test2.png')).createSync(recursive: true);
  File(p.join('assets', 'images', 'test3.unknown')).createSync(recursive: true);
  File(p.join('assets', 'images2x', 'test1.png')).createSync(recursive: true);
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
  void terminate(String? message, dynamic stackTrace) =>
      super.noSuchMethod(Invocation.method(#terminate, [message, stackTrace]),
          returnValueForMissingStub: null);
}
