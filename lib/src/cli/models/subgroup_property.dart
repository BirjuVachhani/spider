// Copyright © 2020 Birju Vachhani. All rights reserved.
// Use of this source code is governed by an Apache license that can be
// found in the LICENSE file.

/// Represents a sub_group property.
class SubgroupProperty {
  /// Subgroup prefix.
  final String prefix;

  /// Subgroup file map (fileName: path).
  final Map<String, String> files;

  /// Creates an instance of [SubgroupProperty].
  SubgroupProperty(this.prefix, this.files);
}
