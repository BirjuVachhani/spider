import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as Path;
import 'package:spider/src/Configuration.dart';
import 'package:spider/src/constants.dart';

class Spider {
  final String _path;
  Configuration configs;
  bool processing = false;
  final _fileRegex = RegExp(r'\.(jpe?g|png|gif|ico|svg|ttf|eot|woff|woff2)$',
      caseSensitive: false);

  Spider(this._path) {
    _initialize();
    configs = Configuration(_path);
  }

  void _initialize() async {
    if (!await Directory(_path).exists()) {}
  }

  void listen_for_changes() {
    print('Watching for changes in directory ${configs["path"]}...');
    Directory(configs['path'])
        .watch(events: FileSystemEvent.all)
        .listen((data) {
      print('something happened $data');
      if (!processing) {
        processing = true;
        Future.delayed(Duration(seconds: 2), () => generate_code());
      }
    });
  }

  void generate_code() {
    if (!Directory(configs['path']).existsSync()) {
      print('Directory "${configs['path']}" does not exist!');
      exit(2);
    }
    var files = Directory(configs['path'])
        .listSync()
        .where((file) =>
            File(file.path).statSync().type == FileSystemEntityType.file &&
            _fileRegex.hasMatch(Path.basename(file.path)))
        .toList();

    if (files.isEmpty) {
      print('Directory ${configs['path']} does not contain any assets!');
      exit(2);
    }
    generate_dart_class(files);
    processing = false;
  }

  static void init_configs() async {
    var configFile = File(Constants.CONFIG_FILE_NAME);
    await configFile.writeAsString(Constants.DEFAULT_CONFIGS_STRING);
    print('Configuration file created successfully');
  }

  void generate_dart_class(List<FileSystemEntity> files) {
    print('Generating dart code...');
    var values = files.map<String>((file) {
      var name = _formatName(Path.basenameWithoutExtension(file.path));
      var dir = Path.dirname(file.path);
      var filename = Path.basename(file.path);
      return "\tstatic const String $name = '$dir/$filename';";
    }).toList();
    var final_values = values.join('\n');
    var final_class = '''class ${configs['class_name']} {
$final_values
}''';
    if (!Directory('lib/' + configs['package']).existsSync()) {
      Directory('lib/' + configs['package']).createSync();
    }
    var classFile = File(Path.join('lib', configs['package'],
        '${configs['class_name'].toString().toLowerCase()}.dart'));
    classFile.writeAsStringSync(final_class);
    print('Processed items: ${values.length}');
    print('Dart code generated successfully');
  }

  String _formatName(String name) {
    name = name.replaceAll('-', '_');
    name = name.replaceAll(' ', '_');
    var tokens = name.split('_');
    var first = tokens.removeAt(0).toLowerCase();
    tokens = tokens
        .map<String>((token) => toBeginningOfSentenceCase(token))
        .toList();
    var final_name = first + tokens.join();
    return final_name;
  }
}
