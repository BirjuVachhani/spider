import 'dart:convert';

import 'dart:io';

import 'package:test/expect.dart';

// Future<ProcessAccess> startSpiderProcess(
//     [String? workingDirectory, String? executablePath]) async {
//   final process = await Process.start(
//       'dart', [executablePath ?? 'bin/main.dart', 'build'],
//       workingDirectory: workingDirectory);
//   final lineStream = process.stdout
//       .transform(Utf8Decoder())
//       .transform(LineSplitter())
//       .asBroadcastStream();
//   return ProcessAccess(process, lineStream, process.stdin);
// }
//
// class ProcessAccess {
//   final Process process;
//   final Stream<String> outputStream;
//   final IOSink inputSink;
//
//   ProcessAccess(this.process, this.outputStream, this.inputSink);
//
//   void input(Object data) {
//     process.stdin.write(data);
//   }
//
//   void inputLine(Object data) {
//     process.stdin.writeln(data);
//   }
//
//   verifyConsoleError(String error, {bool done = true}) {
//     expect(
//         outputStream,
//         emitsInOrder([
//           contains(error),
//           if (done) emitsDone,
//         ]));
//     expect(process.exitCode, completion(equals(2)));
//   }
// }

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
  File('assets/images/test1.png').createSync(recursive: true);
  File('assets/images/test2.png').createSync(recursive: true);
  File('assets/images/test3.unknown').createSync(recursive: true);
  File('assets/images2x/test1.png').createSync(recursive: true);
}

void deleteTestAssets() {
  if (Directory('assets').existsSync()) {
    Directory('assets').deleteSync(recursive: true);
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
