// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'download_service.dart';

class ResultDownloadService implements DownloadService {
  @override
  void downloadFile(String filename, List<int> bytes, String mimeType) {
    final blob = html.Blob([bytes], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..target = 'blank'
      ..download = filename;

    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    html.Url.revokeObjectUrl(url);
  }
}

DownloadService getDownloadService() => ResultDownloadService();
