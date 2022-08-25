// Copyright © 2020 Birju Vachhani. All rights reserved.
// Use of this source code is governed by an Apache license that can be
// found in the LICENSE file.

import 'package:path/path.dart' as p;
import 'package:sprintf/sprintf.dart' hide Formatter;

import 'src/cli/models/flag_names.dart';
import 'src/cli/models/spider_config.dart';
import 'src/cli/utils/utils.dart';
import 'src/dart_class_generator.dart';
import 'src/fonts_generator.dart';
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
    bool fontsOnly = false,
    BaseLogger? logger,
  }) {
    // Only process for groups if fonts-only flag is not set and groups are
    // provided.
    if (!fontsOnly && config.groups.isNotEmpty) {
      for (final group in config.groups) {
        final generator = DartClassGenerator(group, config.globals, logger);
        generator.initAndStart(watch: watch, smartWatch: smartWatch);
      }
    }

    if (config.globals.export) {
      exportAsLibrary();
    }

    if (config.globals.fontConfigs.generate) {
      generateFontReferences(logger);
    } else if (fontsOnly) {
      // [GlobalConfigs.generateForFonts] is not true and fonts-only flag is
      // given then exit with error.
      logger?.exitWith(sprintf(
          ConsoleMessages.fontsOnlyExecutedWithoutSetTemplate,
          [FlagNames.fontsOnly]));
    }
  }

  /// Generates library export file for all the generated references files.
  void exportAsLibrary() {
    final List<String> fileNames = config.groups
        .map<String>((group) => Formatter.formatFileName(group.fileName))
        .toList();

    // Don't include files that does not exist.
    fileNames.removeWhere(
        (name) => file(p.join('lib', config.globals.package, name)) == null);

    if (config.globals.fontConfigs.generate) {
      // Only add fonts.dart in exports fonts are generated.
      fileNames
          .add(Formatter.formatFileName(config.globals.fontConfigs.fileName));
    }

    final content = getExportContent(
      noComments: config.globals.noComments,
      usePartOf: config.globals.usePartOf ?? false,
      fileNames: fileNames,
    );

    writeToFile(
      name: Formatter.formatFileName(config.globals.exportFileName),
      path: config.globals.package,
      content: DartClassGenerator.formatter.format(content),
    );
  }

  /// Generates references for fonts defined in pubspec.yaml
  void generateFontReferences(BaseLogger? logger) {
    if (config.pubspec['flutter']?['fonts'] == null) {
      logger?.info('No fonts found in pubspec.yaml');
      return;
    }
    final generator = FontsGenerator();
    generator.generate(
        config.pubspec['flutter']['fonts'], config.globals, logger);
  }
}
