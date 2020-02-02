// Allow to specify and use custom configurations for this library
// the configurations should be specified in a yml file
import 'dart:io';

import 'package:spider/src/constants.dart';
import 'package:spider/src/utils.dart';
import 'package:yaml/yaml.dart';

class Configuration {
  final String _path;
  var _configs;
  var _defaults;

  Configuration(this._path) {
    _defaults = loadYaml(Constants.DEFAULT_CONFIGS_STRING);
    _initialize();
  }

  void _initialize() {
    if (!Directory(_path).existsSync()) {
      print('$_path does not exists!');
      exitCode = 2;
      return;
    }

    var configFile = file(Constants.CONFIG_FILE_NAME) ?? file('spider.yml');
    if (configFile != null) {
      _configs = loadYaml(File(Constants.CONFIG_FILE_NAME).readAsStringSync());
    } else {
      _configs = _defaults;
    }
  }

  operator [](String name) => _configs[name] ?? _defaults[name];
}
