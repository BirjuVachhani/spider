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

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import 'asset_group.dart';
import 'constants.dart';

/// Returns an instance of [File] if given [path] exists, null otherwise.
File file(String path) {
  var file = File(path);
  return file.existsSync() ? file : null;
}

/// Writes given [content] to the file with given [name] at given [path].
void writeToFile({String name, String path, String content}) {
  if (!Directory(p.join(Constants.LIB_FOLDER, path)).existsSync()) {
    Directory(p.join(Constants.LIB_FOLDER, path)).createSync(recursive: true);
  }
  var classFile = File(p.join(Constants.LIB_FOLDER, path, name));
  classFile.writeAsStringSync(content);
}

/// prints logs if the [verbose] flag is true
void printVerbose(bool verbose, String msg) {
  if (verbose) {
    stdout.writeln(msg);
  }
}

/// formats file extensions and adds preceding dot(.) if missing
String formatExtension(String ext) => ext.startsWith('.') ? ext : '.' + ext;

/// exits process with a message on command-line
void exit_with(String msg) {
  stderr.writeln(msg);
  exitCode = 2;
  exit(2);
}

/// converts yaml file content into json compatible map
Map<String, dynamic> yamlToMap(String path) {
  final content = loadYaml(File(path).readAsStringSync());
  return json.decode(json.encode(content));
}

/// parses the config file and creates asset groups
List<AssetGroup> parseConfig(String path) {
  try {
    var yamlFile =
        file(p.join(path, 'spider.yaml')) ?? file(p.join(path, 'spider.yml'));
    final jsonFile = file(p.join(path, 'spider.json'));
    var map;
    if (yamlFile != null) {
      map = yamlToMap(yamlFile.path);
    } else if (jsonFile != null) {
      map = json.decode(jsonFile.readAsStringSync());
    } else {
      exit_with('Config not found. '
          'Create one using "spider create" command.');
    }
    validateConfigs(map);
    var groups = <AssetGroup>[];
    map['groups']?.forEach((group) {
      groups.add(AssetGroup.fromJson(group));
    });
    return groups;
  } catch (e) {
    stderr.writeln(e);
    exit_with('Unable to parse configs!');
    return null;
  }
}

/// validates the configs of the configuration file
void validateConfigs(Map<String, dynamic> conf) {
  final groups = conf['groups'];
  if (groups == null) {
    exit_with('No groups found in the config file.');
  }
  if (groups.runtimeType != <dynamic>[].runtimeType) {
    exit_with('Groups must be a list of configurations.');
  }
  for (var group in groups) {
    group.forEach((key, value) {
      if (value == null) exit_with('$key cannot be null');
    });

    if (group['path'] == null) {
      exit_with('No path provided for one of the groups.');
    }

    if (File(group['path']).statSync().type != FileSystemEntityType.directory) {
      exit_with('Path ${group['path']} must be a directory');
    }

    if (!Directory(group['path']).existsSync()) {
      exit_with('${group['path']} does not exist');
    }

    if (group['class_name'] == null) {
      exit_with('No class name provided for one of the groups.');
    }
  }
}
