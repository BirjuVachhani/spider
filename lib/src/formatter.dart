// Copyright © 2020 Birju Vachhani. All rights reserved.
// Use of this source code is governed by an Apache license that can be
// found in the LICENSE file.

// Author: Birju Vachhani
// Created Date: February 09, 2020

import 'cli/utils/utils.dart';

/// A utility class that can format various dart source code tokens like
/// variable names, file paths, file names etc.
class Formatter {
  /// Formats variable name to be pascal case or with underscores
  /// if [use_underscores] is true
  static String formatName(String name,
      {String prefix = '', bool useUnderScores = false}) {
    // appending prefix if provided any
    name = (prefix.isEmpty ? '' : '${prefix}_') + name;
    name = name
        // adds preceding _ for capital letters and lowers them
        .replaceAllMapped(
            RegExp(r'[A-Z]+'), (match) => '_${match.group(0)!.toLowerCase()}')
        // replaces all the special characters with _
        .replaceAll(Constants.specialSymbolRegex, '_')
        // removes _ in the beginning of the name
        .replaceFirst(RegExp(r'^_+'), '')
        // removes any numbers in the beginning of the name
        .replaceFirst(RegExp(r'^\d+'), '')
        // lowers the first character of the string
        .replaceFirstMapped(
            RegExp(r'^[A-Za-z]'), (match) => match.group(0)!.toLowerCase());
    return useUnderScores
        ? name
        : name
            // removes _ and capitalize the next character of the _
            .replaceAllMapped(RegExp(Constants.CAPITALIZE_REGEX),
                (match) => match.group(2)!.toUpperCase());
  }

  /// formats path string to match with flutter's standards
  static String formatPath(String value) => value.replaceAll('\\', '/');

  /// formats file name according to effective dart
  static String formatFileName(String name) {
    name = name
        .replaceAllMapped(
            RegExp(r'[A-Z]+'), (match) => '_${match.group(0)!.toLowerCase()}')
        .replaceFirst(RegExp(r'^_+'), '');
    return name.endsWith('.dart') ? name : '$name.dart';
  }
}
