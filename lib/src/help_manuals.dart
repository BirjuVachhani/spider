/*
 * Copyright © $YEAR Birju Vachhani
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
// Created Date: February 07, 2020

class HelpManuals {
  static const SPIDER_HELP = '''

Spider CLI Tool
  Spider is a command-line tool to generate painless dart code for assets
  of your flutter project. It uses 'spider2.yaml' to configure and organize
  generated dart code.
  
  COMMANDS:
  
  build             Generates dart code for assets
  create            Creates config file in the root of the project
  
  ARGUMENTS:
  -h, --help, -?    Show help
  -v, --version,    Show current version''';

  static const CREATE_HELP = '''

spider create [arguments]
  creates 'spider.yaml' file in the current working directory. This config file
  is used to control and manage generation of the dart code.
  
  ARGUMENTS:
  -h, --help, -?    Show help''';

  static const BUILD_HELP = '''

spider build [arguments]
  Generates dart code for assets of your flutter project. 'spider2.yaml' file is
  used by this command to generate dart code.
  
  ARGUMENTS:
  -w, --watch       Watches assets directory for file changes and re-generates
                    dart code upon file creation, deletion or modification.
  -v, --verbose     Shows verbose logs
  -h, --help, -?    Show help''';
}
