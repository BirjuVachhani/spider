/*
 * Copyright © 2020 Birju Vachhani
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// Author: Birju Vachhani
// Created Date: February 02, 2020

import 'dart:io';

import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:spider/spider.dart';
import 'package:spider/src/constants.dart';
import 'package:spider/src/help_manuals.dart';
import 'package:spider/src/utils.dart';
import 'package:spider/src/version.dart';

/// Handles all the commands
void main(List<String> arguments) {
  setupLogging();
  exitCode = 0;

  final argResults = parseArguments(arguments);
  if (argResults == null) return;

  if (argResults.command == null) {
    processArgs(argResults.arguments);
  } else {
    switch (argResults.command!.name) {
      case 'build':
        processBuildCommand(argResults.command!);
        break;
      case 'create':
        processCreateCommand(argResults.command!);
        break;
      default:
        exitWith(
            'No command found. Use Spider --help to see available commands');
    }
  }
}

/// sets up logging for stacktrace and logs.
void setupLogging() {
  Logger.root.level = Level.INFO; // defaults to Level.INFO
  recordStackTraceAtLevel = Level.ALL;
  Logger.root.onRecord.listen((record) {
    if (record.level == Level.SEVERE) {
      stderr.writeln('[${record.level.name}] ${record.message}');
    } else {
      stdout.writeln('[${record.level.name}] ${record.message}');
    }
  });
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

/// Parses command-line arguments and returns results
ArgResults? parseArguments(List<String> arguments) {
  final createParser = ArgParser()
    ..addFlag('json',
        help: 'generates json type of config file',
        negatable: false,
        abbr: 'j');

  final buildParser = ArgParser()
    ..addFlag('watch',
        abbr: 'w',
        negatable: false,
        help: 'Watches for any file changes and re-generates dart code')
    ..addFlag('smart-watch',
        negatable: false,
        help:
            'Smartly watches for file changes that matters and re-generates dart code')
    ..addFlag('verbose',
        abbr: 'v', negatable: false, help: 'prints verbose logs');

  final parser = ArgParser()
    ..addCommand('create', createParser)
    ..addCommand('build', buildParser)
    ..addFlag('help',
        abbr: 'h', help: 'prints usage information', negatable: false)
    ..addFlag('version', abbr: 'v', help: 'prints current version')
    ..addFlag('info', abbr: 'i', help: 'print library info', negatable: false)
    ..addFlag('check-updates',
        abbr: 'u', help: 'Check for update', negatable: false);
  try {
    var result = parser.parse(arguments);
    return result;
  } on Error catch (e) {
    exitWith(
        'Invalid command input. see spider --help for info.', e.stackTrace);
    return null;
  }
}

/// Process build command and its argument
void processBuildCommand(ArgResults command) async {
  checkFlutterProject();
  if (command.arguments.contains('--help')) {
    stdout.writeln(HelpManuals.BUILD_HELP);
  } else {
    var verbose = command.arguments.contains('--verbose');
    Logger.root.level = verbose ? Level.ALL : Level.INFO;
    await checkForNewVersion();
    final spider = Spider(Directory.current.path);
    spider.build(command.arguments);
  }
}

/// Process create command and its argument
void processCreateCommand(ArgResults command) async {
  checkFlutterProject();
  if (command.arguments.contains('--help')) {
    stdout.writeln(HelpManuals.CREATE_HELP);
  } else {
    var verbose = command.arguments.contains('--verbose');
    Logger.root.level = verbose ? Level.ALL : Level.INFO;
    await checkForNewVersion();
    var isJson = command.arguments.contains('--json');
    Spider.createConfigs(isJson);
  }
}
