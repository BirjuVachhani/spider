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
    },
    {
      "class_name": "Svgs",
      "sub_groups": [
        {
          "path": "assets/svgsMenu",
          "prefix": "menu",
          "types": [
            ".svg"
          ]
        },
        {
          "path": "assets/svgsOther",
          "prefix": "other",
          "types": [
            ".svg"
          ]
        }
      ]
    },
    {
      "class_name": "Ico",
      "types": [
        ".ico"
      ],
      "prefix": "ico",
      "sub_groups": [
        {
          "path": "assets/icons",
          "prefix": "test1",
          "types": [
            ".ttf"
          ]
        },
        {
          "path": "assets/vectors",
          "prefix": "test2",
          "types": [
            ".pdf"
          ]
        }
      ]
    },
    {
      "class_name": "Video",
      "types": [
        ".mp4"
      ],
      "path": "assets/moviesOnly",
      "sub_groups": [
        {
          "path": "assets/movies",
          "prefix": "common"
        },
        {
          "path": "assets/moviesExtra",
          "prefix": "extra"
        }
      ]
    }
  ]
}''';
