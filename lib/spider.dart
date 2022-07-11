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

import 'src/cli/models/spider_config.dart';
import 'src/dart_class_generator.dart';
import 'src/formatter.dart';
import 'src/generation_utils.dart';

/// Entry point of all the command process
/// provides various functions to execute commands
/// Responsible for triggering dart code generation
class Spider {
  SpiderConfiguration config;

  Spider(this.config);

  /// Triggers build
  void build({bool watch = false, bool smartWatch = false}) {
    if (config.groups.isEmpty) return;

    for (final group in config.groups) {
      final generator = DartClassGenerator(group, config.globals);
      generator.initAndStart(watch: watch, smartWatch: smartWatch);
    }
    if (config.globals.export) {
      exportAsLibrary();
    }
  }

  /// Generates library export file for all the generated references files.
  void exportAsLibrary() {
    final content = getExportContent(
      noComments: config.globals.noComments,
      usePartOf: config.globals.usePartOf ?? false,
      fileNames: config.groups
          .map<String>((group) => Formatter.formatFileName(group.fileName))
          .toList(),
    );
    writeToFile(
      name: Formatter.formatFileName(config.globals.exportFileName),
      path: config.globals.package,
      content: DartClassGenerator.formatter.format(content),
    );
  }
}
