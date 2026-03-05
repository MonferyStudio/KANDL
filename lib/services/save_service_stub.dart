import 'dart:io';

/// Stub implementation for non-web platforms
void downloadFile(String content, String fileName) {
  // Not used on non-web platforms
  throw UnsupportedError('downloadFile is only supported on web');
}

Future<void> writeFile(String path, String content) async {
  final file = File(path);
  await file.writeAsString(content);
}

Future<String> readFile(String path) async {
  final file = File(path);
  return await file.readAsString();
}
