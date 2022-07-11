import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sprintf/sprintf.dart';
import 'package:yaml/yaml.dart';

import 'constants.dart';
import 'logging.dart';

typedef JsonMap = Map<String, dynamic>;

/// Returns an instance of [File] if given [path] exists, null otherwise.
File? file(String path) {
  var file = File(path);
  return file.existsSync() ? file : null;
}

/// Checks whether the directory in which the command has been fired is a
/// dart/flutter project or not.
bool isFlutterProject() {
  final pubspecFile = file('pubspec.yaml') ?? file('pubspec.yml');
  return pubspecFile != null && pubspecFile.existsSync();
}

/// converts yaml file content into json compatible map
Map<String, dynamic> yamlToMap(String path) {
  final content = loadYaml(File(path).readAsStringSync());
  return json.decode(json.encode(content));
}

/// validates the configs of the configuration file
void validateConfigs(Map<String, dynamic> conf, [BaseLogger? logger]) {
  try {
    final groups = conf['groups'];
    if (groups == null) {
      logger?.exitWith(ConsoleMessages.noGroupsFound);
    }
    if (groups.runtimeType != <dynamic>[].runtimeType) {
      logger?.exitWith(ConsoleMessages.invalidGroupsType);
    }
    for (final group in groups) {
      group.forEach((key, value) {
        if (value == null) {
          logger?.exitWith(sprintf(ConsoleMessages.nullValueError, [key]));
        }
      });
      if (group['paths'] != null || group['path'] != null) {
        final paths = List<String>.from(group['paths'] ?? <String>[]);
        if (paths.isEmpty && group['path'] != null) {
          paths.add(group['path'].toString());
        }
        if (paths.isEmpty) {
          logger?.exitWith(ConsoleMessages.noPathInGroupError);
        }
        for (final dir in paths) {
          _assertDir(dir, logger);
        }
      } else {
        if (group['sub_groups'] == null) {
          logger?.exitWith(ConsoleMessages.noSubgroupsFound);
        }
        for (final subgroup in group['sub_groups']) {
          final paths = List<String>.from(subgroup['paths'] ?? <String>[]);
          if (paths.isEmpty && subgroup['path'] != null) {
            paths.add(subgroup['path'].toString());
          }
          if (paths.isEmpty) {
            logger?.exitWith(ConsoleMessages.noPathInGroupError);
          }
          for (final dir in paths) {
            _assertDir(dir, logger);
          }
        }
      }
      if (group['class_name'] == null) {
        logger?.exitWith(ConsoleMessages.noClassNameError);
      }
      if (group['class_name'].toString().trim().isEmpty) {
        logger?.exitWith(ConsoleMessages.emptyClassNameError);
      }
      if (group['class_name'].contains(' ')) {
        logger?.exitWith(ConsoleMessages.classNameContainsSpacesError);
      }
    }
  } on Error catch (e) {
    logger?.exitWith(ConsoleMessages.configValidationFailed, e.stackTrace);
  }
}

/// validates the path to directory
void _assertDir(String dir, [BaseLogger? logger]) {
  if (dir.contains('*')) {
    logger?.exitWith(sprintf(ConsoleMessages.noWildcardInPathError, [dir]));
  }
  if (!Directory(dir).existsSync()) {
    logger?.exitWith(sprintf(ConsoleMessages.pathNotExistsError, [dir]));
  }
  final dirName = p.basename(dir);
  if (RegExp(r'^\d.\dx$').hasMatch(dirName)) {
    logger?.exitWith(sprintf(ConsoleMessages.invalidAssetDirError, [dir]));
  }
}
