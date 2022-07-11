import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;
import 'package:sprintf/sprintf.dart';
import 'package:yaml/yaml.dart';

import '../models/command_names.dart';
import '../models/default_config_templates.dart';
import '../models/flag_names.dart';
import '../utils/utils.dart';
import 'base_command.dart';

/// Command to create a Spider configuration file.
class CreateCommand extends BaseCommand {
  @override
  String get description =>
      "creates 'spider.yaml' file in the current working directory. This "
      "config file is used to control and manage generation of the dart code.";

  @override
  String get name => CommandNames.create;

  @override
  String get summary => 'Creates config file in the root of the project.';

  CreateCommand(super.logger) {
    argParser
      ..addFlag(FlagNames.addInPubspec,
          negatable: false,
          help: 'Adds the generated config file to the pubspec.yaml file.')
      ..addFlag(FlagNames.json,
          abbr: 'j',
          negatable: false,
          help: 'Generates config file of type JSON rather than YAML.')
      ..addOption(OptionNames.path,
          abbr: 'p',
          help: 'Allows to provide custom directory path for the config file.');
  }

  @override
  Future<void> run() async {
    final ArgResults results = argResults!;

    final bool isJson = results.getFlag(FlagNames.json);
    final bool addInPubspec = results.getFlag(FlagNames.addInPubspec);
    final String? path = results[OptionNames.path];

    try {
      if (addInPubspec) {
        createConfigsInPubspec();
        return;
      }
      if (path != null && path.isNotEmpty) {
        createConfigFileAtCustomPath(path, isJson);
        return;
      }
      createConfigFileInCurrentDirectory(isJson);
    } on Error catch (e) {
      exitWith('Unable to create config file', e.stackTrace);
    }
  }

  void createConfigsInPubspec() {
    final pubspecFile = file('pubspec.yaml') ?? file('pubspec.yml');
    if (pubspecFile == null) {
      exitWith(ConsoleMessages.pubspecNotFound);
      return;
    }
    final pubspecContent = pubspecFile.readAsStringSync();
    final pubspec = loadYaml(pubspecContent);
    if (pubspec['spider'] != null) {
      exitWith(ConsoleMessages.configExistsInPubspec);
      return;
    }
    try {
      final lines = pubspecFile.readAsLinesSync();
      String configContent = DefaultConfigTemplates.pubspecFormat;
      if (lines.last.trim().isNotEmpty || !lines.last.endsWith('\n')) {
        configContent = '\n\n$configContent';
      }
      pubspecFile.openWrite(mode: FileMode.writeOnlyAppend)
        ..write(configContent)
        ..close();
      success(ConsoleMessages.configCreatedInPubspec);
    } on Error catch (e) {
      exitWith(ConsoleMessages.unableToAddConfigInPubspec, e.stackTrace);
    }
  }

  /// Creates config file at custom path.
  void createConfigFileAtCustomPath(String path, bool isJson) {
    String filePath;
    if (path.startsWith('/')) path = '.$path';
    if (FileSystemEntity.isDirectorySync(path)) {
      // provided path is an existing directory
      Directory(path).createSync(recursive: true);
      filePath = p.join(path, isJson ? 'spider.json' : 'spider.yaml');
    } else {
      final String extension = p.extension(path);
      if (extension.isNotEmpty) {
        exitWith('Provided path is not a valid directory.');
        return;
      }
      Directory(path).createSync(recursive: true);
      filePath = p.join(path, isJson ? 'spider.json' : 'spider.yaml');
    }
    final content = p.extension(filePath) == '.json'
        ? DefaultConfigTemplates.jsonFormat
        : DefaultConfigTemplates.yamlFormat;
    final file = File(filePath);
    if (file.existsSync()) {
      exitWith('Config file already exists at $filePath.');
      return;
    }
    file.writeAsStringSync(content);
    success(sprintf(ConsoleMessages.fileCreatedAtCustomPath, [filePath]));
  }

  void createConfigFileInCurrentDirectory(bool isJson) {
    final filename = isJson ? 'spider.json' : 'spider.yaml';
    final dest = File(p.join(Directory.current.path, filename));
    final content = isJson
        ? DefaultConfigTemplates.jsonFormat
        : DefaultConfigTemplates.yamlFormat;
    if (dest.existsSync()) {
      info('Config file already exists. Overwriting configs...');
    }
    dest.writeAsStringSync(content);
    success('Configuration file created successfully.');
  }
}
