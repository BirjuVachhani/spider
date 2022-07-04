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

import 'version.dart';

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
  static final Pattern specialSymbolRegex = RegExp(SPECIAL_SYMBOLS);

  static const String KEY_INGORED_RULES = '[IGNORED_RULES]';
  static const String KEY_PROJECT_NAME = '[PROJECT_NAME]';
  static const String KEY_PACKAGE = '[PACKAGE]';
  static const String TEST_IMPORT = '[TEST_IMPORT]';
  static const String KEY_FILE_NAME = '[FILE_NAME]';
  static const String KEY_TESTS = '[TESTS]';
  static const String KEY_CLASS_NAME = '[CLASS_NAME]';
  static const String KEY_ASSET_NAME = '[ASSET_NAME]';
  static const String KEY_TIME = '[TIME]';
  static const String KEY_REFERENCES = '[REFERENCES]';
  static const String KEY_LIST_OF_ALL_REFERENCES = '[LIST_OF_ALL_REFERENCES]';
  static const String KEY_ASSET_PATH = '[ASSET_PATH]';
  static const String KEY_PROPERTIES = '[PROPERTIES]';
  static const String KEY_LIBRARY_NAME = '[LIBRARY_NAME]';
  static const String KEY_IMPORT_FILE_NAME = '[IMPORT_FILE_NAME]';
  static const String DEFAULT_EXPORT_FILE = 'resources.dart';
  static const String DOCS_URL = 'https://birjuvachhani.github.io/spider';

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

  static const String VERSION_REGEX = '^([0-9]+).([0-9]+).([0-9]+)\$';

  static const String INFO = '''

SPIDER:
  A small dart command-line tool for generating dart references of assets from
  the assets folder.
  
  VERSION           $packageVersion
  AUTHOR            Birju Vachhani (https://birju.dev)
  HOMEPAGE          https://github.com/birjuvachhani/spider
  SDK VERSION       2.6
  
  see spider --help for more available commands.
''';

  static const String LICENSE_SHORT = '''

Copyright © 2020 Birju Vachhani

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
  
See full license at https://github.com/BirjuVachhani/spider/blob/main/LICENSE
''';
}

class ConsoleMessages {
  static const String configNotFound =
      'Config not found. Create one using "spider create" command.';
  static const String unableToLoadPubspecFile =
      'Unable to load pubspec file. Make sure your pubspec.yaml file is valid.';
  static const String unableToGetProjectName =
      'Unable to retrieve project name from pubspec.yaml. Make sure your '
      'pubspec.yaml file is valid.';
  static const String configNotFoundDetailed = """Config not found...
  
    1. Create one using "spider create" command.
    2. If using custom config file path, make sure the path is correct.
    3. If using pubspec.yaml, make sure spider block is not invalid.
    4. If using default config file path, make sure the file is present in the root of the project.
    """;
  static const String invalidConfigFile =
      'Invalid config. Please check your config file.';
  static const String invalidConfigFilePath =
      'Invalid config file path. Please check your config file path.';
  static const String parseError = 'Unable to parse configs!';
  static const String noGroupsFound = 'No groups found in the config file.';
  static const String noSubgroupsFound =
      'No subgroups found in the config file.';
  static const String invalidGroupsType =
      'Groups must be a list of configurations.';
  static const String noPathInGroupError =
      'Either no path is specified in the config or specified path is empty';
  static const String noWildcardInPathError =
      'Path %s must not contain any wildcard.';
  static const String nullValueError = '%s cannot be null';
  static const String pathNotExistsError = 'Path %s does not exist!';
  static const String notDirectoryError = 'Path %s is not a directory';
  static const String invalidAssetDirError =
      '%s is not a valid asset directory.';
  static const String noClassNameError =
      'Class name not specified for one of the groups.';
  static const String emptyClassNameError = 'Empty class name is not allowed';
  static const String classNameContainsSpacesError =
      'Class name must not contain spaces.';
  static const String configValidationFailed = 'Configs Validation failed';
  static const String notFlutterProjectError =
      'Current directory is not flutter project. Please execute '
      'this command in a flutter project root path.';
  static const String pubspecNotFound =
      'Unable to find pubspec.yaml or pubspec.yml';
  static const String configExistsInPubspec =
      'Spider config already exists in pubspec.yaml';
  static const String configCreatedInPubspec =
      'Config file added to pubspec.yaml';
  static const String unableToAddConfigInPubspec =
      'Unable to add config file to pubspec.yaml';
  static const String fileCreatedAtCustomPath =
      'Configuration file created successfully at %s.';
  static const String customPathIsPubspec =
      "You provided pubspec file as custom path? Did you mean to include "
      "configs in pubspec file? If you did then use "
      "'spider create --add-in-pubspec' command.";

  ConsoleMessages._();
}
