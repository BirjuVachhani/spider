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

import 'constants.dart';

/// A utility class that can format various dart source code tokens like
/// variable names, file paths, file names etc.
class Formatter {
  /// Formats variable name to be pascal case or with underscores
  /// if [use_underscores] is true
  static String formatName(String name,
      {String prefix = '', bool useUnderScores = false}) {
    // appending prefix if provided any
    name = (prefix.isEmpty ? '' : prefix + '_') + name;
    name = name
        // adds preceding _ for capital letters and lowers them
        .replaceAllMapped(
            RegExp(r'[A-Z]+'), (match) => '_' + match.group(0)!.toLowerCase())
        // replaces all the special characters with _
        .replaceAll(Constants.specialSymbolRegex, '_')
        // removes _ in the beginning of the name
        .replaceFirst(RegExp(r'^_+'), '')
        // removes any numbers in the beginning of the name
        .replaceFirst(RegExp(r'^[0-9]+'), '')
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
            RegExp(r'[A-Z]+'), (match) => '_' + match.group(0)!.toLowerCase())
        .replaceFirst(RegExp(r'^_+'), '');
    return name.contains('.dart') ? name : name + '.dart';
  }
}
