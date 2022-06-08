import 'package:args/args.dart';
import 'package:spider/src/utils.dart';

/// Parses command-line arguments and returns results
ArgResults? parseArguments(List<String> arguments) {
  final createParser = ArgParser()
    ..addFlag('json',
        help: 'generates json type of config file', negatable: false, abbr: 'j')
    ..addFlag(
      'add-in-pubspec',
      help: 'Allows to create spider config inside pubspec.yaml file.',
      negatable: false,
    )
    ..addOption('path', help: 'Path to spider config file', abbr: 'p');

  final buildParser = ArgParser()
    ..addFlag('watch',
        abbr: 'w',
        negatable: false,
        help: 'Watches for any file changes and re-generates dart code')
    ..addFlag('smart-watch',
        negatable: false,
        help:
            'Smartly watches for file changes that matters and re-generates dart code')
    ..addFlag('fonts-only',
        negatable: false,
        help:
            'Only triggers code-gen for fonts if generate_fonts: true in config file')
    ..addFlag('verbose',
        abbr: 'v', negatable: false, help: 'prints verbose logs');

  final parser = ArgParser()
    ..addCommand('create', createParser)
    ..addCommand('build', buildParser)
    ..addFlag('help',
        abbr: 'h', help: 'prints usage information', negatable: false)
    ..addFlag('version', abbr: 'v', help: 'prints current version')
    ..addFlag('info', abbr: 'i', help: 'print library info', negatable: false)
    ..addFlag('check-updates',
        abbr: 'u', help: 'Check for update', negatable: false)
    ..addOption('path', abbr: 'p', help: 'Directory of the config file.');

  try {
    var result = parser.parse(arguments);
    return result;
  } on Error catch (e) {
    exitWith(
        'Invalid command input. see spider --help for info.', e.stackTrace);
    return null;
  }
}
