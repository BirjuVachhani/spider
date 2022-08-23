// Copyright © 2020 Birju Vachhani. All rights reserved.
// Use of this source code is governed by an Apache license that can be
// found in the LICENSE file.

import 'package:dart_style/dart_style.dart';

import 'cli/models/spider_config.dart';
import 'cli/utils/utils.dart';
import 'formatter.dart';
import 'generation_utils.dart';

/// A dart code generator for fonts references.
class FontsGenerator {
  /// Entry point for this generator.
  /// [fonts] is a list of
  void generate(
      List<dynamic> fonts, GlobalConfigs globals, BaseLogger? logger) {
    final List<String> fontFamilies =
        fonts.map((item) => item['family'].toString()).toList();
    final String references = fontFamilies
        .map((name) {
          logger?.verbose('processing $name');
          return getReference(
            properties: 'static const',
            assetName:
                Formatter.formatName(name, prefix: '', useUnderScores: false),
            assetPath: name,
          );
        })
        .toList()
        .join();

    final valuesList = globals.useReferencesList
        ? getListOfReferences(
            properties: 'static const',
            assetNames: fontFamilies
                .map(
                  (name) => Formatter.formatName(name,
                      prefix: '', useUnderScores: false),
                )
                .toList())
        : null;

    logger?.verbose('Constructing dart class for fonts');
    final content = getDartClass(
      className: 'Fonts',
      references: references,
      noComments: globals.noComments,
      usePartOf: globals.export && globals.usePartOf!,
      exportFileName: Formatter.formatFileName(globals.exportFileName),
      valuesList: valuesList,
      ignoredRules: globals.ignoredRules,
    );
    logger?.verbose('Writing class Fonts to file fonts.dart');
    writeToFile(
      name: Formatter.formatFileName('fonts'),
      path: globals.package,
      content: DartFormatter().format(content),
    );
  }
}
