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

import 'dart:io';

import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:spider/src/cli/args_parser.dart';
import 'package:spider/src/cli/command_processor.dart';

/// Handles all the commands
void main(List<String> arguments) {
  setupLogging();
  exitCode = 0;

  final ArgResults? argResults = parseArguments(arguments);
  if (argResults == null) return;
  CommandProcessor().execute(argResults);
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
