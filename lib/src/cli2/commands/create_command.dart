import '../models/command_names.dart';
import '../models/flag_names.dart';
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

  CreateCommand(super.logger) {
    argParser
      ..addFlag(FlagNames.addInPubspec,
          negatable: false,
          help: 'Adds the generated config file to the pubspec.yaml file.')
      ..addFlag(FlagNames.json,
          abbr: 'j',
          negatable: false,
          help: 'Generates config file of type JSON rather than YAML.')
      ..addOption(FlagNames.path,
          abbr: 'p',
          help: 'Allows to provide custom directory path for the config file.');
  }

  @override
  Future<void> run() async {
    // TODO:
  }
}
