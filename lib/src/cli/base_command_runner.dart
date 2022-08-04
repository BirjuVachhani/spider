// Copyright © 2020 Birju Vachhani. All rights reserved.
// Use of this source code is governed by an Apache license that can be
// found in the LICENSE file.

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import 'flag_commands/flag_commands.dart';
import 'models/flag_names.dart';
import 'utils/utils.dart';

/// A base [CommandRunner] that add capabilities to handle top level flags
/// as commands.
abstract class BaseCommandRunner<T> extends CommandRunner<T> {
  /// This is a list of all flags that are top-level flags and does not need
  /// be specified on a command to be executed and are only meant to be
  /// used on the main executable itself. Since these flags can execute on
  /// their own, they are like commands.
  /// e.g. --version, --check-updates, etc.
  final List<FlagCommand> flagCommands = [];

  /// Default constructor.
  /// [executableName] is the name of the executable for this CLI.
  /// [description] should be information about the CLI executable and its
  /// parameters and sub commands.
  BaseCommandRunner(super.executableName, super.description);

  /// Adds a top-level flag command to the list of top-level flag commands and
  /// registers it as a flag on the parser.
  /// If a command is already registered with the same name, it will be ignored.
  void addFlagCommand(BaseFlagCommand command) {
    if (flagCommands.firstWhereOrNull((item) => item.name == command.name) !=
        null) return;
    flagCommands.add(command);
    argParser.addFlag(
      command.name,
      abbr: command.abbr,
      defaultsTo: command.defaultsTo,
      negatable: command.negatable,
      help: command.help,
      aliases: command.aliases,
    );
  }

  @override
  @mustCallSuper
  Future<T?> runCommand(ArgResults topLevelResults) async {
    // Flag commands are top level flags that work without a command. So we
    // only check for them if we don't have a command. We also check if help
    // flag is specified or not. If help flag is specified, we don't want to
    // run any flag commands.
    if (!topLevelResults.hasCommand &&
        !topLevelResults.getFlag(FlagNames.help)) {
      // Find first flag command and run it if found.
      final String? flagCommandName = topLevelResults.passedFlags
          .firstWhereOrNull((flag) => flagCommands.hasFlag(flag));
      if (flagCommandName != null) {
        final flagCommand = flagCommands.findByName(flagCommandName)!;
        return await flagCommand.run();
      }
    }

    return super.runCommand(topLevelResults);
  }
}
