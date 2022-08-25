// Copyright © 2020 Birju Vachhani. All rights reserved.
// Use of this source code is governed by an Apache license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sprintf/sprintf.dart';
import 'package:yaml/yaml.dart';

import 'utils.dart';

/// Represents a typical json map.
typedef JsonMap = Map<String, dynamic>;

/// Returns an instance of [File] if given [path] exists, null otherwise.
File? file(String path) {
  var file = File(path);
  return file.existsSync() ? file : null;
}

/// Checks whether the directory in which the command has been fired is a
/// dart/flutter project or not.
bool isFlutterProject() {
  final pubspecFile = file(p.join(Directory.current.path, 'pubspec.yaml')) ??
      file(p.join(Directory.current.path, 'pubspec.yml'));
  return pubspecFile != null && pubspecFile.existsSync();
}

/// converts yaml file content into json compatible map
Map<String, dynamic> yamlToMap(String path) {
  final content = loadYaml(File(path).readAsStringSync());
  return json.decode(json.encode(content));
}

/// validates the configs of the configuration file.
/// [allowEmpty] if set to true, would consider configs as valid even if no
/// groups are provided and fonts is not set.
Result<bool> validateConfigs(Map<String, dynamic> conf,
    {bool allowEmpty = false}) {
  try {
    final groups = conf['groups'];
    if (groups != null) {
      if (groups is! Iterable) {
        return Result.error(ConsoleMessages.invalidGroupsType);
      }
      for (final group in groups) {
        for (final entry in group.entries) {
          if (entry.value == null) {
            return Result.error(
                sprintf(ConsoleMessages.nullValueError, [entry.key]));
          }
        }
        if (group['paths'] != null || group['path'] != null) {
          final paths = List<String>.from(group['paths'] ?? <String>[]);
          if (paths.isEmpty && group['path'] != null) {
            paths.add(group['path'].toString());
          }
          if (paths.isEmpty) {
            return Result.error(ConsoleMessages.noPathInGroupError);
          }
          for (final dir in paths) {
            final result = _assertDir(dir);
            if (result.isError) return result;
          }
        } else {
          if (group['sub_groups'] == null) {
            return Result.error(ConsoleMessages.noPathInGroupError);
          }
          for (final subgroup in group['sub_groups']) {
            final paths = List<String>.from(subgroup['paths'] ?? <String>[]);
            if (paths.isEmpty && subgroup['path'] != null) {
              paths.add(subgroup['path'].toString());
            }
            if (paths.isEmpty) {
              return Result.error(ConsoleMessages.noPathInGroupError);
            }
            for (final dir in paths) {
              final result = _assertDir(dir);
              if (result.isError) return result;
            }
          }
        }
        if (group['class_name'] == null) {
          return Result.error(ConsoleMessages.noClassNameError);
        }
        if (group['class_name'].toString().trim().isEmpty) {
          return Result.error(ConsoleMessages.emptyClassNameError);
        }
        if (group['class_name'].contains(' ')) {
          return Result.error(ConsoleMessages.classNameContainsSpacesError);
        }
      }
      return Result.success(true);
    } else if (conf['fonts'] != null) {
      final fontsConfig = conf['fonts'];
      if (fontsConfig == false) {
        return Result.error(ConsoleMessages.nothingToGenerate);
      }

      if (fontsConfig == true) {
        return Result.success(true);
      }

      if (fontsConfig is! Map) {
        return Result.error(ConsoleMessages.invalidFontsConfig);
      }

      // Check for other configs here if required
      return Result.success(true);
    }

    if (allowEmpty) return Result.success(true);

    return Result.error(ConsoleMessages.nothingToGenerate);
  } on Error catch (e) {
    return Result.error(ConsoleMessages.configValidationFailed, e.stackTrace);
  }
}

/// validates the path to directory
Result<bool> _assertDir(String dir) {
  if (dir.contains('*')) {
    return Result.error(sprintf(ConsoleMessages.noWildcardInPathError, [dir]));
  }

  final uri = Uri.parse(dir);
  final resolvedDir = uri.pathSegments.first !=
          Constants.PACKAGE_ASSET_PATH_PREFIX
      ? dir
      : p.join(Constants.LIB_FOLDER, p.joinAll(uri.pathSegments.sublist(2)));
  if (!FileSystemEntity.isDirectorySync(resolvedDir)) {
    return Result.error(sprintf(ConsoleMessages.pathNotExistsError, [dir]));
  }

  final dirName = p.basename(dir);
  if (RegExp(r'^\d.\dx$').hasMatch(dirName)) {
    return Result.error(sprintf(ConsoleMessages.invalidAssetDirError, [dir]));
  }
  return Result.success(true);
}
