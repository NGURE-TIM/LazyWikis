import 'download_service_stub.dart'
    if (dart.library.html) 'download_service_web.dart';

abstract class DownloadService {
  void downloadFile(String filename, List<int> bytes, String mimeType);

  static DownloadService get instance => getDownloadService();
}
