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

import 'package:spider/src/utils.dart';

import 'Formatter.dart';

/// Holds group information for assets sub directories
class AssetGroup {
  late final String className;
  late final String fileName;
  late final bool useUnderScores;
  late final bool useStatic;
  late final bool useConst;
  late final String? prefix;
  late final List<String> types;
  late final List<String> paths;

  AssetGroup({
    required this.className,
    required this.paths,
    String? fileName,
    this.useUnderScores = false,
    this.useStatic = true,
    this.useConst = true,
    this.prefix = '',
    this.types = const <String>[],
  }) : fileName = Formatter.formatFileName(fileName ?? className);

  AssetGroup.fromJson(Map<String, dynamic> json) {
    className = json['class_name'].toString();
    fileName =
        Formatter.formatFileName(json['file_name']?.toString() ?? className);
    prefix = json['prefix']?.toString() ?? '';
    useUnderScores = false;
    useStatic = true;
    useConst = true;
    types = <String>[];
    json['types']?.forEach(
        (group) => types.add(formatExtension(group.toString()).toLowerCase()));
    paths = <String>[];
    if (json['paths'] != null) {
      paths.addAll(List<String>.from(json['paths']));
    } else if (json['path'] != null) {
      paths.add(json['path'].toString());
    }
  }
}
