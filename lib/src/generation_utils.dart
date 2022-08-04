// Copyright © 2020 Birju Vachhani. All rights reserved.
// Use of this source code is governed by an Apache license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:path/path.dart' as p;

import 'cli/utils/utils.dart';
import 'data/class_template.dart';
import 'data/export_template.dart';
import 'data/test_template.dart';

/// Writes given [content] to the file with given [name] at given [path].
void writeToFile(
    {String? name, String? path, required String content, BaseLogger? logger}) {
  if (!Directory(p.join(Constants.LIB_FOLDER, path)).existsSync()) {
    Directory(p.join(Constants.LIB_FOLDER, path)).createSync(recursive: true);
  }
  var classFile = File(p.join(Constants.LIB_FOLDER, path, name));
  classFile.writeAsStringSync(content);
  logger?.verbose('File ${p.basename(classFile.path)} is written successfully');
}

/// formats file extensions and adds preceding dot(.) if missing
String formatExtension(String ext) => ext.startsWith('.') ? ext : '.$ext';

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
