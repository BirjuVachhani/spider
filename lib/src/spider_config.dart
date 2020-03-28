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

class SpiderConfiguration {
  bool generateTests;
  List<AssetGroup> groups;
  String projectName;

  SpiderConfiguration({this.generateTests, this.groups});

  SpiderConfiguration.fromJson(Map<String, dynamic> json) {
    generateTests = json['generate_tests'];
    if (json['groups'] != null) {
      groups = <AssetGroup>[];
      json['groups'].forEach((v) {
        groups.add(AssetGroup.fromJson(v));
      });
    }
    projectName = json['project_name'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['generate_tests'] = generateTests;
    data['project_name'] = projectName;
    if (groups != null) {
      data['groups'] = groups.map((v) => v.toJson())?.toList();
    }
    return data;
  }
}
