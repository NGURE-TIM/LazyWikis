import 'link_opener_stub.dart' if (dart.library.html) 'link_opener_web.dart';

void openExternalLink(String url) => openExternalLinkImpl(url);
