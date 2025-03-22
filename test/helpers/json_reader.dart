import 'dart:io';

String readJson(String fileName) {
  String path = '${Directory.current.path}/test/helpers/dummydata/$fileName';
  return File(path).readAsStringSync();
}
