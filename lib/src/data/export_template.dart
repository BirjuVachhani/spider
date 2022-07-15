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

/// A template to add library statement in dart source code.
String get libraryTemplate => 'library [LIBRARY_NAME];\n\n';

/// A template to add ignored rules.
String get ignoreRulesTemplate => '// ignore_for_file: [IGNORED_RULES]\n\n';

/// A template to generate export statements in dart source code.
String get exportFileTemplate =>
    "export 'package:[PROJECT_NAME]/[PACKAGE]/[FILE_NAME]';";

/// A template to generate `part` directive statement in the dart
/// library source file.
String get partTemplate =>
    "part 'package:[PROJECT_NAME]/[PACKAGE]/[FILE_NAME]';";

/// A template to generate `part of` directive statements in the dart
/// asset reference files.
String get partOfTemplate =>
    "part of 'package:[PROJECT_NAME]/[PACKAGE]/[FILE_NAME]';";
