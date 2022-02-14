import 'dart:io';

// command: update_formula.dart url sha path
void main(List<String> args) {
  if (args.length != 3) {
    print('Version, SHA and file path not specified.');
    exit(0);
  }

  final formulaFile = File(args[2]);
  String content = formulaFile.readAsStringSync();
  // Replace URL
  content = content.replaceFirst(RegExp(r'url\s\".*\"'),
      'url "https://github.com/BirjuVachhani/spider/archive/${args[0]}.tar.gz"');

  // Replace SHA
  content =
      content.replaceFirst(RegExp(r'sha256\s\".*\"'), 'sha256 "${args[1]}"');

  formulaFile.writeAsStringSync(content);
}
