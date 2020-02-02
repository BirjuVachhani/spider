import 'dart:io';

File file(String path) {
  var file = File(path);
  return file.existsSync() ? file : null;
}
