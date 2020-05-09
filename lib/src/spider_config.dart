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

class SpiderConfiguration {
  List<AssetGroup> groups;
  GlobalConfigs globals;

  SpiderConfiguration({this.globals, this.groups});

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

class GlobalConfigs {
  bool generateTests;
  bool noComments;
  String projectName;
  bool export;
  String package;
  bool usePartOf;
  String exportFileName;

  GlobalConfigs.fromJson(Map<String, dynamic> json) {
    generateTests = json['generate_tests'] ?? false;
    noComments = json['no_comments'] ?? false;
    export = json['export'] ?? true;
    usePartOf = json['use_part_of'] ?? false;
    package = json['package'] ?? Constants.DEFAULT_PACKAGE;
    exportFileName = json['export_file'] ?? Constants.DEFAULT_EXPORT_FILE;
    projectName = json['project_name'];
  }
}
