// Copyright © 2020 Birju Vachhani. All rights reserved.
// Use of this source code is governed by an Apache license that can be
// found in the LICENSE file.

import 'package:args/args.dart';
import 'package:sprintf/sprintf.dart';

import '../../../spider.dart';
import '../flag_commands/flag_commands.dart';
import '../models/command_names.dart';
import '../models/flag_names.dart';
import '../models/spider_config.dart';
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

  /// Default constructor for build command.
  /// [logger] is used to output all kinds of logs, errors and exceptions.
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
              "that doesn't fall under the group configuration.")
      ..addFlag(FlagNames.fontsOnly,
          negatable: false,
          help: "Only triggers code-gen for fonts when fonts is set in "
              "config file.");
  }

  @override
  Future<void> run() async {
    if (!isFlutterProject()) {
      exitWith(ConsoleMessages.notFlutterProjectError);
      return;
    }

    final ArgResults results = argResults!;

    // Check for updates.
    await CheckUpdatesFlagCommand.checkForNewVersion(logger);

    final Result<SpiderConfiguration> result = retrieveConfigs(
      customPath: globalResults!['path'],
      logger: logger,
      allowEmpty: true,
      fontsOnly: results.getFlag(FlagNames.fontsOnly),
    );
    if (result.isSuccess) {
      if (results.getFlag(FlagNames.fontsOnly)) {
        // if fonts-only flag is provided and fonts is not set in
        // config then exit with error.
        if (!result.data.globals.fontConfigs.generate) {
          exitWith(sprintf(ConsoleMessages.fontsOnlyExecutedWithoutSetTemplate,
              [FlagNames.fontsOnly]));
          return;
        }
      } else if (result.data.groups.isEmpty &&
          !result.data.globals.fontConfigs.generate) {
        // If fonts-only flag is not set and no groups are provided too then
        // exit with error.
        exitWith(ConsoleMessages.nothingToGenerate);
        return;
      }

      final spider = Spider(result.data);
      spider.build(
        watch: results.getFlag(FlagNames.watch),
        smartWatch: results.getFlag(FlagNames.watch),
        fontsOnly: results.getFlag(FlagNames.fontsOnly),
        logger: logger,
      );
    } else {
      if (result.exception != null) verbose(result.exception.toString());
      if (result.stacktrace != null) verbose(result.stacktrace.toString());
      exitWith(result.error);
    }
  }
}
