// Copyright © 2020 Birju Vachhani. All rights reserved.
// Use of this source code is governed by an Apache license that can be
// found in the LICENSE file.

// Author: Birju Vachhani
// Created Date: February 09, 2020

import '../../formatter.dart';
import '../../generation_utils.dart';
import 'asset_subgroup.dart';

/// Holds group information for assets sub directories
class AssetGroup {
  /// Name of the dart class for the group.
  late final String className;

  /// name of the dart file for the group.
  late final String fileName;

  /// Whether to use underscore over camel case for the reference names.
  late final bool useUnderScores;

  /// Whether to generate static references or not.
  late final bool useStatic;

  /// Whether to generate constant references or not.
  late final bool useConst;

  /// Subgroups of the group.
  late final List<AssetSubgroup>? subgroups;

  /// Whitelisted file types for the group.
  late final List<String>? types;

  /// Paths covered by the group.
  late final List<String>? paths;

  /// Prefix to append to the reference names.
  late final String? prefix;

  /// Default constructor.
  AssetGroup({
    required this.className,
    String? fileName,
    this.useUnderScores = false,
    this.useStatic = true,
    this.useConst = true,
  }) : fileName = Formatter.formatFileName(fileName ?? className);

  /// Generates [AssetGroup] from the [json] map data.
  AssetGroup.fromJson(Map<String, dynamic> json) {
    className = json['class_name'].toString();
    fileName =
        Formatter.formatFileName(json['file_name']?.toString() ?? className);
    paths = json['path'] == null && json['paths'] == null ? null : <String>[];
    if (json['paths'] != null) {
      paths!.addAll(List<String>.from(json['paths']));
    } else if (json['path'] != null) {
      paths!.add(json['path'].toString());
    }
    // If paths are implemented in group scope we don't need
    // sub_groups at all.
    if (paths != null) {
      subgroups = null;
      prefix = json['prefix']?.toString() ?? '';
      types = <String>[];
    } else {
      subgroups = json['sub_groups'] == null && json['sub_group'] == null
          ? null
          : <AssetSubgroup>[];
      prefix = json['prefix']?.toString();
      types = json['types'] == null ? null : <String>[];
    }

    if (types != null) {
      json['types']!.forEach((group) =>
          types!.add(formatExtension(group.toString()).toLowerCase()));
    }
    if (subgroups != null) {
      if (json['sub_groups'] != null) {
        json['sub_groups'].forEach(
            (subgroup) => subgroups!.add(AssetSubgroup.fromJson(subgroup)));
      } else if (json['sub_group'] != null) {
        subgroups!.add(AssetSubgroup.fromJson(json['sub_group']));
      }
    }
    // Diff constants.
    useUnderScores = json['use_underscores'] == true;
    useStatic = true;
    useConst = true;
  }
}
