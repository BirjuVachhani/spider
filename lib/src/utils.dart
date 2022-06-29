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

import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:spider/src/data/class_template.dart';
import 'package:spider/src/data/test_template.dart';
import 'package:spider/src/version.dart';
import 'package:sprintf/sprintf.dart';
import 'package:yaml/yaml.dart';

import 'constants.dart';
import 'data/export_template.dart';
import 'process_terminator.dart';

/// Returns an instance of [File] if given [path] exists, null otherwise.
File? file(String path) {
  var file = File(path);
  return file.existsSync() ? file : null;
}

/// Writes given [content] to the file with given [name] at given [path].
void writeToFile({String? name, String? path, required String content}) {
  if (!Directory(p.join(Constants.LIB_FOLDER, path)).existsSync()) {
    Directory(p.join(Constants.LIB_FOLDER, path)).createSync(recursive: true);
  }
  var classFile = File(p.join(Constants.LIB_FOLDER, path, name));
  classFile.writeAsStringSync(content);
  verbose('File ${p.basename(classFile.path)} is written successfully');
}

/// formats file extensions and adds preceding dot(.) if missing
String formatExtension(String ext) => ext.startsWith('.') ? ext : '.$ext';

/// exits process with a message on command-line
void exitWith(String msg, [StackTrace? stackTrace]) {
  ProcessTerminator.getInstance().terminate(msg, stackTrace);
}

/// converts yaml file content into json compatible map
Map<String, dynamic> yamlToMap(String path) {
  final content = loadYaml(File(path).readAsStringSync());
  return json.decode(json.encode(content));
}

/// validates the configs of the configuration file
void validateConfigs(Map<String, dynamic> conf) {
  try {
    final groups = conf['groups'];
    if (groups == null) {
      exitWith(ConsoleMessages.noGroupsFound);
    }
    if (groups.runtimeType != <dynamic>[].runtimeType) {
      exitWith(ConsoleMessages.invalidGroupsType);
    }
    for (final group in groups) {
      group.forEach((key, value) {
        if (value == null) {
          exitWith(sprintf(ConsoleMessages.nullValueError, [key]));
        }
      });
      for (final subgroup in group['subgroups']) {
        final paths = List<String>.from(subgroup['paths'] ?? <String>[]);
        if (paths.isEmpty && subgroup['path'] != null) {
          paths.add(subgroup['path'].toString());
        }
        if (paths.isEmpty) {
          exitWith(ConsoleMessages.noPathInGroupError);
        }
        for (final dir in paths) {
          if (dir.contains('*')) {
            exitWith(sprintf(ConsoleMessages.noWildcardInPathError, [dir]));
          }
          if (!Directory(dir).existsSync()) {
            exitWith(sprintf(ConsoleMessages.pathNotExistsError, [dir]));
          }
          final dirName = p.basename(dir);
          if (RegExp(r'^\d.\dx$').hasMatch(dirName)) {
            exitWith(sprintf(ConsoleMessages.invalidAssetDirError, [dir]));
          }
        }
      }
      if (group['class_name'] == null) {
        exitWith(ConsoleMessages.noClassNameError);
      }
      if (group['class_name'].toString().trim().isEmpty) {
        exitWith(ConsoleMessages.emptyClassNameError);
      }
      if (group['class_name'].contains(' ')) {
        exitWith(ConsoleMessages.classNameContainsSpacesError);
      }
    }
  } on Error catch (e) {
    exitWith(ConsoleMessages.configValidationFailed, e.stackTrace);
  }
}

/// Checks whether the directory in which the command has been fired is a
/// dart/flutter project or not. Exits with error message if it is not.
void checkFlutterProject() {
  var pubspecPath = p.join(Directory.current.path, 'pubspec.yaml');
  if (!File(pubspecPath).existsSync()) {
    exitWith(ConsoleMessages.notFlutterProjectError);
  }
}

/// Constructs source code for a dart class from [classTemplate].
/// [className] is a valid dart class name.
/// [references] defines all the generated asset references that are
/// to be put inside this class as constants.
/// [noComments] flag determines whether to add auto generated comments
/// to this class or not.
/// [usePartOf] flag determines whether to generate a `part of` directive
/// in this file or not. It helps to unify imports for all the asset classes.
/// [exportFileName] defines the dart compatible file name for this class.
///
/// Returns source code of a dart class file that contains all the references
/// as constants.
String getDartClass({
  required String className,
  required String references,
  bool noComments = false,
  required bool usePartOf,
  String? exportFileName,
  required String? valuesList,
}) {
  var content = '';
  if (!noComments) {
    content += timeStampComment.replaceAll(
        Constants.KEY_TIME, DateTime.now().toString());
  }
  if (usePartOf) {
    content +=
        partOfTemplate.replaceAll(Constants.KEY_FILE_NAME, exportFileName!);
  }

  content += classTemplate
      .replaceAll(Constants.KEY_CLASS_NAME, className)
      .replaceAll(Constants.KEY_REFERENCES, references)
      .replaceAll(Constants.KEY_LIST_OF_ALL_REFERENCES, valuesList ?? '');
  return content;
}

