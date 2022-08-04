import 'package:args/args.dart';

import '../flag_commands/flag_commands.dart';
import '../models/command_names.dart';
import '../models/flag_names.dart';
import '../utils/utils.dart';
import 'base_command.dart';

/// Command to create a Spider configuration file.
class CreateCommand extends BaseCommand {
  @override
  String get description =>
      "creates 'spider.yaml' file in the current working directory. This "
      "config file is used to control and manage generation of the dart code.";

  @override
  String get name => CommandNames.create;

  @override
  String get summary => 'Creates config file in the root of the project.';

  /// Default constructor for create command.
  /// [logger] is used to output all kinds of logs, errors and exceptions.
  CreateCommand(super.logger) {
    argParser
      ..addFlag(FlagNames.addInPubspec,
          negatable: false,
          help: 'Adds the generated config file to the pubspec.yaml file.')
      ..addFlag(FlagNames.json,
          abbr: 'j',
          negatable: false,
          help: 'Generates config file of type JSON rather than YAML.')
      ..addOption(OptionNames.path,
          abbr: 'p',
          help: 'Allows to provide custom directory path for the config file.');
  }

  @override
  Future<void> run() async {
    final ArgResults results = argResults!;

    // Check for updates.
    await CheckUpdatesFlagCommand.checkForNewVersion(logger);

    final bool isJson = results.getFlag(FlagNames.json);
    final bool addInPubspec = results.getFlag(FlagNames.addInPubspec);
    final String? path = results[OptionNames.path];

    final result = ConfigCreator(logger)
        .create(addInPubspec: addInPubspec, isJson: isJson, path: path);

    if (result.isError) {
      if (result.exception != null) verbose(result.exception.toString());
      if (result.stacktrace != null) verbose(result.stacktrace.toString());
      exitWith(result.error);
    }
  }
}
