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

import 'package:yaml/yaml.dart';

import 'constants.dart';
import 'utils.dart';

// Allow to specify and use custom configurations for this library
// the configurations should be specified in a yml file
class Configuration {
  final String _path;
  var configs;
  var _defaults;

  Configuration(this._path) {
    _defaults = loadYaml(Constants.DEFAULT_CONFIGS_STRING);
    _initialize();
  }

  /// loads spider.yaml file
  void _initialize() {
    try {
      var configFile = file(Constants.CONFIG_FILE_NAME) ?? file('spider.yml');
      if (configFile != null) {
        configs = loadYaml(File(Constants.CONFIG_FILE_NAME).readAsStringSync());
      } else {
        var jsonFile = file('spider.json');
        if (jsonFile != null) {
          configs = json.decode(jsonFile.readAsStringSync());
        } else {
          exit_with('Config file not found. Please run spider create to '
              'generate a config file.');
        }
      }
    } catch (e) {
      stderr.writeln('Unable to parse config file');
      print(e);
      exit(6);
    }
  }

  /// allows to access yaml data directly
  dynamic operator [](String name) => configs[name] ?? _defaults[name];
}
