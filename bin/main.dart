import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as Path;
import 'package:spider/spider.dart';

void main(List<String> arguments) {
  var pubspec_path = Path.join(Directory.current.path, 'pubspec.yaml');
  if (!File(pubspec_path).existsSync()) {
    print(
        'Current directory is not flutter project. Please execute this command in a flutter project root path');
    exit(0);
  }
  exitCode = 0;
  final initParser = ArgParser()..addOption('file', abbr: 'f');
  final parser = ArgParser()..addCommand('init', initParser);

  final argResults = parser.parse(arguments);

  if (argResults.command == null) {
    final spider = Spider(Directory.current.path);
//    spider.listen_for_changes();
    spider.generate_code();
  } else {
    Spider.init_configs();
  }
}
