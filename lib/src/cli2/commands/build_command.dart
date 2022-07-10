import '../models/command_names.dart';
import '../models/flag_names.dart';
import 'base_command.dart';

/// Build command to execute code generation for assets.
class BuildCommand extends BaseCommand {
  @override
  String get description =>
      "Generates dart code for assets of your flutter project. 'spider.yaml' "
      "file is used by this command to generate dart code.";

  @override
  String get name => CommandNames.build;

  @override
  String get summary =>
      'Generates dart code for assets of your flutter project.';

  BuildCommand(super.logger) {
    argParser
      ..addFlag(FlagNames.watch,
          negatable: false,
          help: 'Watches assets directory for file changes and re-generates '
              'dart references upon file creation, deletion or modification.')
      ..addFlag(FlagNames.smartWatch,
          negatable: false,
          help: "Smartly watches assets directory for file changes and "
              "re-generates dart references by ignoring events and files "
              "that doesn't fall under the group configuration.");
    // ..addFlag('verbose',
    //     abbr: 'v', negatable: false, help: 'Increase logging.');
  }

  @override
  Future<void> run() async {
    // TODO:
  }
}
