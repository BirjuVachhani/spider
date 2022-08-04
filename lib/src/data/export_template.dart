// Copyright © 2020 Birju Vachhani. All rights reserved.
// Use of this source code is governed by an Apache license that can be
// found in the LICENSE file.

/// A template to add library statement in dart source code.
String get libraryTemplate => 'library [LIBRARY_NAME];\n\n';

/// A template to add ignored rules.
String get ignoreRulesTemplate => '// ignore_for_file: [IGNORED_RULES]\n\n';

/// A template to generate export statements in dart source code.
String get exportFileTemplate => "export '[FILE_NAME]';";

/// A template to generate `part` directive statement in the dart
/// library source file.
String get partTemplate => "part '[FILE_NAME]';";

/// A template to generate `part of` directive statements in the dart
/// asset reference files.
String get partOfTemplate => "part of '[FILE_NAME]';";
