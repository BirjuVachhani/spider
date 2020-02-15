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
import 'package:path/path.dart' as path;
import 'package:spider/spider.dart';
import 'package:spider/src/help_manuals.dart';
import 'package:spider/src/version.dart';
import 'package:yaml/yaml.dart';

/// Handles all the commands
void main(List<String> arguments) {
  var pubspec_path = path.join(Directory.current.path, 'pubspec.yaml');
  if (!File(pubspec_path).existsSync()) {
    stderr.writeln(
        'Current directory is not flutter project.\nPlease execute this command in a flutter project root path.');
    exit(0);
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
        stderr.writeln(
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
  try {
    final yaml = _loadPubspec();
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
  } catch (e) {
    stderr.writeln('Unable to get info!');
  }
}

/// prints library version
void printVersion() {
  stdout.writeln(packageVersion);
}

Map _loadPubspec() {
  final pathToYaml = path.join(
      path.dirname(path.dirname(Platform.script.toFilePath())), 'pubspec.yaml');
  final pubspecFile = File(pathToYaml);
  Map yaml = loadYaml(pubspecFile.readAsStringSync());
  return yaml;
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
        help: 'Watches for file changes and re-generates dart code')
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
  } catch (e) {
    stderr.writeln('Invalid command input. see spider --help for info.');
    return null;
  }
}

/// Process build command and its argument
void processBuildCommand(ArgResults command) {
  if (command.arguments.contains('--help')) {
    stdout.writeln(HelpManuals.BUILD_HELP);
  } else {
    var watch = command.arguments.contains('--watch');
    var verbose = command.arguments.contains('--verbose');
    final spider = Spider(Directory.current.path);
    spider.build(watch, verbose: verbose);
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
