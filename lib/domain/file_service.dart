import 'dart:io';

class FileService {
  Future<void> writeJson(String json, String path) async {
    final file = File(path);
    await file.writeAsString(json);
  }
}