import 'dart:io';

import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:spider/src/spider_config.dart';
import 'package:spider/src/utils.dart';
import 'package:spider/src/version.dart';

import '../../spider.dart';
import '../constants.dart';
import '../help_manuals.dart';
import 'config_retriever.dart';

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
              'No command found. Use Spider --help to see available commands');
      }
    }
  }

  /// Called when no command is passed for spider
  /// Process available options for spider executable
  void processArgs(List<String> arguments) {
    if (arguments.contains('--help')) {
      stdout.writeln(HelpManuals.SPIDER_HELP);
    } else if (arguments.contains('--version')) {
      printVersion();
    } else if (arguments.contains('--info')) {
      printInfo();
    } else if (arguments.contains('--check-updates')) {
      executeUpdateCommand();
    } else {
      stdout.writeln(HelpManuals.SPIDER_HELP);
    }
  }

  /// BUILD COMMAND
  void processBuildCommand(ArgResults command, ArgResults root) async {
    checkFlutterProject();
    if (command.arguments.contains('--help')) {
      stdout.writeln(HelpManuals.BUILD_HELP);
    } else {
      var verbose = command.arguments.contains('--verbose');
      Logger.root.level = verbose ? Level.ALL : Level.INFO;
      await checkForNewVersion();
      final SpiderConfiguration config = retrieveConfigs(root)!;
      final spider = Spider(config);
      spider.build(command.arguments);
    }
  }

  /// CREATE COMMAND
  void processCreateCommand(ArgResults command) async {
    checkFlutterProject();
    if (command.arguments.contains('--help')) {
      stdout.writeln(HelpManuals.CREATE_HELP);
    } else {
      var verbose = command.arguments.contains('--verbose');
      Logger.root.level = verbose ? Level.ALL : Level.INFO;
      await checkForNewVersion();
      var isJson = command.arguments.contains('--json');
      Spider.createConfigs(
        isJson: isJson,
        addInPubspec: command.arguments.contains('--add-in-pubspec'),
        path: command['path'],
      );
    }
  }

  /// Checks for updates
  void executeUpdateCommand() async {
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
