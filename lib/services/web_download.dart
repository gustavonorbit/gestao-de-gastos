// Conditional re-export for web download helper.
export 'web_download_stub.dart'
    if (dart.library.html) 'web_download_web.dart';
