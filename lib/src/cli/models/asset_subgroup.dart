// Copyright © 2020 Birju Vachhani. All rights reserved.
// Use of this source code is governed by an Apache license that can be
// found in the LICENSE file.

import '../../generation_utils.dart';

/// Holds prefix, types and path info for [Group]
class AssetSubgroup {
  /// Prefix to be appended to the reference names.
  late final String prefix;

  /// Whitelisted types that are part of this sub-group.
  late final List<String> types;

  /// Paths covered under this sub-group.
  late final List<String> paths;

  /// Default constructor.
  AssetSubgroup({
    required this.paths,
    this.prefix = '',
    this.types = const <String>[],
  });

  /// Creates [AssetSubgroup] from [json] map data.
  AssetSubgroup.fromJson(Map<String, dynamic> json) {
    prefix = json['prefix']?.toString() ?? '';
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
