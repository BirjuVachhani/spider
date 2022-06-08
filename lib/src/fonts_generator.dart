import 'package:dart_style/dart_style.dart';
import 'package:spider/src/spider_config.dart';

import 'formatter.dart';
import 'utils.dart';

class FontsGenerator {
  void generate(List<dynamic> fonts, GlobalConfigs globals) {
    final List<String> fontFamilies =
        fonts.map((item) => item['family'].toString()).toList();
    final String references = generateReferences(fontFamilies, globals);

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

    verbose('Constructing dart class for fonts');
    final content = getDartClass(
      className: 'Fonts',
      references: references,
      noComments: globals.noComments,
      usePartOf: globals.export && globals.usePartOf!,
      exportFileName: Formatter.formatFileName(globals.exportFileName),
      valuesList: valuesList,
    );
    verbose('Writing class Fonts to file fonts.dart');
    writeToFile(
      name: Formatter.formatFileName('fonts'),
      path: globals.package,
      content: DartFormatter().format(content),
    );
  }

  String generateReferences(List<String> fontFamilies, GlobalConfigs globals) {
    return fontFamilies
        .map((name) {
          verbose('processing $name');
          return getReference(
            properties: 'static const',
            assetName:
                Formatter.formatName(name, prefix: '', useUnderScores: false),
            assetPath: name,
          );
        })
        .toList()
        .join();
  }
}
