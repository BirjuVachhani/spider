// Copyright © 2020 Birju Vachhani. All rights reserved.
// Use of this source code is governed by an Apache license that can be
// found in the LICENSE file.

import '../../formatter.dart';
import '../utils/utils.dart';
import 'asset_group.dart';

/// Represents the config.yaml file in form of dart model.
/// [groups] contains all the defined groups in the config file.
/// [globals] holds all the global configuration values.
class SpiderConfiguration {
  /// Parsed groups from the config file.
  late final List<AssetGroup> groups;

  /// Parsed global configuration values.
  late final GlobalConfigs globals;

  /// Parsed pubspec.yaml data.
  late final Map<String, dynamic> pubspec;

  /// Default constructor.
  SpiderConfiguration({
    required this.globals,
    required this.groups,
    required this.pubspec,
  });

  /// Creates [SpiderConfiguration] from given [json] map data.
  factory SpiderConfiguration.fromJson(Map<String, dynamic> json) {
    final groups = <AssetGroup>[];
    if (json['groups'] != null) {
      json['groups'].forEach((v) {
        groups.add(AssetGroup.fromJson(v));
      });
    }
    return SpiderConfiguration(
      globals: GlobalConfigs.fromJson(json, json['pubspec'] ?? {}),
      groups: groups,
      pubspec: json['pubspec'] ?? {},
    );
  }
}

/// Holds all the global configuration values defined in the config.yaml file.
class GlobalConfigs {
  /// Whether to generate tests for the assets.
  final bool generateTests;

  /// Whether to add any additional comments in the generated code.
  final bool noComments;

  /// The name of the project. Used for generating correct imports.
  final String projectName;

  /// Whether to export as a library or not.
  final bool export;

  /// Defines where to put the generated code.
  String? package;

  /// Whether to use `part of` and `part` directives for the generated code.
  bool? usePartOf;

  /// lint rules to be ignored in the generated code.
  final List<String>? ignoredRules;

  /// Name of the exported library file.
  final String exportFileName;

  /// Whether to generate a list that contains all the assets.
  final bool useReferencesList;

  /// Whether to use `flutter_test` or `test` import for the tests.
  final bool useFlutterTestImports;

  /// Whether to generate references for fonts defined in pubspec.yaml file.
  final FontConfigs fontConfigs;

  /// Default constructor.
  GlobalConfigs({
    required this.ignoredRules,
    required this.generateTests,
    required this.noComments,
    required this.export,
    required this.usePartOf,
    required this.package,
    required this.exportFileName,
    required this.projectName,
    required this.useReferencesList,
    this.useFlutterTestImports = false,
    this.fontConfigs = const FontConfigs(generate: false),
  });

  /// Creates [GlobalConfigs] from given [json] map data.
  factory GlobalConfigs.fromJson(
      Map<String, dynamic> json, Map<String, dynamic> pubspec) {
    List<String>? ignoredRules;
    if (json['ignored_rules'] != null) {
      ignoredRules = [];
      json['ignored_rules'].forEach((rule) => ignoredRules!.add(rule));
    }

    return GlobalConfigs(
      ignoredRules: ignoredRules,
      generateTests: json['generate_tests'] == true,
      noComments: json['no_comments'] == true,
      export: json['export'] == true,
      usePartOf: json['use_part_of'] == true,
      package: json['package'] ?? Constants.DEFAULT_PACKAGE,
      exportFileName: json['export_file'] ?? Constants.DEFAULT_EXPORT_FILE,
      projectName: pubspec['name'],
      useReferencesList: json['use_references_list'] == true,
      useFlutterTestImports: pubspec['dependencies']?['flutter'] != null,
      fontConfigs: FontConfigs.fromJson(json['fonts']),
    );
  }
}

/// Holds configuration for fonts
class FontConfigs {
  /// Whether to generate fonts references or not.
  final bool generate;

  /// Class name to use for fonts dart references.
  final String className;

  /// File name to use for fonts dart class.
  final String fileName;

  /// Prefix to append to the reference names.
  final String? prefix;

  /// Whether to use underscore over camel case for the reference names.
  final bool useUnderScores;

  /// Default constructor
  const FontConfigs({
    required this.generate,
    this.className = 'FontFamily',
    this.fileName = 'fonts',
    this.prefix,
    this.useUnderScores = false,
  });

  /// Generates [AssetGroup] from the [json] map data.
  factory FontConfigs.fromJson(dynamic json) {
    if (json == null) return FontConfigs(generate: false);
    if (json == true) return FontConfigs(generate: true);
    if (json is! Map) return FontConfigs(generate: false);

    final className = json['class_name'].toString();
    final fileName =
        Formatter.formatFileName(json['file_name']?.toString() ?? className);
    final prefix = json['prefix']?.toString();
    final useUnderScores = json['use_underscores'] == true;

    return FontConfigs(
      generate: true,
      className: className,
      fileName: fileName,
      prefix: prefix,
      useUnderScores: useUnderScores,
    );
  }
}
