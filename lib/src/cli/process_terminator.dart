import 'dart:io';

import 'package:meta/meta.dart';

import 'utils/utils.dart';

/// A Singleton helper class that has functionality of terminating the process.
/// This allows to override the termination behavior which is kind useful for
/// testing. It can also be useful in places where it is not being executed
/// from the command line.
class ProcessTerminator {
  static ProcessTerminator? _instance;

  const ProcessTerminator._();

  /// Returns the singleton instance of this class.
  factory ProcessTerminator.getInstance() {
    _instance ??= ProcessTerminator._();
    return _instance!;
  }

  @visibleForTesting

  /// Allows to set mocked instance for testing.
  static setMock(ProcessTerminator? mock) => _instance = mock;

  @visibleForTesting

  /// Removes stored mock instance in testing.
  static clearMock() => _instance = null;

  /// Terminates the process.
  /// [message] will be printed via [logger] as an error message
  /// before termination.
  /// [stacktrace] if provided will also be printed via [logger].
  void terminate(String message, dynamic stackTrace, [BaseLogger? logger]) {
    logger?.error(message, stackTrace);
    exitCode = 2;
    exit(2);
  }
}
