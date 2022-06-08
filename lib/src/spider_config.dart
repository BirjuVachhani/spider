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

import 'package:spider/src/asset_group.dart';
import 'package:spider/src/constants.dart';

/// Represents the config.yaml file in form of dart model.
/// [groups] contains all the defined groups in the config file.
/// [globals] holds all the global configuration values.
class SpiderConfiguration {
  final List<AssetGroup> groups;
  final GlobalConfigs globals;
  final Map<String, dynamic> pubspec;

  SpiderConfiguration({
    required this.globals,
    required this.groups,
    required this.pubspec,
  });

  factory SpiderConfiguration.fromJson(Map<String, dynamic> json) {
    final List<AssetGroup> groups = [];
    if (json['groups'] != null) {
      json['groups'].forEach((v) {
        groups.add(AssetGroup.fromJson(v));
      });
    }
    return SpiderConfiguration(
      globals: GlobalConfigs.fromJson(json),
      groups: groups,
      pubspec: json['pubspec'] ?? {},
    );
  }
}

/// Holds all the global configuration values defined in the config.yaml file.
class GlobalConfigs {
  final bool generateTests;
  final bool noComments;
  final String projectName;
  final bool export;
  String? package;
  bool? usePartOf;
  final String exportFileName;
  final bool useReferencesList;
  final bool useFlutterTestImports;
  final bool generateForFonts;

  GlobalConfigs({
    required this.generateTests,
    required this.noComments,
    required this.export,
    required this.usePartOf,
    required this.package,
    required this.exportFileName,
    required this.projectName,
    required this.useReferencesList,
    this.useFlutterTestImports = false,
    this.generateForFonts = true,
  });

  factory GlobalConfigs.fromJson(Map<String, dynamic> json) {
    return GlobalConfigs(
      generateTests: json['generate_tests'] == true,
      noComments: json['no_comments'] == true,
      export: json['export'] == true,
      usePartOf: json['use_part_of'] == true,
      package: json['package'] ?? Constants.DEFAULT_PACKAGE,
      exportFileName: json['export_file'] ?? Constants.DEFAULT_EXPORT_FILE,
      projectName: json['project_name'],
      useReferencesList: json['use_references_list'] == true,
      useFlutterTestImports: json['flutter_project'] == true,
      generateForFonts: json['generate_fonts'] == true,
    );
  }
}
