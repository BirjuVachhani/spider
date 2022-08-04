// Copyright © 2020 Birju Vachhani. All rights reserved.
// Use of this source code is governed by an Apache license that can be
// found in the LICENSE file.

import 'src/cli/models/spider_config.dart';
import 'src/cli/utils/utils.dart';
import 'src/dart_class_generator.dart';
import 'src/formatter.dart';
import 'src/generation_utils.dart';

/// Entry point of all the command process
/// provides various functions to execute commands
/// Responsible for triggering dart code generation
class Spider {
  /// Holds the typed configuration data parsed from config file.
  SpiderConfiguration config;

  /// Default Constructor.
  /// [config] provides the typed configuration data parsed from config file.
  Spider(this.config);

  /// Triggers build
  void build({
    bool watch = false,
    bool smartWatch = false,
    BaseLogger? logger,
  }) {
    if (config.groups.isEmpty) return;

    for (final group in config.groups) {
      final generator = DartClassGenerator(group, config.globals, logger);
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
