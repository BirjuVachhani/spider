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

/// Holds group information for assets sub directories
class AssetGroup {
  final String path;
  final String className;
  final String package;
  final bool useUnderScores;
  final bool useStatic;
  final bool useConst;
  final String prefix;
  final String fileName;
  final List<String> types;

  AssetGroup(
      {this.fileName,
      this.path,
      this.className,
      this.package,
      this.types = const <String>[],
      this.useUnderScores = false,
      this.useStatic = true,
      this.useConst = true,
      this.prefix = ''});
}
