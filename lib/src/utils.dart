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
// Created Date: February 02, 2020

import 'dart:io';

import 'package:path/path.dart' as p;

import 'constants.dart';

File file(String path) {
  var file = File(path);
  return file.existsSync() ? file : null;
}

String formatFileName(String name) {
  name = name
      .replaceAllMapped(
      RegExp(r'[A-Z]+'), (match) => '_' + match.group(0).toLowerCase())
      .replaceFirst(RegExp(r'^_+'), '');
  return name.contains('.dart') ? name : name + '.dart';
}

void writeToFile({String name, String path, String content}) {
  if (!Directory(p.join(Constants.LIB_FOLDER, path)).existsSync()) {
    Directory(p.join(Constants.LIB_FOLDER, path)).createSync(recursive: true);
  }
  var classFile = File(p.join(Constants.LIB_FOLDER, path, name));
  classFile.writeAsStringSync(content);
}
