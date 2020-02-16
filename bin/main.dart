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
import 'package:path/path.dart' as path;
import 'package:spider/spider.dart';
import 'package:spider/src/help_manuals.dart';
import 'package:spider/src/utils.dart';
import 'package:spider/src/version.dart';

/// Handles all the commands
void main(List<String> arguments) {
  Logger.root.level = Level.INFO; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    if (record.level == Level.SEVERE) {
      stderr.writeln('[${record.level.name}] ${record.message}');
    } else {
      stdout.writeln('[${record.level.name}] ${record.message}');
    }
  });
  var pubspec_path = path.join(Directory.current.path, 'pubspec.yaml');
  if (!File(pubspec_path).existsSync()) {
    exit_with('Current directory is not flutter project.\nPlease execute '
        'this command in a flutter project root path.');
  }
  exitCode = 0;

  final argResults = parseArguments(arguments);
  if (argResults == null) return;

  if (argResults.command == null) {
    processArgs(argResults.arguments);
  } else {
    switch (argResults.command.name) {
      case 'build':
        processBuildCommand(argResults.command);
        break;
      case 'create':
        processCreateCommand(argResults.command);
        break;
      default:
        exit_with(
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
  } else {
    stdout.writeln(HelpManuals.SPIDER_HELP);
  }
}

/// prints library info read from pubspec file
void printInfo() {
  final info = '''

SPIDER:
  A small dart command-line tool for generating dart references of assets from
  the assets folder.
  
  VERSION           ${packageVersion}
  HOMEPAGE          https://github.com/birjuvachhani/spider
  SDK VERSION       2.6
  
  see spider --help for more available commands.
''';
  stdout.writeln(info);
}

/// prints library version
void printVersion() {
  stdout.writeln(packageVersion);
}

/// Parses command-line arguments and returns results
ArgResults parseArguments(List<String> arguments) {
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
    ..addFlag('info', abbr: 'i', help: 'print library info', negatable: false);
  try {
    var result = parser.parse(arguments);
    return result;
  } on Error catch (e) {
    exit_with(
        'Invalid command input. see spider --help for info.', e.stackTrace);
    return null;
  }
}

/// Process build command and its argument
void processBuildCommand(ArgResults command) {
  if (command.arguments.contains('--help')) {
    stdout.writeln(HelpManuals.BUILD_HELP);
  } else {
    var verbose = command.arguments.contains('--verbose');
    Logger.root.level = verbose ? Level.ALL : Level.INFO;
    final spider = Spider(Directory.current.path);
    spider.build(command.arguments);
  }
}

/// Process create command and its argument
void processCreateCommand(ArgResults command) {
  if (command.arguments.contains('--help')) {
    stdout.writeln(HelpManuals.CREATE_HELP);
  } else {
    var isJson = command.arguments.contains('--json');
    Spider.createConfigs(isJson);
  }
}
