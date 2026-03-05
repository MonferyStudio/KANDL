// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';

/// Web implementation using HTML5 download
void downloadFile(String content, String fileName) {
  final bytes = utf8.encode(content);
  final blob = html.Blob([bytes], 'application/json');
  final url = html.Url.createObjectUrlFromBlob(blob);

  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..style.display = 'none';

  html.document.body?.children.add(anchor);
  anchor.click();

  // Cleanup
  html.document.body?.children.remove(anchor);
  html.Url.revokeObjectUrl(url);
}

Future<void> writeFile(String path, String content) async {
  // Not used on web - file picker handles this
  throw UnsupportedError('writeFile is not supported on web');
}

Future<String> readFile(String path) async {
  // Not used on web - file picker returns bytes directly
  throw UnsupportedError('readFile is not supported on web');
}
