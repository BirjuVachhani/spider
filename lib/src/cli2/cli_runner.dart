import 'dart:io';

import 'package:args/command_runner.dart';

import 'base_command_runner.dart';
import 'models/flag_names.dart';
import 'registry.dart';

class CliRunner extends BaseCommandRunner<void> {
  final IOSink _output;

  IOSink get output => _output;

  final IOSink _errorSink;

  IOSink get errorSink => _errorSink;

  CliRunner([IOSink? output, IOSink? errorSink])
      : _output = output ?? stdout,
        _errorSink = errorSink ?? stderr,
        super('spider',
            'A command line tool for generating dart asset references.') {
    // Add all the commands
    commandsCreatorRegistry.values
        .map((creator) => creator(_output, errorSink))
        .forEach(addCommand);
    flagCommandsCreatorRegistry.values
        .map((creator) => creator(_output, errorSink))
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
}
