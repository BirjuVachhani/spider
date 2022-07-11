import 'dart:io';

export 'extensions.dart';
export 'logging.dart';
export 'constants.dart';

/// Returns an instance of [File] if given [path] exists, null otherwise.
File? file(String path) {
  var file = File(path);
  return file.existsSync() ? file : null;
}
