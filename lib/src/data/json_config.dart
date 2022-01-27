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

/// A template for JSON config file generation.
const String JSON_CONFIGS = '''{
  "generate_tests":true,
  "no_comments":true,
  "export":true,
  "use_part_of":true,
  "use_references_list": true,
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
