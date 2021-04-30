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
// Created Date: February 02, 2020

import 'package:spider/src/version.dart';

/// Holds all the constants
class Constants {
  static const String LIB_FOLDER = 'lib';
  static const String TEST_FOLDER = 'test';
  static const String DEFAULT_PATH = 'assets';
  static const String DEFAULT_CLASS_NAME = 'Assets';
  static const String DEFAULT_PACKAGE = 'resources';

  static const String CAPITALIZE_REGEX = r'(_)(\S)';
  static const String SPECIAL_SYMBOLS =
      "[,.\\/;'\\[\\]\\-=<>?:\\\"\\{}_+!@#\$%^&*()\\\\|\\s]+";
  static final Pattern SPECIAL_SYMBOL_REGEX = RegExp(SPECIAL_SYMBOLS);

  static const String KEY_PROJECT_NAME = '[PROJECT_NAME]';
  static const String KEY_PACKAGE = '[PACKAGE]';
  static const String KEY_FILE_NAME = '[FILE_NAME]';
  static const String KEY_TESTS = '[TESTS]';
  static const String KEY_CLASS_NAME = '[CLASS_NAME]';
  static const String KEY_ASSET_NAME = '[ASSET_NAME]';
  static const String KEY_TIME = '[TIME]';
  static const String KEY_REFERENCES = '[REFERENCES]';
  static const String KEY_ASSET_PATH = '[ASSET_PATH]';
  static const String KEY_PROPERTIES = '[PROPERTIES]';
  static const String KEY_LIBRARY_NAME = '[LIBRARY_NAME]';
  static const String KEY_IMPORT_FILE_NAME = '[IMPORT_FILE_NAME]';
  static const String DEFAULT_EXPORT_FILE = 'resources.dart';

  static const String NEW_VERSION_AVAILABLE = '''

  ===================================================================
  |                      New Version Available                      |
  |=================================================================|
  |                                                                 |
  |   New Version Available with more stability and improvements.   |
  |                                                                 |
  |   Current Version:  X.X.X                                       | 
  |   Latest Version:   Y.Y.Y                                       |
  |                                                                 |
  |   Checkout for more info: https://pub.dev/packages/spider       |
  |                                                                 |
  |   Run following command to update to the latest version:        |
  |                                                                 |
  |   pub global activate spider                                    |
  |                                                                 |
  ===================================================================

''';

  static const String VERSION_REGEX = '^([0-9]+)\.([0-9]+)\.([0-9]+)\$';

  static const String INFO = '''

SPIDER:
  A small dart command-line tool for generating dart references of assets from
  the assets folder.
  
  VERSION           $packageVersion
  AUTHOR            Birju Vachhani (https://birjuvachhani.dev)
  HOMEPAGE          https://github.com/birjuvachhani/spider
  SDK VERSION       2.6
  
  see spider --help for more available commands.
''';
}
