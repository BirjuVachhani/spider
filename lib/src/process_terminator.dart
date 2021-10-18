import 'dart:io';

import 'package:meta/meta.dart';
import 'package:spider/src/utils.dart';

class ProcessTerminator {
  static ProcessTerminator? _instance;

  const ProcessTerminator._();

  factory ProcessTerminator.getInstance() {
    _instance ??= ProcessTerminator._();
    return _instance!;
  }

  @visibleForTesting
  static setMock(ProcessTerminator? mock) => _instance = mock;

  @visibleForTesting
  static clearMock() => _instance = null;

  void terminate(String message, dynamic stackTrace) {
    error(message, stackTrace);
    exitCode = 2;
    exit(2);
  }
}
