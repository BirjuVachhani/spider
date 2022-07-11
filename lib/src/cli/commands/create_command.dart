import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;
import 'package:sprintf/sprintf.dart';
import 'package:yaml/yaml.dart';

import '../flag_commands/flag_commands.dart';
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

    // Check for updates.
    await CheckUpdatesFlagCommand.checkForNewVersion(logger);

    final bool isJson = results.getFlag(FlagNames.json);
    final bool addInPubspec = results.getFlag(FlagNames.addInPubspec);
    final String? path = results[OptionNames.path];

    final result = ConfigCreator(logger)
        .create(addInPubspec: addInPubspec, isJson: isJson, path: path);

    if (result.isError) {
      if (result.exception != null) verbose(result.exception.toString());
      if (result.stacktrace != null) verbose(result.stacktrace.toString());
      exitWith(result.error);
    }
  }
}

class ConfigCreator {
  final BaseLogger? logger;

  ConfigCreator([this.logger]);

  Result<void> create({
    bool addInPubspec = false,
    bool isJson = false,
    String? path,
  }) {
    try {
      if (addInPubspec) {
        final result = createConfigsInPubspec();
        if (result.isError) return result;
        return Result.success();
      }
      if (path != null && path.isNotEmpty) {
        final result = createConfigFileAtCustomPath(path, isJson);
        if (result.isError) return result;
        return Result.success();
      }
      final result = createConfigFileInCurrentDirectory(isJson);
      if (result.isError) return result;
      return Result.success();
    } on Error catch (error, stacktrace) {
      return Result.error('Unable to create config file', error, stacktrace);
    }
  }

  Result<void> createConfigsInPubspec() {
    final pubspecFile = file(p.join(Directory.current.path, 'pubspec.yaml')) ??
        file(p.join(Directory.current.path, 'pubspec.yml'));
    if (pubspecFile == null) {
      return Result.error(ConsoleMessages.pubspecNotFound);
    }
    final pubspecContent = pubspecFile.readAsStringSync();
    final pubspec = loadYaml(pubspecContent);
    if (pubspec['spider'] != null) {
      return Result.error(ConsoleMessages.configExistsInPubspec);
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
      logger?.success(ConsoleMessages.configCreatedInPubspec);
      return Result.success();
    } on Error catch (error, stacktrace) {
      return Result.error(
          ConsoleMessages.unableToAddConfigInPubspec, error, stacktrace);
    }
  }

  /// Creates config file at custom path.
  Result<void> createConfigFileAtCustomPath(String path, bool isJson) {
    String filePath;
    if (path.startsWith('/')) path = '.$path';
    if (FileSystemEntity.isDirectorySync(path)) {
      // provided path is an existing directory
      Directory(path).createSync(recursive: true);
      filePath = p.join(path, isJson ? 'spider.json' : 'spider.yaml');
    } else {
      final String extension = p.extension(path);
      if (extension.isNotEmpty) {
        return Result.error('Provided path is not a valid directory.');
      }
      Directory(path).createSync(recursive: true);
      filePath = p.join(path, isJson ? 'spider.json' : 'spider.yaml');
    }
    final content = p.extension(filePath) == '.json'
        ? DefaultConfigTemplates.jsonFormat
        : DefaultConfigTemplates.yamlFormat;
    final file = File(filePath);
    if (file.existsSync()) {
      return Result.error('Config file already exists at $filePath.');
    }
    file.writeAsStringSync(content);
    logger
        ?.success(sprintf(ConsoleMessages.fileCreatedAtCustomPath, [filePath]));
    return Result.success();
  }

  Result<void> createConfigFileInCurrentDirectory(bool isJson) {
    final filename = isJson ? 'spider.json' : 'spider.yaml';
    final dest = File(p.join(Directory.current.path, filename));
    final content = isJson
        ? DefaultConfigTemplates.jsonFormat
        : DefaultConfigTemplates.yamlFormat;
    if (dest.existsSync()) {
      logger?.info('Config file already exists. Overwriting configs...');
    }
    dest.writeAsStringSync(content);
    logger?.success('Configuration file created successfully.');
    return Result.success();
  }
}
