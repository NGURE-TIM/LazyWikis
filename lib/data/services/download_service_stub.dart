import 'download_service.dart';

class StubDownloadService implements DownloadService {
  @override
  void downloadFile(String filename, List<int> bytes, String mimeType) {
    throw UnimplementedError('Download not implemented for this platform');
  }
}

DownloadService getDownloadService() => StubDownloadService();
