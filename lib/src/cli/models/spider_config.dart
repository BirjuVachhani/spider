// Copyright © 2020 Birju Vachhani. All rights reserved.
// Use of this source code is governed by an Apache license that can be
// found in the LICENSE file.

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

  /// Default constructor.
  SpiderConfiguration({required this.globals, required this.groups});

  /// Creates [SpiderConfiguration] from given [json] map data.
  SpiderConfiguration.fromJson(Map<String, dynamic> json) {
    globals = GlobalConfigs.fromJson(json);
    groups = <AssetGroup>[];
    if (json['groups'] != null) {
      json['groups'].forEach((v) {
        groups.add(AssetGroup.fromJson(v));
      });
    }
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
  });

  /// Creates [GlobalConfigs] from given [json] map data.
  factory GlobalConfigs.fromJson(Map<String, dynamic> json) {
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
      projectName: json['project_name'],
      useReferencesList: json['use_references_list'] == true,
      useFlutterTestImports: json['flutter_project'] == true,
    );
  }
}
