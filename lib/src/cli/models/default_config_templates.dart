// Copyright © 2020 Birju Vachhani. All rights reserved.
// Use of this source code is governed by an Apache license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

/// Contains configuration creation templates.
class DefaultConfigTemplates {
  DefaultConfigTemplates._();

  static const String jsonFormat = '''{
  "generate_tests":true,
  "no_comments":true,
  "export":true,
  "use_part_of":true,
  "use_references_list": false,
  "fonts": false,
  "package":"resources",
  "groups": [
    {
      "path": "assets/images",
      "class_name": "Assets",
      "types": ["jpg", "jpeg", "png", "webp", "gif", "bmp", "wbmp"]
    },
    {
      "path": "assets/vectors",
      "class_name": "Svgs",
      "package": "res",
      "types": ["svg"]
    }
  ]
}''';
  static const String pubspecFormat = '''
# Generated by Spider
# For more info on configuration, visit https://birjuvachhani.github.io/spider/grouping/
spider:
  # Generates unit tests to verify that the assets exists in assets directory
  generate_tests: true
  # Use this to remove vcs noise created by the `generated` comments in dart code
  no_comments: true
  # Exports all the generated file as the one library
  export: true
  # This allows you to import all the generated references with 1 single import!
  use_part_of: true
  # Generates a variable that contains a list of all asset values.
  use_references_list: false
  # Generates files with given ignore rules for file.
  # ignored_rules:
  #   - public_member_api_docs
  # Generates dart font family references for fonts specified in pubspec.yaml
  # fonts: true
  # -------- OR --------
  # fonts:
  #   class_name: MyFonts
  #   file_name: my_fonts
  # Location where all the generated references will be stored
  package: resources
  groups:
    - path: assets/images
      class_name: Images
      types: [ .png, .jpg, .jpeg, .webp, .webm, .bmp ]''';

  static const String yamlFormat = '''
# Generated by Spider
# For more info on configuration, visit https://birjuvachhani.github.io/spider/grouping/  
# Generates unit tests to verify that the assets exists in assets directory
generate_tests: true

# Use this to remove vcs noise created by the `generated` comments in dart code
no_comments: true

# Exports all the generated file as the one library
export: true

# This allows you to import all the generated references with 1 single import!
use_part_of: true

# Generates a variable that contains a list of all asset values.
use_references_list: false

# Generates files with given ignore rules for file.
# ignored_rules:
#   - public_member_api_docs

# Generates dart font family references for fonts specified in pubspec.yaml
# fonts: true
# -------- OR --------
# fonts:
#   class_name: MyFonts
#   file_name: my_fonts

# Location where all the generated references will be stored
package: resources

groups:
  - path: assets/images
    class_name: Images
    types: [ .png, .jpg, .jpeg, .webp, .webm, .bmp ]''';
}
