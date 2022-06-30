import 'dart:io';

import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:spider/spider.dart';
import 'package:spider/src/cli/config_retriever.dart';
import 'package:spider/src/constants.dart';
import 'package:spider/src/help_manuals.dart';
import 'package:spider/src/utils.dart';
import 'package:spider/src/version.dart';

class CommandProcessor {
  void execute(ArgResults rootCommand) {
    if (rootCommand.command == null) {
      processArgs(rootCommand.arguments);
    } else {
      switch (rootCommand.command!.name) {
        case 'build':
          processBuildCommand(rootCommand.command!, rootCommand);
          break;
        case 'create':
          processCreateCommand(rootCommand.command!);
          break;
        default:
          exitWith(
            'No command found. Use Spider --help to see available commands',
          );
      }
    }
  }

  /// Called when no command is passed for spider
  /// Process available options for spider executable
  void processArgs(List<String> arguments) {
    if (arguments.hasArg('help', 'h')) {
      stdout.writeln(HelpManuals.SPIDER_HELP);
    } else if (arguments.hasArg('verbose', 'v')) {
      printVersion();
    } else if (arguments.hasArg('info', 'i')) {
      printInfo();
    } else if (arguments.contains('--check-updates')) {
      executeUpdateCommand();
    } else {
      stdout.writeln(HelpManuals.SPIDER_HELP);
    }
  }

  /// BUILD COMMAND
  Future<void> processBuildCommand(ArgResults command, ArgResults root) async {
    checkFlutterProject();
    if (command.arguments.hasArg('help', 'h')) {
      stdout.writeln(HelpManuals.BUILD_HELP);
    } else {
      final verbose = command.arguments.hasArg('verbose', 'v');
      Logger.root.level = verbose ? Level.ALL : Level.INFO;
      await checkForNewVersion();
      final config = retrieveConfigs(root)!;
      Spider(config).build(command.arguments);
    }
  }

  /// CREATE COMMAND
  Future<void> processCreateCommand(ArgResults command) async {
    checkFlutterProject();
    if (command.arguments.hasArg('help', 'h')) {
      stdout.writeln(HelpManuals.CREATE_HELP);
    } else {
      final verbose = command.arguments.hasArg('verbose', 'v');
      Logger.root.level = verbose ? Level.ALL : Level.INFO;
      await checkForNewVersion();
      final isJson = command.arguments.hasArg('json', 'j');
      Spider.createConfigs(
        isJson: isJson,
        addInPubspec: command.arguments.contains('--add-in-pubspec'),
        path: command['path'],
      );
    }
  }

  /// Checks for updates
  Future<void> executeUpdateCommand() async {
    stdout.writeln('Checking for updates...');
    if (!await checkForNewVersion()) {
      stdout.writeln('No updates available!');
    }
  }

  /// prints library info read from pubspec file
  void printInfo() => stdout.writeln(Constants.INFO);

  /// prints library version
  void printVersion() => stdout.writeln(packageVersion);
}

extension ArgExtension on List<String> {
  bool hasArg(String flag, String abbr) {
    return contains('--$flag') || contains('-$abbr');
  }
}
