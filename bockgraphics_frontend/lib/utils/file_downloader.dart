// lib/utils/file_downloader.dart
import 'file_downloader_stub.dart'
    if (dart.library.html) 'file_downloader_web.dart'
    if (dart.library.io) 'file_downloader_io.dart';

abstract class FileDownloader {
  Future<void> saveFile(List<int> bytes, String filename);
}

FileDownloader getFileDownloader() => createDownloader();
