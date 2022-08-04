// Copyright © 2020 Birju Vachhani. All rights reserved.
// Use of this source code is governed by an Apache license that can be
// found in the LICENSE file.

/// A template for JSON config file generation.
const String JSON_CONFIG_TEMPLATE = '''{
  "generate_tests":true,
  "no_comments":true,
  "export":true,
  "use_part_of":true,
  "use_references_list": false,
  "package":"resources",
  "groups": [
    {
      "class_name": "Images",
      "path": "assets/images",
      "types": [
        ".png",
        ".jpg",
        ".jpeg",
        ".webp",
        ".webm",
        ".bmp"
      ]
    }
  ]
}''';
