import 'dart:io';

import 'package:logging/logging.dart';

import '../commands/commands.dart';
import '../flag_commands/flag_commands.dart';
import '../process_terminator.dart';

/// Custom error log level.
const Level errorLevel = Level('ERROR', 1100);

/// Custom success log level.
const Level successLevel = Level('SUCCESS', 1050);

/// Custom verbose log level.
const Level verboseLevel = Level('DEBUG', 600);

/// Represents logging level for [BaseLogger].
enum LogLevel {
  verbose,
  info,
  warning,
  error,
  success,
  none,
}

/// A base class for logging. [BaseCommand] and [BaseFlagCommand] has an
/// instance of this class as a member for logging outputs/errors to the console.
abstract class BaseLogger {
  final IOSink output;
  final IOSink errorSink;

  const BaseLogger({required this.output, required this.errorSink});

  /// Logs given [msg] as an error to the console. [stackTrace] gets logged as
  /// well if provided.
  void error(String msg, [StackTrace? stackTrace]);

  /// Logs given [msg] at info level to the console.
  void info(String msg);

  /// Logs given [msg] at warning level to the console.
  void warning(String msg);

  /// Logs given [msg] at verbose level to the console.
  void verbose(String msg);

  /// Logs given [msg] at success level to the console.
  void success(String msg);

  /// Logs given [msg] using [output] sink directly without any formatting.
  /// Useful for raw printing.
  void log(String msg);

  /// Allows to set the log level.
  void setLogLevel(LogLevel level);

  /// Should log given [msg] as an error to the console and
  /// indicate termination of the process unlike [error] method.
  /// [stackTrace] gets logged as well if provided.
  void exitWith(String msg, [StackTrace? stackTrace]);
}

/// A CLI logger that logs to the console.
class ConsoleLogger extends BaseLogger {
  final Logger logger;

  ConsoleLogger({
    IOSink? output,
    IOSink? errorSink,
    Logger? logger,
  })  : logger = logger ?? Logger('spider-console'),
        super(output: output ?? stdout, errorSink: errorSink ?? stderr) {
    setupLogging();
  }

  /// sets up logging for stacktrace and logs.
  void setupLogging() {
    Logger.root.level = Level.INFO; // defaults to Level.INFO
    recordStackTraceAtLevel = Level.ALL;
    Logger.root.onRecord.listen((record) {
      if (record.level == Level.SEVERE) {
        // TODO: Add support for colored output.
        stderr.writeln('[${record.level.name}] ${record.message}');
      } else {
        stdout.writeln('[${record.level.name}] ${record.message}');
      }
    });
  }

  @override
  void error(String msg, [StackTrace? stackTrace]) =>
      logger.log(errorLevel, msg, null, stackTrace);

  @override
  void info(String msg) => logger.info(msg);

  @override
  void warning(String msg) => logger.warning(msg);

  @override
  void verbose(String msg) => logger.log(Level('DEBUG', 600), msg);

  @override
  void success(String msg) => logger.log(successLevel, msg);

  @override
  void log(String msg) => output.writeln(msg);

  @override
  void setLogLevel(LogLevel level) => Logger.root.level = toLevel(level);

  /// exits process with a message on command-line
  @override
  void exitWith(String msg, [StackTrace? stackTrace]) {
    ProcessTerminator.getInstance().terminate(msg, stackTrace, this);
  }

  /// Converts [LogLevel] to [Level].
  Level toLevel(LogLevel level) {
    switch (level) {
      case LogLevel.verbose:
        return verboseLevel;
      case LogLevel.info:
        return Level.INFO;
      case LogLevel.warning:
        return Level.WARNING;
      case LogLevel.error:
        return errorLevel;
      case LogLevel.success:
        return successLevel;
      case LogLevel.none:
        return Level.OFF;
    }
  }
}

/// A logging mixin used on Commands for easy logging.
mixin LoggingMixin {
  /// A logger for logging outputs/errors..
  abstract final BaseLogger logger;

  /// Delegation method for [BaseLogger.error].
  void error(String msg, [StackTrace? stackTrace]) =>
      logger.error(msg, stackTrace);

  /// Delegation method for [BaseLogger.info].
  void info(String msg) => logger.info(msg);

  /// Delegation method for [BaseLogger.warning].
  void warning(String msg) => logger.warning(msg);

  /// Delegation method for [BaseLogger.verbose].
  void verbose(String msg) => logger.verbose(msg);

  /// Delegation method for [BaseLogger.success].
  void success(String msg) => logger.success(msg);

  /// Delegation method for [BaseLogger.log].
  void log(String msg) => logger.log(msg);

  /// Delegation method for [BaseLogger.exitWith].
  void exitWith(String msg, [StackTrace? stackTrace]) =>
      logger.exitWith(msg, stackTrace);
}
