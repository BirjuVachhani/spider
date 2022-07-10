import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';

import 'base_command_runner.dart';
import 'models/flag_names.dart';
import 'registry.dart';
import 'utils/utils.dart';

class CliRunner extends BaseCommandRunner<void> {
  final IOSink _output;

  IOSink get output => _output;

  final IOSink _errorSink;

  IOSink get errorSink => _errorSink;

  late final BaseLogger _logger;

  CliRunner([IOSink? output, IOSink? errorSink, BaseLogger? logger])
      : _output = output ?? stdout,
        _errorSink = errorSink ?? stderr,
        super('spider',
            'A command line tool for generating dart asset references.') {
    // Create logger for CLI.
    _logger = logger ?? ConsoleLogger(output: _output, errorSink: _errorSink);

    // Add all the commands from registry.
    commandsCreatorRegistry.values
        .map((creator) => creator(_logger))
        .forEach(addCommand);

    // Add all the top-level flag commands from registry.
    flagCommandsCreatorRegistry.values
        .map((creator) => creator(_logger))
        .forEach(addFlagCommand);

    // Top-level flags and options
    argParser.addFlag(FlagNames.verbose,
        /*abbr: 'v', */ negatable: false, help: 'Increase logging.');
  }

  @override
  Future<void> run(Iterable<String> args) async {
    try {
      await super.run(args);
    } on UsageException catch (e) {
      _output
        ..writeln(e.message)
        ..writeln(e.usage);

      exit(64);
    } on Exception catch (e) {
      _output.writeln('Oops; spider has exited unexpectedly: "$e"');

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
