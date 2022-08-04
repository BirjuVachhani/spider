// Copyright © 2020 Birju Vachhani. All rights reserved.
// Use of this source code is governed by an Apache license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:sprintf/sprintf.dart';

import 'base_command_runner.dart';
import 'models/flag_names.dart';
import 'registry.dart';
import 'utils/utils.dart';

/// Entry point for all the command process.
class CliRunner extends BaseCommandRunner<void> {
  late final BaseLogger _logger;

  /// Default constructor.
  /// [output] is the output sink for logging.
  /// [errorSink] is the error sink for logging errors and exceptions.
  /// [logger] is if provided, will be used for logging. If not provided then
  /// a [ConsoleLogger] will be created using [output] and [errorSink].
  CliRunner([IOSink? output, IOSink? errorSink, BaseLogger? logger])
      : super('spider',
            'A command line tool for generating dart asset references.') {
    // Create logger for CLI.
    _logger = logger ?? ConsoleLogger(output: output, errorSink: errorSink);

    // Add all the commands from registry.
    commandsCreatorRegistry.values
        .map((creator) => creator(_logger))
        .forEach(addCommand);

    // Add all the top-level flag commands from registry.
    flagCommandsCreatorRegistry.values
        .map((creator) => creator(_logger))
        .forEach(addFlagCommand);

    // Top-level flags and options
    argParser
      ..addFlag(FlagNames.verbose,
          /*abbr: 'v', */ negatable: false, help: 'Increase logging.')
      ..addOption(OptionNames.path,
          abbr: 'p',
          help: 'Path of the config file if it is not in the root directory '
              'of the project.');
  }

  @override
  Future<void> run(Iterable<String> args) async {
    try {
      await super.run(args);
    } on UsageException catch (e) {
      _logger
        ..error(e.message)
        ..info(e.usage);

      exit(64);
    } on Exception catch (e, stacktrace) {
      _logger.error(sprintf(ConsoleMessages.exitedUnexpectedly, [e.toString()]),
          stacktrace);
      exit(1);
    }
  }

  @override
  Future<void> runCommand(ArgResults topLevelResults) async {
    /// Set level for logging.
    _logger.setLogLevel(topLevelResults.getFlag(FlagNames.verbose)
        ? LogLevel.verbose
        : LogLevel.info);
    return super.runCommand(topLevelResults);
  }
}
