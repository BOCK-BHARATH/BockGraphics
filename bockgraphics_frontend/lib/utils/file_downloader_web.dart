// lib/utils/file_downloader_web.dart
import 'dart:html' as html;
import 'file_downloader.dart';

class WebFileDownloader implements FileDownloader {
  @override
  Future<void> saveFile(List<int> bytes, String filename) async {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    html.AnchorElement(href: url)
      ..setAttribute("download", filename)
      ..click();

    html.Url.revokeObjectUrl(url);
  }
}

FileDownloader createDownloader() => WebFileDownloader();
