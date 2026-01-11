import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'file_downloader.dart';

class IOFileDownloader implements FileDownloader {
  static const _channel = MethodChannel('file_downloader');

  @override
  Future<void> saveFile(List<int> bytes, String filename) async {
    if (Platform.isAndroid) {
      await _channel.invokeMethod('saveToDownloads', {
        'bytes': bytes,
        'filename': filename,
      });
    } else if (Platform.isIOS) {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(bytes);
    }
  }
}

FileDownloader createDownloader() => IOFileDownloader();
