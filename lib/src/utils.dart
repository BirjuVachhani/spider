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

import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:spider/src/spider_config.dart';
import 'package:yaml/yaml.dart';

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
  verbose('File ${p.basename(classFile.path)} is written successfully');
}

/// formats file extensions and adds preceding dot(.) if missing
String formatExtension(String ext) => ext.startsWith('.') ? ext : '.' + ext;

/// exits process with a message on command-line
void exit_with(String msg, [StackTrace stackTrace]) {
  error(msg, stackTrace);
  exitCode = 2;
  exit(2);
}

/// converts yaml file content into json compatible map
Map<String, dynamic> yamlToMap(String path) {
  final content = loadYaml(File(path).readAsStringSync());
  return json.decode(json.encode(content));
}

/// parses the config file and creates asset groups
SpiderConfiguration parseConfig(String path) {
  try {
    var yamlFile =
        file(p.join(path, 'spider.yaml')) ?? file(p.join(path, 'spider.yml'));
    final jsonFile = file(p.join(path, 'spider.json'));
    var map;
    if (yamlFile != null) {
      verbose('Loading configs from ${p.basename(yamlFile.path)}');
      map = yamlToMap(yamlFile.path);
    } else if (jsonFile != null) {
      verbose('Loading configs from ${p.basename(jsonFile.path)}');
      map = json.decode(jsonFile.readAsStringSync());
    } else {
      exit_with('Config not found. '
          'Create one using "spider create" command.');
    }
    verbose('Validating configs');
    validateConfigs(map);
    final config = SpiderConfiguration.fromJson(map);
    return config;
  } on Error catch (e) {
    verbose(e.toString());
    exit_with('Unable to parse configs!', e.stackTrace);
    return null;
  }
}

/// validates the configs of the configuration file
void validateConfigs(Map<String, dynamic> conf) {
  try {
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
      final paths = group['paths']?.cast<String>() ?? <String>[];
      if (paths.isEmpty && group['path'] != null) {
        paths.add(group['path'].toString());
      }
      if (paths == null || paths.isEmpty) {
        exit_with('Either no path is specified in the config '
            'or specified path is empty');
      }
      for (final dir in paths) {
        if (dir.contains('*')) {
          exit_with('Path ${dir} must not contain any wildcard.');
        }
        if (!Directory(dir).existsSync()) {
          exit_with('Path ${dir} does not exist!');
        }
        if (!FileSystemEntity.isDirectorySync(dir)) {
          exit_with('Path ${dir} is not a directory');
        }
        final dirName = p.basename(dir);
        if (RegExp(r'^\d.\dx$').hasMatch(dirName)) {
          exit_with('${dir} is not a valid asset directory.');
        }
      }
      if (group['class_name'] == null) {
        exit_with('Class name not specified for one of the groups.');
      }
      if (group['class_name']
          .replaceAll(' ', 'replace')
          .isEmpty) {
        exit_with('Empty class name is not allowed');
      }
      if (group['class_name'].contains(' ')) {
        exit_with('Class name must not contain spaces.');
      }
    }
  } on Error catch (e) {
    exit_with('Configs Validation failed', e.stackTrace);
  }
}

void checkFlutterProject() {
  var pubspec_path = p.join(Directory.current.path, 'pubspec.yaml');
  if (!File(pubspec_path).existsSync()) {
    exit_with('Current directory is not flutter project.\nPlease execute '
        'this command in a flutter project root path.');
  }
}

void error(String msg, [StackTrace stackTrace]) =>
    Logger('Spider').log(Level('ERROR', 1100), msg, null, stackTrace);

void info(String msg) => Logger('Spider').info(msg);

void warning(String msg) => Logger('Spider').warning(msg);

void verbose(String msg) => Logger('Spider').log(Level('DEBUG', 600), msg);

void success(String msg) => Logger('Spider').log(Level('SUCCESS', 1050), msg);
