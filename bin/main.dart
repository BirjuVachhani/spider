/*
 * Copyright © $YEAR Birju Vachhani
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
import 'package:spider/src/emojis.dart';

/// Handles all the commands
void main(List<String> arguments) {
  var pubspec_path = path.join(Directory.current.path, 'pubspec.yaml');
  if (!File(pubspec_path).existsSync()) {
    print(
        'Current directory is not flutter project.\nPlease execute this command in a flutter project root path. ${Emojis.error}');
    exit(0);
  }
  exitCode = 0;
  final initParser = ArgParser()..addOption('file', abbr: 'f');
  final parser = ArgParser()..addCommand('init', initParser);

  final argResults = parser.parse(arguments);

  if (argResults.command == null) {
    final spider = Spider(Directory.current.path);
//    spider.listen_for_changes();
    spider.generate_code();
  } else {
    Spider.init_configs();
  }
}