/// Generates library export file contents like export statements for all the
/// generated files.
/// [fileNames] contains all the generated file names that are to be exported.
/// [noComments] flag determines whether to add auto generated comments
/// to this class or not.
/// [usePartOf] flag determines whether to generate a `part` directive
/// in this file or not. It helps to unify imports for all the asset classes.
String getExportContent({
  required List<String> fileNames,
  required bool noComments,
  bool usePartOf = false,
}) {
  var content = '';
  if (!noComments) {
    content += timeStampComment.replaceAll(
        Constants.KEY_TIME, DateTime.now().toString());
  }
  content += fileNames
      .map<String>((item) => (usePartOf ? partTemplate : exportFileTemplate)
          .replaceAll(Constants.KEY_FILE_NAME, item))
      .toList()
      .join('\n\n');
  return content;
}

/// Generates a single constant declaration dart code.
/// [properties] defines access modifiers and type of the reference variable.
/// e.g. const, static.
/// [assetName] defines the reference variable name to be used.
/// [assetPath] defines the actual asset location that will be value of the
/// generated reference variable.
String getReference({
  required String properties,
  required String assetName,
  required String assetPath,
}) {
  return referenceTemplate
      .replaceAll(Constants.KEY_PROPERTIES, properties)
      .replaceAll(Constants.KEY_ASSET_NAME, assetName)
      .replaceAll(Constants.KEY_ASSET_PATH, assetPath);
}

/// Generates a value declaration dart code which contains a list of references.
/// [properties] defines access modifiers and type of the reference variable.
/// e.g. const, static.
/// [assetNames] defines the list of reference variable names.
String getListOfReferences({
  required String properties,
  required List<String> assetNames,
}) {
  return referencesTemplate
      .replaceAll(Constants.KEY_PROPERTIES, properties)
      .replaceAll(Constants.KEY_LIST_OF_ALL_REFERENCES, assetNames.toString());
}

/// Generates test class for the generated references file.
/// [project] and [package] and [importFileName] is used to
/// generate required import statements.
/// [importFileName] defines file to be imported for this test.
/// [fileName] defines the file name for tests to be generated.
/// [noComments] flag determines whether to add auto generated comments
/// to this class or not.
/// [tests] defines all the tests to be put inside this test file.
String getTestClass({
  required String project,
  required String package,
  required String fileName,
  required String tests,
  required bool noComments,
  required String importFileName,
  required String testImport,
}) {
  var content = '';
  if (!noComments) {
    content += timeStampTemplate.replaceAll(
        Constants.KEY_TIME, DateTime.now().toString());
  }
  content += testTemplate
      .replaceAll(Constants.KEY_PROJECT_NAME, project)
      .replaceAll(Constants.KEY_PACKAGE, package)
      .replaceAll(Constants.KEY_FILE_NAME, fileName)
      .replaceAll(Constants.KEY_IMPORT_FILE_NAME, importFileName)
      .replaceAll(Constants.KEY_TESTS, tests)
      .replaceAll(Constants.TEST_IMPORT, testImport);
  return content;
}

/// Generates a single test for given [assetName] asset.
/// [className] denotes the name of the class this asset reference variable
/// belongs to.
String getTestCase(String className, String assetName) {
  return expectTestTemplate
      .replaceAll(Constants.KEY_CLASS_NAME, className)
      .replaceAll(Constants.KEY_ASSET_NAME, assetName);
}

/// Logs given [msg] as an error to the console. [stackTrace] gets logged as
/// well if provided.
void error(String msg, [StackTrace? stackTrace]) =>
    Logger('Spider').log(Level('ERROR', 1100), msg, null, stackTrace);

/// Logs given [msg] at info level to the console.
void info(String msg) => Logger('Spider').info(msg);

/// Logs given [msg] at warning level to the console.
void warning(String msg) => Logger('Spider').warning(msg);

/// Logs given [msg] at verbose level to the console.
void verbose(String msg) => Logger('Spider').log(Level('DEBUG', 600), msg);

/// Logs given [msg] at success level to the console.
void success(String msg) => Logger('Spider').log(Level('SUCCESS', 1050), msg);

/// A web scraping script to get latest version available for this package
/// on https://pub.dev.
/// Returns an empty string if fails to extract it.
Future<String> fetchLatestVersion() async {
  try {
    final html = await http
        .get(Uri.parse('https://pub.dev/packages/spider'))
        .timeout(Duration(seconds: 3));

    final document = parser.parse(html.body);

    var jsonScript =
        document.querySelector('script[type="application/ld+json"]')!;
    var json = jsonDecode(jsonScript.innerHtml);
    final version = json['version'] ?? '';
    return RegExp(Constants.VERSION_REGEX).hasMatch(version) ? version : '';
  } catch (error, stacktrace) {
    verbose(error.toString());
    verbose(stacktrace.toString());
    // unable to get version
    return '';
  }
}

/// Fetches the latest version available of this package on https://pub.dev and
/// check whether to show new version available info in the console or not.
Future<bool> checkForNewVersion() async {
  try {
    final latestVersion = await fetchLatestVersion();
    if (packageVersion != latestVersion && latestVersion.isNotEmpty) {
      stdout.writeln(Constants.NEW_VERSION_AVAILABLE
          .replaceAll('X.X.X', packageVersion)
          .replaceAll('Y.Y.Y', latestVersion));
      sleep(Duration(seconds: 2));
      return true;
    }
    return false;
  } catch (error, stacktrace) {
    verbose(error.toString());
    verbose(stacktrace.toString());
    // something wrong happened!
    return false;
  }
}
