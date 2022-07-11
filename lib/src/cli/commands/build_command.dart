import 'package:args/args.dart';

import '../../../spider.dart';
import '../models/spider_config.dart';
import '../models/command_names.dart';
import '../models/flag_names.dart';
import '../utils/utils.dart';
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
  }

  @override
  Future<void> run() async {
    if (isFlutterProject()) {
      exitWith(ConsoleMessages.notFlutterProjectError);
      return;
    }

    final ArgResults results = argResults!;

    final Result<SpiderConfiguration> result = retrieveConfigs(results);
    if (result.isSuccess) {
      final spider = Spider(result.data);
      spider.build(
        watch: results.getFlag(FlagNames.watch),
        smartWatch: results.getFlag(FlagNames.watch),
      );
    } else {
      if (result.exception != null) verbose(result.exception.toString());
      if (result.stacktrace != null) verbose(result.stacktrace.toString());
      exitWith(result.error);
    }
  }
}
