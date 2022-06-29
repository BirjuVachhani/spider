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

// Author: Birju Vachhani
// Created Date: February 09, 2020

import 'package:spider/src/asset_subgroup.dart';

import 'formatter.dart';

/// Holds group information for assets sub directories
class AssetGroup {
  late final String className;
  late final String fileName;
  late final bool useUnderScores;
  late final bool useStatic;
  late final bool useConst;
  late final List<AssetSubgroup> subgroups;

  AssetGroup({
    required this.className,
    String? fileName,
    this.useUnderScores = false,
    this.useStatic = true,
    this.useConst = true,
  }) : fileName = Formatter.formatFileName(fileName ?? className);

  AssetGroup.fromJson(Map<String, dynamic> json) {
    className = json['class_name'].toString();
    fileName =
        Formatter.formatFileName(json['file_name']?.toString() ?? className);
    subgroups = <AssetSubgroup>[];
    if (json['subgroups'] != null) {
      json['subgroups'].forEach(
          (subgroup) => subgroups.add(AssetSubgroup.fromJson(subgroup)));
    } else if (json['subgroup'] != null) {
      subgroups.add(AssetSubgroup.fromJson(json['subgroup']));
    }
    useUnderScores = json['use_underscores'] == true;
    useStatic = true;
    useConst = true;
  }
}
